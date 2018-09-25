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
module hunt.sql.ast.expr.SQLArrayExpr;



import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLExprImpl;
import hunt.sql.ast.SQLObject;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.container;

public class SQLArrayExpr : SQLExprImpl {

    private SQLExpr       expr;

    private List!SQLExpr values;

    this()
    {
        values = new ArrayList!SQLExpr();
    }

    override public SQLArrayExpr clone() {
        SQLArrayExpr x = new SQLArrayExpr();
        if (expr !is null) {
            x.setExpr(expr.clone());
        }
        foreach (SQLExpr value ; values) {
            SQLExpr value2 = value.clone();
            value2.setParent(x);
            x.values.add(value2);
        }
        return x;
    }

    public SQLExpr getExpr() {
        return expr;
    }

    public void setExpr(SQLExpr expr) {
        this.expr = expr;
    }

    public List!SQLExpr getValues() {
        return values;
    }

    public void setValues(List!SQLExpr values) {
        this.values = values;
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, expr);
            acceptChild!SQLExpr(visitor, values);
        }
        visitor.endVisit(this);
    }

    override public List!SQLObject getChildren() {
        List!SQLObject children = new ArrayList!SQLObject();
        children.add(this.expr);
        children.addAll(cast(List!SQLObject)(this.values));
        return children;
    }

   override
    public size_t toHash() @trusted nothrow {
         int prime = 31;
        size_t result = 1;
        result = prime * result + ((expr is null) ? 0 : (cast(Object)expr).toHash());
        result = prime * result + ((values is null) ? 0 : (cast(Object)values).toHash());
        return result;
    }

   override
    public bool opEquals(Object obj) {
        if (this is obj) return true;
        if (obj is null) return false;
        if (typeid(this) != typeid(obj)) return false;
        SQLArrayExpr other = cast(SQLArrayExpr) obj;
        if (expr is null) {
            if (other.expr !is null) return false;
        } else if (!(cast(Object)expr).opEquals(cast(Object)(other.expr))) return false;
        if (values is null) {
            if (other.values !is null) return false;
        } else if (!(cast(Object)values).opEquals(cast(Object)(other.values))) return false;
        return true;
    }



}
