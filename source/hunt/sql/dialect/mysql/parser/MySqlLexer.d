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
module hunt.sql.dialect.mysql.parser.MySqlLexer;

// import  hunt.sql.parser.CharTypes.isFirstIdentifierChar;
// import  hunt.sql.parser.LayoutCharacters.LayoutCharacters.EOI;

import  hunt.sql.parser.CharTypes;
import  hunt.sql.parser.LayoutCharacters;


import hunt.container;
import std.conv;
import hunt.util.string;
import hunt.sql.parser;
import hunt.sql.util.FnvHash;
import hunt.sql.util.DBType;
import std.string;

alias  hunt_charAt = hunt.util.string.common.charAt;

public class MySqlLexer : Lexer {
    public static SymbolTable quoteTable;

    public  static Keywords DEFAULT_MYSQL_KEYWORDS;

    // static this() {
    //     quoteTable = new SymbolTable(8192);

    //     Map!(string, Token) map = new HashMap!(string, Token)();

    //     map.putAll(Keywords.DEFAULT_KEYWORDS.getKeywords());

    //     map.put("DUAL", Token.DUAL);
    //     map.put("FALSE", Token.FALSE);
    //     map.put("IDENTIFIED", Token.IDENTIFIED);
    //     map.put("IF", Token.IF);
    //     map.put("KILL", Token.KILL);

    //     map.put("LIMIT", Token.LIMIT);
    //     map.put("TRUE", Token.TRUE);
    //     map.put("BINARY", Token.BINARY);
    //     map.put("SHOW", Token.SHOW);
    //     map.put("CACHE", Token.CACHE);
    //     map.put("ANALYZE", Token.ANALYZE);
    //     map.put("OPTIMIZE", Token.OPTIMIZE);
    //     map.put("ROW", Token.ROW);
    //     map.put("BEGIN", Token.BEGIN);
    //     map.put("END", Token.END);
    //     map.put("DIV", Token.DIV);
    //     map.put("MERGE", Token.MERGE);
        
    //     // for oceanbase & mysql 5.7
    //     map.put("PARTITION", Token.PARTITION);
        
    //     map.put("CONTINUE", Token.CONTINUE);
    //     map.put("UNDO", Token.UNDO);
    //     map.put("SQLSTATE", Token.SQLSTATE);
    //     map.put("CONDITION", Token.CONDITION);
    //     map.put("MOD", Token.MOD);
    //     map.put("CONTAINS", Token.CONTAINS);
    //     map.put("RLIKE", Token.RLIKE);
    //     map.put("FULLTEXT", Token.FULLTEXT);

    //     DEFAULT_MYSQL_KEYWORDS = new Keywords(map);

    //     for (char c = 0; c < identifierFlags.length; ++c) {
    //         if (c >= 'A' && c <= 'Z') {
    //             identifierFlags[c] = true;
    //         } else if (c >= 'a' && c <= 'z') {
    //             identifierFlags[c] = true;
    //         } else if (c >= '0' && c <= '9') {
    //             identifierFlags[c] = true;
    //         }
    //     }
    //     // identifierFlags['`'] = true;
    //     identifierFlags['_'] = true;
    //     //identifierFlags['-'] = true; // mysql
    // }


    public this(char[] input, int inputLength, bool skipComment){
        dbType = DBType.MYSQL.name;

        super(input, inputLength, skipComment);
        super.keywods = DEFAULT_MYSQL_KEYWORDS;
    }

    public this(string input){
        this(input, true, true);
    }

    public this(string input, SQLParserFeature[] features...){
        dbType = DBType.MYSQL.name;

        super(input, true);
        this.keepComments = true;
        super.keywods = DEFAULT_MYSQL_KEYWORDS;

        foreach(SQLParserFeature feature ; features) {
            config(feature, true);
        }
    }

    public this(string input, bool skipComment, bool keepComments){
        dbType = DBType.MYSQL.name;

        super(input, skipComment);
        this.skipComment = skipComment;
        this.keepComments = keepComments;
        super.keywods = DEFAULT_MYSQL_KEYWORDS;
    }

