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
module hunt.sql.dialect.postgresql.parser.PGSQLStatementParser;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLStatement;
import hunt.sql.ast.expr;
import hunt.sql.ast.statement;
import hunt.sql.dialect.postgresql.ast.stmt.PGDeleteStatement;
import hunt.sql.dialect.postgresql.ast.stmt.PGInsertStatement;
import hunt.sql.dialect.postgresql.ast.stmt.PGSelectStatement;
import hunt.sql.dialect.postgresql.ast.stmt.PGShowStatement;
import hunt.sql.dialect.postgresql.ast.stmt.PGUpdateStatement;
import hunt.sql.parser;
import hunt.sql.dialect.postgresql.ast.stmt;
import hunt.sql.parser.Lexer;
import hunt.sql.parser.ParserException;
import hunt.sql.parser.SQLStatementParser;
import hunt.sql.parser.Token;
import hunt.sql.util.FnvHash;
import hunt.sql.util.DBType;
import hunt.sql.dialect.postgresql.parser.PGExprParser;
import hunt.sql.dialect.postgresql.parser.PGSelectParser;
import hunt.sql.ast.SQLObjectImpl;
import hunt.math;
import hunt.util.string;
import hunt.container;
import std.uni;

public class PGSQLStatementParser : SQLStatementParser {
    public static  string TIME_ZONE = "TIME ZONE";
    public static  string TIME = "TIME";
    public static  string LOCAL = "LOCAL";

    public this(PGExprParser parser) {
        super(parser);
    }
    
    public this(string sql){
        super(new PGExprParser(sql));
    }

    public this(string sql, SQLParserFeature[] features...){
        super(new PGExprParser(sql, features));
    }

    public this(Lexer lexer){
        super(new PGExprParser(lexer));
    }

    override public PGSelectParser createSQLSelectParser() {
        return new PGSelectParser(this.exprParser, selectListCache);
    }

    override public SQLUpdateStatement parseUpdateStatement() {
        accept(Token.UPDATE);

        PGUpdateStatement udpateStatement = new PGUpdateStatement();

        SQLSelectParser selectParser = this.exprParser.createSelectParser();
        SQLTableSource tableSource = selectParser.parseTableSource();
        udpateStatement.setTableSource(tableSource);

        parseUpdateSet(udpateStatement);

        if (lexer.token() == Token.FROM) {
            lexer.nextToken();
            SQLTableSource from = selectParser.parseTableSource();
            udpateStatement.setFrom(from);
        }

        if (lexer.token() == (Token.WHERE)) {
            lexer.nextToken();
            udpateStatement.setWhere(this.exprParser.expr());
        }

        if (lexer.token() == Token.RETURNING) {
            lexer.nextToken();

            for (;;) {
                udpateStatement.getReturning().add(this.exprParser.expr());
                if (lexer.token() == Token.COMMA) {
                    lexer.nextToken();
                    continue;
                }
                break;
            }
        }

        return udpateStatement;
    }

