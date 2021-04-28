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
module hunt.sql.visitor.SQLASTVisitorAdapter;

import hunt.sql.ast;
import hunt.sql.ast.expr;
import hunt.sql.ast.statement;
import hunt.sql.ast.statement.SQLInsertStatement;
// import hunt.sql.ast.statement.SQLInsertStatement.ValuesClause;
// import hunt.sql.ast.statement.SQLMergeStatement.MergeInsertClause;
// import hunt.sql.ast.statement.SQLMergeStatement.MergeUpdateClause;
import hunt.sql.ast.statement.SQLWhileStatement;
import hunt.sql.ast.statement.SQLDeclareStatement;
import hunt.sql.ast.statement.SQLCommitStatement;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.visitor.VisitorFeature;


class SQLASTVisitorAdapter : SQLASTVisitor {
    protected int features;

    void endVisit(SQLAllColumnExpr x) {
    }

    void endVisit(SQLBetweenExpr x) {
    }

    void endVisit(SQLBinaryOpExpr x) {
    }

    void endVisit(SQLCaseExpr x) {
    }

    void endVisit(SQLCaseExpr.Item x) {
    }

    void endVisit(SQLCaseStatement x) {
    }

    void endVisit(SQLCaseStatement.Item x) {
    }

    void endVisit(SQLCharExpr x) {
    }

    void endVisit(SQLIdentifierExpr x) {
    }

    void endVisit(SQLInListExpr x) {
    }

    void endVisit(SQLIntegerExpr x) {
    }

    void endVisit(SQLExistsExpr x) {
    }

    void endVisit(SQLNCharExpr x) {
    }

    void endVisit(SQLNotExpr x) {
    }

    void endVisit(SQLNullExpr x) {
    }

    void endVisit(SQLNumberExpr x) {
    }

    void endVisit(SQLPropertyExpr x) {
    }

    void endVisit(SQLSelectGroupByClause x) {
    }

    void endVisit(SQLSelectItem x) {
    }

    void endVisit(SQLSelectStatement selectStatement) {
    }

    void postVisit(SQLObject astNode) {
    }

    void preVisit(SQLObject astNode) {
    }

    bool visit(SQLAllColumnExpr x) {
        return true;
    }

    bool visit(SQLBetweenExpr x) {
        return true;
    }

    bool visit(SQLBinaryOpExpr x) {
        return true;
    }

    bool visit(SQLCaseExpr x) {
        return true;
    }

    bool visit(SQLCaseExpr.Item x) {
        return true;
    }

    bool visit(SQLCaseStatement x) {
        return true;
    }

    bool visit(SQLCaseStatement.Item x) {
        return true;
    }

    bool visit(SQLCastExpr x) {
        return true;
    }

    bool visit(SQLCharExpr x) {
        return true;
    }

    bool visit(SQLExistsExpr x) {
        return true;
    }

    bool visit(SQLIdentifierExpr x) {
        return true;
    }

    bool visit(SQLInListExpr x) {
        return true;
    }

    bool visit(SQLIntegerExpr x) {
        return true;
    }

    bool visit(SQLNCharExpr x) {
        return true;
    }

    bool visit(SQLNotExpr x) {
        return true;
    }

    bool visit(SQLNullExpr x) {
        return true;
    }

    bool visit(SQLNumberExpr x) {
        return true;
    }

    bool visit(SQLPropertyExpr x) {
        return true;
    }

    bool visit(SQLSelectGroupByClause x) {
        return true;
    }

    bool visit(SQLSelectItem x) {
        return true;
    }

    void endVisit(SQLCastExpr x) {
    }

    bool visit(SQLSelectStatement astNode) {
        return true;
    }

    void endVisit(SQLAggregateExpr x) {
    }

    bool visit(SQLAggregateExpr x) {
        return true;
    }

    bool visit(SQLVariantRefExpr x) {
        return true;
    }

    void endVisit(SQLVariantRefExpr x) {
    }

    bool visit(SQLQueryExpr x) {
        return true;
    }

    void endVisit(SQLQueryExpr x) {
    }

    bool visit(SQLSelect x) {
        return true;
    }

    void endVisit(SQLSelect select) {
    }

