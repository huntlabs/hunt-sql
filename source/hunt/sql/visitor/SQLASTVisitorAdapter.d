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


public class SQLASTVisitorAdapter : SQLASTVisitor {
    protected int features;

    public void endVisit(SQLAllColumnExpr x) {
    }

    public void endVisit(SQLBetweenExpr x) {
    }

    public void endVisit(SQLBinaryOpExpr x) {
    }

    public void endVisit(SQLCaseExpr x) {
    }

    public void endVisit(SQLCaseExpr.Item x) {
    }

    public void endVisit(SQLCaseStatement x) {
    }

    public void endVisit(SQLCaseStatement.Item x) {
    }

    public void endVisit(SQLCharExpr x) {
    }

    public void endVisit(SQLIdentifierExpr x) {
    }

    public void endVisit(SQLInListExpr x) {
    }

    public void endVisit(SQLIntegerExpr x) {
    }

    public void endVisit(SQLExistsExpr x) {
    }

    public void endVisit(SQLNCharExpr x) {
    }

    public void endVisit(SQLNotExpr x) {
    }

    public void endVisit(SQLNullExpr x) {
    }

    public void endVisit(SQLNumberExpr x) {
    }

    public void endVisit(SQLPropertyExpr x) {
    }

    public void endVisit(SQLSelectGroupByClause x) {
    }

    public void endVisit(SQLSelectItem x) {
    }

    public void endVisit(SQLSelectStatement selectStatement) {
    }

    public void postVisit(SQLObject astNode) {
    }

    public void preVisit(SQLObject astNode) {
    }

    public bool visit(SQLAllColumnExpr x) {
        return true;
    }

    public bool visit(SQLBetweenExpr x) {
        return true;
    }

    public bool visit(SQLBinaryOpExpr x) {
        return true;
    }

    public bool visit(SQLCaseExpr x) {
        return true;
    }

    public bool visit(SQLCaseExpr.Item x) {
        return true;
    }

    public bool visit(SQLCaseStatement x) {
        return true;
    }

    public bool visit(SQLCaseStatement.Item x) {
        return true;
    }

    public bool visit(SQLCastExpr x) {
        return true;
    }

    public bool visit(SQLCharExpr x) {
        return true;
    }

    public bool visit(SQLExistsExpr x) {
        return true;
    }

    public bool visit(SQLIdentifierExpr x) {
        return true;
    }

    public bool visit(SQLInListExpr x) {
        return true;
    }

    public bool visit(SQLIntegerExpr x) {
        return true;
    }

    public bool visit(SQLNCharExpr x) {
        return true;
    }

    public bool visit(SQLNotExpr x) {
        return true;
    }

    public bool visit(SQLNullExpr x) {
        return true;
    }

    public bool visit(SQLNumberExpr x) {
        return true;
    }

    public bool visit(SQLPropertyExpr x) {
        return true;
    }

    public bool visit(SQLSelectGroupByClause x) {
        return true;
    }

    public bool visit(SQLSelectItem x) {
        return true;
    }

    public void endVisit(SQLCastExpr x) {
    }

    public bool visit(SQLSelectStatement astNode) {
        return true;
    }

    public void endVisit(SQLAggregateExpr x) {
    }

    public bool visit(SQLAggregateExpr x) {
        return true;
    }

    public bool visit(SQLVariantRefExpr x) {
        return true;
    }

    public void endVisit(SQLVariantRefExpr x) {
    }

    public bool visit(SQLQueryExpr x) {
        return true;
    }

    public void endVisit(SQLQueryExpr x) {
    }

    public bool visit(SQLSelect x) {
        return true;
    }

    public void endVisit(SQLSelect select) {
    }

    public bool visit(SQLSelectQueryBlock x) {
        return true;
    }

    public void endVisit(SQLSelectQueryBlock x) {
    }

    public bool visit(SQLExprTableSource x) {
        return true;
    }

    public void endVisit(SQLExprTableSource x) {
    }

    public bool visit(SQLOrderBy x) {
        return true;
    }

    public void endVisit(SQLOrderBy x) {
    }

    public bool visit(SQLSelectOrderByItem x) {
        return true;
    }

    public void endVisit(SQLSelectOrderByItem x) {
    }

    public bool visit(SQLDropTableStatement x) {
        return true;
    }

    public void endVisit(SQLDropTableStatement x) {
    }