    override public PGInsertStatement parseInsert() {
        PGInsertStatement stmt = new PGInsertStatement();

        if (lexer.token() == Token.INSERT) {
            lexer.nextToken();
            accept(Token.INTO);

            SQLName tableName = this.exprParser.name();
            stmt.setTableName(tableName);

            if (lexer.token() == Token.AS) {
                lexer.nextToken();
                stmt.setAlias(lexer.stringVal());
                lexer.nextToken();
            } else if (lexer.token() == Token.IDENTIFIER) {
                stmt.setAlias(lexer.stringVal());
                lexer.nextToken();
            }

        }
        
        if (lexer.token() == Token.DEFAULT) {
        	lexer.nextToken();
        	accept(Token.VALUES);
        	stmt.setDefaultValues(true);
        }

        if (lexer.token() == (Token.LPAREN)) {
            lexer.nextToken();
            this.exprParser.exprList(stmt.getColumns(), stmt);
            accept(Token.RPAREN);
        }

        if (lexer.token() == (Token.VALUES)) {
            lexer.nextToken();

            for (;;) {
                accept(Token.LPAREN);
                ValuesClause valuesCaluse = new ValuesClause();
                this.exprParser.exprList(valuesCaluse.getValues(), valuesCaluse);
                stmt.addValueCause(valuesCaluse);

                accept(Token.RPAREN);
                if (lexer.token() == Token.COMMA) {
                    lexer.nextToken();
                    continue;
                }
                break;
            }
        } else if (lexer.token() == (Token.SELECT)) {
            SQLQueryExpr queryExpr = cast(SQLQueryExpr) this.exprParser.expr();
            stmt.setQuery(queryExpr.getSubQuery());
        }

        if (lexer.token() == Token.ON) {
            lexer.nextToken();
            if (lexer.identifierEquals(FnvHash.Constants.CONFLICT)) {
                lexer.nextToken();

                if (lexer.token() == Token.LPAREN) {
                    lexer.nextToken();
                    List!(SQLExpr) onConflictTarget = new ArrayList!(SQLExpr)();
                    this.exprParser.exprList(onConflictTarget, stmt);
                    stmt.setOnConflictTarget(onConflictTarget);
                    accept(Token.RPAREN);
                }

                if (lexer.token() == Token.ON) {
                    lexer.nextToken();
                    accept(Token.CONSTRAINT);
                    SQLName constraintName = this.exprParser.name();
                    stmt.setOnConflictConstraint(constraintName);
                }

                if (lexer.token() == Token.WHERE) {
                    lexer.nextToken();
                    SQLExpr where = this.exprParser.expr();
                    stmt.setOnConflictWhere(where);
                }

                if (lexer.token() == Token.DO) {
                    lexer.nextToken();

                    if (lexer.identifierEquals(FnvHash.Constants.NOTHING)) {
                        lexer.nextToken();
                        stmt.setOnConflictDoNothing(true);
                    } else {
                        accept(Token.UPDATE);
                        accept(Token.SET);

                        for (;;) {
                            SQLUpdateSetItem item = this.exprParser.parseUpdateSetItem();
                            stmt.addConflicUpdateItem(item);

                            if (lexer.token() != Token.COMMA) {
                                break;
                            }

                            lexer.nextToken();
                        }
                    }
                }
            }
        }

        if (lexer.token() == Token.RETURNING) {
            lexer.nextToken();
            SQLExpr returning = this.exprParser.expr();

            if (lexer.token() == Token.COMMA) {
                lexer.nextToken();
                SQLListExpr list = new SQLListExpr();
                list.addItem(returning);

                this.exprParser.exprList(list.getItems(), list);

                returning = list;
            }
            stmt.setReturning(returning);
        }
        return stmt;
    }

    override public PGDeleteStatement parseDeleteStatement() {
        lexer.nextToken();
        PGDeleteStatement deleteStatement = new PGDeleteStatement();

        if (lexer.token() == (Token.FROM)) {
            lexer.nextToken();
        }
        if (lexer.token() == (Token.ONLY)) {
            lexer.nextToken();
            deleteStatement.setOnly(true);
        }

        SQLName tableName = exprParser.name();

        deleteStatement.setTableName(tableName);
        
        if (lexer.token() == Token.AS) {
			accept(Token.AS);
		}
		if (lexer.token() == Token.IDENTIFIER) {
			deleteStatement.setAlias(lexer.stringVal());
			lexer.nextToken();
		}

        if (lexer.token() == Token.USING) {
            lexer.nextToken();

            SQLTableSource tableSource = createSQLSelectParser().parseTableSource();
            deleteStatement.setUsing(tableSource);
        }

        if (lexer.token() == (Token.WHERE)) {
            lexer.nextToken();

            if (lexer.token() == Token.CURRENT) {
                lexer.nextToken();
                accept(Token.OF);
                SQLName cursorName = this.exprParser.name();
                SQLExpr where = new SQLCurrentOfCursorExpr(cursorName);
                deleteStatement.setWhere(where);
            } else {
                SQLExpr where = this.exprParser.expr();
                deleteStatement.setWhere(where);
            }
        }

        if (lexer.token() == Token.RETURNING) {
            lexer.nextToken();
            accept(Token.STAR);
            deleteStatement.setReturning(true);
        }

        return deleteStatement;
    }

    override public bool parseStatementListDialect(List!(SQLStatement) statementList) {
        switch (lexer.token()) {
            case Token.BEGIN:
            case Token.START: {
                PGStartTransactionStatement stmt = parseBegin();
                statementList.add(stmt);
                return true;
            }

            case Token.WITH:
                statementList.add(parseWith());
                return true;
            default:
                break;
        }

        if (lexer.identifierEquals(FnvHash.Constants.CONNECT)) {
            SQLStatement stmt = parseConnectTo();
            statementList.add(stmt);
            return true;
        }

        return false;
    }

    protected PGStartTransactionStatement parseBegin() {
        PGStartTransactionStatement stmt = new PGStartTransactionStatement();
        if (lexer.token() == Token.START) {
            lexer.nextToken();
            acceptIdentifier("TRANSACTION");
        } else {
            accept(Token.BEGIN);
        }

        return stmt;
    }

    public SQLStatement parseConnectTo() {
        acceptIdentifier("CONNECT");
        accept(Token.TO);

        PGConnectToStatement stmt = new PGConnectToStatement();
        SQLName target = this.exprParser.name();
        stmt.setTarget(target);

        return stmt;
    }

