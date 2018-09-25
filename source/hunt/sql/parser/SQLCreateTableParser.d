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
module hunt.sql.parser.SQLCreateTableParser;

import hunt.container;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.statement;
import hunt.sql.util.FnvHash;
import hunt.sql.util.DBType;
import hunt.sql.ast.statement.SQLConstraint;
import hunt.sql.ast.statement.SQLTableElement;
import hunt.sql.parser.Token;
import hunt.sql.parser.ParserException;
import hunt.util.string;
import hunt.sql.parser.SQLDDLParser;
import hunt.sql.parser.SQLExprParser;

public class SQLCreateTableParser : SQLDDLParser {

    public this(string sql) {
        super(sql);
    }

    public this(SQLExprParser exprParser) {
        super(exprParser);
    }

    override public SQLCreateTableStatement parseCreateTable() {
        List!(string) comments = null;
        if (lexer.isKeepComments() && lexer.hasComment()) {
            comments = lexer.readAndResetComments();
        }

        SQLCreateTableStatement stmt = parseCreateTable(true);
        if (comments !is null) {
            stmt.addBeforeComment(comments);
        }

        return stmt;
    }

    public SQLCreateTableStatement parseCreateTable(bool acceptCreate) {
        SQLCreateTableStatement createTable = newCreateStatement();

        if (acceptCreate) {
            if (lexer.hasComment() && lexer.isKeepComments()) {
                createTable.addBeforeComment(lexer.readAndResetComments());
            }

            accept(Token.CREATE);
        }

        if (lexer.identifierEquals("GLOBAL")) {
            lexer.nextToken();

            if (lexer.identifierEquals("TEMPORARY")) {
                lexer.nextToken();
                createTable.setType(SQLCreateTableStatement.Type.GLOBAL_TEMPORARY);
            } else {
                throw new ParserException("syntax error " ~ lexer.info());
            }
        } else if (lexer.token == Token.IDENTIFIER && lexer.stringVal().equalsIgnoreCase("LOCAL")) {
            lexer.nextToken();
            if (lexer.token == Token.IDENTIFIER && lexer.stringVal().equalsIgnoreCase("TEMPORAY")) {
                lexer.nextToken();
                createTable.setType(SQLCreateTableStatement.Type.LOCAL_TEMPORARY);
            } else {
                throw new ParserException("syntax error. " ~ lexer.info());
            }
        }

        accept(Token.TABLE);

        if (lexer.token() == Token.IF) {
            lexer.nextToken();
            accept(Token.NOT);
            accept(Token.EXISTS);

            createTable.setIfNotExiists(true);
        }

        createTable.setName(this.exprParser.name());

        if (lexer.token == Token.LPAREN) {
            lexer.nextToken();

            for (; ; ) {
                Token token = lexer.token;
                if (token == Token.IDENTIFIER
                        && lexer.stringVal().equalsIgnoreCase("SUPPLEMENTAL")
                        && DBType.ORACLE.opEquals(dbType)) {
                    this.parseCreateTableSupplementalLogingProps(createTable);
                } else if (token == Token.IDENTIFIER //
                        || token == Token.LITERAL_ALIAS) {
                    SQLColumnDefinition column = this.exprParser.parseColumn();
                    createTable.getTableElementList().add(column);
                } else if (token == Token.PRIMARY //
                        || token == Token.UNIQUE //
                        || token == Token.CHECK //
                        || token == Token.CONSTRAINT
                        || token == Token.FOREIGN) {
                    SQLConstraint constraint = this.exprParser.parseConstaint();
                    constraint.setParent(createTable);
                    createTable.getTableElementList().add(cast(SQLTableElement) constraint);
                } else if (token == Token.TABLESPACE) {
                    throw new ParserException("TODO "  ~ lexer.info());
                } else {
                    SQLColumnDefinition column = this.exprParser.parseColumn();
                    createTable.getTableElementList().add(column);
                }

                if (lexer.token == Token.COMMA) {
                    lexer.nextToken();

                    if (lexer.token == Token.RPAREN) { // compatible for sql server
                        break;
                    }
                    continue;
                }

                break;
            }

            accept(Token.RPAREN);

            if (lexer.identifierEquals(FnvHash.Constants.INHERITS)) {
                lexer.nextToken();
                accept(Token.LPAREN);
                SQLName inherits = this.exprParser.name();
                createTable.setInherits(new SQLExprTableSource(inherits));
                accept(Token.RPAREN);
            }
        }

        if (lexer.token == Token.AS) {
            lexer.nextToken();
            SQLSelect select = this.createSQLSelectParser().select();
            createTable.setSelect(select);
        }

        if (lexer.token == Token.WITH && DBType.POSTGRESQL.opEquals(dbType)) {
            lexer.nextToken();
            accept(Token.LPAREN);

            for (;;) {
                string name = lexer.stringVal();
                lexer.nextToken();
                accept(Token.EQ);
                SQLExpr value = this.exprParser.expr();
                value.setParent(createTable);

                createTable.getTableOptions().put(name, value);

                if (lexer.token == Token.COMMA) {
                    lexer.nextToken();
                    continue;
                }

                break;
            }
            accept(Token.RPAREN);
        }

        return createTable;
    }

    protected void parseCreateTableSupplementalLogingProps(SQLCreateTableStatement stmt) {
        throw new ParserException("TODO " ~ lexer.info());
    }

    override protected SQLCreateTableStatement newCreateStatement() {
        return new SQLCreateTableStatement(getDbType());
    }
}