    public bool visit(SQLCreateTableStatement x) {
        return true;
    }

    public void endVisit(SQLCreateTableStatement x) {
    }

    public bool visit(SQLColumnDefinition x) {
        return true;
    }

    public void endVisit(SQLColumnDefinition x) {
    }

    public bool visit(SQLColumnDefinition.Identity x) {
        return true;
    }

    public void endVisit(SQLColumnDefinition.Identity x) {
    }

    public bool visit(SQLDataType x) {
        return true;
    }

    public void endVisit(SQLDataType x) {
    }

    public bool visit(SQLDeleteStatement x) {
        return true;
    }

    public void endVisit(SQLDeleteStatement x) {
    }

    public bool visit(SQLCurrentOfCursorExpr x) {
        return true;
    }

    public void endVisit(SQLCurrentOfCursorExpr x) {
    }

    public bool visit(SQLInsertStatement x) {
        return true;
    }

    public void endVisit(SQLInsertStatement x) {
    }

    public bool visit(SQLUpdateSetItem x) {
        return true;
    }

    public void endVisit(SQLUpdateSetItem x) {
    }

    public bool visit(SQLUpdateStatement x) {
        return true;
    }

    public void endVisit(SQLUpdateStatement x) {
    }

    public bool visit(SQLCreateViewStatement x) {
        return true;
    }

    public void endVisit(SQLCreateViewStatement x) {
    }

    public bool visit(SQLAlterViewStatement x) {
        return true;
    }

    public void endVisit(SQLAlterViewStatement x) {
    }

    public bool visit(SQLCreateViewStatement.Column x) {
        return true;
    }

    public void endVisit(SQLCreateViewStatement.Column x) {
    }

    public bool visit(SQLNotNullConstraint x) {
        return true;
    }

    public void endVisit(SQLNotNullConstraint x) {
    }

    //override
    public void endVisit(SQLMethodInvokeExpr x) {

    }

    //override
    public bool visit(SQLMethodInvokeExpr x) {
        return true;
    }

    //override
    public void endVisit(SQLUnionQuery x) {

    }

    //override
    public bool visit(SQLUnionQuery x) {
        return true;
    }

    //override
    public bool visit(SQLUnaryExpr x) {
        return true;
    }

    //override
    public void endVisit(SQLUnaryExpr x) {

    }

    //override
    public bool visit(SQLHexExpr x) {
        return false;
    }

    //override
    public void endVisit(SQLHexExpr x) {

    }

    //override
    public void endVisit(SQLSetStatement x) {

    }

    //override
    public bool visit(SQLSetStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLAssignItem x) {

    }

    //override
    public bool visit(SQLAssignItem x) {
        return true;
    }

    //override
    public void endVisit(SQLCallStatement x) {

    }

    //override
    public bool visit(SQLCallStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLJoinTableSource x) {

    }

    //override
    public bool visit(SQLJoinTableSource x) {
        return true;
    }

    //override
    public bool visit(ValuesClause x) {
        return true;
    }

    //override
    public void endVisit(ValuesClause x) {

    }

    //override
    public void endVisit(SQLSomeExpr x) {

    }

    //override
    public bool visit(SQLSomeExpr x) {
        return true;
    }

    //override
    public void endVisit(SQLAnyExpr x) {

    }

    //override
    public bool visit(SQLAnyExpr x) {
        return true;
    }

    //override
    public void endVisit(SQLAllExpr x) {

    }

    //override
    public bool visit(SQLAllExpr x) {
        return true;
    }

    //override
    public void endVisit(SQLInSubQueryExpr x) {

    }

    //override
    public bool visit(SQLInSubQueryExpr x) {
        return true;
    }

    //override
    public void endVisit(SQLListExpr x) {

    }

    //override
    public bool visit(SQLListExpr x) {
        return true;
    }

    //override
    public void endVisit(SQLSubqueryTableSource x) {

    }

    //override
    public bool visit(SQLSubqueryTableSource x) {
        return true;
    }

    //override
    public void endVisit(SQLTruncateStatement x) {

    }

    //override
    public bool visit(SQLTruncateStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLDefaultExpr x) {

    }

    //override
    public bool visit(SQLDefaultExpr x) {
        return true;
    }

    //override
    public void endVisit(SQLCommentStatement x) {

    }

