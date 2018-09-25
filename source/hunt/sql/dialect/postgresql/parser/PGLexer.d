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
module hunt.sql.dialect.postgresql.parser.PGLexer;

import  hunt.sql.parser.CharTypes;
import  hunt.sql.parser.Token;



import hunt.container;
import hunt.sql.parser;
import hunt.sql.util.DBType;

public class PGLexer : Lexer {

    public  static Keywords DEFAULT_PG_KEYWORDS;

    // static this() {
    //     Map!(string, Token) map = new HashMap!(string, Token)();

    //     map.putAll(Keywords.DEFAULT_KEYWORDS.getKeywords());

    //     map.put("BEGIN", Token.BEGIN);
    //     map.put("CASCADE", Token.CASCADE);
    //     map.put("CONTINUE", Token.CONTINUE);
    //     map.put("CURRENT", Token.CURRENT);
    //     map.put("FETCH", Token.FETCH);
    //     map.put("FIRST", Token.FIRST);

    //     map.put("IDENTITY", Token.IDENTITY);
    //     map.put("LIMIT", Token.LIMIT);
    //     map.put("NEXT", Token.NEXT);
    //     map.put("NOWAIT", Token.NOWAIT);
    //     map.put("OF", Token.OF);

    //     map.put("OFFSET", Token.OFFSET);
    //     map.put("ONLY", Token.ONLY);
    //     map.put("RECURSIVE", Token.RECURSIVE);
    //     map.put("RESTART", Token.RESTART);

    //     map.put("RESTRICT", Token.RESTRICT);
    //     map.put("RETURNING", Token.RETURNING);
    //     map.put("ROW", Token.ROW);
    //     map.put("ROWS", Token.ROWS);
    //     map.put("SHARE", Token.SHARE);
    //     map.put("SHOW", Token.SHOW);
    //     map.put("START", Token.START);
        
    //     map.put("USING", Token.USING);
    //     map.put("WINDOW", Token.WINDOW);
        
    //     map.put("TRUE", Token.TRUE);
    //     map.put("FALSE", Token.FALSE);
    //     map.put("ARRAY", Token.ARRAY);
    //     map.put("IF", Token.IF);
    //     map.put("TYPE", Token.TYPE);
    //     map.put("ILIKE", Token.ILIKE);

    //     DEFAULT_PG_KEYWORDS = new Keywords(map);
    // }

    public this(string input, SQLParserFeature[] features...){
        super(input);
        super.keywods = DEFAULT_PG_KEYWORDS;
        super.dbType = DBType.POSTGRESQL.name;
        foreach(SQLParserFeature feature ; features) {
            config(feature, true);
        }
    }
    
    override protected void scanString() {
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

                putChar('\\');
                switch (ch) {
                    case '\0':
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
                scanChar();
            }

            if (ch == '\'') {
                scanChar();
                if (ch != '\'') {
                    _token = Token.LITERAL_CHARS;
                    break;
                } else {
                    initBuff(bufPos);
                    arraycopy(_mark + 1, buf, 0, bufPos);
                    hasSpecial = true;
                    putChar('\'');
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
    
    override public void scanSharp() {
        scanChar();
        if (ch == '>') {
            scanChar();
            if (ch == '>') {
                scanChar();
                _token = Token.POUNDGTGT;
            } else {
                _token = Token.POUNDGT;
            }
        } else {
            _token = Token.POUND;
        }
    }

    override protected void scanVariable_at() {
        if (ch != '@') {
            throw new ParserException("illegal variable. "  ~ info());
        }

        _mark = _pos;
        bufPos = 1;
        char ch;

         char c1 = charAt(_pos + 1);
        if (c1 == '@') {
            _pos += 2;
            _token = Token.MONKEYS_AT_AT;
            this.ch = charAt(++_pos);
            return;
        } else if (c1 == '>') {
            _pos += 2;
            _token = Token.MONKEYS_AT_GT;
            this.ch = charAt(++_pos);
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
}
