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
module hunt.sql.dialect.mysql.ast.statement.MySqlAlterTableModifyColumn;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.statement.SQLAlterTableItem;
import hunt.sql.ast.statement.SQLColumnDefinition;
import hunt.sql.dialect.mysql.ast.MySqlObjectImpl;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;

public class MySqlAlterTableModifyColumn : MySqlObjectImpl , SQLAlterTableItem {

    alias accept0 = MySqlObjectImpl.accept0;
    
    private SQLColumnDefinition newColumnDefinition;

    private bool             first;

    private SQLName             firstColumn;
    private SQLName             afterColumn;

    override
    public void accept0(MySqlASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, newColumnDefinition);

            acceptChild(visitor, firstColumn);
            acceptChild(visitor, afterColumn);
        }
    }

    public SQLName getFirstColumn() {
        return firstColumn;
    }

    public void setFirstColumn(SQLName firstColumn) {
        this.firstColumn = firstColumn;
    }

    public SQLName getAfterColumn() {
        return afterColumn;
    }

    public void setAfterColumn(SQLName afterColumn) {
        this.afterColumn = afterColumn;
    }

    public SQLColumnDefinition getNewColumnDefinition() {
        return newColumnDefinition;
    }

    public void setNewColumnDefinition(SQLColumnDefinition newColumnDefinition) {
        this.newColumnDefinition = newColumnDefinition;
    }

    public bool isFirst() {
        return first;
    }

    public void setFirst(bool first) {
        this.first = first;
    }

}
