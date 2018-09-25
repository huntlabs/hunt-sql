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
module hunt.sql.ast.statement.SQLRevokeStatement;


import hunt.container;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLObject;
import hunt.sql.ast.SQLStatementImpl;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.ast.statement.SQLObjectType;

public class SQLRevokeStatement : SQLStatementImpl {

    private  List!SQLExpr privileges;

    private SQLObject           on;
    private SQLExpr             from;
    // mysql
    private SQLObjectType       objectType;

    public this(){
        privileges = new ArrayList!SQLExpr();
    }

    public this(string dbType){
        privileges = new ArrayList!SQLExpr();
        super(dbType);
    }

    public SQLObject getOn() {
        return on;
    }

    public void setOn(SQLObject on) {
        this.on = on;
    }

    public SQLExpr getFrom() {
        return from;
    }

    public void setFrom(SQLExpr from) {
        this.from = from;
    }

    public List!SQLExpr getPrivileges() {
        return privileges;
    }

    public SQLObjectType getObjectType() {
        return objectType;
    }

    public void setObjectType(SQLObjectType objectType) {
        this.objectType = objectType;
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, on);
            acceptChild(visitor, from);
        }
        visitor.endVisit(this);
    }
}
