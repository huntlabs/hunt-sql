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
module hunt.sql.ast.expr.SQLCaseStatement;

import hunt.sql.ast;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.collection;

public class SQLCaseStatement : SQLStatementImpl //, Serializable 
{
    private List!Item    items;
    private SQLExpr             valueExpr;
    private List!SQLStatement  elseStatements;

    public this(){
        items            = new ArrayList!Item();
        elseStatements = new ArrayList!SQLStatement();
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

    public List!SQLStatement getElseStatements() {
        return elseStatements;
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
            acceptChild!(SQLCaseStatement.Item)(visitor, this.items);
            acceptChild!SQLStatement(visitor, this.elseStatements);
        }
        visitor.endVisit(this);
    }

   override
    public List!SQLObject getChildren() {
        List!SQLObject children = new ArrayList!SQLObject();
        if (valueExpr !is null) {
            children.add(valueExpr);
        }
        children.addAll(cast(List!SQLObject)(this.items));
        children.addAll(cast(List!SQLObject)(this.elseStatements));
        return children;
    }

    public static class Item : SQLObjectImpl //, Serializable 
    {

        private static  long serialVersionUID = 1L;
        private SQLExpr           conditionExpr;
        private SQLStatement      statement;

        public this(){

        }

        public this(SQLExpr conditionExpr, SQLStatement statement){

            setConditionExpr(conditionExpr);
            setStatement(statement);
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

        public SQLStatement getStatement() {
            return this.statement;
        }

        public void setStatement(SQLStatement statement) {
            if (statement !is null) {
                statement.setParent(this);
            }
            this.statement = statement;
        }

        override  protected void accept0(SQLASTVisitor visitor) {
            if (visitor.visit(this)) {
                acceptChild(visitor, this.conditionExpr);
                acceptChild(visitor, this.statement);
            }
            visitor.endVisit(this);
        }

       override
        public size_t toHash() @trusted nothrow {
             int prime = 31;
            size_t result = 1;
            result = prime * result + ((conditionExpr is null) ? 0 : (cast(Object)conditionExpr).toHash());
            result = prime * result + ((statement is null) ? 0 : (cast(Object)statement).toHash());
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
            if (statement is null) {
                if (other.statement !is null) return false;
            } else if (!(cast(Object)(statement)).opEquals(cast(Object)(other.statement))) return false;
            return true;
        }

    }

   override
    public bool opEquals(Object o) {
        if (this == o) return true;
        if (o is null || typeid(this) != typeid(o)) return false;

        SQLCaseStatement that = cast(SQLCaseStatement) o;

        if (items !is null ? !(cast(Object)(items)).opEquals(cast(Object)(that.items)) : that.items !is null) return false;
        if (valueExpr !is null ? !(cast(Object)(valueExpr)).opEquals(cast(Object)(that.valueExpr)) : that.valueExpr !is null) return false;
        return elseStatements !is null ? (cast(Object)(elseStatements)).opEquals(cast(Object)(that.elseStatements)) : that.elseStatements is null;
    }

   override
    public size_t toHash() @trusted nothrow {
        size_t result = items !is null ? (cast(Object)items).toHash() : 0;
        result = 31 * result + (valueExpr !is null ? (cast(Object)valueExpr).toHash() : 0);
        result = 31 * result + (elseStatements !is null ? (cast(Object)elseStatements).toHash() : 0);
        return result;
    }
}