    //override
    public bool visit(SQLCommentStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLUseStatement x) {

    }

    //override
    public bool visit(SQLUseStatement x) {
        return true;
    }

    //override
    public bool visit(SQLAlterTableAddColumn x) {
        return true;
    }

    //override
    public void endVisit(SQLAlterTableAddColumn x) {

    }

    //override
    public bool visit(SQLAlterTableDropColumnItem x) {
        return true;
    }

    //override
    public void endVisit(SQLAlterTableDropColumnItem x) {

    }

    //override
    public bool visit(SQLDropIndexStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLDropIndexStatement x) {

    }

    //override
    public bool visit(SQLDropViewStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLDropViewStatement x) {

    }

    //override
    public bool visit(SQLSavePointStatement x) {
        return false;
    }

    //override
    public void endVisit(SQLSavePointStatement x) {

    }

    //override
    public bool visit(SQLRollbackStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLRollbackStatement x) {

    }

    //override
    public bool visit(SQLReleaseSavePointStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLReleaseSavePointStatement x) {
    }

    //override
    public bool visit(SQLCommentHint x) {
        return true;
    }

    //override
    public void endVisit(SQLCommentHint x) {

    }

    //override
    public void endVisit(SQLCreateDatabaseStatement x) {

    }

    //override
    public bool visit(SQLCreateDatabaseStatement x) {
        return true;
    }

    //override
    public bool visit(SQLAlterTableDropIndex x) {
        return true;
    }

    //override
    public void endVisit(SQLAlterTableDropIndex x) {

    }

    //override
    public void endVisit(SQLOver x) {
    }

    //override
    public bool visit(SQLOver x) {
        return true;
    }
    
    //override
    public void endVisit(SQLKeep x) {
    }
    
    //override
    public bool visit(SQLKeep x) {
        return true;
    }

    //override
    public void endVisit(SQLColumnPrimaryKey x) {

    }

    //override
    public bool visit(SQLColumnPrimaryKey x) {
        return true;
    }

    //override
    public void endVisit(SQLColumnUniqueKey x) {

    }

    //override
    public bool visit(SQLColumnUniqueKey x) {
        return true;
    }

    //override
    public void endVisit(SQLWithSubqueryClause x) {
    }

    //override
    public bool visit(SQLWithSubqueryClause x) {
        return true;
    }

    //override
    public void endVisit(SQLWithSubqueryClause.Entry x) {
    }

    //override
    public bool visit(SQLWithSubqueryClause.Entry x) {
        return true;
    }

    //override
    public bool visit(SQLCharacterDataType x) {
        return true;
    }

    //override
    public void endVisit(SQLCharacterDataType x) {

    }

    //override
    public void endVisit(SQLAlterTableAlterColumn x) {

    }

    //override
    public bool visit(SQLAlterTableAlterColumn x) {
        return true;
    }

    //override
    public bool visit(SQLCheck x) {
        return true;
    }

    //override
    public void endVisit(SQLCheck x) {

    }

    //override
    public bool visit(SQLAlterTableDropForeignKey x) {
        return true;
    }

    //override
    public void endVisit(SQLAlterTableDropForeignKey x) {

    }

    //override
    public bool visit(SQLAlterTableDropPrimaryKey x) {
        return true;
    }

    //override
    public void endVisit(SQLAlterTableDropPrimaryKey x) {

    }

    //override
    public bool visit(SQLAlterTableDisableKeys x) {
        return true;
    }

    //override
    public void endVisit(SQLAlterTableDisableKeys x) {

    }

    //override
    public bool visit(SQLAlterTableEnableKeys x) {
        return true;
    }

    //override
    public void endVisit(SQLAlterTableEnableKeys x) {

    }

    //override
    public bool visit(SQLAlterTableStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLAlterTableStatement x) {

    }

    //override
    public bool visit(SQLAlterTableDisableConstraint x) {
        return true;
    }

    //override
    public void endVisit(SQLAlterTableDisableConstraint x) {

    }

    //override
    public bool visit(SQLAlterTableEnableConstraint x) {
        return true;
    }

    //override
    public void endVisit(SQLAlterTableEnableConstraint x) {

    }

    //override
    public bool visit(SQLColumnCheck x) {
        return true;
    }

    //override
    public void endVisit(SQLColumnCheck x) {

    }

    //override
    public bool visit(SQLExprHint x) {
        return true;
    }

