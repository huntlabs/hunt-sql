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
module hunt.sql.dialect.mysql.visitor.MySqlSchemaStatVisitor;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLObject;
import hunt.sql.ast.statement;
import hunt.sql.dialect.mysql.ast.MySqlForceIndexHint;
import hunt.sql.dialect.mysql.ast.MySqlIgnoreIndexHint;
import hunt.sql.dialect.mysql.ast.MySqlKey;
import hunt.sql.dialect.mysql.ast.MySqlPrimaryKey;
import hunt.sql.dialect.mysql.ast.MySqlUnique;
import hunt.sql.dialect.mysql.ast.MySqlUseIndexHint;
import hunt.sql.dialect.mysql.ast.MysqlForeignKey;
import hunt.sql.dialect.mysql.ast.clause.MySqlCaseStatement;
// import hunt.sql.dialect.mysql.ast.clause.MySqlCaseStatement.MySqlWhenStatement;
import hunt.sql.dialect.mysql.ast.clause.MySqlCursorDeclareStatement;
import hunt.sql.dialect.mysql.ast.clause.MySqlDeclareConditionStatement;
import hunt.sql.dialect.mysql.ast.clause.MySqlDeclareHandlerStatement;
import hunt.sql.dialect.mysql.ast.clause.MySqlDeclareStatement;
import hunt.sql.dialect.mysql.ast.clause.MySqlIterateStatement;
import hunt.sql.dialect.mysql.ast.clause.MySqlLeaveStatement;
import hunt.sql.dialect.mysql.ast.clause.MySqlRepeatStatement;
import hunt.sql.dialect.mysql.ast.clause.MySqlSelectIntoStatement;
import hunt.sql.dialect.mysql.ast.expr.MySqlCharExpr;
import hunt.sql.dialect.mysql.ast.expr.MySqlExtractExpr;
import hunt.sql.dialect.mysql.ast.expr.MySqlMatchAgainstExpr;
import hunt.sql.dialect.mysql.ast.expr.MySqlOrderingExpr;
import hunt.sql.dialect.mysql.ast.expr.MySqlOutFileExpr;
import hunt.sql.dialect.mysql.ast.expr.MySqlUserName;
import hunt.sql.dialect.mysql.ast.statement;
import hunt.sql.dialect.mysql.ast.statement.MySqlCreateTableStatement;

// import hunt.sql.dialect.mysql.ast.statement.MySqlCreateTableStatement.TableSpaceOption;
// import hunt.sql.dialect.mysql.ast.statement.MySqlCreateUserStatement.UserSpecification;
import hunt.sql.visitor.SchemaStatVisitor;
import hunt.sql.stat.TableStat;
// import hunt.sql.stat.TableStat.Mode;
import hunt.sql.util.DBType;
// import hunt.sql.util.DBType;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;
import hunt.collection;

public class MySqlSchemaStatVisitor : SchemaStatVisitor , MySqlASTVisitor {

    alias visit = SchemaStatVisitor.visit;
    alias endVisit = SchemaStatVisitor.endVisit;

    public this() {
        super (DBType.MYSQL.name);
    }

    override public bool visit(SQLSelectStatement x) {
        if (repository !is null
                && x.getParent() is null) {
            repository.resolve(x);
        }

        return true;
    }

    override
    public string getDbType() {
        return DBType.MYSQL.name;
    }

    // DUAL
    public bool visit(MySqlDeleteStatement x) {
        if (repository !is null
                && x.getParent() is null) {
            repository.resolve(x);
        }

        SQLTableSource from = x.getFrom();
        if (from !is null) {
            from.accept(this);
        }

        SQLTableSource using = x.getUsing();
        if (using !is null) {
            using.accept(this);
        }

        SQLTableSource tableSource = x.getTableSource();
        tableSource.accept(this);

        if (cast(SQLExprTableSource)(tableSource) !is null) {
            TableStat stat = this.getTableStat(cast(SQLExprTableSource) tableSource);
            stat.incrementDeleteCount();
        }

        accept(x.getWhere());

        accept(x.getOrderBy());
        accept(x.getLimit());

        return false;
    }

    public void endVisit(MySqlDeleteStatement x) {
    }

    override
    public void endVisit(MySqlInsertStatement x) {
        setModeOrigin(x);
    }

