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
module hunt.sql.ast.statement.SQLCreateTableStatement;


import hunt.sql.SQLUtils;
import hunt.sql.ast;
import hunt.sql.ast.expr.SQLIdentifierExpr;
import hunt.sql.ast.expr.SQLMethodInvokeExpr;
import hunt.sql.ast.expr.SQLPropertyExpr;
import hunt.sql.dialect.mysql.ast.MySqlKey;
import hunt.sql.dialect.mysql.ast.MySqlUnique;
import hunt.sql.dialect.mysql.ast.statement.MySqlTableIndex;
// import hunt.sql.dialect.oracle.ast.stmt.OracleCreateSynonymStatement;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.util.FnvHash;
import hunt.sql.util.DBType;
import hunt.sql.util.ListDG;
import hunt.sql.util.lang.Consumer;
import hunt.sql.ast.statement.SQLAlterTableItem;
import hunt.sql.ast.statement.SQLColumnDefinition;
import hunt.sql.ast.statement.SQLConstraint;
import hunt.sql.ast.statement.SQLUniqueConstraint;
import hunt.sql.ast.statement.SQLSelectOrderByItem;
import hunt.sql.ast.statement.SQLTableElement;
import hunt.sql.ast.statement.SQLExprTableSource;

import hunt.sql.ast.statement.SQLForeignKeyConstraint;
import hunt.sql.ast.statement.SQLSelect;
import hunt.sql.ast.statement.SQLCreateStatement;
import hunt.sql.ast.statement.SQLDDLStatement;
import hunt.container;
import hunt.sql.ast.statement.SQLExternalRecordFormat;
import hunt.sql.ast.statement.SQLPrimaryKey;
import hunt.sql.ast.statement.SQLAlterTableStatement;
import hunt.sql.ast.statement.SQLAlterTableRename;
import hunt.sql.ast.statement.SQLAlterTableRenameColumn;
import hunt.sql.ast.statement.SQLAlterTableDropKey;
import hunt.sql.ast.statement.SQLAlterTableDropConstraint;
import hunt.sql.ast.statement.SQLAlterTableDropForeignKey;
import hunt.sql.ast.statement.SQLAlterTableDropIndex;
import hunt.sql.ast.statement.SQLAlterTableDropPrimaryKey;
import hunt.sql.ast.statement.SQLAlterTableAddConstraint;
import hunt.sql.ast.statement.SQLAlterTableDropColumnItem;
import hunt.sql.ast.statement.SQLAlterTableAddIndex;
import hunt.sql.ast.statement.SQLAlterTableAddColumn;
import hunt.sql.ast.statement.SQLDropIndexStatement;
import hunt.sql.ast.statement.SQLCommentStatement;
import hunt.util.string;
import std.uni;
import hunt.sql.ast.statement.SQLUnique;

public class SQLCreateTableStatement : SQLStatementImpl , SQLDDLStatement, SQLCreateStatement {

    protected bool                          ifNotExiists = false;
    protected Type                             type;
    protected SQLExprTableSource               tableSource;

    protected List!SQLTableElement            tableElementList;

    // for postgresql
    protected SQLExprTableSource               inherits;

    protected SQLSelect                        select;

    protected SQLExpr                          comment;

    protected SQLExprTableSource               like;

    protected bool                          compress;
    protected bool                          logging;

    protected SQLName                          tablespace;
    protected SQLPartitionBy                   partitioning;
    protected SQLName                          storedAs;

    protected bool                          onCommitPreserveRows;
    protected bool                          onCommitDeleteRows;

    // for hive & odps
    protected SQLExternalRecordFormat          rowFormat;
    protected  List!SQLColumnDefinition  partitionColumns;
    protected  List!SQLName              clusteredBy;
    protected  List!SQLSelectOrderByItem sortedBy;
    protected int                              buckets;

    protected Map!(string, SQLObject) tableOptions;

    public this(){
        tableElementList = new ArrayList!SQLTableElement();
        partitionColumns = new ArrayList!SQLColumnDefinition(2);
        clusteredBy = new ArrayList!SQLName();
        sortedBy = new ArrayList!SQLSelectOrderByItem();
        tableOptions = new LinkedHashMap!(string, SQLObject)();
    }