    bool visit(SQLSelectQueryBlock x) {
        return true;
    }

    void endVisit(SQLSelectQueryBlock x) {
    }

    bool visit(SQLExprTableSource x) {
        return true;
    }

    void endVisit(SQLExprTableSource x) {
    }

    bool visit(SQLOrderBy x) {
        return true;
    }

    void endVisit(SQLOrderBy x) {
    }

    bool visit(SQLSelectOrderByItem x) {
        return true;
    }

    void endVisit(SQLSelectOrderByItem x) {
    }

    bool visit(SQLDropTableStatement x) {
        return true;
    }

    void endVisit(SQLDropTableStatement x) {
    }

    bool visit(SQLCreateTableStatement x) {
        return true;
    }

    void endVisit(SQLCreateTableStatement x) {
    }

    bool visit(SQLColumnDefinition x) {
        return true;
    }

    void endVisit(SQLColumnDefinition x) {
    }

    bool visit(SQLColumnDefinition.Identity x) {
        return true;
    }

    void endVisit(SQLColumnDefinition.Identity x) {
    }

    bool visit(SQLDataType x) {
        return true;
    }

    void endVisit(SQLDataType x) {
    }

    bool visit(SQLDeleteStatement x) {
        return true;
    }

    void endVisit(SQLDeleteStatement x) {
    }

    bool visit(SQLCurrentOfCursorExpr x) {
        return true;
    }

    void endVisit(SQLCurrentOfCursorExpr x) {
    }

    bool visit(SQLInsertStatement x) {
        return true;
    }

    void endVisit(SQLInsertStatement x) {
    }

    bool visit(SQLUpdateSetItem x) {
        return true;
    }

    void endVisit(SQLUpdateSetItem x) {
    }

    bool visit(SQLUpdateStatement x) {
        return true;
    }

    void endVisit(SQLUpdateStatement x) {
    }

    bool visit(SQLCreateViewStatement x) {
        return true;
    }

    void endVisit(SQLCreateViewStatement x) {
    }

    bool visit(SQLAlterViewStatement x) {
        return true;
    }

    void endVisit(SQLAlterViewStatement x) {
    }

    bool visit(SQLCreateViewStatement.Column x) {
        return true;
    }

    void endVisit(SQLCreateViewStatement.Column x) {
    }

    bool visit(SQLNotNullConstraint x) {
        return true;
    }

    void endVisit(SQLNotNullConstraint x) {
    }

    //override
    void endVisit(SQLMethodInvokeExpr x) {

    }

    //override
    bool visit(SQLMethodInvokeExpr x) {
        return true;
    }

    //override
    void endVisit(SQLUnionQuery x) {

    }

    //override
    bool visit(SQLUnionQuery x) {
        return true;
    }

    //override
    bool visit(SQLUnaryExpr x) {
        return true;
    }

    //override
    void endVisit(SQLUnaryExpr x) {

    }

    //override
    bool visit(SQLHexExpr x) {
        return false;
    }

    //override
    void endVisit(SQLHexExpr x) {

    }

    bool visit(SQLBlobExpr x) {
        return false;
    }

    void endVisit(SQLBlobExpr x) {

    }
    //override
    void endVisit(SQLSetStatement x) {

    }

    //override
    bool visit(SQLSetStatement x) {
        return true;
    }

    //override
    void endVisit(SQLAssignItem x) {

    }

    //override
    bool visit(SQLAssignItem x) {
        return true;
    }

    //override
    void endVisit(SQLCallStatement x) {

    }

    //override
    bool visit(SQLCallStatement x) {
        return true;
    }

    //override
    void endVisit(SQLJoinTableSource x) {

    }

    //override
    bool visit(SQLJoinTableSource x) {
        return true;
    }

    //override
    bool visit(ValuesClause x) {
        return true;
    }

    //override
    void endVisit(ValuesClause x) {

    }

    //override
    void endVisit(SQLSomeExpr x) {

    }

    //override
    bool visit(SQLSomeExpr x) {
        return true;
    }

    //override
    void endVisit(SQLAnyExpr x) {

    }

    //override
    bool visit(SQLAnyExpr x) {
        return true;
    }

    //override
    void endVisit(SQLAllExpr x) {

    }

