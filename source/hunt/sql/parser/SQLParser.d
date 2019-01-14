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
module hunt.sql.parser.SQLParser;

import hunt.sql.ast.statement.SQLCreateTableStatement;
// import hunt.sql.dialect.hive.stmt.HiveCreateTableStatement;
import hunt.sql.parser.Lexer;
import hunt.sql.parser.Token;
import hunt.sql.parser.SQLParserFeature;
import hunt.sql.parser.ParserException;
import hunt.String;
//import hunt.lang;
import hunt.text;
import hunt.Integer;

public class SQLParser {
    protected  Lexer lexer;
    protected string      dbType;

    public this(string sql, string dbType){
        this(new Lexer(sql, null, dbType), dbType);
        this.lexer.nextToken();
    }

    public this(string sql){
        this(sql, null);
    }

    public this(Lexer lexer){
        this(lexer, null);
    }

    public this(Lexer lexer, string dbType){
        this.lexer = lexer;
        this.dbType = dbType;
    }

    public  Lexer getLexer() {
        return lexer;
    }

    public string getDbType() {
        return dbType;
    }

    protected bool identifierEquals(string text) {
        return lexer.identifierEquals(text);
    }

    protected void acceptIdentifier(string text) {
        if (lexer.identifierEquals(text)) {
            lexer.nextToken();
        } else {
            setErrorEndPos(lexer.pos());
            throw new ParserException("syntax error, expect " ~ text ~ ", actual " ~ lexer.token ~ ", " ~ lexer.info());
        }
    }

    protected string tableAlias() {
        return tableAlias(false);
    }

    protected string tableAlias(bool must) {
         Token token = lexer.token;
        if (token == Token.CONNECT
                || token == Token.START
                || token == Token.SELECT
                || token == Token.FROM
                || token == Token.WHERE) {
            if (must) {
                throw new ParserException("illegal _alias. " ~ lexer.info());
            }
            return null;
        }

        if (token == Token.IDENTIFIER) {
            string ident = lexer.stringVal;
            if (equalsIgnoreCase(ident, "START") || equalsIgnoreCase(ident, "CONNECT")) {
                if (must) {
                    throw new ParserException("illegal _alias. " ~ lexer.info());
                }
                return null;
            }
        }

        return this.as();
    }

    protected string as() {
        string _alias = null;

         Token token = lexer.token;

        if (token == Token.COMMA) {
            return null;
        }

        if (token == Token.AS) {
            lexer.nextToken();
            _alias = lexer.stringVal();
            lexer.nextToken();

            if (_alias !is null) {
                while (lexer.token == Token.DOT) {
                    lexer.nextToken();
                    _alias ~= ('.' ~ lexer.token.stringof); //@gxc
                    lexer.nextToken();
                }

                return _alias;
            }

            if (lexer.token == Token.LPAREN) {
                return null;
            }

            throw new ParserException("Error : " ~ lexer.info());
        }

        if (lexer.token == Token.LITERAL_ALIAS) {
            _alias = lexer.stringVal();
            lexer.nextToken();
        } else if (lexer.token == Token.IDENTIFIER) {
            _alias = lexer.stringVal();
            lexer.nextToken();
        } else if (lexer.token == Token.LITERAL_CHARS) {
            _alias = "'" ~ lexer.stringVal() ~ "'";
            lexer.nextToken();
        } else {
            switch (lexer.token) {
                case Token.CASE:
                case Token.USER:
                case Token.LOB:
                case Token.END:
                case Token.DEFERRED:
                case Token.OUTER:
                case Token.DO:
                case Token.STORE:
                case Token.MOD:
                    _alias = lexer.stringVal();
                    lexer.nextToken();
                    break;
                default:
                    break;
            }
        }

        switch (lexer.token) {
            case Token.KEY:
            case Token.INTERVAL:
            case Token.CONSTRAINT:
                _alias = lexer.token.stringof;  //@gxc
                lexer.nextToken();
                return _alias;
            default:
                break;
        }

        return _alias;
    }

