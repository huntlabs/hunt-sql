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
module hunt.sql.ast.statement.SQLAlterProcedureStatement;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLStatementImpl;
// import hunt.sql.dialect.oracle.ast.stmt.OracleAlterStatement;
// import hunt.sql.dialect.oracle.ast.stmt.OracleStatementImpl;
// import hunt.sql.dialect.oracle.visitor.OracleASTVisitor;   //@gxc
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLAlterStatement;


public class SQLAlterProcedureStatement : SQLStatementImpl , SQLAlterStatement {

    private SQLExpr name;

    private bool compile       = false;
    private bool reuseSettings = false;

    private SQLExpr comment;
    private bool languageSql;
    private bool containsSql;
    private SQLExpr sqlSecurity;

    override public void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, name);
        }
        visitor.endVisit(this);
    }

    public SQLExpr getName() {
        return name;
    }

    public void setName(SQLExpr name) {
        this.name = name;
    }

    public bool isCompile() {
        return compile;
    }

    public void setCompile(bool compile) {
        this.compile = compile;
    }

    public bool isReuseSettings() {
        return reuseSettings;
    }

    public void setReuseSettings(bool reuseSettings) {
        this.reuseSettings = reuseSettings;
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

    public SQLExpr getComment() {
        return comment;
    }

    public void setComment(SQLExpr comment) {
        if (comment !is null) {
            comment.setParent(this);
        }
        this.comment = comment;
    }
}