    override
    public bool visit(MySqlInsertStatement x) {
        if (repository !is null
                && x.getParent() is null) {
            repository.resolve(x);
        }

        setMode(x, TableStat.Mode.Insert);

        TableStat stat = getTableStat(x.getTableSource());

        if (stat !is null) {
            stat.incrementInsertCount();
        }

        accept(cast(List!SQLObject)(x.getColumns()));
        accept(cast(List!SQLObject)(x.getValuesList()));
        accept(x.getQuery());
        accept(cast(List!SQLObject)(x.getDuplicateKeyUpdate()));

        return false;
    }

    override
    public bool visit(MySqlTableIndex x) {

        return false;
    }

    override
    public void endVisit(MySqlTableIndex x) {

    }

    override
    public bool visit(MySqlKey x) {
        foreach(SQLSelectOrderByItem item ; x.getColumns()) {
            item.accept(this);
        }
        return false;
    }

    override
    public void endVisit(MySqlKey x) {

    }

    override
    public bool visit(MySqlPrimaryKey x) {
        foreach(SQLSelectOrderByItem item ; x.getColumns()) {
            SQLExpr expr = item.getExpr();
            expr.accept(this);
        }
        return false;
    }

    override
    public void endVisit(MySqlPrimaryKey x) {

    }

    override
    public void endVisit(MySqlExtractExpr x) {

    }

    override
    public bool visit(MySqlExtractExpr x) {

        return true;
    }

    override
    public void endVisit(MySqlMatchAgainstExpr x) {

    }

    override
    public bool visit(MySqlMatchAgainstExpr x) {

        return true;
    }

    override
    public void endVisit(MySqlPrepareStatement x) {

    }

    override
    public bool visit(MySqlPrepareStatement x) {

        return true;
    }

    override
    public void endVisit(MySqlExecuteStatement x) {

    }

    override
    public bool visit(MySqlExecuteStatement x) {

        return true;
    }
    
    override
    public void endVisit(MysqlDeallocatePrepareStatement x) {
    	
    }
    
    override
    public bool visit(MysqlDeallocatePrepareStatement x) {
    	return true;
    }

    override
    public void endVisit(MySqlLoadDataInFileStatement x) {

    }

    override
    public bool visit(MySqlLoadDataInFileStatement x) {

        return true;
    }

    override
    public void endVisit(MySqlLoadXmlStatement x) {

    }

    override
    public bool visit(MySqlLoadXmlStatement x) {

        return true;
    }

    override
    public void endVisit(SQLStartTransactionStatement x) {

    }

    override
    public bool visit(SQLStartTransactionStatement x) {

        return true;
    }

    override
    public void endVisit(MySqlShowColumnsStatement x) {

    }

    override
    public bool visit(MySqlShowColumnsStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlShowDatabasesStatement x) {

    }

    override
    public bool visit(MySqlShowDatabasesStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlShowWarningsStatement x) {

    }

    override
    public bool visit(MySqlShowWarningsStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlShowStatusStatement x) {

    }

    override
    public bool visit(MySqlShowStatusStatement x) {
        return true;
    }

    override
    public void endVisit(CobarShowStatus x) {

    }

    override
    public bool visit(CobarShowStatus x) {
        return true;
    }

    override
    public void endVisit(MySqlKillStatement x) {

    }

    override
    public bool visit(MySqlKillStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlBinlogStatement x) {

    }

    override
    public bool visit(MySqlBinlogStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlResetStatement x) {

    }

    override
    public bool visit(MySqlResetStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlCreateUserStatement x) {

    }

    override
    public bool visit(MySqlCreateUserStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlCreateUserStatement.UserSpecification x) {

    }

    override
    public bool visit(MySqlCreateUserStatement.UserSpecification x) {
        return true;
    }

    override
    public void endVisit(MySqlPartitionByKey x) {

    }

    override
    public bool visit(MySqlPartitionByKey x) {
        accept(cast(List!SQLObject)(x.getColumns()));
        return false;
    }

    override
    public bool visit(MySqlSelectQueryBlock x) {
        return this.visit(cast(SQLSelectQueryBlock) x);
    }

    override
    public void endVisit(MySqlSelectQueryBlock x) {
        super.endVisit(cast(SQLSelectQueryBlock) x);
    }

    override
    public bool visit(MySqlOutFileExpr x) {
        return false;
    }

    override
    public void endVisit(MySqlOutFileExpr x) {

    }

