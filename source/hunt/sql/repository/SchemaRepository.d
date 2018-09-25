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
module hunt.sql.repository.SchemaRepository;

import std.exception;
import hunt.sql.SQLUtils;
import hunt.sql.ast;
import hunt.sql.ast.expr.SQLAllColumnExpr;
import hunt.sql.ast.expr.SQLIdentifierExpr;
import hunt.sql.ast.expr.SQLPropertyExpr;
import hunt.sql.ast.statement;
import hunt.sql.dialect.mysql.ast.statement;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitorAdapter;
import hunt.sql.repository.SchemaResolveVisitorFactory;
// import hunt.sql.dialect.oracle.ast.stmt.OracleCreateTableStatement;
// import hunt.sql.dialect.oracle.visitor.OracleASTVisitorAdapter;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.visitor.SQLASTVisitorAdapter;
// import hunt.sql.support.logging.Log;
// import hunt.sql.support.logging.LogFactory;
import hunt.sql.util.DBType;
import hunt.logging;
import hunt.sql.repository.SchemaObjectType;
import hunt.sql.repository.Schema;
import hunt.sql.repository.SchemaObject;
import hunt.sql.repository.SchemaResolveVisitor;
import hunt.container;
import std.uni;
import hunt.sql.repository.SchemaObjectImpl;
import hunt.math;
/**
 * Created by wenshao on 03/06/2017.
 */
public class SchemaRepository {
    // private static Log LOG = LogFactory.getLog(SchemaRepository.class);
    private Schema defaultSchema;
    protected string dbType;
    protected SQLASTVisitor consoleVisitor;

    public this() {
        schemas = new LinkedHashMap!(string, Schema)();
    }

    public this(string dbType) {
        this();
        this.dbType = dbType;

        if (DBType.MYSQL.opEquals(dbType)) {
            consoleVisitor = new MySqlConsoleSchemaVisitor();
        } else if (DBType.ORACLE.opEquals(dbType)) {
            // consoleVisitor = new OracleConsoleSchemaVisitor();
        } else {
            consoleVisitor = new DefaultConsoleSchemaVisitor();
        }
    }

    private Map!(string, Schema) schemas;

    public string getDbType() {
        return dbType;
    }

    public string getDefaultSchemaName() {
        return getDefaultSchema().getName();
    }

    public void setDefaultSchema(string name) {
        if (name is null) {
            defaultSchema = null;
            return;
        }

        string normalizedName = toLower(SQLUtils.normalize(name));

        Schema defaultSchema = schemas.get(normalizedName);
        if (defaultSchema !is null) {
            this.defaultSchema = defaultSchema;
            return;
        }

        if (defaultSchema is null) {
            if (this.defaultSchema !is null
                    && this.defaultSchema.getName() is null) {
                this.defaultSchema.setName(name);

                schemas.put(normalizedName, this.defaultSchema);
                return;
            }

            defaultSchema = new Schema(this);
            defaultSchema.setName(name);
            schemas.put(normalizedName, defaultSchema);
            this.defaultSchema = defaultSchema;
        }
    }

    public Schema findSchema(string schema) {
        return findSchema(schema, false);
    }

    protected Schema findSchema(string name, bool create) {
        if (name is null || name.length == 0) {
            return getDefaultSchema();
        }

        name = SQLUtils.normalize(name);
        string normalizedName = toLower(name);

        if (getDefaultSchema() !is null && defaultSchema.getName() is null) {
            defaultSchema.setName(name);
            schemas.put(normalizedName, defaultSchema);
            return defaultSchema;
        }

        Schema schema = schemas.get(normalizedName);
        if (schema is null) {
            schema = new Schema(this, name);
            schemas.put(normalizedName, schema);
        }
        return schema;
    }

    public Schema getDefaultSchema() {
        if (defaultSchema is null) {
            defaultSchema = new Schema(this);
        }

        return defaultSchema;
    }

    public void setDefaultSchema(Schema schema) {
        this.defaultSchema = schema;
    }

    public SchemaObject findTable(string tableName) {
        return getDefaultSchema().findTable(tableName);
    }

    public SchemaObject findTableOrView(string tableName) {
        return findTableOrView(tableName, true);
    }

