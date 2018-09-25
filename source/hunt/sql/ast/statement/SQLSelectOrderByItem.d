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
module hunt.sql.ast.statement.SQLSelectOrderByItem;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.ast.SQLOrderingSpecification;
import hunt.sql.ast.SQLReplaceable;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLSelectItem;

public  class SQLSelectOrderByItem : SQLObjectImpl , SQLReplaceable {

    protected SQLExpr                  expr;
    protected string                   collate;
    protected SQLOrderingSpecification type;
    protected NullsOrderType           nullsOrderType;

    protected SQLSelectItem  resolvedSelectItem;

    public this(){

    }

    public this(SQLExpr expr){
        this.setExpr(expr);
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

    public string getCollate() {
        return collate;
    }

    public void setCollate(string collate) {
        this.collate = collate;
    }

    public SQLOrderingSpecification getType() {
        return this.type;
    }

    public void setType(SQLOrderingSpecification type) {
        this.type = type;
    }
    
    public NullsOrderType getNullsOrderType() {
        return this.nullsOrderType;
    }

    public void setNullsOrderType(NullsOrderType nullsOrderType) {
        this.nullsOrderType = nullsOrderType;
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, this.expr);
        }

        visitor.endVisit(this);
    }

    override
    public size_t toHash() @trusted nothrow {
         int prime = 31;
        size_t result = 1;
        result = prime * result + hashOf(collate);
        result = prime * result + ((expr is null) ? 0 : (cast(Object)expr).toHash());
        result = prime * result + hashOf(type);
        return result;
    }

    override
    public bool opEquals(Object obj) {
        if (this == obj) return true;
        if (obj is null) return false;
        if (typeid(this) != typeid(obj)) return false;
        SQLSelectOrderByItem other = cast(SQLSelectOrderByItem) obj;
        if (collate is null) {
            if (other.collate !is null) return false;
        } else if (!(collate == other.collate)) return false;
        if (expr is null) {
            if (other.expr !is null) return false;
        } else if (!(cast(Object)(expr)).opEquals(cast(Object)(other.expr))) return false;
        if (type != other.type) return false;
        return true;
    }

    override
    public bool replace(SQLExpr expr, SQLExpr target) {
        if (this.expr == expr) {
            this.setExpr(target);
            return true;
        }
        return false;
    }

    public static struct NullsOrderType {
        enum NullsOrderType NullsFirst = NullsOrderType("NULLS FIRST");
        enum NullsOrderType NullsLast = NullsOrderType("NULLS LAST");

        private string _name;
        this(string name)
        {
            _name = name;
        }

        @property string name()
        {
            return _name;
        }

        public string toFormalString() {
            return _name;
        }
    }

    override public SQLSelectOrderByItem clone() {
        SQLSelectOrderByItem x = new SQLSelectOrderByItem();
        if (expr !is null) {
            x.setExpr(expr.clone());
        }
        x.collate = collate;
        x.type = type;
        x.nullsOrderType = nullsOrderType;
        return x;
    }

    public SQLSelectItem getResolvedSelectItem() {
        return resolvedSelectItem;
    }

    public void setResolvedSelectItem(SQLSelectItem resolvedSelectItem) {
        this.resolvedSelectItem = resolvedSelectItem;
    }
}