    public this(string dbType){
        tableElementList = new ArrayList!SQLTableElement();
        partitionColumns = new ArrayList!SQLColumnDefinition(2);
        clusteredBy = new ArrayList!SQLName();
        sortedBy = new ArrayList!SQLSelectOrderByItem();
        tableOptions = new LinkedHashMap!(string, SQLObject)();
        super(dbType);
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

    public SQLName getName() {
        if (tableSource is null) {
            return null;
        }

        return cast(SQLName) tableSource.getExpr();
    }

    public string getSchema() {
        SQLName name = getName();
        if (name is null) {
            return null;
        }

        if (cast(SQLPropertyExpr)(name) !is null ) {
            return (cast(SQLPropertyExpr) name).getOwnernName();
        }

        return null;
    }

    public void setSchema(string name) {
        if (this.tableSource is null) {
            return;
        }
        tableSource.setSchema(name);
    }

    public void setName(SQLName name) {
        this.setTableSource(new SQLExprTableSource(name));
    }

    public void setName(string name) {
        this.setName(new SQLIdentifierExpr(name));
    }

    public SQLExprTableSource getTableSource() {
        return tableSource;
    }

    public void setTableSource(SQLExprTableSource tableSource) {
        if (tableSource !is null) {
            tableSource.setParent(this);
        }
        this.tableSource = tableSource;
    }

    public Type getType() {
        return type;
    }

    public void setType(Type type) {
        this.type = type;
    }

    public static enum Type {
                             GLOBAL_TEMPORARY, LOCAL_TEMPORARY
    }

    public List!SQLTableElement getTableElementList() {
        return tableElementList;
    }

    public bool isIfNotExiists() {
        return ifNotExiists;
    }

    public void setIfNotExiists(bool ifNotExiists) {
        this.ifNotExiists = ifNotExiists;
    }

    public SQLExprTableSource getInherits() {
        return inherits;
    }

    public void setInherits(SQLExprTableSource inherits) {
        if (inherits !is null) {
            inherits.setParent(this);
        }
        this.inherits = inherits;
    }

    public SQLSelect getSelect() {
        return select;
    }

    public void setSelect(SQLSelect select) {
        if (select !is null) {
            select.setParent(this);
        }
        this.select = select;
    }

    public SQLExprTableSource getLike() {
        return like;
    }

    public void setLike(SQLName like) {
        this.setLike(new SQLExprTableSource(like));
    }

    public void setLike(SQLExprTableSource like) {
        if (like !is null) {
            like.setParent(this);
        }
        this.like = like;
    }

    public bool getCompress() {
        return compress;
    }

    public void setCompress(bool compress) {
        this.compress = compress;
    }

    public bool getLogging() {
        return logging;
    }

    public void setLogging(bool logging) {
        this.logging = logging;
    }

    public SQLName getTablespace() {
        return tablespace;
    }

    public void setTablespace(SQLName tablespace) {
        if (tablespace !is null) {
            tablespace.setParent(this);
        }
        this.tablespace = tablespace;
    }

    public SQLPartitionBy getPartitioning() {
        return partitioning;
    }

    public void setPartitioning(SQLPartitionBy partitioning) {
        if (partitioning !is null) {
            partitioning.setParent(this);
        }

        this.partitioning = partitioning;
    }

    public Map!(string, SQLObject) getTableOptions() {
        return tableOptions;
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            this.acceptChild(visitor, tableSource);
            this.acceptChild!SQLTableElement(visitor, tableElementList);
            this.acceptChild(visitor, inherits);
            this.acceptChild(visitor, select);
        }
        visitor.endVisit(this);
    }

    override
    public List!SQLObject getChildren() {
        List!SQLObject children = new ArrayList!SQLObject();
        children.add(tableSource);
        children.addAll(cast(List!SQLObject)(tableElementList));
        if (inherits !is null) {
            children.add(inherits);
        }
        if (select !is null) {
            children.add(select);
        }
        return children;
    }

    public void addBodyBeforeComment(List!string comments) {
        if (attributes is null) {
            attributes = new HashMap!(string, Object)();
        }
        
        List!string attrComments = cast(List!string) attributes.get("format.body_before_comment");
        if (attrComments is null) {
            attributes.put("format.body_before_comment", cast(Object)comments);
        } else {
            attrComments.addAll(comments);
        }
    }
    
    public List!string getBodyBeforeCommentsDirect() {
        if (attributes is null) {
            return null;
        }
        
        return cast(List!string) attributes.get("format.body_before_comment");
    }
    
    public bool hasBodyBeforeComment() {
        List!string comments = getBodyBeforeCommentsDirect();
        if (comments is null) {
            return false;
        }
        
        return !comments.isEmpty();
    }

