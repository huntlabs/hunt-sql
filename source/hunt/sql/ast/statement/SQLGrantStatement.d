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
module hunt.sql.ast.statement.SQLGrantStatement;
import hunt.sql.ast.statement.SQLObjectType;


import hunt.collection;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLObject;
import hunt.sql.ast.SQLStatementImpl;
import hunt.sql.visitor.SQLASTVisitor;

public class SQLGrantStatement : SQLStatementImpl {

    protected  List!SQLExpr privileges;

    protected SQLObject           on;
    protected SQLExpr             to;

    public this(){
        privileges = new ArrayList!SQLExpr();
    }

    public this(string dbType){
        privileges = new ArrayList!SQLExpr();
        super(dbType);
    }

    // mysql
    protected SQLObjectType objectType;
    private SQLExpr         maxQueriesPerHour;
    private SQLExpr         maxUpdatesPerHour;
    private SQLExpr         maxConnectionsPerHour;
    private SQLExpr         maxUserConnections;

    private bool         adminOption;

    private SQLExpr         identifiedBy;
    private string          identifiedByPassword;

    private bool         withGrantOption;

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild!SQLExpr(visitor, this.privileges);
            acceptChild(visitor, on);
            acceptChild(visitor, to);
            acceptChild(visitor, identifiedBy);
        }
        visitor.endVisit(this);
    }

    override
    public List!SQLObject getChildren() {
        List!SQLObject children = new ArrayList!SQLObject();
        children.addAll(cast(List!SQLObject)(privileges));
        if (on !is null) {
            children.add(on);
        }
        if (to !is null) {
            children.add(to);
        }
        if (identifiedBy !is null) {
            children.add(identifiedBy);
        }
        return children;
    }

    public SQLObjectType getObjectType() {
        return objectType;
    }

    public void setObjectType(SQLObjectType objectType) {
        this.objectType = objectType;
    }

    public SQLObject getOn() {
        return on;
    }

    public void setOn(SQLObject on) {
        this.on = on;
        on.setParent(this);
    }

    public SQLExpr getTo() {
        return to;
    }

    public void setTo(SQLExpr to) {
        this.to = to;
    }

    public List!SQLExpr getPrivileges() {
        return privileges;
    }

    public SQLExpr getMaxQueriesPerHour() {
        return maxQueriesPerHour;
    }

    public void setMaxQueriesPerHour(SQLExpr maxQueriesPerHour) {
        this.maxQueriesPerHour = maxQueriesPerHour;
    }

    public SQLExpr getMaxUpdatesPerHour() {
        return maxUpdatesPerHour;
    }

    public void setMaxUpdatesPerHour(SQLExpr maxUpdatesPerHour) {
        this.maxUpdatesPerHour = maxUpdatesPerHour;
    }

    public SQLExpr getMaxConnectionsPerHour() {
        return maxConnectionsPerHour;
    }

    public void setMaxConnectionsPerHour(SQLExpr maxConnectionsPerHour) {
        this.maxConnectionsPerHour = maxConnectionsPerHour;
    }

    public SQLExpr getMaxUserConnections() {
        return maxUserConnections;
    }

    public void setMaxUserConnections(SQLExpr maxUserConnections) {
        this.maxUserConnections = maxUserConnections;
    }

    public bool isAdminOption() {
        return adminOption;
    }

    public void setAdminOption(bool adminOption) {
        this.adminOption = adminOption;
    }

    public SQLExpr getIdentifiedBy() {
        return identifiedBy;
    }

    public void setIdentifiedBy(SQLExpr identifiedBy) {
        this.identifiedBy = identifiedBy;
    }

    public string getIdentifiedByPassword() {
        return identifiedByPassword;
    }

    public void setIdentifiedByPassword(string identifiedByPassword) {
        this.identifiedByPassword = identifiedByPassword;
    }

    public bool getWithGrantOption() {
        return withGrantOption;
    }

    public void setWithGrantOption(bool withGrantOption) {
        this.withGrantOption = withGrantOption;
    }
}
