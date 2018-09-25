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
module hunt.sql.ast.statement.SQLAlterTableRenameColumn;

import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLAlterTableItem;

public class SQLAlterTableRenameColumn : SQLObjectImpl , SQLAlterTableItem {

    private SQLName column;
    private SQLName to;

    public this(){

    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, column);
            acceptChild(visitor, to);
        }
        visitor.endVisit(this);
    }

    public SQLName getColumn() {
        return column;
    }

    public void setColumn(SQLName column) {
        if (column !is null) {
            column.setParent(this);
        }
        this.column = column;
    }

    public SQLName getTo() {
        return to;
    }

    public void setTo(SQLName to) {
        if (to !is null) {
            to.setParent(this);
        }
        this.to = to;
    }

}