    //override
    public void endVisit(SQLExprHint x) {

    }

    //override
    public bool visit(SQLAlterTableDropConstraint x) {
        return true;
    }

    //override
    public void endVisit(SQLAlterTableDropConstraint x) {

    }

    //override
    public bool visit(SQLUnique x) {
        foreach(SQLSelectOrderByItem column ; x.getColumns()) {
            column.accept(this);
        }
        return false;
    }

    //override
    public void endVisit(SQLUnique x) {

    }

    //override
    public bool visit(SQLCreateIndexStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLCreateIndexStatement x) {

    }

    //override
    public bool visit(SQLPrimaryKeyImpl x) {
        return true;
    }

    //override
    public void endVisit(SQLPrimaryKeyImpl x) {

    }

    //override
    public bool visit(SQLAlterTableRenameColumn x) {
        return true;
    }

    //override
    public void endVisit(SQLAlterTableRenameColumn x) {

    }

    //override
    public bool visit(SQLColumnReference x) {
        return true;
    }

    //override
    public void endVisit(SQLColumnReference x) {

    }

    //override
    public bool visit(SQLForeignKeyImpl x) {
        return true;
    }

    //override
    public void endVisit(SQLForeignKeyImpl x) {

    }

    //override
    public bool visit(SQLDropSequenceStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLDropSequenceStatement x) {

    }

    //override
    public bool visit(SQLDropTriggerStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLDropTriggerStatement x) {

    }

    //override
    public void endVisit(SQLDropUserStatement x) {

    }

    //override
    public bool visit(SQLDropUserStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLExplainStatement x) {

    }

    //override
    public bool visit(SQLExplainStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLGrantStatement x) {

    }

    //override
    public bool visit(SQLGrantStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLDropDatabaseStatement x) {

    }

    //override
    public bool visit(SQLDropDatabaseStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLAlterTableAddIndex x) {

    }

    //override
    public bool visit(SQLAlterTableAddIndex x) {
        return true;
    }

    //override
    public void endVisit(SQLAlterTableAddConstraint x) {

    }

    //override
    public bool visit(SQLAlterTableAddConstraint x) {
        return true;
    }

    //override
    public void endVisit(SQLCreateTriggerStatement x) {

    }

    //override
    public bool visit(SQLCreateTriggerStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLDropFunctionStatement x) {

    }

    //override
    public bool visit(SQLDropFunctionStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLDropTableSpaceStatement x) {

    }

    //override
    public bool visit(SQLDropTableSpaceStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLDropProcedureStatement x) {

    }

    //override
    public bool visit(SQLDropProcedureStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLBooleanExpr x) {

    }

    //override
    public bool visit(SQLBooleanExpr x) {
        return true;
    }

    //override
    public void endVisit(SQLUnionQueryTableSource x) {

    }

    //override
    public bool visit(SQLUnionQueryTableSource x) {
        return true;
    }

    //override
    public void endVisit(SQLTimestampExpr x) {

    }

    //override
    public bool visit(SQLTimestampExpr x) {
        return true;
    }

    //override
    public void endVisit(SQLRevokeStatement x) {

    }

    //override
    public bool visit(SQLRevokeStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLBinaryExpr x) {

    }

    //override
    public bool visit(SQLBinaryExpr x) {
        return true;
    }

    //override
    public void endVisit(SQLAlterTableRename x) {

    }

    //override
    public bool visit(SQLAlterTableRename x) {
        return true;
    }

    //override
    public void endVisit(SQLAlterViewRenameStatement x) {

    }

    //override
    public bool visit(SQLAlterViewRenameStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLShowTablesStatement x) {

    }

    //override
    public bool visit(SQLShowTablesStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLAlterTableAddPartition x) {

    }

    //override
    public bool visit(SQLAlterTableAddPartition x) {
        return true;
    }

    //override
    public void endVisit(SQLAlterTableDropPartition x) {

    }

    //override
    public bool visit(SQLAlterTableDropPartition x) {
        return true;
    }

    //override
    public void endVisit(SQLAlterTableRenamePartition x) {

    }

    //override
    public bool visit(SQLAlterTableRenamePartition x) {
        return true;
    }

    //override
    public void endVisit(SQLAlterTableSetComment x) {

    }

    //override
    public bool visit(SQLAlterTableSetComment x) {
        return true;
    }

