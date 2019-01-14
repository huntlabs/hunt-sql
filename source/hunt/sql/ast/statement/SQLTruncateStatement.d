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
module hunt.sql.ast.statement.SQLTruncateStatement;


import hunt.collection;

import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLObject;
import hunt.sql.ast.SQLStatementImpl;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLExprTableSource;
import hunt.Boolean;

public class SQLTruncateStatement : SQLStatementImpl {

    protected List!SQLExprTableSource tableSources;

    private bool                    purgeSnapshotLog           = false;

    private bool                    only;
    private Boolean                    restartIdentity;
    private Boolean                    cascade;

    // db2
    private bool                    dropStorage                = false;
    private bool                    reuseStorage               = false;
    private bool                    immediate                  = false;
    private bool                    ignoreDeleteTriggers       = false;
    private bool                    restrictWhenDeleteTriggers = false;
    private bool                    continueIdentity           = false;

    public this(){
        tableSources               = new ArrayList!SQLExprTableSource(2);
    }

    public this(string dbType){
        tableSources               = new ArrayList!SQLExprTableSource(2);
        super(dbType);
    }

    public List!SQLExprTableSource getTableSources() {
        return tableSources;
    }

    public void setTableSources(List!SQLExprTableSource tableSources) {
        this.tableSources = tableSources;
    }

    public void addTableSource(SQLName name) {
        SQLExprTableSource tableSource = new SQLExprTableSource(name);
        tableSource.setParent(this);
        this.tableSources.add(tableSource);
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild!SQLExprTableSource(visitor, tableSources);
        }
        visitor.endVisit(this);
    }

    public bool isPurgeSnapshotLog() {
        return purgeSnapshotLog;
    }

    public void setPurgeSnapshotLog(bool purgeSnapshotLog) {
        this.purgeSnapshotLog = purgeSnapshotLog;
    }

    public bool isOnly() {
        return only;
    }

    public void setOnly(bool only) {
        this.only = only;
    }

    public Boolean getRestartIdentity() {
        return restartIdentity;
    }

    public void setRestartIdentity(Boolean restartIdentity) {
        this.restartIdentity = restartIdentity;
    }

    public Boolean getCascade() {
        return cascade;
    }

    public void setCascade(Boolean cascade) {
        this.cascade = cascade;
    }

    public bool isDropStorage() {
        return dropStorage;
    }

    public void setDropStorage(bool dropStorage) {
        this.dropStorage = dropStorage;
    }

    public bool isReuseStorage() {
        return reuseStorage;
    }

    public void setReuseStorage(bool reuseStorage) {
        this.reuseStorage = reuseStorage;
    }

    public bool isImmediate() {
        return immediate;
    }

    public void setImmediate(bool immediate) {
        this.immediate = immediate;
    }

    public bool isIgnoreDeleteTriggers() {
        return ignoreDeleteTriggers;
    }

    public void setIgnoreDeleteTriggers(bool ignoreDeleteTriggers) {
        this.ignoreDeleteTriggers = ignoreDeleteTriggers;
    }

    public bool isRestrictWhenDeleteTriggers() {
        return restrictWhenDeleteTriggers;
    }

    public void setRestrictWhenDeleteTriggers(bool restrictWhenDeleteTriggers) {
        this.restrictWhenDeleteTriggers = restrictWhenDeleteTriggers;
    }

    public bool isContinueIdentity() {
        return continueIdentity;
    }

    public void setContinueIdentity(bool continueIdentity) {
        this.continueIdentity = continueIdentity;
    }

    override
    public List!SQLObject getChildren() {
        return cast(List!SQLObject)tableSources;
    }
}
