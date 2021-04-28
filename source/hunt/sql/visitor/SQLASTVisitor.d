module hunt.sql.visitor.SQLASTVisitor;


import hunt.sql.ast;
import hunt.sql.ast.expr;
// import hunt.sql.ast.statement;
import hunt.sql.ast.statement.SQLWhileStatement;
import hunt.sql.ast.statement.SQLDeclareStatement;
import hunt.sql.ast.statement.SQLCommitStatement;

public interface SQLASTVisitor {

    void endVisit(SQLAllColumnExpr x);

    void endVisit(SQLBetweenExpr x);

    void endVisit(SQLBinaryOpExpr x);

    void endVisit(SQLCaseExpr x);

    void endVisit(SQLCaseExpr.Item x);

    void endVisit(SQLCaseStatement x);

    void endVisit(SQLCaseStatement.Item x);

    void endVisit(SQLCharExpr x);

    void endVisit(SQLIdentifierExpr x);

    void endVisit(SQLInListExpr x);

    void endVisit(SQLIntegerExpr x);

    void endVisit(SQLExistsExpr x);

    void endVisit(SQLNCharExpr x);

    void endVisit(SQLNotExpr x);

    void endVisit(SQLNullExpr x);

    void endVisit(SQLNumberExpr x);

    void endVisit(SQLPropertyExpr x);

    void endVisit(SQLSelectGroupByClause x);

    void endVisit(SQLSelectItem x);

    void endVisit(SQLSelectStatement selectStatement);

    void postVisit(SQLObject x);

    void preVisit(SQLObject x);

    bool visit(SQLAllColumnExpr x);

    bool visit(SQLBetweenExpr x);

    bool visit(SQLBinaryOpExpr x);

    bool visit(SQLCaseExpr x);

    bool visit(SQLCaseExpr.Item x);

    bool visit(SQLCaseStatement x);

    bool visit(SQLCaseStatement.Item x);

    bool visit(SQLCastExpr x);

    bool visit(SQLCharExpr x);

    bool visit(SQLExistsExpr x);

    bool visit(SQLIdentifierExpr x);

    bool visit(SQLInListExpr x);

    bool visit(SQLIntegerExpr x);

    bool visit(SQLNCharExpr x);

    bool visit(SQLNotExpr x);

    bool visit(SQLNullExpr x);

    bool visit(SQLNumberExpr x);

    bool visit(SQLPropertyExpr x);

    bool visit(SQLSelectGroupByClause x);

    bool visit(SQLSelectItem x);

    void endVisit(SQLCastExpr x);

    bool visit(SQLSelectStatement astNode);

    void endVisit(SQLAggregateExpr astNode);

    bool visit(SQLAggregateExpr astNode);

    bool visit(SQLVariantRefExpr x);

    void endVisit(SQLVariantRefExpr x);

    bool visit(SQLQueryExpr x);

    void endVisit(SQLQueryExpr x);

    bool visit(SQLUnaryExpr x);

    void endVisit(SQLUnaryExpr x);

    bool visit(SQLHexExpr x);

    void endVisit(SQLHexExpr x);

    bool visit(SQLBlobExpr x);

    void endVisit(SQLBlobExpr x);

    bool visit(SQLSelect x);

    void endVisit(SQLSelect select);

    bool visit(SQLSelectQueryBlock x);

    void endVisit(SQLSelectQueryBlock x);

    bool visit(SQLExprTableSource x);

    void endVisit(SQLExprTableSource x);

    bool visit(SQLOrderBy x);

    void endVisit(SQLOrderBy x);

    bool visit(SQLSelectOrderByItem x);

    void endVisit(SQLSelectOrderByItem x);

    bool visit(SQLDropTableStatement x);

    void endVisit(SQLDropTableStatement x);

    bool visit(SQLCreateTableStatement x);

    void endVisit(SQLCreateTableStatement x);

    bool visit(SQLColumnDefinition x);

    void endVisit(SQLColumnDefinition x);
    
    bool visit(SQLColumnDefinition.Identity x);
    
    void endVisit(SQLColumnDefinition.Identity x);

    bool visit(SQLDataType x);

    void endVisit(SQLDataType x);

    bool visit(SQLCharacterDataType x);

    void endVisit(SQLCharacterDataType x);

    bool visit(SQLDeleteStatement x);

    void endVisit(SQLDeleteStatement x);

    bool visit(SQLCurrentOfCursorExpr x);

    void endVisit(SQLCurrentOfCursorExpr x);

    bool visit(SQLInsertStatement x);

    void endVisit(SQLInsertStatement x);

    bool visit(ValuesClause x);

