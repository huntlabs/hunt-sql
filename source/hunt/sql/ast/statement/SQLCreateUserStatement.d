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
module hunt.sql.ast.statement.SQLCreateUserStatement;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLStatementImpl;
import hunt.sql.visitor.SQLASTVisitor;

public class SQLCreateUserStatement : SQLStatementImpl {
    private SQLName user;
    private SQLExpr password;

    // oracle
    private SQLName defaultTableSpace;

    public this() {

    }

    public SQLName getUser() {
        return user;
    }

    public void setUser(SQLName user) {
        if (user !is null) {
            user.setParent(this);
        }
        this.user = user;
    }

    public SQLExpr getPassword() {
        return password;
    }

    public void setPassword(SQLExpr password) {
        if (password !is null) {
            password.setParent(this);
        }
        this.password = password;
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, user);
            acceptChild(visitor, password);
        }
        visitor.endVisit(this);
    }
}
