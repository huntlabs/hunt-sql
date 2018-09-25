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
module hunt.sql.dialect.mysql.ast.statement.MySqlExplainStatement;

import hunt.sql.SQLUtils;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.statement.SQLExplainStatement;
import hunt.sql.dialect.mysql.ast.clause.MySqlExplainType;
import hunt.sql.dialect.mysql.ast.clause.MySqlFormatName;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.util.DBType;
import hunt.sql.dialect.mysql.ast.statement.MySqlStatement;

public class MySqlExplainStatement : SQLExplainStatement , MySqlStatement {
    private bool describe;
    private SQLName tableName;
    private SQLName columnName;
    private SQLExpr wild;
    private string  format;
    private SQLExpr connectionId;

    public this() {
        super (DBType.MYSQL.name);
    }

       public this(string dbType) {
        super (dbType);
    }


    override
    public void accept0(MySqlASTVisitor visitor) {
        if (visitor.visit(this)) {
            // tbl_name [col_name | wild]
            if (tableName !is null) {
                acceptChild(visitor, tableName);
                if (columnName !is null) {
                    acceptChild(visitor, columnName);
                } else if (wild !is null) {
                    acceptChild(visitor, wild);
                }
            } else {
                // {explainable_stmt | FOR CONNECTION connection_id}
                if (connectionId !is null) {
                    acceptChild(visitor, connectionId);
                } else {
                    acceptChild(visitor, statement);
                }
            }
        }

        visitor.endVisit(this);
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        accept0(cast(MySqlASTVisitor) visitor);
    }

    override public string toString() {
        return SQLUtils.toMySqlString(this);
    }

    public bool isDescribe() {
        return describe;
    }

    public void setDescribe(bool describe) {
        this.describe = describe;
    }

    public SQLName getTableName() {
        return tableName;
    }

    public void setTableName(SQLName tableName) {
        this.tableName = tableName;
    }

    public SQLName getColumnName() {
        return columnName;
    }

    public void setColumnName(SQLName columnName) {
        this.columnName = columnName;
    }

    public SQLExpr getWild() {
        return wild;
    }

    public void setWild(SQLExpr wild) {
        this.wild = wild;
    }

    public string getFormat() {
        return format;
    }

    public void setFormat(string format) {
        this.format = format;
    }

    public SQLExpr getConnectionId() {
        return connectionId;
    }

    public void setConnectionId(SQLExpr connectionId) {
        this.connectionId = connectionId;
    }

}