    override
    public bool visit(MySqlExplainStatement x) {
        if (repository !is null
                && x.getParent() is null) {
            repository.resolve(x);
        }

        SQLName tableName = x.getTableName();
        if (tableName !is null) {
            string table = (cast(Object)(tableName)).toString();
            getTableStat(tableName);

            SQLName columnName = x.getColumnName();
            if (columnName !is null) {
                addColumn(table, columnName.getSimpleName());
            }
        }

        if (x.getStatement() !is null) {
            accept(x.getStatement());
        }

        return false;
    }

    override
    public void endVisit(MySqlExplainStatement x) {

    }

    override
    public bool visit(MySqlUpdateStatement x) {
        visit(cast(SQLUpdateStatement) x);
        foreach(SQLExpr item ; x.getReturning()) {
            item.accept(this);
        }
        
        return false;
    }

    override
    public void endVisit(MySqlUpdateStatement x) {

    }

    override
    public bool visit(MySqlSetTransactionStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlSetTransactionStatement x) {

    }

    override
    public bool visit(MySqlShowAuthorsStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlShowAuthorsStatement x) {

    }

    override
    public bool visit(MySqlShowBinaryLogsStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlShowBinaryLogsStatement x) {

    }

    override
    public bool visit(MySqlShowMasterLogsStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlShowMasterLogsStatement x) {

    }

    override
    public bool visit(MySqlShowCollationStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlShowCollationStatement x) {

    }

    override
    public bool visit(MySqlShowBinLogEventsStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlShowBinLogEventsStatement x) {

    }

    override
    public bool visit(MySqlShowCharacterSetStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlShowCharacterSetStatement x) {

    }

    override
    public bool visit(MySqlShowContributorsStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlShowContributorsStatement x) {

    }

    override
    public bool visit(MySqlShowCreateDatabaseStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlShowCreateDatabaseStatement x) {

    }

    override
    public bool visit(MySqlShowCreateEventStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlShowCreateEventStatement x) {

    }

    override
    public bool visit(MySqlShowCreateFunctionStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlShowCreateFunctionStatement x) {

    }

    override
    public bool visit(MySqlShowCreateProcedureStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlShowCreateProcedureStatement x) {

    }

    override
    public bool visit(MySqlShowCreateTableStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlShowCreateTableStatement x) {

    }

    override
    public bool visit(MySqlShowCreateTriggerStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlShowCreateTriggerStatement x) {

    }

    override
    public bool visit(MySqlShowCreateViewStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlShowCreateViewStatement x) {

    }

    override
    public bool visit(MySqlShowEngineStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlShowEngineStatement x) {

    }

    override
    public bool visit(MySqlShowEnginesStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlShowEnginesStatement x) {

    }

    override
    public bool visit(MySqlShowErrorsStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlShowErrorsStatement x) {

    }

    override
    public bool visit(MySqlShowEventsStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlShowEventsStatement x) {

    }

    override
    public bool visit(MySqlShowFunctionCodeStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlShowFunctionCodeStatement x) {

    }

    override
    public bool visit(MySqlShowFunctionStatusStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlShowFunctionStatusStatement x) {

    }

    override
    public bool visit(MySqlShowGrantsStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlShowGrantsStatement x) {

    }

    override
    public bool visit(MySqlUserName x) {
        return false;
    }

    override
    public void endVisit(MySqlUserName x) {

    }

    override
    public bool visit(MySqlShowIndexesStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlShowIndexesStatement x) {

    }

    override
    public bool visit(MySqlShowKeysStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlShowKeysStatement x) {

    }

    override
    public bool visit(MySqlShowMasterStatusStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlShowMasterStatusStatement x) {

    }

    override
    public bool visit(MySqlShowOpenTablesStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlShowOpenTablesStatement x) {

    }

    override
    public bool visit(MySqlShowPluginsStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlShowPluginsStatement x) {

    }

    override
    public bool visit(MySqlShowPrivilegesStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlShowPrivilegesStatement x) {

    }

    override
    public bool visit(MySqlShowProcedureCodeStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlShowProcedureCodeStatement x) {

    }

    override
    public bool visit(MySqlShowProcedureStatusStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlShowProcedureStatusStatement x) {

    }

    override
    public bool visit(MySqlShowProcessListStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlShowProcessListStatement x) {

    }

    override
    public bool visit(MySqlShowProfileStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlShowProfileStatement x) {

    }

    override
    public bool visit(MySqlShowProfilesStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlShowProfilesStatement x) {

    }

