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
module hunt.sql.ast.statement.SQLRollbackStatement;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLObject;
import hunt.sql.ast.SQLStatementImpl;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.math;

import hunt.container;

public class SQLRollbackStatement : SQLStatementImpl {

    private SQLName to;

    // for mysql
    private Boolean chain;
    private Boolean release;
    private SQLExpr force;
    
    public this() {
        
    }
    
    public this(string dbType) {
        super (dbType);
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, to);

            acceptChild(visitor, force);
        }
        visitor.endVisit(this);
    }

    override
    public List!SQLObject getChildren() {
        List!SQLObject children = new ArrayList!SQLObject();
        if (to !is null) {
            children.add(to);
        }
        if (force !is null) {
            children.add(force);
        }
        return children;
    }

    public SQLName getTo() {
        return to;
    }

    public void setTo(SQLName to) {
        this.to = to;
    }

    public Boolean getChain() {
        return chain;
    }

    public void setChain(Boolean chain) {
        this.chain = chain;
    }

    public Boolean getRelease() {
        return release;
    }

    public void setRelease(Boolean release) {
        this.release = release;
    }

    public SQLExpr getForce() {
        return force;
    }

    public void setForce(SQLExpr force) {
        this.force = force;
    }

}
