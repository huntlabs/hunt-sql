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
module hunt.sql.dialect.mysql.parser.MySqlSelectIntoParser;


import hunt.collection;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLSetQuantifier;
import hunt.sql.ast.expr.SQLIdentifierExpr;
import hunt.sql.ast.expr.SQLLiteralExpr;
import hunt.sql.ast.expr.SQLVariantRefExpr;
import hunt.sql.ast.statement.SQLSelect;
import hunt.sql.ast.statement.SQLSelectQuery;
import hunt.sql.ast.statement.SQLSelectQueryBlock;
import hunt.sql.ast.statement.SQLTableSource;
import hunt.sql.ast.statement.SQLUnionQuery;
import hunt.sql.dialect.mysql.ast.MySqlForceIndexHint;
import hunt.sql.dialect.mysql.ast.MySqlIgnoreIndexHint;
import hunt.sql.dialect.mysql.ast.MySqlIndexHint;
import hunt.sql.dialect.mysql.ast.MySqlIndexHintImpl;
import hunt.sql.dialect.mysql.ast.MySqlUseIndexHint;
import hunt.sql.dialect.mysql.ast.clause.MySqlSelectIntoStatement;
import hunt.sql.dialect.mysql.ast.expr.MySqlOutFileExpr;
import hunt.sql.dialect.mysql.ast.statement.MySqlSelectQueryBlock;
import hunt.sql.parser.ParserException;
import hunt.sql.parser.SQLExprParser;
import hunt.sql.parser.SQLSelectParser;
import hunt.sql.parser.Token;
import hunt.sql.dialect.mysql.parser.MySqlExprParser;
import hunt.sql.ast.SQLObject;
import hunt.Boolean;
import hunt.sql.ast.SQLCommentHint;

public class MySqlSelectIntoParser : SQLSelectParser {
	private List!(SQLExpr) argsList;

    public this(SQLExprParser exprParser){
        super(exprParser);
    }

    public this(string sql){
        this(new MySqlExprParser(sql));
    }
    
    public MySqlSelectIntoStatement parseSelectInto()
    {
    	SQLSelect select=select();
    	MySqlSelectIntoStatement stmt=new MySqlSelectIntoStatement();
    	stmt.setSelect(select);
    	stmt.setVarList(argsList);
    	return stmt;
    	
    }

    override
    public SQLSelectQuery query() {
        if (lexer.token() == (Token.LPAREN)) {
            lexer.nextToken();

            SQLSelectQuery select = query();
            accept(Token.RPAREN);

            return queryRest(select);
        }

        MySqlSelectQueryBlock queryBlock = new MySqlSelectQueryBlock();

        if (lexer.token() == Token.SELECT) {
            lexer.nextToken();

            if (lexer.token() == Token.HINT) {
                this.exprParser.parseHints!(SQLCommentHint)((queryBlock.getHints()));
            }

            if (lexer.token() == Token.COMMENT) {
                lexer.nextToken();
            }

            if (lexer.token() == (Token.DISTINCT)) {
                queryBlock.setDistionOption(SQLSetQuantifier.DISTINCT);
                lexer.nextToken();
            } else if (lexer.identifierEquals("DISTINCTROW")) {
                queryBlock.setDistionOption(SQLSetQuantifier.DISTINCTROW);
                lexer.nextToken();
            } else if (lexer.token() == (Token.ALL)) {
                queryBlock.setDistionOption(SQLSetQuantifier.ALL);
                lexer.nextToken();
            }

            if (lexer.identifierEquals("HIGH_PRIORITY")) {
                queryBlock.setHignPriority(true);
                lexer.nextToken();
            }

            if (lexer.identifierEquals("STRAIGHT_JOIN")) {
                queryBlock.setStraightJoin(true);
                lexer.nextToken();
            }

            if (lexer.identifierEquals("SQL_SMALL_RESULT")) {
                queryBlock.setSmallResult(true);
                lexer.nextToken();
            }

            if (lexer.identifierEquals("SQL_BIG_RESULT")) {
                queryBlock.setBigResult(true);
                lexer.nextToken();
            }

            if (lexer.identifierEquals("SQL_BUFFER_RESULT")) {
                queryBlock.setBufferResult(true);
                lexer.nextToken();
            }

            if (lexer.identifierEquals("SQL_CACHE")) {
                queryBlock.setCache(new Boolean(true));
                lexer.nextToken();
            }

            if (lexer.identifierEquals("SQL_NO_CACHE")) {
                queryBlock.setCache(new Boolean(false));
                lexer.nextToken();
            }

            if (lexer.identifierEquals("SQL_CALC_FOUND_ROWS")) {
                queryBlock.setCalcFoundRows(true);
                lexer.nextToken();
            }

            parseSelectList(queryBlock);
            
            argsList=parseIntoArgs();
        }

        parseFrom(queryBlock);

        parseWhere(queryBlock);

        parseGroupBy(queryBlock);

        queryBlock.setOrderBy(this.exprParser.parseOrderBy());

        if (lexer.token() == Token.LIMIT) {
            queryBlock.setLimit(this.exprParser.parseLimit());
        }

        if (lexer.token() == Token.PROCEDURE) {
            lexer.nextToken();
            throw new ParserException("TODO. " ~ lexer.info());
        }

        parseInto(queryBlock);

        if (lexer.token() == Token.FOR) {
            lexer.nextToken();
            accept(Token.UPDATE);

            queryBlock.setForUpdate(true);
        }

        if (lexer.token() == Token.LOCK) {
            lexer.nextToken();
            accept(Token.IN);
            acceptIdentifier("SHARE");
            acceptIdentifier("MODE");
            queryBlock.setLockInShareMode(true);
        }

        return queryRest(queryBlock);
    }
    /**
     * parser the select into arguments
     * @return
     */
	protected List!(SQLExpr) parseIntoArgs() {
		
		List!(SQLExpr) args=new ArrayList!(SQLExpr)();
		if (lexer.token() == (Token.INTO)) {
			accept(Token.INTO);
			//lexer.nextToken();
			for (;;) {
				SQLExpr var = exprParser.primary();
				if (cast(SQLIdentifierExpr)(var) !is null) {
					var = new SQLVariantRefExpr(
							(cast(SQLIdentifierExpr) var).getName());
				}
				args.add(var);
				if (lexer.token() == Token.COMMA) {
					accept(Token.COMMA);
					continue;
				}
				else
				{
					break;
				}
			}
		}
		return args;
	}
    
    
    protected void parseInto(SQLSelectQueryBlock queryBlock) {
        if (lexer.token() == (Token.INTO)) {
            lexer.nextToken();

            if (lexer.identifierEquals("OUTFILE")) {
                lexer.nextToken();

                MySqlOutFileExpr outFile = new MySqlOutFileExpr();
                outFile.setFile(expr());

                queryBlock.setInto(outFile);

                if (lexer.identifierEquals("FIELDS") || lexer.identifierEquals("COLUMNS")) {
                    lexer.nextToken();

                    if (lexer.identifierEquals("TERMINATED")) {
                        lexer.nextToken();
                        accept(Token.BY);
                    }
                    outFile.setColumnsTerminatedBy(cast(SQLLiteralExpr) expr());

                    if (lexer.identifierEquals("OPTIONALLY")) {
                        lexer.nextToken();
                        outFile.setColumnsEnclosedOptionally(true);
                    }

                    if (lexer.identifierEquals("ENCLOSED")) {
                        lexer.nextToken();
                        accept(Token.BY);
                        outFile.setColumnsEnclosedBy(cast(SQLLiteralExpr) expr());
                    }

                    if (lexer.identifierEquals("ESCAPED")) {
                        lexer.nextToken();
                        accept(Token.BY);
                        outFile.setColumnsEscaped(cast(SQLLiteralExpr) expr());
                    }
                }

                if (lexer.identifierEquals("LINES")) {
                    lexer.nextToken();

                    if (lexer.identifierEquals("STARTING")) {
                        lexer.nextToken();
                        accept(Token.BY);
                        outFile.setLinesStartingBy(cast(SQLLiteralExpr) expr());
                    } else {
                        lexer.identifierEquals("TERMINATED");
                        lexer.nextToken();
                        accept(Token.BY);
                        outFile.setLinesTerminatedBy(cast(SQLLiteralExpr) expr());
                    }
                }
            } else {
                queryBlock.setInto(this.exprParser.name());
            }
        }
    }

