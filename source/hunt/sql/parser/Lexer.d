module hunt.sql.parser.Lexer;

/*
 * Copyright 2015-2018 HuntLabs.cn
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import hunt.sql.ast.expr.SQLNumberExpr;
import hunt.sql.dialect.mysql.parser.MySqlLexer;
import hunt.sql.parser.SymbolTable;
import hunt.sql.parser.CharTypes;
import hunt.sql.parser.LayoutCharacters;
import hunt.sql.parser.Token;
import hunt.sql.parser.Keywords;
import hunt.sql.parser.SQLParserFeature;
import hunt.sql.util.DBType;
import hunt.sql.parser.ParserException;
import hunt.sql.util.FnvHash;
import hunt.sql.util.Utils;
import hunt.Exceptions;
import hunt.sql.parser.SQLParserUtils;

import hunt.collection;
import std.string;
import std.bigint;
import std.xml;
import std.uni;
import std.conv;
import std.algorithm.mutation;
import hunt.Number;
import hunt.Long;
import hunt.Integer;
import hunt.String;
import hunt.math;
import hunt.text;

public class Lexer {
    public static SymbolTable symbols_l2;

    protected int          features       = 0; //SQLParserFeature.of(SQLParserFeature.EnableSQLBinaryOpExprGroup);
    public    string text;
    protected int          _pos;
    public int          _mark;

    protected char         ch;

    protected char[]       buf;
    protected int          bufPos;

    public Token        _token;

    protected Keywords     keywods;

    public string       _stringVal;
    protected long         _hash_lower; // fnv1a_64
    protected long         hash;

    public int            commentCount = 0;
    public List!string    comments     = null;
    protected bool        skipComment  = true;
    private SavePoint        savePoint    = null;

    /*
     * anti sql injection
     */
    private bool          allowComment = true;
    private int              varIndex     = -1;
    protected CommentHandler commentHandler;
    protected bool        endOfComment = false;
    protected bool        keepComments = false;
    protected int            line         = 0;
    protected int            lines        = 0;
    public string         dbType;

    protected bool        optimizedForParameterized = false;

    private int startPos;
    private int _posLine;
    private int _posColumn;

    public this(string input){
        this(input, null);
    }
    
    public this(string input, CommentHandler commentHandler){
        this(input, true);
        this.commentHandler = commentHandler;
    }

    public this(string input, CommentHandler commentHandler, string dbType){
        this(input, true);
        this.commentHandler = commentHandler;
        this.dbType = dbType;

        if (DBType.SQLITE == dbType) {
            this.keywods = Keywords.SQLITE_KEYWORDS;
        }
    }
    
    public bool isKeepComments() {
        return keepComments;
    }
    
    public void setKeepComments(bool keepComments) {
        this.keepComments = keepComments;
    }

    public CommentHandler getCommentHandler() {
        return commentHandler;
    }

    public void setCommentHandler(CommentHandler commentHandler) {
        this.commentHandler = commentHandler;
    }

    public  char charAt(int index) {
        if (index >= text.length) {
            return LayoutCharacters.EOI;
        }

        return .charAt(text,index);
    }

    public  string addSymbol() {
        return subString(_mark, bufPos);
    }

    public  string subString(int offset, int count) {
        return text.substring(offset, offset + count);
    }

    public  char[] sub_chars(int offset, int count) {
        // char[] chars = new char[count];
        // text.getChars(offset, offset + count, chars, 0);
        return cast(char[])text[offset .. offset + count];
    }

    protected void initBuff(int size) {
        if (buf is null) {
            if (size < 32) {
                buf = new char[32];
            } else {
                buf = new char[size + 32];
            }
        } else if (buf.length < size) {
            //buf = Arrays.copyOf(buf, size);
            auto tmp = new char[size];
            buf.copy(tmp);
            buf = tmp.dup;
        }
    }

    public void arraycopy(int srcPos, char[] dest, int destPos, int length) {
        //text.getChars(srcPos, srcPos + length, dest, destPos);
        dest[destPos .. destPos+length] = cast(char[])text[srcPos .. srcPos + length].dup;
    }

    public bool isAllowComment() {
        return allowComment;
    }

    public void setAllowComment(bool allowComment) {
        this.allowComment = allowComment;
    }

    public int nextVarIndex() {
        return ++varIndex;
    }

    public static class SavePoint {
        int   bp;
        int   sp;
        int   np;
        char  ch;
        long hash;
        long _hash_lower;
        public Token _token;
        string _stringVal;
    }

    public Keywords getKeywods() {
        return keywods;
    }

    public SavePoint mark() {
        SavePoint savePoint = new SavePoint();
        savePoint.bp = _pos;
        savePoint.sp = bufPos;
        savePoint.np = _mark;
        savePoint.ch = ch;
        savePoint._token = _token;
        savePoint._stringVal = _stringVal;
        savePoint.hash = hash;
        savePoint._hash_lower = _hash_lower;
        return this.savePoint = savePoint;
    }

    public void reset(SavePoint savePoint) {
        this._pos = savePoint.bp;
        this.bufPos = savePoint.sp;
        this._mark = savePoint.np;
        this.ch = savePoint.ch;
        this._token = savePoint._token;
        this._stringVal = savePoint._stringVal;
        this.hash = savePoint.hash;
        this._hash_lower = savePoint._hash_lower;
    }

    public void reset() {
        this.reset(this.savePoint);
    }

    public void reset(int _pos) {
        this._pos = _pos;
        this.ch = charAt(_pos);
    }

    public this(string input, bool skipComment){
        this.skipComment = skipComment;
        this.keywods       = Keywords.DEFAULT_KEYWORDS;
        this.text = input;
        this._pos = 0;
        ch = charAt(_pos);
    }

    public this(char[] input, int inputLength, bool skipComment){
        this(cast(string)input[0..inputLength], skipComment);
    }

    protected  void scanChar() {
        ch = charAt(++_pos);
    }
    
    protected void unscan() {
        ch = charAt(--_pos);
    }

    public bool isEOF() {
        return _pos >= text.length;
    }

    /**
     * Report an error at the given _position using the provided arguments.
     */
    protected void lexError(string key, Object[] args...) {
        _token = Token.ERROR;
    }

    /**
     * Return the current _token, set by nextToken().
     */
    public  Token token() {
        return _token;
    }

    public  string getDbType() {
        return this.dbType;
    }

    public string info() {
        int line = 1;
        int column = 1;
        for (int i = 0; i < startPos; ++i, column++) {
            char ch = .charAt(text, i);
            if (ch == '\n') {
                column = 1;
                line++;
            }
        }

        this._posLine = line;
        this._posColumn = _posColumn;

        StringBuilder buf = new StringBuilder();
        buf
                .append("_pos ")
                .append(_pos)
                .append(", line ")
                .append(line)
                .append(", column ")
                .append(column)
                .append(", _token ")
                .append(_token);

        if (_token == Token.IDENTIFIER || _token == Token.LITERAL_ALIAS || _token == Token.LITERAL_CHARS) {
            buf.append(" ").append(_stringVal);
        }

        return buf.toString();
    }

    public  void nextTokenComma() {
        if (ch == ' ') {
            scanChar();
        }

        if (ch == ',' || ch == '，') {
            scanChar();
            _token = Token.COMMA;
            return;
        }

        if (ch == ')' || ch == '）') {
            scanChar();
            _token = Token.RPAREN;
            return;
        }

        if (ch == '.') {
            scanChar();
            _token = Token.DOT;
            return;
        }

        if (ch == 'a' || ch == 'A') {
            char ch_next = charAt(_pos + 1);
            if (ch_next == 's' || ch_next == 'S') {
                char ch_next_2 = charAt(_pos + 2);
                if (ch_next_2 == ' ') {
                    _pos += 2;
                    ch = ' ';
                    _token = Token.AS;
                    _stringVal = "AS";
                    return;
                }
            }
        }

        nextToken();
    }

    public  void nextTokenCommaValue() {
        if (ch == ' ') {
            scanChar();
        }

        if (ch == ',' || ch == '，') {
            scanChar();
            _token = Token.COMMA;
            return;
        }

        if (ch == ')' || ch == '）') {
            scanChar();
            _token = Token.RPAREN;
            return;
        }

        if (ch == '.') {
            scanChar();
            _token = Token.DOT;
            return;
        }

        if (ch == 'a' || ch == 'A') {
            char ch_next = charAt(_pos + 1);
            if (ch_next == 's' || ch_next == 'S') {
                char ch_next_2 = charAt(_pos + 2);
                if (ch_next_2 == ' ') {
                    _pos += 2;
                    ch = ' ';
                    _token = Token.AS;
                    _stringVal = "AS";
                    return;
                }
            }
        }

        nextTokenValue();
    }

    public  void nextTokenEq() {
        if (ch == ' ') {
            scanChar();
        }

        if (ch == '=') {
            scanChar();
            _token = Token.EQ;
            return;
        }

        if (ch == '.') {
            scanChar();
            _token = Token.DOT;
            return;
        }

        if (ch == 'a' || ch == 'A') {
            char ch_next = charAt(_pos + 1);
            if (ch_next == 's' || ch_next == 'S') {
                char ch_next_2 = charAt(_pos + 2);
                if (ch_next_2 == ' ') {
                    _pos += 2;
                    ch = ' ';
                    _token = Token.AS;
                    _stringVal = "AS";
                    return;
                }
            }
        }

        nextToken();
    }

    public  void nextTokenLParen() {
        if (ch == ' ') {
            scanChar();
        }

        if (ch == '(' || ch == '（') {
            scanChar();
            _token = Token.LPAREN;
            return;
        }
        nextToken();
    }

    public  void nextTokenValue() {
        this.startPos = _pos;
        if (ch == ' ') {
            scanChar();
        }

        if (ch == '\'') {
            bufPos = 0;
            scanString();
            return;
        }

        if (ch == '"') {
            bufPos = 0;
            scanString2_d();
            return;
        }

        if (ch == '0') {
            bufPos = 0;
            if (charAt(_pos + 1) == 'x') {
                scanChar();
                scanChar();
                scanHexaDecimal();
            } else {
                scanNumber();
            }
            return;
        }

        if (ch > '0' && ch <= '9') {
            bufPos = 0;
            scanNumber();
            return;
        }

        if (ch == '?') {
            scanChar();
            _token = Token.QUES;
            return;
        }

        if (ch == 'n' || ch == 'N') {
            char c1 = 0, c2, c3, c4;
            if (_pos + 4 < text.length
                    && ((c1 = .charAt(text, _pos + 1)) == 'u' || c1 == 'U')
                    && ((c2 = .charAt(text, _pos + 2)) == 'l' || c2 == 'L')
                    && ((c3 = .charAt(text, _pos + 3)) == 'l' || c3 == 'L')
                    && (CharTypes.isWhitespace(c4 = .charAt(text, _pos + 4)) || c4 == ',' || c4 == ')')) {
                _pos += 4;
                ch = c4;
                _token = Token.NULL;
                _stringVal = "NULL";
                return;
            }

            if (c1 == '\'') {
                bufPos = 0;
                ++_pos;
                ch = '\'';
                scanString();
                _token = Token.LITERAL_NCHARS;
                return;
            }
        }

        if (ch == ')') {
            scanChar();
            _token = Token.RPAREN;
            return;
        }

        if (CharTypes.isFirstIdentifierChar(ch)) {
            scanIdentifier();
            return;
        }

        nextToken();
    }

    public  void nextTokenBy() {
        while (ch == ' ') {
            scanChar();
        }

        if (ch == 'b' || ch == 'B') {
            char ch_next = charAt(_pos + 1);
            if (ch_next == 'y' || ch_next == 'Y') {
                char ch_next_2 = charAt(_pos + 2);
                if (ch_next_2 == ' ') {
                    _pos += 2;
                    ch = ' ';
                    _token = Token.BY;
                    _stringVal = "BY";
                    return;
                }
            }
        }

        nextToken();
    }

    public  void nextTokenNotOrNull() {
        while (ch == ' ') {
            scanChar();
        }


        if ((ch == 'n' || ch == 'N') && _pos + 3 < text.length) {
            char c1 = .charAt(text, _pos + 1);
            char c2 = .charAt(text, _pos + 2);
            char c3 = .charAt(text, _pos + 3);

            if ((c1 == 'o' || c1 == 'O')
                    && (c2 == 't' || c2 == 'T')
                    && CharTypes.isWhitespace(c3)) {
                _pos += 3;
                ch = c3;
                _token = Token.NOT;
                _stringVal = "NOT";
                return;
            }

            char c4;
            if (_pos + 4 < text.length
                    && (c1 == 'u' || c1 == 'U')
                    && (c2 == 'l' || c2 == 'L')
                    && (c3 == 'l' || c3 == 'L')
                    && CharTypes.isWhitespace(c4 = .charAt(text, _pos + 4))) {
                _pos += 4;
                ch = c4;
                _token = Token.NULL;
                _stringVal = "NULL";
                return;
            }
        }

        nextToken();
    }

    public  void nextTokenIdent() {
        while (ch == ' ') {
            scanChar();
        }

        if (CharTypes.isFirstIdentifierChar(ch)) {
            scanIdentifier();
            return;
        }

        if (ch == ')') {
            scanChar();
            _token = Token.RPAREN;
            return;
        }

        nextToken();
    }

    public  void nextToken() {
        startPos = _pos;
        bufPos = 0;
        if (comments !is null && comments.size() > 0) {
            comments = null;
        }

        this.lines = 0;
        int startLine = line;
        
        for (;;) {
            if (CharTypes.isWhitespace(ch)) {
                if (ch == '\n') {
                    line++;
                    
                    lines = line - startLine;
                }

                ch = charAt(++_pos);
                continue;
            }

            if (ch == '$' && charAt(_pos + 1) == '{') {
                scanVariable();
                return;
            }

            if (CharTypes.isFirstIdentifierChar(ch)) {
                if (ch == '（') {
                    scanChar();
                    _token = Token.LPAREN;
                    return;
                } else if (ch == '）') {
                    scanChar();
                    _token = Token.RPAREN;
                    return;
                }

                if (ch == 'N' || ch == 'n') {
                    if (charAt(_pos + 1) == '\'') {
                        ++_pos;
                        ch = '\'';
                        scanString();
                        _token = Token.LITERAL_NCHARS;
                        return;
                    }
                }

                scanIdentifier();
                return;
            }

            switch (ch) {
                case '0':
                    if (charAt(_pos + 1) == 'x') {
                        scanChar();
                        scanChar();
                        scanHexaDecimal();
                    } else {
                        scanNumber();
                    }
                    return;
                case '1':
                case '2':
                case '3':
                case '4':
                case '5':
                case '6':
                case '7':
                case '8':
                case '9':
                    scanNumber();
                    return;
                case ',':
                case '，':
                    scanChar();
                    _token = Token.COMMA;
                    return;
                case '(':
                case '（':
                    scanChar();
                    _token = Token.LPAREN;
                    return;
                case ')':
                case '）':
                    scanChar();
                    _token = Token.RPAREN;
                    return;
                case '[':
                    scanLBracket();
                    return;
                case ']':
                    scanChar();
                    _token = Token.RBRACKET;
                    return;
                case '{':
                    scanChar();
                    _token = Token.LBRACE;
                    return;
                case '}':
                    scanChar();
                    _token = Token.RBRACE;
                    return;
                case ':':
                    scanChar();
                    if (ch == '=') {
                        scanChar();
                        _token = Token.COLONEQ;
                    } else if (ch == ':') {
                        scanChar();
                        _token = Token.COLONCOLON;
                    } else {
                        unscan();
                        scanVariable();
                    }
                    return;
                case '#':
                    scanSharp();
                    if ((_token == Token.LINE_COMMENT || _token == Token.MULTI_LINE_COMMENT) && skipComment) {
                        bufPos = 0;
                        continue;
                    }
                    return;
                case '.':
                    scanChar();
                    if (isDigit(ch) && !CharTypes.isFirstIdentifierChar(charAt(pos - 2))) {
                        unscan();
                        scanNumber();
                        return;
                    } else if (ch == '.') {
                        scanChar();
                        if (ch == '.') {
                            scanChar();
                            _token = Token.DOTDOTDOT;
                        } else {
                            _token = Token.DOTDOT;
                        }
                    } else {
                        _token = Token.DOT;
                    }
                    return;
                case '\'':
                    scanString();
                    return;
                case '\"':
                    scanAlias();
                    return;
                case '*':
                    scanChar();
                    _token = Token.STAR;
                    return;
                case '?':
                    scanChar();
                    if (ch == '?' && DBType.POSTGRESQL == dbType) {
                        scanChar();
                        if (ch == '|') {
                            scanChar();
                            _token = Token.QUESBAR;
                        } else {
                            _token = Token.QUESQUES;
                        }
                    } else if (ch == '|' && DBType.POSTGRESQL == (dbType)) {
                        scanChar();
                        if (ch == '|') {
                            unscan();
                            _token = Token.QUES;
                        } else {
                            _token = Token.QUESBAR;
                        }
                    } else if (ch == '&' && DBType.POSTGRESQL == (dbType)) {
                        scanChar();
                        _token = Token.QUESAMP;
                    } else {
                        _token = Token.QUES;
                    }
                    return;
                case ';':
                    scanChar();
                    _token = Token.SEMI;
                    return;
                case '`':
                    throw new ParserException("TODO. " ~ info()); // TODO
                case '@':
                    scanVariable_at();
                    return;
                case '-':
                    if (charAt(_pos +1) == '-') {
                        scanComment();
                        if ((_token == Token.LINE_COMMENT || _token == Token.MULTI_LINE_COMMENT) && skipComment) {
                            bufPos = 0;
                            continue;
                        }
                    } else {
                        scanOperator();
                    }
                    return;
                case '/':
                    int nextChar = charAt(_pos + 1);
                    if (nextChar == '/' || nextChar == '*') {
                        scanComment();
                        if ((_token == Token.LINE_COMMENT || _token == Token.MULTI_LINE_COMMENT) && skipComment) {
                            bufPos = 0;
                            continue;
                        }
                    } else {
                        _token = Token.SLASH;
                        scanChar();
                    }
                    return;
                default:
                    if (isLetter(ch)) {
                        scanIdentifier();
                        return;
                    }

                    if (isOperator(ch)) {
                        scanOperator();
                        return;
                    }

                    if (ch == '\\' && charAt(_pos + 1) == 'N'
                            && DBType.MYSQL == (dbType)) {
                        scanChar();
                        scanChar();
                        _token = Token.NULL;
                        return;
                    }

                    // QS_TODO ?
                    if (isEOF()) { // JLS
                        _token = Token.EOF;
                    } else {
                        //lexError("illegal.char", String.valueOf((int) ch));
                        scanChar();
                    }

                    return;
            }
        }

    }

    protected void scanLBracket() {
        scanChar();
        _token = Token.LBRACKET;
    }

    private  void scanOperator() {
        switch (ch) {
            case '+':
                scanChar();
                _token = Token.PLUS;
                break;
            case '-':
                scanChar();
                if (ch == '>') {
                    scanChar();
                    if (ch == '>') {
                        scanChar();
                        _token = Token.SUBGTGT;
                    } else {
                        _token = Token.SUBGT;
                    }
                } else {
                    _token = Token.SUB;    
                }
                break;
            case '*':
                scanChar();
                _token = Token.STAR;
                break;
            case '/':
                scanChar();
                _token = Token.SLASH;
                break;
            case '&':
                scanChar();
                if (ch == '&') {
                    scanChar();
                    _token = Token.AMPAMP;
                } else {
                    _token = Token.AMP;
                }
                break;
            case '|':
                scanChar();
                if (ch == '|') {
                    scanChar();
                    if (ch == '/') {
                        scanChar();
                        _token = Token.BARBARSLASH; 
                    } else {
                        _token = Token.BARBAR;
                    }
                } else if (ch == '/') {
                    scanChar();
                    _token = Token.BARSLASH;
                } else {
                    _token = Token.BAR;
                }
                break;
            case '^':
                scanChar();
                if (ch == '=') {
                    scanChar();
                    _token = Token.CARETEQ;
                } else {
                    _token = Token.CARET;
                }
                break;
            case '%':
                scanChar();
                _token = Token.PERCENT;
                break;
            case '=':
                scanChar();
                if (ch == '=') {
                    scanChar();
                    _token = Token.EQEQ;
                } else if (ch == '>') {
                    scanChar();
                    _token = Token.EQGT;
                } else {
                    _token = Token.EQ;
                }
                break;
            case '>':
                scanChar();
                if (ch == '=') {
                    scanChar();
                    _token = Token.GTEQ;
                } else if (ch == '>') {
                    scanChar();
                    _token = Token.GTGT;
                } else {
                    _token = Token.GT;
                }
                break;
            case '<':
                scanChar();
                if (ch == '=') {
                    scanChar();
                    if (ch == '>') {
                        _token = Token.LTEQGT;
                        scanChar();
                    } else {
                        _token = Token.LTEQ;
                    }
                } else if (ch == '>') {
                    scanChar();
                    _token = Token.LTGT;
                } else if (ch == '<') {
                    scanChar();
                    _token = Token.LTLT;
                } else if (ch == '@') {
                    scanChar();
                    _token = Token.LT_MONKEYS_AT;
                } else if (ch == '-' && charAt(_pos + 1) == '>') {
                    scanChar();
                    scanChar();
                    _token = Token.LT_SUB_GT;
                } else {
                    if (ch == ' ') {
                        char c1 = charAt(_pos + 1);
                        if (c1 == '=') {
                            scanChar();
                            scanChar();
                            if (ch == '>') {
                                _token = Token.LTEQGT;
                                scanChar();
                            } else {
                                _token = Token.LTEQ;
                            }
                        } else if (c1 == '>') {
                            scanChar();
                            scanChar();
                            _token = Token.LTGT;
                        } else if (c1 == '<') {
                            scanChar();
                            scanChar();
                            _token = Token.LTLT;
                        } else if (c1 == '@') {
                            scanChar();
                            scanChar();
                            _token = Token.LT_MONKEYS_AT;
                        } else if (c1 == '-' && charAt(_pos + 2) == '>') {
                            scanChar();
                            scanChar();
                            scanChar();
                            _token = Token.LT_SUB_GT;
                        } else {
                            _token = Token.LT;
                        }
                    } else {
                        _token = Token.LT;
                    }
                }
                break;
            case '!':
                scanChar();
                while (CharTypes.isWhitespace(ch)) {
                    scanChar();
                }
                if (ch == '=') {
                    scanChar();
                    _token = Token.BANGEQ;
                } else if (ch == '>') {
                    scanChar();
                    _token = Token.BANGGT;
                } else if (ch == '<') {
                    scanChar();
                    _token = Token.BANGLT;
                } else if (ch == '!') {
                    scanChar();
                    _token = Token.BANGBANG; // _postsql
                } else if (ch == '~') {
                    scanChar();
                    if (ch == '*') {
                        scanChar();
                        _token = Token.BANG_TILDE_STAR; // _postsql
                    } else {
                        _token = Token.BANG_TILDE; // _postsql
                    }
                } else {
                    _token = Token.BANG;
                }
                break;
            case '?':
                scanChar();
                _token = Token.QUES;
                break;
            case '~':
                scanChar();
                if (ch == '*') {
                    scanChar();
                    _token = Token.TILDE_STAR;
                } else if (ch == '=') {
                    scanChar();
                    _token = Token.TILDE_EQ; // _postsql
                } else {
                    _token = Token.TILDE;
                }
                break;
            default:
                throw new ParserException("TODO. " ~ info());
        }
    }

    protected void scanString() {
        _mark = _pos;
        bool hasSpecial = false;
        Token preToken = this._token;

        for (;;) {
            if (isEOF()) {
                lexError("unclosed.str.lit");
                return;
            }

            ch = charAt(++_pos);

            if (ch == '\'') {
                scanChar();
                if (ch != '\'') {
                    _token = Token.LITERAL_CHARS;
                    break;
                } else {
                    if (!hasSpecial) {
                        initBuff(bufPos);
                        arraycopy(_mark + 1, buf, 0, bufPos);
                        hasSpecial = true;
                    }
                    putChar('\'');
                    continue;
                }
            }

            if (!hasSpecial) {
                bufPos++;
                continue;
            }

            if (bufPos == buf.length) {
                putChar(ch);
            } else {
                buf[bufPos++] = ch;
            }
        }

        if (!hasSpecial) {
            if (preToken == Token.AS) {
                _stringVal = subString(_mark, bufPos + 2);
            } else {
                _stringVal = subString(_mark + 1, bufPos);
            }
        } else {
            _stringVal = cast(string)buf[0..bufPos];
        }
    }
    
    protected  void scanString2() {
        {
            bool hasSpecial = false;
            int startIndex = _pos + 1;
            int endIndex = -1; // text.indexOf('\'', startIndex);
            for (int i = startIndex; i < text.length; ++i) {
                 char ch = .charAt(text, i);
                if (ch == '\\') {
                    hasSpecial = true;
                    continue;
                }
                if (ch == '\'') {
                    endIndex = i;
                    break;
                }
            }

            if (endIndex == -1) {
                throw new ParserException("unclosed str. " ~ info());
            }

            string _stringVal;
            if (_token == Token.AS) {
                _stringVal = subString(_pos, endIndex + 1 - _pos);
            } else {
                _stringVal = subString(startIndex, endIndex - startIndex);
            }
            // hasSpecial = _stringVal.indexOf('\\') != -1;

            if (!hasSpecial) {
                this._stringVal = _stringVal;
                int _pos = endIndex + 1;
                char ch = charAt(_pos);
                if (ch != '\'') {
                    this._pos = _pos;
                    this.ch = ch;
                    _token = Token.LITERAL_CHARS;
                    return;
                }
            }
        }

        _mark = _pos;
        bool hasSpecial = false;
        for (;;) {
            if (isEOF()) {
                lexError("unclosed.str.lit");
                return;
            }

            ch = charAt(++_pos);

            if (ch == '\\') {
                scanChar();
                if (!hasSpecial) {
                    initBuff(bufPos);
                    arraycopy(_mark + 1, buf, 0, bufPos);
                    hasSpecial = true;
                }

                switch (ch) {
                    case '0':
                        putChar('\0');
                        break;
                    case '\'':
                        putChar('\'');
                        break;
                    case '"':
                        putChar('"');
                        break;
                    case 'b':
                        putChar('\b');
                        break;
                    case 'n':
                        putChar('\n');
                        break;
                    case 'r':
                        putChar('\r');
                        break;
                    case 't':
                        putChar('\t');
                        break;
                    case '\\':
                        putChar('\\');
                        break;
                    case '_':
                        if(DBType.MYSQL == (dbType)) {
                            putChar('\\');
                        }
                        putChar('_');
                        break;
                    case 'Z':
                        putChar(cast(char) 0x1A); // ctrl + Z
                        break;
                    case '%':
                        putChar('\\');
                        putChar(ch);
                        break;
                    default:
                        putChar(ch);
                        break;
                }

                continue;
            }
            if (ch == '\'') {
                scanChar();
                if (ch != '\'') {
                    _token = Token.LITERAL_CHARS;
                    break;
                } else {
                    if (!hasSpecial) {
                        initBuff(bufPos);
                        arraycopy(_mark + 1, buf, 0, bufPos);
                        hasSpecial = true;
                    }
                    putChar('\'');
                    continue;
                }
            }

            if (!hasSpecial) {
                bufPos++;
                continue;
            }

            if (bufPos == buf.length) {
                putChar(ch);
            } else {
                buf[bufPos++] = ch;
            }
        }

        if (!hasSpecial) {
            _stringVal = subString(_mark + 1, bufPos);
        } else {
            _stringVal = cast(string)buf[0..bufPos];
        }
    }

    protected  void scanString2_d() {
        {
            bool hasSpecial = false;
            int startIndex = _pos + 1;
            int endIndex = -1; // text.indexOf('\'', startIndex);
            for (int i = startIndex; i < text.length; ++i) {
                 char ch = .charAt(text, i);
                if (ch == '\\') {
                    hasSpecial = true;
                    continue;
                }
                if (ch == '"') {
                    endIndex = i;
                    break;
                }
            }

            if (endIndex == -1) {
                throw new ParserException("unclosed str. " ~ info());
            }

            string _stringVal;
            if (_token == Token.AS) {
                _stringVal = subString(_pos, endIndex + 1 - _pos);
            } else {
                _stringVal = subString(startIndex, endIndex - startIndex);
            }
            // hasSpecial = _stringVal.indexOf('\\') != -1;

            if (!hasSpecial) {
                this._stringVal = _stringVal;
                int _pos = endIndex + 1;
                char ch = charAt(_pos);
                if (ch != '\'') {
                    this._pos = _pos;
                    this.ch = ch;
                    _token = Token.LITERAL_CHARS;
                    return;
                }
            }
        }

        _mark = _pos;
        bool hasSpecial = false;
        for (;;) {
            if (isEOF()) {
                lexError("unclosed.str.lit");
                return;
            }

            ch = charAt(++_pos);

            if (ch == '\\') {
                scanChar();
                if (!hasSpecial) {
                    initBuff(bufPos);
                    arraycopy(_mark + 1, buf, 0, bufPos);
                    hasSpecial = true;
                }


                switch (ch) {
                    case '0':
                        putChar('\0');
                        break;
                    case '\'':
                        putChar('\'');
                        break;
                    case '"':
                        putChar('"');
                        break;
                    case 'b':
                        putChar('\b');
                        break;
                    case 'n':
                        putChar('\n');
                        break;
                    case 'r':
                        putChar('\r');
                        break;
                    case 't':
                        putChar('\t');
                        break;
                    case '\\':
                        putChar('\\');
                        break;
                    case 'Z':
                        putChar(cast(char) 0x1A); // ctrl + Z
                        break;
                    case '%':
                        if(DBType.MYSQL == (dbType)) {
                            putChar('\\');
                        }
                        putChar('%');
                        break;
                    case '_':
                        if(DBType.MYSQL == (dbType)) {
                            putChar('\\');
                        }
                        putChar('_');
                        break;
                    default:
                        putChar(ch);
                        break;
                }

                continue;
            }
            if (ch == '"') {
                scanChar();
                if (ch != '"') {
                    _token = Token.LITERAL_CHARS;
                    break;
                } else {
                    if (!hasSpecial) {
                        initBuff(bufPos);
                        arraycopy(_mark + 1, buf, 0, bufPos);
                        hasSpecial = true;
                    }
                    putChar('"');
                    continue;
                }
            }

            if (!hasSpecial) {
                bufPos++;
                continue;
            }

            if (bufPos == buf.length) {
                putChar(ch);
            } else {
                buf[bufPos++] = ch;
            }
        }

        if (!hasSpecial) {
            _stringVal = subString(_mark + 1, bufPos);
        } else {
            _stringVal = cast(string)buf[0..bufPos];
        }
    }
    
    protected  void scanAlias() {
        {
            bool hasSpecial = false;
            int startIndex = _pos + 1;
            int endIndex = -1; // text.indexOf('\'', startIndex);
            for (int i = startIndex; i < text.length; ++i) {
                 char ch = .charAt(text, i);
                if (ch == '\\') {
                    hasSpecial = true;
                    continue;
                }
                if (ch == '"') {
                    if (i + 1 < text.length) {
                        char ch_next = charAt(i + 1);
                        if (ch_next == '"' || ch_next == '\'') {
                            hasSpecial = true;
                            i++;
                            continue;
                        }
                    }
                    if (i > 0) {
                        char ch_last = charAt(i - 1);
                        if (ch_last == '\'') {
                            hasSpecial = true;
                            continue;
                        }
                    }
                    endIndex = i;
                    break;
                }
            }

            if (endIndex == -1) {
                throw new ParserException("unclosed str. " ~ info());
            }

            string _stringVal = subString(_pos, endIndex + 1 - _pos);
            // hasSpecial = _stringVal.indexOf('\\') != -1;

            if (!hasSpecial) {
                this._stringVal = _stringVal;
                int _pos = endIndex + 1;
                char ch = charAt(_pos);
                if (ch != '\'') {
                    this._pos = _pos;
                    this.ch = ch;
                    _token = Token.LITERAL_ALIAS;
                    return;
                }
            }
        }

        _mark = _pos;
        initBuff(bufPos);
        //putChar(ch);

        for (;;) {
            if (isEOF()) {
                lexError("unclosed.str.lit");
                return;
            }

            ch = charAt(++_pos);

            if (ch == '\\') {
                scanChar();

                switch (ch) {
                    case '0':
                        putChar('\0');
                        break;
                    case '\'':
                        putChar('\'');
                        break;
                    case '"':
                        putChar('"');
                        break;
                    case 'b':
                        putChar('\b');
                        break;
                    case 'n':
                        putChar('\n');
                        break;
                    case 'r':
                        putChar('\r');
                        break;
                    case 't':
                        putChar('\t');
                        break;
                    case '\\':
                        putChar('\\');
                        break;
                    case 'Z':
                        putChar(cast(char) 0x1A); // ctrl + Z
                        break;
                    default:
                        putChar(ch);
                        break;
                }

                continue;
            }

//            if (ch == '\'') {
//                char ch_next = charAt(_pos + 1);
//                if (ch_next == '"') {
//                    scanChar();
//                    continue;
//                }
//            } else
            if (ch == '\"') {
                char ch_next = charAt(_pos + 1);
                if (ch_next == '"' || ch_next == '\'') {
                    scanChar();
                    continue;
                }

                //putChar(ch);
                scanChar();
                _token = Token.LITERAL_CHARS;
                break;
            }

            if (bufPos == buf.length) {
                putChar(ch);
            } else {
                buf[bufPos++] = ch;
            }
        }

        _stringVal = cast(string)buf[0..bufPos];
    }
    
    public void scanSharp() {
        scanVariable();
    }

    public void scanVariable() {
        if (ch != ':' && ch != '#' && ch != '$') {
            throw new ParserException("illegal variable. " ~ info());
        }

        _mark = _pos;
        bufPos = 1;
        char ch;

         char c1 = charAt(_pos + 1);
        if (c1 == '>' && DBType.POSTGRESQL == toLower(dbType)) {
            _pos += 2;
            _token = Token.MONKEYS_AT_GT;
            this.ch = charAt(++_pos);
            return;
        } else if (c1 == '{') {
            _pos++;
            bufPos++;
            
            for (;;) {
                ch = charAt(++_pos);

                if (ch == '}') {
                    break;
                }

                bufPos++;
                continue;
            }
            
            if (ch != '}') {
                throw new ParserException("syntax error. " ~ info());
            }
            ++_pos;
            bufPos++;
            
            this.ch = charAt(_pos);

            _stringVal = addSymbol();
            _token = Token.VARIANT;
            return;
        }

        for (;;) {
            ch = charAt(++_pos);

            if (!CharTypes.isIdentifierChar(ch)) {
                break;
            }

            bufPos++;
            continue;
        }

        this.ch = charAt(_pos);

        _stringVal = addSymbol();
        _token = Token.VARIANT;
    }

    protected void scanVariable_at() {
        if (ch != '@') {
            throw new ParserException("illegal variable. " ~ info());
        }

        _mark = _pos;
        bufPos = 1;
        char ch;

         char c1 = charAt(_pos + 1);
        if (c1 == '@') {
            ++_pos;
            bufPos++;
        }

        for (;;) {
            ch = charAt(++_pos);

            if (!CharTypes.isIdentifierChar(ch)) {
                break;
            }

            bufPos++;
            continue;
        }

        this.ch = charAt(_pos);

        _stringVal = addSymbol();
        _token = Token.VARIANT;
    }

    public void scanComment() {
        if (!allowComment) {
            throw new Exception("not allow comment");
        }

        if ((ch == '/' && charAt(_pos + 1) == '/')
                || (ch == '-' && charAt(_pos + 1) == '-')) {
            scanSingleLineComment();
        } else if (ch == '/' && charAt(_pos + 1) == '*') {
            scanMultiLineComment();
        } else {
            throw new Exception("Exception");
        }
    }

    private void scanMultiLineComment() {
        Token lastToken = this._token;
        
        scanChar();
        scanChar();
        _mark = _pos;
        bufPos = 0;

        for (;;) {
            if (ch == '*' && charAt(_pos + 1) == '/') {
                scanChar();
                scanChar();
                break;
            }
            
			// multiline comment结束符错误
			if (ch == LayoutCharacters.EOI) {
				throw new ParserException("unterminated /* comment. " ~ info());
			}
            scanChar();
            bufPos++;
        }

        _stringVal = subString(_mark, bufPos);
        _token = Token.MULTI_LINE_COMMENT;
        commentCount++;
        if (keepComments) {
            addComment(_stringVal);
        }
        
        if (commentHandler !is null && commentHandler.handle(lastToken, _stringVal)) {
            return;
        }
        
        if (!isAllowComment() && !isSafeComment(_stringVal)) {
            throw new Exception("NotAllowComment");
        }
    }

    private void scanSingleLineComment() {
        Token lastToken = this._token;
        
        scanChar();
        scanChar();
        _mark = _pos;
        bufPos = 0;

        for (;;) {
            if (ch == '\r') {
                if (charAt(_pos + 1) == '\n') {
                    line++;
                    scanChar();
                    break;
                }
                bufPos++;
                break;
            }

            if (ch == '\n') {
                line++;
                scanChar();
                break;
            }
            
			// single line comment结束符错误
			if (ch == LayoutCharacters.EOI) {
				throw new ParserException("syntax error at end of input. " ~ info());
			}

            scanChar();
            bufPos++;
        }

        _stringVal = subString(_mark, bufPos);
        _token = Token.LINE_COMMENT;
        commentCount++;
        if (keepComments) {
            addComment(_stringVal);
        }
        
        if (commentHandler !is null && commentHandler.handle(lastToken, _stringVal)) {
            return;
        }
        
        if (!isAllowComment() && !isSafeComment(_stringVal)) {
            throw new Exception("NotAllowComment");
        }
    }

    public void scanIdentifier() {
        this._hash_lower = 0;
        this.hash = 0;

         char first = ch;

        if (ch == '`') {
            _mark = _pos;
            bufPos = 1;
            char ch;

            int startPos = _pos + 1;
            int quoteIndex = cast(int)text.indexOf('`', cast(ulong)startPos);
            if (quoteIndex == -1) {
                throw new ParserException("illegal identifier. " ~ info());
            }

            _hash_lower = 0xcbf29ce484222325L;
            hash = 0xcbf29ce484222325L;

            for (int i = startPos; i < quoteIndex; ++i) {
                ch = .charAt(text, i);

                _hash_lower ^= ((ch >= 'A' && ch <= 'Z') ? (ch + 32) : ch);
                _hash_lower *= 0x100000001b3L;

                hash ^= ch;
                hash *= 0x100000001b3L;
            }

            _stringVal = MySqlLexer.quoteTable.addSymbol(text, _pos, quoteIndex + 1 - _pos, hash); //@gxc
            //_stringVal = text.substring(_mark, _pos);
            _pos = quoteIndex + 1;
            this.ch = charAt(_pos);
            _token = Token.IDENTIFIER;
            return;
        }

         bool firstFlag = CharTypes.isFirstIdentifierChar(first);
        if (!firstFlag) {
            throw new ParserException("illegal identifier. " ~ info());
        }

        _hash_lower = 0xcbf29ce484222325L;
        hash = 0xcbf29ce484222325L;

        _hash_lower ^= ((ch >= 'A' && ch <= 'Z') ? (ch + 32) : ch);
        _hash_lower *= 0x100000001b3L;

        hash ^= ch;
        hash *= 0x100000001b3L;

        _mark = _pos;
        bufPos = 1;
        char ch;
        for (;;) {
            ch = charAt(++_pos);

            if (!CharTypes.isIdentifierChar(ch)) {
                break;
            }

            _hash_lower ^= ((ch >= 'A' && ch <= 'Z') ? (ch + 32) : ch);
            _hash_lower *= 0x100000001b3L;

            hash ^= ch;
            hash *= 0x100000001b3L;

            bufPos++;
            continue;
        }

        this.ch = charAt(_pos);

        if (bufPos == 1) {
            _token = Token.IDENTIFIER;
            _stringVal = CharTypes.valueOf(first);
            if (_stringVal is null) {
                _stringVal = to!string(first);
            }
            return;
        }

        Token tok = keywods.getKeyword(_hash_lower);
        if (tok !is null) {
            _token = tok;
            if (_token == Token.IDENTIFIER) {
                _stringVal = SymbolTable.global.addSymbol(text, _mark, bufPos, hash);
            } else {
                _stringVal = null;
            }
        } else {
            _token = Token.IDENTIFIER;
            _stringVal = SymbolTable.global.addSymbol(text, _mark, bufPos, hash);
        }
    }

    public void scanNumber() {
        _mark = _pos;

        if (ch == '-') {
            bufPos++;
            ch = charAt(++_pos);
        }

        for (;;) {
            if (ch >= '0' && ch <= '9') {
                bufPos++;
            } else {
                break;
            }
            ch = charAt(++_pos);
        }

        bool isDouble = false;

        if (ch == '.') {
            if (charAt(_pos + 1) == '.') {
                _token = Token.LITERAL_INT;
                return;
            }
            bufPos++;
            ch = charAt(++_pos);
            isDouble = true;

            for (;;) {
                if (ch >= '0' && ch <= '9') {
                    bufPos++;
                } else {
                    break;
                }
                ch = charAt(++_pos);
            }
        }

        if (ch == 'e' || ch == 'E') {
            bufPos++;
            ch = charAt(++_pos);

            if (ch == '+' || ch == '-') {
                bufPos++;
                ch = charAt(++_pos);
            }

            for (;;) {
                if (ch >= '0' && ch <= '9') {
                    bufPos++;
                } else {
                    break;
                }
                ch = charAt(++_pos);
            }

            isDouble = true;
        }

        if (isDouble) {
            _token = Token.LITERAL_FLOAT;
        } else {
            _token = Token.LITERAL_INT;
        }
    }

    public void scanHexaDecimal() {
        _mark = _pos;

        if (ch == '-') {
            bufPos++;
            ch = charAt(++_pos);
        }

        for (;;) {
            if (CharTypes.isHex(ch)) {
                bufPos++;
            } else {
                break;
            }
            ch = charAt(++_pos);
        }

        _token = Token.LITERAL_HEX;
    }

    public string hexString() {
        return subString(_mark, bufPos);
    }

    public  bool isDigit(char ch) {
        return ch >= '0' && ch <= '9';
    }

    /**
     * Append a character to sbuf.
     */
    protected  void putChar(char ch) {
        if (bufPos == buf.length) {
            char[] newsbuf = new char[buf.length * 2];
            buf.copy(newsbuf);
           // System.arraycopy(buf, 0, newsbuf, 0, buf.length);
            buf = newsbuf;
        }
        buf[bufPos++] = ch;
    }

    /**
     * Return the current _token's _position: a 0-based offset from beginning of the raw input stream (before unicode
     * translation)
     */
    public  int pos() {
        return _pos;
    }

    /**
     * The value of a literal _token, recorded as a string. For integers, leading 0x and 'l' suffixes are suppressed.
     */
    public  string stringVal() {
        if (_stringVal is null) {
            _stringVal = subString(_mark, bufPos);
        }
        return _stringVal;
    }

    private  void stringVal(StringBuffer sb) {
        if (_stringVal !is null) {
            sb.append(_stringVal);
            return;
        }

        sb.append(text, _mark, _mark + bufPos);
    }

    public  bool identifierEquals(string text) {
        if (_token != Token.IDENTIFIER) {
            return false;
        }

        if (_stringVal is null) {
            _stringVal = subString(_mark, bufPos);
        }
        return toLower(text) == toLower(_stringVal);
    }

    public  bool identifierEquals(long _hash_lower) {
        if (_token != Token.IDENTIFIER) {
            return false;
        }

        if (this._hash_lower == 0) {
            if (_stringVal is null) {
                _stringVal = subString(_mark, bufPos);
            }
            this._hash_lower = FnvHash.fnv1a_64_lower(_stringVal);
        }
        return this._hash_lower == _hash_lower;
    }

    public  long hash_lower() {
        if (this._hash_lower == 0) {
            if (_stringVal is null) {
                _stringVal = subString(_mark, bufPos);
            }
            this._hash_lower = FnvHash.fnv1a_64_lower(_stringVal);
        }
        return _hash_lower;
    }
    
    public  List!string readAndResetComments() {
        List!string comments = this.comments;
        
        this.comments = null;
        
        return comments;
    }

    private bool isOperator(char ch) {
        switch (ch) {
            case '!':
            case '%':
            case '&':
            case '*':
            case '+':
            case '-':
            case '<':
            case '=':
            case '>':
            case '^':
            case '|':
            case '~':
            case ';':
                return true;
            default:
                return false;
        }
    }

    private static  long  MULTMIN_RADIX_TEN   = long.min / 10;
    private static  long  N_MULTMAX_RADIX_TEN = -long.max / 10;

    public  static int[] digits              = new int[cast(int) '9' + 1];

    // static this(){
    //     symbols_l2 = new SymbolTable(512);
    //     for (int i = '0'; i <= '9'; ++i) {
    //         digits[i] = i - '0';
    //     }
    // }

    // QS_TODO negative number is invisible for lexer
     public Number integerValue() {
        long result = 0;
        bool negative = false;
        int i = _mark, max = _mark + bufPos;
        long limit;
        long multmin;
        int digit;

        if (charAt(_mark) == '-') {
            negative = true;
            limit = Long.MIN_VALUE;
            i++;
        } else {
            limit = -Long.MAX_VALUE;
        }
        multmin = negative ? MULTMIN_RADIX_TEN : N_MULTMAX_RADIX_TEN;
        if (i < max) {
            digit = charAt(i++) - '0';
            result = -digit;
        }
        while (i < max) {
            // Accumulating negatively avoids surprises near MAX_VALUE
            digit = charAt(i++) - '0';
            if (result < multmin) {
                return new BigInteger(numberString());
            }
            result *= 10;
            if (result < limit + digit) {
                return new BigInteger(numberString());
            }
            result -= digit;
        }

        if (negative) {
            if (i > _mark + 1) {
                if (result >= Integer.MIN_VALUE) {
                    return new Integer(cast(int)result);
                }
                return new Long(result);
            } else { /* Only got "-" */
                throw new Exception(numberString());
            }
        } else {
            result = -result;
            if (result <= Integer.MAX_VALUE) {
                return new Integer(cast(int)result);
            }
            return new Long(result);
        }
    }

    public int bp() {
        return this._pos;
    }

    public char current() {
        return this.ch;
    }

    public void reset(int _mark, char _markChar, Token _token) {
        this._pos = _mark;
        this.ch = _markChar;
        this._token = _token;
    }

    public  string numberString() {
        return subString(_mark, bufPos);
    }

    public BigDecimal decimalValue() {
        // char[] value = sub_chars(_mark, bufPos);
        // if (!isNumeric(value)){
        //     throw new ParserException(value+" is not a number! " ~ info());
        // }
        implementationMissing();
        return BigDecimal.init;
    }

    public SQLNumberExpr numberExpr() {
        char[] value = sub_chars(_mark, bufPos);
        if (!isNumeric(value)){
            throw new ParserException( cast(string)value ~ " is not a number! " ~ info());
        }

        return new SQLNumberExpr(value);
    }

    public SQLNumberExpr numberExpr(bool negate) {
        char[] value = sub_chars(_mark, bufPos);
        if (!isNumeric(value)){
            throw new ParserException(cast(string)value ~ " is not a number! " ~ info());
        }

        if (negate) {
            char[] chars = new char[value.length + 1];
            chars[0] = '-';
            // System.arraycopy(value, 0, chars, 1, value.length);
            value.copy(chars);
            return new SQLNumberExpr(chars);
        } else {
            return new SQLNumberExpr(value);
        }
    }

    public static interface CommentHandler {
        bool handle(Token lastToken, string comment);
    }

    public bool hasComment() {
        return comments !is null;
    }

    public int getCommentCount() {
        return commentCount;
    }
    
    public void skipToEOF() {
        _pos = cast(int)text.length;
        this._token = Token.EOF;
    }

    public bool isEndOfComment() {
        return endOfComment;
    }
    
    protected bool isSafeComment(string comment) {
        if (comment is null) {
            return true;
        }
        comment = toLower(comment);
        if (comment.indexOf("select") != -1 //
            || comment.indexOf("delete") != -1 //
            || comment.indexOf("insert") != -1 //
            || comment.indexOf("update") != -1 //
            || comment.indexOf("into") != -1 //
            || comment.indexOf("where") != -1 //
            || comment.indexOf("or") != -1 //
            || comment.indexOf("and") != -1 //
            || comment.indexOf("union") != -1 //
            || comment.indexOf('\'') != -1 //
            || comment.indexOf('=') != -1 //
            || comment.indexOf('>') != -1 //
            || comment.indexOf('<') != -1 //
            || comment.indexOf('&') != -1 //
            || comment.indexOf('|') != -1 //
            || comment.indexOf('^') != -1 //
        ) {
            return false;
        }
        return true;
    }

    protected void addComment(string comment) {
        if (comments is null) {
            comments = new ArrayList!string(2);
        }
        comments.add(_stringVal);
    }
    
    public int getLine() {
        return line;
    }

    public void computeRowAndColumn() {
        int line = 1;
        int column = 1;
        for (int i = 0; i < _pos; ++i) {
            char ch = .charAt(text, i);
            if (ch == '\n') {
                column = 1;
                line++;
            }
        }

        this._posLine = line;
        this._posColumn = _posColumn;
    }

    public int getPosLine() {
        return _posLine;
    }

    public int getPosColumn() {
        return _posColumn;
    }

    public void config(SQLParserFeature feature, bool state) {
        features = SQLParserFeature.config(features, feature, state);

        if (feature == SQLParserFeature.OptimizedForParameterized) {
            optimizedForParameterized = state;
        } else if (feature == SQLParserFeature.KeepComments) {
            this.keepComments = state;
        } else if (feature == SQLParserFeature.SkipComments) {
            this.skipComment = state;
        }
    }

    public  bool isEnabled(SQLParserFeature feature) {
        return SQLParserFeature.isEnabled(this.features, feature);
    }

    public static string parameterize(string sql, string dbType) {
        Lexer lexer = SQLParserUtils.createLexer(sql, dbType);  //@gxc tmp
        // Lexer lexer;
        lexer.optimizedForParameterized = true; // optimized

        lexer.nextToken();

        StringBuffer buf = new StringBuffer();

        for_:
        for (;;) {
            Token _token = lexer._token;
            switch (_token) {
                case Token.LITERAL_ALIAS:
                case Token.LITERAL_FLOAT:
                case Token.LITERAL_CHARS:
                case Token.LITERAL_INT:
                case Token.LITERAL_NCHARS:
                case Token.LITERAL_HEX:
                case Token.VARIANT:
                    if (buf.length != 0) {
                        buf.append(' ');
                    }
                    buf.append('?');
                    break;
                case Token.COMMA:
                    buf.append(',');
                    break;
                case Token.EQ:
                    buf.append('=');
                    break;
                case Token.EOF:
                    break for_;
                case Token.ERROR:
                    return sql;
                case Token.SELECT:
                    buf.append("SELECT");
                    break;
                case Token.UPDATE:
                    buf.append("UPDATE");
                    break;
                default:
                    if (buf.length != 0) {
                        buf.append(' ');
                    }
                    lexer.stringVal(buf);
                    break;
            }

            lexer.nextToken();
        }

        return buf.toString();
    }

    public string getSource() {
        return text;
    }
}
