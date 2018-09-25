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
module hunt.sql.ast.statement.SQLConstraintImpl;

import hunt.sql.SQLUtils;
import hunt.sql.ast.SQLCommentHint;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.ast.expr.SQLIdentifierExpr;
import hunt.sql.ast.statement.SQLConstraint;
import hunt.math;
import hunt.container;

public abstract class SQLConstraintImpl : SQLObjectImpl , SQLConstraint {
    protected string  dbType;
    protected SQLName name;
    protected Boolean enable;
    protected Boolean validate;
    protected Boolean rely;
    protected SQLExpr comment;

    public List!SQLCommentHint hints;

    public this(){

    }

    public void cloneTo(SQLConstraintImpl x) {
        if (name !is null) {
            x.setName(name.clone());
        }

        x.enable = enable;
        x.validate = validate;
        x.rely = rely;
    }

    public List!SQLCommentHint getHints() {
        return hints;
    }

    public void setHints(List!SQLCommentHint hints) {
        this.hints = hints;
    }


    public SQLName getName() {
        return name;
    }

    public void setName(SQLName name) {
        this.name = name;
    }

    public void setName(string name) {
        this.setName(new SQLIdentifierExpr(name));
    }

    public Boolean getEnable() {
        return enable;
    }

    public void setEnable(Boolean enable) {
        this.enable = enable;
    }

    public void cloneTo(SQLConstraint x) {
        if (name !is null) {
            x.setName(name.clone());
        }
    }

    public Boolean getValidate() {
        return validate;
    }

    public void setValidate(Boolean validate) {
        this.validate = validate;
    }

    public Boolean getRely() {
        return rely;
    }

    public void setRely(Boolean rely) {
        this.rely = rely;
    }

    public string getDbType() {
        return dbType;
    }

    public void setDbType(string dbType) {
        this.dbType = dbType;
    }

    public SQLExpr getComment() {
        return comment;
    }

    public void setComment(SQLExpr x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.comment = x;
    }

    public void simplify() {
        if (cast(SQLIdentifierExpr)(this.name) !is null ) {
            SQLIdentifierExpr identExpr = cast(SQLIdentifierExpr) this.name;
            string columnName = identExpr.getName();

            string normalized = SQLUtils.normalize(columnName, dbType);
            if (columnName != normalized) {
                this.setName(normalized);
            }
        }
    }
}