    public string computeName() {
        if (tableSource is null) {
            return null;
        }

        SQLExpr expr = tableSource.getExpr();
        if (cast(SQLName)(expr) !is null ) {
            string name = (cast(SQLName) expr).getSimpleName();
            return SQLUtils.normalize(name);
        }

        return null;
    }

    public SQLColumnDefinition findColumn(string columName) {
        if (columName is null) {
            return null;
        }

        long hash = FnvHash.hashCode64(columName);
        return findColumn(hash);
    }

    public SQLColumnDefinition findColumn(long columName_hash) {
        foreach (SQLTableElement element ; tableElementList) {
            if (cast(SQLColumnDefinition)(element) !is null ) {
                SQLColumnDefinition column = cast(SQLColumnDefinition) element;
                SQLName columnName = column.getName();
                if (columnName !is null && columnName.nameHashCode64() == columName_hash) {
                    return column;
                }
            }
        }

        return null;
    }

    public bool isPrimaryColumn(string columnName) {
        SQLPrimaryKey pk = this.findPrimaryKey();
        if (pk is null) {
            return false;
        }

        return pk.containsColumn(columnName);
    }

    /**
     * only for show columns
     */
    public bool isMUL(string columnName) {
        foreach (SQLTableElement element ; this.tableElementList) {
            if (cast(MySqlUnique)(element) !is null ) {
                MySqlUnique unique = cast(MySqlUnique) element;

                SQLExpr column = unique.getColumns().get(0).getExpr();
                if ( (cast(SQLIdentifierExpr)column !is null)
                        && SQLUtils.nameEquals(columnName, (cast(SQLIdentifierExpr) column).getName())) {
                    return unique.columns.size() > 1;
                } else if ( (cast(SQLMethodInvokeExpr)column !is null)
                        && SQLUtils.nameEquals((cast(SQLMethodInvokeExpr) column).getMethodName(), columnName)) {
                    return true;
                }
            } else if (cast(MySqlKey)(element) !is null ) {
                MySqlKey unique = cast(MySqlKey) element;

                SQLExpr column = unique.getColumns().get(0).getExpr();
                if (  (cast(SQLIdentifierExpr)column !is null)
                        && SQLUtils.nameEquals(columnName, (cast(SQLIdentifierExpr) column).getName())) {
                    return true;
                } else if ( (cast(SQLMethodInvokeExpr)column !is null)
                        && SQLUtils.nameEquals((cast(SQLMethodInvokeExpr) column).getMethodName(), columnName)) {
                    return true;
                }
            }
        }
        return false;
    }

    /**
     * only for show columns
     */
    public bool isUNI(string columnName) {
        foreach (SQLTableElement element ; this.tableElementList) {
            if (cast(MySqlUnique)(element) !is null ) {
                MySqlUnique unique = cast(MySqlUnique) element;

                if (unique.getColumns().size() == 0) {
                    continue;
                }

                SQLExpr column = unique.getColumns().get(0).getExpr();
                if ( (cast(SQLIdentifierExpr)column !is null)
                        && SQLUtils.nameEquals(columnName, (cast(SQLIdentifierExpr) column).getName())) {
                    return unique.columns.size() == 1;
                } else if ( (cast(SQLMethodInvokeExpr)column !is null)
                        && SQLUtils.nameEquals((cast(SQLMethodInvokeExpr) column).getMethodName(), columnName)) {
                    return true;
                }
            }
        }
        return false;
    }

    public MySqlUnique findUnique(string columnName) {
        foreach (SQLTableElement element ; this.tableElementList) {
            if (cast(MySqlUnique)(element) !is null ) {
                MySqlUnique unique = cast(MySqlUnique) element;

                if (unique.containsColumn(columnName)) {
                    return unique;
                }
            }
        }

        return null;
    }

    public SQLTableElement findIndex(string columnName) {
        foreach (SQLTableElement element ; tableElementList) {
            if (cast(SQLUniqueConstraint)(element) !is null ) {
                SQLUniqueConstraint unique = cast(SQLUniqueConstraint) element;
                foreach (SQLSelectOrderByItem item ; unique.getColumns()) {
                    SQLExpr columnExpr = item.getExpr();
                    if (cast(SQLIdentifierExpr)(columnExpr) !is null ) {
                        string keyColumName = (cast(SQLIdentifierExpr) columnExpr).getName();
                        keyColumName = SQLUtils.normalize(keyColumName);
                        if (equalsIgnoreCase(keyColumName, columnName)) {
                            return element;
                        }
                    }
                }

            } else if (cast(MySqlTableIndex)(element) !is null ) {
                List!SQLSelectOrderByItem indexColumns = (cast(MySqlTableIndex) element).getColumns();
                foreach (SQLSelectOrderByItem orderByItem ; indexColumns) {
                    SQLExpr columnExpr = orderByItem.getExpr();
                    if (cast(SQLIdentifierExpr)(columnExpr) !is null ) {
                        string keyColumName = (cast(SQLIdentifierExpr) columnExpr).getName();
                        keyColumName = SQLUtils.normalize(keyColumName);
                        if (equalsIgnoreCase(keyColumName, columnName)) {
                            return element;
                        }
                    }
                }
            }

        }

        return null;
    }

