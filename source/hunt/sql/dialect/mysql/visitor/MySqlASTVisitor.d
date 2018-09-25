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
module hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;

import hunt.sql.ast.SQLExpr;
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
import hunt.sql.dialect.mysql.ast.expr.MySqlMatchAgainstExpr;
import hunt.sql.dialect.mysql.ast.expr.MySqlOrderingExpr;
import hunt.sql.dialect.mysql.ast.expr.MySqlOutFileExpr;
import hunt.sql.dialect.mysql.ast.expr.MySqlUserName;
import hunt.sql.dialect.mysql.ast.statement;
import hunt.sql.visitor.SQLASTVisitor;

public interface MySqlASTVisitor : SQLASTVisitor {
    bool visit(MySqlTableIndex x);

    void endVisit(MySqlTableIndex x);

    bool visit(MySqlKey x);

    void endVisit(MySqlKey x);

    bool visit(MySqlPrimaryKey x);

    void endVisit(MySqlPrimaryKey x);

    bool visit(MySqlUnique x);

    void endVisit(MySqlUnique x);

    bool visit(MysqlForeignKey x);

    void endVisit(MysqlForeignKey x);

    void endVisit(MySqlExtractExpr x);

    bool visit(MySqlExtractExpr x);

    void endVisit(MySqlMatchAgainstExpr x);

    bool visit(MySqlMatchAgainstExpr x);

    void endVisit(MySqlPrepareStatement x);

    bool visit(MySqlPrepareStatement x);

    void endVisit(MySqlExecuteStatement x);

    bool visit(MysqlDeallocatePrepareStatement x);

    void endVisit(MysqlDeallocatePrepareStatement x);

    bool visit(MySqlExecuteStatement x);

    void endVisit(MySqlDeleteStatement x);

    bool visit(MySqlDeleteStatement x);

    void endVisit(MySqlInsertStatement x);

    bool visit(MySqlInsertStatement x);

    void endVisit(MySqlLoadDataInFileStatement x);

    bool visit(MySqlLoadDataInFileStatement x);

    void endVisit(MySqlLoadXmlStatement x);

    bool visit(MySqlLoadXmlStatement x);

    void endVisit(MySqlShowColumnsStatement x);

    bool visit(MySqlShowColumnsStatement x);

    void endVisit(MySqlShowDatabasesStatement x);

    bool visit(MySqlShowDatabasesStatement x);

    void endVisit(MySqlShowWarningsStatement x);

    bool visit(MySqlShowWarningsStatement x);

    void endVisit(MySqlShowStatusStatement x);

    bool visit(MySqlShowStatusStatement x);

    void endVisit(MySqlShowAuthorsStatement x);

    bool visit(MySqlShowAuthorsStatement x);

    void endVisit(CobarShowStatus x);

    bool visit(CobarShowStatus x);

    void endVisit(MySqlKillStatement x);

    bool visit(MySqlKillStatement x);

    void endVisit(MySqlBinlogStatement x);

    bool visit(MySqlBinlogStatement x);

    void endVisit(MySqlResetStatement x);

    bool visit(MySqlResetStatement x);

    void endVisit(MySqlCreateUserStatement x);

    bool visit(MySqlCreateUserStatement x);

    void endVisit(MySqlCreateUserStatement.UserSpecification x);

    bool visit(MySqlCreateUserStatement.UserSpecification x);

    void endVisit(MySqlPartitionByKey x);

    bool visit(MySqlPartitionByKey x);

    bool visit(MySqlSelectQueryBlock x);

    void endVisit(MySqlSelectQueryBlock x);

    bool visit(MySqlOutFileExpr x);

    void endVisit(MySqlOutFileExpr x);

    bool visit(MySqlExplainStatement x);

    void endVisit(MySqlExplainStatement x);

    bool visit(MySqlUpdateStatement x);

    void endVisit(MySqlUpdateStatement x);

    bool visit(MySqlSetTransactionStatement x);

    void endVisit(MySqlSetTransactionStatement x);

    bool visit(MySqlShowBinaryLogsStatement x);

    void endVisit(MySqlShowBinaryLogsStatement x);

    bool visit(MySqlShowMasterLogsStatement x);

    void endVisit(MySqlShowMasterLogsStatement x);

    bool visit(MySqlShowCharacterSetStatement x);

    void endVisit(MySqlShowCharacterSetStatement x);

    bool visit(MySqlShowCollationStatement x);

    void endVisit(MySqlShowCollationStatement x);

    bool visit(MySqlShowBinLogEventsStatement x);

    void endVisit(MySqlShowBinLogEventsStatement x);

    bool visit(MySqlShowContributorsStatement x);

