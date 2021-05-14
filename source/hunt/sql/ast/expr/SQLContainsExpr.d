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
module hunt.sql.ast.expr.SQLContainsExpr;

import hunt.sql.ast;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.collection;
import hunt.sql.ast.expr.SQLBooleanExpr;


public  class SQLContainsExpr : SQLExprImpl , SQLReplaceable//, Serializable 
{
    private bool not = false;
    private SQLExpr expr;
    private List!SQLExpr targetList;

    public this() {
        targetList = new ArrayList!SQLExpr();
    }

    public this(SQLExpr expr) {
        this();
        this.setExpr(expr);
    }

    public this(SQLExpr expr, bool not) {
        this();
        this.setExpr(expr);
        this.not = not;
    }

    override public SQLContainsExpr clone() {
        SQLContainsExpr x = new SQLContainsExpr();
        x.not = not;
        if (expr !is null) {
            x.setExpr(expr.clone());
        }
        foreach (SQLExpr e ; targetList) {
            SQLExpr e2 = e.clone();
            e2.setParent(x);
            x.targetList.add(e2);
        }
        return x;
    }

    public bool isNot() {
        return this.not;
    }

    public void setNot(bool not) {
        this.not = not;
    }

    public SQLExpr getExpr() {
        return this.expr;
    }

    public void setExpr(SQLExpr expr) {
        if (expr !is null) {
            expr.setParent(this);
        }

        this.expr = expr;
    }

    public List!SQLExpr getTargetList() {
        return this.targetList;
    }

    public void setTargetList(List!SQLExpr targetList) {
        this.targetList = targetList;
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, this.expr);
            acceptChild!SQLExpr(visitor, this.targetList);
        }

        visitor.endVisit(this);
    }

    override public List!SQLObject getChildren() {
        List!SQLObject children = new ArrayList!SQLObject();
        if (this.expr !is null) {
            children.add(this.expr);
        }
        children.addAll(cast(List!SQLObject)(this.targetList));
        return children;
    }

   override
    public size_t toHash() @trusted nothrow {
         int prime = 31;
        size_t result = 1;
        result = prime * result + ((expr is null) ? 0 : (cast(Object)expr).toHash());
        result = prime * result + (not ? 1231 : 1237);
        result = prime * result + ((targetList is null) ? 0 : (cast(Object)targetList).toHash());
        return result;
    }

   override
    public bool opEquals(Object obj) {
        if (this is obj) {
            return true;
        }
        if (obj is null) {
            return false;
        }
        if (typeid(this) != typeid(obj)) {
            return false;
        }
        SQLContainsExpr other = cast(SQLContainsExpr) obj;
        if (expr is null) {
            if (other.expr !is null) {
                return false;
            }
        } else if (!(cast(Object)(expr)).opEquals(cast(Object)(other.expr))) {
            return false;
        }
        if (not != other.not) {
            return false;
        }
        if (targetList is null) {
            if (other.targetList !is null) {
                return false;
            }
        } else if (!(cast(Object)(targetList)).opEquals(cast(Object)(other.targetList))) {
            return false;
        }
        return true;
    }

    override public SQLDataType computeDataType() {
        return SQLBooleanExpr.DEFAULT_DATA_TYPE;
    }

   override
    public bool replace(SQLExpr expr, SQLExpr target) {
        if (this.expr == expr) {
            setExpr(target);
            return true;
        }

        for (int i = 0; i < targetList.size(); i++) {
            if (targetList.get(i) == expr) {
                targetList.set(i, target);
                target.setParent(this);
                return true;
            }
        }

        return false;
    }
}
