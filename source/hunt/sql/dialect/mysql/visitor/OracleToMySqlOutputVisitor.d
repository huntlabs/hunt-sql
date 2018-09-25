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
module hunt.sql.dialect.mysql.visitor.OracleToMySqlOutputVisitor;

// import hunt.sql.dialect.oracle.ast.OracleDataTypeIntervalDay;
// import hunt.sql.dialect.oracle.ast.OracleDataTypeIntervalYear;
// import hunt.sql.dialect.oracle.ast.clause;
// import hunt.sql.dialect.oracle.ast.expr;
// import hunt.sql.dialect.oracle.ast.stmt;
// import hunt.sql.dialect.oracle.visitor.OracleASTVisitor;

/**
 * Created by wenshao on 16/07/2017.
 */
// public class OracleToMySqlOutputVisitor : MySqlOutputVisitor , OracleASTVisitor {
//     public this(Appendable appender) {
//         super(appender);
//     }

//     public this(Appendable appender, bool parameterized) {
//         super(appender, parameterized);
//     }


//     override
//     public void endVisit(OracleAnalytic x) {

//     }

//     override
//     public void endVisit(OracleAnalyticWindowing x) {

//     }

//     override
//     public void endVisit(OracleDbLinkExpr x) {

//     }

//     override
//     public void endVisit(OracleDeleteStatement x) {

//     }

//     override
//     public void endVisit(OracleIntervalExpr x) {

//     }

//     override
//     public void endVisit(OracleOuterExpr x) {

//     }

//     override
//     public void endVisit(OracleSelectJoin x) {

//     }

//     override
//     public void endVisit(OracleSelectPivot x) {

//     }

//     override
//     public void endVisit(OracleSelectPivot.Item x) {

//     }

//     override
//     public void endVisit(OracleSelectRestriction.CheckOption x) {

//     }

//     override
//     public void endVisit(OracleSelectRestriction.ReadOnly x) {

//     }

//     override
//     public void endVisit(OracleSelectSubqueryTableSource x) {

//     }

//     override
//     public void endVisit(OracleSelectUnPivot x) {

//     }

//     override
//     public void endVisit(OracleUpdateStatement x) {

//     }

//     override
//     public bool visit(OracleAnalytic x) {
//         return false;
//     }

//     override
//     public bool visit(OracleAnalyticWindowing x) {
//         return false;
//     }

//     override
//     public bool visit(OracleDbLinkExpr x) {
//         return false;
//     }

//     override
//     public bool visit(OracleDeleteStatement x) {
//         return false;
//     }

//     override
//     public bool visit(OracleIntervalExpr x) {
//         return false;
//     }

//     override
//     public bool visit(OracleOuterExpr x) {
//         return false;
//     }

//     override
//     public bool visit(OracleSelectJoin x) {
//         return false;
//     }

//     override
//     public bool visit(OracleSelectPivot x) {
//         return false;
//     }

//     override
//     public bool visit(OracleSelectPivot.Item x) {
//         return false;
//     }

//     override
//     public bool visit(OracleSelectRestriction.CheckOption x) {
//         return false;
//     }

//     override
//     public bool visit(OracleSelectRestriction.ReadOnly x) {
//         return false;
//     }

//     override
//     public bool visit(OracleSelectSubqueryTableSource x) {
//         return false;
//     }

//     override
//     public bool visit(OracleSelectUnPivot x) {
//         return false;
//     }

//     override
//     public bool visit(OracleUpdateStatement x) {
//         return false;
//     }

//     override
//     public bool visit(SampleClause x) {
//         return false;
//     }

//     override
//     public void endVisit(SampleClause x) {

//     }

//     override
//     public bool visit(OracleSelectTableReference x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleSelectTableReference x) {

//     }

//     override
//     public bool visit(PartitionExtensionClause x) {
//         return false;
//     }

//     override
//     public void endVisit(PartitionExtensionClause x) {

//     }

//     override
//     public bool visit(OracleWithSubqueryEntry x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleWithSubqueryEntry x) {

//     }

//     override
//     public bool visit(SearchClause x) {
//         return false;
//     }

//     override
//     public void endVisit(SearchClause x) {

//     }

//     override
//     public bool visit(CycleClause x) {
//         return false;
//     }

//     override
//     public void endVisit(CycleClause x) {

//     }

//     override
//     public bool visit(OracleBinaryFloatExpr x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleBinaryFloatExpr x) {

//     }

//     override
//     public bool visit(OracleBinaryDoubleExpr x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleBinaryDoubleExpr x) {

//     }

//     override
//     public bool visit(OracleCursorExpr x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleCursorExpr x) {

//     }