    //override
    public void endVisit(SQLAlterTableSetLifecycle x) {

    }

    //override
    public bool visit(SQLAlterTableSetLifecycle x) {
        return true;
    }

    //override
    public void endVisit(SQLAlterTableEnableLifecycle x) {

    }

    //override
    public bool visit(SQLAlterTableEnableLifecycle x) {
        return true;
    }

    //override
    public void endVisit(SQLAlterTableDisableLifecycle x) {

    }

    //override
    public bool visit(SQLAlterTableDisableLifecycle x) {
        return true;
    }

    //override
    public void endVisit(SQLAlterTableTouch x) {

    }

    //override
    public bool visit(SQLAlterTableTouch x) {
        return true;
    }

    //override
    public void endVisit(SQLArrayExpr x) {

    }

    //override
    public bool visit(SQLArrayExpr x) {
        return true;
    }

    //override
    public void endVisit(SQLOpenStatement x) {

    }

    //override
    public bool visit(SQLOpenStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLFetchStatement x) {

    }

    //override
    public bool visit(SQLFetchStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLCloseStatement x) {

    }

    //override
    public bool visit(SQLCloseStatement x) {
        return true;
    }

    //override
    public bool visit(SQLGroupingSetExpr x) {
        return true;
    }

    //override
    public void endVisit(SQLGroupingSetExpr x) {

    }

    //override
    public bool visit(SQLIfStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLIfStatement x) {

    }

    //override
    public bool visit(SQLIfStatement.Else x) {
        return true;
    }

    //override
    public void endVisit(SQLIfStatement.Else x) {

    }

    //override
    public bool visit(SQLIfStatement.ElseIf x) {
        return true;
    }

    //override
    public void endVisit(SQLIfStatement.ElseIf x) {

    }

    //override
    public bool visit(SQLLoopStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLLoopStatement x) {

    }

    //override
    public bool visit(SQLParameter x) {
        return true;
    }

    //override
    public void endVisit(SQLParameter x) {

    }

    //override
    public bool visit(SQLCreateProcedureStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLCreateProcedureStatement x) {

    }

    //override
    public bool visit(SQLCreateFunctionStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLCreateFunctionStatement x) {

    }

    //override
    public bool visit(SQLBlockStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLBlockStatement x) {

    }

    //override
    public bool visit(SQLAlterTableDropKey x) {
        return true;
    }

    //override
    public void endVisit(SQLAlterTableDropKey x) {

    }

    //override
    public bool visit(SQLDeclareItem x) {
        return true;
    }

    //override
    public void endVisit(SQLDeclareItem x) {
    }

    //override
    public bool visit(SQLPartitionValue x) {
        return true;
    }

    //override
    public void endVisit(SQLPartitionValue x) {

    }

    //override
    public bool visit(SQLPartition x) {
        return true;
    }

    //override
    public void endVisit(SQLPartition x) {

    }

    //override
    public bool visit(SQLPartitionByRange x) {
        return true;
    }

    //override
    public void endVisit(SQLPartitionByRange x) {

    }

    //override
    public bool visit(SQLPartitionByHash x) {
        return true;
    }

    //override
    public void endVisit(SQLPartitionByHash x) {

    }

    //override
    public bool visit(SQLPartitionByList x) {
        return true;
    }

    //override
    public void endVisit(SQLPartitionByList x) {

    }

    //override
    public bool visit(SQLSubPartition x) {
        return true;
    }

    //override
    public void endVisit(SQLSubPartition x) {

    }

    //override
    public bool visit(SQLSubPartitionByHash x) {
        return true;
    }

    //override
    public void endVisit(SQLSubPartitionByHash x) {

    }

    //override
    public bool visit(SQLSubPartitionByList x) {
        return true;
    }

    //override
    public void endVisit(SQLSubPartitionByList x) {

    }

    //override
    public bool visit(SQLAlterDatabaseStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLAlterDatabaseStatement x) {

    }

    //override
    public bool visit(SQLAlterTableConvertCharSet x) {
        return true;
    }

    //override
    public void endVisit(SQLAlterTableConvertCharSet x) {

    }

    //override
    public bool visit(SQLAlterTableReOrganizePartition x) {
        return true;
    }

    //override
    public void endVisit(SQLAlterTableReOrganizePartition x) {

    }