    public SchemaObject findTableOrView(string tableName, bool onlyCurrent) {
        Schema schema = getDefaultSchema();

        SchemaObject object = schema.findTableOrView(tableName);
        if (object !is null) {
            return object;
        }

        foreach(Schema s ; this.schemas.values()) {
            if (s == schema) {
                continue;
            }

            object = schema.findTableOrView(tableName);
            if (object !is null) {
                return object;
            }
        }

        return null;
    }

    public Schema[] getSchemas() {
        return schemas.values();
    }

    public SchemaObject findFunction(string functionName) {
        return getDefaultSchema().findFunction(functionName);
    }

    public void acceptDDL(string ddl) {
        acceptDDL(ddl, dbType);
    }

    public void acceptDDL(string ddl, string dbType) {
        List!(SQLStatement) stmtList = SQLUtils.parseStatements(ddl, dbType);
        foreach(SQLStatement stmt ; stmtList) {
            accept(stmt);
        }
    }

    public void accept(SQLStatement stmt) {
        stmt.accept(consoleVisitor);
    }

    public bool isSequence(string name) {
        return getDefaultSchema().isSequence(name);
    }

    public SchemaObject findTable(SQLTableSource tableSource, string _alias) {
        return getDefaultSchema().findTable(tableSource, _alias);
    }

    public SQLColumnDefinition findColumn(SQLTableSource tableSource, SQLSelectItem selectItem) {
        return getDefaultSchema().findColumn(tableSource, selectItem);
    }

    public SQLColumnDefinition findColumn(SQLTableSource tableSource, SQLExpr expr) {
        return getDefaultSchema().findColumn(tableSource, expr);
    }

    public SchemaObject findTable(SQLTableSource tableSource, SQLSelectItem selectItem) {
        return getDefaultSchema().findTable(tableSource, selectItem);
    }

    public SchemaObject findTable(SQLTableSource tableSource, SQLExpr expr) {
        return getDefaultSchema().findTable(tableSource, expr);
    }

    public Map!(string, SchemaObject) getTables(SQLTableSource x) {
        return getDefaultSchema().getTables(x);
    }

    public int getTableCount() {
        return getDefaultSchema().getTableCount();
    }

    public SchemaObject[] getObjects() {
        return getDefaultSchema().getObjects();
    }

    public int getViewCount() {
        return getDefaultSchema().getViewCount();
    }

    public void resolve(SQLSelectStatement stmt, SchemaResolveVisitor.Option[] options...) {
        if (stmt is null) {
            return;
        }

        SchemaResolveVisitor resolveVisitor = createResolveVisitor(options);
        resolveVisitor.visit(stmt);
    }

    public void resolve(SQLStatement stmt, SchemaResolveVisitor.Option[] options...) {
        if (stmt is null) {
            return;
        }

        SchemaResolveVisitor resolveVisitor = createResolveVisitor(options);
        stmt.accept(resolveVisitor);
    }

    private SchemaResolveVisitor createResolveVisitor(SchemaResolveVisitor.Option[] options...) {
        int optionsValue = SchemaResolveVisitor.Option.of(options);

        SchemaResolveVisitor resolveVisitor;
        if (DBType.MYSQL.opEquals(dbType)
                || DBType.SQLITE.opEquals(dbType)) {
            resolveVisitor = new SchemaResolveVisitorFactory.MySqlResolveVisitor(this, optionsValue);
        } else if (DBType.ORACLE.opEquals(dbType)) {
            // resolveVisitor = new SchemaResolveVisitorFactory.OracleResolveVisitor(this, optionsValue);
        } else if (DBType.DB2.opEquals(dbType)) {
            // resolveVisitor = new SchemaResolveVisitorFactory.DB2ResolveVisitor(this, optionsValue);
        } else if (DBType.ODPS.opEquals(dbType)) {
            // resolveVisitor = new SchemaResolveVisitorFactory.OdpsResolveVisitor(this, optionsValue);
        } else if (DBType.HIVE.opEquals(dbType)) {
            // resolveVisitor = new SchemaResolveVisitorFactory.HiveResolveVisitor(this, optionsValue);
        } else if (DBType.POSTGRESQL.opEquals(dbType)) {
            resolveVisitor = new SchemaResolveVisitorFactory.PGResolveVisitor(this, optionsValue);
        } else if (DBType.SQL_SERVER.opEquals(dbType)) {
            // resolveVisitor = new SchemaResolveVisitorFactory.SQLServerResolveVisitor(this, optionsValue);
        } else {
            // resolveVisitor = new SchemaResolveVisitorFactory.SQLResolveVisitor(this, optionsValue);
        }
        return resolveVisitor;
    }