    override public PGSelectStatement parseSelect() {
        PGSelectParser selectParser = createSQLSelectParser();
        SQLSelect select = selectParser.select();
        return new PGSelectStatement(select);
    }

    override public SQLStatement parseWith() {
        SQLWithSubqueryClause with_p = this.parseWithQuery();
        // PGWithClause with = this.parseWithClause();
        if (lexer.token() == Token.INSERT) {
            PGInsertStatement stmt = this.parseInsert();
            stmt.setWith(with_p);
            return stmt;
        }

        if (lexer.token() == Token.SELECT) {
            PGSelectStatement stmt = this.parseSelect();
            stmt.getSelect().setWithSubQuery(with_p);
            return stmt;
        }

        if (lexer.token() == Token.DELETE) {
            PGDeleteStatement stmt = this.parseDeleteStatement();
            stmt.setWith(with_p);
            return stmt;
        }

        if (lexer.token() == Token.UPDATE) {
            PGUpdateStatement stmt = cast(PGUpdateStatement) this.parseUpdateStatement();
            stmt.setWith(with_p);
            return stmt;
        }

        throw new ParserException("TODO. " ~ lexer.info());
    }

    override protected SQLAlterTableAlterColumn parseAlterColumn() {
        if (lexer.token() == Token.COLUMN) {
            lexer.nextToken();
        }

        SQLColumnDefinition column = this.exprParser.parseColumn();

        SQLAlterTableAlterColumn alterColumn = new SQLAlterTableAlterColumn();
        alterColumn.setColumn(column);

        if (column.getDataType() is null && column.getConstraints().size() == 0) {
            if (lexer.token() == Token.SET) {
                lexer.nextToken();
                if (lexer.token() == Token.NOT) {
                    lexer.nextToken();
                    accept(Token.NULL);
                    alterColumn.setSetNotNull(true);
                } else {
                    accept(Token.DEFAULT);
                    SQLExpr defaultValue = this.exprParser.expr();
                    alterColumn.setSetDefault(defaultValue);
                }
            } else if (lexer.token() == Token.DROP) {
                lexer.nextToken();
                if (lexer.token() == Token.NOT) {
                    lexer.nextToken();
                    accept(Token.NULL);
                    alterColumn.setDropNotNull(true);
                } else {
                    accept(Token.DEFAULT);
                    alterColumn.setDropDefault(true);
                }
            }
        }
        return alterColumn;
    }
    
    override public SQLStatement parseShow() {
        accept(Token.SHOW);
        PGShowStatement stmt = new PGShowStatement();
        switch (lexer.token()) {
        case Token.ALL:
            stmt.setExpr(new SQLIdentifierExpr(Token.ALL.stringof)); //@gxc
            lexer.nextToken();
            break;
        default:
            stmt.setExpr(this.exprParser.expr());
            break;
        }
        return stmt;
    }
    
    override
    public SQLStatement parseCommit() {
        SQLCommitStatement stmt = new SQLCommitStatement();
        stmt.setDbType(this.dbType);
        lexer.nextToken();
        return stmt;
    }

    override
    public SQLStatement parseSet() {
        accept(Token.SET);
        Token token = lexer.token();
        string range = "";

        SQLSetStatement.Option option = null;
        if (token == Token.SESSION) {
            lexer.nextToken();
            range = Token.SESSION.stringof;//@gxc
            option = SQLSetStatement.Option.SESSION;
        } else if (token == Token.IDENTIFIER && equalsIgnoreCase(LOCAL, lexer.stringVal())) {
            range = LOCAL;
            option = SQLSetStatement.Option.LOCAL;
            lexer.nextToken();
        }
        string parameter = lexer.stringVal();
        SQLExpr paramExpr;
        List!(SQLExpr) values = new ArrayList!(SQLExpr)();
        if (equalsIgnoreCase(TIME, parameter)) {
            lexer.nextToken();
            acceptIdentifier("ZONE");
            paramExpr = new SQLIdentifierExpr("TIME ZONE");
            string value = lexer.stringVal();
            if (lexer.token() == Token.IDENTIFIER) {
                values.add(new SQLIdentifierExpr(toUpper(value)));
            } else {
                values.add(new SQLCharExpr(value));
            }
            lexer.nextToken();
//            return new PGSetStatement(range, TIME_ZONE, exprs);
        } else {
            paramExpr = new SQLIdentifierExpr(parameter);
            lexer.nextToken();

            while (!lexer.isEOF()) {
                lexer.nextToken();
                if (lexer.token() == Token.LITERAL_CHARS) {
                    values.add(new SQLCharExpr(lexer.stringVal()));
                } else if (lexer.token() == Token.LITERAL_INT) {
                    values.add(new SQLIdentifierExpr(lexer.numberString()));
                } else {
                    values.add(new SQLIdentifierExpr(lexer.stringVal()));
                }
                // skip comma
                lexer.nextToken();
            }
        }

        // value | 'value' | DEFAULT



        SQLExpr valueExpr;
        if (values.size() == 1) {
            valueExpr = values.get(0);
        } else {
            SQLListExpr listExpr = new SQLListExpr();
            foreach(SQLExpr value ; values) {
                listExpr.addItem(value);
            }
            valueExpr = listExpr;
        }
        SQLSetStatement stmt = new SQLSetStatement(paramExpr, valueExpr, dbType);
        stmt.setOption(option);
        return stmt;
    }