    //override
    public bool visit(SQLAlterTableCoalescePartition x) {
        return true;
    }

    //override
    public void endVisit(SQLAlterTableCoalescePartition x) {

    }

    //override
    public bool visit(SQLAlterTableTruncatePartition x) {
        return true;
    }

    //override
    public void endVisit(SQLAlterTableTruncatePartition x) {

    }

    //override
    public bool visit(SQLAlterTableDiscardPartition x) {
        return true;
    }

    //override
    public void endVisit(SQLAlterTableDiscardPartition x) {

    }

    //override
    public bool visit(SQLAlterTableImportPartition x) {
        return true;
    }

    //override
    public void endVisit(SQLAlterTableImportPartition x) {

    }

    //override
    public bool visit(SQLAlterTableAnalyzePartition x) {
        return true;
    }

    //override
    public void endVisit(SQLAlterTableAnalyzePartition x) {

    }

    //override
    public bool visit(SQLAlterTableCheckPartition x) {
        return true;
    }

    //override
    public void endVisit(SQLAlterTableCheckPartition x) {

    }

    //override
    public bool visit(SQLAlterTableOptimizePartition x) {
        return true;
    }

    //override
    public void endVisit(SQLAlterTableOptimizePartition x) {

    }

    //override
    public bool visit(SQLAlterTableRebuildPartition x) {
        return true;
    }

    //override
    public void endVisit(SQLAlterTableRebuildPartition x) {

    }

    //override
    public bool visit(SQLAlterTableRepairPartition x) {
        return true;
    }

    //override
    public void endVisit(SQLAlterTableRepairPartition x) {

    }
    
    //override
    public bool visit(SQLSequenceExpr x) {
        return true;
    }
    
    //override
    public void endVisit(SQLSequenceExpr x) {
        
    }

    //override
    public bool visit(SQLMergeStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLMergeStatement x) {
        
    }

    //override
    public bool visit(SQLMergeStatement.MergeUpdateClause x) {
        return true;
    }

    //override
    public void endVisit(SQLMergeStatement.MergeUpdateClause x) {
        
    }

    //override
    public bool visit(SQLMergeStatement.MergeInsertClause x) {
        return true;
    }

    //override
    public void endVisit(SQLMergeStatement.MergeInsertClause x) {
        
    }

    //override
    public bool visit(SQLErrorLoggingClause x) {
        return true;
    }

    //override
    public void endVisit(SQLErrorLoggingClause x) {

    }

    //override
    public bool visit(SQLNullConstraint x) {
	return true;
    }

    //override
    public void endVisit(SQLNullConstraint x) {
    }

    //override
    public bool visit(SQLCreateSequenceStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLCreateSequenceStatement x) {
    }

    //override
    public bool visit(SQLDateExpr x) {
        return true;
    }

    //override
    public void endVisit(SQLDateExpr x) {

    }

    //override
    public bool visit(SQLLimit x) {
        return true;
    }

    //override
    public void endVisit(SQLLimit x) {

    }

    //override
    public void endVisit(SQLStartTransactionStatement x) {

    }

    //override
    public bool visit(SQLStartTransactionStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLDescribeStatement x) {

    }

    //override
    public bool visit(SQLDescribeStatement x) {
        return true;
    }

    //override
    public bool visit(SQLWhileStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLWhileStatement x) {

    }


    //override
    public bool visit(SQLDeclareStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLDeclareStatement x) {

    }

    //override
    public bool visit(SQLReturnStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLReturnStatement x) {

    }

    //override
    public bool visit(SQLArgument x) {
        return true;
    }

    //override
    public void endVisit(SQLArgument x) {

    }

    //override
    public bool visit(SQLCommitStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLCommitStatement x) {

    }

    //override
    public bool visit(SQLFlashbackExpr x) {
        return true;
    }

    //override
    public void endVisit(SQLFlashbackExpr x) {

    }

    //override
    public bool visit(SQLCreateMaterializedViewStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLCreateMaterializedViewStatement x) {

    }

    //override
    public bool visit(SQLBinaryOpExprGroup x) {
        return true;
    }

    //override
    public void endVisit(SQLBinaryOpExprGroup x) {

    }

    public void config(VisitorFeature feature, bool state) {
        features = VisitorFeature.config(features, feature, state);
    }