    //override
    bool visit(SQLAllExpr x) {
        return true;
    }

    //override
    void endVisit(SQLInSubQueryExpr x) {

    }

    //override
    bool visit(SQLInSubQueryExpr x) {
        return true;
    }

    //override
    void endVisit(SQLListExpr x) {

    }

    //override
    bool visit(SQLListExpr x) {
        return true;
    }

    //override
    void endVisit(SQLSubqueryTableSource x) {

    }

    //override
    bool visit(SQLSubqueryTableSource x) {
        return true;
    }

    //override
    void endVisit(SQLTruncateStatement x) {

    }

    //override
    bool visit(SQLTruncateStatement x) {
        return true;
    }

    //override
    void endVisit(SQLDefaultExpr x) {

    }

    //override
    bool visit(SQLDefaultExpr x) {
        return true;
    }

    //override
    void endVisit(SQLCommentStatement x) {

    }

    //override
    bool visit(SQLCommentStatement x) {
        return true;
    }

    //override
    void endVisit(SQLUseStatement x) {

    }

    //override
    bool visit(SQLUseStatement x) {
        return true;
    }

    //override
    bool visit(SQLAlterTableAddColumn x) {
        return true;
    }

    //override
    void endVisit(SQLAlterTableAddColumn x) {

    }

    //override
    bool visit(SQLAlterTableDropColumnItem x) {
        return true;
    }

    //override
    void endVisit(SQLAlterTableDropColumnItem x) {

    }

    //override
    bool visit(SQLDropIndexStatement x) {
        return true;
    }

    //override
    void endVisit(SQLDropIndexStatement x) {

    }

    //override
    bool visit(SQLDropViewStatement x) {
        return true;
    }

    //override
    void endVisit(SQLDropViewStatement x) {

    }

    //override
    bool visit(SQLSavePointStatement x) {
        return false;
    }

    //override
    void endVisit(SQLSavePointStatement x) {

    }

    //override
    bool visit(SQLRollbackStatement x) {
        return true;
    }

    //override
    void endVisit(SQLRollbackStatement x) {

    }

    //override
    bool visit(SQLReleaseSavePointStatement x) {
        return true;
    }

    //override
    void endVisit(SQLReleaseSavePointStatement x) {
    }

    //override
    bool visit(SQLCommentHint x) {
        return true;
    }

    //override
    void endVisit(SQLCommentHint x) {

    }

    //override
    void endVisit(SQLCreateDatabaseStatement x) {

    }

    //override
    bool visit(SQLCreateDatabaseStatement x) {
        return true;
    }

    //override
    bool visit(SQLAlterTableDropIndex x) {
        return true;
    }

    //override
    void endVisit(SQLAlterTableDropIndex x) {

    }

    //override
    void endVisit(SQLOver x) {
    }

    //override
    bool visit(SQLOver x) {
        return true;
    }
    
    //override
    void endVisit(SQLKeep x) {
    }
    
    //override
    bool visit(SQLKeep x) {
        return true;
    }

    //override
    void endVisit(SQLColumnPrimaryKey x) {

    }

    //override
    bool visit(SQLColumnPrimaryKey x) {
        return true;
    }

    //override
    void endVisit(SQLColumnUniqueKey x) {

    }

    //override
    bool visit(SQLColumnUniqueKey x) {
        return true;
    }

    //override
    void endVisit(SQLWithSubqueryClause x) {
    }

    //override
    bool visit(SQLWithSubqueryClause x) {
        return true;
    }

    //override
    void endVisit(SQLWithSubqueryClause.Entry x) {
    }

    //override
    bool visit(SQLWithSubqueryClause.Entry x) {
        return true;
    }

    //override
    bool visit(SQLCharacterDataType x) {
        return true;
    }

    //override
    void endVisit(SQLCharacterDataType x) {

    }

    //override
    void endVisit(SQLAlterTableAlterColumn x) {

    }

    //override
    bool visit(SQLAlterTableAlterColumn x) {
        return true;
    }

    //override
    bool visit(SQLCheck x) {
        return true;
    }

    //override
    void endVisit(SQLCheck x) {

    }

    //override
    bool visit(SQLAlterTableDropForeignKey x) {
        return true;
    }

