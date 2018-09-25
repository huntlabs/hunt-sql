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
module hunt.sql.ast.statement.SQLShowTablesStatement;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLStatementImpl;
import hunt.sql.visitor.SQLASTVisitor;

public class SQLShowTablesStatement : SQLStatementImpl {

    protected SQLName database;
    protected SQLExpr like;
    
    // for mysql
    protected bool full;
    protected SQLExpr where;

    public SQLName getDatabase() {
        return database;
    }

    public void setDatabase(SQLName database) {
        if (database !is null) {
            database.setParent(this);
        }

        this.database = database;
    }

    public SQLExpr getLike() {
        return like;
    }

    public void setLike(SQLExpr like) {
        if (like !is null) {
            like.setParent(this);
        }

        this.like = like;
    }
    
    public bool isFull() {
        return full;
    }

    public void setFull(bool full) {
        this.full = full;
    }

    public SQLExpr getWhere() {
        return where;
    }

    public void setWhere(SQLExpr where) {
        this.where = where;
    }
    
    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, database);
            acceptChild(visitor, like);
        }
    }
}
