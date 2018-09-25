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

module hunt.sql.ast.statement.SQLAlterTableAlterColumn;

import hunt.sql.ast.SQLDataType;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLAlterTableItem;
import hunt.sql.ast.statement.SQLColumnDefinition;


public class SQLAlterTableAlterColumn : SQLObjectImpl , SQLAlterTableItem {
    private SQLName             originColumn;
    private SQLColumnDefinition column;
    private bool             setNotNull;
    private bool             dropNotNull;
    private SQLExpr             setDefault;
    private bool             dropDefault;
    private SQLDataType         dataType;

    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, column);
            acceptChild(visitor, setDefault);
        }
        visitor.endVisit(this);
    }

    public SQLColumnDefinition getColumn() {
        return column;
    }

    public void setColumn(SQLColumnDefinition column) {
        this.column = column;
    }

    public bool isSetNotNull() {
        return setNotNull;
    }

    public void setSetNotNull(bool setNotNull) {
        this.setNotNull = setNotNull;
    }

    public bool isDropNotNull() {
        return dropNotNull;
    }

    public void setDropNotNull(bool dropNotNull) {
        this.dropNotNull = dropNotNull;
    }

    public SQLExpr getSetDefault() {
        return setDefault;
    }

    public void setSetDefault(SQLExpr setDefault) {
        this.setDefault = setDefault;
    }

    public bool isDropDefault() {
        return dropDefault;
    }

    public void setDropDefault(bool dropDefault) {
        this.dropDefault = dropDefault;
    }

    public SQLName getOriginColumn() {
        return originColumn;
    }

    public void setOriginColumn(SQLName x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.originColumn = x;
    }

    public SQLDataType getDataType() {
        return dataType;
    }

    public void setDataType(SQLDataType x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.dataType = x;
    }
}