    //override
    public bool visit(SQLScriptCommitStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLScriptCommitStatement x) {

    }

    //override
    public bool visit(SQLReplaceStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLReplaceStatement x) {

    }

    //override
    public bool visit(SQLCreateUserStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLCreateUserStatement x) {

    }

    //override
    public bool visit(SQLAlterFunctionStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLAlterFunctionStatement x) {

    }

    //override
    public bool visit(SQLAlterTypeStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLAlterTypeStatement x) {

    }

    //override
    public bool visit(SQLIntervalExpr x) {
        return true;
    }

    //override
    public void endVisit(SQLIntervalExpr x) {

    }

    //override
    public bool visit(SQLLateralViewTableSource x) {
        return true;
    }

    //override
    public void endVisit(SQLLateralViewTableSource x) {

    }

    //override
    public bool visit(SQLShowErrorsStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLShowErrorsStatement x) {

    }

    //override
    public bool visit(SQLAlterCharacter x) {
        return true;
    }

    //override
    public void endVisit(SQLAlterCharacter x) {

    }

    //override
    public bool visit(SQLExprStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLExprStatement x) {

    }

    //override
    public bool visit(SQLAlterProcedureStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLAlterProcedureStatement x) {

    }

    //override
    public bool visit(SQLDropEventStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLDropEventStatement x) {

    }

    //override
    public bool visit(SQLDropLogFileGroupStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLDropLogFileGroupStatement x) {

    }

    //override
    public bool visit(SQLDropServerStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLDropServerStatement x) {

    }

    //override
    public bool visit(SQLDropSynonymStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLDropSynonymStatement x) {

    }

    //override
    public bool visit(SQLDropTypeStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLDropTypeStatement x) {

    }

    //override
    public bool visit(SQLRecordDataType x) {
        return true;
    }

    //override
    public void endVisit(SQLRecordDataType x) {

    }

    public bool visit(SQLExternalRecordFormat x) {
        return true;
    }

    public void endVisit(SQLExternalRecordFormat x) {

    }

    //override
    public bool visit(SQLArrayDataType x) {
        return true;
    }

    //override
    public void endVisit(SQLArrayDataType x) {

    }

    //override
    public bool visit(SQLMapDataType x) {
        return true;
    }

    //override
    public void endVisit(SQLMapDataType x) {

    }

    //override
    public bool visit(SQLStructDataType x) {
        return true;
    }

    //override
    public void endVisit(SQLStructDataType x) {

    }

    //override
    public bool visit(SQLStructDataType.Field x) {
        return true;
    }

    //override
    public void endVisit(SQLStructDataType.Field x) {

    }

    //override
    public bool visit(SQLDropMaterializedViewStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLDropMaterializedViewStatement x) {

    }

    //override
    public bool visit(SQLAlterTableRenameIndex x) {
        return true;
    }

    //override
    public void endVisit(SQLAlterTableRenameIndex x) {

    }

    //override
    public bool visit(SQLAlterSequenceStatement x) {
        return true;
    }

    //override
    public void endVisit(SQLAlterSequenceStatement x) {

    }

    //override
    public bool visit(SQLAlterTableExchangePartition x) {
        return true;
    }

    //override
    public void endVisit(SQLAlterTableExchangePartition x) {

    }

    //override
    public bool visit(SQLValuesExpr x) {
        return true;
    }

    //override
    public void endVisit(SQLValuesExpr x) {

    }

    //override
    public bool visit(SQLValuesTableSource x) {
        return true;
    }

    public void endVisit(SQLValuesTableSource x) {

    }

    //override
    public bool visit(SQLContainsExpr x) {
        return true;
    }

    public void endVisit(SQLContainsExpr x) {

    }

    //override
    public bool visit(SQLRealExpr x) {
        return true;
    }

    public void endVisit(SQLRealExpr x) {

    }

    //override
    public bool visit(SQLWindow x) {
        return true;
    }

    public void endVisit(SQLWindow x) {

    }

    //override
    public bool visit(SQLDumpStatement x) {
        return true;
    }

    public void endVisit(SQLDumpStatement x) {

    }

    public  bool isEnabled(VisitorFeature feature) {
        return VisitorFeature.isEnabled(this.features, feature);
    }

    public int getFeatures() {
        return features;
    }

    public void setFeatures(int features) {
        this.features = features;
    }
}