    public void forEachColumn(Consumer!SQLColumnDefinition columnConsumer) {
        if (columnConsumer is null) {
            return;
        }

        foreach (SQLTableElement element ; this.tableElementList) {
            if (cast(SQLColumnDefinition)(element) !is null ) {
                columnConsumer.accept(cast(SQLColumnDefinition) element);
            }
        }
    }

    public SQLPrimaryKey findPrimaryKey() {
        foreach (SQLTableElement element ; this.tableElementList) {
            if (cast(SQLPrimaryKey)(element) !is null ) {
                return cast(SQLPrimaryKey) element;
            }
        }

        return null;
    }

    public List!SQLForeignKeyConstraint findForeignKey() {
        List!SQLForeignKeyConstraint fkList = new ArrayList!SQLForeignKeyConstraint();
        foreach (SQLTableElement element ; this.tableElementList) {
            if (cast(SQLForeignKeyConstraint)(element) !is null ) {
                fkList.add(cast(SQLForeignKeyConstraint) element);
            }
        }
        return fkList;
    }

    public bool hashForeignKey() {
        foreach (SQLTableElement element ; this.tableElementList) {
            if (cast(SQLForeignKeyConstraint)(element) !is null ) {
                return true;
            }
        }
        return false;
    }

    public bool isReferenced(SQLName tableName) {
        if (tableName is null) {
            return false;
        }

        return isReferenced(tableName.getSimpleName());
    }

    public bool isReferenced(string tableName) {
        if (tableName is null) {
            return false;
        }

        tableName = SQLUtils.normalize(tableName);

        foreach (SQLTableElement element ; this.tableElementList) {
            if (cast(SQLForeignKeyConstraint)(element) !is null ) {
                SQLForeignKeyConstraint fk = cast(SQLForeignKeyConstraint) element;
                string refTableName = fk.getReferencedTableName().getSimpleName();

                if (SQLUtils.nameEquals(tableName, refTableName)) {
                    return true;
                }
            }
        }

        return false;
    }

    public SQLAlterTableStatement foreignKeyToAlterTable() {
        SQLAlterTableStatement stmt = new SQLAlterTableStatement();
        for (int i = this.tableElementList.size() - 1; i >= 0; --i) {
            SQLTableElement element = this.tableElementList.get(i);
            if (cast(SQLForeignKeyConstraint)(element) !is null ) {
                SQLForeignKeyConstraint fk = cast(SQLForeignKeyConstraint) element;
                this.tableElementList.removeAt(i);
                stmt.addItem(new SQLAlterTableAddConstraint(fk));
            }
        }

        if (stmt.getItems().size() == 0) {
            return null;
        }

        stmt.setDbType(getDbType());
        stmt.setTableSource(this.tableSource.clone());

       // Collections.reverse(stmt.getItems()); @gxc

        return stmt;
    }

