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
module hunt.sql.dialect.mysql.ast.statement.MySqlAlterUserStatement;


import hunt.collection;
import hunt.sql.ast.SQLObject;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.statement.SQLAlterStatement;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;
import hunt.sql.dialect.mysql.ast.statement.MySqlStatementImpl;

public class MySqlAlterUserStatement : MySqlStatementImpl , SQLAlterStatement {

    alias accept0 = MySqlStatementImpl.accept0;
    
    private  List!(SQLExpr) users;

    this()
    {
        users = new ArrayList!(SQLExpr)();
    }
    
    override public void accept0(MySqlASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild!SQLExpr(visitor, users);
        }
        visitor.endVisit(this);
    }

    public List!(SQLExpr) getUsers() {
        return users;
    }

    public void addUser(SQLExpr user) {
        if (user !is null) {
            user.setParent(this);
        }
        this.users.add(user);
    }
}
