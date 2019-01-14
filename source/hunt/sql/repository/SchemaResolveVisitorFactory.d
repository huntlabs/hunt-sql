/*
 * Copyright 2015-2018 HuntLabs.cn
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance _with the License.
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
module hunt.sql.repository.SchemaResolveVisitorFactory;

import hunt.sql.SQLUtils;
import hunt.sql.ast;
import hunt.sql.ast.expr;
import hunt.sql.ast.statement;
// import hunt.sql.dialect.db2.ast.DB2Object;
// import hunt.sql.dialect.db2.ast.stmt.DB2SelectQueryBlock;
// import hunt.sql.dialect.db2.visitor.DB2ASTVisitorAdapter;
// import hunt.sql.dialect.hive.ast.HiveInsert;
// import hunt.sql.dialect.hive.ast.HiveMultiInsertStatement;
// import hunt.sql.dialect.hive.visitor.HiveASTVisitorAdapter;
import hunt.sql.dialect.mysql.ast.MysqlForeignKey;
import hunt.sql.dialect.mysql.ast.clause.MySqlCursorDeclareStatement;
import hunt.sql.dialect.mysql.ast.clause.MySqlDeclareStatement;
import hunt.sql.dialect.mysql.ast.clause.MySqlRepeatStatement;
import hunt.sql.dialect.mysql.ast.statement;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitorAdapter;
// import hunt.sql.dialect.odps.ast;
// import hunt.sql.dialect.odps.visitor.OdpsASTVisitorAdapter;
// import hunt.sql.dialect.oracle.ast.stmt;
// import hunt.sql.dialect.oracle.visitor.OracleASTVisitorAdapter;
import hunt.sql.dialect.postgresql.ast.stmt;
import hunt.sql.dialect.postgresql.visitor.PGASTVisitorAdapter;
// import hunt.sql.dialect.sqlserver.ast.SQLServerSelectQueryBlock;
// import hunt.sql.dialect.sqlserver.ast.stmt.SQLServerInsertStatement;
// import hunt.sql.dialect.sqlserver.ast.stmt.SQLServerUpdateStatement;
// import hunt.sql.dialect.sqlserver.visitor.SQLServerASTVisitorAdapter;
import hunt.sql.visitor.SQLASTVisitorAdapter;
import hunt.sql.util.FnvHash;
import hunt.sql.util.PGUtils;
import hunt.sql.repository.SchemaResolveVisitor;
import hunt.sql.repository.SchemaRepository;
import hunt.sql.repository.SchemaObject;
import hunt.collection;
// import hunt.util.Argument;


class SchemaResolveVisitorFactory {
    static class MySqlResolveVisitor : MySqlASTVisitorAdapter , SchemaResolveVisitor {

        alias endVisit = MySqlASTVisitorAdapter.endVisit;
        alias visit = MySqlASTVisitorAdapter.visit;

        private SchemaRepository repository;
        private int options;
        private SchemaResolveVisitor.Context context;

        public this(SchemaRepository repository, int options) {
            this.repository = repository;
            this.options = options;
        }

        override  public bool visit(SQLSelectStatement x) {
            resolve(this, x.getSelect());
            return false;
        }

        override  public bool visit(MySqlRepeatStatement x) {
            return true;
        }

        override public bool visit(MySqlDeclareStatement x) {
            foreach(SQLDeclareItem declareItem ; x.getVarList()) {
                visit(declareItem);
            }
            return false;
        }

        override public bool visit(MySqlCursorDeclareStatement x) {
            return true;
        }

        override public bool visit(MysqlForeignKey x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLExprTableSource x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(MySqlSelectQueryBlock x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLSelectQueryBlock x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLSelectItem x) {
            SQLExpr expr = x.getExpr();
            if (cast(SQLIdentifierExpr)(expr) !is null) {
                resolve(this, cast(SQLIdentifierExpr) expr);
                return false;
            }

            if (cast(SQLPropertyExpr)(expr) !is null) {
                resolve(this, cast(SQLPropertyExpr) expr);
                return false;
            }

            return true;
        }

        override public bool visit(SQLIdentifierExpr x) {
            resolve(this, x);
            return true;
        }

        override public bool visit(SQLPropertyExpr x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLAllColumnExpr x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(MySqlCreateTableStatement x) {
            resolve(this, x);
            SQLExprTableSource like = x.getLike();
            if (like !is null) {
                like.accept(this);
            }
            return false;
        }

        override public bool visit(MySqlUpdateStatement x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(MySqlDeleteStatement x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLSelect x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLWithSubqueryClause x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLAlterTableStatement x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(MySqlInsertStatement x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLInsertStatement x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLReplaceStatement x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLMergeStatement x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLCreateProcedureStatement x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLBlockStatement x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLParameter x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLDeclareItem x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLOver x) {
            resolve(this, x);
            return false;
        }

        override
        public bool isEnabled(Option option) {
            return (options & option.mask) != 0;
        }

        override
        public Context getContext() {
            return context;
        }

        public Context createContext(SQLObject object) {
            return this.context = new Context(object, context);
        }

        override
        public void popContext() {
            if (context !is null) {
                context = context.parent;
            }
        }

        public SchemaRepository getRepository() {
            return repository;
        }
    }

    // static class DB2ResolveVisitor : DB2ASTVisitorAdapter , SchemaResolveVisitor {
    //     private SchemaRepository repository;
    //     private int options;
    //     private Context context;

    //     public DB2ResolveVisitor(SchemaRepository repository, int options) {
    //         this.repository = repository;
    //         this.options = options;
    //     }

    //     override public bool visit(SQLForeignKeyImpl x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLSelectStatement x) {
    //         resolve(this, x.getSelect());
    //         return false;
    //     }

    //     override public bool visit(SQLExprTableSource x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLSelectQueryBlock x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(DB2SelectQueryBlock x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLSelectItem x) {
    //         SQLExpr expr = x.getExpr();
    //         if (cast(SQLIdentifierExpr)(expr) !is null) {
    //             resolve(this, (SQLIdentifierExpr) expr);
    //             return false;
    //         }

    //         if (cast(SQLPropertyExpr)(expr) !is null) {
    //             resolve(this, (SQLPropertyExpr) expr);
    //             return false;
    //         }

    //         return true;
    //     }

    //     override public bool visit(SQLIdentifierExpr x) {
    //         long hash64 = x.hashCode64();
    //         if (hash64 == DB2Object.Constants.CURRENT_DATE || hash64 == DB2Object.Constants.CURRENT_TIME) {
    //             return false;
    //         }

    //         resolve(this, x);
    //         return true;
    //     }

    //     override public bool visit(SQLPropertyExpr x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLAllColumnExpr x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLCreateTableStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLUpdateStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLDeleteStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLSelect x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLWithSubqueryClause x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLAlterTableStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLInsertStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLMergeStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLCreateProcedureStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLBlockStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLParameter x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLDeclareItem x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLOver x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override
    //     public bool isEnabled(Option option) {
    //         return (options & option.mask) != 0;
    //     }

    //     override
    //     public Context getContext() {
    //         return context;
    //     }

    //     public Context createContext(SQLObject object) {
    //         return this.context = new Context(object, context);
    //     }

    //     override
    //     public void popContext() {
    //         if (context !is null) {
    //             context = context.parent;
    //         }
    //     }

    //     override
    //     public SchemaRepository getRepository() {
    //         return repository;
    //     }
    // }

    // static class OracleResolveVisitor : OracleASTVisitorAdapter , SchemaResolveVisitor {
    //     private SchemaRepository repository;
    //     private int options;
    //     private Context context;

    //     public OracleResolveVisitor(SchemaRepository repository, int options) {
    //         this.repository = repository;
    //         this.options = options;
    //     }

    //     override public bool visit(SQLSelectStatement x) {
    //         resolve(this, x.getSelect());
    //         return false;
    //     }

    //     override public bool visit(OracleCreatePackageStatement x) {
    //         Context ctx = createContext(x);

    //         foreach(SQLStatement stmt ; x.getStatements()) {
    //             stmt.accept(this);
    //         }

    //         popContext();
    //         return false;
    //     }

    //     override public bool visit(OracleForStatement x) {
    //         Context ctx = createContext(x);

    //         SQLName index = x.getIndex();
    //         SQLExpr range = x.getRange();

    //         if (index !is null) {
    //             SQLDeclareItem declareItem = new SQLDeclareItem(index, null);
    //             declareItem.setParent(x);

    //             if (cast(SQLIdentifierExpr)(index) !is null) {
    //                 (cast(SQLIdentifierExpr) index).setResolvedDeclareItem(declareItem);
    //             }
    //             declareItem.setResolvedObject(range);
    //             ctx.declare(declareItem);
    //             if (cast(SQLQueryExpr)(range) !is null) {
    //                 SQLSelect select = (cast(SQLQueryExpr) range).getSubQuery();
    //                 SQLSubqueryTableSource tableSource = new SQLSubqueryTableSource(select);
    //                 declareItem.setResolvedObject(tableSource);
    //             }

    //             index.accept(this);
    //         }


    //         if (range !is null) {
    //             range.accept(this);
    //         }

    //         foreach(SQLStatement stmt ; x.getStatements()) {
    //             stmt.accept(this);
    //         }

    //         popContext();
    //         return false;
    //     }

    //     override public bool visit(OracleForeignKey x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLIfStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLCreateFunctionStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(OracleSelectTableReference x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLExprTableSource x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLSelectQueryBlock x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(OracleSelectQueryBlock x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLSelectItem x) {
    //         SQLExpr expr = x.getExpr();
    //         if (cast(SQLIdentifierExpr)(expr) !is null) {
    //             resolve(this, (SQLIdentifierExpr) expr);
    //             return false;
    //         }

    //         if (cast(SQLPropertyExpr)(expr) !is null) {
    //             resolve(this, (SQLPropertyExpr) expr);
    //             return false;
    //         }

    //         return true;
    //     }

    //     override public bool visit(SQLIdentifierExpr x) {
    //         if (x.nameHashCode64() == FnvHash.Constants.ROWNUM) {
    //             return false;
    //         }

    //         resolve(this, x);
    //         return true;
    //     }

    //     override public bool visit(SQLPropertyExpr x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLAllColumnExpr x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLCreateTableStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(OracleCreateTableStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLUpdateStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(OracleUpdateStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLDeleteStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(OracleDeleteStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLSelect x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLWithSubqueryClause x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLInsertStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(OracleMultiInsertStatement x) {
    //         Context ctx = createContext(x);

    //         SQLSelect select = x.getSubQuery();
    //         visit(select);

    //         OracleSelectSubqueryTableSource tableSource = new OracleSelectSubqueryTableSource(select);
    //         tableSource.setParent(x);
    //         ctx.setTableSource(tableSource);

    //         foreach(OracleMultiInsertStatement.Entry entry ; x.getEntries()) {
    //             entry.accept(this);
    //         }

    //         popContext();
    //         return false;
    //     }

    //     override public bool visit(OracleMultiInsertStatement.InsertIntoClause x) {
    //         foreach(SQLExpr column ; x.getColumns()) {
    //             if (cast(SQLIdentifierExpr)(column) !is null) {
    //                 SQLIdentifierExpr identColumn = cast(SQLIdentifierExpr) column;
    //                 identColumn.setResolvedTableSource(x.getTableSource());
    //             }
    //         }
    //         return true;
    //     }

    //     override public bool visit(OracleInsertStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLAlterTableStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLMergeStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLCreateProcedureStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLBlockStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLParameter x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLDeclareItem x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLOver x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLFetchStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override
    //     public bool isEnabled(Option option) {
    //         return (options & option.mask) != 0;
    //     }

    //     override
    //     public Context getContext() {
    //         return context;
    //     }

    //     public Context createContext(SQLObject object) {
    //         return this.context = new Context(object, context);
    //     }

    //     override
    //     public void popContext() {
    //         if (context !is null) {
    //             context = context.parent;
    //         }
    //     }

    //     public SchemaRepository getRepository() {
    //         return repository;
    //     }
    // }

    // static class OdpsResolveVisitor : OdpsASTVisitorAdapter , SchemaResolveVisitor {
    //     private int options;
    //     private SchemaRepository repository;
    //     private Context context;

    //     public OdpsResolveVisitor(SchemaRepository repository, int options) {
    //         this.repository = repository;
    //         this.options = options;
    //     }

    //     override public bool visit(SQLForeignKeyImpl x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLSelectStatement x) {
    //         resolve(this, x.getSelect());
    //         return false;
    //     }

    //     override public bool visit(SQLExprTableSource x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLSelectQueryBlock x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(OdpsSelectQueryBlock x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLSelectItem x) {
    //         SQLExpr expr = x.getExpr();
    //         if (cast(SQLIdentifierExpr)(expr) !is null) {
    //             resolve(this, (SQLIdentifierExpr) expr);
    //             return false;
    //         }

    //         if (cast(SQLPropertyExpr)(expr) !is null) {
    //             resolve(this, (SQLPropertyExpr) expr);
    //             return false;
    //         }

    //         return true;
    //     }

    //     override public bool visit(SQLIdentifierExpr x) {
    //         resolve(this, x);
    //         return true;
    //     }

    //     override public bool visit(SQLPropertyExpr x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLAllColumnExpr x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLCreateTableStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(OdpsCreateTableStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLUpdateStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLDeleteStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLSelect x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLWithSubqueryClause x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(HiveInsert x) {
    //         Context ctx = createContext(x);

    //         SQLExprTableSource tableSource = x.getTableSource();
    //         if (tableSource !is null) {
    //             ctx.setTableSource(x.getTableSource());
    //             visit(tableSource);
    //         }

    //         foreach(SQLAssignItem item ; x.getPartitions()) {
    //             item.accept(this);
    //         }

    //         SQLSelect select = x.getQuery();
    //         if (select !is null) {
    //             visit(select);
    //         }

    //         popContext();
    //         return false;
    //     }

    //     override public bool visit(SQLInsertStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLAlterTableStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLMergeStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLCreateProcedureStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLBlockStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLParameter x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLDeclareItem x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLOver x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override
    //     public bool isEnabled(Option option) {
    //         return (options & option.mask) != 0;
    //     }

    //     override
    //     public Context getContext() {
    //         return context;
    //     }

    //     public Context createContext(SQLObject object) {
    //         return this.context = new Context(object, context);
    //     }

    //     override
    //     public void popContext() {
    //         if (context !is null) {
    //             context = context.parent;
    //         }
    //     }

    //     public SchemaRepository getRepository() {
    //         return repository;
    //     }
    // }

    // static class HiveResolveVisitor : HiveASTVisitorAdapter , SchemaResolveVisitor {
    //     private int options;
    //     private SchemaRepository repository;
    //     private Context context;

    //     public HiveResolveVisitor(SchemaRepository repository, int options) {
    //         this.repository = repository;
    //         this.options = options;
    //     }

    //     override public bool visit(SQLForeignKeyImpl x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLSelectStatement x) {
    //         resolve(this, x.getSelect());
    //         return false;
    //     }

    //     override public bool visit(SQLExprTableSource x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLSelectQueryBlock x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(OdpsSelectQueryBlock x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLSelectItem x) {
    //         SQLExpr expr = x.getExpr();
    //         if (cast(SQLIdentifierExpr)(expr) !is null) {
    //             resolve(this, (SQLIdentifierExpr) expr);
    //             return false;
    //         }

    //         if (cast(SQLPropertyExpr)(expr) !is null) {
    //             resolve(this, (SQLPropertyExpr) expr);
    //             return false;
    //         }

    //         return true;
    //     }

    //     override public bool visit(SQLIdentifierExpr x) {
    //         resolve(this, x);
    //         return true;
    //     }

    //     override public bool visit(SQLPropertyExpr x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLAllColumnExpr x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLCreateTableStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(OdpsCreateTableStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLUpdateStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLDeleteStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLSelect x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLWithSubqueryClause x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(HiveInsert x) {
    //         Context ctx = createContext(x);

    //         SQLExprTableSource tableSource = x.getTableSource();
    //         if (tableSource !is null) {
    //             ctx.setTableSource(x.getTableSource());
    //             visit(tableSource);
    //         }

    //         foreach(SQLAssignItem item ; x.getPartitions()) {
    //             item.accept(this);
    //         }

    //         SQLSelect select = x.getQuery();
    //         if (select !is null) {
    //             visit(select);
    //         }

    //         popContext();
    //         return false;
    //     }

    //     override public bool visit(SQLInsertStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLAlterTableStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLMergeStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLCreateProcedureStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLBlockStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLParameter x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLDeclareItem x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLOver x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override
    //     public bool isEnabled(Option option) {
    //         return (options & option.mask) != 0;
    //     }

    //     override
    //     public Context getContext() {
    //         return context;
    //     }

    //     public Context createContext(SQLObject object) {
    //         return this.context = new Context(object, context);
    //     }

    //     override
    //     public void popContext() {
    //         if (context !is null) {
    //             context = context.parent;
    //         }
    //     }

    //     public SchemaRepository getRepository() {
    //         return repository;
    //     }
    // }

    static class PGResolveVisitor : PGASTVisitorAdapter , SchemaResolveVisitor {

        alias endVisit = PGASTVisitorAdapter.endVisit;
        alias visit = PGASTVisitorAdapter.visit; 

        private int options;
        private SchemaRepository repository;
        private Context context;

        public this(SchemaRepository repository, int options) {
            this.repository = repository;
            this.options = options;
        }

        override public bool visit(SQLForeignKeyImpl x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLSelectStatement x) {
            resolve(this, x.getSelect());
            return false;
        }

        override public bool visit(SQLExprTableSource x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLSelectQueryBlock x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(PGSelectQueryBlock x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(PGFunctionTableSource x) {
            foreach(SQLParameter parameter ; x.getParameters()) {
                SQLName name = parameter.getName();
                if (cast(SQLIdentifierExpr)(name) !is null) {
                    SQLIdentifierExpr identName = cast(SQLIdentifierExpr) name;
                    identName.setResolvedTableSource(x);
                }
            }

            return false;
        }

        override public bool visit(SQLSelectItem x) {
            SQLExpr expr = x.getExpr();
            if (cast(SQLIdentifierExpr)(expr) !is null) {
                resolve(this, cast(SQLIdentifierExpr) expr);
                return false;
            }

            if (cast(SQLPropertyExpr)(expr) !is null) {
                resolve(this, cast(SQLPropertyExpr) expr);
                return false;
            }

            return true;
        }

        override public bool visit(SQLIdentifierExpr x) {
            if (PGUtils.isPseudoColumn(x.nameHashCode64())) {
                return false;
            }

            resolve(this, x);
            return true;
        }

        override public bool visit(SQLPropertyExpr x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLAllColumnExpr x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLCreateTableStatement x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLUpdateStatement x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(PGUpdateStatement x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLDeleteStatement x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(PGDeleteStatement x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(PGSelectStatement x) {
            createContext(x);
            visit(x.getSelect());
            popContext();
            return false;
        }

        override public bool visit(SQLSelect x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLWithSubqueryClause x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(PGInsertStatement x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLInsertStatement x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLAlterTableStatement x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLMergeStatement x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLCreateProcedureStatement x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLBlockStatement x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLParameter x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLDeclareItem x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLOver x) {
            resolve(this, x);
            return false;
        }

        override
        public bool isEnabled(Option option) {
            return (options & option.mask) != 0;
        }

        override
        public Context getContext() {
            return context;
        }

        public Context createContext(SQLObject object) {
            return this.context = new Context(object, context);
        }

        override
        public void popContext() {
            if (context !is null) {
                context = context.parent;
            }
        }

        public SchemaRepository getRepository() {
            return repository;
        }
    }

    // static class SQLServerResolveVisitor : SQLServerASTVisitorAdapter , SchemaResolveVisitor {
    //     private int options;
    //     private SchemaRepository repository;
    //     private Context context;

    //     public SQLServerResolveVisitor(SchemaRepository repository, int options) {
    //         this.repository = repository;
    //         this.options = options;
    //     }

    //     override public bool visit(SQLForeignKeyImpl x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLSelectStatement x) {
    //         resolve(this, x.getSelect());
    //         return false;
    //     }

    //     override public bool visit(SQLExprTableSource x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLSelectQueryBlock x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLServerSelectQueryBlock x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLSelectItem x) {
    //         SQLExpr expr = x.getExpr();
    //         if (cast(SQLIdentifierExpr)(expr) !is null) {
    //             resolve(this, (SQLIdentifierExpr) expr);
    //             return false;
    //         }

    //         if (cast(SQLPropertyExpr)(expr) !is null) {
    //             resolve(this, (SQLPropertyExpr) expr);
    //             return false;
    //         }

    //         return true;
    //     }

    //     override public bool visit(SQLIdentifierExpr x) {
    //         resolve(this, x);
    //         return true;
    //     }

    //     override public bool visit(SQLPropertyExpr x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLAllColumnExpr x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLCreateTableStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLUpdateStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLServerUpdateStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLDeleteStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLSelect x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLWithSubqueryClause x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLServerInsertStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLInsertStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLAlterTableStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLMergeStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLCreateProcedureStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLBlockStatement x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLParameter x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLDeclareItem x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override public bool visit(SQLOver x) {
    //         resolve(this, x);
    //         return false;
    //     }

    //     override
    //     public bool isEnabled(Option option) {
    //         return (options & option.mask) != 0;
    //     }

    //     override
    //     public Context getContext() {
    //         return context;
    //     }

    //     public Context createContext(SQLObject object) {
    //         return this.context = new Context(object, context);
    //     }

    //     override
    //     public void popContext() {
    //         if (context !is null) {
    //             context = context.parent;
    //         }
    //     }

    //     public SchemaRepository getRepository() {
    //         return repository;
    //     }
    // }

    static class SQLResolveVisitor : SQLASTVisitorAdapter , SchemaResolveVisitor {
        alias endVisit = SQLASTVisitorAdapter.endVisit;
        alias visit = SQLASTVisitorAdapter.visit; 
        private int options;
        private SchemaRepository repository;
        private Context context;

        public this(SchemaRepository repository, int options) {
            this.repository = repository;
            this.options = options;
        }

        override public bool visit(SQLForeignKeyImpl x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLSelectStatement x) {
            resolve(this, x.getSelect());
            return false;
        }

        override public bool visit(SQLExprTableSource x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLSelectQueryBlock x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLSelectItem x) {
            SQLExpr expr = x.getExpr();
            if (cast(SQLIdentifierExpr)(expr) !is null) {
                resolve(this, cast(SQLIdentifierExpr) expr);
                return false;
            }

            if (cast(SQLPropertyExpr)(expr) !is null) {
                resolve(this, cast(SQLPropertyExpr) expr);
                return false;
            }

            return true;
        }

        override public bool visit(SQLIdentifierExpr x) {
            resolve(this, x);
            return true;
        }

        override public bool visit(SQLPropertyExpr x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLAllColumnExpr x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLCreateTableStatement x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLUpdateStatement x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLDeleteStatement x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLSelect x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLWithSubqueryClause x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLInsertStatement x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLAlterTableStatement x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLMergeStatement x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLCreateProcedureStatement x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLBlockStatement x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLParameter x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLDeclareItem x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLOver x) {
            resolve(this, x);
            return false;
        }

        override public bool visit(SQLReplaceStatement x) {
            resolve(this, x);
            return false;
        }

        override
        public bool isEnabled(Option option) {
            return (options & option.mask) != 0;
        }

        override
        public Context getContext() {
            return context;
        }

        public Context createContext(SQLObject object) {
            return this.context = new Context(object, context);
        }

        override
        public void popContext() {
            if (context !is null) {
                context = context.parent;
            }
        }

        public SchemaRepository getRepository() {
            return repository;
        }
    }

    static void resolve(SchemaResolveVisitor visitor, SQLCreateTableStatement x) {
        SchemaResolveVisitor.Context ctx = visitor.createContext(x);

        SQLExprTableSource table = x.getTableSource();
        ctx.setTableSource(table);

        table.accept(visitor);

        List!(SQLTableElement) elements = x.getTableElementList();
        for (int i = 0; i < elements.size(); i++) {
            SQLTableElement e = elements.get(i);
            if (cast(SQLColumnDefinition)(e) !is null) {
                SQLColumnDefinition columnn = cast(SQLColumnDefinition) e;
                SQLName columnnName = columnn.getName();
                if (cast(SQLIdentifierExpr)(columnnName) !is null) {
                    SQLIdentifierExpr identifierExpr = cast(SQLIdentifierExpr) columnnName;
                    identifierExpr.setResolvedTableSource(table);
                    identifierExpr.setResolvedColumn(columnn);
                }
            } else if (cast(SQLUniqueConstraint)(e) !is null) {
                List!(SQLSelectOrderByItem) columns = (cast(SQLUniqueConstraint) e).getColumns();
                foreach(SQLSelectOrderByItem orderByItem ; columns) {
                    SQLExpr orderByItemExpr = orderByItem.getExpr();
                    if (cast(SQLIdentifierExpr)(orderByItemExpr) !is null) {
                        SQLIdentifierExpr identifierExpr = cast(SQLIdentifierExpr) orderByItemExpr;
                        identifierExpr.setResolvedTableSource(table);

                        SQLColumnDefinition column = x.findColumn(identifierExpr.nameHashCode64());
                        if (column !is null) {
                            identifierExpr.setResolvedColumn(column);
                        }
                    }
                }
            } else {
                e.accept(visitor);
            }
        }

        SQLSelect select = x.getSelect();
        if (select !is null) {
            visitor.visit(select);
        }

        SchemaRepository repository = visitor.getRepository();
        if (repository !is null) {
            repository.acceptCreateTable(x);
        }

        visitor.popContext();
    }

    static void resolve(SchemaResolveVisitor visitor, SQLUpdateStatement x) {
        SchemaResolveVisitor.Context ctx = visitor.createContext(x);

        SQLWithSubqueryClause _with = x.getWith();
        if (_with !is null) {
            _with.accept(visitor);
        }

        SQLTableSource table = x.getTableSource();
        SQLTableSource from = x.getFrom();

        ctx.setTableSource(table);
        ctx.setFrom(from);

        table.accept(visitor);
        if (from !is null) {
            from.accept(visitor);
        }

        List!(SQLUpdateSetItem) items = x.getItems();
        foreach(SQLUpdateSetItem item ; items) {
            SQLExpr column = item.getColumn();
            if (cast(SQLIdentifierExpr)(column) !is null) {
                SQLIdentifierExpr identifierExpr = cast(SQLIdentifierExpr) column;
                identifierExpr.setResolvedTableSource(table);
                visitor.visit(identifierExpr);
            } else if (cast(SQLListExpr)(column) !is null) {
                SQLListExpr columnGroup = cast(SQLListExpr) column;
                foreach(SQLExpr columnGroupItem ; columnGroup.getItems()) {
                    if (cast(SQLIdentifierExpr)(columnGroupItem) !is null) {
                        SQLIdentifierExpr identifierExpr = cast(SQLIdentifierExpr) columnGroupItem;
                        identifierExpr.setResolvedTableSource(table);
                        visitor.visit(identifierExpr);
                    } else {
                        columnGroupItem.accept(visitor);
                    }
                }
            } else {
                column.accept(visitor);
            }
            SQLExpr value = item.getValue();
            if (value !is null) {
                value.accept(visitor);
            }
        }

        SQLExpr where = x.getWhere();
        if (where !is null) {
            where.accept(visitor);
        }

        SQLOrderBy orderBy = x.getOrderBy();
        if (orderBy !is null) {
            orderBy.accept(visitor);
        }

        foreach(SQLExpr sqlExpr ; x.getReturning()) {
            sqlExpr.accept(visitor);
        }

        visitor.popContext();
    }

    static void resolve(SchemaResolveVisitor visitor, SQLDeleteStatement x) {
        SchemaResolveVisitor.Context ctx = visitor.createContext(x);

        SQLWithSubqueryClause _with = x.getWith();
        if (_with !is null) {
            visitor.visit(_with);
        }

        SQLTableSource table = x.getTableSource();
        SQLTableSource from = x.getFrom();

        if (from is null) {
            from = x.getUsing();
        }

        if (table is null && from !is null) {
            table = from;
            from = null;
        }

        if (from !is null) {
            ctx.setFrom(from);
            from.accept(visitor);
        }

        if (table !is null) {
            if (from !is null && cast(SQLExprTableSource)(table) !is null) {
                SQLExpr tableExpr = (cast(SQLExprTableSource) table).getExpr();
                if (cast(SQLPropertyExpr)(tableExpr) !is null
                        && (cast(SQLPropertyExpr) tableExpr).getName() == ("*")) {
                    string _alias = (cast(SQLPropertyExpr) tableExpr).getOwnernName();
                    SQLTableSource refTableSource = from.findTableSource(_alias);
                    if (refTableSource !is null) {
                        (cast(SQLPropertyExpr) tableExpr).setResolvedTableSource(refTableSource);
                    }
                }
            }
            table.accept(visitor);
            ctx.setTableSource(table);
        }

        SQLExpr where = x.getWhere();
        if (where !is null) {
            where.accept(visitor);
        }

        visitor.popContext();
    }

    static void resolve(SchemaResolveVisitor visitor, SQLInsertStatement x) {
        SchemaResolveVisitor.Context ctx = visitor.createContext(x);

        SQLWithSubqueryClause _with = x.getWith();
        if (_with !is null) {
            visitor.visit(_with);
        }

        SQLTableSource table = x.getTableSource();

        ctx.setTableSource(table);

        if (table !is null) {
            table.accept(visitor);
        }

        foreach(SQLExpr column ; x.getColumns()) {
            column.accept(visitor);
        }

        foreach(ValuesClause valuesClause ; x.getValuesList()) {
            valuesClause.accept(visitor);
        }

        SQLSelect query = x.getQuery();
        if (query !is null) {
            visitor.visit(query);
        }

        visitor.popContext();
    }

    static void resolve(SchemaResolveVisitor visitor, SQLIdentifierExpr x) {
        SchemaResolveVisitor.Context ctx = visitor.getContext();
        if (ctx is null) {
            return;
        }

        string ident = x.getName();
        long hash = x.nameHashCode64();
        SQLTableSource tableSource = null;

        if ((hash == FnvHash.Constants.LEVEL || hash == FnvHash.Constants.CONNECT_BY_ISCYCLE)
                && cast(SQLSelectQueryBlock)(ctx.object) !is null) {
            SQLSelectQueryBlock queryBlock = cast(SQLSelectQueryBlock) ctx.object;
            if (queryBlock.getStartWith() !is null
                    || queryBlock.getConnectBy() !is null) {
                return;
            }
        }

        SQLTableSource ctxTable = ctx.getTableSource();

        if (cast(SQLJoinTableSource)(ctxTable) !is null) {
            SQLJoinTableSource join = cast(SQLJoinTableSource) ctxTable;
            tableSource = join.findTableSourceWithColumn(hash);
            if (tableSource is null) {
                 SQLTableSource left = join.getLeft(), right = join.getRight();

                if (cast(SQLSubqueryTableSource)(left) !is null
                        && cast(SQLExprTableSource)(right) !is null) {
                    SQLSelect leftSelect = (cast(SQLSubqueryTableSource) left).getSelect();
                    if (cast(SQLSelectQueryBlock) leftSelect.getQuery() !is null) {
                        bool hasAllColumn = (cast(SQLSelectQueryBlock) leftSelect.getQuery()).selectItemHasAllColumn();
                        if (!hasAllColumn) {
                            tableSource = right;
                        }
                    }
                } else if (cast(SQLSubqueryTableSource)(right) !is null
                        && cast(SQLExprTableSource)(left) !is null) {
                    SQLSelect rightSelect = (cast(SQLSubqueryTableSource) right).getSelect();
                    if (cast(SQLSelectQueryBlock) rightSelect.getQuery() !is null) {
                        bool hasAllColumn = (cast(SQLSelectQueryBlock) rightSelect.getQuery()).selectItemHasAllColumn();
                        if (!hasAllColumn) {
                            tableSource = left;
                        }
                    }
                } else if (cast(SQLExprTableSource)(left) !is null && cast(SQLExprTableSource)(right) !is null) {
                    SQLExprTableSource leftExprTableSource = cast(SQLExprTableSource) left;
                    SQLExprTableSource rightExprTableSource = cast(SQLExprTableSource) right;

                    if (leftExprTableSource.getSchemaObject() !is null
                            && rightExprTableSource.getSchemaObject() is null) {
                        tableSource = rightExprTableSource;

                    } else if (rightExprTableSource.getSchemaObject() !is null
                            && leftExprTableSource.getSchemaObject() is null) {
                        tableSource = leftExprTableSource;
                    }
                }
            }
        } else if (cast(SQLSubqueryTableSource)(ctxTable) !is null) {
            tableSource = ctxTable.findTableSourceWithColumn(hash);
        } else if (cast(SQLLateralViewTableSource)(ctxTable) !is null) {
            tableSource = ctxTable.findTableSourceWithColumn(hash);

            if (tableSource is null) {
                tableSource = (cast(SQLLateralViewTableSource) ctxTable).getTableSource();
            }
        } else {
            for (SchemaResolveVisitor.Context parentCtx = ctx;
                 parentCtx !is null;
                 parentCtx = parentCtx.parent)
            {
                SQLDeclareItem declareItem = parentCtx.findDeclare(hash);
                if (declareItem !is null) {
                    x.setResolvedDeclareItem(declareItem);
                    return;
                }

                if (cast(SQLBlockStatement)(parentCtx.object) !is null) {
                    SQLBlockStatement block = cast(SQLBlockStatement) parentCtx.object;
                    SQLParameter parameter = block.findParameter(hash);
                    if (parameter !is null) {
                        x.setResolvedParameter(parameter);
                        return;
                    }
                } else if (cast(SQLCreateProcedureStatement)(parentCtx.object) !is null) {
                    SQLCreateProcedureStatement createProc = cast(SQLCreateProcedureStatement) parentCtx.object;
                    SQLParameter parameter = createProc.findParameter(hash);
                    if (parameter !is null) {
                        x.setResolvedParameter(parameter);
                        return;
                    }
                }
            }

            tableSource = ctxTable;
            if (cast(SQLExprTableSource)(tableSource) !is null) {
                SchemaObject table = (cast(SQLExprTableSource) tableSource).getSchemaObject();
                if (table !is null) {
                    if (table.findColumn(hash) is null) {
                        SQLCreateTableStatement createStmt = null;
                        {
                            SQLStatement smt = table.getStatement();
                            if (cast(SQLCreateTableStatement)(smt) !is null) {
                                createStmt = cast(SQLCreateTableStatement) smt;
                            }
                        }

                        if (createStmt !is null && createStmt.getTableElementList().size() > 0) {
                            tableSource = null; // maybe parent
                        }
                    }
                }
            }
        }

        if (cast(SQLExprTableSource)(tableSource) !is null) {
                    SQLExpr expr = (cast(SQLExprTableSource) tableSource).getExpr();
            if (cast(SQLIdentifierExpr)(expr) !is null) {
                SQLIdentifierExpr identExpr = cast(SQLIdentifierExpr) expr;
                long identHash = identExpr.nameHashCode64();

                tableSource = unwrapAlias(ctx, tableSource, identHash);
            }
        }

        if (tableSource !is null) {
            x.setResolvedTableSource(tableSource);

            SQLColumnDefinition column = tableSource.findColumn(hash);
            if (column !is null) {
                x.setResolvedColumn(column);
            }

            if (cast(SQLJoinTableSource)(ctxTable) !is null) {
                string _alias = tableSource.computeAlias();
                if (_alias is null || cast(SQLWithSubqueryClause.Entry)(tableSource) !is null) {
                    return;
                }

                SQLPropertyExpr propertyExpr = new SQLPropertyExpr(new SQLIdentifierExpr(_alias), ident, hash);
                propertyExpr.setResolvedColumn(x.getResolvedColumn());
                propertyExpr.setResolvedTableSource(x.getResolvedTableSource());
                SQLUtils.replaceInParent(x, propertyExpr);
            }
        }

        if (x.getResolvedColumn() is null
                && x.getResolvedTableSource() is null) {
            for (SchemaResolveVisitor.Context parentCtx = ctx;
                 parentCtx !is null;
                 parentCtx = parentCtx.parent)
            {
                SQLDeclareItem declareItem = parentCtx.findDeclare(hash);
                if (declareItem !is null) {
                    x.setResolvedDeclareItem(declareItem);
                    return;
                }

                if (cast(SQLBlockStatement)(parentCtx.object) !is null) {
                    SQLBlockStatement block = cast(SQLBlockStatement) parentCtx.object;
                    SQLParameter parameter = block.findParameter(hash);
                    if (parameter !is null) {
                        x.setResolvedParameter(parameter);
                        return;
                    }
                } else if (cast(SQLCreateProcedureStatement)(parentCtx.object) !is null) {
                    SQLCreateProcedureStatement createProc = cast(SQLCreateProcedureStatement) parentCtx.object;
                    SQLParameter parameter = createProc.findParameter(hash);
                    if (parameter !is null) {
                        x.setResolvedParameter(parameter);
                        return;
                    }
                }
            }
        }
    }

    static void resolve(SchemaResolveVisitor visitor, SQLPropertyExpr x) {
        SchemaResolveVisitor.Context ctx = visitor.getContext();
        if (ctx is null) {
            return;
        }

        long owner_hash = 0;
        {
            SQLExpr ownerObj = x.getOwner();
            if (cast(SQLIdentifierExpr)(ownerObj) !is null) {
                SQLIdentifierExpr owner = cast(SQLIdentifierExpr) ownerObj;
                owner_hash = owner.nameHashCode64();
            } else if (cast(SQLPropertyExpr)(ownerObj) !is null) {
                owner_hash = (cast(SQLPropertyExpr) ownerObj).hashCode64();
            }
        }

        SQLTableSource tableSource = null;
        SQLTableSource ctxTable = ctx.getTableSource();

        if (ctxTable !is null) {
            tableSource = ctxTable.findTableSource(owner_hash);
        }

        if (tableSource is null) {
            SQLTableSource ctxFrom = ctx.getFrom();
            if (ctxFrom !is null) {
                tableSource = ctxFrom.findTableSource(owner_hash);
            }
        }

        if (tableSource is null) {
            for (SchemaResolveVisitor.Context parentCtx = ctx;
                 parentCtx !is null;
                 parentCtx = parentCtx.parent) {

                SQLTableSource parentCtxTable = parentCtx.getTableSource();

                if (parentCtxTable !is null) {
                    tableSource = parentCtxTable.findTableSource(owner_hash);
                    if (tableSource is null) {
                        SQLTableSource ctxFrom = parentCtx.getFrom();
                        if (ctxFrom !is null) {
                            tableSource = ctxFrom.findTableSource(owner_hash);
                        }
                    }

                    if (tableSource !is null) {
                        break;
                    }
                } else {
                    if (cast(SQLBlockStatement)(parentCtx.object) !is null) {
                        SQLBlockStatement block = cast(SQLBlockStatement) parentCtx.object;
                        SQLParameter parameter = block.findParameter(owner_hash);
                        if (parameter !is null) {
                            x.setResolvedOwnerObject(parameter);
                            return;
                        }
                    } else if (cast(SQLMergeStatement)(parentCtx.object) !is null) {
                        SQLMergeStatement mergeStatement = cast(SQLMergeStatement) parentCtx.object;
                        SQLTableSource into = mergeStatement.getInto();
                        if (cast(SQLSubqueryTableSource)(into) !is null
                                && into.aliasHashCode64() == owner_hash) {
                            x.setResolvedOwnerObject(into);
                        }
                    }

                    SQLDeclareItem declareItem = parentCtx.findDeclare(owner_hash);
                    if (declareItem !is null) {
                        SQLObject resolvedObject = declareItem.getResolvedObject();
                        if (cast(SQLCreateProcedureStatement)(resolvedObject) !is null
                                || cast(SQLCreateFunctionStatement)(resolvedObject) !is null
                                || cast(SQLTableSource)(resolvedObject) !is null) {
                            x.setResolvedOwnerObject(resolvedObject);
                        }
                        break;
                    }
                }
            }
        }

        if (tableSource !is null) {
            x.setResolvedTableSource(tableSource);
            SQLColumnDefinition column = tableSource.findColumn(x.nameHashCode64());
            if (column !is null) {
                x.setResolvedColumn(column);
            }
        }
    }

    private static SQLTableSource unwrapAlias(SchemaResolveVisitor.Context ctx, SQLTableSource tableSource, long identHash) {
        if (ctx is null) {
            return tableSource;
        }

        if (cast(SQLDeleteStatement)(ctx.object) !is null
                && (ctx.getTableSource() is null || tableSource == ctx.getTableSource())
                && ctx.getFrom() !is null) {
            SQLTableSource found = ctx.getFrom().findTableSource(identHash);
            if (found !is null) {
                return found;
            }
        }

        for (SchemaResolveVisitor.Context parentCtx = ctx;
             parentCtx !is null;
             parentCtx = parentCtx.parent) {

            SQLWithSubqueryClause _with = null;
            if (cast(SQLSelect)(parentCtx.object) !is null) {
                SQLSelect select = cast(SQLSelect) parentCtx.object;
                _with = select.getWithSubQuery();
            } else if (cast(SQLDeleteStatement)(parentCtx.object) !is null) {
                SQLDeleteStatement _delete = cast(SQLDeleteStatement) parentCtx.object;
                _with = _delete.getWith();
            } else if (cast(SQLInsertStatement)(parentCtx.object) !is null) {
                SQLInsertStatement insertStmt = cast(SQLInsertStatement) parentCtx.object;
                _with = insertStmt.getWith();
            } else if (cast(SQLUpdateStatement)(parentCtx.object) !is null) {
                SQLUpdateStatement updateStmt = cast(SQLUpdateStatement) parentCtx.object;
                _with = updateStmt.getWith();
            }

            if (_with !is null) {
                SQLWithSubqueryClause.Entry entry = _with.findEntry(identHash);
                if (entry !is null) {
                    return entry;
                }
            }
        }
        return tableSource;
    }

    static void resolve(SchemaResolveVisitor visitor, SQLSelectQueryBlock x) {
        SchemaResolveVisitor.Context ctx = visitor.createContext(x);

        SQLTableSource from = x.getFrom();
        if (from !is null) {
            ctx.setTableSource(from);

            from.accept(visitor);
        }// } else if (x.getParent() !is null && cast(HiveInsert)x.getParent().getParent() !is null
        //         && cast(HiveMultiInsertStatement)x.getParent().getParent().getParent() !is null){
        //     HiveMultiInsertStatement insert = cast(HiveMultiInsertStatement) x.getParent().getParent().getParent();
        //     if (cast(SQLExprTableSource)insert.getFrom()  !is null) {
        //         from = insert.getFrom();
        //         ctx.setTableSource(from);
        //     }
        // }

        List!(SQLSelectItem) selectList = x.getSelectList();

        List!(SQLSelectItem) columns = new ArrayList!(SQLSelectItem)();
        for (int i = selectList.size() - 1; i >= 0; i--) {
            SQLSelectItem selectItem = selectList.get(i);
            SQLExpr expr = selectItem.getExpr();
            if (cast(SQLAllColumnExpr)(expr) !is null) {
                SQLAllColumnExpr allColumnExpr = cast(SQLAllColumnExpr) expr;
                allColumnExpr.setResolvedTableSource(from);

                visitor.visit(allColumnExpr);

                if (visitor.isEnabled(SchemaResolveVisitor.Option.ResolveAllColumn)) {
                    extractColumns(visitor, from, columns);
                }
            } else if (cast(SQLPropertyExpr)(expr) !is null) {
                SQLPropertyExpr propertyExpr = cast(SQLPropertyExpr) expr;
                visitor.visit(propertyExpr);

                string ownerName = propertyExpr.getOwnernName();
                if (propertyExpr.getName() == ("*")) {
                    if (visitor.isEnabled(SchemaResolveVisitor.Option.ResolveAllColumn)) {
                        SQLTableSource tableSource = x.findTableSource(ownerName);
                        extractColumns(visitor, tableSource, columns);
                    }
                }

                SQLColumnDefinition column = propertyExpr.getResolvedColumn();
                if (column !is null) {
                    continue;
                }
                SQLTableSource tableSource = x.findTableSource(propertyExpr.getOwnernName());
                if (tableSource !is null) {
                    column = tableSource.findColumn(propertyExpr.nameHashCode64());
                    if (column !is null) {
                        propertyExpr.setResolvedColumn(column);
                    }
                }
            } else if (cast(SQLIdentifierExpr)(expr) !is null) {
                SQLIdentifierExpr identExpr = cast(SQLIdentifierExpr) expr;
                visitor.visit(identExpr);

                long name_hash = identExpr.nameHashCode64();

                SQLColumnDefinition column = identExpr.getResolvedColumn();
                if (column !is null) {
                    continue;
                }
                if (from is null) {
                    continue;
                }
                column = from.findColumn(name_hash);
                if (column !is null) {
                    identExpr.setResolvedColumn(column);
                }
            } else {
                expr.accept(visitor);
            }

            if (columns.size() > 0) {
                foreach(SQLSelectItem column ; columns) {
                    column.setParent(x);
                    column.getExpr().accept(visitor);
                }

                selectList.removeAt(i);
                // selectList.addAll(i, columns);
                selectList.addAll( columns); //@gxc
            }
        }

        SQLExprTableSource into = x.getInto();
        if (into !is null) {
            visitor.visit(into);
        }

        SQLExpr where = x.getWhere();
        if (where !is null) {
            if (cast(SQLBinaryOpExpr)(where) !is null) {
                SQLBinaryOpExpr binaryOpExpr = cast(SQLBinaryOpExpr) where;
                resolveExpr(visitor, binaryOpExpr.getLeft());
                resolveExpr(visitor, binaryOpExpr.getRight());
            } else if (cast(SQLBinaryOpExprGroup)(where) !is null) {
                SQLBinaryOpExprGroup binaryOpExprGroup = cast(SQLBinaryOpExprGroup) where;
                foreach(SQLExpr item ; binaryOpExprGroup.getItems()) {
                    if (cast(SQLBinaryOpExpr)(item) !is null) {
                        SQLBinaryOpExpr binaryOpExpr = cast(SQLBinaryOpExpr) item;
                        resolveExpr(visitor, binaryOpExpr.getLeft());
                        resolveExpr(visitor, binaryOpExpr.getRight());
                    } else {
                        item.accept(visitor);
                    }
                }
            } else {
                where.accept(visitor);
            }
        }

        SQLExpr startWith = x.getStartWith();
        if (startWith !is null) {
            startWith.accept(visitor);
        }

        SQLExpr connectBy = x.getConnectBy();
        if (connectBy !is null) {
            connectBy.accept(visitor);
        }

        SQLSelectGroupByClause groupBy = x.getGroupBy();
        if (groupBy !is null) {
            groupBy.accept(visitor);
        }

        SQLOrderBy orderBy = x.getOrderBy();
        if (orderBy !is null) {
            foreach(SQLSelectOrderByItem orderByItem ; orderBy.getItems()) {
                SQLExpr orderByItemExpr = orderByItem.getExpr();

                if (cast(SQLIdentifierExpr)(orderByItemExpr) !is null) {
                    SQLIdentifierExpr orderByItemIdentExpr = cast(SQLIdentifierExpr) orderByItemExpr;
                    long hash = orderByItemIdentExpr.nameHashCode64();
                    SQLSelectItem selectItem = x.findSelectItem(hash);

                    if (selectItem !is null) {
                        orderByItem.setResolvedSelectItem(selectItem);

                        SQLExpr selectItemExpr = selectItem.getExpr();
                        if (cast(SQLIdentifierExpr)(selectItemExpr) !is null) {
                            orderByItemIdentExpr.setResolvedTableSource((cast(SQLIdentifierExpr) selectItemExpr).getResolvedTableSource());
                            orderByItemIdentExpr.setResolvedColumn((cast(SQLIdentifierExpr) selectItemExpr).getResolvedColumn());
                        } else if (cast(SQLPropertyExpr)(selectItemExpr) !is null) {
                            orderByItemIdentExpr.setResolvedTableSource((cast(SQLPropertyExpr) selectItemExpr).getResolvedTableSource());
                            orderByItemIdentExpr.setResolvedColumn((cast(SQLPropertyExpr) selectItemExpr).getResolvedColumn());
                        }
                        continue;
                    }
                }

                orderByItemExpr.accept(visitor);
            }
        }

        int forUpdateOfSize = x.getForUpdateOfSize();
        if (forUpdateOfSize > 0) {
            foreach(SQLExpr sqlExpr ; x.getForUpdateOf()) {
                sqlExpr.accept(visitor);
            }
        }

        visitor.popContext();
    }

    static void extractColumns(SchemaResolveVisitor visitor, SQLTableSource from, List!(SQLSelectItem) columns) {
        if (cast(SQLExprTableSource)(from) !is null) {
            SchemaRepository repository = visitor.getRepository();
            if (repository is null) {
                return;
            }

            string _alias = from.getAlias();

            SchemaObject table = repository.findTable(cast(SQLExprTableSource) from);
            if (table !is null) {
                SQLCreateTableStatement createTableStmt = cast(SQLCreateTableStatement) table.getStatement();
                foreach(SQLTableElement e ; createTableStmt.getTableElementList()) {
                    if (cast(SQLColumnDefinition)(e) !is null) {
                        SQLColumnDefinition column = cast(SQLColumnDefinition) e;

                        if (_alias !is null) {
                            SQLPropertyExpr name = new SQLPropertyExpr(_alias, column.getName().getSimpleName());
                            name.setResolvedColumn(column);
                            columns.add(new SQLSelectItem(name));
                        } else {
                            SQLIdentifierExpr name = cast(SQLIdentifierExpr) column.getName().clone();
                            name.setResolvedColumn(column);
                            columns.add(new SQLSelectItem(name));
                        }


                    }
                }
            }
            return;
        }

        if (cast(SQLJoinTableSource)(from) !is null) {
            SQLJoinTableSource join = cast(SQLJoinTableSource) from;
            extractColumns(visitor, join.getLeft(), columns);
            extractColumns(visitor, join.getRight(), columns);
        }
    }

    static void resolve(SchemaResolveVisitor visitor, SQLAllColumnExpr x) {
        SQLTableSource tableSource = x.getResolvedTableSource();

        if (tableSource is null) {
            SQLSelectQueryBlock queryBlock = null;
            for (SQLObject parent = x.getParent(); parent !is null; parent = parent.getParent()) {
                if (cast(SQLTableSource)(parent) !is null) {
                    return;
                }
                if (cast(SQLSelectQueryBlock)(parent) !is null) {
                    queryBlock = cast(SQLSelectQueryBlock) parent;
                    break;
                }
            }

            if (queryBlock is null) {
                return;
            }

            SQLTableSource from = queryBlock.getFrom();
            if (from is null || cast(SQLJoinTableSource)(from) !is null) {
                return;
            }

            x.setResolvedTableSource(from);
            tableSource = from;
        }

        if (cast(SQLExprTableSource)(tableSource) !is null) {
            SQLExpr expr = (cast(SQLExprTableSource) tableSource).getExpr();
            if (cast(SQLIdentifierExpr)(expr) !is null) {
                SQLTableSource resolvedTableSource = (cast(SQLIdentifierExpr) expr).getResolvedTableSource();
                if (resolvedTableSource !is null) {
                    x.setResolvedTableSource(resolvedTableSource);
                }
            }
        }
    }

    static void resolve(SchemaResolveVisitor visitor, SQLSelect x) {
        SchemaResolveVisitor.Context ctx = visitor.createContext(x);

        SQLWithSubqueryClause _with = x.getWithSubQuery();
        if (_with !is null) {
            visitor.visit(_with);
        }

        SQLSelectQuery query = x.getQuery();
        if (query !is null) {
            query.accept(visitor);
        }

        SQLSelectQueryBlock queryBlock = x.getFirstQueryBlock();

        SQLOrderBy orderBy = x.getOrderBy();
        if (orderBy !is null) {
            foreach(SQLSelectOrderByItem orderByItem ; orderBy.getItems()) {
                SQLExpr orderByItemExpr = orderByItem.getExpr();

                if (cast(SQLIdentifierExpr)(orderByItemExpr) !is null) {
                    SQLIdentifierExpr orderByItemIdentExpr = cast(SQLIdentifierExpr) orderByItemExpr;
                    long hash = orderByItemIdentExpr.nameHashCode64();

                    SQLSelectItem selectItem = null;
                    if (queryBlock !is null) {
                        selectItem = queryBlock.findSelectItem(hash);
                    }

                    if (selectItem !is null) {
                        orderByItem.setResolvedSelectItem(selectItem);

                        SQLExpr selectItemExpr = selectItem.getExpr();
                        if (cast(SQLIdentifierExpr)(selectItemExpr) !is null) {
                            orderByItemIdentExpr.setResolvedTableSource((cast(SQLIdentifierExpr) selectItemExpr).getResolvedTableSource());
                            orderByItemIdentExpr.setResolvedColumn((cast(SQLIdentifierExpr) selectItemExpr).getResolvedColumn());
                        } else if (cast(SQLPropertyExpr)(selectItemExpr) !is null) {
                            orderByItemIdentExpr.setResolvedTableSource((cast(SQLPropertyExpr) selectItemExpr).getResolvedTableSource());
                            orderByItemIdentExpr.setResolvedColumn((cast(SQLPropertyExpr) selectItemExpr).getResolvedColumn());
                        }
                        continue;
                    }
                }

                orderByItemExpr.accept(visitor);
            }
        }

        visitor.popContext();
    }

    static void resolve(SchemaResolveVisitor visitor, SQLWithSubqueryClause x) {
        List!(SQLWithSubqueryClause.Entry) entries = x.getEntries();
        foreach(SQLWithSubqueryClause.Entry entry ; entries) {
            SQLSelect query = entry.getSubQuery();
            if (query !is null) {
                visitor.visit(query);
            } else {
                entry.getReturningStatement().accept(visitor);
            }
        }
    }

    static void resolve(SchemaResolveVisitor visitor, SQLExprTableSource x) {
        SQLExpr expr = x.getExpr();
        if (cast(SQLName)(expr) !is null) {
            if (x.getSchemaObject() !is null) {
                return;
            }

            SchemaRepository repository = visitor.getRepository();
            if (repository !is null) {
                SchemaObject table = repository.findTable(cast(SQLName) expr);
                if (table !is null) {
                    x.setSchemaObject(table);
                }
            }

            SQLIdentifierExpr identifierExpr = null;

            if (cast(SQLIdentifierExpr)(expr) !is null) {
                identifierExpr = cast(SQLIdentifierExpr) expr;
            } else if (cast(SQLPropertyExpr)(expr) !is null) {
                SQLExpr owner = (cast(SQLPropertyExpr) expr).getOwner();
                if (cast(SQLIdentifierExpr)(owner) !is null) {
                    identifierExpr = cast(SQLIdentifierExpr) owner;
                }
            }

            if (identifierExpr !is null) {
                checkParameter(visitor, identifierExpr);

                SQLTableSource tableSource = unwrapAlias(visitor.getContext(), null, identifierExpr.nameHashCode64());
                if (tableSource !is null) {
                    identifierExpr.setResolvedTableSource(tableSource);
                }
            }

        } else if (cast(SQLMethodInvokeExpr)(expr) !is null) {
            expr.accept(visitor);
        } else {
            expr.accept(visitor);
        }
    }

    static void resolve(SchemaResolveVisitor visitor, SQLAlterTableStatement x) {
        SchemaResolveVisitor.Context ctx = visitor.createContext(x);

        SQLTableSource tableSource = x.getTableSource();
        ctx.setTableSource(tableSource);

        foreach(SQLAlterTableItem item ; x.getItems()) {
            item.accept(visitor);
        }

        visitor.popContext();
    }

    static void resolve(SchemaResolveVisitor visitor, SQLMergeStatement x) {
        SchemaResolveVisitor.Context ctx = visitor.createContext(x);

        SQLTableSource into = x.getInto();
        if (cast(SQLExprTableSource)(into) !is null) {
            ctx.setTableSource(into);
        } else {
            into.accept(visitor);
        }

        SQLTableSource using = x.getUsing();
        if (using !is null) {
            using.accept(visitor);
            ctx.setFrom(using);
        }

        SQLExpr on = x.getOn();
        if (on !is null) {
            on.accept(visitor);
        }

        SQLMergeStatement.MergeUpdateClause updateClause  = x.getUpdateClause();
        if (updateClause !is null) {
            foreach(SQLUpdateSetItem item ; updateClause.getItems()) {
                SQLExpr column = item.getColumn();

                if (cast(SQLIdentifierExpr)(column) !is null) {
                    (cast(SQLIdentifierExpr) column).setResolvedTableSource(into);
                } else if (cast(SQLPropertyExpr)(column) !is null) {
                    (cast(SQLPropertyExpr) column).setResolvedTableSource(into);
                } else {
                    column.accept(visitor);
                }

                SQLExpr value = item.getValue();
                if (value !is null) {
                    value.accept(visitor);
                }
            }

            SQLExpr where = updateClause.getWhere();
            if (where !is null) {
                where.accept(visitor);
            }

            SQLExpr deleteWhere = updateClause.getDeleteWhere();
            if (deleteWhere !is null) {
                deleteWhere.accept(visitor);
            }
        }

        SQLMergeStatement.MergeInsertClause insertClause = x.getInsertClause();
        if (insertClause !is null) {
            foreach(SQLExpr column ; insertClause.getColumns()) {
                if (cast(SQLIdentifierExpr)(column) !is null) {
                    (cast(SQLIdentifierExpr) column).setResolvedTableSource(into);
                } else if (cast(SQLPropertyExpr)(column) !is null) {
                    (cast(SQLPropertyExpr) column).setResolvedTableSource(into);
                }
                column.accept(visitor);
            }
            foreach(SQLExpr value ; insertClause.getValues()) {
                value.accept(visitor);
            }
            SQLExpr where = insertClause.getWhere();
            if (where !is null) {
                where.accept(visitor);
            }
        }

        visitor.popContext();
    }

    static void resolve(SchemaResolveVisitor visitor, SQLCreateFunctionStatement x) {
        SchemaResolveVisitor.Context ctx = visitor.createContext(x);

        {
            SQLDeclareItem declareItem = new SQLDeclareItem(x.getName().clone(), null);
            declareItem.setResolvedObject(x);

            SchemaResolveVisitor.Context parentCtx = visitor.getContext();
            if (parentCtx !is null) {
                parentCtx.declare(declareItem);
            } else {
                ctx.declare(declareItem);
            }
        }

        foreach(SQLParameter parameter ; x.getParameters()) {
            parameter.accept(visitor);
        }

        SQLStatement block = x.getBlock();
        if (block !is null) {
            block.accept(visitor);
        }

        visitor.popContext();
    }
    static void resolve(SchemaResolveVisitor visitor, SQLCreateProcedureStatement x) {
        SchemaResolveVisitor.Context ctx = visitor.createContext(x);

        {
            SQLDeclareItem declareItem = new SQLDeclareItem(x.getName().clone(), null);
            declareItem.setResolvedObject(x);


            SchemaResolveVisitor.Context parentCtx = visitor.getContext();
            if (parentCtx !is null) {
                parentCtx.declare(declareItem);
            } else {
                ctx.declare(declareItem);
            }
        }

        foreach(SQLParameter parameter ; x.getParameters()) {
            parameter.accept(visitor);
        }

        SQLStatement block = x.getBlock();
        if (block !is null) {
            block.accept(visitor);
        }

        visitor.popContext();
    }

    static bool resolve(SchemaResolveVisitor visitor, SQLIfStatement x) {
        SchemaResolveVisitor.Context ctx = visitor.createContext(x);

        SQLExpr condition = x.getCondition();
        if (condition !is null) {
            condition.accept(visitor);
        }

        foreach(SQLStatement stmt ; x.getStatements()) {
            stmt.accept(visitor);
        }

        foreach(SQLIfStatement.ElseIf elseIf ; x.getElseIfList()) {
            elseIf.accept(visitor);
        }

        SQLIfStatement.Else e = x.getElseItem();
        if (e !is null) {
            e.accept(visitor);
        }

        visitor.popContext();
        return false;
    }

    static void resolve(SchemaResolveVisitor visitor, SQLBlockStatement x) {
        SchemaResolveVisitor.Context ctx = visitor.createContext(x);

        foreach(SQLParameter parameter ; x.getParameters()) {
            visitor.visit(parameter);
        }

        foreach(SQLStatement stmt ; x.getStatementList()) {
            stmt.accept(visitor);
        }

        SQLStatement exception = x.getException();
        if (exception !is null) {
            exception.accept(visitor);
        }

        visitor.popContext();
    }

    static void resolve(SchemaResolveVisitor visitor, SQLParameter x) {
        SQLName name = x.getName();
        if (cast(SQLIdentifierExpr)(name) !is null) {
            (cast(SQLIdentifierExpr) name).setResolvedParameter(x);
        }

        SQLExpr expr = x.getDefaultValue();

        SchemaResolveVisitor.Context ctx = null;
        if (expr !is null) {
            if (cast(SQLQueryExpr)(expr) !is null) {
                ctx = visitor.createContext(x);

                SQLSubqueryTableSource tableSource = new SQLSubqueryTableSource((cast(SQLQueryExpr) expr).getSubQuery());
                tableSource.setParent(x);
                tableSource.setAlias(x.getName().getSimpleName());

                ctx.setTableSource(tableSource);
            }

            expr.accept(visitor);
        }

        if (ctx !is null) {
            visitor.popContext();
        }
    }

    static void resolve(SchemaResolveVisitor visitor, SQLDeclareItem x) {
        SchemaResolveVisitor.Context ctx = visitor.getContext();
        if (ctx !is null) {
            ctx.declare(x);
        }

        SQLName name = x.getName();
        if (cast(SQLIdentifierExpr)(name) !is null) {
            (cast(SQLIdentifierExpr) name).setResolvedDeclareItem(x);
        }
    }

    static void resolve(SchemaResolveVisitor visitor, SQLOver x) {
        SQLName of = x.getOf();
        SQLOrderBy orderBy = x.getOrderBy();
        List!(SQLExpr) partitionBy = x.getPartitionBy();


        if (of is null // skip if of is not null
                && orderBy !is null) {
            orderBy.accept(visitor);
        }

        if (partitionBy !is null) {
            foreach(SQLExpr expr ; partitionBy) {
                expr.accept(visitor);
            }
        }
    }

    private static bool checkParameter(SchemaResolveVisitor visitor, SQLIdentifierExpr x) {
        if (x.getResolvedParameter() !is null) {
            return true;
        }

        SchemaResolveVisitor.Context ctx = visitor.getContext();
        if (ctx is null) {
            return false;
        }

        long hash = x.hashCode64();
        for (SchemaResolveVisitor.Context parentCtx = ctx;
             parentCtx !is null;
             parentCtx = parentCtx.parent) {

            if (cast(SQLBlockStatement)(parentCtx.object) !is null) {
                SQLBlockStatement block = cast(SQLBlockStatement) parentCtx.object;
                SQLParameter parameter = block.findParameter(hash);
                if (parameter !is null) {
                    x.setResolvedParameter(parameter);
                    return true;
                }
            }

            if (cast(SQLCreateProcedureStatement)(parentCtx.object) !is null) {
                SQLCreateProcedureStatement createProc = cast(SQLCreateProcedureStatement) parentCtx.object;
                SQLParameter parameter = createProc.findParameter(hash);
                if (parameter !is null) {
                    x.setResolvedParameter(parameter);
                    return true;
                }
            }

            if (cast(SQLSelect)(parentCtx.object) !is null) {
                SQLSelect select = cast(SQLSelect) parentCtx.object;
                SQLWithSubqueryClause _with = select.getWithSubQuery();
                if (_with !is null) {
                    SQLWithSubqueryClause.Entry entry = _with.findEntry(hash);
                    if (entry !is null) {
                        x.setResolvedTableSource(entry);
                        return true;
                    }
                }
            }

            SQLDeclareItem declareItem = parentCtx.findDeclare(hash);
            if (declareItem !is null) {
                x.setResolvedDeclareItem(declareItem);
                break;
            }
        }
        return false;
    }

    static void resolve(SchemaResolveVisitor visitor, SQLReplaceStatement x) {
        SchemaResolveVisitor.Context ctx = visitor.createContext(x);

        SQLExprTableSource tableSource = x.getTableSource();
        ctx.setTableSource(tableSource);
        visitor.visit(tableSource);

        foreach(SQLExpr column ; x.getColumns()) {
            column.accept(visitor);
        }

        SQLQueryExpr queryExpr = x.getQuery();
        if (queryExpr !is null) {
            visitor.visit(queryExpr.getSubQuery());
        }

        visitor.popContext();
    }

    static void resolve(SchemaResolveVisitor visitor, SQLFetchStatement x) {
        resolveExpr(visitor, x.getCursorName());
        foreach(SQLExpr expr ; x.getInto()) {
            resolveExpr(visitor, expr);
        }
    }

    static void resolve(SchemaResolveVisitor visitor, SQLForeignKeyConstraint x) {
        SchemaRepository repository = visitor.getRepository();
        SQLObject parent = x.getParent();

        if (cast(SQLCreateTableStatement)(parent) !is null) {
            SQLCreateTableStatement createTableStmt = cast(SQLCreateTableStatement) parent;
            SQLTableSource table = createTableStmt.getTableSource();
            foreach(SQLName item ; x.getReferencingColumns()) {
                SQLIdentifierExpr columnName = cast(SQLIdentifierExpr) item;
                columnName.setResolvedTableSource(table);

                SQLColumnDefinition column = createTableStmt.findColumn(columnName.nameHashCode64());
                if (column !is null) {
                    columnName.setResolvedColumn(column);
                }
            }
        } else if (cast(SQLAlterTableAddConstraint)(parent) !is null) {
            SQLAlterTableStatement stmt = cast(SQLAlterTableStatement) parent.getParent();
            SQLTableSource table = stmt.getTableSource();
            foreach(SQLName item ; x.getReferencingColumns()) {
                SQLIdentifierExpr columnName = cast(SQLIdentifierExpr) item;
                columnName.setResolvedTableSource(table);
            }
        }


        if (repository is null) {
            return;
        }

        SQLExprTableSource table = x.getReferencedTable();
        foreach(SQLName item ; x.getReferencedColumns()) {
            SQLIdentifierExpr columnName = cast(SQLIdentifierExpr) item;
            columnName.setResolvedTableSource(table);
        }

        SQLName tableName = table.getName();

        SchemaObject tableObject = repository.findTable(tableName);
        if (tableObject is null) {
            return;
        }

        SQLStatement tableStmt = tableObject.getStatement();
        if (cast(SQLCreateTableStatement)(tableStmt) !is null) {
            SQLCreateTableStatement refCreateTableStmt = cast(SQLCreateTableStatement) tableStmt;
            foreach(SQLName item ; x.getReferencedColumns()) {
                SQLIdentifierExpr columnName = cast(SQLIdentifierExpr) item;
                SQLColumnDefinition column = refCreateTableStmt.findColumn(columnName.nameHashCode64());
                if (column !is null) {
                    columnName.setResolvedColumn(column);
                }
            }
        }
    }

    // for performance
    static void resolveExpr(SchemaResolveVisitor visitor, SQLExpr x) {
        if (x is null) {
            return;
        }

        auto clazz = typeid(x);
        if (clazz == typeid(SQLIdentifierExpr)) {
            visitor.visit(cast(SQLIdentifierExpr) x);
            return;
        } else if (clazz == typeid(SQLIntegerExpr) || clazz == typeid(SQLCharExpr)) {
            // skip
            return;
        }

        x.accept(visitor);
    }


}
