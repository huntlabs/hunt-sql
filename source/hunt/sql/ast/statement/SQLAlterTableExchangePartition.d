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
module hunt.sql.ast.statement.SQLAlterTableExchangePartition;

import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLAlterTableItem;
import hunt.sql.ast.statement.SQLExprTableSource;
import hunt.Boolean;

public class SQLAlterTableExchangePartition : SQLObjectImpl , SQLAlterTableItem {
    private SQLName partition;
    private SQLExprTableSource table;
    private bool validation;

    public this() {

    }

    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, partition);
            acceptChild(visitor, table);
        }
        visitor.endVisit(this);
    }

    public SQLName getPartition() {
        return partition;
    }

    public void setPartition(SQLName x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.partition = x;
    }

    public SQLExprTableSource getTable() {
        return table;
    }

    public void setTable(SQLName x) {
        setTable(new SQLExprTableSource(x));
    }

    public void setTable(SQLExprTableSource x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.table = x;
    }

    public void setValidation(bool validation) {
        this.validation = validation;
    }

    public Boolean getValidation() {
        return new Boolean(validation);
    }
}