    override public void scanSharp() {
        if (ch != '#') {
            throw new ParserException("illegal stat. "  ~ info());
        }

        if (charAt(_pos + 1) == '{') {
            scanVariable();
            return;
        }

        Token lastToken = this._token;

        scanChar();
        _mark = _pos;
        bufPos = 0;
        for (;;) {
            if (ch == '\r') {
                if (charAt(_pos + 1) == '\n') {
                    bufPos += 2;
                    scanChar();
                    break;
                }
                bufPos++;
                break;
            } else if (ch == LayoutCharacters.EOI) {
                break;
            }

            if (ch == '\n') {
                scanChar();
                bufPos++;
                break;
            }

            scanChar();
            bufPos++;
        }

        _stringVal = subString(_mark - 1, bufPos + 1);
        _token = Token.LINE_COMMENT;
        commentCount++;
        if (keepComments) {
            addComment(_stringVal);
        }

        if (commentHandler !is null && commentHandler.handle(lastToken, _stringVal)) {
            return;
        }
        
        endOfComment = isEOF();

        if (!isAllowComment() && (isEOF() || !isSafeComment(_stringVal))) {
            throw new NotAllowCommentException();
        }
    }

    override public void scanVariable() {
        if (ch != ':' && ch != '#' && ch != '$') {
            throw new ParserException("illegal variable. "  ~ info());
        }

        _mark = _pos;
        bufPos = 1;

        if (charAt(_pos + 1) == '`') {
            ++_pos;
            ++bufPos;
            char ch;
            for (;;) {
                ch = charAt(++_pos);

                if (ch == '`') {
                    bufPos++;
                    ch = charAt(++_pos);
                    break;
                } else if (ch == LayoutCharacters.EOI) {
                    throw new ParserException("illegal identifier. "  ~ info());
                }

                bufPos++;
                continue;
            }

            this.ch = charAt(_pos);

            _stringVal = subString(_mark, bufPos);
            _token = Token.VARIANT;
        } else if (charAt(_pos + 1) == '{') {
            ++_pos;
            ++bufPos;
            char ch;
            for (;;) {
                ch = charAt(++_pos);

                if (ch == '}') {
                    bufPos++;
                    ch = charAt(++_pos);
                    break;
                } else if (ch == LayoutCharacters.EOI) {
                    throw new ParserException("illegal identifier. "  ~ info());
                }

                bufPos++;
                continue;
            }

            this.ch = charAt(_pos);

            _stringVal = subString(_mark, bufPos);
            _token = Token.VARIANT;
        } else {
            for (;;) {
                ch = charAt(++_pos);

                if (!isIdentifierChar(ch)) {
                    break;
                }

                bufPos++;
                continue;
            }
        }

        this.ch = charAt(_pos);

        _stringVal = subString(_mark, bufPos);
        _token = Token.VARIANT;
    }

    override protected void scanVariable_at() {
        if (ch != '@') {
            throw new ParserException("illegal variable. "  ~ info());
        }

        _mark = _pos;
        bufPos = 1;

        if (charAt(_pos + 1) == '@') {
            ch = charAt(++_pos);
            bufPos++;
        }

        if (charAt(_pos + 1) == '`') {
            ++_pos;
            ++bufPos;
            char ch;
            for (;;) {
                ch = charAt(++_pos);

                if (ch == '`') {
                    bufPos++;
                    ++_pos;
                    break;
                } else if (ch == LayoutCharacters.EOI) {
                    throw new ParserException("illegal identifier. "  ~ info());
                }

                bufPos++;
                continue;
            }

            this.ch = charAt(_pos);

            _stringVal = subString(_mark, bufPos);
            _token = Token.VARIANT;
        } else {
            for (; ; ) {
                ch = charAt(++_pos);

                if (!isIdentifierChar(ch)) {
                    break;
                }

                bufPos++;
                continue;
            }
        }

        this.ch = charAt(_pos);

        _stringVal = subString(_mark, bufPos);
        _token = Token.VARIANT;
    }

