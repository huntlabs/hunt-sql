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
module hunt.sql.dialect.postgresql.parser.PGSelectParser;

import hunt.container;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLLimit;
import hunt.sql.ast.SQLParameter;
import hunt.sql.ast.SQLSetQuantifier;
import hunt.sql.ast.expr.SQLIdentifierExpr;
import hunt.sql.ast.statement.SQLExprTableSource;
import hunt.sql.ast.statement.SQLSelectQuery;
import hunt.sql.ast.statement.SQLSelectQueryBlock;
import hunt.sql.ast.statement.SQLTableSource;
import hunt.sql.dialect.postgresql.ast.stmt.PGFunctionTableSource;
import hunt.sql.dialect.postgresql.ast.stmt.PGSelectQueryBlock;
// import hunt.sql.dialect.postgresql.ast.stmt.PGSelectQueryBlock.IntoOption;
import hunt.sql.dialect.postgresql.ast.stmt.PGValuesQuery;
import hunt.sql.parser;
import hunt.sql.ast.statement.SQLTableSource;
import hunt.sql.dialect.postgresql.parser.PGExprParser;


public class PGSelectParser : SQLSelectParser {

    public this(SQLExprParser exprParser){
        super(exprParser);
    }

    public this(SQLExprParser exprParser, SQLSelectListCache selectListCache){
        super(exprParser, selectListCache);
    }

    public this(string sql){
        this(new PGExprParser(sql));
    }

    protected SQLExprParser createExprParser() {
        return new PGExprParser(lexer);
    }

    override
    public SQLSelectQuery query() {
        if (lexer.token() == Token.VALUES) {
            lexer.nextToken();
            accept(Token.LPAREN);
            PGValuesQuery valuesQuery = new PGValuesQuery();
            this.exprParser.exprList(valuesQuery.getValues(), valuesQuery);
            accept(Token.RPAREN);
            return queryRest(valuesQuery);
        }

        if (lexer.token() == Token.LPAREN) {
            lexer.nextToken();

            SQLSelectQuery select = query();
            if (cast(SQLSelectQueryBlock)(select) !is null) {
                (cast(SQLSelectQueryBlock) select).setParenthesized(true);
            }
            accept(Token.RPAREN);

            return queryRest(select);
        }

        PGSelectQueryBlock queryBlock = new PGSelectQueryBlock();

        if (lexer.token() == Token.SELECT) {
            lexer.nextToken();

            if (lexer.token() == Token.COMMENT) {
                lexer.nextToken();
            }

            if (lexer.token() == Token.DISTINCT) {
                queryBlock.setDistionOption(SQLSetQuantifier.DISTINCT);
                lexer.nextToken();

                if (lexer.token() == Token.ON) {
                    lexer.nextToken();

                    for (;;) {
                        SQLExpr expr = this.createExprParser().expr();
                        queryBlock.getDistinctOn().add(expr);
                        if (lexer.token() == Token.COMMA) {
                            lexer.nextToken();
                            continue;
                        } else {
                            break;
                        }
                    }
                }
            } else if (lexer.token() == Token.ALL) {
                queryBlock.setDistionOption(SQLSetQuantifier.ALL);
                lexer.nextToken();
            }

            parseSelectList(queryBlock);

            if (lexer.token() == Token.INTO) {
                lexer.nextToken();

                if (lexer.token() == Token.TEMPORARY) {
                    lexer.nextToken();
                    queryBlock.setIntoOption(PGSelectQueryBlock.IntoOption.TEMPORARY);
                } else if (lexer.token() == Token.TEMP) {
                    lexer.nextToken();
                    queryBlock.setIntoOption(PGSelectQueryBlock.IntoOption.TEMP);
                } else if (lexer.token() == Token.UNLOGGED) {
                    lexer.nextToken();
                    queryBlock.setIntoOption(PGSelectQueryBlock.IntoOption.UNLOGGED);
                }

                if (lexer.token() == Token.TABLE) {
                    lexer.nextToken();
                }

                SQLExpr name = this.createExprParser().name();

                queryBlock.setInto(new SQLExprTableSource(name));
            }
        }

        parseFrom(queryBlock);

        parseWhere(queryBlock);

        parseGroupBy(queryBlock);

        if (lexer.token() == Token.WINDOW) {
            this.parseWindow(queryBlock);
        }

        queryBlock.setOrderBy(this.createExprParser().parseOrderBy());

        for (;;) {
            if (lexer.token() == Token.LIMIT) {
                SQLLimit limit = new SQLLimit();

                lexer.nextToken();
                if (lexer.token() == Token.ALL) {
                    limit.setRowCount(new SQLIdentifierExpr("ALL"));
                    lexer.nextToken();
                } else {
                    limit.setRowCount(expr());
                }

                queryBlock.setLimit(limit);
            } else if (lexer.token() == Token.OFFSET) {
                SQLLimit limit = queryBlock.getLimit();
                if (limit is null) {
                    limit = new SQLLimit();
                    queryBlock.setLimit(limit);
                }
                lexer.nextToken();
                SQLExpr offset = expr();
                limit.setOffset(offset);

                if (lexer.token() == Token.ROW || lexer.token() == Token.ROWS) {
                    lexer.nextToken();
                }
            } else {
                break;
            }
        }

        if (lexer.token() == Token.FETCH) {
            lexer.nextToken();
            PGSelectQueryBlock.FetchClause fetch = new PGSelectQueryBlock.FetchClause();

            if (lexer.token() == Token.FIRST) {
                fetch.setOption(PGSelectQueryBlock.FetchClause.Option.FIRST);
            } else if (lexer.token() == Token.NEXT) {
                fetch.setOption(PGSelectQueryBlock.FetchClause.Option.NEXT);
            } else {
                throw new ParserException("expect 'FIRST' or 'NEXT'. " ~ lexer.info());
            }

            SQLExpr count = expr();
            fetch.setCount(count);

            if (lexer.token() == Token.ROW || lexer.token() == Token.ROWS) {
                lexer.nextToken();
            } else {
                throw new ParserException("expect 'ROW' or 'ROWS'. " ~ lexer.info());
            }

            if (lexer.token() == Token.ONLY) {
                lexer.nextToken();
            } else {
                throw new ParserException("expect 'ONLY'. " ~ lexer.info());
            }

            queryBlock.setFetch(fetch);
        }

        if (lexer.token() == Token.FOR) {
            lexer.nextToken();

            PGSelectQueryBlock.ForClause forClause = new PGSelectQueryBlock.ForClause();

            if (lexer.token() == Token.UPDATE) {
                forClause.setOption(PGSelectQueryBlock.ForClause.Option.UPDATE);
                lexer.nextToken();
            } else if (lexer.token() == Token.SHARE) {
                forClause.setOption(PGSelectQueryBlock.ForClause.Option.SHARE);
                lexer.nextToken();
            } else {
                throw new ParserException("expect 'FIRST' or 'NEXT'. " ~ lexer.info());
            }

            if (lexer.token() == Token.OF) {
                for (;;) {
                    SQLExpr expr = this.createExprParser().expr();
                    forClause.getOf().add(expr);
                    if (lexer.token() == Token.COMMA) {
                        lexer.nextToken();
                        continue;
                    } else {
                        break;
                    }
                }
            }

            if (lexer.token() == Token.NOWAIT) {
                lexer.nextToken();
                forClause.setNoWait(true);
            }

            queryBlock.setForClause(forClause);
        }

        return queryRest(queryBlock);
    }

