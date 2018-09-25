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
module hunt.sql.dialect.mysql.ast.expr.MySqlExtractExpr;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLExprImpl;
import hunt.sql.ast.expr.SQLIntervalUnit;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.dialect.mysql.ast.expr.MySqlExpr;
import hunt.sql.ast.SQLObject;


import hunt.container;

public class MySqlExtractExpr : SQLExprImpl , MySqlExpr {

    private SQLExpr           value;
    private SQLIntervalUnit unit;

    public this(){
    }

    override public MySqlExtractExpr clone() {
        MySqlExtractExpr x = new MySqlExtractExpr();
        if (value !is null) {
            x.setValue(value.clone());
        }
        x.unit = unit;
        return x;
    }

    public SQLExpr getValue() {
        return value;
    }

    public void setValue(SQLExpr value) {
        if (value !is null) {
            value.setParent(this);
        }
        this.value = value;
    }

    public SQLIntervalUnit getUnit() {
        return unit;
    }

    public void setUnit(SQLIntervalUnit unit) {
        this.unit = unit;
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        MySqlASTVisitor mysqlVisitor = cast(MySqlASTVisitor) visitor;
        if (mysqlVisitor.visit(this)) {
            acceptChild(visitor, value);
        }
        mysqlVisitor.endVisit(this);
    }
    override
    public List!SQLObject getChildren() {
        return Collections.singletonList!SQLObject(value);
    }

    override
    public size_t toHash() @trusted nothrow {
         int prime = 31;
        size_t result = 1;
        result = prime * result + hashOf(unit);
        result = prime * result + ((value is null) ? 0 : (cast(Object)value).toHash());
        return result;
    }

    override
    public bool opEquals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj is null) {
            return false;
        }
        if (!(cast(MySqlExtractExpr)(obj) !is null)) {
            return false;
        }
        MySqlExtractExpr other = cast(MySqlExtractExpr) obj;
        if (unit != other.unit) {
            return false;
        }
        if (value is null) {
            if (other.value !is null) {
                return false;
            }
        } else if (!(cast(Object)(value)).opEquals(cast(Object)(other.value))) {
            return false;
        }
        return true;
    }

}