    void endVisit(ValuesClause x);

    bool visit(SQLUpdateSetItem x);

    void endVisit(SQLUpdateSetItem x);

    bool visit(SQLUpdateStatement x);

    void endVisit(SQLUpdateStatement x);

    bool visit(SQLCreateViewStatement x);

    void endVisit(SQLCreateViewStatement x);
    
    bool visit(SQLCreateViewStatement.Column x);
    
    void endVisit(SQLCreateViewStatement.Column x);

    bool visit(SQLNotNullConstraint x);

    void endVisit(SQLNotNullConstraint x);

    void endVisit(SQLMethodInvokeExpr x);

    bool visit(SQLMethodInvokeExpr x);

    void endVisit(SQLUnionQuery x);

    bool visit(SQLUnionQuery x);

    void endVisit(SQLSetStatement x);

    bool visit(SQLSetStatement x);

    void endVisit(SQLAssignItem x);

    bool visit(SQLAssignItem x);

    void endVisit(SQLCallStatement x);

    bool visit(SQLCallStatement x);

    void endVisit(SQLJoinTableSource x);

    bool visit(SQLJoinTableSource x);

    void endVisit(SQLSomeExpr x);

    bool visit(SQLSomeExpr x);

    void endVisit(SQLAnyExpr x);

    bool visit(SQLAnyExpr x);

    void endVisit(SQLAllExpr x);

    bool visit(SQLAllExpr x);

    void endVisit(SQLInSubQueryExpr x);

    bool visit(SQLInSubQueryExpr x);

    void endVisit(SQLListExpr x);

    bool visit(SQLListExpr x);

    void endVisit(SQLSubqueryTableSource x);

    bool visit(SQLSubqueryTableSource x);

    void endVisit(SQLTruncateStatement x);

    bool visit(SQLTruncateStatement x);

    void endVisit(SQLDefaultExpr x);

    bool visit(SQLDefaultExpr x);

    void endVisit(SQLCommentStatement x);

    bool visit(SQLCommentStatement x);

    void endVisit(SQLUseStatement x);

    bool visit(SQLUseStatement x);

    bool visit(SQLAlterTableAddColumn x);

    void endVisit(SQLAlterTableAddColumn x);

    bool visit(SQLAlterTableDropColumnItem x);

    void endVisit(SQLAlterTableDropColumnItem x);

    bool visit(SQLAlterTableDropIndex x);

    void endVisit(SQLAlterTableDropIndex x);

    bool visit(SQLDropIndexStatement x);

    void endVisit(SQLDropIndexStatement x);

    bool visit(SQLDropViewStatement x);

    void endVisit(SQLDropViewStatement x);

    bool visit(SQLSavePointStatement x);

    void endVisit(SQLSavePointStatement x);

    bool visit(SQLRollbackStatement x);

    void endVisit(SQLRollbackStatement x);

    bool visit(SQLReleaseSavePointStatement x);

    void endVisit(SQLReleaseSavePointStatement x);

    void endVisit(SQLCommentHint x);

    bool visit(SQLCommentHint x);

    void endVisit(SQLCreateDatabaseStatement x);

    bool visit(SQLCreateDatabaseStatement x);

    void endVisit(SQLOver x);

    bool visit(SQLOver x);
    
    void endVisit(SQLKeep x);
    
    bool visit(SQLKeep x);

    void endVisit(SQLColumnPrimaryKey x);

    bool visit(SQLColumnPrimaryKey x);

    bool visit(SQLColumnUniqueKey x);

    void endVisit(SQLColumnUniqueKey x);

    void endVisit(SQLWithSubqueryClause x);

    bool visit(SQLWithSubqueryClause x);

    void endVisit(SQLWithSubqueryClause.Entry x);

    bool visit(SQLWithSubqueryClause.Entry x);

    void endVisit(SQLAlterTableAlterColumn x);

    bool visit(SQLAlterTableAlterColumn x);

    bool visit(SQLCheck x);

    void endVisit(SQLCheck x);

    bool visit(SQLAlterTableDropForeignKey x);

    void endVisit(SQLAlterTableDropForeignKey x);

    bool visit(SQLAlterTableDropPrimaryKey x);

    void endVisit(SQLAlterTableDropPrimaryKey x);

    bool visit(SQLAlterTableDisableKeys x);

    void endVisit(SQLAlterTableDisableKeys x);

    bool visit(SQLAlterTableEnableKeys x);

    void endVisit(SQLAlterTableEnableKeys x);

    bool visit(SQLAlterTableStatement x);

    void endVisit(SQLAlterTableStatement x);

