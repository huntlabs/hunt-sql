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
module hunt.sql.ast.statement.SQLAlterTableStatement;


import hunt.collection;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLObject;
import hunt.sql.ast.SQLStatementImpl;
import hunt.sql.ast.expr.SQLIdentifierExpr;
import hunt.sql.ast.expr.SQLPropertyExpr;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLAlterTableItem;
import hunt.sql.ast.statement.SQLExprTableSource;
import hunt.sql.ast.statement.SQLDDLStatement;
import hunt.sql.ast.statement.SQLAlterStatement;

public class SQLAlterTableStatement : SQLStatementImpl , SQLDDLStatement, SQLAlterStatement {

    private SQLExprTableSource      tableSource;
    private List!SQLAlterTableItem items;

    // for mysql
    private bool                 ignore                  = false;

    private bool                 updateGlobalIndexes     = false;
    private bool                 invalidateGlobalIndexes = false;

    private bool                 removePatiting          = false;
    private bool                 upgradePatiting         = false;
    private Map!(string, SQLObject)  tableOptions;

    // odps
    private bool                 mergeSmallFiles         = false;

    public this(){
        items                   = new ArrayList!SQLAlterTableItem();
        tableOptions            = new LinkedHashMap!(string, SQLObject)();
    }

    public this(string dbType){
        items                   = new ArrayList!SQLAlterTableItem();
        tableOptions            = new LinkedHashMap!(string, SQLObject)();
        super(dbType);
    }

    public bool isIgnore() {
        return ignore;
    }

    public void setIgnore(bool ignore) {
        this.ignore = ignore;
    }

    public bool isRemovePatiting() {
        return removePatiting;
    }

    public void setRemovePatiting(bool removePatiting) {
        this.removePatiting = removePatiting;
    }

    public bool isUpgradePatiting() {
        return upgradePatiting;
    }

    public void setUpgradePatiting(bool upgradePatiting) {
        this.upgradePatiting = upgradePatiting;
    }

    public bool isUpdateGlobalIndexes() {
        return updateGlobalIndexes;
    }

    public void setUpdateGlobalIndexes(bool updateGlobalIndexes) {
        this.updateGlobalIndexes = updateGlobalIndexes;
    }

    public bool isInvalidateGlobalIndexes() {
        return invalidateGlobalIndexes;
    }

    public void setInvalidateGlobalIndexes(bool invalidateGlobalIndexes) {
        this.invalidateGlobalIndexes = invalidateGlobalIndexes;
    }

    public bool isMergeSmallFiles() {
        return mergeSmallFiles;
    }

    public void setMergeSmallFiles(bool mergeSmallFiles) {
        this.mergeSmallFiles = mergeSmallFiles;
    }

    public List!SQLAlterTableItem getItems() {
        return items;
    }

    public void addItem(SQLAlterTableItem item) {
        if (item !is null) {
            item.setParent(this);
        }
        this.items.add(item);
    }

    public SQLExprTableSource getTableSource() {
        return tableSource;
    }

    public void setTableSource(SQLExprTableSource tableSource) {
        this.tableSource = tableSource;
    }

    public void setTableSource(SQLExpr table) {
        this.setTableSource(new SQLExprTableSource(table));
    }

    public SQLName getName() {
        if (getTableSource() is null) {
            return null;
        }
        return cast(SQLName) getTableSource().getExpr();
    }

    public long nameHashCode64() {
        if (getTableSource() is null) {
            return 0L;
        }
        return (cast(SQLName) getTableSource().getExpr()).nameHashCode64();
    }

    public void setName(SQLName name) {
        this.setTableSource(new SQLExprTableSource(name));
    }

    public Map!(string, SQLObject) getTableOptions() {
        return tableOptions;
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, getTableSource());
            acceptChild!SQLAlterTableItem(visitor, getItems());
        }
        visitor.endVisit(this);
    }

    override
    public List!SQLObject getChildren() {
        List!SQLObject children = new ArrayList!SQLObject();
        if (tableSource !is null) {
            children.add(tableSource);
        }
        children.addAll(cast(List!SQLObject)(this.items));
        return children;
    }

    public string getTableName() {
        if (tableSource is null) {
            return null;
        }
        SQLExpr expr = (cast(SQLExprTableSource) tableSource).getExpr();
        if ( cast(SQLIdentifierExpr)expr !is null) {
            return (cast(SQLIdentifierExpr) expr).getName();
        } else if ( cast(SQLPropertyExpr)expr !is null) {
            return (cast(SQLPropertyExpr) expr).getName();
        }

        return null;
    }

    public string getSchema() {
        SQLName name = getName();
        if (name is null) {
            return null;
        }

        if ( cast(SQLPropertyExpr)name !is null) {
            return (cast(SQLPropertyExpr) name).getOwnernName();
        }

        return null;
    }
}