    public string resolve(string input) {
        SchemaResolveVisitor visitor
                = createResolveVisitor(
                    SchemaResolveVisitor.Option.ResolveAllColumn,
                    SchemaResolveVisitor.Option.ResolveIdentifierAlias);

        List!(SQLStatement) stmtList = SQLUtils.parseStatements(input, dbType);

        foreach(SQLStatement stmt ; stmtList) {
            stmt.accept(visitor);
        }

        return SQLUtils.toSQLString(stmtList, dbType);
    }

    public string console(string input) {
        try {
            StringBuffer buf = new StringBuffer();

            List!(SQLStatement) stmtList = SQLUtils.parseStatements(input, dbType);

            foreach(SQLStatement stmt ; stmtList) {
                if (cast(MySqlShowColumnsStatement)(stmt) !is null) {
                    MySqlShowColumnsStatement showColumns = (cast(MySqlShowColumnsStatement) stmt);
                    SQLName db = showColumns.getDatabase();
                    Schema schema;
                    if (db is null) {
                        schema = getDefaultSchema();
                    } else {
                        schema = findSchema(db.getSimpleName());
                    }

                    SQLName table = null;
                    SchemaObject schemaObject = null;
                    if (schema !is null) {
                        table = showColumns.getTable();
                        schemaObject = schema.findTable(table.nameHashCode64());
                    }

                    if (schemaObject is null) {
                        buf.append("ERROR 1146 (42S02): Table '" ~ table.stringof ~ "' doesn't exist\n");
                    } else {
                        MySqlCreateTableStatement createTableStmt = cast(MySqlCreateTableStatement) schemaObject.getStatement();
                        createTableStmt.showCoumns(buf);
                    }
                } else if (cast(MySqlShowCreateTableStatement)(stmt) !is null) {
                    MySqlShowCreateTableStatement showCreateTableStmt = cast(MySqlShowCreateTableStatement) stmt;
                    SQLName table = showCreateTableStmt.getName();
                    SchemaObject schemaObject = findTable(table);
                    if (schemaObject is null) {
                        buf.append("ERROR 1146 (42S02): Table '" ~ table.stringof ~ "' doesn't exist\n");
                    } else {
                        MySqlCreateTableStatement createTableStmt = cast(MySqlCreateTableStatement) schemaObject.getStatement();
                        createTableStmt.output(buf);
                    }
                } else if (cast(MySqlRenameTableStatement)(stmt) !is null) {
                    MySqlRenameTableStatement renameStmt = cast(MySqlRenameTableStatement) stmt;
                    foreach(MySqlRenameTableStatement.Item item ; renameStmt.getItems()) {
                        renameTable(item.getName(), item.getTo());
                    }
                } else if (cast(SQLShowTablesStatement)(stmt) !is null) {
                    SQLShowTablesStatement showTables = cast(SQLShowTablesStatement) stmt;
                    SQLName database = showTables.getDatabase();

                    Schema schema;
                    if (database is null) {
                        schema = getDefaultSchema();
                    } else {
                        schema = findSchema(database.getSimpleName());
                    }
                    if (schema !is null) {
                        foreach(string table ; schema.showTables()) {
                            buf.append(table);
                            buf.append('\n');
                        }
                    }
                } else {
                    stmt.accept(consoleVisitor);
                }
            }

            if (buf.length == 0) {
                return "\n";
            }

            return buf.toString();
        } catch (Exception ex) {
            throw new Exception("exeucte command error.", ex);
        }
    }

    public SchemaObject findTable(SQLName name) {
        if (cast(SQLIdentifierExpr)(name) !is null) {
            return findTable((cast(SQLIdentifierExpr) name).getName());
        }

        if (cast(SQLPropertyExpr)(name) !is null) {
            SQLPropertyExpr propertyExpr = cast(SQLPropertyExpr) name;
            string schema = propertyExpr.getOwnernName();
            long tableHashCode64 = propertyExpr.nameHashCode64();

            Schema schemaObj = findSchema(schema);
            if (schemaObj is null) {
                return null;
            }

            return schemaObj.findTable(tableHashCode64);
        }

        return null;
    }

