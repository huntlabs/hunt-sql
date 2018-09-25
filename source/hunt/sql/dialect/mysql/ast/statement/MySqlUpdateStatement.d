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
module hunt.sql.dialect.mysql.ast.statement.MySqlUpdateStatement;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLOrderBy;
import hunt.sql.ast.statement.SQLUpdateStatement;
import hunt.sql.ast.SQLLimit;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.util.DBType;
import hunt.sql.dialect.mysql.ast.statement.MySqlStatement;
import hunt.container;
import hunt.sql.ast.SQLObject;
import hunt.sql.ast.statement.SQLUpdateSetItem;

public class MySqlUpdateStatement : SQLUpdateStatement , MySqlStatement {
    private SQLLimit limit;

    private bool             lowPriority        = false;
    private bool             ignore             = false;
    private bool             commitOnSuccess    = false;
    private bool             rollBackOnFail     = false;
    private bool             queryOnPk          = false;
    private SQLExpr             targetAffectRow;

    // for petadata
    private bool             forceAllPartitions = false;
    private SQLName             forcePartition;

    public this(){
        super(DBType.MYSQL.name);
    }

    public SQLLimit getLimit() {
        return limit;
    }

    public void setLimit(SQLLimit limit) {
        if (limit !is null) {
            limit.setParent(this);
        }
        this.limit = limit;
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (cast(MySqlASTVisitor)(visitor) !is null) {
            accept0(cast(MySqlASTVisitor) visitor);
        } else {
            super.accept0(visitor);
        }
    }

    public void accept0(MySqlASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, tableSource);
            acceptChild!SQLUpdateSetItem(visitor, items);
            acceptChild(visitor, where);
            acceptChild(visitor, orderBy);
            acceptChild(visitor, limit);
        }
        visitor.endVisit(this);
    }

    public bool isLowPriority() {
        return lowPriority;
    }

    public void setLowPriority(bool lowPriority) {
        this.lowPriority = lowPriority;
    }

    public bool isIgnore() {
        return ignore;
    }

    public void setIgnore(bool ignore) {
        this.ignore = ignore;
    }

    public bool isCommitOnSuccess() {
        return commitOnSuccess;
    }

    public void setCommitOnSuccess(bool commitOnSuccess) {
        this.commitOnSuccess = commitOnSuccess;
    }

    public bool isRollBackOnFail() {
        return rollBackOnFail;
    }

    public void setRollBackOnFail(bool rollBackOnFail) {
        this.rollBackOnFail = rollBackOnFail;
    }

    public bool isQueryOnPk() {
        return queryOnPk;
    }

    public void setQueryOnPk(bool queryOnPk) {
        this.queryOnPk = queryOnPk;
    }

    public SQLExpr getTargetAffectRow() {
        return targetAffectRow;
    }

    public void setTargetAffectRow(SQLExpr targetAffectRow) {
        if (targetAffectRow !is null) {
            targetAffectRow.setParent(this);
        }
        this.targetAffectRow = targetAffectRow;
    }

    public bool isForceAllPartitions() {
        return forceAllPartitions;
    }

    public void setForceAllPartitions(bool forceAllPartitions) {
        this.forceAllPartitions = forceAllPartitions;
    }

    public SQLName getForcePartition() {
        return forcePartition;
    }

    public void setForcePartition(SQLName x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.forcePartition = x;
    }
}
