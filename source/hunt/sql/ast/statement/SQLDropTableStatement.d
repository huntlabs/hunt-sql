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
module hunt.sql.ast.statement.SQLDropTableStatement;


import hunt.container;

import hunt.sql.ast.SQLCommentHint;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLObject;
import hunt.sql.ast.SQLStatementImpl;
import hunt.sql.ast.expr.SQLPropertyExpr;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLExprTableSource;
import hunt.sql.ast.statement.SQLDropStatement;

public class SQLDropTableStatement : SQLStatementImpl , SQLDropStatement {
    private List!SQLCommentHint hints;

    protected List!SQLExprTableSource tableSources;

    private bool                    purge;

    protected bool                  cascade      = false;
    protected bool                  restrict     = false;
    protected bool                  ifExists     = false;
    private bool                    temporary    = false;

    public this(){
        tableSources = new ArrayList!SQLExprTableSource();
    }
    
    public this(string dbType){
        tableSources = new ArrayList!SQLExprTableSource();
        super (dbType);
    }

    public this(SQLName name, string dbType){
        tableSources = new ArrayList!SQLExprTableSource();
        this(new SQLExprTableSource(name), dbType);
    }
    
    public this(SQLName name){
        this (name, string.init);
    }
    
    public this(SQLExprTableSource tableSource){
        this(tableSource, string.init);
    }

    public this(SQLExprTableSource tableSource, string dbType){
        this (dbType);
        this.tableSources.add(tableSource);
    }

    public List!SQLExprTableSource getTableSources() {
        return tableSources;
    }
    
    public void addPartition(SQLExprTableSource tableSource) {
        if (tableSource !is null) {
            tableSource.setParent(this);
        }
        this.tableSources.add(tableSource);
    }

    public void setName(SQLName name) {
        this.addTableSource(new SQLExprTableSource(name));
    }

    public void addTableSource(SQLName name) {
        this.addTableSource(new SQLExprTableSource(name));
    }

    public void addTableSource(SQLExprTableSource tableSource) {
        tableSources.add(tableSource);
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            this.acceptChild!SQLExprTableSource(visitor, tableSources);
        }
        visitor.endVisit(this);
    }

    override
    public List!SQLObject getChildren() {
        return cast(List!SQLObject)this.tableSources;
    }

    public bool isPurge() {
        return purge;
    }

    public void setPurge(bool purge) {
        this.purge = purge;
    }

    public bool isIfExists() {
        return ifExists;
    }

    public void setIfExists(bool ifExists) {
        this.ifExists = ifExists;
    }

    public bool isCascade() {
        return cascade;
    }

    public void setCascade(bool cascade) {
        this.cascade = cascade;
    }

    public bool isRestrict() {
        return restrict;
    }

    public void setRestrict(bool restrict) {
        this.restrict = restrict;
    }

    public bool isTemporary() {
        return temporary;
    }

    public void setTemporary(bool temporary) {
        this.temporary = temporary;
    }

    public List!SQLCommentHint getHints() {
        return hints;
    }

    public void setHints(List!SQLCommentHint hints) {
        this.hints = hints;
    }
}