    override
    public bool visit(MySqlShowRelayLogEventsStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlShowRelayLogEventsStatement x) {

    }

    override
    public bool visit(MySqlShowSlaveHostsStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlShowSlaveHostsStatement x) {

    }

    override
    public bool visit(MySqlShowSlaveStatusStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlShowSlaveStatusStatement x) {

    }

    override
    public bool visit(MySqlShowTableStatusStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlShowTableStatusStatement x) {

    }

    override
    public bool visit(MySqlShowTriggersStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlShowTriggersStatement x) {

    }

    override
    public bool visit(MySqlShowVariantsStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlShowVariantsStatement x) {

    }

    override
    public bool visit(MySqlRenameTableStatement.Item x) {
        return false;
    }

    override
    public void endVisit(MySqlRenameTableStatement.Item x) {

    }

    override
    public bool visit(MySqlRenameTableStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlRenameTableStatement x) {

    }

    override
    public bool visit(MySqlUseIndexHint x) {
        return false;
    }

    override
    public void endVisit(MySqlUseIndexHint x) {

    }

    override
    public bool visit(MySqlIgnoreIndexHint x) {
        return false;
    }

    override
    public void endVisit(MySqlIgnoreIndexHint x) {

    }

    override
    public bool visit(MySqlLockTableStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlLockTableStatement x) {

    }

    override
    public bool visit(MySqlLockTableStatement.Item x) {
        return false;
    }

    override
    public void endVisit(MySqlLockTableStatement.Item x) {

    }

    override
    public bool visit(MySqlUnlockTablesStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlUnlockTablesStatement x) {

    }

    override
    public bool visit(MySqlForceIndexHint x) {
        return false;
    }

    override
    public void endVisit(MySqlForceIndexHint x) {

    }

    override
    public bool visit(MySqlAlterTableChangeColumn x) {
        SQLAlterTableStatement stmt = cast(SQLAlterTableStatement) x.getParent();

        SQLName table = stmt.getName();
        string tableName = (cast(Object)(table)).toString();

        SQLName column = x.getColumnName();
        string columnName = (cast(Object)(column)).toString();
        addColumn(tableName, columnName);
        return false;
    }

    override
    public void endVisit(MySqlAlterTableChangeColumn x) {

    }

    override
    public bool visit(MySqlAlterTableModifyColumn x) {
        SQLAlterTableStatement stmt = cast(SQLAlterTableStatement) x.getParent();

        SQLName table = stmt.getName();
        string tableName = (cast(Object)(table)).toString();

        SQLName column = x.getNewColumnDefinition().getName();
        string columnName = (cast(Object)(column)).toString();
        addColumn(tableName, columnName);

        return false;
    }

    override
    public void endVisit(MySqlAlterTableModifyColumn x) {

    }

    override
    public bool visit(SQLAlterCharacter x) {
        return false;
    }

    override
    public void endVisit(SQLAlterCharacter x) {

    }

    override
    public bool visit(MySqlAlterTableOption x) {
        return false;
    }

    override
    public void endVisit(MySqlAlterTableOption x) {

    }

    override
    public bool visit(MySqlCreateTableStatement x) {
        if (repository !is null
                && x.getParent() is null) {
            repository.resolve(x);
        }

        bool val = super.visit(cast(SQLCreateTableStatement) x);

        foreach(SQLObject option ; x.getTableOptions().values()) {
            if (cast(SQLTableSource)(option) !is null) {
                option.accept(this);
            }
        }

        return val;
    }

    override
    public void endVisit(MySqlCreateTableStatement x) {

    }

    override
    public bool visit(MySqlHelpStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlHelpStatement x) {

    }

    override
    public bool visit(MySqlCharExpr x) {
        return false;
    }

    override
    public void endVisit(MySqlCharExpr x) {

    }

    override
    public bool visit(MySqlUnique x) {
        return false;
    }

    override
    public void endVisit(MySqlUnique x) {

    }

    override
    public bool visit(MysqlForeignKey x) {
        return super.visit(cast(SQLForeignKeyImpl) x);
    }

    override
    public void endVisit(MysqlForeignKey x) {

    }

    override
    public bool visit(MySqlAlterTableDiscardTablespace x) {
        return false;
    }

    override
    public void endVisit(MySqlAlterTableDiscardTablespace x) {

    }

    override
    public bool visit(MySqlAlterTableImportTablespace x) {
        return false;
    }

    override
    public void endVisit(MySqlAlterTableImportTablespace x) {

    }

