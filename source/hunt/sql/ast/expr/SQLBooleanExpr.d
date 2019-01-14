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
module hunt.sql.ast.expr.SQLBooleanExpr;

import hunt.sql.ast.SQLDataType;
import hunt.sql.ast.SQLDataTypeImpl;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLExprImpl;
import hunt.sql.ast.statement.SQLCharacterDataType;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.expr.SQLValuableExpr;
import hunt.sql.ast.expr.SQLLiteralExpr;
import hunt.collection;
import hunt.sql.ast.SQLObject;
import hunt.Boolean;

public  class SQLBooleanExpr : SQLExprImpl , SQLExpr, SQLLiteralExpr, SQLValuableExpr {
    public static  SQLDataType DEFAULT_DATA_TYPE;

    private bool value;

    // static this()
    // {
    //     DEFAULT_DATA_TYPE = new SQLDataTypeImpl(SQLDataType.Constants.BOOLEAN);
    // }

    public this(){

    }

    public this(bool value){
        this.value = value;
    }

    public Boolean getBooleanValue() {
        return new Boolean(value);
    }

    public Boolean getValue() {
        return new Boolean(value);
    }

    public void setValue(bool value) {
        this.value = value;
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        visitor.visit(this);

        visitor.endVisit(this);
    }

    override public void output(StringBuffer buf) {
        buf.append("x");
        buf.append(value ? "TRUE" : "FALSE");
    }

   override
    public size_t toHash() @trusted nothrow {
         int prime = 31;
        size_t result = 1;
        result = prime * result + (value ? 1231 : 1237);
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
        SQLBooleanExpr other = cast(SQLBooleanExpr) obj;
        if (value != other.value) {
            return false;
        }
        return true;
    }

    override public SQLDataType computeDataType() {
        return DEFAULT_DATA_TYPE;
    }

    override public SQLBooleanExpr clone() {
        return new SQLBooleanExpr(value);
    }

   override
    public List!SQLObject getChildren() {
        return Collections.emptyList!(SQLObject)();
    }

    public static enum Type {
        ON_OFF
    }
}
