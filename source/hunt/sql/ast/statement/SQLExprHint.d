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
module hunt.sql.ast.statement.SQLExprHint;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLHint;
import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.visitor.SQLASTVisitor;

public class SQLExprHint : SQLObjectImpl , SQLHint {

    private SQLExpr expr;

    public this(){

    }

    public this(SQLExpr expr){
        this.setExpr(expr);
    }

    public SQLExpr getExpr() {
        return expr;
    }

    public void setExpr(SQLExpr expr) {
        if (expr !is null) {
            expr.setParent(this);
        }

        this.expr = expr;
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, expr);
        }
        visitor.endVisit(this);
    }

    override public SQLExprHint clone() {
        SQLExprHint x = new SQLExprHint();
        if (expr !is null) {
            x.setExpr(expr.clone());
        }
        return x;
    }
}
