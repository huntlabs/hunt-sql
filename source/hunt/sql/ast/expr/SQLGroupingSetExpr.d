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
module hunt.sql.ast.expr.SQLGroupingSetExpr;


import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLExprImpl;
import hunt.sql.ast.SQLObject;
import hunt.sql.ast.statement.SQLExplainStatement;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.container;

public class SQLGroupingSetExpr : SQLExprImpl {

    private  List!SQLExpr parameters;

    this()
    {
         parameters = new ArrayList!SQLExpr();
    }

    override public SQLGroupingSetExpr clone() {
        SQLGroupingSetExpr x = new SQLGroupingSetExpr();
        foreach (SQLExpr p ; parameters) {
            SQLExpr p2 = p.clone();
            p2.setParent(x);
            x.parameters.add(p2);
        }
        return x;
    }

    public List!SQLExpr getParameters() {
        return parameters;
    }
    
    public void addParameter(SQLExpr parameter) {
        if (parameter !is null) {
            parameter.setParent(this);
        }
        this.parameters.add(parameter);
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild!SQLExpr(visitor, parameters);
        }
        visitor.endVisit(this);
    }

   override
    public List!SQLObject getChildren() {
        return  cast(List!SQLObject)this.parameters;
    }

   override
    public size_t toHash() @trusted nothrow {
         int prime = 31;
        size_t result = 1;
        result = prime * result + ((parameters is null) ? 0 : (cast(Object)parameters).toHash());
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
        if (!(cast(SQLGroupingSetExpr)obj !is null)) {
            return false;
        }
        SQLGroupingSetExpr other = cast(SQLGroupingSetExpr) obj;
        if (parameters is null) {
            if (other.parameters !is null) {
                return false;
            }
        } else if (!(cast(Object)(parameters)).opEquals(cast(Object)(other.parameters))) {
            return false;
        }
        return true;
    }

}
