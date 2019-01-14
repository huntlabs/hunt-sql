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
module hunt.sql.dialect.mysql.ast.statement.MySqlCreateUserStatement;


import hunt.collection;
import hunt.sql.ast.SQLObject;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.statement.SQLCreateStatement;
import hunt.sql.dialect.mysql.ast.MySqlObjectImpl;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;
import hunt.sql.dialect.mysql.ast.statement.MySqlStatementImpl;

public class MySqlCreateUserStatement : MySqlStatementImpl , SQLCreateStatement {

    alias accept0 = MySqlStatementImpl.accept0;

    private List!(UserSpecification) users;

    this(){
        users = new ArrayList!(UserSpecification)(2);
    }

    public List!(UserSpecification) getUsers() {
        return users;
    }

    public void addUser(UserSpecification user) {
        if (user !is null) {
            user.setParent(this);
        }
        this.users.add(user);
    }

    override
    public void accept0(MySqlASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild!(MySqlCreateUserStatement.UserSpecification)(visitor, users);
        }
        visitor.endVisit(this);
    }

    public static class UserSpecification : MySqlObjectImpl {

        alias accept0 = MySqlObjectImpl.accept0;

        private SQLExpr user;
        private bool passwordHash = false;
        private SQLExpr password;
        private SQLExpr authPlugin;

        public SQLExpr getUser() {
            return user;
        }

        public void setUser(SQLExpr user) {
            this.user = user;
        }

        public bool isPasswordHash() {
            return passwordHash;
        }

        public void setPasswordHash(bool passwordHash) {
            this.passwordHash = passwordHash;
        }

        public SQLExpr getPassword() {
            return password;
        }

        public void setPassword(SQLExpr password) {
            this.password = password;
        }

        public SQLExpr getAuthPlugin() {
            return authPlugin;
        }

        public void setAuthPlugin(SQLExpr authPlugin) {
            this.authPlugin = authPlugin;
        }

        override
        public void accept0(MySqlASTVisitor visitor) {
            if (visitor.visit(this)) {
                acceptChild(visitor, user);
                acceptChild(visitor, password);
                acceptChild(visitor, authPlugin);
            }
            visitor.endVisit(this);
        }

    }
}
