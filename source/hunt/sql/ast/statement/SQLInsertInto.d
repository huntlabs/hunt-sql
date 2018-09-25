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
module hunt.sql.ast.statement.SQLInsertInto;


import hunt.container;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.ast.statement.SQLInsertStatement;
// import hunt.sql.ast.statement.SQLInsertStatement.ValuesClause;
import hunt.sql.ast.statement.SQLExprTableSource;
import hunt.sql.ast.statement.SQLSelect;
import hunt.sql.ast.statement.SQLSelectQuery;

public abstract class SQLInsertInto : SQLObjectImpl {
    protected SQLExprTableSource        tableSource;
    protected  List!SQLExpr       columns;
    protected  string          columnsString;
    protected  long            columnsStringHash;
    protected SQLSelect                 query;
    protected  List!(ValuesClause)  valuesList;

    public this(){
        columns = new ArrayList!SQLExpr();
        valuesList = new ArrayList!(ValuesClause)();
    }

    public void cloneTo(SQLInsertInto x) {
        if (tableSource !is null) {
            x.setTableSource(tableSource.clone());
        }
        foreach (SQLExpr column ; columns) {
            SQLExpr column2 = column.clone();
            column2.setParent(x);
            x.columns.add(column2);
        }
        if (query !is null) {
            x.setQuery(query.clone());
        }
        foreach (ValuesClause v ; valuesList) {
            ValuesClause v2 = v.clone();
            v2.setParent(x);
            x.valuesList.add(v2);
        }
    }

    override public abstract SQLInsertInto clone();

    public string getAlias() {
        return tableSource.getAlias();
    }

    public void setAlias(string alias_p) {
        this.tableSource.setAlias(alias_p);
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

    public SQLName getTableName() {
        return cast(SQLName) tableSource.getExpr();
    }

    public void setTableName(SQLName tableName) {
        this.setTableSource(new SQLExprTableSource(tableName));
    }

    public void setTableSource(SQLName tableName) {
        this.setTableSource(new SQLExprTableSource(tableName));
    }

    public SQLSelect getQuery() {
        return query;
    }

    public void setQuery(SQLSelectQuery query) {
        this.setQuery(new SQLSelect(query));
    }

    public void setQuery(SQLSelect query) {
        if (query !is null) {
            query.setParent(this);
        }
        this.query = query;
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

    public ValuesClause getValues() {
        if (valuesList.size() == 0) {
            return null;
        }
        return valuesList.get(0);
    }

    public void setValues(ValuesClause values) {
        if (valuesList.size() == 0) {
            valuesList.add(values);
        } else {
            valuesList.set(0, values);
        }
    }
    
    public List!ValuesClause getValuesList() {
        return valuesList;
    }

    public void addValueCause(ValuesClause valueClause) {
        if (valueClause !is null) {
            valueClause.setParent(this);
        }
        valuesList.add(valueClause);
    }

    public string getColumnsString() {
        return columnsString;
    }

    public long getColumnsStringHash() {
        return columnsStringHash;
    }

    public void setColumnsString(string columnsString, long columnsStringHash) {
        this.columnsString = columnsString;
        this.columnsStringHash = columnsStringHash;
    }
}
