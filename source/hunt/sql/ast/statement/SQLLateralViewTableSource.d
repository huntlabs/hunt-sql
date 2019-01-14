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
module hunt.sql.ast.statement.SQLLateralViewTableSource;


import hunt.collection;

import hunt.sql.ast.SQLName;
import hunt.sql.ast.expr.SQLMethodInvokeExpr;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLTableSourceImpl;
import hunt.sql.ast.statement.SQLTableSource;
import hunt.sql.ast.SQLObject;

public class SQLLateralViewTableSource : SQLTableSourceImpl {

    private SQLTableSource      tableSource;

    private SQLMethodInvokeExpr method;

    private List!SQLName       columns;

    this()
    {
        columns = new ArrayList!SQLName(2);
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, tableSource);
            acceptChild(visitor, method);
            acceptChild!SQLName(visitor, columns);
        }
        visitor.endVisit(this);
    }

    public SQLTableSource getTableSource() {
        return tableSource;
    }

    public void setTableSource(SQLTableSource tableSource) {
        if (tableSource !is null) {
            tableSource.setParent(this);
        }
        this.tableSource = tableSource;
    }

    public SQLMethodInvokeExpr getMethod() {
        return method;
    }

    public void setMethod(SQLMethodInvokeExpr method) {
        if (method !is null) {
            method.setParent(this);
        }
        this.method = method;
    }

    public List!SQLName getColumns() {
        return columns;
    }

    public void setColumns(List!SQLName columns) {
        this.columns = columns;
    }

    override public SQLTableSource findTableSource(long alias_hash) {
        long hash = this.aliasHashCode64();
        if (hash != 0 && hash == alias_hash) {
            return this;
        }

        foreach (SQLName column ; columns) {
            if (column.nameHashCode64() == alias_hash) {
                return this;
            }
        }

        if (tableSource !is null) {
            return tableSource.findTableSource(alias_hash);
        }

        return null;
    }

    override public SQLTableSource findTableSourceWithColumn(long columnNameHash) {
        foreach (SQLName column ; columns) {
            if (column.nameHashCode64() == columnNameHash) {
                return this;
            }
        }

        if (tableSource !is null) {
            return tableSource.findTableSourceWithColumn(columnNameHash);
        }
        return null;
    }
}
