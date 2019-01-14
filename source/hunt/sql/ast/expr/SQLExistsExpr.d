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
module hunt.sql.ast.expr.SQLExistsExpr;

import hunt.util.Serialize;

import hunt.collection;

import hunt.sql.ast.SQLExprImpl;
import hunt.sql.ast.statement.SQLSelect;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.SQLObject;


public  class SQLExistsExpr : SQLExprImpl //, Serializable 
{

    private static  long serialVersionUID = 1L;
    public bool            not              = false;
    public SQLSelect          subQuery;

    public this(){

    }

    public this(SQLSelect subQuery){
        this.setSubQuery(subQuery);
    }

    public this(SQLSelect subQuery, bool not){
        this.setSubQuery(subQuery);
        this.not = not;
    }

    public bool isNot() {
        return this.not;
    }

    public void setNot(bool not) {
        this.not = not;
    }

    public SQLSelect getSubQuery() {
        return this.subQuery;
    }

    public void setSubQuery(SQLSelect subQuery) {
        if (subQuery !is null) {
            subQuery.setParent(this);
        }
        this.subQuery = subQuery;
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, this.subQuery);
        }

        visitor.endVisit(this);
    }

   override
    public List!SQLObject getChildren() {
        return Collections.singletonList!SQLObject(this.subQuery);
    }

   override
    public size_t toHash() @trusted nothrow {
         int prime = 31;
        size_t result = 1;
        result = prime * result + (not ? 1231 : 1237);
        result = prime * result + ((subQuery is null) ? 0 : (cast(Object)subQuery).toHash());
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
        SQLExistsExpr other = cast(SQLExistsExpr) obj;
        if (not != other.not) {
            return false;
        }
        if (subQuery is null) {
            if (other.subQuery !is null) {
                return false;
            }
        } else if (!(cast(Object)(subQuery)).opEquals(cast(Object)(other.subQuery))) {
            return false;
        }
        return true;
    }

    override public SQLExistsExpr clone () {
        SQLExistsExpr x = new SQLExistsExpr();

        x.not = not;
        if (subQuery !is null) {
            x.setSubQuery(subQuery.clone());
        }

        return x;
    }
}