    bool visit(SQLAlterTableDisableConstraint x);

    void endVisit(SQLAlterTableDisableConstraint x);

    bool visit(SQLAlterTableEnableConstraint x);

    void endVisit(SQLAlterTableEnableConstraint x);

    bool visit(SQLColumnCheck x);

    void endVisit(SQLColumnCheck x);

    bool visit(SQLExprHint x);

    void endVisit(SQLExprHint x);

    bool visit(SQLAlterTableDropConstraint x);

    void endVisit(SQLAlterTableDropConstraint x);

    bool visit(SQLUnique x);

    void endVisit(SQLUnique x);

    bool visit(SQLPrimaryKeyImpl x);

    void endVisit(SQLPrimaryKeyImpl x);

    bool visit(SQLCreateIndexStatement x);

    void endVisit(SQLCreateIndexStatement x);

    bool visit(SQLAlterTableRenameColumn x);

    void endVisit(SQLAlterTableRenameColumn x);

    bool visit(SQLColumnReference x);

    void endVisit(SQLColumnReference x);

    bool visit(SQLForeignKeyImpl x);

    void endVisit(SQLForeignKeyImpl x);

    bool visit(SQLDropSequenceStatement x);

    void endVisit(SQLDropSequenceStatement x);

    bool visit(SQLDropTriggerStatement x);

    void endVisit(SQLDropTriggerStatement x);

    void endVisit(SQLDropUserStatement x);

    bool visit(SQLDropUserStatement x);

    void endVisit(SQLExplainStatement x);

    bool visit(SQLExplainStatement x);

    void endVisit(SQLGrantStatement x);

    bool visit(SQLGrantStatement x);

    void endVisit(SQLDropDatabaseStatement x);

    bool visit(SQLDropDatabaseStatement x);

    void endVisit(SQLAlterTableAddIndex x);

    bool visit(SQLAlterTableAddIndex x);

    void endVisit(SQLAlterTableAddConstraint x);

    bool visit(SQLAlterTableAddConstraint x);

    void endVisit(SQLCreateTriggerStatement x);

    bool visit(SQLCreateTriggerStatement x);
    
    void endVisit(SQLDropFunctionStatement x);
    
    bool visit(SQLDropFunctionStatement x);
    
    void endVisit(SQLDropTableSpaceStatement x);
    
    bool visit(SQLDropTableSpaceStatement x);
    
    void endVisit(SQLDropProcedureStatement x);
    
    bool visit(SQLDropProcedureStatement x);
    
    void endVisit(SQLBooleanExpr x);
    
    bool visit(SQLBooleanExpr x);
    
    void endVisit(SQLUnionQueryTableSource x);

    bool visit(SQLUnionQueryTableSource x);
    
    void endVisit(SQLTimestampExpr x);
    
    bool visit(SQLTimestampExpr x);
    
    void endVisit(SQLRevokeStatement x);
    
    bool visit(SQLRevokeStatement x);
    
    void endVisit(SQLBinaryExpr x);
    
    bool visit(SQLBinaryExpr x);
    
    void endVisit(SQLAlterTableRename x);
    
    bool visit(SQLAlterTableRename x);
    
    void endVisit(SQLAlterViewRenameStatement x);
    
    bool visit(SQLAlterViewRenameStatement x);
    
    void endVisit(SQLShowTablesStatement x);
    
    bool visit(SQLShowTablesStatement x);
    
    void endVisit(SQLAlterTableAddPartition x);
    
    bool visit(SQLAlterTableAddPartition x);
    
    void endVisit(SQLAlterTableDropPartition x);
    
    bool visit(SQLAlterTableDropPartition x);
    
    void endVisit(SQLAlterTableRenamePartition x);
    
    bool visit(SQLAlterTableRenamePartition x);
    
    void endVisit(SQLAlterTableSetComment x);
    
    bool visit(SQLAlterTableSetComment x);
    
    void endVisit(SQLAlterTableSetLifecycle x);
    
    bool visit(SQLAlterTableSetLifecycle x);
    
    void endVisit(SQLAlterTableEnableLifecycle x);
    
    bool visit(SQLAlterTableEnableLifecycle x);
    
    void endVisit(SQLAlterTableDisableLifecycle x);
    
    bool visit(SQLAlterTableDisableLifecycle x);
    
    void endVisit(SQLAlterTableTouch x);
    
    bool visit(SQLAlterTableTouch x);
    
    void endVisit(SQLArrayExpr x);
    
    bool visit(SQLArrayExpr x);
    
    void endVisit(SQLOpenStatement x);
    
    bool visit(SQLOpenStatement x);
    