    public static void sort(List!SQLStatement stmtList) {
        Map!(string, SQLCreateTableStatement) tables = new HashMap!(string, SQLCreateTableStatement)();
        Map!(string, List!SQLCreateTableStatement) referencedTables = new HashMap!(string, List!SQLCreateTableStatement)();

        foreach (SQLStatement stmt ; stmtList) {
            if (cast(SQLCreateTableStatement)(stmt) !is null ) {
                SQLCreateTableStatement createTableStmt = cast(SQLCreateTableStatement) stmt;
                string tableName = createTableStmt.getName().getSimpleName();
                tableName = toLower(SQLUtils.normalize(tableName));
                tables.put(tableName, createTableStmt);
            }
        }

        List!(ListDG.Edge) edges = new ArrayList!(ListDG.Edge)();

        foreach (SQLCreateTableStatement stmt ; tables.values()) {
            foreach (SQLTableElement element ; stmt.getTableElementList()) {
                if (cast(SQLForeignKeyConstraint)(element) !is null ) {
                    SQLForeignKeyConstraint fk = cast(SQLForeignKeyConstraint) element;
                    string refTableName = fk.getReferencedTableName().getSimpleName();
                    refTableName = toLower(SQLUtils.normalize(refTableName));

                    SQLCreateTableStatement refTable = tables.get(refTableName);
                    if (refTable !is null) {
                        edges.add(new ListDG.Edge(stmt, refTable));
                    }

                    List!SQLCreateTableStatement referencedList = referencedTables.get(refTableName);
                    if (referencedList is null) {
                        referencedList = new ArrayList!SQLCreateTableStatement();
                        referencedTables.put(refTableName, referencedList);
                    }
                    referencedList.add(stmt);
                }
            }
        }

        // foreach (SQLStatement stmt ; stmtList) {
        //     if (cast(OracleCreateSynonymStatement)(stmt) !is null ) {
        //         OracleCreateSynonymStatement createSynonym = cast(OracleCreateSynonymStatement) stmt;
        //         SQLName object = createSynonym.getObject();
        //         string refTableName = object.getSimpleName();
        //         SQLCreateTableStatement refTable = tables.get(refTableName);
        //         if (refTable !is null) {
        //             edges.add(new ListDG.Edge(stmt, refTable));
        //         }
        //     }
        // }

        ListDG dg = new ListDG(cast(List!Object)stmtList, edges);

        SQLStatement[] tops = new SQLStatement[stmtList.size()];
        if (dg.topologicalSort(cast(Object[])tops)) {
            for (int i = 0, size = stmtList.size(); i < size; ++i) {
                stmtList.set(i, tops[size - i - 1]);
            }
            return;
        }

        List!SQLAlterTableStatement alterList = new ArrayList!SQLAlterTableStatement();

        for (int i = edges.size() - 1; i >= 0; --i) {
            ListDG.Edge edge = edges.get(i);
            SQLCreateTableStatement from = cast(SQLCreateTableStatement) edge.from;
            string fromTableName = from.getName().getSimpleName();
            fromTableName = toLower(SQLUtils.normalize(fromTableName));
            if (referencedTables.containsKey(fromTableName)) {
                edges.removeAt(i);

                //Arrays.fill(tops, null);@gxc
                tops = new SQLStatement[stmtList.size()];

                dg = new ListDG(cast(List!Object)stmtList, edges);
                if (dg.topologicalSort(cast(Object[])tops)) {
                    for (int j = 0, size = stmtList.size(); j < size; ++j) {
                        SQLStatement stmt = tops[size - j - 1];
                        stmtList.set(j, stmt);
                    }

                    SQLAlterTableStatement alter = from.foreignKeyToAlterTable();
                    alterList.add(alter);

                    stmtList.add(alter);
                    return;
                }
                edges.add(i, edge);
            }
        }

        for (int i = edges.size() - 1; i >= 0; --i) {
            ListDG.Edge edge = edges.get(i);
            SQLCreateTableStatement from = cast(SQLCreateTableStatement) edge.from;
            string fromTableName = from.getName().getSimpleName();
            fromTableName = toLower(SQLUtils.normalize(fromTableName));
            if (referencedTables.containsKey(fromTableName)) {
                SQLAlterTableStatement alter = from.foreignKeyToAlterTable();

                edges.removeAt(i);
                if (alter !is null) {
                    alterList.add(alter);
                }

                // Arrays.fill(tops, null);@gxc
                tops = new SQLStatement[stmtList.size()];

                dg = new ListDG(cast(List!Object)stmtList, edges);
                if (dg.topologicalSort(cast(Object[])tops)) {
                    for (int j = 0, size = stmtList.size(); j < size; ++j) {
                        SQLStatement stmt = tops[size - j - 1];
                        stmtList.set(j, stmt);
                    }

                    stmtList.addAll(cast(List!SQLStatement)alterList);
                    return;
                }
            }
        }
    }

    public void simplify() {
        SQLName name = getName();
        if (cast(SQLPropertyExpr)(name) !is null ) {
            string tableName = (cast(SQLPropertyExpr) name).getName();
            tableName = SQLUtils.normalize(tableName);

            string normalized = SQLUtils.normalize(tableName, dbType);
            if (tableName != normalized) {
                this.setName(normalized);
                name = getName();
            }
        }

        if (cast(SQLIdentifierExpr)(name) !is null ) {
            SQLIdentifierExpr identExpr = cast(SQLIdentifierExpr) name;
            string tableName = identExpr.getName();
            string normalized = SQLUtils.normalize(tableName, dbType);
            if (normalized != tableName) {
                setName(normalized);
            }
        }

        foreach (SQLTableElement element ; this.tableElementList) {
            if (cast(SQLColumnDefinition)(element) !is null ) {
                SQLColumnDefinition column = cast(SQLColumnDefinition) element;
                column.simplify();
            } else if (cast(SQLConstraint)(element) !is null ) {
                (cast(SQLConstraint) element).simplify();
            }
        }
    }

