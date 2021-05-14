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
module hunt.sql.ast.expr.SQLBetweenExpr;

import hunt.collection;

import hunt.sql.ast;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.expr.SQLBooleanExpr;

public class SQLBetweenExpr : SQLExprImpl , SQLReplaceable //Serializable, 
{

    public SQLExpr            testExpr;
    private bool           not;
    public SQLExpr            beginExpr;
    public SQLExpr            endExpr;

    public this(){

    }

    override public SQLBetweenExpr clone() {
        SQLBetweenExpr x = new SQLBetweenExpr();
        if (testExpr !is null) {
            x.setTestExpr(testExpr.clone());
        }
        x.not = not;
        if (beginExpr !is null) {
            x.setBeginExpr(beginExpr.clone());
        }
        if (endExpr !is null) {
            x.setEndExpr(endExpr.clone());
        }
        return x;
    }

    public this(SQLExpr testExpr, SQLExpr beginExpr, SQLExpr endExpr){
        setTestExpr(testExpr);
        setBeginExpr(beginExpr);
        setEndExpr(endExpr);
    }

    public this(SQLExpr testExpr, bool not, SQLExpr beginExpr, SQLExpr endExpr){
        this(testExpr, beginExpr, endExpr);
        this.not = not;
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, this.testExpr);
            acceptChild(visitor, this.beginExpr);
            acceptChild(visitor, this.endExpr);
        }
        visitor.endVisit(this);
    }

    override public List!SQLObject getChildren() {
        // return Arrays.!SQLObjectasList(this.testExpr, beginExpr, this.endExpr);
        List!SQLObject ls = new ArrayList!SQLObject();
        ls.add(this.testExpr);
        ls.add(beginExpr);
        ls.add(this.endExpr);
        return ls;
    }

    public SQLExpr getTestExpr() {
        return this.testExpr;
    }

    public void setTestExpr(SQLExpr testExpr) {
        if (testExpr !is null) {
            testExpr.setParent(this);
        }
        this.testExpr = testExpr;
    }

    public bool isNot() {
        return this.not;
    }

    public void setNot(bool not) {
        this.not = not;
    }

    public SQLExpr getBeginExpr() {
        return this.beginExpr;
    }

    public void setBeginExpr(SQLExpr beginExpr) {
        if (beginExpr !is null) {
            beginExpr.setParent(this);
        }
        this.beginExpr = beginExpr;
    }

    public SQLExpr getEndExpr() {
        return this.endExpr;
    }

    public void setEndExpr(SQLExpr endExpr) {
        if (endExpr !is null) {
            endExpr.setParent(this);
        }
        this.endExpr = endExpr;
    }

   override
    public size_t toHash() @trusted nothrow {
         int prime = 31;
        size_t result = 1;
        result = prime * result + ((beginExpr is null) ? 0 : (cast(Object)beginExpr).toHash());
        result = prime * result + ((endExpr is null) ? 0 : (cast(Object)endExpr).toHash());
        result = prime * result + (not ? 1231 : 1237);
        result = prime * result + ((testExpr is null) ? 0 : (cast(Object)testExpr).toHash());
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
        SQLBetweenExpr other = cast(SQLBetweenExpr) obj;
        if (beginExpr is null) {
            if (other.beginExpr !is null) {
                return false;
            }
        } else if (!(cast(Object)beginExpr).opEquals(cast(Object)(other.beginExpr))) {
            return false;
        }
        if (endExpr is null) {
            if (other.endExpr !is null) {
                return false;
            }
        } else if (!(cast(Object)endExpr).opEquals(cast(Object)(other.endExpr))) {
            return false;
        }
        if (not != other.not) {
            return false;
        }
        if (testExpr is null) {
            if (other.testExpr !is null) {
                return false;
            }
        } else if (!(cast(Object)testExpr).opEquals(cast(Object)(other.testExpr))) {
            return false;
        }
        return true;
    }

    override public SQLDataType computeDataType() {
        return SQLBooleanExpr.DEFAULT_DATA_TYPE;
    }

   override
    public bool replace(SQLExpr expr, SQLExpr target) {
        if (expr == testExpr) {
            setTestExpr(target);
            return true;
        }

        if (expr == beginExpr) {
            setBeginExpr(target);
            return true;
        }

        if (expr == endExpr) {
            setEndExpr(target);
            return true;
        }

        return false;
    }
}
