/*
 * Copyright 2015-2018 HuntLabs.cn
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance _with the License.
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
module hunt.sql.parser.SQLSelectParser;

import hunt.collection;

import hunt.sql.ast;
import hunt.sql.ast.expr;
import hunt.sql.ast.statement;
// import hunt.sql.dialect.db2.ast.stmt.DB2SelectQueryBlock;
import hunt.sql.dialect.mysql.ast.expr.MySqlOrderingExpr;
import hunt.sql.dialect.mysql.ast.statement.MySqlSelectQueryBlock;
import hunt.sql.util.FnvHash;
import hunt.sql.util.DBType;
import hunt.sql.parser.SQLParser;
import hunt.sql.parser.SQLExprParser;
import hunt.sql.parser.SQLSelectListCache;
import hunt.sql.parser.Lexer;
import hunt.sql.parser.SQLExprParser;
import hunt.sql.parser.Token;
import hunt.Float;
import hunt.sql.parser.ParserException;
import hunt.String;
import hunt.text;
import hunt.sql.ast.SQLCommentHint;

public class SQLSelectParser : SQLParser {
    protected SQLExprParser      exprParser;
    protected SQLSelectListCache selectListCache;

    public this(string sql){
        super(sql);
    }

    public this(Lexer lexer){
        super(lexer);
    }

    public this(SQLExprParser exprParser){
        this(exprParser, null);
    }

    public this(SQLExprParser exprParser, SQLSelectListCache selectListCache){
        super(exprParser.getLexer(), exprParser.getDbType());
        this.exprParser = exprParser;
        this.selectListCache = selectListCache;
    }

    public SQLSelect select() {
        SQLSelect select = new SQLSelect();

        if (lexer.token == Token.WITH) {
            SQLWithSubqueryClause _with = this.parseWith();
            select.setWithSubQuery(_with);
        }

        SQLSelectQuery query = query();
        select.setQuery(query);

        SQLOrderBy orderBy = this.parseOrderBy();

        if (cast(SQLSelectQueryBlock)(query) !is null) {
            SQLSelectQueryBlock queryBlock = cast(SQLSelectQueryBlock) query;

            if (queryBlock.getOrderBy() is null) {
                queryBlock.setOrderBy(orderBy);
            } else {
                select.setOrderBy(orderBy);
            }

            if (orderBy !is null) {
                parseFetchClause(queryBlock);
            }
        } else {
            select.setOrderBy(orderBy);
        }

        while (lexer.token == Token.HINT) {
            this.exprParser.parseHints!(SQLHint)((select.getHints()));
        }

        return select;
    }

    protected SQLUnionQuery createSQLUnionQuery() {
        SQLUnionQuery _union = new SQLUnionQuery();
        _union.setDbType(getDbType());
        return _union;
    }

    public SQLUnionQuery unionRest(SQLUnionQuery _union) {
        if (lexer.token == Token.ORDER) {
            SQLOrderBy orderBy = this.exprParser.parseOrderBy();
            _union.setOrderBy(orderBy);
            return unionRest(_union);
        }
        return _union;
    }

    public SQLSelectQuery queryRest(SQLSelectQuery selectQuery) {
        return queryRest(selectQuery, true);
    }

    public SQLSelectQuery queryRest(SQLSelectQuery selectQuery, bool acceptUnion) {
        if (!acceptUnion) {
            return selectQuery;
        }

        if (lexer.token == Token.UNION) {
            do {
                lexer.nextToken();

                SQLUnionQuery _union = createSQLUnionQuery();
                if (_union.getLeft() is null) {
                    _union.setLeft(selectQuery);
                }

                bool paren = lexer.token == Token.LPAREN;

                if (lexer.token == Token.ALL) {
                    _union.setOperator(SQLUnionOperator.UNION_ALL);
                    lexer.nextToken();
                } else if (lexer.token == Token.DISTINCT) {
                    _union.setOperator(SQLUnionOperator.DISTINCT);
                    lexer.nextToken();
                }
                SQLSelectQuery right = this.query(paren ? null : _union, false);
                _union.setRight(right);

                if (!paren) {
                    if (cast(SQLSelectQueryBlock)(right) !is null) {
                        SQLSelectQueryBlock rightQuery = cast(SQLSelectQueryBlock) right;
                        SQLOrderBy orderBy = rightQuery.getOrderBy();
                        SQLLimit limit = rightQuery.getLimit();
                        if (orderBy !is null && limit is null) {
                            _union.setOrderBy(orderBy);
                            rightQuery.setOrderBy(null);
                        }
                    } else if (cast(SQLUnionQuery)(right) !is null) {
                        SQLUnionQuery rightUnion = cast(SQLUnionQuery) right;
                        if (rightUnion.getOrderBy() !is null) {
                            _union.setOrderBy(rightUnion.getOrderBy());
                            rightUnion.setOrderBy(null);
                        }
                    }
                }

                _union = unionRest(_union);

                selectQuery = _union;

            } while (lexer.token() == Token.UNION);

            selectQuery = queryRest(selectQuery, true);

            return selectQuery;
        }

        if (lexer.token == Token.EXCEPT) {
            lexer.nextToken();

            SQLUnionQuery _union = new SQLUnionQuery();
            _union.setLeft(selectQuery);

            _union.setOperator(SQLUnionOperator.EXCEPT);

            SQLSelectQuery right = this.query(_union, false);
            _union.setRight(right);

            return queryRest(_union, true);
        }

        if (lexer.token == Token.INTERSECT) {
            lexer.nextToken();

            SQLUnionQuery _union = new SQLUnionQuery();
            _union.setLeft(selectQuery);

            _union.setOperator(SQLUnionOperator.INTERSECT);

            SQLSelectQuery right = this.query(_union, false);
            _union.setRight(right);

            return queryRest(_union, true);
        }

        if (acceptUnion && lexer.token == Token.MINUS) {
            lexer.nextToken();

            SQLUnionQuery _union = new SQLUnionQuery();
            _union.setLeft(selectQuery);

            _union.setOperator(SQLUnionOperator.MINUS);

            SQLSelectQuery right = this.query(_union, false);
            _union.setRight(right);

            return queryRest(_union, true);
        }

        return selectQuery;
    }

    public SQLSelectQuery query() {
        return query(null, true);
    }

    public SQLSelectQuery query(SQLObject parent) {
        return query(parent, true);
    }

    public SQLSelectQuery query(SQLObject parent, bool acceptUnion) {
        if (lexer.token == Token.LPAREN) {
            lexer.nextToken();

            SQLSelectQuery select = query();
            accept(Token.RPAREN);

            return queryRest(select, acceptUnion);
        }

        SQLSelectQueryBlock queryBlock = new SQLSelectQueryBlock();

        if (lexer.hasComment() && lexer.isKeepComments()) {
            queryBlock.addBeforeComment(lexer.readAndResetComments());
        }

        accept(Token.SELECT);

        if (lexer.token() == Token.HINT) {
            this.exprParser.parseHints!(SQLCommentHint)((queryBlock.getHints()));
        }

        if (lexer.token == Token.COMMENT) {
            lexer.nextToken();
        }

        if (DBType.INFORMIX.opEquals(dbType)) {
            if (lexer.identifierEquals(FnvHash.Constants.SKIP)) {
                lexer.nextToken();
                SQLExpr offset = this.exprParser.primary();
                queryBlock.setOffset(offset);
            }

            if (lexer.identifierEquals(FnvHash.Constants.FIRST)) {
                lexer.nextToken();
                SQLExpr first = this.exprParser.primary();
                queryBlock.setFirst(first);
            }
        }

        if (lexer.token == Token.DISTINCT) {
            queryBlock.setDistionOption(SQLSetQuantifier.DISTINCT);
            lexer.nextToken();
        } else if (lexer.token == Token.UNIQUE) {
            queryBlock.setDistionOption(SQLSetQuantifier.UNIQUE);
            lexer.nextToken();
        } else if (lexer.token == Token.ALL) {
            queryBlock.setDistionOption(SQLSetQuantifier.ALL);
            lexer.nextToken();
        }

        parseSelectList(queryBlock);

        parseFrom(queryBlock);

        parseWhere(queryBlock);

        parseGroupBy(queryBlock);

        parseSortBy(queryBlock);

        parseFetchClause(queryBlock);

        if (lexer.token() == Token.FOR) {
            lexer.nextToken();
            accept(Token.UPDATE);

            queryBlock.setForUpdate(true);

            if (lexer.identifierEquals(FnvHash.Constants.NO_WAIT) || lexer.identifierEquals(FnvHash.Constants.NOWAIT)) {
                lexer.nextToken();
                queryBlock.setNoWait(true);
            } else if (lexer.identifierEquals(FnvHash.Constants.WAIT)) {
                lexer.nextToken();
                SQLExpr waitTime = this.exprParser.primary();
                queryBlock.setWaitTime(waitTime);
            }
        }

        return queryRest(queryBlock, acceptUnion);
    }

    protected void parseSortBy(SQLSelectQueryBlock queryBlock) {

    }

    protected void withSubquery(SQLSelect s_select) {
        if (lexer.token == Token.WITH) {
            lexer.nextToken();

            SQLWithSubqueryClause withQueryClause = new SQLWithSubqueryClause();

            if (lexer.token == Token.RECURSIVE || lexer.identifierEquals(FnvHash.Constants.RECURSIVE)) {
                lexer.nextToken();
                withQueryClause.setRecursive(true);
            }

            for (;;) {
                SQLWithSubqueryClause.Entry entry = new SQLWithSubqueryClause.Entry();
                entry.setParent(withQueryClause);

                string _alias = this.lexer.stringVal();
                lexer.nextToken();
                entry.setAlias(_alias);

                if (lexer.token == Token.LPAREN) {
                    lexer.nextToken();
                    exprParser.names(entry.getColumns());
                    accept(Token.RPAREN);
                }

                accept(Token.AS);
                accept(Token.LPAREN);
                entry.setSubQuery(select());
                accept(Token.RPAREN);

                withQueryClause.addEntry(entry);

                if (lexer.token == Token.COMMA) {
                    lexer.nextToken();
                    continue;
                }

                break;
            }

            s_select.setWithSubQuery(withQueryClause);
        }
    }

    public SQLWithSubqueryClause parseWith() {
        accept(Token.WITH);

        SQLWithSubqueryClause withQueryClause = new SQLWithSubqueryClause();

        if (lexer.token == Token.RECURSIVE || lexer.identifierEquals(FnvHash.Constants.RECURSIVE)) {
            lexer.nextToken();
            withQueryClause.setRecursive(true);
        }

        for (;;) {
            SQLWithSubqueryClause.Entry entry = new SQLWithSubqueryClause.Entry();
            entry.setParent(withQueryClause);

            string _alias = this.lexer.stringVal();
            lexer.nextToken();
            entry.setAlias(_alias);

            if (lexer.token == Token.LPAREN) {
                lexer.nextToken();
                exprParser.names(entry.getColumns());
                accept(Token.RPAREN);
            }

            accept(Token.AS);
            accept(Token.LPAREN);

            switch (lexer.token) {
                case Token.SELECT:
                    entry.setSubQuery(select());
                    break;
                default:
                    break;
            }

            accept(Token.RPAREN);

            withQueryClause.addEntry(entry);

            if (lexer.token == Token.COMMA) {
                lexer.nextToken();
                continue;
            }

            break;
        }

        return withQueryClause;
    }

    public void parseWhere(SQLSelectQueryBlock queryBlock) {
        if (lexer.token == Token.WHERE) {
            lexer.nextTokenIdent();

            List!(string) beforeComments = null;
            if (lexer.hasComment() && lexer.isKeepComments()) {
                beforeComments = lexer.readAndResetComments();
            }

            SQLExpr where;

            if (lexer.token == Token.IDENTIFIER) {
                string ident = lexer.stringVal();
                long hash_lower = lexer.hash_lower();
                lexer.nextTokenEq();

                SQLExpr identExpr;
                if (lexer.token == Token.LITERAL_CHARS) {
                    string literal = lexer.stringVal;
                    if (hash_lower == FnvHash.Constants.TIMESTAMP) {
                        identExpr = new SQLTimestampExpr(literal);
                        lexer.nextToken();
                    } else if (hash_lower == FnvHash.Constants.DATE) {
                        identExpr = new SQLDateExpr(literal);
                        lexer.nextToken();
                    } else if (hash_lower == FnvHash.Constants.REAL) {
                        identExpr = new SQLRealExpr(Float.parseFloat(literal));
                        lexer.nextToken();
                    } else {
                        identExpr = new SQLIdentifierExpr(ident, hash_lower);
                    }
                } else {
                    identExpr = new SQLIdentifierExpr(ident, hash_lower);
                }

                if (lexer.token == Token.DOT) {
                    identExpr = this.exprParser.primaryRest(identExpr);
                }

                if (lexer.token == Token.EQ) {
                    SQLExpr rightExp;

                    lexer.nextToken();

                    try {
                        rightExp = this.exprParser.bitOr();
                    } catch (ParserException e) {
                        throw new ParserException("EOF, " ~ ident ~ "=", e);
                    }

                    where = new SQLBinaryOpExpr(identExpr, SQLBinaryOperator.Equality, rightExp, dbType);
                    switch (lexer.token) {
                        case Token.BETWEEN:
                        case Token.IS:
                        case Token.EQ:
                        case Token.IN:
                        case Token.CONTAINS:
                        case Token.BANG_TILDE_STAR:
                        case Token.TILDE_EQ:
                        case Token.LT:
                        case Token.LTEQ:
                        case Token.LTEQGT:
                        case Token.GT:
                        case Token.GTEQ:
                        case Token.LTGT:
                        case Token.BANGEQ:
                        case Token.LIKE:
                        case Token.NOT:
                            where = this.exprParser.relationalRest(where);
                            break;
                        default:
                            break;
                    }

                    where = this.exprParser.andRest(where);
                    where = this.exprParser.xorRest(where);
                    where = this.exprParser.orRest(where);
                } else {
                    identExpr = this.exprParser.primaryRest(identExpr);
                    where = this.exprParser.exprRest(identExpr);
                }
            } else {
                where = this.exprParser.expr();
            }
//            where = this.exprParser.expr();

            if (beforeComments !is null) {
                where.addBeforeComment(beforeComments);
            }

            if (lexer.hasComment() && lexer.isKeepComments() //
                    && lexer.token != Token.INSERT // odps multi-insert
                    ) {
                where.addAfterComment(lexer.readAndResetComments());
            }

            queryBlock.setWhere(where);
        }
    }

    protected void parseWindow(SQLSelectQueryBlock queryBlock) {
        if (!(lexer.identifierEquals(FnvHash.Constants.WINDOW) || lexer.token == Token.WINDOW)) {
            return;
        }

        lexer.nextToken();

        for (;;) {
            SQLName name = this.exprParser.name();
            accept(Token.AS);
            SQLOver s_over = new SQLOver();
            this.exprParser.over(s_over);
            queryBlock.addWindow(new SQLWindow(name, s_over));

            if (lexer.token == Token.COMMA) {
                lexer.nextToken();
                continue;
            }

            break;
        }
    }
    
    protected void parseGroupBy(SQLSelectQueryBlock queryBlock) {
        if (lexer.token == (Token.GROUP)) {
            lexer.nextTokenBy();
            accept(Token.BY);

            SQLSelectGroupByClause groupBy = new SQLSelectGroupByClause();
            if (lexer.identifierEquals(FnvHash.Constants.ROLLUP)) {
                lexer.nextToken();
                accept(Token.LPAREN);
                groupBy.setWithRollUp(true);
            }
            if (lexer.identifierEquals(FnvHash.Constants.CUBE)) {
                lexer.nextToken();
                accept(Token.LPAREN);
                groupBy.setWithCube(true);
            }

            for (;;) {
                SQLExpr item = parseGroupByItem();
                
                item.setParent(groupBy);
                groupBy.addItem(item);

                if (!(lexer.token == (Token.COMMA))) {
                    break;
                }

                lexer.nextToken();
            }
            if (groupBy.isWithRollUp() || groupBy.isWithCube()) {
                accept(Token.RPAREN);
            }

            if (lexer.token == (Token.HAVING)) {
                lexer.nextToken();

                SQLExpr having = this.exprParser.expr();
                groupBy.setHaving(having);
            }
            
            if (lexer.token == Token.WITH) {
                lexer.nextToken();
                
                if (lexer.identifierEquals(FnvHash.Constants.CUBE)) {
                    lexer.nextToken();
                    groupBy.setWithCube(true);
                } else if(lexer.identifierEquals(FnvHash.Constants.ROLLUP)) {
                    lexer.nextToken();
                    groupBy.setWithRollUp(true);
                // } else if (lexer.identifierEquals(FnvHash.Constants.RS)
                //         && DBType.DB2.opEquals(dbType)) {
                //     lexer.nextToken();
                //     ((DB2SelectQueryBlock) queryBlock).setIsolation(DB2SelectQueryBlock.Isolation.RS);
                // } else if (lexer.identifierEquals(FnvHash.Constants.RR)
                //         && DBType.DB2.opEquals(dbType)) {
                //     lexer.nextToken();
                //     ((DB2SelectQueryBlock) queryBlock).setIsolation(DB2SelectQueryBlock.Isolation.RR);
                // } else if (lexer.identifierEquals(FnvHash.Constants.CS)
                //         && DBType.DB2.opEquals(dbType)) {
                //     lexer.nextToken();
                //     ((DB2SelectQueryBlock) queryBlock).setIsolation(DB2SelectQueryBlock.Isolation.CS);
                // } else if (lexer.identifierEquals(FnvHash.Constants.UR)
                //         && DBType.DB2.opEquals(dbType)) {
                //     lexer.nextToken();
                //     ((DB2SelectQueryBlock) queryBlock).setIsolation(DB2SelectQueryBlock.Isolation.UR);
                } else {
                    throw new ParserException("TODO " ~ lexer.info());
                }
            }
            
            queryBlock.setGroupBy(groupBy);
        } else if (lexer.token == (Token.HAVING)) {
            lexer.nextToken();

            SQLSelectGroupByClause groupBy = new SQLSelectGroupByClause();
            groupBy.setHaving(this.exprParser.expr());

            if (lexer.token == (Token.GROUP)) {
                lexer.nextToken();
                accept(Token.BY);

                for (;;) {
                    SQLExpr item = parseGroupByItem();
                    
                    item.setParent(groupBy);
                    groupBy.addItem(item);

                    if (!(lexer.token == (Token.COMMA))) {
                        break;
                    }

                    lexer.nextToken();
                }
            }
            
            if (lexer.token == Token.WITH) {
                lexer.nextToken();
                acceptIdentifier("ROLLUP");

                groupBy.setWithRollUp(true);
            }
            
            if(DBType.MYSQL.opEquals(getDbType())
                    && lexer.token == Token.DESC) {
                lexer.nextToken(); // skip
            }

            queryBlock.setGroupBy(groupBy);
        }
    }

    protected SQLExpr parseGroupByItem() {
        SQLExpr item = this.exprParser.expr();
        
        if(DBType.MYSQL.opEquals(getDbType())) {
            if (lexer.token == Token.DESC) {
                lexer.nextToken(); // skip
                item =new MySqlOrderingExpr(item, SQLOrderingSpecification.DESC);
            } else if (lexer.token == Token.ASC) {
                lexer.nextToken(); // skip
                item =new MySqlOrderingExpr(item, SQLOrderingSpecification.ASC);
            }
        }
        return item;
    }

    public void parseSelectList(SQLSelectQueryBlock queryBlock) {
         List!(SQLSelectItem) selectList = queryBlock.getSelectList();
        for (;;) {
             SQLSelectItem selectItem = this.exprParser.parseSelectItem();
            selectList.add(selectItem);
            selectItem.setParent(queryBlock);

            if (lexer.token != Token.COMMA) {
                break;
            }

            lexer.nextToken();
        }
    }

    public void parseFrom(SQLSelectQueryBlock queryBlock) {
        if (lexer.token != Token.FROM) {
            return;
        }
        
        lexer.nextToken();
        
        queryBlock.setFrom(
                parseTableSource());
    }

    public SQLTableSource parseTableSource() {
        if (lexer.token == Token.LPAREN) {
            lexer.nextToken();
            SQLTableSource tableSource;
            if (lexer.token == Token.SELECT || lexer.token == Token.WITH
                    || lexer.token == Token.SEL) {
                SQLSelect select = select();
                accept(Token.RPAREN);
                SQLSelectQuery query = queryRest(select.getQuery(), true);
                if (cast(SQLUnionQuery)(query) !is null) {
                    tableSource = new SQLUnionQueryTableSource(cast(SQLUnionQuery) query);
                } else {
                    tableSource = new SQLSubqueryTableSource(select);
                }
            } else if (lexer.token == Token.LPAREN) {
                tableSource = parseTableSource();
                accept(Token.RPAREN);
            } else {
                tableSource = parseTableSource();
                accept(Token.RPAREN);
            }

            if (lexer.token == Token.AS
                    && cast(SQLValuesTableSource)(tableSource) !is null
                    && (cast(SQLValuesTableSource) tableSource).getColumns().size() == 0)
            {
                lexer.nextToken();

                string _alias = this.tableAlias();
                tableSource.setAlias(_alias);

                SQLValuesTableSource values = cast(SQLValuesTableSource) tableSource;
                accept(Token.LPAREN);
                this.exprParser.names(values.getColumns(), values);
                accept(Token.RPAREN);
            }

            return parseTableSourceRest(tableSource);
        }

        if (lexer.token() == Token.VALUES) {
            lexer.nextToken();
            SQLValuesTableSource tableSource = new SQLValuesTableSource();

            for (;;) {
                accept(Token.LPAREN);
                SQLListExpr listExpr = new SQLListExpr();
                this.exprParser.exprList(listExpr.getItems(), listExpr);
                accept(Token.RPAREN);

                listExpr.setParent(tableSource);

                tableSource.getValues().add(listExpr);

                if (lexer.token == Token.COMMA) {
                    lexer.nextToken();
                    continue;
                }
                break;
            }

            if (lexer.token == Token.RPAREN) {
                return tableSource;
            }

            string _alias = this.tableAlias();
            if (_alias !is null) {
                tableSource.setAlias(_alias);
            }

            accept(Token.LPAREN);
            this.exprParser.names(tableSource.getColumns(), tableSource);
            accept(Token.RPAREN);

            return tableSource;
        }

        if (lexer.token == Token.SELECT) {
            throw new ParserException("TODO " ~ lexer.info());
        }

        SQLExprTableSource tableReference = new SQLExprTableSource();

        parseTableSourceQueryTableExpr(tableReference);

        SQLTableSource tableSrc = parseTableSourceRest(tableReference);

        if (lexer.hasComment() && lexer.isKeepComments()) {
            tableSrc.addAfterComment(lexer.readAndResetComments());
        }

        return tableSrc;
    }

    protected void parseTableSourceQueryTableExpr(SQLExprTableSource tableReference) {
        if (lexer.token == Token.LITERAL_ALIAS || lexer.token == Token.IDENTIFIED
            || lexer.token == Token.LITERAL_CHARS) {
            tableReference.setExpr(this.exprParser.name());
            return;
        }

        tableReference.setExpr(expr());
    }

    protected SQLTableSource primaryTableSourceRest(SQLTableSource tableSource) {
        return tableSource;
    }

    protected SQLTableSource parseTableSourceRest(SQLTableSource tableSource) {
        if (tableSource.getAlias() is null || tableSource.getAlias().length == 0) {
            Token token = lexer.token;
            long hash;
            if (token != Token.LEFT
                    && token != Token.RIGHT
                    && token != Token.FULL
                    && token != Token.OUTER
                    && !(token == Token.IDENTIFIER
                        && ((hash = lexer.hash_lower()) == FnvHash.Constants.STRAIGHT_JOIN
                            || hash == FnvHash.Constants.CROSS)))
            {
                string _alias = tableAlias();
                if (_alias !is null) {
                    tableSource.setAlias(_alias);

                    if (lexer.token == Token.WHERE) {
                        return tableSource;
                    }

                    return parseTableSourceRest(tableSource);
                }
            }
        }

        SQLJoinTableSource.JoinType joinType = null;

        bool natural = lexer.identifierEquals(FnvHash.Constants.NATURAL) && DBType.MYSQL.opEquals(dbType);
        if (natural) {
            lexer.nextToken();
        }

        if (lexer.token == Token.LEFT) {
            lexer.nextToken();

            if (lexer.identifierEquals(FnvHash.Constants.SEMI)) {
                lexer.nextToken();
                joinType = SQLJoinTableSource.JoinType.LEFT_SEMI_JOIN;
            } else if (lexer.identifierEquals(FnvHash.Constants.ANTI)) {
                lexer.nextToken();
                joinType = SQLJoinTableSource.JoinType.LEFT_ANTI_JOIN;
            } else if (lexer.token == Token.OUTER) {
                lexer.nextToken();
                joinType = SQLJoinTableSource.JoinType.LEFT_OUTER_JOIN;
            } else {
                joinType = SQLJoinTableSource.JoinType.LEFT_OUTER_JOIN;
            }

            accept(Token.JOIN);

        } else if (lexer.token == Token.RIGHT) {
            lexer.nextToken();
            if (lexer.token == Token.OUTER) {
                lexer.nextToken();
            }
            accept(Token.JOIN);
            joinType = SQLJoinTableSource.JoinType.RIGHT_OUTER_JOIN;
        } else if (lexer.token == Token.FULL) {
            lexer.nextToken();
            if (lexer.token == Token.OUTER) {
                lexer.nextToken();
            }
            accept(Token.JOIN);
            joinType = SQLJoinTableSource.JoinType.FULL_OUTER_JOIN;
        } else if (lexer.token == Token.INNER) {
            lexer.nextToken();
            accept(Token.JOIN);
            joinType = SQLJoinTableSource.JoinType.INNER_JOIN;
        } else if (lexer.token == Token.JOIN) {
            lexer.nextToken();
            joinType = SQLJoinTableSource.JoinType.JOIN;
        } else if (lexer.token == Token.COMMA) {
            lexer.nextToken();
            joinType = SQLJoinTableSource.JoinType.COMMA;
        } else if (lexer.identifierEquals(FnvHash.Constants.STRAIGHT_JOIN)) {
            lexer.nextToken();
            joinType = SQLJoinTableSource.JoinType.STRAIGHT_JOIN;
        } else if (lexer.identifierEquals(FnvHash.Constants.CROSS)) {
            lexer.nextToken();
            if (lexer.token == Token.JOIN) {
                lexer.nextToken();
                joinType = SQLJoinTableSource.JoinType.CROSS_JOIN;
            } else if (lexer.identifierEquals(FnvHash.Constants.APPLY)) {
                lexer.nextToken();
                joinType = SQLJoinTableSource.JoinType.CROSS_APPLY;
            }
        } else if (lexer.token == Token.OUTER) {
            lexer.nextToken();
            if (lexer.identifierEquals(FnvHash.Constants.APPLY)) {
                lexer.nextToken();
                joinType = SQLJoinTableSource.JoinType.OUTER_APPLY;
            }
        }

        if (joinType.name.length != 0) {
            SQLJoinTableSource join = new SQLJoinTableSource();
            join.setLeft(tableSource);
            join.setJoinType(joinType);


            SQLTableSource rightTableSource;
            if (lexer.token == Token.LPAREN) {
                lexer.nextToken();
                if (lexer.token == Token.SELECT) {
                    SQLSelect select = this.select();
                    rightTableSource = new SQLSubqueryTableSource(select);
                } else  {
                    rightTableSource = this.parseTableSource();
                }
                accept(Token.RPAREN);
            } else {
                SQLExpr expr = this.expr();
                rightTableSource = new SQLExprTableSource(expr);
                primaryTableSourceRest(rightTableSource);
            }

            if (lexer.token == Token.USING
                ||lexer.identifierEquals(FnvHash.Constants.USING))
            {
                Lexer.SavePoint savePoint = lexer.mark();
                lexer.nextToken();

                if (lexer.token == Token.LPAREN) {
                    lexer.nextToken();
                    join.setRight(rightTableSource);
                    this.exprParser.exprList(join.getUsing(), join);
                    accept(Token.RPAREN);
                } else if (lexer.token == Token.IDENTIFIER) {
                    lexer.reset(savePoint);
                    join.setRight(rightTableSource);
                    return join;
                } else {
                    join.setAlias(this.tableAlias());
                }
            } else {
                rightTableSource.setAlias(this.tableAlias());

                primaryTableSourceRest(rightTableSource);
            }

            if (lexer.token == Token.WITH) {
                lexer.nextToken();
                accept(Token.LPAREN);

                for (;;) {
                    SQLExpr hintExpr = this.expr();
                    SQLExprHint hint = new SQLExprHint(hintExpr);
                    hint.setParent(tableSource);
                    rightTableSource.getHints().add(hint);
                    if (lexer.token == Token.COMMA) {
                        lexer.nextToken();
                        continue;
                    } else {
                        break;
                    }
                }

                accept(Token.RPAREN);
            }

            join.setRight(rightTableSource);

            if (!natural) {
                if (tableSource.aliasHashCode64() == FnvHash.Constants.NATURAL && DBType.MYSQL.opEquals(dbType)) {
                    tableSource.setAlias(null);
                    natural = true;
                }
            }
            join.setNatural(natural);

            if (lexer.token == Token.ON) {
                lexer.nextToken();
                join.setCondition(expr());
            } else if (lexer.token == Token.USING
                    || lexer.identifierEquals(FnvHash.Constants.USING)) {
                Lexer.SavePoint savePoint = lexer.mark();
                lexer.nextToken();
                if (lexer.token == Token.LPAREN) {
                    lexer.nextToken();
                    this.exprParser.exprList(join.getUsing(), join);
                    accept(Token.RPAREN);
                } else {
                    lexer.reset(savePoint);
                }
            }

            return parseTableSourceRest(join);
        }

        if (tableSource.aliasHashCode64() == FnvHash.Constants.LATERAL
                && lexer.token() == Token.VIEW) {
            return parseLateralView(tableSource);
        }

        if (lexer.identifierEquals(FnvHash.Constants.LATERAL)) {
            lexer.nextToken();
            return parseLateralView(tableSource);
        }

        return tableSource;
    }

    public SQLExpr expr() {
        return this.exprParser.expr();
    }

    public SQLOrderBy parseOrderBy() {
        return this.exprParser.parseOrderBy();
    }

    public void acceptKeyword(string ident) {
        if (lexer.token == Token.IDENTIFIER && equalsIgnoreCase(ident, lexer.stringVal())) {
            lexer.nextToken();
        } else {
            setErrorEndPos(lexer.pos());
            throw new ParserException("syntax error, expect " ~ ident ~ ", actual " ~ lexer.token ~ ", " ~ lexer.info());
        }
    }

    public void parseFetchClause(SQLSelectQueryBlock queryBlock) {
        if (lexer.token == Token.LIMIT) {
            SQLLimit limit = this.exprParser.parseLimit();
            queryBlock.setLimit(limit);
            return;
        }

        if (lexer.identifierEquals(FnvHash.Constants.OFFSET) || lexer.token == Token.OFFSET) {
            lexer.nextToken();
            SQLExpr offset = this.exprParser.primary();
            queryBlock.setOffset(offset);
            if (lexer.identifierEquals(FnvHash.Constants.ROW) || lexer.identifierEquals(FnvHash.Constants.ROWS)) {
                lexer.nextToken();
            }
        }

        if (lexer.token == Token.FETCH) {
            lexer.nextToken();
            if (lexer.token == Token.FIRST
                    || lexer.token == Token.NEXT
                    || lexer.identifierEquals(FnvHash.Constants.NEXT)) {
                lexer.nextToken();
            } else {
                acceptIdentifier("FIRST");
            }
            SQLExpr first = this.exprParser.primary();
            queryBlock.setFirst(first);
            if (lexer.identifierEquals(FnvHash.Constants.ROW) || lexer.identifierEquals(FnvHash.Constants.ROWS)) {
                lexer.nextToken();
            }

            if (lexer.token == Token.ONLY) {
                lexer.nextToken();
            } else {
                acceptIdentifier("ONLY");
            }
        }
    }

    protected void parseHierachical(SQLSelectQueryBlock queryBlock) {
        if (lexer.token == Token.CONNECT || lexer.identifierEquals(FnvHash.Constants.CONNECT)) {
            lexer.nextToken();
            accept(Token.BY);

            if (lexer.token == Token.PRIOR || lexer.identifierEquals(FnvHash.Constants.PRIOR)) {
                lexer.nextToken();
                queryBlock.setPrior(true);
            }

            if (lexer.identifierEquals(FnvHash.Constants.NOCYCLE)) {
                queryBlock.setNoCycle(true);
                lexer.nextToken();

                if (lexer.token == Token.PRIOR) {
                    lexer.nextToken();
                    queryBlock.setPrior(true);
                }
            }
            queryBlock.setConnectBy(this.exprParser.expr());
        }

        if (lexer.token == Token.START || lexer.identifierEquals(FnvHash.Constants.START)) {
            lexer.nextToken();
            accept(Token.WITH);

            queryBlock.setStartWith(this.exprParser.expr());
        }

        if (lexer.token == Token.CONNECT || lexer.identifierEquals(FnvHash.Constants.CONNECT)) {
            lexer.nextToken();
            accept(Token.BY);

            if (lexer.token == Token.PRIOR || lexer.identifierEquals(FnvHash.Constants.PRIOR)) {
                lexer.nextToken();
                queryBlock.setPrior(true);
            }

            if (lexer.identifierEquals(FnvHash.Constants.NOCYCLE)) {
                queryBlock.setNoCycle(true);
                lexer.nextToken();

                if (lexer.token == Token.PRIOR || lexer.identifierEquals(FnvHash.Constants.PRIOR)) {
                    lexer.nextToken();
                    queryBlock.setPrior(true);
                }
            }
            queryBlock.setConnectBy(this.exprParser.expr());
        }
    }

    protected SQLTableSource parseLateralView(SQLTableSource tableSource) {
        accept(Token.VIEW);
        if ("LATERAL".equalsIgnoreCase(tableSource.getAlias())) {
            tableSource.setAlias(null);
        }
        SQLLateralViewTableSource lateralViewTabSrc = new SQLLateralViewTableSource();
        lateralViewTabSrc.setTableSource(tableSource);

        SQLMethodInvokeExpr udtf = cast(SQLMethodInvokeExpr) this.exprParser.expr();
        lateralViewTabSrc.setMethod(udtf);

        string _alias = as();
        lateralViewTabSrc.setAlias(_alias);

        accept(Token.AS);

        this.exprParser.names(lateralViewTabSrc.getColumns());

        return parseTableSourceRest(lateralViewTabSrc);
    }
}