    void endVisit(MySqlShowContributorsStatement x);

    bool visit(MySqlShowCreateDatabaseStatement x);

    void endVisit(MySqlShowCreateDatabaseStatement x);

    bool visit(MySqlShowCreateEventStatement x);

    void endVisit(MySqlShowCreateEventStatement x);

    bool visit(MySqlShowCreateFunctionStatement x);

    void endVisit(MySqlShowCreateFunctionStatement x);

    bool visit(MySqlShowCreateProcedureStatement x);

    void endVisit(MySqlShowCreateProcedureStatement x);

    bool visit(MySqlShowCreateTableStatement x);

    void endVisit(MySqlShowCreateTableStatement x);

    bool visit(MySqlShowCreateTriggerStatement x);

    void endVisit(MySqlShowCreateTriggerStatement x);

    bool visit(MySqlShowCreateViewStatement x);

    void endVisit(MySqlShowCreateViewStatement x);

    bool visit(MySqlShowEngineStatement x);

    void endVisit(MySqlShowEngineStatement x);

    bool visit(MySqlShowEnginesStatement x);

    void endVisit(MySqlShowEnginesStatement x);

    bool visit(MySqlShowErrorsStatement x);

    void endVisit(MySqlShowErrorsStatement x);

    bool visit(MySqlShowEventsStatement x);

    void endVisit(MySqlShowEventsStatement x);

    bool visit(MySqlShowFunctionCodeStatement x);

    void endVisit(MySqlShowFunctionCodeStatement x);

    bool visit(MySqlShowFunctionStatusStatement x);

    void endVisit(MySqlShowFunctionStatusStatement x);

    bool visit(MySqlShowGrantsStatement x);

    void endVisit(MySqlShowGrantsStatement x);

    bool visit(MySqlUserName x);

    void endVisit(MySqlUserName x);

    bool visit(MySqlShowIndexesStatement x);

    void endVisit(MySqlShowIndexesStatement x);

    bool visit(MySqlShowKeysStatement x);

    void endVisit(MySqlShowKeysStatement x);

    bool visit(MySqlShowMasterStatusStatement x);

    void endVisit(MySqlShowMasterStatusStatement x);

    bool visit(MySqlShowOpenTablesStatement x);

    void endVisit(MySqlShowOpenTablesStatement x);

    bool visit(MySqlShowPluginsStatement x);

    void endVisit(MySqlShowPluginsStatement x);

    bool visit(MySqlShowPrivilegesStatement x);

    void endVisit(MySqlShowPrivilegesStatement x);

    bool visit(MySqlShowProcedureCodeStatement x);

    void endVisit(MySqlShowProcedureCodeStatement x);

    bool visit(MySqlShowProcedureStatusStatement x);

    void endVisit(MySqlShowProcedureStatusStatement x);

    bool visit(MySqlShowProcessListStatement x);

    void endVisit(MySqlShowProcessListStatement x);

    bool visit(MySqlShowProfileStatement x);

    void endVisit(MySqlShowProfileStatement x);

    bool visit(MySqlShowProfilesStatement x);

    void endVisit(MySqlShowProfilesStatement x);

    bool visit(MySqlShowRelayLogEventsStatement x);

    void endVisit(MySqlShowRelayLogEventsStatement x);

    bool visit(MySqlShowSlaveHostsStatement x);

    void endVisit(MySqlShowSlaveHostsStatement x);

    bool visit(MySqlShowSlaveStatusStatement x);

    void endVisit(MySqlShowSlaveStatusStatement x);

    bool visit(MySqlShowTableStatusStatement x);

    void endVisit(MySqlShowTableStatusStatement x);

    bool visit(MySqlShowTriggersStatement x);

    void endVisit(MySqlShowTriggersStatement x);

    bool visit(MySqlShowVariantsStatement x);

    void endVisit(MySqlShowVariantsStatement x);

    bool visit(MySqlRenameTableStatement.Item x);

    void endVisit(MySqlRenameTableStatement.Item x);

    bool visit(MySqlRenameTableStatement x);

    void endVisit(MySqlRenameTableStatement x);

    bool visit(MySqlUseIndexHint x);

    void endVisit(MySqlUseIndexHint x);

    bool visit(MySqlIgnoreIndexHint x);

    void endVisit(MySqlIgnoreIndexHint x);

    bool visit(MySqlLockTableStatement x);

    void endVisit(MySqlLockTableStatement x);

    bool visit(MySqlLockTableStatement.Item x);

    void endVisit(MySqlLockTableStatement.Item x);

    bool visit(MySqlUnlockTablesStatement x);

    void endVisit(MySqlUnlockTablesStatement x);

    bool visit(MySqlForceIndexHint x);

