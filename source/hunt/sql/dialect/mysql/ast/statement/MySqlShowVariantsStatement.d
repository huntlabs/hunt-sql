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
module hunt.sql.dialect.mysql.ast.statement.MySqlShowVariantsStatement;

import hunt.sql.ast.SQLExpr;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;
import hunt.sql.dialect.mysql.ast.statement.MySqlStatementImpl;
import hunt.sql.dialect.mysql.ast.statement.MySqlShowStatement;

public class MySqlShowVariantsStatement : MySqlStatementImpl , MySqlShowStatement {
    alias accept0 = MySqlStatementImpl.accept0;
    private bool global  = false;
    private bool session = false;

    private SQLExpr like;
    private SQLExpr where;

    public bool isGlobal() {
        return global;
    }

    public void setGlobal(bool global) {
        this.global = global;
    }

    public bool isSession() {
        return session;
    }

    public void setSession(bool session) {
        this.session = session;
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
            acceptChild(visitor, like);
            acceptChild(visitor, where);
        }
        visitor.endVisit(this);
    }
}
