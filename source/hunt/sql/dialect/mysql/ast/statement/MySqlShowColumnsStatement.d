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
module hunt.sql.dialect.mysql.ast.statement.MySqlShowColumnsStatement;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLObject;
import hunt.sql.ast.expr.SQLIdentifierExpr;
import hunt.sql.ast.expr.SQLPropertyExpr;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;
import hunt.sql.dialect.mysql.ast.statement.MySqlShowStatement;

import hunt.sql.dialect.mysql.ast.statement.MySqlStatementImpl;

import hunt.container;

public class MySqlShowColumnsStatement : MySqlStatementImpl , MySqlShowStatement {

    alias accept0 = MySqlStatementImpl.accept0;
    
    private bool full;

    private SQLName table;
    private SQLName database;
    private SQLExpr like;
    private SQLExpr where;

    public bool isFull() {
        return full;
    }

    public void setFull(bool full) {
        this.full = full;
    }

    public SQLName getTable() {
        return table;
    }

    public void setTable(SQLName table) {
        if (cast(SQLPropertyExpr)(table) !is null) {
            SQLPropertyExpr propExpr = cast(SQLPropertyExpr) table;
            this.setDatabase(cast(SQLName) propExpr.getOwner());
            this.table = new SQLIdentifierExpr(propExpr.getName());
            return;
        }
        this.table = table;
    }

    public SQLName getDatabase() {
        return database;
    }

    public void setDatabase(SQLName database) {
        this.database = database;
    }

    public SQLExpr getLike() {
        return like;
    }

    public void setLike(SQLExpr like) {
        this.like = like;
    }

    public SQLExpr getWhere() {
        return where;
    }

    public void setWhere(SQLExpr where) {
        this.where = where;
    }

    override public void accept0(MySqlASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, table);
            acceptChild(visitor, database);
            acceptChild(visitor, like);
            acceptChild(visitor, where);
        }
        visitor.endVisit(this);
    }

    override public List!(SQLObject) getChildren() {
        List!(SQLObject) children = new ArrayList!(SQLObject)();
        if (table !is null) {
            children.add(table);
        }
        if (database !is null) {
            children.add(database);
        }
        if (like !is null) {
            children.add(like);
        }
        if (where !is null) {
            children.add(where);
        }
        return children;
    }
}