    void endVisit(MySqlForceIndexHint x);

    bool visit(MySqlAlterTableChangeColumn x);

    void endVisit(MySqlAlterTableChangeColumn x);

    bool visit(MySqlAlterTableOption x);

    void endVisit(MySqlAlterTableOption x);

    bool visit(MySqlCreateTableStatement x);

    void endVisit(MySqlCreateTableStatement x);

    bool visit(MySqlHelpStatement x);

    void endVisit(MySqlHelpStatement x);

    bool visit(MySqlCharExpr x);

    void endVisit(MySqlCharExpr x);

    bool visit(MySqlAlterTableModifyColumn x);

    void endVisit(MySqlAlterTableModifyColumn x);

    bool visit(MySqlAlterTableDiscardTablespace x);

    void endVisit(MySqlAlterTableDiscardTablespace x);

    bool visit(MySqlAlterTableImportTablespace x);

    void endVisit(MySqlAlterTableImportTablespace x);

    bool visit(MySqlCreateTableStatement.TableSpaceOption x);

    void endVisit(MySqlCreateTableStatement.TableSpaceOption x);

    bool visit(MySqlAnalyzeStatement x);

    void endVisit(MySqlAnalyzeStatement x);

    bool visit(MySqlAlterUserStatement x);

    void endVisit(MySqlAlterUserStatement x);

    bool visit(MySqlOptimizeStatement x);

    void endVisit(MySqlOptimizeStatement x);

    bool visit(MySqlHintStatement x);

    void endVisit(MySqlHintStatement x);

    bool visit(MySqlOrderingExpr x);

    void endVisit(MySqlOrderingExpr x);

    bool visit(MySqlCaseStatement x);

    void endVisit(MySqlCaseStatement x);

    bool visit(MySqlDeclareStatement x);

    void endVisit(MySqlDeclareStatement x);

    bool visit(MySqlSelectIntoStatement x);

    void endVisit(MySqlSelectIntoStatement x);

    bool visit(MySqlCaseStatement.MySqlWhenStatement x);

    void endVisit(MySqlCaseStatement.MySqlWhenStatement x);

    bool visit(MySqlLeaveStatement x);

    void endVisit(MySqlLeaveStatement x);

    bool visit(MySqlIterateStatement x);

    void endVisit(MySqlIterateStatement x);

    bool visit(MySqlRepeatStatement x);

    void endVisit(MySqlRepeatStatement x);

    bool visit(MySqlCursorDeclareStatement x);

    void endVisit(MySqlCursorDeclareStatement x);

    bool visit(MySqlUpdateTableSource x);

    void endVisit(MySqlUpdateTableSource x);

    bool visit(MySqlAlterTableAlterColumn x);

    void endVisit(MySqlAlterTableAlterColumn x);

    bool visit(MySqlSubPartitionByKey x);

    void endVisit(MySqlSubPartitionByKey x);

    bool visit(MySqlSubPartitionByList x);

    void endVisit(MySqlSubPartitionByList x);

    bool visit(MySqlDeclareHandlerStatement x);

    void endVisit(MySqlDeclareHandlerStatement x);

    bool visit(MySqlDeclareConditionStatement x);

    void endVisit(MySqlDeclareConditionStatement x);

    bool visit(MySqlFlushStatement x);

    void endVisit(MySqlFlushStatement x);

    bool visit(MySqlEventSchedule x);
    void endVisit(MySqlEventSchedule x);

    bool visit(MySqlCreateEventStatement x);
    void endVisit(MySqlCreateEventStatement x);

    bool visit(MySqlCreateAddLogFileGroupStatement x);
    void endVisit(MySqlCreateAddLogFileGroupStatement x);

    bool visit(MySqlCreateServerStatement x);
    void endVisit(MySqlCreateServerStatement x);

    bool visit(MySqlCreateTableSpaceStatement x);
    void endVisit(MySqlCreateTableSpaceStatement x);

    bool visit(MySqlAlterEventStatement x);
    void endVisit(MySqlAlterEventStatement x);

    bool visit(MySqlAlterLogFileGroupStatement x);
    void endVisit(MySqlAlterLogFileGroupStatement x);

    bool visit(MySqlAlterServerStatement x);
    void endVisit(MySqlAlterServerStatement x);

    bool visit(MySqlAlterTablespaceStatement x);
    void endVisit(MySqlAlterTablespaceStatement x);

    bool visit(MySqlShowDatabasePartitionStatusStatement x);
    void endVisit(MySqlShowDatabasePartitionStatusStatement x);

    bool visit(MySqlChecksumTableStatement x);
    void endVisit(MySqlChecksumTableStatement x);

} //
