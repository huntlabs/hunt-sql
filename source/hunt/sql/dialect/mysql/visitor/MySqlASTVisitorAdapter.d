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
module hunt.sql.dialect.mysql.visitor.MySqlASTVisitorAdapter;

import hunt.sql.ast.statement.SQLAlterCharacter;
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
import hunt.sql.ast.expr.SQLIntervalExpr;
import hunt.sql.dialect.mysql.ast.expr.MySqlMatchAgainstExpr;
import hunt.sql.dialect.mysql.ast.expr.MySqlOrderingExpr;
import hunt.sql.dialect.mysql.ast.expr.MySqlOutFileExpr;
import hunt.sql.dialect.mysql.ast.expr.MySqlUserName;
import hunt.sql.dialect.mysql.ast.statement;
import hunt.sql.dialect.mysql.ast.statement.MySqlCreateTableStatement;
import hunt.sql.dialect.mysql.ast.statement.MySqlCreateUserStatement;
// import hunt.sql.dialect.mysql.ast.statement.MySqlCreateTableStatement.TableSpaceOption;
// import hunt.sql.dialect.mysql.ast.statement.MySqlCreateUserStatement.UserSpecification;
import hunt.sql.visitor.SQLASTVisitorAdapter;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;

public class MySqlASTVisitorAdapter : SQLASTVisitorAdapter , MySqlASTVisitor {

     alias endVisit = SQLASTVisitorAdapter.endVisit;
     alias visit = SQLASTVisitorAdapter.visit;
    override
    public bool visit(MySqlTableIndex x) {
        return true;
    }

    override
    public void endVisit(MySqlTableIndex x) {

    }

    override
    public bool visit(MySqlKey x) {
        return true;
    }

    override
    public void endVisit(MySqlKey x) {

    }

    override
    public bool visit(MySqlPrimaryKey x) {

        return true;
    }

    override
    public void endVisit(MySqlPrimaryKey x) {

    }

    override
    public void endVisit(SQLIntervalExpr x) {
    }

