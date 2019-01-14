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
module hunt.sql.ast.expr.SQLBinaryOpExprGroup;

import hunt.sql.SQLUtils;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLExprImpl;
import hunt.sql.ast.SQLObject;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.expr.SQLBinaryOperator;
import hunt.collection;

public class SQLBinaryOpExprGroup : SQLExprImpl {
    private  SQLBinaryOperator operator;
    private  List!SQLExpr items;
    private string dbType;

    this()
    {
        items = new ArrayList!SQLExpr();
    }
    public this(SQLBinaryOperator operator) {
        this();
        this.operator = operator;
    }

    public this(SQLBinaryOperator operator, string dbType) {
        this();
        this.operator = operator;
        this.dbType = dbType;
    }

   override
    public bool opEquals(Object o) {
        if (this == o) return true;
        if (o is null || typeid(this) != typeid(o)) return false;

        SQLBinaryOpExprGroup that = cast(SQLBinaryOpExprGroup) o;

        if (operator != that.operator) return false;
        return (cast(Object)items).opEquals(cast(Object)(that.items));
    }

   override
    public size_t toHash() @trusted nothrow {
        size_t result = hashOf(operator);
        result = 31 * result + (cast(Object)items).toHash();
        return result;
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild!SQLExpr(visitor, this.items);
        }

        visitor.endVisit(this);
    }

   override
    public SQLExpr clone() {
        SQLBinaryOpExprGroup x = new SQLBinaryOpExprGroup(operator);

        foreach (SQLExpr item ; items) {
            SQLExpr item2 = item.clone();
            item2.setParent(this);
            x.items.add(item2);
        }

        return x;
    }

   override
    public List!SQLObject getChildren() {
        return cast(List!SQLObject)items;
    }

    public void add(SQLExpr item) {
        if (item !is null) {
            item.setParent(this);
        }
        this.items.add(item);
    }

    public List!SQLExpr getItems() {
        return this.items;
    }

    public SQLBinaryOperator getOperator() {
        return operator;
    }

    override public string toString() {
        return SQLUtils.toSQLString(this, dbType);
    }
}
