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
module hunt.sql.ast.expr.SQLCastExpr;

import hunt.sql.ast;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.container;

public class SQLCastExpr : SQLExprImpl , SQLObjectWithDataType, SQLReplaceable {

    protected SQLExpr     expr;
    protected SQLDataType dataType;

    public this(){

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

    public SQLDataType getDataType() {
        return this.dataType;
    }

    public void setDataType(SQLDataType dataType) {
        if (dataType !is null) {
            dataType.setParent(this);
        }
        this.dataType = dataType;
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, this.expr);
            acceptChild(visitor, this.dataType);
        }
        visitor.endVisit(this);
    }

   override
    public bool replace(SQLExpr expr, SQLExpr target) {
        if (this.expr == expr) {
            setExpr(target);
            return true;
        }

        return false;
    }

   override
    public List!SQLObject getChildren() {
        //return Arrays.asList(this.expr, this.dataType);
        List!SQLObject ls = new ArrayList!SQLObject();
        ls.add(this.expr);
        ls.add(this.dataType);
        return ls;
    }

   override
    public size_t toHash() @trusted nothrow {
         int prime = 31;
        size_t result = 1;
        result = prime * result + ((dataType is null) ? 0 : (cast(Object)dataType).toHash());
        result = prime * result + ((expr is null) ? 0 : (cast(Object)expr).toHash());
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
        SQLCastExpr other = cast(SQLCastExpr) obj;
        if (dataType is null) {
            if (other.dataType !is null) {
                return false;
            }
        } else if (!(cast(Object)(dataType)).opEquals(cast(Object)(other.dataType))) {
            return false;
        }
        if (expr is null) {
            if (other.expr !is null) {
                return false;
            }
        } else if (!(cast(Object)(expr)).opEquals(cast(Object)(other.expr))) {
            return false;
        }
        return true;
    }

    override public SQLDataType computeDataType() {
        return dataType;
    }

    override public SQLCastExpr clone() {
        SQLCastExpr x = new SQLCastExpr();
        if (expr !is null) {
            x.setExpr(expr.clone());
        }
        if (dataType !is null) {
            x.setDataType(dataType.clone());
        }
        return x;
    }
}
