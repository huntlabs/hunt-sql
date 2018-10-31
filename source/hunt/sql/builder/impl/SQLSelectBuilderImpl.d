/*
 * Copyright 2015-2018 HuntLabs.cn.
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
module hunt.sql.builder.impl.SQLSelectBuilderImpl;

import hunt.container;

import hunt.sql.SQLUtils;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLOrderBy;
import hunt.sql.ast.SQLStatement;
import hunt.sql.ast.expr.SQLBinaryOperator;
import hunt.sql.ast.expr.SQLIdentifierExpr;
import hunt.sql.ast.expr.SQLIntegerExpr;
import hunt.sql.ast.statement.SQLExprTableSource;
import hunt.sql.ast.statement.SQLJoinTableSource;
import hunt.sql.ast.statement.SQLSelect;
import hunt.sql.ast.statement.SQLSelectGroupByClause;
import hunt.sql.ast.statement.SQLSelectItem;
import hunt.sql.ast.statement.SQLSelectOrderByItem;
import hunt.sql.ast.statement.SQLSelectQuery;
import hunt.sql.ast.statement.SQLSelectQueryBlock;
import hunt.sql.ast.statement.SQLSelectStatement;
import hunt.sql.builder.SQLSelectBuilder;
import hunt.sql.ast.SQLSetQuantifier;
// import hunt.sql.dialect.db2.ast.stmt.DB2SelectQueryBlock;
import hunt.sql.dialect.mysql.ast.statement.MySqlSelectQueryBlock;
import hunt.sql.ast.SQLLimit;
// import hunt.sql.dialect.odps.ast.OdpsSelectQueryBlock;
// import hunt.sql.dialect.oracle.ast.stmt.OracleSelectQueryBlock;
import hunt.sql.dialect.postgresql.ast.stmt.PGSelectQueryBlock;
// import hunt.sql.dialect.sqlserver.ast.SQLServerSelectQueryBlock;
// import hunt.sql.dialect.sqlserver.ast.SQLServerTop;
import hunt.sql.util.DBType;
import hunt.sql.builder.SQLBuilder;

public class SQLSelectBuilderImpl : SQLSelectBuilder {

    private SQLSelectStatement stmt;
    private string             dbType;

    public this(string dbType){
        this(new SQLSelectStatement(), dbType);
    }
    
    public this(string sql, string dbType){
        List!SQLStatement stmtList = SQLUtils.parseStatements(sql, dbType);

        if (stmtList.size() == 0) {
            throw new Exception("not support empty-statement :" ~ sql);
        }

        if (stmtList.size() > 1) {
            throw new Exception("not support multi-statement :" ~ sql);
        }

        SQLSelectStatement stmt = cast(SQLSelectStatement) stmtList.get(0);
        this.stmt = stmt;
        this.dbType = dbType;
    }

    public this(SQLSelectStatement stmt, string dbType){
        this.stmt = stmt;
        this.dbType = dbType;
    }

    public SQLSelect getSQLSelect() {
        if (stmt.getSelect() is null) {
            stmt.setSelect(createSelect());
        }
        return stmt.getSelect();
    }

    public SQLSelectStatement getSQLSelectStatement() {
        return stmt;
    }

    override
    public SQLBuilder select(string[] columns...) {
        SQLSelectQueryBlock queryBlock = getQueryBlock();

        foreach (string column ; columns) {
            SQLSelectItem selectItem = SQLUtils.toSelectItem(column, dbType);
            queryBlock.addSelectItem(selectItem);
        }

        return this;
    }

    override
    public SQLBuilder selectWithAlias(string column, string _alias) {
        SQLSelectQueryBlock queryBlock = getQueryBlock();

        SQLExpr columnExpr = SQLUtils.toSQLExpr(column, dbType);
        SQLSelectItem selectItem = new SQLSelectItem(columnExpr, _alias);
        queryBlock.addSelectItem(selectItem);

        return this;
    }

    override
    public SQLBuilder from(string table) {
        return from(table, null);
    }

    override
    public SQLBuilder from(string table, string _alias) {
        SQLSelectQueryBlock queryBlock = getQueryBlock();
        SQLExprTableSource from = new SQLExprTableSource(new SQLIdentifierExpr(table), _alias);
        queryBlock.setFrom(from);

        return this;
    }

    override
    public SQLBuilder orderBy(string[] columns...) {
        SQLSelect select = this.getSQLSelect();

        SQLOrderBy orderBy = select.getOrderBy();
        if (orderBy is null) {
            orderBy = createOrderBy();
            select.setOrderBy(orderBy);
        }

        foreach (string column ; columns) {
            SQLSelectOrderByItem orderByItem = SQLUtils.toOrderByItem(column, dbType);
            orderBy.addItem(orderByItem);
        }

        return this;
    }

    override
    public SQLBuilder groupBy(string expr) {
        SQLSelectQueryBlock queryBlock = getQueryBlock();

        SQLSelectGroupByClause groupBy = queryBlock.getGroupBy();
        if (groupBy is null) {
            groupBy = createGroupBy();
            queryBlock.setGroupBy(groupBy);
        }

        SQLExpr exprObj = SQLUtils.toSQLExpr(expr, dbType);
        groupBy.addItem(exprObj);

        return this;
    }

    override
    public SQLBuilder having(string expr) {
        SQLSelectQueryBlock queryBlock = getQueryBlock();

        SQLSelectGroupByClause groupBy = queryBlock.getGroupBy();
        if (groupBy is null) {
            groupBy = createGroupBy();
            queryBlock.setGroupBy(groupBy);
        }

        SQLExpr exprObj = SQLUtils.toSQLExpr(expr, dbType);
        groupBy.setHaving(exprObj);

        return this;
    }

    override
    public SQLBuilder into(string expr) {
        SQLSelectQueryBlock queryBlock = getQueryBlock();

        SQLExpr exprObj = SQLUtils.toSQLExpr(expr, dbType);
        queryBlock.setInto(exprObj);

        return this;
    }

    override
    public SQLBuilder where(string expr) {
        SQLSelectQueryBlock queryBlock = getQueryBlock();

        SQLExpr exprObj = SQLUtils.toSQLExpr(expr, dbType);
        queryBlock.setWhere(exprObj);

        return this;
    }

    override
    public SQLBuilder whereAnd(string expr) {
        SQLSelectQueryBlock queryBlock = getQueryBlock();
        queryBlock.addWhere(SQLUtils.toSQLExpr(expr, dbType));

        return this;
    }

    override
    public SQLBuilder whereOr(string expr) {
        SQLSelectQueryBlock queryBlock = getQueryBlock();

        SQLExpr exprObj = SQLUtils.toSQLExpr(expr, dbType);
        SQLExpr newCondition = SQLUtils.buildCondition(SQLBinaryOperator.BooleanOr, exprObj, false,
                                                       queryBlock.getWhere());
        queryBlock.setWhere(newCondition);

        return this;
    }

    override
    public SQLBuilder limit(int rowCount) {
        auto rowLimit = getQueryBlock().getLimit();
        if(rowLimit !is null)
            rowLimit.setRowCount(rowCount);
        else
        {
            getQueryBlock()
                .limit(rowCount, 0);
        }
        return this;
    }

    override
    public SQLBuilder offset(int off) {
        auto rowLimit = getQueryBlock().getLimit();
        if(rowLimit !is null)
            rowLimit.setOffset(off);
        else
        {
            getQueryBlock()
                .limit(1, off);
        }
        return this;
    }

    override
    public SQLBuilder limit(int rowCount, int offset) {
        getQueryBlock()
                .limit(rowCount, offset);
        return this;
    }

    override
    public SQLBuilder join(string table , string _alias = null , string cond = null)
    {
        return doJoin(SQLJoinTableSource.JoinType.JOIN,table,_alias,cond);
    }

    override
    public SQLBuilder innerJoin(string table , string _alias = null , string cond = null)
    {
        return doJoin(SQLJoinTableSource.JoinType.INNER_JOIN,table,_alias,cond);
    }

    override
    public SQLBuilder leftJoin(string table , string _alias = null , string cond = null)
    {
        return doJoin(SQLJoinTableSource.JoinType.LEFT_OUTER_JOIN,table,_alias,cond);
    }

    override
    public SQLBuilder rightJoin(string table , string _alias = null , string cond = null)
    {
        return doJoin(SQLJoinTableSource.JoinType.RIGHT_OUTER_JOIN,table,_alias,cond);
    }

    private SQLBuilder doJoin(SQLJoinTableSource.JoinType type , string table , string _alias = null , string cond = null)
    {
        SQLSelectQueryBlock queryBlock = getQueryBlock();
        auto  from = queryBlock.getFrom();
        if(from is null)
        {
            throw new Exception("No From Table");
        }
        else
        {
            auto rightTable = new SQLExprTableSource();
            rightTable.setExpr(table);
            rightTable.setAlias(_alias);
            if(cond is null)
                queryBlock.setFrom(new SQLJoinTableSource(from,type,rightTable));
            else
                queryBlock.setFrom(new SQLJoinTableSource(from,type,rightTable,SQLUtils.toSQLExpr(cond)));
        }

        return this;
    }


    protected SQLSelectQueryBlock getQueryBlock() {
        SQLSelect select = getSQLSelect();
        SQLSelectQuery query = select.getQuery();
        if (query is null) {
            query = createSelectQueryBlock();
            select.setQuery(query);
        }

        if (!(cast(SQLSelectQueryBlock)(query) !is null)) {
            throw new Exception("not support from, class : " ~ typeid(query).stringof);
        }

        SQLSelectQueryBlock queryBlock = cast(SQLSelectQueryBlock) query;
        return queryBlock;
    }

    protected SQLSelect createSelect() {
        return new SQLSelect();
    }

    protected SQLSelectQuery createSelectQueryBlock() {
        if (DBType.MYSQL.name == dbType) {
            return new MySqlSelectQueryBlock();
        }

        if (DBType.POSTGRESQL.name == dbType) {
            return new PGSelectQueryBlock();
        }

        // if (DBType.SQL_SERVER.name == dbType) {
        //     return new SQLServerSelectQueryBlock();
        // }

        // if (DBType.ORACLE.name == dbType) {
        //     return new OracleSelectQueryBlock();
        // }

        return new SQLSelectQueryBlock();
    }

    protected SQLOrderBy createOrderBy() {
        return new SQLOrderBy();
    }

    protected SQLSelectGroupByClause createGroupBy() {
        return new SQLSelectGroupByClause();
    }

    public void setDistinct()
    {
        getQueryBlock().setDistionOption(SQLSetQuantifier.DISTINCT);
        return;
    }

    override public string toString() {
        return SQLUtils.toSQLString(stmt, dbType);
    }
}
