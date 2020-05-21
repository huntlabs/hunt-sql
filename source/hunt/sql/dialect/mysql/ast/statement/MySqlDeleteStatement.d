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
module hunt.sql.dialect.mysql.ast.statement.MySqlDeleteStatement;


import hunt.collection;

import hunt.sql.ast.SQLCommentHint;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLOrderBy;
import hunt.sql.ast.statement.SQLDeleteStatement;
import hunt.sql.ast.statement.SQLTableSource;
import hunt.sql.ast.SQLLimit;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;
import hunt.sql.dialect.mysql.visitor.MySqlOutputVisitor;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.util.DBType;
import hunt.util.StringBuilder;

public class MySqlDeleteStatement : SQLDeleteStatement {

    private bool              lowPriority        = false;
    private bool              quick              = false;
    private bool              ignore             = false;
    private SQLOrderBy           orderBy;
    private SQLLimit             limit;
    private List!(SQLCommentHint) hints;
    // for petadata
    private bool              forceAllPartitions = false;
    private SQLName              forcePartition;

    public this(){
        super(DBType.MYSQL.name);
    }

    override public MySqlDeleteStatement clone() {
        MySqlDeleteStatement x = new MySqlDeleteStatement();
        cloneTo(x);

        x.lowPriority = lowPriority;
        x.quick = quick;
        x.ignore = ignore;

        if (using !is null) {
            x.setUsing(using.clone());
        }
        if (orderBy !is null) {
            x.setOrderBy(orderBy.clone());
        }
        if (limit !is null) {
            x.setLimit(limit.clone());
        }

        return x;
    }

    public List!(SQLCommentHint) getHints() {
        if (hints is null) {
            hints = new ArrayList!(SQLCommentHint)();
        }
        return hints;
    }
    
    public int getHintsSize() {
        if (hints is null) {
            return 0;
        }
        
        return hints.size();
    }

    public bool isLowPriority() {
        return lowPriority;
    }

    public void setLowPriority(bool lowPriority) {
        this.lowPriority = lowPriority;
    }

    public bool isQuick() {
        return quick;
    }

    public void setQuick(bool quick) {
        this.quick = quick;
    }

    public bool isIgnore() {
        return ignore;
    }

    public void setIgnore(bool ignore) {
        this.ignore = ignore;
    }

    public SQLOrderBy getOrderBy() {
        return orderBy;
    }

    public void setOrderBy(SQLOrderBy orderBy) {
        this.orderBy = orderBy;
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

    override public void output(StringBuilder buf) {
        new MySqlOutputVisitor(buf).visit(this);
    }

    protected void accept0(MySqlASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, tableSource);
            acceptChild(visitor, where);
            acceptChild(visitor, from);
            acceptChild(visitor, using);
            acceptChild(visitor, orderBy);
            acceptChild(visitor, limit);
        }

        visitor.endVisit(this);
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
