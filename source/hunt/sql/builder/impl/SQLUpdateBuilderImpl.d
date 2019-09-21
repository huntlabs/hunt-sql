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
module hunt.sql.builder.impl.SQLUpdateBuilderImpl;

import hunt.collection;

import hunt.sql.SQLUtils;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLStatement;
import hunt.sql.ast.expr.SQLBinaryOperator;
import hunt.sql.ast.expr.SQLIdentifierExpr;
import hunt.sql.ast.statement.SQLExprTableSource;
import hunt.sql.ast.statement.SQLUpdateSetItem;
import hunt.sql.ast.statement.SQLUpdateStatement;
import hunt.sql.builder.SQLUpdateBuilder;
import hunt.sql.dialect.mysql.ast.statement.MySqlUpdateStatement;
// import hunt.sql.dialect.oracle.ast.stmt.OracleUpdateStatement;
import hunt.sql.dialect.postgresql.ast.stmt.PGUpdateStatement;
// import hunt.sql.dialect.sqlserver.ast.stmt.SQLServerUpdateStatement;
import hunt.sql.util.DBType;
import hunt.sql.builder.impl.SQLBuilderImpl;
import hunt.sql.builder.SQLBuilder;
import hunt.sql.ast.expr.SQLBooleanExpr;
import hunt.sql.ast.expr.SQLCharExpr;
import hunt.sql.ast.expr.SQLIntegerExpr;
import hunt.sql.ast.expr.SQLNullExpr;
import hunt.sql.ast.expr.SQLNumberExpr;

import hunt.Double;
import hunt.Exceptions;
import hunt.Float;
import hunt.Boolean;
import hunt.Integer;
import hunt.Long;
import hunt.Number;
import hunt.String;
import hunt.logging;
import hunt.Nullable;

import std.variant;

public class SQLUpdateBuilderImpl :  SQLUpdateBuilder {

    private SQLUpdateStatement stmt;
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

