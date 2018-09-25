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
module hunt.sql.ast.statement.SQLUnique;


import hunt.container;

import hunt.sql.SQLUtils;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.expr.SQLIdentifierExpr;
import hunt.sql.ast.expr.SQLMethodInvokeExpr;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLConstraintImpl;
import hunt.sql.ast.statement.SQLUniqueConstraint;
import hunt.sql.ast.statement.SQLSelectOrderByItem;
import hunt.sql.ast.statement.SQLTableElement;
import hunt.sql.ast.SQLObject;

public class SQLUnique : SQLConstraintImpl , SQLUniqueConstraint, SQLTableElement {

    alias cloneTo = SQLConstraintImpl.cloneTo;

    public   List!SQLSelectOrderByItem columns;

    public this(){
        columns = new ArrayList!SQLSelectOrderByItem();
    }

    public List!SQLSelectOrderByItem getColumns() {
        return columns;
    }
    
    public void addColumn(SQLExpr column) {
        if (column is null) {
            return;
        }

        addColumn(new SQLSelectOrderByItem(column));
    }

    public void addColumn(SQLSelectOrderByItem column) {
        if (column !is null) {
            column.setParent(this);
        }
        this.columns.add(column);
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, this.getName());
            acceptChild!SQLSelectOrderByItem(visitor, this.getColumns());
        }
        visitor.endVisit(this);
    }

    public bool containsColumn(string column) {
        foreach (SQLSelectOrderByItem item ; columns) {
            SQLExpr expr = item.getExpr();
            if (cast(SQLIdentifierExpr)(expr) !is null ) {
                if (SQLUtils.nameEquals((cast(SQLIdentifierExpr) expr).getName(), column)) {
                    return true;
                }
            }
        }
        return false;
    }

    public bool containsColumn(long columnNameHash) {
        foreach (SQLSelectOrderByItem item ; columns) {
            SQLExpr expr = item.getExpr();
            if (cast(SQLIdentifierExpr)(expr) !is null ) {
                if ((cast(SQLIdentifierExpr) expr).nameHashCode64() == columnNameHash) {
                    return true;
                }
            }
        }
        return false;
    }

    public void cloneTo(SQLUnique x) {
        super.cloneTo(x);

        foreach (SQLSelectOrderByItem column ; columns) {
            SQLSelectOrderByItem column2 = column.clone();
            column2.setParent(x);
            x.columns.add(column2);
        }
    }

    override public SQLUnique clone() {
        SQLUnique x = new SQLUnique();
        cloneTo(x);
        return x;
    }

    override public void simplify() {
        super.simplify();

        foreach (SQLSelectOrderByItem item ; columns) {
            SQLExpr column = item.getExpr();
            if (cast(SQLIdentifierExpr)(column) !is null ) {
                SQLIdentifierExpr identExpr = cast(SQLIdentifierExpr) column;
                string columnName = identExpr.getName();
                string normalized = SQLUtils.normalize(columnName, dbType);
                if (normalized != columnName) {
                    item.setExpr(new SQLIdentifierExpr(columnName));
                }
            }
        }
    }

    public bool applyColumnRename(SQLName columnName, SQLName to) {
        foreach (SQLSelectOrderByItem orderByItem ; columns) {
            SQLExpr expr = orderByItem.getExpr();
            if ( cast(SQLName)expr !is null
                    && SQLUtils.nameEquals(cast(SQLName) expr, columnName)) {
                orderByItem.setExpr(to.clone());
                return true;
            }
        }
        return false;
    }

    public bool applyDropColumn(SQLName columnName) {
        for (int i = columns.size() - 1; i >= 0; i--) {
            SQLExpr expr = columns.get(i).getExpr();
            if ( cast(SQLName)expr !is null
                    && SQLUtils.nameEquals(cast(SQLName) expr, columnName)) {
                columns.removeAt(i);
                return true;
            }

            if ( cast(SQLMethodInvokeExpr)expr !is null
                    && SQLUtils.nameEquals((cast(SQLMethodInvokeExpr) expr).getMethodName(), columnName.getSimpleName())) {
                columns.removeAt(i);
                return true;
            }
        }
        return false;
    }
}
