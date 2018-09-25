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
module hunt.sql.ast.statement.SQLAlterTableRename;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.ast.expr.SQLIdentifierExpr;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLAlterTableItem;
import hunt.sql.ast.statement.SQLExprTableSource;

public class SQLAlterTableRename : SQLObjectImpl , SQLAlterTableItem {

    protected SQLExprTableSource to;

    public this() {

    }

    public this(SQLExpr to) {
        this.setTo(to);
    }

    public this(string to) {
        this.setTo(to);
    }

    public SQLExprTableSource getTo() {
        return to;
    }

    public SQLName getToName() {
        if (to is null) {
            return null;
        }

        SQLExpr expr = to.expr;

        if ( cast(SQLName)expr !is null) {
            return cast(SQLName) expr;
        }

        return null;
    }

    public void setTo(SQLExprTableSource to) {
        if (to !is null) {
            to.setParent(this);
        }
        this.to = to;
    }

    public void setTo(string to) {
        this.setTo(new SQLIdentifierExpr(to));
    }

    public void setTo(SQLExpr to) {
        this.setTo(new SQLExprTableSource(to));
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, to);
        }
        visitor.endVisit(this);
    }

}