    //override
    void endVisit(SQLAlterTableDropForeignKey x) {

    }

    //override
    bool visit(SQLAlterTableDropPrimaryKey x) {
        return true;
    }

    //override
    void endVisit(SQLAlterTableDropPrimaryKey x) {

    }

    //override
    bool visit(SQLAlterTableDisableKeys x) {
        return true;
    }

    //override
    void endVisit(SQLAlterTableDisableKeys x) {

    }

    //override
    bool visit(SQLAlterTableEnableKeys x) {
        return true;
    }

    //override
    void endVisit(SQLAlterTableEnableKeys x) {

    }

    //override
    bool visit(SQLAlterTableStatement x) {
        return true;
    }

    //override
    void endVisit(SQLAlterTableStatement x) {

    }

    //override
    bool visit(SQLAlterTableDisableConstraint x) {
        return true;
    }

    //override
    void endVisit(SQLAlterTableDisableConstraint x) {

    }

    //override
    bool visit(SQLAlterTableEnableConstraint x) {
        return true;
    }

    //override
    void endVisit(SQLAlterTableEnableConstraint x) {

    }

    //override
    bool visit(SQLColumnCheck x) {
        return true;
    }

    //override
    void endVisit(SQLColumnCheck x) {

    }

    //override
    bool visit(SQLExprHint x) {
        return true;
    }

    //override
    void endVisit(SQLExprHint x) {

    }

    //override
    bool visit(SQLAlterTableDropConstraint x) {
        return true;
    }

    //override
    void endVisit(SQLAlterTableDropConstraint x) {

    }

    //override
    bool visit(SQLUnique x) {
        foreach(SQLSelectOrderByItem column ; x.getColumns()) {
            column.accept(this);
        }
        return false;
    }

    //override
    void endVisit(SQLUnique x) {

    }

    //override
    bool visit(SQLCreateIndexStatement x) {
        return true;
    }

    //override
    void endVisit(SQLCreateIndexStatement x) {

    }

    //override
    bool visit(SQLPrimaryKeyImpl x) {
        return true;
    }

    //override
    void endVisit(SQLPrimaryKeyImpl x) {

    }

    //override
    bool visit(SQLAlterTableRenameColumn x) {
        return true;
    }

    //override
    void endVisit(SQLAlterTableRenameColumn x) {

    }

    //override
    bool visit(SQLColumnReference x) {
        return true;
    }

    //override
    void endVisit(SQLColumnReference x) {

    }

    //override
    bool visit(SQLForeignKeyImpl x) {
        return true;
    }

    //override
    void endVisit(SQLForeignKeyImpl x) {

    }

    //override
    bool visit(SQLDropSequenceStatement x) {
        return true;
    }

    //override
    void endVisit(SQLDropSequenceStatement x) {

    }

    //override
    bool visit(SQLDropTriggerStatement x) {
        return true;
    }

    //override
    void endVisit(SQLDropTriggerStatement x) {

    }

    //override
    void endVisit(SQLDropUserStatement x) {

    }

    //override
    bool visit(SQLDropUserStatement x) {
        return true;
    }

    //override
    void endVisit(SQLExplainStatement x) {

    }

    //override
    bool visit(SQLExplainStatement x) {
        return true;
    }

    //override
    void endVisit(SQLGrantStatement x) {

    }

    //override
    bool visit(SQLGrantStatement x) {
        return true;
    }

    //override
    void endVisit(SQLDropDatabaseStatement x) {

    }

    //override
    bool visit(SQLDropDatabaseStatement x) {
        return true;
    }

    //override
    void endVisit(SQLAlterTableAddIndex x) {

    }

    //override
    bool visit(SQLAlterTableAddIndex x) {
        return true;
    }

    //override
    void endVisit(SQLAlterTableAddConstraint x) {

    }

    //override
    bool visit(SQLAlterTableAddConstraint x) {
        return true;
    }

    //override
    void endVisit(SQLCreateTriggerStatement x) {

    }

    //override
    bool visit(SQLCreateTriggerStatement x) {
        return true;
    }

    //override
    void endVisit(SQLDropFunctionStatement x) {

    }

    //override
    bool visit(SQLDropFunctionStatement x) {
        return true;
    }