    void endVisit(SQLFetchStatement x);
    
    bool visit(SQLFetchStatement x);
    
    void endVisit(SQLCloseStatement x);
    
    bool visit(SQLCloseStatement x);

    bool visit(SQLGroupingSetExpr x);

    void endVisit(SQLGroupingSetExpr x);
    
    bool visit(SQLIfStatement x);
    
    void endVisit(SQLIfStatement x);
    
    bool visit(SQLIfStatement.ElseIf x);
    
    void endVisit(SQLIfStatement.ElseIf x);
    
    bool visit(SQLIfStatement.Else x);
    
    void endVisit(SQLIfStatement.Else x);
    
    bool visit(SQLLoopStatement x);

    void endVisit(SQLLoopStatement x);
    
    bool visit(SQLParameter x);
    
    void endVisit(SQLParameter x);
    
    bool visit(SQLCreateProcedureStatement x);
    
    void endVisit(SQLCreateProcedureStatement x);

    bool visit(SQLCreateFunctionStatement x);

    void endVisit(SQLCreateFunctionStatement x);
    
    bool visit(SQLBlockStatement x);
    
    void endVisit(SQLBlockStatement x);
    
    bool visit(SQLAlterTableDropKey x);
    
    void endVisit(SQLAlterTableDropKey x);
    
    bool visit(SQLDeclareItem x);
    
    void endVisit(SQLDeclareItem x);
    
    bool visit(SQLPartitionValue x);
    
    void endVisit(SQLPartitionValue x);
    
    bool visit(SQLPartition x);
    
    void endVisit(SQLPartition x);
    
    bool visit(SQLPartitionByRange x);
    
    void endVisit(SQLPartitionByRange x);
    
    bool visit(SQLPartitionByHash x);
    
    void endVisit(SQLPartitionByHash x);
    
    bool visit(SQLPartitionByList x);
    
    void endVisit(SQLPartitionByList x);
    
    bool visit(SQLSubPartition x);
    
    void endVisit(SQLSubPartition x);
    
    bool visit(SQLSubPartitionByHash x);
    
    void endVisit(SQLSubPartitionByHash x);
    
    bool visit(SQLSubPartitionByList x);
    
    void endVisit(SQLSubPartitionByList x);
    
    bool visit(SQLAlterDatabaseStatement x);
    
    void endVisit(SQLAlterDatabaseStatement x);
    
    bool visit(SQLAlterTableConvertCharSet x);
    
    void endVisit(SQLAlterTableConvertCharSet x);
    
    bool visit(SQLAlterTableReOrganizePartition x);
    
    void endVisit(SQLAlterTableReOrganizePartition x);
    
    bool visit(SQLAlterTableCoalescePartition x);
    
    void endVisit(SQLAlterTableCoalescePartition x);
    
    bool visit(SQLAlterTableTruncatePartition x);
    
    void endVisit(SQLAlterTableTruncatePartition x);
    
    bool visit(SQLAlterTableDiscardPartition x);
    
    void endVisit(SQLAlterTableDiscardPartition x);
    
    bool visit(SQLAlterTableImportPartition x);
    
    void endVisit(SQLAlterTableImportPartition x);
    
    bool visit(SQLAlterTableAnalyzePartition x);
    
    void endVisit(SQLAlterTableAnalyzePartition x);
    
    bool visit(SQLAlterTableCheckPartition x);
    
    void endVisit(SQLAlterTableCheckPartition x);
    
    bool visit(SQLAlterTableOptimizePartition x);
    
    void endVisit(SQLAlterTableOptimizePartition x);
    
    bool visit(SQLAlterTableRebuildPartition x);
    
    void endVisit(SQLAlterTableRebuildPartition x);
    
    bool visit(SQLAlterTableRepairPartition x);
    
    void endVisit(SQLAlterTableRepairPartition x);
    
    bool visit(SQLSequenceExpr x);
    
    void endVisit(SQLSequenceExpr x);

    bool visit(SQLMergeStatement x);

    void endVisit(SQLMergeStatement x);

    bool visit(SQLMergeStatement.MergeUpdateClause x);

    void endVisit(SQLMergeStatement.MergeUpdateClause x);

    bool visit(SQLMergeStatement.MergeInsertClause x);

    void endVisit(SQLMergeStatement.MergeInsertClause x);
    
    bool visit(SQLErrorLoggingClause x);

    void endVisit(SQLErrorLoggingClause x);

    bool visit(SQLNullConstraint x);

    void endVisit(SQLNullConstraint x);

    bool visit(SQLCreateSequenceStatement x);

    void endVisit(SQLCreateSequenceStatement x);