//     override
//     public bool visit(OracleIsSetExpr x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleIsSetExpr x) {

//     }

//     override
//     public bool visit(ModelClause.ReturnRowsClause x) {
//         return false;
//     }

//     override
//     public void endVisit(ModelClause.ReturnRowsClause x) {

//     }

//     override
//     public bool visit(ModelClause.MainModelClause x) {
//         return false;
//     }

//     override
//     public void endVisit(ModelClause.MainModelClause x) {

//     }

//     override
//     public bool visit(ModelClause.ModelColumnClause x) {
//         return false;
//     }

//     override
//     public void endVisit(ModelClause.ModelColumnClause x) {

//     }

//     override
//     public bool visit(ModelClause.QueryPartitionClause x) {
//         return false;
//     }

//     override
//     public void endVisit(ModelClause.QueryPartitionClause x) {

//     }

//     override
//     public bool visit(ModelClause.ModelColumn x) {
//         return false;
//     }

//     override
//     public void endVisit(ModelClause.ModelColumn x) {

//     }

//     override
//     public bool visit(ModelClause.ModelRulesClause x) {
//         return false;
//     }

//     override
//     public void endVisit(ModelClause.ModelRulesClause x) {

//     }

//     override
//     public bool visit(ModelClause.CellAssignmentItem x) {
//         return false;
//     }

//     override
//     public void endVisit(ModelClause.CellAssignmentItem x) {

//     }

//     override
//     public bool visit(ModelClause.CellAssignment x) {
//         return false;
//     }

//     override
//     public void endVisit(ModelClause.CellAssignment x) {

//     }

//     override
//     public bool visit(ModelClause x) {
//         return false;
//     }

//     override
//     public void endVisit(ModelClause x) {

//     }

//     override
//     public bool visit(OracleReturningClause x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleReturningClause x) {

//     }

//     override
//     public bool visit(OracleInsertStatement x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleInsertStatement x) {

//     }

//     override
//     public bool visit(OracleMultiInsertStatement.InsertIntoClause x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleMultiInsertStatement.InsertIntoClause x) {

//     }

//     override
//     public bool visit(OracleMultiInsertStatement x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleMultiInsertStatement x) {

//     }

//     override
//     public bool visit(OracleMultiInsertStatement.ConditionalInsertClause x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleMultiInsertStatement.ConditionalInsertClause x) {

//     }

//     override
//     public bool visit(OracleMultiInsertStatement.ConditionalInsertClauseItem x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleMultiInsertStatement.ConditionalInsertClauseItem x) {

//     }

//     override
//     public bool visit(OracleSelectQueryBlock x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleSelectQueryBlock x) {

//     }

//     override
//     public bool visit(OracleLockTableStatement x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleLockTableStatement x) {

//     }

//     override
//     public bool visit(OracleAlterSessionStatement x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleAlterSessionStatement x) {

//     }

//     override
//     public bool visit(OracleDatetimeExpr x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleDatetimeExpr x) {

//     }

//     override
//     public bool visit(OracleSysdateExpr x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleSysdateExpr x) {

//     }

//     override
//     public bool visit(OracleExceptionStatement x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleExceptionStatement x) {

//     }

//     override
//     public bool visit(OracleExceptionStatement.Item x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleExceptionStatement.Item x) {

//     }

//     override
//     public bool visit(OracleArgumentExpr x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleArgumentExpr x) {

//     }

//     override
//     public bool visit(OracleSetTransactionStatement x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleSetTransactionStatement x) {

//     }

//     override
//     public bool visit(OracleExplainStatement x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleExplainStatement x) {

//     }

//     override
//     public bool visit(OracleAlterTableDropPartition x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleAlterTableDropPartition x) {

//     }

//     override
//     public bool visit(OracleAlterTableTruncatePartition x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleAlterTableTruncatePartition x) {

//     }

//     override
//     public bool visit(OracleAlterTableSplitPartition.TableSpaceItem x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleAlterTableSplitPartition.TableSpaceItem x) {

//     }

//     override
//     public bool visit(OracleAlterTableSplitPartition.UpdateIndexesClause x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleAlterTableSplitPartition.UpdateIndexesClause x) {

//     }

//     override
//     public bool visit(OracleAlterTableSplitPartition.NestedTablePartitionSpec x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleAlterTableSplitPartition.NestedTablePartitionSpec x) {

//     }

//     override
//     public bool visit(OracleAlterTableSplitPartition x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleAlterTableSplitPartition x) {

//     }

//     override
//     public bool visit(OracleAlterTableModify x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleAlterTableModify x) {

//     }

//     override
//     public bool visit(OracleCreateIndexStatement x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleCreateIndexStatement x) {