    //override
    void endVisit(SQLDropTableSpaceStatement x) {

    }

    //override
    bool visit(SQLDropTableSpaceStatement x) {
        return true;
    }

    //override
    void endVisit(SQLDropProcedureStatement x) {

    }

    //override
    bool visit(SQLDropProcedureStatement x) {
        return true;
    }

    //override
    void endVisit(SQLBooleanExpr x) {

    }

    //override
    bool visit(SQLBooleanExpr x) {
        return true;
    }

    //override
    void endVisit(SQLUnionQueryTableSource x) {

    }

    //override
    bool visit(SQLUnionQueryTableSource x) {
        return true;
    }

    //override
    void endVisit(SQLTimestampExpr x) {

    }

    //override
    bool visit(SQLTimestampExpr x) {
        return true;
    }

    //override
    void endVisit(SQLRevokeStatement x) {

    }

    //override
    bool visit(SQLRevokeStatement x) {
        return true;
    }

    //override
    void endVisit(SQLBinaryExpr x) {

    }

    //override
    bool visit(SQLBinaryExpr x) {
        return true;
    }

    //override
    void endVisit(SQLAlterTableRename x) {

    }

    //override
    bool visit(SQLAlterTableRename x) {
        return true;
    }

    //override
    void endVisit(SQLAlterViewRenameStatement x) {

    }

    //override
    bool visit(SQLAlterViewRenameStatement x) {
        return true;
    }

    //override
    void endVisit(SQLShowTablesStatement x) {

    }

    //override
    bool visit(SQLShowTablesStatement x) {
        return true;
    }

    //override
    void endVisit(SQLAlterTableAddPartition x) {

    }

    //override
    bool visit(SQLAlterTableAddPartition x) {
        return true;
    }

    //override
    void endVisit(SQLAlterTableDropPartition x) {

    }

    //override
    bool visit(SQLAlterTableDropPartition x) {
        return true;
    }

    //override
    void endVisit(SQLAlterTableRenamePartition x) {

    }

    //override
    bool visit(SQLAlterTableRenamePartition x) {
        return true;
    }

    //override
    void endVisit(SQLAlterTableSetComment x) {

    }

    //override
    bool visit(SQLAlterTableSetComment x) {
        return true;
    }

    //override
    void endVisit(SQLAlterTableSetLifecycle x) {

    }

    //override
    bool visit(SQLAlterTableSetLifecycle x) {
        return true;
    }

    //override
    void endVisit(SQLAlterTableEnableLifecycle x) {

    }

    //override
    bool visit(SQLAlterTableEnableLifecycle x) {
        return true;
    }

    //override
    void endVisit(SQLAlterTableDisableLifecycle x) {

    }

    //override
    bool visit(SQLAlterTableDisableLifecycle x) {
        return true;
    }

    //override
    void endVisit(SQLAlterTableTouch x) {

    }

    //override
    bool visit(SQLAlterTableTouch x) {
        return true;
    }

    //override
    void endVisit(SQLArrayExpr x) {

    }

    //override
    bool visit(SQLArrayExpr x) {
        return true;
    }

    //override
    void endVisit(SQLOpenStatement x) {

    }

    //override
    bool visit(SQLOpenStatement x) {
        return true;
    }

    //override
    void endVisit(SQLFetchStatement x) {

    }

    //override
    bool visit(SQLFetchStatement x) {
        return true;
    }

    //override
    void endVisit(SQLCloseStatement x) {

    }

    //override
    bool visit(SQLCloseStatement x) {
        return true;
    }

    //override
    bool visit(SQLGroupingSetExpr x) {
        return true;
    }

    //override
    void endVisit(SQLGroupingSetExpr x) {

    }

    //override
    bool visit(SQLIfStatement x) {
        return true;
    }

    //override
    void endVisit(SQLIfStatement x) {

    }

    //override
    bool visit(SQLIfStatement.Else x) {
        return true;
    }

    //override
    void endVisit(SQLIfStatement.Else x) {

    }

    //override
    bool visit(SQLIfStatement.ElseIf x) {
        return true;
    }

    //override
    void endVisit(SQLIfStatement.ElseIf x) {

    }

