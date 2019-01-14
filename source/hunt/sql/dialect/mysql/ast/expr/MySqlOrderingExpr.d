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
module hunt.sql.dialect.mysql.ast.expr.MySqlOrderingExpr;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLExprImpl;
import hunt.sql.ast.SQLOrderingSpecification;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.dialect.mysql.ast.expr.MySqlExpr;
import hunt.sql.ast.SQLObject;


import hunt.collection;

public class MySqlOrderingExpr : SQLExprImpl , MySqlExpr {

    protected SQLExpr                  expr;
    protected SQLOrderingSpecification type;
    
    public this() {
        
    }
    
    public this(SQLExpr expr, SQLOrderingSpecification type){
        super();
        setExpr(expr);
        this.type = type;
    }

    override public MySqlOrderingExpr clone() {
        MySqlOrderingExpr x = new MySqlOrderingExpr();
        if (expr !is null) {
            x.setExpr(expr.clone());
        }
        x.type = type;
        return x;
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        MySqlASTVisitor mysqlVisitor = cast(MySqlASTVisitor) visitor;
        if (mysqlVisitor.visit(this)) {
            acceptChild(visitor, this.expr);
        }

        mysqlVisitor.endVisit(this);
    }

    override
    public List!SQLObject getChildren() {
        return Collections.singletonList!SQLObject(this.expr);
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

    public SQLOrderingSpecification getType() {
        return type;
    }

    public void setType(SQLOrderingSpecification type) {
        this.type = type;
    }

    override
    public bool opEquals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj is null) {
            return false;
        }
        if ( typeid(this) != typeid(obj)) {
            return false;
        }
        MySqlOrderingExpr other = cast(MySqlOrderingExpr) obj;
        if (expr != other.expr) {
            return false;
        }
        if (type.name.length == 0) {
            if (other.type.name.length != 0) {
                return false;
            }
        } else if (!(type == other.type)) {
            return false;
        }
        return true;
    }

    override
    public size_t toHash() @trusted nothrow {
         int prime = 31;
        size_t result = 1;
        result = prime * result + ((expr is null) ? 0 : (cast(Object)expr).toHash());
        result = prime * result + hashOf(type);
        return result;
    }

}
