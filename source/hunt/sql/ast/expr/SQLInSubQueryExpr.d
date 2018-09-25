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
module hunt.sql.ast.expr.SQLInSubQueryExpr;

import hunt.sql.SQLUtils;
import hunt.sql.ast.SQLDataType;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLExprImpl;
import hunt.sql.ast.SQLObject;
import hunt.sql.ast.statement.SQLSelect;
import hunt.sql.visitor.SQLASTOutputVisitor;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.container;
import hunt.sql.ast.expr.SQLBooleanExpr;

public class SQLInSubQueryExpr : SQLExprImpl //, Serializable 
{

    private static  long serialVersionUID = 1L;
    private bool           not              = false;
    private SQLExpr           expr;

    public SQLSelect          subQuery;

    public this(){

    }

    override public SQLInSubQueryExpr clone() {
        SQLInSubQueryExpr x = new SQLInSubQueryExpr();
        x.not = not;
        if (expr !is null) {
            x.setExpr(expr.clone());
        }
        if (subQuery !is null) {
            x.setSubQuery(subQuery.clone());
        }
        return x;
    }

    public bool isNot() {
        return not;
    }

    public void setNot(bool not) {
        this.not = not;
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

    public this(SQLSelect select){

        this.subQuery = select;
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

    override public void output(StringBuffer buf) {
        SQLASTOutputVisitor visitor = SQLUtils.createOutputVisitor(buf, null);
        this.accept(visitor);
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor,this.expr);
            acceptChild(visitor, this.subQuery);
        }

        visitor.endVisit(this);
    }

    override public List!SQLObject getChildren() {
        // return Arrays.!SQLObjectasList(this.expr, this.subQuery);
        List!SQLObject ls = new ArrayList!SQLObject();
        ls.add(this.expr);
        ls.add(this.subQuery);
        return ls;
    }

   override
    public size_t toHash() @trusted nothrow {
         int prime = 31;
        size_t result = 1;
        result = prime * result + ((expr is null) ? 0 : (cast(Object)expr).toHash());
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
        SQLInSubQueryExpr other = cast(SQLInSubQueryExpr) obj;
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
        if (subQuery is null) {
            if (other.subQuery !is null) {
                return false;
            }
        } else if (!(cast(Object)(subQuery)).opEquals(cast(Object)(other.subQuery))) {
            return false;
        }
        return true;
    }

    override public SQLDataType computeDataType() {
        return SQLBooleanExpr.DEFAULT_DATA_TYPE;
    }
}