    //override
    bool visit(SQLLoopStatement x) {
        return true;
    }

    //override
    void endVisit(SQLLoopStatement x) {

    }

    //override
    bool visit(SQLParameter x) {
        return true;
    }

    //override
    void endVisit(SQLParameter x) {

    }

    //override
    bool visit(SQLCreateProcedureStatement x) {
        return true;
    }

    //override
    void endVisit(SQLCreateProcedureStatement x) {

    }

    //override
    bool visit(SQLCreateFunctionStatement x) {
        return true;
    }

    //override
    void endVisit(SQLCreateFunctionStatement x) {

    }

    //override
    bool visit(SQLBlockStatement x) {
        return true;
    }

    //override
    void endVisit(SQLBlockStatement x) {

    }

    //override
    bool visit(SQLAlterTableDropKey x) {
        return true;
    }

    //override
    void endVisit(SQLAlterTableDropKey x) {

    }

    //override
    bool visit(SQLDeclareItem x) {
        return true;
    }

    //override
    void endVisit(SQLDeclareItem x) {
    }

    //override
    bool visit(SQLPartitionValue x) {
        return true;
    }

    //override
    void endVisit(SQLPartitionValue x) {

    }

    //override
    bool visit(SQLPartition x) {
        return true;
    }

    //override
    void endVisit(SQLPartition x) {

    }

    //override
    bool visit(SQLPartitionByRange x) {
        return true;
    }

    //override
    void endVisit(SQLPartitionByRange x) {

    }

    //override
    bool visit(SQLPartitionByHash x) {
        return true;
    }

    //override
    void endVisit(SQLPartitionByHash x) {

    }

    //override
    bool visit(SQLPartitionByList x) {
        return true;
    }

    //override
    void endVisit(SQLPartitionByList x) {

    }

    //override
    bool visit(SQLSubPartition x) {
        return true;
    }

    //override
    void endVisit(SQLSubPartition x) {

    }

    //override
    bool visit(SQLSubPartitionByHash x) {
        return true;
    }

    //override
    void endVisit(SQLSubPartitionByHash x) {

    }

    //override
    bool visit(SQLSubPartitionByList x) {
        return true;
    }

    //override
    void endVisit(SQLSubPartitionByList x) {

    }

    //override
    bool visit(SQLAlterDatabaseStatement x) {
        return true;
    }

    //override
    void endVisit(SQLAlterDatabaseStatement x) {

    }

    //override
    bool visit(SQLAlterTableConvertCharSet x) {
        return true;
    }

    //override
    void endVisit(SQLAlterTableConvertCharSet x) {

    }

    //override
    bool visit(SQLAlterTableReOrganizePartition x) {
        return true;
    }

    //override
    void endVisit(SQLAlterTableReOrganizePartition x) {

    }

    //override
    bool visit(SQLAlterTableCoalescePartition x) {
        return true;
    }

    //override
    void endVisit(SQLAlterTableCoalescePartition x) {

    }

    //override
    bool visit(SQLAlterTableTruncatePartition x) {
        return true;
    }

    //override
    void endVisit(SQLAlterTableTruncatePartition x) {

    }

    //override
    bool visit(SQLAlterTableDiscardPartition x) {
        return true;
    }

    //override
    void endVisit(SQLAlterTableDiscardPartition x) {

    }

    //override
    bool visit(SQLAlterTableImportPartition x) {
        return true;
    }

    //override
    void endVisit(SQLAlterTableImportPartition x) {

    }

    //override
    bool visit(SQLAlterTableAnalyzePartition x) {
        return true;
    }

    //override
    void endVisit(SQLAlterTableAnalyzePartition x) {

    }

    //override
    bool visit(SQLAlterTableCheckPartition x) {
        return true;
    }

    //override
    void endVisit(SQLAlterTableCheckPartition x) {

    }

    //override
    bool visit(SQLAlterTableOptimizePartition x) {
        return true;
    }

    //override
    void endVisit(SQLAlterTableOptimizePartition x) {

    }

    //override
    bool visit(SQLAlterTableRebuildPartition x) {
        return true;
    }

    //override
    void endVisit(SQLAlterTableRebuildPartition x) {

    }

