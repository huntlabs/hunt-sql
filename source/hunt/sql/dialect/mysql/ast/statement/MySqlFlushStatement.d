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
module hunt.sql.dialect.mysql.ast.statement.MySqlFlushStatement;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.statement.SQLExprTableSource;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;
import hunt.sql.dialect.mysql.ast.statement.MySqlStatementImpl;

import hunt.sql.ast.SQLObject;

import hunt.container;

/**
 * Created by wenshao on 16/08/2017.
 */
public class MySqlFlushStatement : MySqlStatementImpl {

    alias accept0 = MySqlStatementImpl.accept0;
    
    private bool noWriteToBinlog = false;
    private bool local = false;

    private  List!(SQLExprTableSource) tables;

    private bool withReadLock = false;
    private bool forExport;

    private bool binaryLogs;
    private bool desKeyFile;
    private bool engineLogs;
    private bool errorLogs;
    private bool generalLogs;
    private bool hots;
    private bool logs;
    private bool privileges;
    private bool optimizerCosts;
    private bool queryCache;
    private bool relayLogs;
    private SQLExpr relayLogsForChannel;
    private bool slowLogs;
    private bool status;
    private bool userResources;
    private bool tableOption;

    this()
    {
        tables = new ArrayList!(SQLExprTableSource)();
    }

    public bool isNoWriteToBinlog() {
        return noWriteToBinlog;
    }

    public void setNoWriteToBinlog(bool noWriteToBinlog) {
        this.noWriteToBinlog = noWriteToBinlog;
    }

    public bool isLocal() {
        return local;
    }

    public void setLocal(bool local) {
        this.local = local;
    }

    public List!(SQLExprTableSource) getTables() {
        return tables;
    }

    public bool isWithReadLock() {
        return withReadLock;
    }

    public void setWithReadLock(bool withReadLock) {
        this.withReadLock = withReadLock;
    }

    public bool isForExport() {
        return forExport;
    }

    public void setForExport(bool forExport) {
        this.forExport = forExport;
    }

    public bool isBinaryLogs() {
        return binaryLogs;
    }

    public void setBinaryLogs(bool binaryLogs) {
        this.binaryLogs = binaryLogs;
    }

    public bool isDesKeyFile() {
        return desKeyFile;
    }

    public void setDesKeyFile(bool desKeyFile) {
        this.desKeyFile = desKeyFile;
    }

    public bool isEngineLogs() {
        return engineLogs;
    }

    public void setEngineLogs(bool engineLogs) {
        this.engineLogs = engineLogs;
    }

    public bool isGeneralLogs() {
        return generalLogs;
    }

    public void setGeneralLogs(bool generalLogs) {
        this.generalLogs = generalLogs;
    }

    public bool isHots() {
        return hots;
    }

    public void setHots(bool hots) {
        this.hots = hots;
    }

    public bool isLogs() {
        return logs;
    }

    public void setLogs(bool logs) {
        this.logs = logs;
    }

    public bool isPrivileges() {
        return privileges;
    }

    public void setPrivileges(bool privileges) {
        this.privileges = privileges;
    }

    public bool isOptimizerCosts() {
        return optimizerCosts;
    }

    public void setOptimizerCosts(bool optimizerCosts) {
        this.optimizerCosts = optimizerCosts;
    }

    public bool isQueryCache() {
        return queryCache;
    }

    public void setQueryCache(bool queryCache) {
        this.queryCache = queryCache;
    }

    public bool isRelayLogs() {
        return relayLogs;
    }

    public void setRelayLogs(bool relayLogs) {
        this.relayLogs = relayLogs;
    }

    public SQLExpr getRelayLogsForChannel() {
        return relayLogsForChannel;
    }

    public void setRelayLogsForChannel(SQLExpr relayLogsForChannel) {
        this.relayLogsForChannel = relayLogsForChannel;
    }

    public bool isSlowLogs() {
        return slowLogs;
    }

    public void setSlowLogs(bool showLogs) {
        this.slowLogs = showLogs;
    }

    public bool isStatus() {
        return status;
    }

    public void setStatus(bool status) {
        this.status = status;
    }

    public bool isUserResources() {
        return userResources;
    }

    public void setUserResources(bool userResources) {
        this.userResources = userResources;
    }

    public bool isErrorLogs() {
        return errorLogs;
    }

    public void setErrorLogs(bool errorLogs) {
        this.errorLogs = errorLogs;
    }

    public bool isTableOption() {
        return tableOption;
    }

    public void setTableOption(bool tableOption) {
        this.tableOption = tableOption;
    }

    override public void accept0(MySqlASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild!SQLExprTableSource(visitor, tables);
            acceptChild(visitor, relayLogsForChannel);
        }
        visitor.endVisit(this);
    }

    public void addTable(SQLName name) {
        if (name is null) {
            return;
        }
        this.addTable(new SQLExprTableSource(name));
    }

    public void addTable(SQLExprTableSource table) {
        if (table is null) {
            return;
        }
        table.setParent(this);
        this.tables.add(table);
    }
}