//     }

//     override
//     public bool visit(OracleForStatement x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleForStatement x) {

//     }

//     override
//     public bool visit(OracleRangeExpr x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleRangeExpr x) {

//     }

//     override
//     public bool visit(OracleAlterIndexStatement x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleAlterIndexStatement x) {

//     }

//     override
//     public bool visit(OraclePrimaryKey x) {
//         return false;
//     }

//     override
//     public void endVisit(OraclePrimaryKey x) {

//     }

//     override
//     public bool visit(OracleCreateTableStatement x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleCreateTableStatement x) {

//     }

//     override
//     public bool visit(OracleAlterIndexStatement.Rebuild x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleAlterIndexStatement.Rebuild x) {

//     }

//     override
//     public bool visit(OracleStorageClause x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleStorageClause x) {

//     }

//     override
//     public bool visit(OracleGotoStatement x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleGotoStatement x) {

//     }

//     override
//     public bool visit(OracleLabelStatement x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleLabelStatement x) {

//     }

//     override
//     public bool visit(OracleAlterTriggerStatement x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleAlterTriggerStatement x) {

//     }

//     override
//     public bool visit(OracleAlterSynonymStatement x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleAlterSynonymStatement x) {

//     }

//     override
//     public bool visit(OracleAlterViewStatement x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleAlterViewStatement x) {

//     }

//     override
//     public bool visit(OracleAlterTableMoveTablespace x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleAlterTableMoveTablespace x) {

//     }

//     override
//     public bool visit(OracleSizeExpr x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleSizeExpr x) {

//     }

//     override
//     public bool visit(OracleFileSpecification x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleFileSpecification x) {

//     }

//     override
//     public bool visit(OracleAlterTablespaceAddDataFile x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleAlterTablespaceAddDataFile x) {

//     }

//     override
//     public bool visit(OracleAlterTablespaceStatement x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleAlterTablespaceStatement x) {

//     }

//     override
//     public bool visit(OracleExitStatement x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleExitStatement x) {

//     }

//     override
//     public bool visit(OracleContinueStatement x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleContinueStatement x) {

//     }

//     override
//     public bool visit(OracleRaiseStatement x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleRaiseStatement x) {

//     }

//     override
//     public bool visit(OracleCreateDatabaseDbLinkStatement x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleCreateDatabaseDbLinkStatement x) {

//     }

//     override
//     public bool visit(OracleDropDbLinkStatement x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleDropDbLinkStatement x) {

//     }

//     override
//     public bool visit(OracleDataTypeIntervalYear x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleDataTypeIntervalYear x) {

//     }

//     override
//     public bool visit(OracleDataTypeIntervalDay x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleDataTypeIntervalDay x) {

//     }

//     override
//     public bool visit(OracleUsingIndexClause x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleUsingIndexClause x) {

//     }

//     override
//     public bool visit(OracleLobStorageClause x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleLobStorageClause x) {

//     }

//     override
//     public bool visit(OracleUnique x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleUnique x) {

//     }

//     override
//     public bool visit(OracleForeignKey x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleForeignKey x) {

//     }

//     override
//     public bool visit(OracleCheck x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleCheck x) {

//     }

//     override
//     public bool visit(OracleSupplementalIdKey x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleSupplementalIdKey x) {

//     }

//     override
//     public bool visit(OracleSupplementalLogGrp x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleSupplementalLogGrp x) {

//     }

//     override
//     public bool visit(OracleCreateTableStatement.Organization x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleCreateTableStatement.Organization x) {

//     }

//     override
//     public bool visit(OracleCreateTableStatement.OIDIndex x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleCreateTableStatement.OIDIndex x) {

//     }

//     override
//     public bool visit(OracleCreatePackageStatement x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleCreatePackageStatement x) {

//     }

//     override
//     public bool visit(OracleExecuteImmediateStatement x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleExecuteImmediateStatement x) {

//     }

//     override
//     public bool visit(OracleTreatExpr x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleTreatExpr x) {

//     }

//     override
//     public bool visit(OracleCreateSynonymStatement x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleCreateSynonymStatement x) {

//     }

//     override
//     public bool visit(OracleCreateTypeStatement x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleCreateTypeStatement x) {

//     }

//     override
//     public bool visit(OraclePipeRowStatement x) {
//         return false;
//     }

//     override
//     public void endVisit(OraclePipeRowStatement x) {

//     }

//     override
//     public bool visit(OracleIsOfTypeExpr x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleIsOfTypeExpr x) {

//     }

//     override
//     public bool visit(OracleRunStatement x) {
//         return false;
//     }

//     override
//     public void endVisit(OracleRunStatement x) {

//     }
// }