    public bool apply(SQLDropIndexStatement x) {
        long indexNameHashCode64 = x.getIndexName().nameHashCode64();

        for (int i = tableElementList.size() - 1; i >= 0; i--) {
            SQLTableElement e = tableElementList.get(i);
            if (cast(SQLUniqueConstraint)(e) !is null ) {
                SQLUniqueConstraint unique = cast(SQLUniqueConstraint) e;
                if (unique.getName().nameHashCode64() == indexNameHashCode64) {
                    tableElementList.removeAt(i);
                    return true;
                }

            } else if (cast(MySqlTableIndex)(e) !is null ) {
                MySqlTableIndex tableIndex = cast(MySqlTableIndex) e;
                if (SQLUtils.nameEquals(tableIndex.getName(), x.getIndexName())) {
                    tableElementList.removeAt(i);
                    return true;
                }
            }
        }
        return false;
    }

    public bool apply(SQLCommentStatement x) {
        SQLName on = x.getOn().getName();
        SQLExpr comment = x.getComment();
        if (comment is null) {
            return false;
        }

        SQLCommentStatement.Type type = x.getType();
        if (type == SQLCommentStatement.Type.TABLE) {
            if (!SQLUtils.nameEquals(getName(), on)) {
                return false;
            }

            setComment(comment.clone());

            return true;
        } else if (type == SQLCommentStatement.Type.COLUMN) {
            SQLPropertyExpr propertyExpr = cast(SQLPropertyExpr) on;
            if (!SQLUtils.nameEquals(getName(), cast(SQLName) propertyExpr.getOwner())) {
                return false;
            }

            SQLColumnDefinition column
                    = this.findColumn(
                        propertyExpr.nameHashCode64());

            if (column !is null) {
                column.setComment(comment.clone());
            }
            return true;
        }

        return false;
    }

    public bool apply(SQLAlterTableStatement alter) {
        if (!SQLUtils.nameEquals(alter.getName(), this.getName())) {
            return false;
        }

        int applyCount = 0;
        foreach (SQLAlterTableItem item ; alter.getItems()) {
            if (alterApply(item)) {
                applyCount++;
            }
        }

        return applyCount > 0;
    }

    protected bool alterApply(SQLAlterTableItem item) {
        if (cast(SQLAlterTableDropColumnItem)(item) !is null ) {
            return apply(cast(SQLAlterTableDropColumnItem) item);

        } else if (cast(SQLAlterTableAddColumn)(item) !is null ) {
            return apply(cast(SQLAlterTableAddColumn) item);

        } else if (cast(SQLAlterTableAddConstraint)(item) !is null ) {
            return apply(cast(SQLAlterTableAddConstraint) item);

        } else if (cast(SQLAlterTableDropPrimaryKey)(item) !is null ) {
            return apply(cast(SQLAlterTableDropPrimaryKey) item);

        } else if (cast(SQLAlterTableDropIndex)(item) !is null ) {
            return apply(cast(SQLAlterTableDropIndex) item);

        } else if (cast(SQLAlterTableDropConstraint)(item) !is null ) {
            return apply(cast(SQLAlterTableDropConstraint) item);

        } else if (cast(SQLAlterTableDropKey)(item) !is null ) {
            return apply(cast(SQLAlterTableDropKey) item);

        } else if (cast(SQLAlterTableDropForeignKey)(item) !is null ) {
            return apply(cast(SQLAlterTableDropForeignKey) item);

        } else if (cast(SQLAlterTableRename)(item) !is null ) {
            return apply(cast(SQLAlterTableRename) item);

        } else if (cast(SQLAlterTableRenameColumn)(item) !is null ) {
            return apply(cast(SQLAlterTableRenameColumn) item);

        } else if (cast(SQLAlterTableAddIndex)(item) !is null ) {
            return apply(cast(SQLAlterTableAddIndex) item);
        }

        return false;
    }

    // SQLAlterTableRenameColumn

