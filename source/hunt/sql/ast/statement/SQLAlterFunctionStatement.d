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
module hunt.sql.ast.statement.SQLAlterFunctionStatement;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLStatementImpl;
import hunt.sql.visitor.SQLASTVisitor;

public class SQLAlterFunctionStatement : SQLStatementImpl {
    private SQLName name;

    private bool _debug;
    private bool reuseSettings;

    private SQLExpr comment;
    private bool languageSql;
    private bool containsSql;
    private SQLExpr sqlSecurity;

    public bool isDebug() {
        return _debug;
    }

    public void setDebug(bool _debug) {
        this._debug = _debug;
    }

    public SQLName getName() {
        return name;
    }

    public void setName(SQLName name) {
        if (name !is null) {
            name.setParent(this);
        }
        this.name = name;
    }

    public SQLExpr getComment() {
        return comment;
    }

    public void setComment(SQLExpr comment) {
        if (comment !is null) {
            comment.setParent(this);
        }
        this.comment = comment;
    }

    public bool isReuseSettings() {
        return reuseSettings;
    }

    public void setReuseSettings(bool x) {
        this.reuseSettings = x;
    }

    public bool isLanguageSql() {
        return languageSql;
    }

    public void setLanguageSql(bool languageSql) {
        this.languageSql = languageSql;
    }

    public bool isContainsSql() {
        return containsSql;
    }

    public void setContainsSql(bool containsSql) {
        this.containsSql = containsSql;
    }

    public SQLExpr getSqlSecurity() {
        return sqlSecurity;
    }

    public void setSqlSecurity(SQLExpr sqlSecurity) {
        if (sqlSecurity !is null) {
            sqlSecurity.setParent(this);
        }
        this.sqlSecurity = sqlSecurity;
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, name);
            acceptChild(visitor, comment);
            acceptChild(visitor, sqlSecurity);
        }
        visitor.endVisit(this);
    }
}
