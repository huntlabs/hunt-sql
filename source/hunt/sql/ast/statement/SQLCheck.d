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
module hunt.sql.ast.statement.SQLCheck;

import hunt.sql.ast.SQLExpr;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLConstraintImpl;
import hunt.sql.ast.statement.SQLTableElement;
import hunt.sql.ast.statement.SQLTableConstraint;

public class SQLCheck : SQLConstraintImpl , SQLTableElement, SQLTableConstraint {

    alias cloneTo = SQLConstraintImpl.cloneTo;
    
    private SQLExpr expr;

    public this(){

    }

    public this(SQLExpr expr){
        this.setExpr(expr);
    }

    public SQLExpr getExpr() {
        return expr;
    }

    public void setExpr(SQLExpr x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.expr = x;
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, this.getName());
            acceptChild(visitor, this.getExpr());
        }
        visitor.endVisit(this);
    }

    public void cloneTo(SQLCheck x) {
        super.cloneTo(x);

        if (expr !is null) {
            expr = expr.clone();
        }
    }

    override public SQLCheck clone() {
        SQLCheck x = new SQLCheck();
        cloneTo(x);
        return x;
    }
}