    private bool renameTable(SQLName name, SQLName to) {
        Schema schema;
        if (cast(SQLPropertyExpr)(name) !is null) {
            string schemaName = (cast(SQLPropertyExpr) name).getOwnernName();
            schema = findSchema(schemaName);
        } else {
            schema = getDefaultSchema();
        }

        if (schema is null) {
            return false;
        }

        long nameHashCode64 = name.nameHashCode64();
        SchemaObject schemaObject = schema.findTable(nameHashCode64);
        if (schemaObject !is null) {
            MySqlCreateTableStatement createTableStmt = cast(MySqlCreateTableStatement) schemaObject.getStatement();
            if (createTableStmt !is null) {
                createTableStmt.setName(to.clone());
            }

            schema.objects.put(new Long(to.hashCode64()), schemaObject);
            schema.objects.remove(new Long(nameHashCode64));
        }
        return true;
    }


    public SchemaObject findTable(SQLExprTableSource x) {
        if (x is null) {
            return null;
        }

        SQLExpr expr = x.getExpr();
        if (cast(SQLName)(expr) !is null) {
            return findTable(cast(SQLName) expr);
        }

        return null;
    }

    public class MySqlConsoleSchemaVisitor : MySqlASTVisitorAdapter {
        alias endVisit = MySqlASTVisitorAdapter.endVisit;
      alias visit = MySqlASTVisitorAdapter.visit;
        override public bool visit(SQLDropSequenceStatement x) {
            acceptDropSequence(x);
            return false;
        }

        override public bool visit(SQLCreateSequenceStatement x) {
            acceptCreateSequence(x);
            return false;
        }

        override public bool visit(MySqlCreateTableStatement x) {
            acceptCreateTable(x);
            return false;
        }

        override public bool visit(SQLCreateTableStatement x) {
            acceptCreateTable(x);
            return false;
        }

        override public bool visit(SQLDropTableStatement x) {
            acceptDropTable(x);
            return false;
        }

        override public bool visit(SQLCreateViewStatement x) {
            acceptView(x);
            return false;
        }

        override public bool visit(SQLAlterViewStatement x) {
            acceptView(x);
            return false;
        }

        override public bool visit(SQLCreateIndexStatement x) {
            acceptCreateIndex(x);
            return false;
        }

        override public bool visit(SQLCreateFunctionStatement x) {
            acceptCreateFunction(x);
            return false;
        }

        override public bool visit(SQLAlterTableStatement x) {
            acceptAlterTable(x);
            return false;
        }

        override public bool visit(SQLUseStatement x) {
            string schema = x.getDatabase().getSimpleName();
            setDefaultSchema(schema);
            return false;
        }

        override public bool visit(SQLDropIndexStatement x) {
            acceptDropIndex(x);
            return false;
        }
    }

    // public class OracleConsoleSchemaVisitor : OracleASTVisitorAdapter {
    //     public bool visit(SQLDropSequenceStatement x) {
    //         acceptDropSequence(x);
    //         return false;
    //     }

    //     public bool visit(SQLCreateSequenceStatement x) {
    //         acceptCreateSequence(x);
    //         return false;
    //     }

    //     public bool visit(OracleCreateTableStatement x) {
    //         visit(cast(SQLCreateTableStatement) x);
    //         return false;
    //     }

    //     public bool visit(SQLCreateTableStatement x) {
    //         acceptCreateTable(x);
    //         return false;
    //     }

    //     public bool visit(SQLDropTableStatement x) {
    //         acceptDropTable(x);
    //         return false;
    //     }

    //     public bool visit(SQLCreateViewStatement x) {
    //         acceptView(x);
    //         return false;
    //     }

    //     public bool visit(SQLAlterViewStatement x) {
    //         acceptView(x);
    //         return false;
    //     }

    //     public bool visit(SQLCreateIndexStatement x) {
    //         acceptCreateIndex(x);
    //         return false;
    //     }

    //     public bool visit(SQLCreateFunctionStatement x) {
    //         acceptCreateFunction(x);
    //         return false;
    //     }

    //     public bool visit(SQLAlterTableStatement x) {
    //         acceptAlterTable(x);
    //         return false;
    //     }