    override
    public bool visit(SQLIntervalExpr x) {
        return true;
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
    public void endVisit(MySqlDeleteStatement x) {

    }

    override
    public bool visit(MySqlDeleteStatement x) {

        return true;
    }

    override
    public void endVisit(MySqlInsertStatement x) {

    }

    override
    public bool visit(MySqlInsertStatement x) {

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
    public void endVisit(MySqlShowColumnsStatement x) {

    }

    override
    public bool visit(MySqlShowColumnsStatement x) {

        return true;
    }

    override
    public void endVisit(MySqlShowDatabasesStatement x) {

    }

    override
    public bool visit(MySqlShowDatabasesStatement x) {

        return true;
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
        return true;
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
        return true;
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
        return true;
    }

    override
    public bool visit(MySqlSelectQueryBlock x) {
        return true;
    }

    override
    public void endVisit(MySqlSelectQueryBlock x) {

    }

    override
    public bool visit(MySqlOutFileExpr x) {
        return true;
    }

    override
    public void endVisit(MySqlOutFileExpr x) {

    }

    override
    public bool visit(MySqlExplainStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlExplainStatement x) {

    }

    override
    public bool visit(MySqlUpdateStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlUpdateStatement x) {

    }

    override
    public bool visit(MySqlSetTransactionStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlSetTransactionStatement x) {

    }

    override
    public bool visit(MySqlShowAuthorsStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlShowAuthorsStatement x) {

    }

    override
    public bool visit(MySqlShowBinaryLogsStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlShowBinaryLogsStatement x) {

    }

    override
    public bool visit(MySqlShowMasterLogsStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlShowMasterLogsStatement x) {

    }

    override
    public bool visit(MySqlShowCollationStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlShowCollationStatement x) {

    }

    override
    public bool visit(MySqlShowBinLogEventsStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlShowBinLogEventsStatement x) {

    }

    override
    public bool visit(MySqlShowCharacterSetStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlShowCharacterSetStatement x) {

    }

    override
    public bool visit(MySqlShowContributorsStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlShowContributorsStatement x) {

    }

    override
    public bool visit(MySqlShowCreateDatabaseStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlShowCreateDatabaseStatement x) {

    }

    override
    public bool visit(MySqlShowCreateEventStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlShowCreateEventStatement x) {

    }

    override
    public bool visit(MySqlShowCreateFunctionStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlShowCreateFunctionStatement x) {

    }

    override
    public bool visit(MySqlShowCreateProcedureStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlShowCreateProcedureStatement x) {

    }

    override
    public bool visit(MySqlShowCreateTableStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlShowCreateTableStatement x) {

    }

    override
    public bool visit(MySqlShowCreateTriggerStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlShowCreateTriggerStatement x) {

    }

    override
    public bool visit(MySqlShowCreateViewStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlShowCreateViewStatement x) {

    }

    override
    public bool visit(MySqlShowEngineStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlShowEngineStatement x) {

    }

    override
    public bool visit(MySqlShowEnginesStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlShowEnginesStatement x) {

    }

    override
    public bool visit(MySqlShowErrorsStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlShowErrorsStatement x) {

    }

    override
    public bool visit(MySqlShowEventsStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlShowEventsStatement x) {

    }

    override
    public bool visit(MySqlShowFunctionCodeStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlShowFunctionCodeStatement x) {

    }

    override
    public bool visit(MySqlShowFunctionStatusStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlShowFunctionStatusStatement x) {

    }

    override
    public bool visit(MySqlShowGrantsStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlShowGrantsStatement x) {
    }

    override
    public bool visit(MySqlUserName x) {
        return true;
    }

    override
    public void endVisit(MySqlUserName x) {

    }

    override
    public bool visit(MySqlShowIndexesStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlShowIndexesStatement x) {

    }

    override
    public bool visit(MySqlShowKeysStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlShowKeysStatement x) {

    }

    override
    public bool visit(MySqlShowMasterStatusStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlShowMasterStatusStatement x) {

    }

    override
    public bool visit(MySqlShowOpenTablesStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlShowOpenTablesStatement x) {

    }

    override
    public bool visit(MySqlShowPluginsStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlShowPluginsStatement x) {

    }

    override
    public bool visit(MySqlShowPrivilegesStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlShowPrivilegesStatement x) {

    }

    override
    public bool visit(MySqlShowProcedureCodeStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlShowProcedureCodeStatement x) {

    }

    override
    public bool visit(MySqlShowProcedureStatusStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlShowProcedureStatusStatement x) {

    }

    override
    public bool visit(MySqlShowProcessListStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlShowProcessListStatement x) {

    }

    override
    public bool visit(MySqlShowProfileStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlShowProfileStatement x) {

    }

    override
    public bool visit(MySqlShowProfilesStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlShowProfilesStatement x) {

    }

    override
    public bool visit(MySqlShowRelayLogEventsStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlShowRelayLogEventsStatement x) {

    }

    override
    public bool visit(MySqlShowSlaveHostsStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlShowSlaveHostsStatement x) {

    }

    override
    public bool visit(MySqlShowSlaveStatusStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlShowSlaveStatusStatement x) {

    }

    override
    public bool visit(MySqlShowTableStatusStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlShowTableStatusStatement x) {

    }

    override
    public bool visit(MySqlShowTriggersStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlShowTriggersStatement x) {

    }

    override
    public bool visit(MySqlShowVariantsStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlShowVariantsStatement x) {

    }

    override
    public bool visit(MySqlRenameTableStatement.Item x) {
        return true;
    }

    override
    public void endVisit(MySqlRenameTableStatement.Item x) {

    }

    override
    public bool visit(MySqlRenameTableStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlRenameTableStatement x) {

    }

    override
    public bool visit(MySqlUseIndexHint x) {
        return true;
    }

    override
    public void endVisit(MySqlUseIndexHint x) {

    }

    override
    public bool visit(MySqlIgnoreIndexHint x) {
        return true;
    }

    override
    public void endVisit(MySqlIgnoreIndexHint x) {

    }

    override
    public bool visit(MySqlLockTableStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlLockTableStatement x) {

    }

    override
    public bool visit(MySqlLockTableStatement.Item x) {
        return true;
    }

    override
    public void endVisit(MySqlLockTableStatement.Item x) {

    }

    override
    public bool visit(MySqlUnlockTablesStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlUnlockTablesStatement x) {

    }

    override
    public bool visit(MySqlForceIndexHint x) {
        return true;
    }

    override
    public void endVisit(MySqlForceIndexHint x) {

    }

    override
    public bool visit(MySqlAlterTableChangeColumn x) {
        return true;
    }

    override
    public void endVisit(MySqlAlterTableChangeColumn x) {

    }

    override
    public bool visit(SQLAlterCharacter x) {
        return true;
    }

    override
    public void endVisit(SQLAlterCharacter x) {

    }

    override
    public bool visit(MySqlAlterTableOption x) {
        return true;
    }

    override
    public void endVisit(MySqlAlterTableOption x) {

    }

    override
    public bool visit(MySqlCreateTableStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlCreateTableStatement x) {

    }

    override
    public bool visit(MySqlHelpStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlHelpStatement x) {

    }

    override
    public bool visit(MySqlCharExpr x) {
        return true;
    }

    override
    public void endVisit(MySqlCharExpr x) {

    }

    override
    public bool visit(MySqlUnique x) {
        return true;
    }

    override
    public void endVisit(MySqlUnique x) {

    }

    override
    public bool visit(MysqlForeignKey x) {
        return true;
    }

    override
    public void endVisit(MysqlForeignKey x) {

    }

    override
    public bool visit(MySqlAlterTableModifyColumn x) {
        return true;
    }

    override
    public void endVisit(MySqlAlterTableModifyColumn x) {

    }

    override
    public bool visit(MySqlAlterTableDiscardTablespace x) {
        return true;
    }

    override
    public void endVisit(MySqlAlterTableDiscardTablespace x) {

    }

    override
    public bool visit(MySqlAlterTableImportTablespace x) {
        return true;
    }

    override
    public void endVisit(MySqlAlterTableImportTablespace x) {

    }

    override
    public bool visit(MySqlCreateTableStatement.TableSpaceOption x) {
        return true;
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
    public bool visit(MySqlCaseStatement x) {
        return true;
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
        return true;
    }

    override
    public void endVisit(MySqlSelectIntoStatement x) {

    }

    override
    public bool visit(MySqlCaseStatement.MySqlWhenStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlCaseStatement.MySqlWhenStatement x) {

    }
    // add:end

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
        return false;
    }

    override
    public void endVisit(MySqlRepeatStatement x) {

    }

    override
    public bool visit(MySqlCursorDeclareStatement x) {
        return false;
    }

    override
    public void endVisit(MySqlCursorDeclareStatement x) {

    }

    override
    public bool visit(MySqlUpdateTableSource x) {
        return true;
    }

    override
    public void endVisit(MySqlUpdateTableSource x) {

    }

    override
    public bool visit(MySqlAlterTableAlterColumn x) {
        return true;
    }

    override
    public void endVisit(MySqlAlterTableAlterColumn x) {

    }

    override
    public bool visit(MySqlSubPartitionByKey x) {
        return true;
    }

    override
    public void endVisit(MySqlSubPartitionByKey x) {

    }
    
    override
    public bool visit(MySqlSubPartitionByList x) {
        return true;
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
        return true;
    }

    override
    public void endVisit(MySqlEventSchedule x) {

    }

    override
    public bool visit(MySqlCreateEventStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlCreateEventStatement x) {

    }

    override
    public bool visit(MySqlCreateAddLogFileGroupStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlCreateAddLogFileGroupStatement x) {

    }

    override
    public bool visit(MySqlCreateServerStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlCreateServerStatement x) {

    }

    override
    public bool visit(MySqlCreateTableSpaceStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlCreateTableSpaceStatement x) {

    }

    override
    public bool visit(MySqlAlterEventStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlAlterEventStatement x) {

    }

    override
    public bool visit(MySqlAlterLogFileGroupStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlAlterLogFileGroupStatement x) {

    }

    override
    public bool visit(MySqlAlterServerStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlAlterServerStatement x) {

    }

    override
    public bool visit(MySqlAlterTablespaceStatement x) {
        return true;
    }

    override
    public void endVisit(MySqlAlterTablespaceStatement x) {

    }

    override
    public bool visit(MySqlShowDatabasePartitionStatusStatement x) {
        return true;
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

} //
