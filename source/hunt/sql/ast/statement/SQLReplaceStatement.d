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
module hunt.sql.ast.statement.SQLReplaceStatement;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLStatementImpl;
import hunt.sql.ast.expr.SQLQueryExpr;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLExprTableSource;
import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.ast.SQLObject;


import hunt.collection;

public class SQLReplaceStatement : SQLStatementImpl {
    protected bool             lowPriority = false;
    protected bool             delayed     = false;

    protected SQLExprTableSource  tableSource;
    protected  List!SQLExpr columns;
    protected List!ValuesClause  valuesList;
    protected SQLQueryExpr query;

    this()
    {
        columns     = new ArrayList!SQLExpr();
        valuesList  = new ArrayList!ValuesClause();
    }

    public SQLName getTableName() {
        if (tableSource is null) {
            return null;
        }

        return cast(SQLName) tableSource.getExpr();
    }

    public void setTableName(SQLName tableName) {
        this.setTableSource(new SQLExprTableSource(tableName));
    }

    public SQLExprTableSource getTableSource() {
        return tableSource;
    }

    public void setTableSource(SQLExprTableSource tableSource) {
        if (tableSource !is null) {
            tableSource.setParent(this);
        }
        this.tableSource = tableSource;
    }

    public List!SQLExpr getColumns() {
        return columns;
    }

    public void addColumn(SQLExpr column) {
        if (column !is null) {
            column.setParent(this);
        }
        this.columns.add(column);
    }

    public bool isLowPriority() {
        return lowPriority;
    }

    public void setLowPriority(bool lowPriority) {
        this.lowPriority = lowPriority;
    }

    public bool isDelayed() {
        return delayed;
    }

    public void setDelayed(bool delayed) {
        this.delayed = delayed;
    }

    public SQLQueryExpr getQuery() {
        return query;
    }

    public void setQuery(SQLQueryExpr query) {
        if (query !is null) {
            query.setParent(this);
        }
        this.query = query;
    }

    public List!ValuesClause getValuesList() {
        return valuesList;
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, tableSource);
            acceptChild!SQLExpr(visitor, columns);
            acceptChild!ValuesClause(visitor, valuesList);
            acceptChild(visitor, query);
        }
        visitor.endVisit(this);
    }
}
