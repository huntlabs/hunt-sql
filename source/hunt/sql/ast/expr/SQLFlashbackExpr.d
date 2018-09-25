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
module hunt.sql.ast.expr.SQLFlashbackExpr;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLExprImpl;
import hunt.sql.ast.SQLObject;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.container;

/**
 * Created by wenshao on 14/06/2017.
 */
public class SQLFlashbackExpr : SQLExprImpl {
    private Type type;
    private SQLExpr expr;

    public this() {

    }

    public this(Type type, SQLExpr expr) {
        this.type = type;
        this.setExpr(expr);
    }

    public Type getType() {
        return type;
    }

    public void setType(Type type) {
        this.type = type;
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

    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, expr);
        }
        visitor.endVisit(this);
    }

   override
    public List!SQLObject getChildren() {
        return Collections.singletonList!SQLObject(expr);
    }

    override public SQLFlashbackExpr clone() {
        SQLFlashbackExpr x = new SQLFlashbackExpr();
        x.type = this.type;
        if (expr !is null) {
            x.setExpr(expr.clone());
        }
        return x;
    }

   override
    public bool opEquals(Object o) {
        if (this == o) return true;
        if (o is null || typeid(this) != typeid(o)) return false;

        SQLFlashbackExpr that = cast(SQLFlashbackExpr) o;

        if (type != that.type) return false;
        return expr !is null ? (cast(Object)(expr)).opEquals(cast(Object)(that.expr)) : that.expr is null;
    }

   override
    public size_t toHash() @trusted nothrow {
        size_t result = hashOf(type);
        result = 31 * result + (expr !is null ? (cast(Object)expr).toHash() : 0);
        return result;
    }

    public static struct Type {
        enum Type SCN = Type("");
        enum Type TIMESTAMP = Type("");

        private string _name;

        this(string name)
        {
            _name = name;
        }

        @property string name()
        {
            return _name;
        }

        bool opEquals(const Type h) nothrow {
            return _name == h._name ;
        } 

        bool opEquals(ref const Type h) nothrow {
            return _name == h._name ;
        } 
    }
}
