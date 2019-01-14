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
module hunt.sql.dialect.mysql.ast.statement.MySqlTableIndex;


import hunt.collection;
import hunt.sql.ast.SQLObject;

import hunt.sql.SQLUtils;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.expr.SQLMethodInvokeExpr;
import hunt.sql.ast.statement.SQLColumnDefinition;
import hunt.sql.ast.statement.SQLSelectOrderByItem;
import hunt.sql.ast.statement.SQLTableElement;
import hunt.sql.dialect.mysql.ast.MySqlObjectImpl;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;

public class MySqlTableIndex : MySqlObjectImpl , SQLTableElement {
    alias accept0 = MySqlObjectImpl.accept0;
    private SQLName                    name;
    private string                     indexType;
    private List!(SQLSelectOrderByItem) columns;

    public this(){
        columns = new ArrayList!(SQLSelectOrderByItem)();
    }

    public SQLName getName() {
        return name;
    }

    public string getIndexType() {
        return indexType;
    }

    public void setIndexType(string indexType) {
        this.indexType = indexType;
    }

    public void setName(SQLName name) {
        this.name = name;
    }

    public List!(SQLSelectOrderByItem) getColumns() {
        return columns;
    }
    
    public void addColumn(SQLSelectOrderByItem column) {
        if (column !is null) {
            column.setParent(this);
        }
        this.columns.add(column);
    }

    override public void accept0(MySqlASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, name);
            acceptChild!SQLSelectOrderByItem(visitor, columns);
        }
        visitor.endVisit(this);
    }

    override public MySqlTableIndex clone() {
        MySqlTableIndex x = new MySqlTableIndex();
        if (name !is null) {
            x.setName(name.clone());
        }
        x.indexType = indexType;
        foreach(SQLSelectOrderByItem column ; columns) {
            SQLSelectOrderByItem c2 = column.clone();
            c2.setParent(x);
            x.columns.add(c2);
        }
        return x;
    }

    public bool applyColumnRename(SQLName columnName, SQLName to) {
        foreach(SQLSelectOrderByItem orderByItem ; columns) {
            SQLExpr expr = orderByItem.getExpr();
            if (cast(SQLName)(expr) !is null
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
            if (cast(SQLName)(expr) !is null
                    && SQLUtils.nameEquals(cast(SQLName) expr, columnName)) {
                columns.removeAt(i);
                return true;
            }
            if (cast(SQLMethodInvokeExpr)(expr) !is null
                    && SQLUtils.nameEquals((cast(SQLMethodInvokeExpr) expr).getMethodName(), columnName.getSimpleName())) {
                columns.removeAt(i);
                return true;
            }
        }
        return false;
    }
}
