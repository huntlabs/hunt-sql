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
module hunt.sql.dialect.mysql.ast.statement.MySqlCreateTableStatement;

import hunt.collection;

import hunt.sql.SQLUtils;
import hunt.sql.ast;
import hunt.sql.ast.statement;
import hunt.sql.dialect.mysql.ast.MySqlKey;
import hunt.sql.dialect.mysql.ast.MySqlObjectImpl;
import hunt.sql.dialect.mysql.ast.MySqlUnique;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;
import hunt.sql.dialect.mysql.visitor.MySqlOutputVisitor;
import hunt.sql.dialect.mysql.visitor.MySqlShowColumnOutpuVisitor;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.util.DBType;
import hunt.sql.dialect.mysql.ast.statement.MySqlStatement;
import hunt.sql.dialect.mysql.ast.statement.MySqlAlterTableOption;
import hunt.sql.dialect.mysql.ast.statement.MySqlRenameTableStatement;
import hunt.sql.dialect.mysql.ast.statement.MySqlAlterTableAlterColumn;
import hunt.sql.dialect.mysql.ast.statement.MySqlAlterTableChangeColumn;
import hunt.sql.dialect.mysql.ast.statement.MySqlAlterTableModifyColumn;
import hunt.sql.dialect.mysql.ast.statement.MySqlTableIndex;
import hunt.util.Common;

public class MySqlCreateTableStatement : SQLCreateTableStatement , MySqlStatement {

    alias cloneTo = SQLCreateTableStatement.cloneTo;

    private Map!(string, SQLObject) tableOptions = new LinkedHashMap!(string, SQLObject)();
    private List!(SQLCommentHint)   hints       ;
    private List!(SQLCommentHint)   optionHints ;
    private SQLName                tableGroup;

    protected SQLPartitionBy dbPartitionBy;
    protected SQLPartitionBy tablePartitionBy;
    protected SQLExpr        tbpartitions;

    public this(){
        hints        = new ArrayList!(SQLCommentHint)();
        optionHints  = new ArrayList!(SQLCommentHint)();
        super (DBType.MYSQL.name);
    }



    public List!(SQLCommentHint) getHints() {
        return hints;
    }

    public void setHints(List!(SQLCommentHint) hints) {
        this.hints = hints;
    }

    public void setTableOptions(Map!(string, SQLObject) tableOptions) {
        this.tableOptions = tableOptions;
    }

    //@Deprecated
    public SQLSelect getQuery() {
        return select;
    }