    private bool apply(SQLAlterTableRenameColumn item) {
        int columnIndex = columnIndexOf(item.getColumn());
        if (columnIndex == -1) {
            return false;
        }

        SQLColumnDefinition column = cast(SQLColumnDefinition) tableElementList.get(columnIndex);
        column.setName(item.getTo().clone());

        return true;
    }

    public bool renameColumn(string colummName, string newColumnName) {
        if (colummName is null || newColumnName is null || newColumnName.length == 0) {
            return false;
        }

        int columnIndex = columnIndexOf(new SQLIdentifierExpr(colummName));
        if (columnIndex == -1) {
            return false;
        }

        SQLColumnDefinition column = cast(SQLColumnDefinition) tableElementList.get(columnIndex);
        column.setName(new SQLIdentifierExpr(newColumnName));

        return true;
    }

    private bool apply(SQLAlterTableRename item) {
        SQLName name = item.getToName();
        if (name is null) {
            return false;
        }

        this.setName(name.clone());

        return true;
    }

    private bool apply(SQLAlterTableDropForeignKey item) {
        for (int i = tableElementList.size() - 1; i >= 0; i--) {
            SQLTableElement e = tableElementList.get(i);
            if (cast(SQLUniqueConstraint)(e) !is null ) {
                SQLForeignKeyConstraint fk = cast(SQLForeignKeyConstraint) e;
                if (SQLUtils.nameEquals(fk.getName(), item.getIndexName())) {
                    tableElementList.removeAt(i);
                    return true;
                }
            }
        }
        return false;
    }

    private bool apply(SQLAlterTableDropKey item) {
        for (int i = tableElementList.size() - 1; i >= 0; i--) {
            SQLTableElement e = tableElementList.get(i);
            if (cast(SQLUniqueConstraint)(e) !is null ) {
                SQLUniqueConstraint unique = cast(SQLUniqueConstraint) e;
                if (SQLUtils.nameEquals(unique.getName(), item.getKeyName())) {
                    tableElementList.removeAt(i);
                    return true;
                }
            }
        }
        return false;
    }

    private bool apply(SQLAlterTableDropConstraint item) {
        for (int i = tableElementList.size() - 1; i >= 0; i--) {
            SQLTableElement e = tableElementList.get(i);
            if (cast(SQLConstraint)(e) !is null ) {
                SQLConstraint constraint = cast(SQLConstraint) e;
                if (SQLUtils.nameEquals(constraint.getName(), item.getConstraintName())) {
                    tableElementList.removeAt(i);
                    return true;
                }
            }
        }
        return false;
    }

    private bool apply(SQLAlterTableDropIndex item) {
        for (int i = tableElementList.size() - 1; i >= 0; i--) {
            SQLTableElement e = tableElementList.get(i);
            if (cast(SQLUniqueConstraint)(e) !is null ) {
                SQLUniqueConstraint unique = cast(SQLUniqueConstraint) e;
                if (SQLUtils.nameEquals(unique.getName(), item.getIndexName())) {
                    tableElementList.removeAt(i);
                    return true;
                }

            } else if (cast(MySqlTableIndex)(e) !is null ) {
                MySqlTableIndex tableIndex = cast(MySqlTableIndex) e;
                if (SQLUtils.nameEquals(tableIndex.getName(), item.getIndexName())) {
                    tableElementList.removeAt(i);
                    return true;
                }
            }
        }
        return false;
    }

    private bool apply(SQLAlterTableDropPrimaryKey item) {
        for (int i = tableElementList.size() - 1; i >= 0; i--) {
            SQLTableElement e = tableElementList.get(i);
            if (cast(SQLPrimaryKey)(e) !is null ) {
                tableElementList.removeAt(i);
                return true;
            }
        }
        return false;
    }

    private bool apply(SQLAlterTableAddConstraint item) {
        tableElementList.add(cast(SQLTableElement) item.getConstraint());
        return true;
    }

    private bool apply(SQLAlterTableDropColumnItem item) {
        foreach (SQLName column ; item.getColumns()) {
            string columnName = column.getSimpleName();
            for (int i = tableElementList.size() - 1; i >= 0; --i) {
                SQLTableElement e = tableElementList.get(i);
                if (cast(SQLColumnDefinition)(e) !is null ) {
                    if (SQLUtils.nameEquals(columnName, (cast(SQLColumnDefinition) e).getName().getSimpleName())) {
                        tableElementList.removeAt(i);
                    }
                }
            }

            for (int i = tableElementList.size() - 1; i >= 0; --i) {
                SQLTableElement e = tableElementList.get(i);
                if (cast(SQLUnique)(e) !is null ) {
                    SQLUnique unique = cast(SQLUnique) e;
                    unique.applyDropColumn(column);
                    if (unique.getColumns().size() == 0) {
                        tableElementList.removeAt(i);
                    }
                } else if (cast(MySqlTableIndex)(e) !is null ) {
                    MySqlTableIndex index = cast(MySqlTableIndex) e;
                    index.applyDropColumn(column);
                    if (index.getColumns().size() == 0) {
                        tableElementList.removeAt(i);
                    }
                }
            }
        }



        return true;
    }