    protected string alias_f() {
        string _alias = null;
        if (lexer.token == Token.LITERAL_ALIAS) {
            _alias = lexer.stringVal();
            lexer.nextToken();
        } else if (lexer.token == Token.IDENTIFIER) {
            _alias = lexer.stringVal();
            lexer.nextToken();
        } else if (lexer.token == Token.LITERAL_CHARS) {
            _alias = "'" ~ lexer.stringVal() ~ "'";
            lexer.nextToken();
        } else {
            switch (lexer.token) {
                case Token.KEY:
                case Token.INDEX:
                case Token.CASE:
                case Token.MODEL:
                case Token.PCTFREE:
                case Token.INITRANS:
                case Token.MAXTRANS:
                case Token.SEGMENT:
                case Token.CREATION:
                case Token.IMMEDIATE:
                case Token.DEFERRED:
                case Token.STORAGE:
                case Token.NEXT:
                case Token.MINEXTENTS:
                case Token.MAXEXTENTS:
                case Token.MAXSIZE:
                case Token.PCTINCREASE:
                case Token.FLASH_CACHE:
                case Token.CELL_FLASH_CACHE:
                case Token.NONE:
                case Token.LOB:
                case Token.STORE:
                case Token.ROW:
                case Token.CHUNK:
                case Token.CACHE:
                case Token.NOCACHE:
                case Token.LOGGING:
                case Token.NOCOMPRESS:
                case Token.KEEP_DUPLICATES:
                case Token.EXCEPTIONS:
                case Token.PURGE:
                case Token.INITIALLY:
                case Token.END:
                case Token.COMMENT:
                case Token.ENABLE:
                case Token.DISABLE:
                case Token.SEQUENCE:
                case Token.USER:
                case Token.ANALYZE:
                case Token.OPTIMIZE:
                case Token.GRANT:
                case Token.REVOKE:
                case Token.FULL:
                case Token.TO:
                case Token.NEW:
                case Token.INTERVAL:
                case Token.LOCK:
                case Token.LIMIT:
                case Token.IDENTIFIED:
                case Token.PASSWORD:
                case Token.BINARY:
                case Token.WINDOW:
                case Token.OFFSET:
                case Token.SHARE:
                case Token.START:
                case Token.CONNECT:
                case Token.MATCHED:
                case Token.ERRORS:
                case Token.REJECT:
                case Token.UNLIMITED:
                case Token.BEGIN:
                case Token.EXCLUSIVE:
                case Token.MODE:
                case Token.ADVISE:
                case Token.TYPE:
                case Token.CLOSE:
                case Token.OPEN:
                    _alias = lexer.stringVal();
                    lexer.nextToken();
                    return _alias;
                case Token.QUES:
                    _alias = "?";
                    lexer.nextToken();
                    break;
                default:
                    break;
            }
        }
        return _alias;
    }

    protected void printError(Token token) {
        string arround;
        if (lexer._mark >= 0 && (lexer.text.length > lexer._mark + 30)) {
            if (lexer._mark - 5 > 0) {
                arround = lexer.text.substring(lexer._mark - 5, lexer._mark + 30);
            } else {
                arround = lexer.text.substring(lexer._mark, lexer._mark + 30);
            }

        } else if (lexer._mark >= 0) {
            if (lexer._mark - 5 > 0) {
                arround = lexer.text.substring(lexer._mark - 5);
            } else {
                arround = lexer.text.substring(lexer._mark);
            }
        } else {
            arround = lexer.text;
        }

        // throw new
        // ParserException("syntax error, error arround:'"~arround~"',expect "
        // ~ token ~ ", actual " ~ lexer.token ~ " "
        // ~ lexer.stringVal() ~ ", pos " ~ this.lexer.pos());
        throw new ParserException("syntax error, error in :'" ~ arround ~ "', expect " ~ token ~ ", actual "
                                  ~ lexer.token ~ " " ~ lexer.info());
    }

    public void accept(Token token) {
        if (lexer.token == token) {
            lexer.nextToken();
        } else {
            setErrorEndPos(lexer.pos());
            printError(token);
        }
    }

    public int acceptInteger() {
        if (lexer.token == Token.LITERAL_INT) {
            int intVal = (cast(Integer) lexer.integerValue()).intValue();
            lexer.nextToken();
            return intVal;
        } else {
            throw new ParserException("syntax error, expect int, actual " ~ lexer.token ~ " "
                    ~ lexer.info());
        }
    }

    public void match(Token token) {
        if (lexer.token != token) {
            throw new ParserException("syntax error, expect " ~ token ~ ", actual " ~ lexer.token ~ " "
                                      ~ lexer.info());
        }
    }

    private int errorEndPos = -1;

    protected void setErrorEndPos(int errPos) {
        if (errPos > errorEndPos) {
            errorEndPos = errPos;
        }
    }

    public void config(SQLParserFeature feature, bool state) {
        this.lexer.config(feature, state);
    }

    public  bool isEnabled(SQLParserFeature feature) {
        return lexer.isEnabled(feature);
    }

    protected SQLCreateTableStatement newCreateStatement() {
        return new SQLCreateTableStatement(getDbType());
    }
}
