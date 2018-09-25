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
module hunt.sql.dialect.mysql.ast.statement.MySqlInsertStatement;


import hunt.container;
import hunt.sql.ast.SQLObject;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.statement.SQLInsertStatement;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;
import hunt.sql.dialect.mysql.visitor.MySqlOutputVisitor;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.util.DBType;
import hunt.sql.ast.SQLObjectImpl;

public class MySqlInsertStatement : SQLInsertStatement {

    alias cloneTo = SQLInsertStatement.cloneTo;

    private bool             lowPriority        = false;
    private bool             delayed            = false;
    private bool             highPriority       = false;
    private bool             ignore             = false;
    private bool             rollbackOnFail     = false;

    private  List!(SQLExpr) duplicateKeyUpdate;

    this() {
        duplicateKeyUpdate = new ArrayList!(SQLExpr)();
        dbType = DBType.MYSQL.name;
    }

    public void cloneTo(MySqlInsertStatement x) {
        super.cloneTo(x);
        x.lowPriority = lowPriority;
        x.delayed = delayed;
        x.highPriority = highPriority;
        x.ignore = ignore;
        x.rollbackOnFail = rollbackOnFail;

        foreach(SQLExpr e ; duplicateKeyUpdate) {
            SQLExpr e2 = e.clone();
            e2.setParent(x);
            x.duplicateKeyUpdate.add(e2);
        }
    }

    public List!(SQLExpr) getDuplicateKeyUpdate() {
        return duplicateKeyUpdate;
    }

    public bool isLowPriority() {
        return lowPriority;
    }

    public void setLowPriority(bool lowPriority) {
        this.lowPriority = lowPriority;
    }

    public bool isDelayed() {
        return delayed;
    }

    public void setDelayed(bool delayed) {
        this.delayed = delayed;
    }

    public bool isHighPriority() {
        return highPriority;
    }

    public void setHighPriority(bool highPriority) {
        this.highPriority = highPriority;
    }

    public bool isIgnore() {
        return ignore;
    }

    public void setIgnore(bool ignore) {
        this.ignore = ignore;
    }

    public bool isRollbackOnFail() {
        return rollbackOnFail;
    }

    public void setRollbackOnFail(bool rollbackOnFail) {
        this.rollbackOnFail = rollbackOnFail;
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (cast(MySqlASTVisitor)(visitor) !is null) {
            accept0(cast(MySqlASTVisitor) visitor);
        } else {
            super.accept0(visitor);
        }
    }

    override  public void output(StringBuffer buf) {
        new MySqlOutputVisitor(buf).visit(this);
    }

    protected void accept0(MySqlASTVisitor visitor) {
        if (visitor.visit(this)) {
            this.acceptChild(visitor, getTableSource());
            this.acceptChild!SQLExpr(visitor, getColumns());
            this.acceptChild!ValuesClause(visitor, getValuesList());
            this.acceptChild(visitor, getQuery());
            this.acceptChild!SQLExpr(visitor, getDuplicateKeyUpdate());
        }

        visitor.endVisit(this);
    }

    override public SQLInsertStatement clone() {
        MySqlInsertStatement x = new MySqlInsertStatement();
        cloneTo(x);
        return x;
    }
}