        SQLUpdateStatement stmt = cast(SQLUpdateStatement) stmtList.get(0);
        this.stmt = stmt;
        this.dbType = dbType;
    }

    public static SQLExpr toSQLExpr(Variant obj, string dbType) {
        // logDebug("set : ",obj.toString);
        if (!obj.hasValue() || obj == null) {
            return new SQLNullExpr();
        }

        TypeInfo typeInfo = obj.type;
        
        if (typeInfo == typeid(int)) {
            return new SQLIntegerExpr(obj.get!int());
        }

        if (typeInfo == typeid(uint)) {
            return new SQLIntegerExpr(cast(int)obj.get!uint());
        }
        
        if (typeInfo == typeid(short)) {
            return new SQLIntegerExpr(cast(int)obj.get!short());
        }
        
        if (typeInfo == typeid(ushort)) {
            return new SQLIntegerExpr(cast(int)obj.get!ushort());
        }
        
        if (typeInfo == typeid(long)) {
            return new SQLIntegerExpr(cast(int)obj.get!long());
        }
        
        if (typeInfo == typeid(ulong)) {
            return new SQLIntegerExpr(cast(int)obj.get!ulong());
        }
        
        if (typeInfo == typeid(double)) {
            Double db = new Double(obj.get!double());
            return new SQLNumberExpr(db);
        }
        
        if (typeInfo == typeid(float)) {
            Float db = new Float(obj.get!float());
            return new SQLNumberExpr(db);
        }

        if (typeInfo == typeid(bool)) {
            return new SQLBooleanExpr(obj.get!bool());
        }

        if (typeInfo == typeid(string)) {
            return new SQLCharExpr(obj.get!string());
        }


        // if (cast(Integer)(obj) !is null) {
        //     return new SQLIntegerExpr(cast(Integer) obj);
        // }

        // if (cast(Long)(obj) !is null) {
        //     return new SQLIntegerExpr(cast(int)(cast(Long) obj).longValue);
        // }

        // if (cast(Float)(obj) !is null) {
        //     return new SQLNumberExpr(cast(Float)obj);
        // }

        // if (cast(Double)(obj) !is null) {
        //     Number nm = cast(Number)obj;
        //     return new SQLNumberExpr(nm);
        // }
        
        // if (cast(Number)(obj) !is null) {
        //     return new SQLNumberExpr(cast(Number) obj);
        // }
        
        // if (cast(String)(obj) !is null) {
        //     return new SQLCharExpr(cast(String) obj);
        // }
        
        // if (cast(Boolean)(obj) !is null) {
        //     return new SQLBooleanExpr((cast(Boolean) obj).booleanValue);
        // }

        throw new IllegalArgumentException("unsupported : " ~ obj.type.toString());
    }

    public this(SQLUpdateStatement stmt, string dbType){
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
        SQLUpdateStatement update = getSQLUpdateStatement();
        SQLExprTableSource from = new SQLExprTableSource(new SQLIdentifierExpr(table), _alias);
        update.setTableSource(from);
        return this;
    }

    override
    public SQLBuilder where(string expr) {
        SQLUpdateStatement update = getSQLUpdateStatement();

        SQLExpr exprObj = SQLUtils.toSQLExpr(expr, dbType);
        update.setWhere(exprObj);

        return this;
    }

    override
    public SQLBuilder whereAnd(string expr) {
        SQLUpdateStatement update = getSQLUpdateStatement();

        SQLExpr exprObj = SQLUtils.toSQLExpr(expr, dbType);
        SQLExpr newCondition = SQLUtils.buildCondition(SQLBinaryOperator.BooleanAnd, exprObj, false, update.getWhere());
        update.setWhere(newCondition);

        return this;
    }

    override
    public SQLBuilder whereOr(string expr) {
        SQLUpdateStatement update = getSQLUpdateStatement();

        SQLExpr exprObj = SQLUtils.toSQLExpr(expr, dbType);
        SQLExpr newCondition = SQLUtils.buildCondition(SQLBinaryOperator.BooleanOr, exprObj, false, update.getWhere());
        update.setWhere(newCondition);

        return this;
    }

    override
    public SQLUpdateBuilder set(string[] items...) {
        SQLUpdateStatement update = getSQLUpdateStatement();
        foreach (string item ; items) {
            SQLUpdateSetItem updateSetItem = SQLUtils.toUpdateSetItem(item, dbType);
            update.addItem(updateSetItem);
        }
        
        return this;
    }
    
    public SQLUpdateBuilderImpl setValue(Map!(string, Variant) values) {
        foreach (string k, Variant v ; values) {
            setValue(k, v);
        }
        
        return this;
    }
    
    public SQLUpdateBuilderImpl setValue(string column, Variant value) {
        SQLUpdateStatement update = getSQLUpdateStatement();
        
        SQLExpr columnExpr = SQLUtils.toSQLExpr(column, dbType);
        SQLExpr valueExpr = toSQLExpr(value, dbType);
        
        SQLUpdateSetItem item = new SQLUpdateSetItem();
        item.setColumn(columnExpr);
        item.setValue(valueExpr);
        update.addItem(item);
        
        return this;
    }

    public SQLUpdateStatement getSQLUpdateStatement() {
        if (stmt is null) {
            stmt = createSQLUpdateStatement();
        }
        return stmt;
    }

    public SQLUpdateStatement createSQLUpdateStatement() {
        if (DBType.MYSQL.name == dbType) {
            return new MySqlUpdateStatement();    
        }
        
        // if (DBType.ORACLE.name == dbType) {
        //     return new OracleUpdateStatement();    
        // }
        
        if (DBType.POSTGRESQL.name == dbType) {
            return new PGUpdateStatement();    
        }
        
        // if (DBType.SQL_SERVER.name == dbType) {
        //     return new SQLServerUpdateStatement();    
        // }
        
        return new SQLUpdateStatement();
    }
    
    override public string toString() {
        return SQLUtils.toSQLString(stmt, dbType);
    }
}
