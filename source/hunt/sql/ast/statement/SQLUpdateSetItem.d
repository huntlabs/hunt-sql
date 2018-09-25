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
module hunt.sql.ast.statement.SQLUpdateSetItem;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.ast.SQLReplaceable;
import hunt.sql.ast.expr.SQLIdentifierExpr;
import hunt.sql.ast.expr.SQLPropertyExpr;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.container;

public class SQLUpdateSetItem : SQLObjectImpl , SQLReplaceable {

    private SQLExpr column;
    private SQLExpr value;

    public this(){

    }

    public SQLExpr getColumn() {
        return column;
    }

    public void setColumn(SQLExpr x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.column = x;
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

    override public void output(StringBuffer buf) {
        column.output(buf);
        buf.append(" = ");
        value.output(buf);
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, column);
            acceptChild(visitor, value);
        }

        visitor.endVisit(this);
    }

    public bool columnMatch(string column) {
        if (cast(SQLIdentifierExpr)(this.column) !is null ) {
            return (cast(SQLIdentifierExpr) this.column).nameEquals(column);
        } else if (cast(SQLPropertyExpr)(this.column) !is null ) {
            (cast(SQLPropertyExpr) this.column).nameEquals(column);
        }
        return false;
    }

    public bool columnMatch(long columnHash) {
        if (cast(SQLName)(this.column) !is null ) {
            return (cast(SQLName) this.column).nameHashCode64() == columnHash;
        }

        return false;
    }

    override
    public bool replace(SQLExpr expr, SQLExpr target) {
        if (expr == this.column) {
            this.column = target;
            return true;
        }

        if (expr == this.value) {
            this.value = target;
            return true;
        }
        return false;
    }
}