    override protected SQLTableSource parseTableSourceRest(SQLTableSource tableSource) {
        if (lexer.token() == Token.AS && cast(SQLExprTableSource)(tableSource) !is null) {
            lexer.nextToken();

            string _alias = null;
            if (lexer.token() == Token.IDENTIFIER) {
                _alias = lexer.stringVal();
                lexer.nextToken();
            }

            if (lexer.token() == Token.LPAREN) {
                SQLExprTableSource exprTableSource = cast(SQLExprTableSource) tableSource;

                PGFunctionTableSource functionTableSource = new PGFunctionTableSource(exprTableSource.getExpr());
                if (_alias !is null) {
                    functionTableSource.setAlias(_alias);
                }
                
                lexer.nextToken();
                parserParameters(functionTableSource.getParameters());
                accept(Token.RPAREN);

                return super.parseTableSourceRest(functionTableSource);
            }
            if (_alias !is null) {
                tableSource.setAlias(_alias);
                return super.parseTableSourceRest(tableSource);
            }
        }

        return super.parseTableSourceRest(tableSource);
    }

    private void parserParameters(List!(SQLParameter) parameters) {
        for (;;) {
            SQLParameter parameter = new SQLParameter();

            parameter.setName(this.exprParser.name());
            parameter.setDataType(this.exprParser.parseDataType());

            parameters.add(parameter);
            if (lexer.token() == Token.COMMA || lexer.token() == Token.SEMI) {
                lexer.nextToken();
            }

            if (lexer.token() != Token.BEGIN && lexer.token() != Token.RPAREN) {
                continue;
            }

            break;
        }
    }
}