    bool visit(SQLDateExpr x);
    void endVisit(SQLDateExpr x);

    bool visit(SQLLimit x);
    void endVisit(SQLLimit x);

    void endVisit(SQLStartTransactionStatement x);
    bool visit(SQLStartTransactionStatement x);

    void endVisit(SQLDescribeStatement x);
    bool visit(SQLDescribeStatement x);

    /**
     * support procedure
     */
    bool visit(SQLWhileStatement x);

    void endVisit(SQLWhileStatement x);

    bool visit(SQLDeclareStatement x);

    void endVisit(SQLDeclareStatement x);

    bool visit(SQLReturnStatement x);

    void endVisit(SQLReturnStatement x);

    bool visit(SQLArgument x);

    void endVisit(SQLArgument x);

    bool visit(SQLCommitStatement x);

    void endVisit(SQLCommitStatement x);

    bool visit(SQLFlashbackExpr x);

    void endVisit(SQLFlashbackExpr x);

    bool visit(SQLCreateMaterializedViewStatement x);

    void endVisit(SQLCreateMaterializedViewStatement x);

    bool visit(SQLBinaryOpExprGroup x);

    void endVisit(SQLBinaryOpExprGroup x);

    bool visit(SQLScriptCommitStatement x);

    void endVisit(SQLScriptCommitStatement x);

    bool visit(SQLReplaceStatement x);

    void endVisit(SQLReplaceStatement x);

    bool visit(SQLCreateUserStatement x);

    void endVisit(SQLCreateUserStatement x);

    bool visit(SQLAlterFunctionStatement x);

    void endVisit(SQLAlterFunctionStatement x);

    bool visit(SQLAlterTypeStatement x);

    void endVisit(SQLAlterTypeStatement x);

    bool visit(SQLIntervalExpr x);

    void endVisit(SQLIntervalExpr x);

    bool visit(SQLLateralViewTableSource x);

    void endVisit(SQLLateralViewTableSource x);

    bool visit(SQLShowErrorsStatement x);
    void endVisit(SQLShowErrorsStatement x);

    bool visit(SQLAlterCharacter x);
    void endVisit(SQLAlterCharacter x);

    bool visit(SQLExprStatement x);
    void endVisit(SQLExprStatement x);

    bool visit(SQLAlterProcedureStatement x);
    void endVisit(SQLAlterProcedureStatement x);

    bool visit(SQLAlterViewStatement x);
    void endVisit(SQLAlterViewStatement x);

    bool visit(SQLDropEventStatement x);
    void endVisit(SQLDropEventStatement x);

    bool visit(SQLDropLogFileGroupStatement x);
    void endVisit(SQLDropLogFileGroupStatement x);

    bool visit(SQLDropServerStatement x);
    void endVisit(SQLDropServerStatement x);

    bool visit(SQLDropSynonymStatement x);
    void endVisit(SQLDropSynonymStatement x);

    bool visit(SQLRecordDataType x);
    void endVisit(SQLRecordDataType x);

    bool visit(SQLDropTypeStatement x);
    void endVisit(SQLDropTypeStatement x);

    bool visit(SQLExternalRecordFormat x);
    void endVisit(SQLExternalRecordFormat x);

    bool visit(SQLArrayDataType x);
    void endVisit(SQLArrayDataType x);

    bool visit(SQLMapDataType x);
    void endVisit(SQLMapDataType x);

    bool visit(SQLStructDataType x);
    void endVisit(SQLStructDataType x);

    bool visit(SQLStructDataType.Field x);
    void endVisit(SQLStructDataType.Field x);

    bool visit(SQLDropMaterializedViewStatement x);
    void endVisit(SQLDropMaterializedViewStatement x);

    bool visit(SQLAlterTableRenameIndex x);
    void endVisit(SQLAlterTableRenameIndex x);

    bool visit(SQLAlterSequenceStatement x);
    void endVisit(SQLAlterSequenceStatement x);

    bool visit(SQLAlterTableExchangePartition x);
    void endVisit(SQLAlterTableExchangePartition x);

    bool visit(SQLValuesExpr x);
    void endVisit(SQLValuesExpr x);

    bool visit(SQLValuesTableSource x);
    void endVisit(SQLValuesTableSource x);

    bool visit(SQLContainsExpr x);
    void endVisit(SQLContainsExpr x);

    bool visit(SQLRealExpr x);
    void endVisit(SQLRealExpr x);

    bool visit(SQLWindow x);
    void endVisit(SQLWindow x);

    bool visit(SQLDumpStatement x);
    void endVisit(SQLDumpStatement x);

}