    override
    public bool visit(MySqlCreateTableStatement.TableSpaceOption x) {
        return false;
    }

    override
    public void endVisit(MySqlCreateTableStatement.TableSpaceOption x) {
    }

    override
    public bool visit(MySqlAnalyzeStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlAnalyzeStatement x) {

    }

    override
    public bool visit(MySqlAlterUserStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlAlterUserStatement x) {

    }

    override
    public bool visit(MySqlOptimizeStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlOptimizeStatement x) {

    }

    override
    public bool visit(MySqlHintStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlHintStatement x) {

    }

    override
    public bool visit(MySqlOrderingExpr x) {
        return true;
    }

    override
    public void endVisit(MySqlOrderingExpr x) {

    }

    override
    public bool visit(MySqlAlterTableAlterColumn x) {
        return false;
    }

    override
    public void endVisit(MySqlAlterTableAlterColumn x) {

    }

    override
    public bool visit(MySqlCaseStatement x) {
        accept(cast(List!SQLObject)(x.getWhenList()));
        return false;
    }

    override
    public void endVisit(MySqlCaseStatement x) {

    }

    override
    public bool visit(MySqlDeclareStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlDeclareStatement x) {

    }

    override
    public bool visit(MySqlSelectIntoStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlSelectIntoStatement x) {

    }

    override
    public bool visit(MySqlCaseStatement.MySqlWhenStatement x) {
        accept(cast(List!SQLObject)(x.getStatements()));
        return false;
    }

    override
    public void endVisit(MySqlCaseStatement.MySqlWhenStatement x) {

    }

    override
    public bool visit(MySqlLeaveStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlLeaveStatement x) {

    }

    override
    public bool visit(MySqlIterateStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlIterateStatement x) {

    }

    override
    public bool visit(MySqlRepeatStatement x) {
        accept(cast(List!SQLObject)(x.getStatements()));
        return false;
    }

    override
    public void endVisit(MySqlRepeatStatement x) {

    }

    override
    public bool visit(MySqlCursorDeclareStatement x) {
        accept(x.getSelect());
        return false;
    }

    override
    public void endVisit(MySqlCursorDeclareStatement x) {

    }

    override
    public bool visit(MySqlUpdateTableSource x) {
        if (x.getUpdate() !is null) {
            return this.visit(x.getUpdate());
        }
        return false;
    }

    override
    public void endVisit(MySqlUpdateTableSource x) {

    }

    override
    public bool visit(MySqlSubPartitionByKey x) {
        return false;
    }

    override
    public void endVisit(MySqlSubPartitionByKey x) {

    }

    override
    public bool visit(MySqlSubPartitionByList x) {
        return false;
    }

    override
    public void endVisit(MySqlSubPartitionByList x) {

    }

	override
	public bool visit(MySqlDeclareHandlerStatement x) {
		return false;
	}

	override
	public void endVisit(MySqlDeclareHandlerStatement x) {

	}

	override
	public bool visit(MySqlDeclareConditionStatement x) {
		return false;
	}

	override
	public void endVisit(MySqlDeclareConditionStatement x) {

	}

    override
    public bool visit(MySqlFlushStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlFlushStatement x) {

    }

    override
    public bool visit(MySqlEventSchedule x) {
        return false;
    }

    override
    public void endVisit(MySqlEventSchedule x) {

    }

    override
    public bool visit(MySqlCreateEventStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlCreateEventStatement x) {

    }

    override
    public bool visit(MySqlCreateAddLogFileGroupStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlCreateAddLogFileGroupStatement x) {

    }

    override
    public bool visit(MySqlCreateServerStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlCreateServerStatement x) {

    }

    override
    public bool visit(MySqlCreateTableSpaceStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlCreateTableSpaceStatement x) {

    }

    override
    public bool visit(MySqlAlterEventStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlAlterEventStatement x) {

    }

    override
    public bool visit(MySqlAlterLogFileGroupStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlAlterLogFileGroupStatement x) {

    }

    override
    public bool visit(MySqlAlterServerStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlAlterServerStatement x) {

    }

    override
    public bool visit(MySqlAlterTablespaceStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlAlterTablespaceStatement x) {

    }

    override
    public bool visit(MySqlShowDatabasePartitionStatusStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlShowDatabasePartitionStatusStatement x) {

    }

    override
    public bool visit(MySqlChecksumTableStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlChecksumTableStatement x) {

    }
}