    //override
    bool visit(SQLAlterTableRepairPartition x) {
        return true;
    }

    //override
    void endVisit(SQLAlterTableRepairPartition x) {

    }
    
    //override
    bool visit(SQLSequenceExpr x) {
        return true;
    }
    
    //override
    void endVisit(SQLSequenceExpr x) {
        
    }

    //override
    bool visit(SQLMergeStatement x) {
        return true;
    }

    //override
    void endVisit(SQLMergeStatement x) {
        
    }

    //override
    bool visit(SQLMergeStatement.MergeUpdateClause x) {
        return true;
    }

    //override
    void endVisit(SQLMergeStatement.MergeUpdateClause x) {
        
    }

    //override
    bool visit(SQLMergeStatement.MergeInsertClause x) {
        return true;
    }

    //override
    void endVisit(SQLMergeStatement.MergeInsertClause x) {
        
    }

    //override
    bool visit(SQLErrorLoggingClause x) {
        return true;
    }

    //override
    void endVisit(SQLErrorLoggingClause x) {

    }

    //override
    bool visit(SQLNullConstraint x) {
	return true;
    }

    //override
    void endVisit(SQLNullConstraint x) {
    }

    //override
    bool visit(SQLCreateSequenceStatement x) {
        return true;
    }

    //override
    void endVisit(SQLCreateSequenceStatement x) {
    }

    //override
    bool visit(SQLDateExpr x) {
        return true;
    }

    //override
    void endVisit(SQLDateExpr x) {

    }

    //override
    bool visit(SQLLimit x) {
        return true;
    }

    //override
    void endVisit(SQLLimit x) {

    }

    //override
    void endVisit(SQLStartTransactionStatement x) {

    }

    //override
    bool visit(SQLStartTransactionStatement x) {
        return true;
    }

    //override
    void endVisit(SQLDescribeStatement x) {

    }

    //override
    bool visit(SQLDescribeStatement x) {
        return true;
    }

    //override
    bool visit(SQLWhileStatement x) {
        return true;
    }

    //override
    void endVisit(SQLWhileStatement x) {

    }


    //override
    bool visit(SQLDeclareStatement x) {
        return true;
    }

    //override
    void endVisit(SQLDeclareStatement x) {

    }

    //override
    bool visit(SQLReturnStatement x) {
        return true;
    }

    //override
    void endVisit(SQLReturnStatement x) {

    }

    //override
    bool visit(SQLArgument x) {
        return true;
    }

    //override
    void endVisit(SQLArgument x) {

    }

    //override
    bool visit(SQLCommitStatement x) {
        return true;
    }

    //override
    void endVisit(SQLCommitStatement x) {

    }

    //override
    bool visit(SQLFlashbackExpr x) {
        return true;
    }

    //override
    void endVisit(SQLFlashbackExpr x) {

    }

    //override
    bool visit(SQLCreateMaterializedViewStatement x) {
        return true;
    }

    //override
    void endVisit(SQLCreateMaterializedViewStatement x) {

    }

    //override
    bool visit(SQLBinaryOpExprGroup x) {
        return true;
    }

    //override
    void endVisit(SQLBinaryOpExprGroup x) {

    }

    void config(VisitorFeature feature, bool state) {
        features = VisitorFeature.config(features, feature, state);
    }

    //override
    bool visit(SQLScriptCommitStatement x) {
        return true;
    }

    //override
    void endVisit(SQLScriptCommitStatement x) {

    }

    //override
    bool visit(SQLReplaceStatement x) {
        return true;
    }

    //override
    void endVisit(SQLReplaceStatement x) {

    }

    //override
    bool visit(SQLCreateUserStatement x) {
        return true;
    }

    //override
    void endVisit(SQLCreateUserStatement x) {

    }

    //override
    bool visit(SQLAlterFunctionStatement x) {
        return true;
    }

    //override
    void endVisit(SQLAlterFunctionStatement x) {

    }

    //override
    bool visit(SQLAlterTypeStatement x) {
        return true;
    }

    //override
    void endVisit(SQLAlterTypeStatement x) {

    }

    //override
    bool visit(SQLIntervalExpr x) {
        return true;
    }

    //override
    void endVisit(SQLIntervalExpr x) {

    }

