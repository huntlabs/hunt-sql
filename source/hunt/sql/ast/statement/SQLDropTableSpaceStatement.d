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
module hunt.sql.ast.statement.SQLDropTableSpaceStatement;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLStatementImpl;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLDropStatement;

public class SQLDropTableSpaceStatement : SQLStatementImpl , SQLDropStatement {

    private SQLName name;
    private bool ifExists;
    private SQLExpr engine;
    
    public this() {
        
    }
    
    public this(string dbType) {
        super (dbType);
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, name);
        }
        visitor.endVisit(this);
    }

    public SQLName getName() {
        return name;
    }

    public void setName(SQLName x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.name = x;
    }

    public SQLExpr getEngine() {
        return engine;
    }

    public void setEngine(SQLExpr x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.engine = x;
    }

    public bool isIfExists() {
        return ifExists;
    }

    public void setIfExists(bool ifExists) {
        this.ifExists = ifExists;
    }

}
