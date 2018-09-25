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
module hunt.sql.ast.statement.SQLAlterTableAddColumn;

import hunt.container;

import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLAlterStatement;
import hunt.sql.ast.statement.SQLAlterTableItem;
import hunt.sql.ast.statement.SQLColumnDefinition;
import hunt.sql.ast.SQLObject;

public class SQLAlterTableAddColumn : SQLObjectImpl , SQLAlterTableItem {

    private  List!SQLColumnDefinition columns;
    
    
    // for mysql
    private SQLName firstColumn;
    private SQLName afterColumn;

    private bool first;

    this()
    {
        columns = new ArrayList!SQLColumnDefinition();
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild!SQLColumnDefinition(visitor, columns);
        }
        visitor.endVisit(this);
    }

    public List!SQLColumnDefinition getColumns() {
        return columns;
    }
    
    public void addColumn(SQLColumnDefinition column) {
        if (column !is null) {
            column.setParent(this);
        }
        this.columns.add(column);
    }

    public SQLName getFirstColumn() {
        return firstColumn;
    }

    public void setFirstColumn(SQLName first) {
        this.firstColumn = first;
    }

    public bool isFirst() {
        return first;
    }

    public void setFirst(bool first) {
        this.first = first;
    }

    public SQLName getAfterColumn() {
        return afterColumn;
    }

    public void setAfterColumn(SQLName after) {
        this.afterColumn = after;
    }
}