    //override
    bool visit(SQLLateralViewTableSource x) {
        return true;
    }

    //override
    void endVisit(SQLLateralViewTableSource x) {

    }

    //override
    bool visit(SQLShowErrorsStatement x) {
        return true;
    }

    //override
    void endVisit(SQLShowErrorsStatement x) {

    }

    //override
    bool visit(SQLAlterCharacter x) {
        return true;
    }

    //override
    void endVisit(SQLAlterCharacter x) {

    }

    //override
    bool visit(SQLExprStatement x) {
        return true;
    }

    //override
    void endVisit(SQLExprStatement x) {

    }

    //override
    bool visit(SQLAlterProcedureStatement x) {
        return true;
    }

    //override
    void endVisit(SQLAlterProcedureStatement x) {

    }

    //override
    bool visit(SQLDropEventStatement x) {
        return true;
    }

    //override
    void endVisit(SQLDropEventStatement x) {

    }

    //override
    bool visit(SQLDropLogFileGroupStatement x) {
        return true;
    }

    //override
    void endVisit(SQLDropLogFileGroupStatement x) {

    }

    //override
    bool visit(SQLDropServerStatement x) {
        return true;
    }

    //override
    void endVisit(SQLDropServerStatement x) {

    }

    //override
    bool visit(SQLDropSynonymStatement x) {
        return true;
    }

    //override
    void endVisit(SQLDropSynonymStatement x) {

    }

    //override
    bool visit(SQLDropTypeStatement x) {
        return true;
    }

    //override
    void endVisit(SQLDropTypeStatement x) {

    }

    //override
    bool visit(SQLRecordDataType x) {
        return true;
    }

    //override
    void endVisit(SQLRecordDataType x) {

    }

    bool visit(SQLExternalRecordFormat x) {
        return true;
    }

    void endVisit(SQLExternalRecordFormat x) {

    }

    //override
    bool visit(SQLArrayDataType x) {
        return true;
    }

    //override
    void endVisit(SQLArrayDataType x) {

    }

    //override
    bool visit(SQLMapDataType x) {
        return true;
    }

    //override
    void endVisit(SQLMapDataType x) {

    }

    //override
    bool visit(SQLStructDataType x) {
        return true;
    }

    //override
    void endVisit(SQLStructDataType x) {

    }

    //override
    bool visit(SQLStructDataType.Field x) {
        return true;
    }

    //override
    void endVisit(SQLStructDataType.Field x) {

    }

    //override
    bool visit(SQLDropMaterializedViewStatement x) {
        return true;
    }

    //override
    void endVisit(SQLDropMaterializedViewStatement x) {

    }

    //override
    bool visit(SQLAlterTableRenameIndex x) {
        return true;
    }

    //override
    void endVisit(SQLAlterTableRenameIndex x) {

    }

    //override
    bool visit(SQLAlterSequenceStatement x) {
        return true;
    }

    //override
    void endVisit(SQLAlterSequenceStatement x) {

    }

    //override
    bool visit(SQLAlterTableExchangePartition x) {
        return true;
    }

    //override
    void endVisit(SQLAlterTableExchangePartition x) {

    }

    //override
    bool visit(SQLValuesExpr x) {
        return true;
    }

    //override
    void endVisit(SQLValuesExpr x) {

    }

    //override
    bool visit(SQLValuesTableSource x) {
        return true;
    }

    void endVisit(SQLValuesTableSource x) {

    }

    //override
    bool visit(SQLContainsExpr x) {
        return true;
    }

    void endVisit(SQLContainsExpr x) {

    }

    //override
    bool visit(SQLRealExpr x) {
        return true;
    }

    void endVisit(SQLRealExpr x) {

    }

    //override
    bool visit(SQLWindow x) {
        return true;
    }

    void endVisit(SQLWindow x) {

    }

    //override
    bool visit(SQLDumpStatement x) {
        return true;
    }

    void endVisit(SQLDumpStatement x) {

    }

     bool isEnabled(VisitorFeature feature) {
        return VisitorFeature.isEnabled(this.features, feature);
    }

    int getFeatures() {
        return features;
    }

    void setFeatures(int features) {
        this.features = features;
    }
}
