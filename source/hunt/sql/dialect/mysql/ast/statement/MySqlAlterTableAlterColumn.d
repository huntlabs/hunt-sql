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
module hunt.sql.dialect.mysql.ast.statement.MySqlAlterTableAlterColumn;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.statement.SQLAlterTableItem;
import hunt.sql.dialect.mysql.ast.MySqlObjectImpl;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;

public class MySqlAlterTableAlterColumn : MySqlObjectImpl , SQLAlterTableItem {

    alias accept0 = MySqlObjectImpl.accept0;
    
    private SQLName column;

    private bool dropDefault = false;
    private SQLExpr defaultExpr;

    override
    public void accept0(MySqlASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, column);
            acceptChild(visitor, defaultExpr);
        }
        visitor.endVisit(this);
    }

    public bool isDropDefault() {
        return dropDefault;
    }

    public void setDropDefault(bool dropDefault) {
        this.dropDefault = dropDefault;
    }

    public SQLExpr getDefaultExpr() {
        return defaultExpr;
    }

    public void setDefaultExpr(SQLExpr defaultExpr) {
        this.defaultExpr = defaultExpr;
    }

    public SQLName getColumn() {
        return column;
    }

    public void setColumn(SQLName column) {
        this.column = column;
    }

}
