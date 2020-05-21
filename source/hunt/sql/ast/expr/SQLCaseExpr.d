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
module hunt.sql.ast.expr.SQLCaseExpr;


import hunt.sql.SQLUtils;
import hunt.sql.ast;
import hunt.sql.visitor.SQLASTOutputVisitor;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.collection;
import hunt.util.StringBuilder;

public class SQLCaseExpr : SQLExprImpl , SQLReplaceable//, Serializable 
{

    private static  long serialVersionUID = 1L;
    private  List!Item  items;
    private SQLExpr           valueExpr;
    private SQLExpr           elseExpr;

    public this(){
        items            = new ArrayList!Item();
    }

    public SQLExpr getValueExpr() {
        return this.valueExpr;
    }

    public void setValueExpr(SQLExpr valueExpr) {
        if (valueExpr !is null) {
            valueExpr.setParent(this);
        }
        this.valueExpr = valueExpr;
    }

    public SQLExpr getElseExpr() {
        return this.elseExpr;
    }

    public void setElseExpr(SQLExpr elseExpr) {
        if (elseExpr !is null) {
            elseExpr.setParent(this);
        }
        this.elseExpr = elseExpr;
    }

    public List!Item getItems() {
        return this.items;
    }

    public void addItem(Item item) {
        if (item !is null) {
            item.setParent(this);
            this.items.add(item);
        }
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, this.valueExpr);
            acceptChild!(SQLCaseExpr.Item)(visitor, this.items);
            acceptChild(visitor, this.elseExpr);
        }
        visitor.endVisit(this);
    }

   override
    public List!SQLObject getChildren() {
        List!SQLObject children = new ArrayList!SQLObject();
        if (valueExpr !is null) {
            children.add(this.valueExpr);
        }
        children.addAll(cast(List!SQLObject)(this.items));
        if (elseExpr !is null) {
            children.add(this.elseExpr);
        }
        return children;
    }

   override
    public bool replace(SQLExpr expr, SQLExpr target) {
        if (valueExpr == expr) {
            setValueExpr(target);
            return true;
        }

        if (elseExpr == expr) {
            setElseExpr(target);
            return true;
        }

        return false;
    }

    public static class Item : SQLObjectImpl , SQLReplaceable//, Serializable 
    {

        private static  long serialVersionUID = 1L;
        private SQLExpr           conditionExpr;
        private SQLExpr           valueExpr;

        public this(){

        }

        public this(SQLExpr conditionExpr, SQLExpr valueExpr){

            setConditionExpr(conditionExpr);
            setValueExpr(valueExpr);
        }

        public SQLExpr getConditionExpr() {
            return this.conditionExpr;
        }

        public void setConditionExpr(SQLExpr conditionExpr) {
            if (conditionExpr !is null) {
                conditionExpr.setParent(this);
            }
            this.conditionExpr = conditionExpr;
        }

        public SQLExpr getValueExpr() {
            return this.valueExpr;
        }

        public void setValueExpr(SQLExpr valueExpr) {
            if (valueExpr !is null) {
                valueExpr.setParent(this);
            }
            this.valueExpr = valueExpr;
        }

        override  protected void accept0(SQLASTVisitor visitor) {
            if (visitor.visit(this)) {
                acceptChild(visitor, this.conditionExpr);
                acceptChild(visitor, this.valueExpr);
            }
            visitor.endVisit(this);
        }

       override
        public size_t toHash() @trusted nothrow {
             int prime = 31;
            size_t result = 1;
            result = prime * result + ((conditionExpr is null) ? 0 : (cast(Object)conditionExpr).toHash());
            result = prime * result + ((valueExpr is null) ? 0 : (cast(Object)valueExpr).toHash());
            return result;
        }

       override
        public bool opEquals(Object obj) {
            if (this is obj) return true;
            if (obj is null) return false;
            if (typeid(this) != typeid(obj)) return false;
            Item other = cast(Item) obj;
            if (conditionExpr is null) {
                if (other.conditionExpr !is null) return false;
            } else if (!(cast(Object)(conditionExpr)).opEquals(cast(Object)(other.conditionExpr))) return false;
            if (valueExpr is null) {
                if (other.valueExpr !is null) return false;
            } else if (!(cast(Object)(valueExpr)).opEquals(cast(Object)(other.valueExpr))) return false;
            return true;
        }


        override public Item clone() {
            Item x = new Item();
            if (conditionExpr !is null) {
                x.setConditionExpr(conditionExpr.clone());
            }
            if (valueExpr !is null) {
                x.setValueExpr(valueExpr.clone());
            }
            return x;
        }

        override public void output(StringBuilder buf) {
            new SQLASTOutputVisitor(buf).visit(this);
        }

       override
        public bool replace(SQLExpr expr, SQLExpr target) {
            if (valueExpr == expr) {
                setValueExpr(target);
                return true;
            }

            if (conditionExpr == expr) {
                setConditionExpr(target);
                return true;
            }

            return false;
        }
    }

   override
    public size_t toHash() @trusted nothrow {
         int prime = 31;
        size_t result = 1;
        result = prime * result + ((elseExpr is null) ? 0 : (cast(Object)elseExpr).toHash());
        result = prime * result + ((items is null) ? 0 : (cast(Object)items).toHash());
        result = prime * result + ((valueExpr is null) ? 0 : (cast(Object)valueExpr).toHash());
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
        SQLCaseExpr other = cast(SQLCaseExpr) obj;
        if (elseExpr is null) {
            if (other.elseExpr !is null) {
                return false;
            }
        } else if (!(cast(Object)(elseExpr)).opEquals(cast(Object)(other.elseExpr))) {
            return false;
        }
        if (items is null) {
            if (other.items !is null) {
                return false;
            }
        } else if (!(cast(Object)(items)).opEquals(cast(Object)(other.items))) {
            return false;
        }
        if (valueExpr is null) {
            if (other.valueExpr !is null) {
                return false;
            }
        } else if (!(cast(Object)(valueExpr)).opEquals(cast(Object)(other.valueExpr))) {
            return false;
        }
        return true;
    }


    override public SQLCaseExpr clone() {
        SQLCaseExpr x = new SQLCaseExpr();

        foreach (Item item ; items) {
            x.addItem(item.clone());
        }

        if (valueExpr !is null) {
            x.setValueExpr(valueExpr.clone());
        }

        if (elseExpr !is null) {
            x.setElseExpr(elseExpr.clone());
        }

        return x;
    }

    override public SQLDataType computeDataType() {
        foreach (Item item ; items) {
            SQLExpr expr = item.getValueExpr();
            if (expr !is null) {
                SQLDataType dataType = expr.computeDataType();
                if (dataType !is null) {
                    return dataType;
                }
            }
        }

        if(elseExpr !is null) {
            return elseExpr.computeDataType();
        }

        return null;
    }

    override public string toString() {
        return SQLUtils.toSQLString(this, null);
    }
}
