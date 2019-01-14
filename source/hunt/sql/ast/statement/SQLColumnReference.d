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
module hunt.sql.ast.statement.SQLColumnReference;

import hunt.collection;

import hunt.sql.ast.SQLName;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLConstraintImpl;
import hunt.sql.ast.statement.SQLColumnConstraint;
import hunt.sql.ast.statement.SQLForeignKeyImpl;

public class SQLColumnReference : SQLConstraintImpl , SQLColumnConstraint {

    private SQLName       table;
    private List!SQLName columns;

    private SQLForeignKeyImpl.Match referenceMatch;
    protected SQLForeignKeyImpl.Option onUpdate;
    protected SQLForeignKeyImpl.Option onDelete;

    public this() {
        columns = new ArrayList!SQLName();
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, this.getName());
        }
        visitor.endVisit(this);
    }

    public SQLName getTable() {
        return table;
    }

    public void setTable(SQLName table) {
        this.table = table;
    }

    public List!SQLName getColumns() {
        return columns;
    }

    public void setColumns(List!SQLName columns) {
        this.columns = columns;
    }

    override public SQLColumnReference clone() {
        SQLColumnReference x = new SQLColumnReference();

        super.cloneTo(x);

        if (table !is null) {
            x.setTable(table.clone());
        }

        foreach (SQLName column ; columns) {
            SQLName columnCloned = column.clone();
            columnCloned.setParent(x);
            x.columns.add(columnCloned);
        }

        x.referenceMatch = referenceMatch;
        x.onUpdate = onUpdate;
        x.onDelete = onDelete;

        return x;
    }

    public SQLForeignKeyImpl.Match getReferenceMatch() {
        return referenceMatch;
    }

    public void setReferenceMatch(SQLForeignKeyImpl.Match referenceMatch) {
        this.referenceMatch = referenceMatch;
    }

    public SQLForeignKeyImpl.Option getOnUpdate() {
        return onUpdate;
    }

    public void setOnUpdate(SQLForeignKeyImpl.Option onUpdate) {
        this.onUpdate = onUpdate;
    }

    public SQLForeignKeyImpl.Option getOnDelete() {
        return onDelete;
    }

    public void setOnDelete(SQLForeignKeyImpl.Option onDelete) {
        this.onDelete = onDelete;
    }
}