    //@Deprecated
    public void setQuery(SQLSelect query) {
        this.select = query;
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
            this.acceptChild!SQLCommentHint(visitor, getHints());
            this.acceptChild(visitor, getTableSource());
            this.acceptChild!SQLTableElement(visitor, getTableElementList());
            this.acceptChild(visitor, getLike());
            this.acceptChild(visitor, getSelect());
        }
        visitor.endVisit(this);
    }

    public static class TableSpaceOption : MySqlObjectImpl {

        alias accept0 = MySqlObjectImpl.accept0;

        private SQLName name;
        private SQLExpr storage;

        public SQLName getName() {
            return name;
        }

        public void setName(SQLName name) {
            if (name !is null) {
                name.setParent(this);
            }
            this.name = name;
        }

        public SQLExpr getStorage() {
            return storage;
        }

        public void setStorage(SQLExpr storage) {
            if (storage !is null) {
                storage.setParent(this);
            }
            this.storage = storage;
        }

        override
        public void accept0(MySqlASTVisitor visitor) {
            if (visitor.visit(this)) {
                acceptChild(visitor, getName());
                acceptChild(visitor, getStorage());
            }
            visitor.endVisit(this);
        }

        override public TableSpaceOption clone() {
            TableSpaceOption x = new TableSpaceOption();

            if (name !is null) {
                x.setName(name.clone());
            }

            if (storage !is null) {
                x.setStorage(storage.clone());
            }

            return x;
        }

    }

    public List!(SQLCommentHint) getOptionHints() {
        return optionHints;
    }

    public void setOptionHints(List!(SQLCommentHint) optionHints) {
        this.optionHints = optionHints;
    }

    
    public SQLName getTableGroup() {
        return tableGroup;
    }

    public void setTableGroup(SQLName tableGroup) {
        this.tableGroup = tableGroup;
    }

    override
    public void simplify() {
        tableOptions.clear();
        super.simplify();
    }

    public void showCoumns(Appendable out_p) {
        this.accept(new MySqlShowColumnOutpuVisitor(out_p));
    }

    public bool apply(MySqlRenameTableStatement x) {
        foreach(MySqlRenameTableStatement.Item item ; x.getItems()) {
            if (apply(item)) {
                return true;
            }
        }

        return false;
    }

    override protected bool alterApply(SQLAlterTableItem item) {
        if (cast(MySqlAlterTableAlterColumn)(item) !is null) {
            return apply(cast(MySqlAlterTableAlterColumn) item);

        } else if (cast(MySqlAlterTableChangeColumn)(item) !is null) {
            return apply(cast(MySqlAlterTableChangeColumn) item);

        } else if (cast(SQLAlterCharacter)(item) !is null) {
            return apply(cast(SQLAlterCharacter) item);

        } else if (cast(MySqlAlterTableModifyColumn)(item) !is null) {
            return apply(cast(MySqlAlterTableModifyColumn) item);

        } else if (cast(MySqlAlterTableOption)(item) !is null) {
            return apply(cast(MySqlAlterTableOption) item);
        }

        return super.alterApply(item);
    }

    override public bool apply(SQLAlterTableAddIndex item) {
        if (item.isUnique()) {
            MySqlUnique x = new MySqlUnique();
            item.cloneTo(x);
            x.setParent(this);
            this.tableElementList.add(x);
            return true;
        }

        if (item.isKey()) {
            MySqlKey x = new MySqlKey();
            item.cloneTo(x);
            x.setParent(this);
            this.tableElementList.add(x);
            return true;
        }

        MySqlTableIndex x = new MySqlTableIndex();
        item.cloneTo(x);
        x.setParent(this);
        this.tableElementList.add(x);
        return true;
    }

    public bool apply(MySqlAlterTableOption item) {
        this.tableOptions.put(item.getName(), item.getValue());
        return true;
    }

    public bool apply(SQLAlterCharacter item) {
        SQLExpr charset = item.getCharacterSet();
        if (charset !is null) {
            this.tableOptions.put("CHARACTER SET", charset);
        }

        SQLExpr collate = item.getCollate();
        if (collate !is null) {
            this.tableOptions.put("COLLATE", collate);
        }
        return true;
    }

    public bool apply(MySqlRenameTableStatement.Item item) {
        if (!SQLUtils.nameEquals(cast(SQLName) item.getName(), this.getName())) {
            return false;
        }
        this.setName(cast(SQLName) item.getTo().clone());
        return true;
    }

    public bool apply(MySqlAlterTableAlterColumn x) {
        int columnIndex = columnIndexOf(x.getColumn());
        if (columnIndex == -1) {
            return false;
        }

        SQLExpr defaultExpr = x.getDefaultExpr();
        SQLColumnDefinition column = cast(SQLColumnDefinition) tableElementList.get(columnIndex);

        if (x.isDropDefault()) {
            column.setDefaultExpr(null);
        } else if (defaultExpr !is null) {
            column.setDefaultExpr(defaultExpr);
        }

        return true;
    }

    public bool apply(MySqlAlterTableChangeColumn item) {
        SQLName columnName = item.getColumnName();
        int columnIndex = columnIndexOf(columnName);
        if (columnIndex == -1) {
            return false;
        }

        int afterIndex = columnIndexOf(item.getAfterColumn());
        int beforeIndex = columnIndexOf(item.getFirstColumn());

        int insertIndex = -1;
        if (beforeIndex != -1) {
            insertIndex = beforeIndex;
        } else if (afterIndex != -1) {
            insertIndex = afterIndex + 1;
        } else if (item.isFirst()) {
            insertIndex = 0;
        }

        SQLColumnDefinition column = item.getNewColumnDefinition().clone();
        column.setParent(this);
        if (insertIndex == -1 || insertIndex == columnIndex) {
            tableElementList.set(columnIndex, column);
        } else {
            if (insertIndex > columnIndex) {
                tableElementList.add(insertIndex, column);
                tableElementList.removeAt(columnIndex);
            } else {
                tableElementList.removeAt(columnIndex);
                tableElementList.add(insertIndex, column);
            }
        }

        for (int i = 0; i < tableElementList.size(); i++) {
            SQLTableElement e = tableElementList.get(i);
            if(cast(MySqlTableIndex)(e) !is null) {
                (cast(MySqlTableIndex) e).applyColumnRename(columnName, column.getName());
            } else if (cast(SQLUnique)(e) !is null) {
                SQLUnique unique = cast(SQLUnique) e;
                unique.applyColumnRename(columnName, column.getName());
            }
        }

        return true;
    }

    public bool apply(MySqlAlterTableModifyColumn item) {
        SQLColumnDefinition column = item.getNewColumnDefinition().clone();
        SQLName columnName = column.getName();

        int columnIndex = columnIndexOf(columnName);
        if (columnIndex == -1) {
            return false;
        }

        int afterIndex = columnIndexOf(item.getAfterColumn());
        int beforeIndex = columnIndexOf(item.getFirstColumn());

        int insertIndex = -1;
        if (beforeIndex != -1) {
            insertIndex = beforeIndex;
        } else if (afterIndex != -1) {
            insertIndex = afterIndex + 1;
        }

        column.setParent(this);
        if (insertIndex == -1 || insertIndex == columnIndex) {
            tableElementList.set(columnIndex, column);
            return true;
        } else {
            if (insertIndex > columnIndex) {
                tableElementList.add(insertIndex, column);
                tableElementList.removeAt(columnIndex);
            } else {
                tableElementList.removeAt(columnIndex);
                tableElementList.add(insertIndex, column);
            }
        }

        return true;
    }

    override public void output(StringBuffer buf) {
        this.accept(new MySqlOutputVisitor(buf));
    }

    public void cloneTo(MySqlCreateTableStatement x) {
        super.cloneTo(x);
        foreach(string k, SQLObject v ; tableOptions) {
            SQLObject obj = v.clone();
            obj.setParent(x);
            x.tableOptions.put(k, obj);
        }
        if (partitioning !is null) {
            x.setPartitioning(partitioning.clone());
        }
        foreach(SQLCommentHint hint ; hints) {
            SQLCommentHint h2 = hint.clone();
            h2.setParent(x);
            x.hints.add(h2);
        }
        foreach(SQLCommentHint hint ; optionHints) {
            SQLCommentHint h2 = hint.clone();
            h2.setParent(x);
            x.optionHints.add(h2);
        }
        if (like !is null) {
            x.setLike(like.clone());
        }
        if (tableGroup !is null) {
            x.setTableGroup(tableGroup.clone());
        }
    }

    override public MySqlCreateTableStatement clone() {
        MySqlCreateTableStatement x = new MySqlCreateTableStatement();
        cloneTo(x);
        return x;
    }

    public SQLPartitionBy getDbPartitionBy() {
        return dbPartitionBy;
    }

    public void setDbPartitionBy(SQLPartitionBy x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.dbPartitionBy = x;
    }

    public SQLPartitionBy getTablePartitionBy() {
        return tablePartitionBy;
    }

    public void setTablePartitionBy(SQLPartitionBy x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.tablePartitionBy = x;
    }

    public SQLExpr getTbpartitions() {
        return tbpartitions;
    }

    public void setTbpartitions(SQLExpr x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.tbpartitions = x;
    }
}
