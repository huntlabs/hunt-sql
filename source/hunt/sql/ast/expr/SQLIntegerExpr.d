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
module hunt.sql.ast.expr.SQLIntegerExpr;

import hunt.sql.ast.SQLDataType;
import hunt.sql.ast.SQLDataTypeImpl;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.expr.SQLNumericLiteralExpr;
import hunt.sql.ast.expr.SQLValuesExpr;
import hunt.sql.ast.expr.SQLValuableExpr;
import hunt.math;
import hunt.container;

public class SQLIntegerExpr : SQLNumericLiteralExpr , SQLValuableExpr{
    public static  SQLDataType DEFAULT_DATA_TYPE;

    private Number number;

    // static this()
    // {
    //      DEFAULT_DATA_TYPE = new SQLDataTypeImpl("bigint");
    // }

    public this(Number number){

        this.number = number;
    }

    public this(int number){
        this.number = new Integer(number);
    }

    public override Number getNumber() {
        return this.number;
    }

    override public void setNumber(Number number) {
        this.number = number;
    }

    public void setNumber(int number) {
        this.number = new Integer(number);
    }

    override public void output(StringBuffer buf) {
        buf.append(this.number.intValue);
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        visitor.visit(this);

        visitor.endVisit(this);
    }

   override
    public size_t toHash() @trusted nothrow {
         int prime = 31;
        size_t result = 1;
        result = prime * result + ((number is null) ? 0 : (cast(Object)number).toHash());
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
        SQLIntegerExpr other = cast(SQLIntegerExpr) obj;
        if (number is null) {
            if (other.number !is null) {
                return false;
            }
        } else if (!(cast(Object)(number)).opEquals(cast(Object)(other.number))) {
            return false;
        }
        return true;
    }

   override
    public Object getValue() {
        return this.number;
    }

    override public SQLIntegerExpr clone() {
        return new SQLIntegerExpr(this.number);
    }

    override public SQLDataType computeDataType() {
        return DEFAULT_DATA_TYPE;
    }

}
