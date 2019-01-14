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
module hunt.sql.dialect.mysql.ast.statement.MySqlPrepareStatement;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLObject;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;
import hunt.sql.dialect.mysql.ast.statement.MySqlStatementImpl;


import hunt.collection;

public class MySqlPrepareStatement : MySqlStatementImpl {

    alias accept0 = MySqlStatementImpl.accept0;
    
    private SQLName name;
    private SQLExpr from;

    public this(){
    }

    public this(SQLName name, SQLExpr from){
        this.name = name;
        this.from = from;
    }

    public SQLName getName() {
        return name;
    }

    public void setName(SQLName name) {
        this.name = name;
    }

    public SQLExpr getFrom() {
        return from;
    }

    public void setFrom(SQLExpr from) {
        this.from = from;
    }

    override public void accept0(MySqlASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, name);
            acceptChild(visitor, from);
        }
        visitor.endVisit(this);
    }

    override
    public List!(SQLObject) getChildren() {
        List!(SQLObject) children = new ArrayList!(SQLObject)();
        if (name !is null) {
            children.add(name);
        }
        if (this.from !is null) {
            children.add(from);
        }
        return children;
    }
}