    //     public bool visit(SQLUseStatement x) {
    //         string schema = x.getDatabase().getSimpleName();
    //         setDefaultSchema(schema);
    //         return false;
    //     }

    //     public bool visit(SQLDropIndexStatement x) {
    //         acceptDropIndex(x);
    //         return false;
    //     }
    // }

    public class DefaultConsoleSchemaVisitor : SQLASTVisitorAdapter {

        alias endVisit = SQLASTVisitorAdapter.endVisit;
        alias visit = SQLASTVisitorAdapter.visit;

        override public bool visit(SQLDropSequenceStatement x) {
            acceptDropSequence(x);
            return false;
        }

        override public bool visit(SQLCreateSequenceStatement x) {
            acceptCreateSequence(x);
            return false;
        }

        override public bool visit(SQLCreateTableStatement x) {
            acceptCreateTable(x);
            return false;
        }

        override public bool visit(SQLDropTableStatement x) {
            acceptDropTable(x);
            return false;
        }

        override public bool visit(SQLCreateViewStatement x) {
            acceptView(x);
            return false;
        }

        override public bool visit(SQLAlterViewStatement x) {
            acceptView(x);
            return false;
        }

        override public bool visit(SQLCreateIndexStatement x) {
            acceptCreateIndex(x);
            return false;
        }

        override public bool visit(SQLCreateFunctionStatement x) {
            acceptCreateFunction(x);
            return false;
        }

        override public bool visit(SQLAlterTableStatement x) {
            acceptAlterTable(x);
            return false;
        }

        override public bool visit(SQLDropIndexStatement x) {
            acceptDropIndex(x);
            return false;
        }
    }

    bool acceptCreateTable(MySqlCreateTableStatement x) {
        SQLExprTableSource like = x.getLike();
        if (like !is null) {
            SchemaObject table = findTable(cast(SQLName) like.getExpr());
            if (table !is null) {
                MySqlCreateTableStatement stmt = cast(MySqlCreateTableStatement) table.getStatement();
                MySqlCreateTableStatement stmtCloned = stmt.clone();
                stmtCloned.setName(x.getName().clone());
                acceptCreateTable(cast(SQLCreateTableStatement) stmtCloned);
                return false;
            }
        }

        return acceptCreateTable(cast(SQLCreateTableStatement) x);
    }

    bool acceptCreateTable(SQLCreateTableStatement x) {
        SQLCreateTableStatement x1 = x.clone();
        string schemaName = x1.getSchema();

        Schema schema = findSchema(schemaName, true);

        SQLSelect select = x1.getSelect();
        if (select !is null) {
            select.accept(createResolveVisitor(SchemaResolveVisitor.Option.ResolveAllColumn));

            SQLSelectQueryBlock queryBlock = select.getFirstQueryBlock();
            if (queryBlock !is null) {
                List!(SQLSelectItem) selectList = queryBlock.getSelectList();
                foreach(SQLSelectItem selectItem ; selectList) {
                    SQLExpr selectItemExpr = selectItem.getExpr();
                    if (cast(SQLAllColumnExpr)(selectItemExpr) !is null
                            || (cast(SQLPropertyExpr)(selectItemExpr) !is null && (cast(SQLPropertyExpr) selectItemExpr).getName() == ("*"))) {
                        continue;
                    }

                    string name = selectItem.computeAlias();
                    SQLDataType dataType = selectItem.computeDataType();
                    SQLColumnDefinition column = new SQLColumnDefinition();
                    column.setName(name);
                    column.setDataType(dataType);
                    column.setDbType(dbType);
                    x1.getTableElementList().add(column);
                }
                if (x1.getTableElementList().size() > 0) {
                    x1.setSelect(null);
                }
            }
        }

        SQLExprTableSource like = x1.getLike();
        if (like !is null) {
            SchemaObject tableObject = null;

            SQLName name = like.getName();
            if (name !is null) {
                tableObject = findTable(name);
            }

            SQLCreateTableStatement tableStmt = null;
            if (tableObject !is null) {
                SQLStatement stmt = tableObject.getStatement();
                if (cast(SQLCreateTableStatement)(stmt) !is null) {
                    tableStmt = cast(SQLCreateTableStatement) stmt;
                }
            }

            if (tableStmt !is null) {
                SQLName tableName = x1.getName();
                tableStmt.cloneTo(x1);
                x1.setName(tableName);
                x1.setLike(cast(SQLExprTableSource) null);
            }
        }

        x1.setSchema(null);

        string name = x1.computeName();
        SchemaObject table = schema.findTableOrView(name);
        if (table !is null) {
            logInfo("replaced table '" ~ name ~ "'");
        }

        table = new SchemaObjectImpl(name, SchemaObjectType.Table, x1);
        schema.objects.put(new Long(table.nameHashCode64()), table);
        return true;
    }