    protected bool apply(SQLAlterTableAddIndex item) {
        return false;
    }

    private bool apply(SQLAlterTableAddColumn item) {
        int startIndex = tableElementList.size();
        if (item.isFirst()) {
            startIndex = 0;
        }

        int afterIndex = columnIndexOf(item.getAfterColumn());
        if (afterIndex != -1) {
            startIndex = afterIndex + 1;
        }

        int beforeIndex = columnIndexOf(item.getFirstColumn());
        if (beforeIndex != -1) {
            startIndex = beforeIndex;
        }

        for (int i = 0; i < item.getColumns().size(); i++) {
            SQLColumnDefinition column = item.getColumns().get(i);
            tableElementList.add(i + startIndex, column);
            column.setParent(this);
        }

        return true;
    }

    protected int columnIndexOf(SQLName column) {
        if (column is null) {
            return -1;
        }

        string columnName = column.getSimpleName();
        for (int i = tableElementList.size() - 1; i >= 0; --i) {
            SQLTableElement e = tableElementList.get(i);
            if (cast(SQLColumnDefinition)(e) !is null ) {
                if (SQLUtils.nameEquals(columnName, (cast(SQLColumnDefinition) e).getName().getSimpleName())) {
                    return i;
                }
            }
        }

        return -1;
    }

    public void cloneTo(SQLCreateTableStatement x) {
        x.ifNotExiists = ifNotExiists;
        x.type = type;
        if (tableSource !is null) {
            x.setTableSource(tableSource.clone());
        }
        foreach (SQLTableElement e ; tableElementList) {
            SQLTableElement e2 = e.clone();
            e2.setParent(x);
            x.tableElementList.add(e2);
        }
        if (inherits !is null) {
            x.setInherits(inherits.clone());
        }
        if (select !is null) {
            x.setSelect(select.clone());
        }
        if (comment !is null) {
            x.setComment(comment.clone());
        }

        x.onCommitPreserveRows = onCommitPreserveRows;
        x.onCommitDeleteRows = onCommitDeleteRows;

        if (tableOptions !is null) {
            foreach (string k, SQLObject v; tableOptions) {
                SQLObject entryVal = v.clone();
                x.tableOptions.put(k, entryVal);
            }
        }
    }

    public SQLName getStoredAs() {
        return storedAs;
    }

    public void setStoredAs(SQLName x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.storedAs = x;
    }

    override public SQLCreateTableStatement clone() {
        SQLCreateTableStatement x = new SQLCreateTableStatement(dbType);
        cloneTo(x);
        return x;
    }

    override public string toString() {
        return SQLUtils.toSQLString(this, dbType);
    }

    public bool isOnCommitPreserveRows() {
        return onCommitPreserveRows;
    }

    public void setOnCommitPreserveRows(bool onCommitPreserveRows) {
        this.onCommitPreserveRows = onCommitPreserveRows;
    }

    public List!SQLName getClusteredBy() {
        return clusteredBy;
    }

    public List!SQLSelectOrderByItem getSortedBy() {
        return sortedBy;
    }

    public void addSortedByItem(SQLSelectOrderByItem item) {
        item.setParent(this);
        this.sortedBy.add(item);
    }

    public int getBuckets() {
        return buckets;
    }

    public void setBuckets(int buckets) {
        this.buckets = buckets;
    }

    public List!SQLColumnDefinition getPartitionColumns() {
        return partitionColumns;
    }

    public void addPartitionColumn(SQLColumnDefinition column) {
        if (column !is null) {
            column.setParent(this);
        }
        this.partitionColumns.add(column);
    }

    public SQLExternalRecordFormat getRowFormat() {
        return rowFormat;
    }

    public void setRowFormat(SQLExternalRecordFormat x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.rowFormat = x;
    }

    public bool isPrimaryColumn(long columnNameHash) {
        SQLPrimaryKey pk = this.findPrimaryKey();
        if (pk is null) {
            return false;
        }

        return pk.containsColumn(columnNameHash);
    }
}