    override protected SQLTableSource parseTableSourceRest(SQLTableSource tableSource) {
        if (lexer.identifierEquals("USING")) {
            return tableSource;
        }

        parseIndexHintList(tableSource);
	
        return super.parseTableSourceRest(tableSource);
    }

    private void parseIndexHintList(SQLTableSource tableSource) {
	if (lexer.token() == Token.USE) {
            lexer.nextToken();
            MySqlUseIndexHint hint = new MySqlUseIndexHint();
            parseIndexHint(hint);
            tableSource.getHints().add(hint);
	    parseIndexHintList(tableSource);
        }

        if (lexer.identifierEquals("IGNORE")) {
            lexer.nextToken();
            MySqlIgnoreIndexHint hint = new MySqlIgnoreIndexHint();
            parseIndexHint(hint);
            tableSource.getHints().add(hint);
	    parseIndexHintList(tableSource);
        }

        if (lexer.identifierEquals("FORCE")) {
            lexer.nextToken();
            MySqlForceIndexHint hint = new MySqlForceIndexHint();
            parseIndexHint(hint);
            tableSource.getHints().add(hint);
	    parseIndexHintList(tableSource);
        }
    }

    private void parseIndexHint(MySqlIndexHintImpl hint) {
        if (lexer.token() == Token.INDEX) {
            lexer.nextToken();
        } else {
            accept(Token.KEY);
        }

        if (lexer.token() == Token.FOR) {
            lexer.nextToken();

            if (lexer.token() == Token.JOIN) {
                lexer.nextToken();
                hint.setOption(MySqlIndexHint.Option.JOIN);
            } else if (lexer.token() == Token.ORDER) {
                lexer.nextToken();
                accept(Token.BY);
                hint.setOption(MySqlIndexHint.Option.ORDER_BY);
            } else {
                accept(Token.GROUP);
                accept(Token.BY);
                hint.setOption(MySqlIndexHint.Option.GROUP_BY);
            }
        }

        accept(Token.LPAREN);
        if (lexer.token() == Token.PRIMARY) {
            lexer.nextToken();
            hint.getIndexList().add(new SQLIdentifierExpr("PRIMARY"));
        } else {
            this.exprParser.names(hint.getIndexList());
        }
        accept(Token.RPAREN);
    }

    override public SQLUnionQuery unionRest(SQLUnionQuery union_p) {
        if (lexer.token() == Token.LIMIT) {
            union_p.setLimit(this.exprParser.parseLimit());
        }
        return super.unionRest(union_p);
    }
    
    public MySqlExprParser getExprParser() {
        return cast(MySqlExprParser) exprParser;
    }
}