    override public SQLCreateSequenceStatement parseCreateSequence(bool acceptCreate) {
        if (acceptCreate) {
            accept(Token.CREATE);
        }

        accept(Token.SEQUENCE);

        SQLCreateSequenceStatement stmt = new SQLCreateSequenceStatement();
        stmt.setDbType(dbType);
        stmt.setName(this.exprParser.name());

        for (;;) {
            if (lexer.token() == Token.START) {
                lexer.nextToken();
                accept(Token.WITH);
                stmt.setStartWith(this.exprParser.expr());
                continue;
            } else if (lexer.identifierEquals("INCREMENT")) {
                lexer.nextToken();
                accept(Token.BY);
                stmt.setIncrementBy(this.exprParser.expr());
                continue;
            } else if (lexer.token() == Token.CACHE || lexer.identifierEquals(FnvHash.Constants.CACHE)) {
                lexer.nextToken();
                stmt.setCache(Boolean.TRUE);

                if (lexer.token() == Token.LITERAL_INT) {
                    stmt.setCacheValue(this.exprParser.primary());
                }
                continue;
            } else if (lexer.token() == Token.NOCACHE) {
                lexer.nextToken();
                stmt.setCache(Boolean.FALSE);
                continue;
            } else if (lexer.token() == Token.ORDER) {
                lexer.nextToken();
                stmt.setOrder(Boolean.TRUE);
                continue;
            } else if (lexer.identifierEquals("NOORDER")) {
                lexer.nextToken();
                stmt.setOrder(Boolean.FALSE);
                continue;
            } else if (lexer.identifierEquals("CYCLE")) {
                lexer.nextToken();
                stmt.setCycle(Boolean.TRUE);
                continue;
            } else if (lexer.identifierEquals("NOCYCLE")) {
                lexer.nextToken();
                stmt.setCycle(Boolean.FALSE);
                continue;
            } else if (lexer.identifierEquals("MINVALUE")) {
                lexer.nextToken();
                stmt.setMinValue(this.exprParser.expr());
                continue;
            } else if (lexer.identifierEquals("MAXVALUE")) {
                lexer.nextToken();
                stmt.setMaxValue(this.exprParser.expr());
                continue;
            } else if (lexer.identifierEquals("NOMAXVALUE")) {
                lexer.nextToken();
                stmt.setNoMaxValue(true);
                continue;
            } else if (lexer.identifierEquals("NOMINVALUE")) {
                lexer.nextToken();
                stmt.setNoMinValue(true);
                continue;
            }
            break;
        }

        return stmt;
    }

    override public SQLStatement parseCreateIndex(bool acceptCreate) {
        if (acceptCreate) {
            accept(Token.CREATE);
        }

        SQLCreateIndexStatement stmt = new SQLCreateIndexStatement(getDbType());
        if (lexer.token() == Token.UNIQUE) {
            lexer.nextToken();
            if (lexer.identifierEquals("CLUSTERED")) {
                lexer.nextToken();
                stmt.setType("UNIQUE CLUSTERED");
            } else {
                stmt.setType("UNIQUE");
            }
        } else if (lexer.identifierEquals("FULLTEXT")) {
            stmt.setType("FULLTEXT");
            lexer.nextToken();
        } else if (lexer.identifierEquals("NONCLUSTERED")) {
            stmt.setType("NONCLUSTERED");
            lexer.nextToken();
        }

        accept(Token.INDEX);

        stmt.setName(this.exprParser.name());

        accept(Token.ON);

        stmt.setTable(this.exprParser.name());

        if (lexer.token() == Token.USING) {
            lexer.nextToken();
            string using = lexer.stringVal();
            accept(Token.IDENTIFIER);
            stmt.setUsing(using);
        }

        accept(Token.LPAREN);

        for (;;) {
            SQLSelectOrderByItem item = this.exprParser.parseSelectOrderByItem();
            item.setParent(stmt);
            stmt.addItem(item);
            if (lexer.token() == Token.COMMA) {
                lexer.nextToken();
                continue;
            }
            break;
        }
        accept(Token.RPAREN);

        return stmt;
    }
}