    bool acceptDropTable(SQLDropTableStatement x) {
        foreach(SQLExprTableSource table ; x.getTableSources()) {
            string schemaName = table.getSchema();
            Schema schema = findSchema(schemaName, false);
            if (schema is null) {
                continue;
            }
            long nameHashCode64 = table.getName().nameHashCode64();
            schema.objects.remove(new Long(nameHashCode64));
        }
        return true;
    }

    bool acceptView(SQLCreateViewStatement x) {
        string schemaName = x.getSchema();

        Schema schema = findSchema(schemaName, true);

        string name = x.computeName();
        SchemaObject view = schema.findTableOrView(name);
        if (view !is null) {
            return false;
        }

        SchemaObject object = new SchemaObjectImpl(name, SchemaObjectType.View, x.clone());
        schema.objects.put(new Long(object.nameHashCode64()), object);
        return true;
    }

    bool acceptView(SQLAlterViewStatement x) {
        string schemaName = x.getSchema();

        Schema schema = findSchema(schemaName, true);

        string name = x.computeName();
        SchemaObject view = schema.findTableOrView(name);
        if (view !is null) {
            return false;
        }

        SchemaObject object = new SchemaObjectImpl(name, SchemaObjectType.View, x.clone());
        schema.objects.put(new Long(object.nameHashCode64()), object);
        return true;
    }

    bool acceptDropIndex(SQLDropIndexStatement x) {
        SQLName table = x.getTableName().getName();
        SchemaObject object = findTable(table);

        if (object !is null) {
            SQLCreateTableStatement stmt = cast(SQLCreateTableStatement) object.getStatement();
            if (stmt !is null) {
                stmt.apply(x);
                return true;
            }
        }

        return false;
    }

    bool acceptCreateIndex(SQLCreateIndexStatement x) {
        string schemaName = x.getSchema();

        Schema schema = findSchema(schemaName, true);

        string name = x.getName().getSimpleName();
        SchemaObject object = new SchemaObjectImpl(name, SchemaObjectType.Index, x.clone());
        schema.objects.put(new Long(object.nameHashCode64()), object);

        return true;
    }

    bool acceptCreateFunction(SQLCreateFunctionStatement x) {
        string schemaName = x.getSchema();
        Schema schema = findSchema(schemaName, true);

        string name = x.getName().getSimpleName();
        SchemaObject object = new SchemaObjectImpl(name, SchemaObjectType.Function, x.clone());
        schema._functions.put(new Long(object.nameHashCode64()), object);

        return true;
    }

    bool acceptAlterTable(SQLAlterTableStatement x) {
        string schemaName = x.getSchema();
        Schema schema = findSchema(schemaName, true);

        SchemaObject object = schema.findTable(x.nameHashCode64());
        if (object !is null) {
            SQLCreateTableStatement stmt = cast(SQLCreateTableStatement) object.getStatement();
            if (stmt !is null) {
                stmt.apply(x);
                return true;
            }
        }

        return false;
    }

    public bool acceptCreateSequence(SQLCreateSequenceStatement x) {
        string schemaName = x.getSchema();
        Schema schema = findSchema(schemaName, true);

        string name = x.getName().getSimpleName();
        SchemaObject object = new SchemaObjectImpl(name, SchemaObjectType.Sequence);
        schema.objects.put(new Long(object.nameHashCode64()), object);
        return false;
    }

    public bool acceptDropSequence(SQLDropSequenceStatement x) {
        string schemaName = x.getSchema();
        Schema schema = findSchema(schemaName, true);

        long nameHashCode64 = x.getName().nameHashCode64();
        schema.objects.remove(new Long(nameHashCode64));
        return false;
    }
}
