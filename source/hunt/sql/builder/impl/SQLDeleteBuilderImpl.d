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
module hunt.sql.builder.impl.SQLDeleteBuilderImpl;

import hunt.container;

import hunt.sql.SQLUtils;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLStatement;
import hunt.sql.ast.expr.SQLBinaryOperator;
import hunt.sql.ast.expr.SQLIdentifierExpr;
import hunt.sql.ast.statement.SQLDeleteStatement;
import hunt.sql.ast.statement.SQLExprTableSource;
import hunt.sql.builder.SQLDeleteBuilder;
import hunt.sql.dialect.mysql.ast.statement.MySqlDeleteStatement;
// import hunt.sql.dialect.oracle.ast.stmt.OracleDeleteStatement;
import hunt.sql.dialect.postgresql.ast.stmt.PGDeleteStatement;
import hunt.sql.util.DBType;
import hunt.sql.builder.SQLBuilder;

public class SQLDeleteBuilderImpl : SQLDeleteBuilder {

    private SQLDeleteStatement stmt;
    private string             dbType;

    public this(string dbType){
        this.dbType = dbType;
    }
    
    public this(string sql, string dbType){
        List!SQLStatement stmtList = SQLUtils.parseStatements(sql, dbType);

        if (stmtList.size() == 0) {
            throw new Exception("not support empty-statement :" ~ sql);
        }

        if (stmtList.size() > 1) {
            throw new Exception("not support multi-statement :" ~ sql);
        }

        SQLDeleteStatement stmt = cast(SQLDeleteStatement) stmtList.get(0);
        this.stmt = stmt;
        this.dbType = dbType;
    }

    public this(SQLDeleteStatement stmt, string dbType){
        this.stmt = stmt;
        this.dbType = dbType;
    }

    override
    public SQLBuilder limit(int rowCount) {
        throw new Exception("not implement");
    }

    override
    public SQLBuilder limit(int rowCount, int offset) {
        throw new Exception("not implement");
    }

    override
    public SQLBuilder from(string table) {
        return from(table, null);
    }

    override
    public SQLBuilder from(string table, string _alias) {
        SQLDeleteStatement _delete = getSQLDeleteStatement();
        SQLExprTableSource from = new SQLExprTableSource(new SQLIdentifierExpr(table), _alias);
        _delete.setTableSource(from);
        return this;
    }

    override
    public SQLBuilder where(string expr) {
        SQLDeleteStatement _delete = getSQLDeleteStatement();

        SQLExpr exprObj = SQLUtils.toSQLExpr(expr, dbType);
        _delete.setWhere(exprObj);

        return this;
    }

    override
    public SQLBuilder whereAnd(string expr) {
        SQLDeleteStatement _delete = getSQLDeleteStatement();

        SQLExpr exprObj = SQLUtils.toSQLExpr(expr, dbType);
        SQLExpr newCondition = SQLUtils.buildCondition(SQLBinaryOperator.BooleanAnd, exprObj, false, _delete.getWhere());
        _delete.setWhere(newCondition);

        return this;
    }

    override
    public SQLBuilder whereOr(string expr) {
        SQLDeleteStatement _delete = getSQLDeleteStatement();

        SQLExpr exprObj = SQLUtils.toSQLExpr(expr, dbType);
        SQLExpr newCondition = SQLUtils.buildCondition(SQLBinaryOperator.BooleanOr, exprObj, false, _delete.getWhere());
        _delete.setWhere(newCondition);

        return this;
    }

    public SQLDeleteStatement getSQLDeleteStatement() {
        if (stmt is null) {
            stmt = createSQLDeleteStatement();
        }
        return stmt;
    }

    public SQLDeleteStatement createSQLDeleteStatement() {
        // if (DBType.ORACLE.name == dbType) {
        //     return new OracleDeleteStatement();    
        // }
        
        if (DBType.MYSQL.name == dbType) {
            return new MySqlDeleteStatement();    
        }
        
        if (DBType.POSTGRESQL.name == dbType) {
            return new PGDeleteStatement();    
        }
        
        return new SQLDeleteStatement();
    }

    override public string toString() {
        return SQLUtils.toSQLString(stmt, dbType);
    }
}