    override public void scanIdentifier() {
        _hash_lower = 0;
        hash = 0;

         char first = ch;

        if (ch == 'b'
                && charAt(_pos + 1) == '\'') {
            int i = 2;
            int _mark = _pos + 2;
            for (;;++i) {
                char ch = charAt(_pos + i);
                if (ch == '0' || ch == '1') {
                    continue;
                } else if (ch == '\'') {
                    bufPos += i;
                    _pos += (i + 1);
                    _stringVal = subString(_mark, i - 2);
                    this.ch = charAt(_pos);
                    _token = Token.BITS;
                    return;
                } else if (ch == LayoutCharacters.EOI) {
                    throw new ParserException("illegal identifier. "  ~ info());
                } else {
                    break;
                }
            }
        }

        if (ch == '`') {
            _mark = _pos;
            bufPos = 1;
            char ch;

            int startPos = _pos + 1;
            int quoteIndex = cast(int)indexOf(text, '`',startPos);
            if (quoteIndex == -1) {
                throw new ParserException("illegal identifier. "  ~ info());
            }

            _hash_lower = 0xcbf29ce484222325L;
            hash = 0xcbf29ce484222325L;

            for (int i = startPos; i < quoteIndex; ++i) {
                ch = hunt_charAt(text, i);

                _hash_lower ^= ((ch >= 'A' && ch <= 'Z') ? (ch + 32) : ch);
                _hash_lower *= 0x100000001b3L;

                hash ^= ch;
                hash *= 0x100000001b3L;
            }

            _stringVal = quoteTable.addSymbol(text, _pos, quoteIndex + 1 - _pos, hash);
            //_stringVal = text.substring(_mark, _pos);
            _pos = quoteIndex + 1;
            this.ch = charAt(_pos);
            _token = Token.IDENTIFIER;
        } else {
             bool firstFlag = CharTypes.isFirstIdentifierChar(first);
            if (!firstFlag) {
                throw new ParserException("illegal identifier. "  ~ info());
            }

            _hash_lower = 0xcbf29ce484222325L;
            hash = 0xcbf29ce484222325L;

            _hash_lower ^= ((ch >= 'A' && ch <= 'Z') ? (ch + 32) : ch);
            _hash_lower *= 0x100000001b3L;

            hash ^= ch;
            hash *= 0x100000001b3L;

            _mark = _pos;
            bufPos = 1;
            char ch = '\0';
            for (;;) {
                ch = charAt(++_pos);

                if (!isIdentifierChar(ch)) {
                    break;
                }

                bufPos++;

                _hash_lower ^= ((ch >= 'A' && ch <= 'Z') ? (ch + 32) : ch);
                _hash_lower *= 0x100000001b3L;

                hash ^= ch;
                hash *= 0x100000001b3L;

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
    }



    override protected  void scanString() {
        scanString2();
    }

    public void skipFirstHintsOrMultiCommentAndNextToken() {
        int starIndex = _pos + 2;

        for (;;) {
            starIndex =cast(int)indexOf(text,'*', starIndex);
            if (starIndex == -1 || starIndex == text.length - 1) {
                this._token = Token.ERROR;
                return;
            }

            int slashIndex = starIndex + 1;
            if (charAt(slashIndex) == '/') {
                _pos = slashIndex + 1;
                ch = hunt_charAt(text, _pos);
                if (_pos < text.length - 6) {
                    int pos_6 = _pos + 6;
                    char c0 = ch;
                    char c1 = hunt_charAt(text, _pos + 1);
                    char c2 = hunt_charAt(text, _pos + 2);
                    char c3 = hunt_charAt(text, _pos + 3);
                    char c4 = hunt_charAt(text, _pos + 4);
                    char c5 = hunt_charAt(text, _pos + 5);
                    char c6 = hunt_charAt(text, pos_6);
                    if (c0 == 's' && c1 == 'e' && c2 == 'l' && c3 == 'e' && c4 == 'c' && c5 == 't' && c6 == ' ') {
                        this.comments = null;
                        reset(pos_6, ' ', Token.SELECT);
                        return;
                    }

                    if (c0 == 'i' && c1 == 'n' && c2 == 's' && c3 == 'e' && c4 == 'r' && c5 == 't' && c6 == ' ') {
                        this.comments = null;
                        reset(pos_6, ' ', Token.INSERT);
                        return;
                    }

                    if (c0 == 'u' && c1 == 'p' && c2 == 'd' && c3 == 'a' && c4 == 't' && c5 == 'e' && c6 == ' ') {
                        this.comments = null;
                        reset(pos_6, ' ', Token.UPDATE);
                        return;
                    }


                    if (c0 == 'd' && c1 == 'e' && c2 == 'l' && c3 == 'e' && c4 == 't' && c5 == 'e' && c6 == ' ') {
                        this.comments = null;
                        reset(pos_6, ' ', Token.DELETE);
                        return;
                    }

                    if (c0 == 'S' && c1 == 'E' && c2 == 'L' && c3 == 'E' && c4 == 'C' && c5 == 'T' && c6 == ' ') {
                        this.comments = null;
                        reset(pos_6, ' ', Token.SELECT);
                        return;
                    }

                    if (c0 == 'I' && c1 == 'N' && c2 == 'S' && c3 == 'E' && c4 == 'R' && c5 == 'T' && c6 == ' ') {
                        this.comments = null;
                        reset(pos_6, ' ', Token.INSERT);
                        return;
                    }

                    if (c0 == 'U' && c1 == 'P' && c2 == 'D' && c3 == 'A' && c4 == 'T' && c5 == 'E' && c6 == ' ') {
                        this.comments = null;
                        reset(pos_6, ' ', Token.UPDATE);
                        return;
                    }

                    if (c0 == 'D' && c1 == 'E' && c2 == 'L' && c3 == 'E' && c4 == 'T' && c5 == 'E' && c6 == ' ') {
                        this.comments = null;
                        reset(pos_6, ' ', Token.DELETE);
                        return;
                    }

                    nextToken();
                    return;
                } else {
                    nextToken();
                    return;
                }
            }
            starIndex++;
        }
    }

    override public void scanComment() {
        Token lastToken = this._token;
        
        if (ch == '-') {
            char next_2 = charAt(_pos + 2);
            if (isDigit(next_2)) {
                scanChar();
                _token = Token.SUB;
                return;
            }
        } else if (ch != '/') {
            throw new Exception("IllegalState");
        }

        _mark = _pos;
        bufPos = 0;
        scanChar();

        // /*+ */
        if (ch == '*') {
            scanChar();
            bufPos++;

            while (ch == ' ') {
                scanChar();
                bufPos++;
            }

            bool isHint = false;
            int startHintSp = bufPos + 1;
            if (ch == '!' //
                    || ch == '+' // oceanbase hints
                    ) {
                isHint = true;
                scanChar();
                bufPos++;
            }

            int starIndex = _pos;

            for (;;) {
                starIndex = cast(int)indexOf(text,'*', starIndex);
                if (starIndex == -1 || starIndex == text.length - 1) {
                    this._token = Token.ERROR;
                    return;
                }
                if (charAt(starIndex + 1) == '/') {
                    if (isHint) {
                        //_stringVal = subString(_mark + startHintSp, (bufPos - startHintSp) - 2);
                        _stringVal = this.subString(_mark + startHintSp, starIndex - startHintSp - _mark);
                        _token = Token.HINT;
                    } else {
                        if (!optimizedForParameterized) {
                            _stringVal = this.subString(_mark, starIndex + 2 - _mark);
                        }
                        _token = Token.MULTI_LINE_COMMENT;
                        commentCount++;
                        if (keepComments) {
                            addComment(_stringVal);
                        }
                    }
                    _pos = starIndex + 2;
                    ch = charAt(_pos);
                    break;
                }
                starIndex++;
            }

            endOfComment = isEOF();
            
            if (commentHandler !is null
                    && commentHandler.handle(lastToken, _stringVal)) {
                return;
            }

            if (!isHint && !isAllowComment() && !isSafeComment(_stringVal)) {
                throw new NotAllowCommentException();
            }

            return;
        }

        if (ch == '/' || ch == '-') {
            scanChar();
            bufPos++;

            for (;;) {
                if (ch == '\r') {
                    if (charAt(_pos + 1) == '\n') {
                        bufPos += 2;
                        scanChar();
                        break;
                    }
                    bufPos++;
                    break;
                } else if (ch == LayoutCharacters.EOI) {
                    break;
                }

                if (ch == '\n') {
                    scanChar();
                    bufPos++;
                    break;
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

            endOfComment = isEOF();
            
            if (!isAllowComment() && (isEOF() || !isSafeComment(_stringVal))) {
                throw new NotAllowCommentException();
            }

            return;
        }
    }
    
    public  static bool[] identifierFlags = new bool[256];
    // static {
        
    // }

    public static bool isIdentifierChar(char c) {
        if (c <= identifierFlags.length) {
            return identifierFlags[c];
        }
        return c != '　' && c != '，';
    }

    override public void scanNumber() {
        _mark = _pos;

        if (ch == '0' && charAt(_pos + 1) == 'b') {
            int i = 2;
            int _mark = _pos + 2;
            for (;;++i) {
                char ch = charAt(_pos + i);
                if (ch == '0' || ch == '1') {
                    continue;
                } else if (ch >= '2' && ch <= '9') {
                    break;
                } else {
                    bufPos += i;
                    _pos += i;
                    _stringVal = subString(_mark, i - 2);
                    this.ch = charAt(_pos);
                    _token = Token.BITS;
                    return;
                }
            }
        }

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
            if (CharTypes.isFirstIdentifierChar(ch) && !(ch == 'b' && bufPos == 1 && charAt(_pos - 1) == '0')) {
                bufPos++;
                for (;;) {
                    ch = charAt(++_pos);

                    if (!isIdentifierChar(ch)) {
                        break;
                    }

                    bufPos++;
                    continue;
                }

                _stringVal = addSymbol();
                _token = Token.IDENTIFIER;
            } else {
                _token = Token.LITERAL_INT;
            }
        }
    }
}
