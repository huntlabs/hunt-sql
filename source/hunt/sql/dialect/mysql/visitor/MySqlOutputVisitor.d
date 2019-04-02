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
module hunt.sql.dialect.mysql.visitor.MySqlOutputVisitor;

import hunt.sql.ast;
import hunt.sql.ast.expr;
import hunt.sql.ast.statement;
import hunt.sql.dialect.mysql.ast.MySqlForceIndexHint;
import hunt.sql.dialect.mysql.ast.MySqlIgnoreIndexHint;
import hunt.sql.dialect.mysql.ast.MySqlKey;
import hunt.sql.dialect.mysql.ast.MySqlPrimaryKey;
import hunt.sql.dialect.mysql.ast.MySqlUnique;
import hunt.sql.dialect.mysql.ast.MySqlUseIndexHint;
import hunt.sql.dialect.mysql.ast.MysqlForeignKey;
import hunt.sql.dialect.mysql.ast.clause.ConditionValue;
// import hunt.sql.dialect.mysql.ast.clause.ConditionValue.ConditionType;
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
import hunt.sql.dialect.mysql.ast.statement.MySqlCreateUserStatement;
// import hunt.sql.dialect.mysql.ast.statement.MySqlCreateUserStatement.UserSpecification;
import hunt.sql.visitor;
import hunt.sql.util.DBType;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;

import hunt.Byte;
import hunt.collection;
import hunt.String;
import hunt.Boolean;
import hunt.util.Common;
import hunt.text;

import std.string;

public class MySqlOutputVisitor : SQLASTOutputVisitor , MySqlASTVisitor {
    alias visit = SQLASTOutputVisitor.visit;
    alias endVisit = SQLASTOutputVisitor.endVisit;

    this(){
        this.dbType = DBType.MYSQL.name;
        this.shardingSupport = true;
    }

    public this(Appendable appender) {
        this.dbType = DBType.MYSQL.name;
        this.shardingSupport = true;
        super(appender);
    }

    public this(Appendable appender, bool parameterized) {
        this.dbType = DBType.MYSQL.name;
        this.shardingSupport = true;
        super(appender, parameterized);

        // try {
        //     configFromProperty(System.getProperties());
        // } catch (AccessControlException e) {
        //     // skip
        // }
    }

    

    // public void configFromProperty(Properties properties) {
    //     if (this.parameterized) {
    //         string property = properties.getProperty("druid.parameterized.shardingSupport");
    //         if ("true" == (property)) {
    //             this.setShardingSupport(true);
    //         } else if ("false" == (property)) {
    //             this.setShardingSupport(false);
    //         }
    //     }
    // }

    public bool isShardingSupport() {
        return this.parameterized
                && shardingSupport;
    }

    public void setShardingSupport(bool shardingSupport) {
        this.shardingSupport = shardingSupport;
    }

    override
    public bool visit(SQLSelectQueryBlock select) {
        if (cast(MySqlSelectQueryBlock)(select) !is null) {
            return visit(cast(MySqlSelectQueryBlock) select);
        }

        return super.visit(select);
    }


    public bool visit(MySqlSelectQueryBlock x) {
         bool bracket = x.isBracket();
        if (bracket) {
            print('(');
        }

        if ((!isParameterized()) && isPrettyFormat() && x.hasBeforeComment()) {
            printlnComments(x.getBeforeCommentsDirect());
        }

        string cachedSelectList = x.getCachedSelectList();

        if (cachedSelectList !is null) {
            if (!isEnabled(VisitorFeature.OutputSkipSelectListCacheString)) {
                print0(cachedSelectList);
            }
        } else {
            print0(ucase ? "SELECT " : "select ");

            for (int i = 0, size = x.getHintsSize(); i < size; ++i) {
                SQLCommentHint hint = x.getHints().get(i);
                hint.accept(this);
                print(' ');
            }

             int distionOption = x.getDistionOption();
            if (SQLSetQuantifier.ALL == distionOption) {
                print0(ucase ? "ALL " : "all ");
            } else if (SQLSetQuantifier.DISTINCT == distionOption) {
                print0(ucase ? "DISTINCT " : "distinct ");
            } else if (SQLSetQuantifier.DISTINCTROW == distionOption) {
                print0(ucase ? "DISTINCTROW " : "distinctrow ");
            }

            if (x.isHignPriority()) {
                print0(ucase ? "HIGH_PRIORITY " : "high_priority ");
            }

            if (x.isStraightJoin()) {
                print0(ucase ? "STRAIGHT_JOIN " : "straight_join ");
            }

            if (x.isSmallResult()) {
                print0(ucase ? "SQL_SMALL_RESULT " : "sql_small_result ");
            }

            if (x.isBigResult()) {
                print0(ucase ? "SQL_BIG_RESULT " : "sql_big_result ");
            }

            if (x.isBufferResult()) {
                print0(ucase ? "SQL_BUFFER_RESULT " : "sql_buffer_result ");
            }

            if (x.getCache() !is null) {
                if (x.getCache().booleanValue()) {
                    print0(ucase ? "SQL_CACHE " : "sql_cache ");
                } else {
                    print0(ucase ? "SQL_NO_CACHE " : "sql_no_cache ");
                }
            }

            if (x.isCalcFoundRows()) {
                print0(ucase ? "SQL_CALC_FOUND_ROWS " : "sql_calc_found_rows ");
            }

            printSelectList(x.getSelectList());

            SQLName forcePartition = x.getForcePartition();
            if (forcePartition !is null) {
                println();
                print0(ucase ? "FORCE PARTITION " : "force partition ");
                printExpr(forcePartition);
            }

            SQLExprTableSource into = x.getInto();
            if (into !is null) {
                println();
                print0(ucase ? "INTO " : "into ");
                printTableSource(into);
            }
        }

        SQLTableSource from = x.getFrom();
        if (from !is null) {
            println();
            print0(ucase ? "FROM " : "from ");

            printTableSource(from);
        }

        SQLExpr where = x.getWhere();
        if (where !is null) {
            println();
            print0(ucase ? "WHERE " : "where ");
            printExpr(where);
        }

        printHierarchical(x);

        SQLSelectGroupByClause groupBy = x.getGroupBy();
        if (groupBy !is null) {
            println();
            visit(groupBy);
        }

        SQLOrderBy orderBy = x.getOrderBy();
        if (orderBy !is null) {
            println();
            visit(orderBy);
        }

        SQLLimit limit = x.getLimit();
        if (limit !is null) {
            println();
            visit(limit);
        }

        SQLName procedureName = x.getProcedureName();
        if (procedureName !is null) {
            print0(ucase ? " PROCEDURE " : " procedure ");
            procedureName.accept(this);
            if (!x.getProcedureArgumentList().isEmpty()) {
                print('(');
                printAndAccept!SQLExpr((x.getProcedureArgumentList()), ", ");
                print(')');
            }
        }

        if (x.isForUpdate()) {
            println();
            print0(ucase ? "FOR UPDATE" : "for update");
            if (x.isNoWait()) {
                print0(ucase ? " NOWAIT" : " nowait");
            } else if (x.getWaitTime() !is null) {
                print0(ucase ? " WAIT " : " wait ");
                x.getWaitTime().accept(this);
            }
        }

        if (x.isLockInShareMode()) {
            println();
            print0(ucase ? "LOCK IN SHARE MODE" : "lock in share mode");
        }

        if (bracket) {
            print(')');
        }

        return false;
    }

    override public bool visit(SQLColumnDefinition x) {
        bool parameterized = this.parameterized;
        this.parameterized = false;

        x.getName().accept(this);

        SQLDataType dataType = x.getDataType();
        if (dataType !is null) {
            print(' ');
            dataType.accept(this);
        }

         SQLExpr charsetExpr = x.getCharsetExpr();
        if (charsetExpr !is null) {
            print0(ucase ? " CHARSET " : " charset ");
            charsetExpr.accept(this);
        }

        foreach(SQLColumnConstraint item ; x.getConstraints()) {
            print(' ');
            item.accept(this);
        }

         SQLExpr defaultExpr = x.getDefaultExpr();
        if (defaultExpr !is null) {
            print0(ucase ? " DEFAULT " : " default ");
            defaultExpr.accept(this);
        }

         SQLExpr storage = x.getStorage();
        if (storage !is null) {
            print0(ucase ? " STORAGE " : " storage ");
            storage.accept(this);
        }

        SQLExpr onUpdate = x.getOnUpdate();
        if (onUpdate !is null) {
            print0(ucase ? " ON UPDATE " : " on update ");

            onUpdate.accept(this);
        }

        if (x.isAutoIncrement()) {
            print0(ucase ? " AUTO_INCREMENT" : " auto_increment");
        }

        if (x.getComment() !is null) {
            print0(ucase ? " COMMENT " : " comment ");
            x.getComment().accept(this);
        }

        if (x.getAsExpr() !is null) {
            print0(ucase ? " AS (" : " as (");
            x.getAsExpr().accept(this);
            print(')');
        }

        if (x.isSorted()) {
            print0(ucase ? " SORTED" : " sorted");
        }

        if (x.isVirtual()) {
            print0(ucase ? " VIRTUAL" : " virtual");
        }

        this.parameterized = parameterized;
        return false;
    }

    override public bool visit(SQLDataType x) {
        printDataType(x);

        if (cast(SQLDataTypeImpl)(x) !is null) {
            SQLDataTypeImpl dataTypeImpl = cast(SQLDataTypeImpl) x;
            if (dataTypeImpl.isUnsigned()) {
                print0(ucase ? " UNSIGNED" : " unsigned");
            }

            if (dataTypeImpl.isZerofill()) {
                print0(ucase ? " ZEROFILL" : " zerofill");
            }
        }

        if (cast(SQLCharacterDataType)(x) !is null) {
            SQLCharacterDataType charType = cast(SQLCharacterDataType) x;
            if (charType.getCharSetName() !is null) {
                print0(ucase ? " CHARACTER SET " : " character set ");
                print0(charType.getCharSetName());

                if (charType.getCollate() !is null) {
                    print0(ucase ? " COLLATE " : " collate ");
                    print0(charType.getCollate());
                }
            }

            List!(SQLCommentHint) hints = (cast(SQLCharacterDataType) x).hints;
            if (hints !is null) {
                print(' ');
                foreach(SQLCommentHint hint ; hints) {
                    hint.accept(this);
                }
            }
        }
        return false;
    }

    override
    public bool visit(SQLCharacterDataType x) {
        printDataType(x);

        if (x.isHasBinary()) {
            print0(ucase ? " BINARY " : " binary ");
        }

        if (x.getCharSetName() !is null) {
            print0(ucase ? " CHARACTER SET " : " character set ");
            print0(x.getCharSetName());
            if (x.getCollate() !is null) {
                print0(ucase ? " COLLATE " : " collate ");
                print0(x.getCollate());
            }
        } else if (x.getCollate() !is null) {
            print0(ucase ? " COLLATE " : " collate ");
            print0(x.getCollate());
        }

        List!(SQLCommentHint) hints = (cast(SQLCharacterDataType) x).hints;
        if (hints !is null) {
            print(' ');
            foreach(SQLCommentHint hint ; hints) {
                hint.accept(this);
            }
        }

        return false;
    }

    override
    public void endVisit(MySqlTableIndex x) {

    }

    override
    public bool visit(MySqlTableIndex x) {
        string indexType = x.getIndexType();

        bool indexTypePrinted = false;
        if ("FULLTEXT".equalsIgnoreCase(indexType)) {
            print0(ucase ? "FULLTEXT " : "fulltext ");
            indexTypePrinted = true;
        } else if ("SPATIAL".equalsIgnoreCase(indexType)) {
            print0(ucase ? "SPATIAL " : "spatial ");
            indexTypePrinted = true;
        }

        print0(ucase ? "INDEX" : "index");
        if (x.getName() !is null) {
            print(' ');
            x.getName().accept(this);
        }

        if (indexType !is null && !indexTypePrinted) {
            print0(ucase ? " USING " : " using ");
            print0(indexType);
        }

        print('(');
        for (int i = 0, size = x.getColumns().size(); i < size; ++i) {
            if (i != 0) {
                print0(", ");
            }
            x.getColumns().get(i).accept(this);
        }
        print(')');
        return false;
    }

    public bool visit(MySqlCreateTableStatement x) {
        if (isPrettyFormat() && x.hasBeforeComment()) {
            printlnComments(x.getBeforeCommentsDirect());
        }

        print0(ucase ? "CREATE " : "create ");

        foreach(SQLCommentHint hint ; x.getHints()) {
            hint.accept(this);
            print(' ');
        }

        if (SQLCreateTableStatement.Type.GLOBAL_TEMPORARY == x.getType()) {
            print0(ucase ? "TEMPORARY TABLE " : "temporary table ");
        } else {
            print0(ucase ? "TABLE " : "table ");
        }

        if (x.isIfNotExiists()) {
            print0(ucase ? "IF NOT EXISTS " : "if not exists ");
        }

        printTableSourceExpr(x.getName());

        if (x.getLike() !is null) {
            print0(ucase ? " LIKE " : " like ");
            x.getLike().accept(this);
        }

        printTableElements(x.getTableElementList());

        foreach(string key, SQLObject v ; x.getTableOptions()) {
            // string key = option.getKey();

            print(' ');
            print0(ucase ? key : toLower(key));

            if ("TABLESPACE" == key) {
                print(' ');
                v.accept(this);
                continue;
            } else if ("UNION" == (key)) {
                print0(" = (");
                v.accept(this);
                print(')');
                continue;
            }

            print0(" = ");

            v.accept(this);
        }

        SQLExpr comment = x.getComment();
        if (comment !is null) {
            print0(ucase ? " COMMENT " : " comment ");
            comment.accept(this);
        }

        SQLPartitionBy partitionBy = x.getPartitioning();
        if (partitionBy !is null) {
            println();
            print0(ucase ? "PARTITION BY " : "partition by ");
            partitionBy.accept(this);
        }

        SQLPartitionBy dbPartitionBy = x.getDbPartitionBy();
        if (dbPartitionBy !is null) {
            println();
            print0(ucase ? "DBPARTITION BY " : "dbpartition by ");
            dbPartitionBy.accept(this);
        }

        SQLPartitionBy tbPartitionsBy = x.getTablePartitionBy();
        if (tbPartitionsBy !is null) {
            println();
            print0(ucase ? "TBPARTITION BY " : "tbpartition by ");
            tbPartitionsBy.accept(this);
        }

        if (x.getTbpartitions() !is null) {
            println();
            print0(ucase ? "TBPARTITIONS " : "tbpartitions ");
            x.getTbpartitions().accept(this);
        }

        if (x.getTableGroup() !is null) {
            println();
            print0(ucase ? "TABLEGROUP " : "tablegroup ");
            x.getTableGroup().accept(this);
        }

        if (x.getSelect() !is null) {
            println();
            print0(ucase ? "AS" : "as");
            println();
            x.getSelect().accept(this);
        }

        foreach(SQLCommentHint hint ; x.getOptionHints()) {
            print(' ');
            hint.accept(this);
        }
        return false;
    }

    override
    public void endVisit(MySqlKey x) {

    }

    override
    public void endVisit(MySqlPrimaryKey x) {

    }

    override
    public void endVisit(MysqlForeignKey x) {

    }

    override
    public bool visit(MySqlKey x) {
        if (x.isHasConstaint()) {
            print0(ucase ? "CONSTRAINT " : "constraint ");
            if (x.getName() !is null) {
                x.getName().accept(this);
                print(' ');
            }
        }

        print0(ucase ? "KEY" : "key");

        SQLName name = x.getName();
        if (name !is null) {
            print(' ');
            name.accept(this);
        }

        if (x.getIndexType() !is null) {
            print0(ucase ? " USING " : " using ");
            print0(x.getIndexType());
        }

        print0(" (");

        for (int i = 0, size = x.getColumns().size(); i < size; ++i) {
            if (i != 0) {
                print0(", ");
            }
            x.getColumns().get(i).accept(this);
        }
        print(')');

        return false;
    }

    override
    public bool visit(MySqlPrimaryKey x) {
        if (x.getName() !is null) {
            print0(ucase ? "CONSTRAINT " : "constraint ");
            x.getName().accept(this);
            print(' ');
        }

        print0(ucase ? "PRIMARY KEY" : "primary key");

        if (x.getIndexType() !is null) {
            print0(ucase ? " USING " : " using ");
            print0(x.getIndexType());
        }

        print0(" (");

        for (int i = 0, size = x.getColumns().size(); i < size; ++i) {
            if (i != 0) {
                print0(", ");
            }
            x.getColumns().get(i).accept(this);
        }
        print(')');

        return false;
    }

    override public bool visit(SQLCharExpr x) {
        if (this.appender is null) {
            return false;
        }

        try {
            if (this.parameterized) {
                this.appender.append('?');
                incrementReplaceCunt();
                if (this.parameters !is null) {
                    ExportParameterVisitorUtils.exportParameter(this.parameters, x);
                }
                return false;
            }

            this.appender.append('\'');

            string text = x.getText().value();

            bool hasSpecial = false;
            for (int i = 0; i < text.length; ++i) {
                char ch = charAt(text, i);
                if (ch == '\'' || ch == '\\' || ch == '\0') {
                    hasSpecial = true;
                    break;
                }
            }

            if (hasSpecial) {
                for (int i = 0; i < text.length; ++i) {
                    char ch = charAt(text, i);
                    if (ch == '\'') {
                        appender.append('\'');
                        appender.append('\'');
                    } else if (ch == '\\') {
                        appender.append('\\');
                        appender.append('\\');
                    } else if (ch == '\0') {
                        appender.append('\\');
                        appender.append('0');
                    } else {
                        appender.append(ch);
                    }
                }
            } else {
                appender.append(text);
            }

            appender.append('\'');
        return false;
        } catch (Exception e) {
            throw new Exception("println error", e);
        }
    }

    override public bool visit(SQLVariantRefExpr x) {
        {
            int index = x.getIndex();

            if (inputParameters !is null && index < inputParameters.size()) {

                return super.visit(x);
            }
        }

        if (x.isGlobal()) {
            print0("@@global.");
        }else if(x.isSession()){
            print0("@@session.");
        }

        string varName = x.getName();
        for (int i = 0; i < varName.length; ++i) {
            char ch = charAt(varName, i);
            if (ch == '\'') {
                if (varName.startsWith("@@") && i == 2) {
                    print(ch);
                } else if (varName.startsWith("@") && i == 1) {
                    print(ch);
                } else if (i != 0 && i != varName.length - 1) {
                    print0("\\'");
                } else {
                    print(ch);
                }
            } else {
                print(ch);
            }
        }

        String collate = cast(String) x.getAttribute("COLLATE");
        if (collate !is null) {
            print0(ucase ? " COLLATE " : " collate ");
            print0(collate);
        }

        return false;
    }

    override
    public bool visit(MySqlExtractExpr x) {
        print0(ucase ? "EXTRACT(" : "extract(");
        print0(x.getUnit().name());
        print0(ucase ? " FROM " : " from ");
        x.getValue().accept(this);
        print(')');
        return false;
    }

    override
    public void endVisit(MySqlExtractExpr x) {

    }

    override
    public void endVisit(MySqlMatchAgainstExpr x) {

    }

    override
    public bool visit(MySqlMatchAgainstExpr x) {
        print0(ucase ? "MATCH (" : "match (");
        printAndAccept!SQLExpr((x.getColumns()), ", ");
        print(')');

        print0(ucase ? " AGAINST (" : " against (");
        x.getAgainst().accept(this);
        if (x.getSearchModifier().name.length != 0) {
            print(' ');
            print0(ucase ? x.getSearchModifier().name : x.getSearchModifier().name_lcase);
        }
        print(')');

        return false;
    }

    override
    public void endVisit(MySqlPrepareStatement x) {
    }

    override
    public bool visit(MySqlPrepareStatement x) {
        print0(ucase ? "PREPARE " : "prepare ");
        x.getName().accept(this);
        print0(ucase ? " FROM " : " from ");
        x.getFrom().accept(this);
        return false;
    }

    override
    public void endVisit(MySqlExecuteStatement x) {

    }

    override
    public bool visit(MySqlExecuteStatement x) {
        print0(ucase ? "EXECUTE " : "execute ");
        x.getStatementName().accept(this);
        if (x.getParameters().size() > 0) {
            print0(ucase ? " USING " : " using ");
            printAndAccept!SQLExpr((x.getParameters()), ", ");
        }
        return false;
    }

    override
    public void endVisit(MysqlDeallocatePrepareStatement x) {

    }

    public bool visit(MysqlDeallocatePrepareStatement x) {
        print0(ucase ? "DEALLOCATE PREPARE " : "deallocate prepare ");
        x.getStatementName().accept(this);
        return false;
    }

    override
    public void endVisit(MySqlDeleteStatement x) {

    }

    override
    public bool visit(MySqlDeleteStatement x) {
        print0(ucase ? "DELETE " : "delete ");

        for (int i = 0, size = x.getHintsSize(); i < size; ++i) {
            SQLCommentHint hint = x.getHints().get(i);
            hint.accept(this);
            print(' ');
        }

        if (x.isLowPriority()) {
            print0(ucase ? "LOW_PRIORITY " : "low_priority ");
        }

        if (x.isQuick()) {
            print0(ucase ? "QUICK " : "quick ");
        }

        if (x.isIgnore()) {
            print0(ucase ? "IGNORE " : "ignore ");
        }

        if (x.isForceAllPartitions()) {
            print0(ucase ? "FORCE ALL PARTITIONS " : "force all partitions ");
        } else {
            SQLName partition = x.getForcePartition();
            if (partition !is null) {
                print0(ucase ? "FORCE PARTITION " : "force partition ");
                printExpr(partition);
                print(' ');
            }
        }

        SQLTableSource from = x.getFrom();
        if (from is null) {
            print0(ucase ? "FROM " : "from ");
            x.getTableSource().accept(this);
        } else {
            x.getTableSource().accept(this);
            println();
            print0(ucase ? "FROM " : "from ");
            from.accept(this);
        }

        SQLTableSource using = x.getUsing();
        if (using !is null) {
            println();
            print0(ucase ? "USING " : "using ");
            using.accept(this);
        }

        SQLExpr where = x.getWhere();
        if (where !is null) {
            println();
            this.indentCount++;
            print0(ucase ? "WHERE " : "where ");
            printExpr(where);
            this.indentCount--;
        }


        if (x.getOrderBy() !is null) {
            println();
            x.getOrderBy().accept(this);
        }

        if (x.getLimit() !is null) {
            println();
            x.getLimit().accept(this);
        }

        return false;
    }

    override
    public void endVisit(MySqlInsertStatement x) {

    }

    override
    public bool visit(MySqlInsertStatement x) {
        print0(ucase ? "INSERT " : "insert ");

        if (x.isLowPriority()) {
            print0(ucase ? "LOW_PRIORITY " : "low_priority ");
        }

        if (x.isDelayed()) {
            print0(ucase ? "DELAYED " : "delayed ");
        }

        if (x.isHighPriority()) {
            print0(ucase ? "HIGH_PRIORITY " : "high_priority ");
        }

        if (x.isIgnore()) {
            print0(ucase ? "IGNORE " : "ignore ");
        }

        if (x.isRollbackOnFail()) {
            print0(ucase ? "ROLLBACK_ON_FAIL " : "rollback_on_fail ");
        }

        print0(ucase ? "INTO " : "into ");

        SQLExprTableSource tableSource = x.getTableSource();
        if (typeid(tableSource) == typeid(SQLExprTableSource)) {
            visit(tableSource);
        } else {
            tableSource.accept(this);
        }

        string columnsString = x.getColumnsString();
        if (columnsString !is null) {
            if (!isEnabled(VisitorFeature.OutputSkipInsertColumnsString)) {
                print0(columnsString);
            }
        } else {
            List!(SQLExpr) columns = x.getColumns();
            if (columns.size() > 0) {
                this.indentCount++;
                print0(" (");
                for (int i = 0, size = columns.size(); i < size; ++i) {
                    if (i != 0) {
                        if (i % 5 == 0) {
                            println();
                        }
                        print0(", ");
                    }

                    SQLExpr column = columns.get(i);
                    if (cast(SQLIdentifierExpr)(column) !is null) {
                        print0((cast(SQLIdentifierExpr) column).getName());
                    } else {
                        printExpr(column);
                    }
                }
                print(')');
                this.indentCount--;
            }
        }

        List!(ValuesClause)  valuesList = x.getValuesList();
        if (!valuesList.isEmpty()) {
            println();
            printValuesList(valuesList);
        }

        if (x.getQuery() !is null) {
            println();
            x.getQuery().accept(this);
        }

        List!(SQLExpr) duplicateKeyUpdate = x.getDuplicateKeyUpdate();
        if (duplicateKeyUpdate.size() != 0) {
            println();
            print0(ucase ? "ON DUPLICATE KEY UPDATE " : "on duplicate key update ");
            for (int i = 0, size = duplicateKeyUpdate.size(); i < size; ++i) {
                if (i != 0) {
                    if (i % 5 == 0) {
                        println();
                    }
                    print0(", ");
                }
                duplicateKeyUpdate.get(i).accept(this);
            }
        }

        return false;
    }

    protected void printValuesList(List!(ValuesClause) valuesList) {

        if (this.parameterized && valuesList.size() > 0) {
            print0(ucase ? "VALUES " : "values ");
            this.indentCount++;
            visit(valuesList.get(0));
            this.indentCount--;
            if (valuesList.size() > 1) {
                this.incrementReplaceCunt();
            }
            return;
        }

        print0(ucase ? "VALUES " : "values ");
        if (valuesList.size() > 1) {
            this.indentCount++;
        }
        for (int i = 0, size = valuesList.size(); i < size; ++i) {
            if (i != 0) {
                print(',');
                println();
            }

            ValuesClause item = valuesList.get(i);
            visit(item);
        }
        if (valuesList.size() > 1) {
            this.indentCount--;
        }
    }

    override
    public void endVisit(MySqlLoadDataInFileStatement x) {

    }

    override
    public bool visit(MySqlLoadDataInFileStatement x) {
        print0(ucase ? "LOAD DATA " : "load data ");

        if (x.isLowPriority()) {
            print0(ucase ? "LOW_PRIORITY " : "low_priority ");
        }

        if (x.isConcurrent()) {
            print0(ucase ? "CONCURRENT " : "concurrent ");
        }

        if (x.isLocal()) {
            print0(ucase ? "LOCAL " : "local ");
        }

        print0(ucase ? "INFILE " : "infile ");

        x.getFileName().accept(this);

        if (x.isReplicate()) {
            print0(ucase ? " REPLACE " : " replace ");
        }

        if (x.isIgnore()) {
            print0(ucase ? " IGNORE " : " ignore ");
        }

        print0(ucase ? " INTO TABLE " : " into table ");
        x.getTableName().accept(this);

        if (x.getColumnsTerminatedBy() !is null || x.getColumnsEnclosedBy() !is null || x.getColumnsEscaped() !is null) {
            print0(ucase ? " COLUMNS" : " columns");
            if (x.getColumnsTerminatedBy() !is null) {
                print0(ucase ? " TERMINATED BY " : " terminated by ");
                x.getColumnsTerminatedBy().accept(this);
            }

            if (x.getColumnsEnclosedBy() !is null) {
                if (x.isColumnsEnclosedOptionally()) {
                    print0(ucase ? " OPTIONALLY" : " optionally");
                }
                print0(ucase ? " ENCLOSED BY " : " enclosed by ");
                x.getColumnsEnclosedBy().accept(this);
            }

            if (x.getColumnsEscaped() !is null) {
                print0(ucase ? " ESCAPED BY " : " escaped by ");
                x.getColumnsEscaped().accept(this);
            }
        }

        if (x.getLinesStartingBy() !is null || x.getLinesTerminatedBy() !is null) {
            print0(ucase ? " LINES" : " lines");
            if (x.getLinesStartingBy() !is null) {
                print0(ucase ? " STARTING BY " : " starting by ");
                x.getLinesStartingBy().accept(this);
            }

            if (x.getLinesTerminatedBy() !is null) {
                print0(ucase ? " TERMINATED BY " : " terminated by ");
                x.getLinesTerminatedBy().accept(this);
            }
        }

        if (x.getIgnoreLinesNumber() !is null) {
            print0(ucase ? " IGNORE " : " ignore ");
            x.getIgnoreLinesNumber().accept(this);
            print0(ucase ? " LINES" : " lines");
        }

        if (x.getColumns().size() != 0) {
            print0(" (");
            printAndAccept!SQLExpr((x.getColumns()), ", ");
            print(')');
        }

        if (x.getSetList().size() != 0) {
            print0(ucase ? " SET " : " set ");
            printAndAccept!SQLExpr((x.getSetList()), ", ");
        }

        return false;
    }

    override public bool visit(SQLReplaceStatement x) {
        print0(ucase ? "REPLACE " : "replace ");

        if (x.isLowPriority()) {
            print0(ucase ? "LOW_PRIORITY " : "low_priority ");
        }

        if (x.isDelayed()) {
            print0(ucase ? "DELAYED " : "delayed ");
        }

        print0(ucase ? "INTO " : "into ");

        printTableSourceExpr(x.getTableName());

        List!(SQLExpr) columns = x.getColumns();
        if (columns.size() > 0) {
            print0(" (");
            for (int i = 0, size = columns.size(); i < size; ++i) {
                if (i != 0) {
                    print0(", ");
                }

                SQLExpr columnn = columns.get(i);
                printExpr(columnn);
            }
            print(')');
        }

        List!(ValuesClause) valuesClauseList = x.getValuesList();
        if (valuesClauseList.size() != 0) {
            println();
            print0(ucase ? "VALUES " : "values ");
            int size = valuesClauseList.size();
            if (size == 0) {
                print0("()");
            } else {
                for (int i = 0; i < size; ++i) {
                    if (i != 0) {
                        print0(", ");
                    }
                    visit(valuesClauseList.get(i));
                }
            }
        }

        SQLQueryExpr query = x.getQuery();
        if (query !is null) {
            visit(query);
        }

        return false;
    }

    override
    public bool visit(SQLStartTransactionStatement x) {
        print0(ucase ? "START TRANSACTION" : "start transaction");
        if (x.isConsistentSnapshot()) {
            print0(ucase ? " WITH CONSISTENT SNAPSHOT" : " with consistent snapshot");
        }

        if (x.getHints() !is null && x.getHints().size() > 0) {
            print(' ');
            printAndAccept!SQLCommentHint((x.getHints()), " ");
        }

        if (x.isBegin()) {
            print0(ucase ? " BEGIN" : " begin");
        }

        if (x.isWork()) {
            print0(ucase ? " WORK" : " work");
        }

        return false;
    }

    override public bool visit(SQLRollbackStatement x) {
        print0(ucase ? "ROLLBACK" : "rollback");

        if (x.getChain() !is null) {
            if (x.getChain().booleanValue()) {
                print0(ucase ? " AND CHAIN" : " and chain");
            } else {
                print0(ucase ? " AND NO CHAIN" : " and no chain");
            }
        }

        if (x.getRelease() !is null) {
            if (x.getRelease().booleanValue()) {
                print0(ucase ? " AND RELEASE" : " and release");
            } else {
                print0(ucase ? " AND NO RELEASE" : " and no release");
            }
        }

        if (x.getTo() !is null) {
            print0(ucase ? " TO " : " to ");
            x.getTo().accept(this);
        }

        return false;
    }

    override
    public void endVisit(MySqlShowColumnsStatement x) {

    }

    override
    public bool visit(MySqlShowColumnsStatement x) {
        if (x.isFull()) {
            print0(ucase ? "SHOW FULL COLUMNS" : "show full columns");
        } else {
            print0(ucase ? "SHOW COLUMNS" : "show columns");
        }

        if (x.getTable() !is null) {
            print0(ucase ? " FROM " : " from ");
            if (x.getDatabase() !is null) {
                x.getDatabase().accept(this);
                print('.');
            }
            x.getTable().accept(this);
        }

        if (x.getLike() !is null) {
            print0(ucase ? " LIKE " : " like ");
            x.getLike().accept(this);
        }

        if (x.getWhere() !is null) {
            print0(ucase ? " WHERE " : " where ");
            x.getWhere().accept(this);
        }

        return false;
    }

    override
    public bool visit(SQLShowTablesStatement x) {
        if (x.isFull()) {
            print0(ucase ? "SHOW FULL TABLES" : "show full tables");
        } else {
            print0(ucase ? "SHOW TABLES" : "show tables");
        }

        if (x.getDatabase() !is null) {
            print0(ucase ? " FROM " : " from ");
            x.getDatabase().accept(this);
        }

        if (x.getLike() !is null) {
            print0(ucase ? " LIKE " : " like ");
            x.getLike().accept(this);
        }

        if (x.getWhere() !is null) {
            print0(ucase ? " WHERE " : " where ");
            x.getWhere().accept(this);
        }

        return false;
    }

    override
    public void endVisit(MySqlShowDatabasesStatement x) {

    }

    override
    public bool visit(MySqlShowDatabasesStatement x) {
        print0(ucase ? "SHOW DATABASES" : "show databases");

        if (x.getLike() !is null) {
            print0(ucase ? " LIKE " : " like ");
            x.getLike().accept(this);
        }

        if (x.getWhere() !is null) {
            print0(ucase ? " WHERE " : " where ");
            x.getWhere().accept(this);
        }

        return false;
    }

    override
    public void endVisit(MySqlShowWarningsStatement x) {

    }

    override
    public bool visit(MySqlShowWarningsStatement x) {
        if (x.isCount()) {
            print0(ucase ? "SHOW COUNT(*) WARNINGS" : "show count(*) warnings");
        } else {
            print0(ucase ? "SHOW WARNINGS" : "show warnings");
            if (x.getLimit() !is null) {
                print(' ');
                x.getLimit().accept(this);
            }
        }

        return false;
    }

    override
    public void endVisit(MySqlShowStatusStatement x) {

    }

    override
    public bool visit(MySqlShowStatusStatement x) {
        print0(ucase ? "SHOW " : "show ");

        if (x.isGlobal()) {
            print0(ucase ? "GLOBAL " : "global ");
        }

        if (x.isSession()) {
            print0(ucase ? "SESSION " : "session ");
        }

        print0(ucase ? "STATUS" : "status");

        if (x.getLike() !is null) {
            print0(ucase ? " LIKE " : " like ");
            x.getLike().accept(this);
        }

        if (x.getWhere() !is null) {
            print0(ucase ? " WHERE " : " where ");
            x.getWhere().accept(this);
        }

        return false;
    }

    override
    public void endVisit(MySqlLoadXmlStatement x) {

    }

    override
    public bool visit(MySqlLoadXmlStatement x) {
        print0(ucase ? "LOAD XML " : "load xml ");

        if (x.isLowPriority()) {
            print0(ucase ? "LOW_PRIORITY " : "low_priority ");
        }

        if (x.isConcurrent()) {
            print0(ucase ? "CONCURRENT " : "concurrent ");
        }

        if (x.isLocal()) {
            print0(ucase ? "LOCAL " : "local ");
        }

        print0(ucase ? "INFILE " : "infile ");

        x.getFileName().accept(this);

        if (x.isReplicate()) {
            print0(ucase ? " REPLACE " : " replace ");
        }

        if (x.isIgnore()) {
            print0(ucase ? " IGNORE " : " ignore ");
        }

        print0(ucase ? " INTO TABLE " : " into table ");
        x.getTableName().accept(this);

        if (x.getCharset() !is null) {
            print0(ucase ? " CHARSET " : " charset ");
            print0(x.getCharset());
        }

        if (x.getRowsIdentifiedBy() !is null) {
            print0(ucase ? " ROWS IDENTIFIED BY " : " rows identified by ");
            x.getRowsIdentifiedBy().accept(this);
        }

        if (x.getSetList().size() != 0) {
            print0(ucase ? " SET " : " set ");
            printAndAccept!SQLExpr((x.getSetList()), ", ");
        }

        return false;
    }

    override
    public void endVisit(CobarShowStatus x) {

    }

    override
    public bool visit(CobarShowStatus x) {
        print0(ucase ? "SHOW COBAR_STATUS" : "show cobar_status");
        return false;
    }

    override
    public void endVisit(MySqlKillStatement x) {

    }

    override
    public bool visit(MySqlKillStatement x) {
        if (MySqlKillStatement.Type.CONNECTION == (x.getType())) {
            print0(ucase ? "KILL CONNECTION " : "kill connection ");
        } else if (MySqlKillStatement.Type.QUERY == (x.getType())) {
            print0(ucase ? "KILL QUERY " : "kill query ");
        } else {
            print0(ucase ? "KILL " : "kill ");
        }

        printAndAccept!SQLExpr((x.getThreadIds()), ", ");
        return false;
    }

    override
    public void endVisit(MySqlBinlogStatement x) {

    }

    override
    public bool visit(MySqlBinlogStatement x) {
        print0(ucase ? "BINLOG " : "binlog ");
        x.getExpr().accept(this);
        return false;
    }

    override
    public void endVisit(MySqlResetStatement x) {

    }

    override
    public bool visit(MySqlResetStatement x) {
        print0(ucase ? "RESET " : "reset ");
        for (int i = 0; i < x.getOptions().size(); ++i) {
            if (i != 0) {
                print0(", ");
            }
            print0(x.getOptions().get(i));
        }
        return false;
    }

    override
    public void endVisit(MySqlCreateUserStatement x) {

    }

    override
    public bool visit(MySqlCreateUserStatement x) {
        print0(ucase ? "CREATE USER " : "create user ");
        printAndAccept!(MySqlCreateUserStatement.UserSpecification)((x.getUsers()), ", ");
        return false;
    }

    override
    public void endVisit(MySqlCreateUserStatement.UserSpecification x) {

    }

    override
    public bool visit(MySqlCreateUserStatement.UserSpecification x) {
        x.getUser().accept(this);

        if (x.getPassword() !is null) {
            print0(ucase ? " IDENTIFIED BY " : " identified by ");
            if (x.isPasswordHash()) {
                print0(ucase ? "PASSWORD " : "password ");
            }
            x.getPassword().accept(this);
        }

        if (x.getAuthPlugin() !is null) {
            print0(ucase ? " IDENTIFIED WITH " : " identified with ");
            x.getAuthPlugin().accept(this);
        }
        return false;
    }

    override
    public void endVisit(MySqlPartitionByKey x) {

    }

    override
    public bool visit(MySqlPartitionByKey x) {
        if (x.isLinear()) {
            print0(ucase ? "LINEAR KEY (" : "linear key (");
        } else {
            print0(ucase ? "KEY (" : "key (");
        }
        printAndAccept!SQLExpr((x.getColumns()), ", ");
        print(')');

        printPartitionsCountAndSubPartitions(x);
        return false;
    }


    //

    override
    public void endVisit(MySqlSelectQueryBlock x) {

    }

    override
    public bool visit(MySqlOutFileExpr x) {
        print0(ucase ? "OUTFILE " : "outfile ");
        x.getFile().accept(this);

        if (x.getCharset() !is null) {
            print0(ucase ? " CHARACTER SET " : " character set ");
            print0(x.getCharset());
        }

        if (x.getColumnsTerminatedBy() !is null || x.getColumnsEnclosedBy() !is null || x.getColumnsEscaped() !is null) {
            print0(ucase ? " COLUMNS" : " columns");
            if (x.getColumnsTerminatedBy() !is null) {
                print0(ucase ? " TERMINATED BY " : " terminated by ");
                x.getColumnsTerminatedBy().accept(this);
            }

            if (x.getColumnsEnclosedBy() !is null) {
                if (x.isColumnsEnclosedOptionally()) {
                    print0(ucase ? " OPTIONALLY" : " optionally");
                }
                print0(ucase ? " ENCLOSED BY " : " enclosed by ");
                x.getColumnsEnclosedBy().accept(this);
            }

            if (x.getColumnsEscaped() !is null) {
                print0(ucase ? " ESCAPED BY " : " escaped by ");
                x.getColumnsEscaped().accept(this);
            }
        }

        if (x.getLinesStartingBy() !is null || x.getLinesTerminatedBy() !is null) {
            print0(ucase ? " LINES" : " lines");
            if (x.getLinesStartingBy() !is null) {
                print0(ucase ? " STARTING BY " : " starting by ");
                x.getLinesStartingBy().accept(this);
            }

            if (x.getLinesTerminatedBy() !is null) {
                print0(ucase ? " TERMINATED BY " : " terminated by ");
                x.getLinesTerminatedBy().accept(this);
            }
        }

        return false;
    }

    override
    public void endVisit(MySqlOutFileExpr x) {

    }

    override
    public bool visit(MySqlExplainStatement x) {
        string name = x.isDescribe() ? "desc" : "explain";
        print0(ucase ? toUpper(name) : name);
        print(' ');

        // tbl_name [col_name | wild]
        if (x.getTableName() !is null) {
            x.getTableName().accept(this);
            if (x.getColumnName() !is null) {
                print(' ');
                x.getColumnName().accept(this);
            } else if (x.getWild() !is null) {
                print(' ');
                x.getWild().accept(this);
            }
        } else {
            // [explain_type]
            string type = x.getType();
            if (type !is null) {
                print0(type);
                print(' ');
                if ("format".equalsIgnoreCase(type)) {
                    print0("= ");
                    print0(x.getFormat());
                    print(' ');
                }
            }

            // {explainable_stmt | FOR CONNECTION connection_id}
            if (x.getConnectionId() !is null) {
                print0(ucase ? "FOR CONNECTION " : "for connection ");
                x.getConnectionId().accept(this);
            } else {
                x.getStatement().accept(this);
            }
        }

        return false;
    }

    override
    public void endVisit(MySqlExplainStatement x) {

    }

    override
    public bool visit(MySqlUpdateStatement x) {
        List!(SQLExpr) returning = x.getReturning();
        if (returning !is null && returning.size() > 0) {
            print0(ucase ? "SELECT " : "select ");
            printAndAccept!SQLExpr((returning), ", ");
            println();
            print0(ucase ? "FROM " : "from ");
        }

        print0(ucase ? "UPDATE " : "update ");

        if (x.isLowPriority()) {
            print0(ucase ? "LOW_PRIORITY " : "low_priority ");
        }

        if (x.isIgnore()) {
            print0(ucase ? "IGNORE " : "ignore ");
        }


        if (x.getHints() !is null && x.getHints().size() > 0) {
            printAndAccept!SQLHint((x.getHints()), " ");
            print0(" ");
        }

        if (x.isCommitOnSuccess()) {
            print0(ucase ? "COMMIT_ON_SUCCESS " : "commit_on_success ");
        }

        if (x.isRollBackOnFail()) {
            print0(ucase ? "ROLLBACK_ON_FAIL " : "rollback_on_fail ");
        }

        if (x.isQueryOnPk()) {
            print0(ucase ? "QUEUE_ON_PK " : "queue_on_pk ");
        }

        SQLExpr targetAffectRow = x.getTargetAffectRow();
        if (targetAffectRow !is null) {
            print0(ucase ? "TARGET_AFFECT_ROW " : "target_affect_row ");
            printExpr(targetAffectRow);
            print(' ');
        }

        if (x.isForceAllPartitions()) {
            print0(ucase ? "FORCE ALL PARTITIONS " : "force all partitions ");
        } else {
            SQLName partition = x.getForcePartition();
            if (partition !is null) {
                print0(ucase ? "FORCE PARTITION " : "force partition ");
                printExpr(partition);
                print(' ');
            }
        }

        printTableSource(x.getTableSource());

        println();
        print0(ucase ? "SET " : "set ");
        List!(SQLUpdateSetItem) items = x.getItems();
        for (int i = 0, size = items.size(); i < size; ++i) {
            if (i != 0) {
                print0(", ");
            }
            SQLUpdateSetItem item = items.get(i);
            visit(item);
        }

        SQLExpr where = x.getWhere();
        if (where !is null) {
            println();
            indentCount++;
            print0(ucase ? "WHERE " : "where ");
            printExpr(where);
            indentCount--;
        }

        SQLOrderBy orderBy = x.getOrderBy();
        if (orderBy !is null) {
            println();
            visit(orderBy);
        }

        SQLLimit limit = x.getLimit();
        if (limit !is null) {
            println();
            visit(limit);
        }
        return false;
    }

    override
    public void endVisit(MySqlUpdateStatement x) {

    }

    override
    public bool visit(MySqlSetTransactionStatement x) {
        if (x.getGlobal() is null) {
            print0(ucase ? "SET TRANSACTION " : "set transaction ");
        } else if (x.getGlobal().booleanValue()) {
            print0(ucase ? "SET GLOBAL TRANSACTION " : "set global transaction ");
        } else {
            print0(ucase ? "SET SESSION TRANSACTION " : "set session transaction ");
        }

        if (x.getIsolationLevel() !is null) {
            print0(ucase ? "ISOLATION LEVEL " : "isolation level ");
            print0(x.getIsolationLevel());
        }

        if (x.getAccessModel() !is null) {
            print0(ucase ? "READ " : "read ");
            print0(x.getAccessModel());
        }

        return false;
    }

    override
    public void endVisit(MySqlSetTransactionStatement x) {

    }
//
//    override
//    public bool visit(MySqlSetNamesStatement x) {
//        print0(ucase ? "SET NAMES " : "set names ");
//        if (x.isDefault()) {
//            print0(ucase ? "DEFAULT" : "default");
//        } else {
//            print0(x.getCharSet());
//            if (x.getCollate() !is null) {
//                print0(ucase ? " COLLATE " : " collate ");
//                print0(x.getCollate());
//            }
//        }
//        return false;
//    }

//    public bool visit(MySqlSetCharSetStatement x) {
//        print0(ucase ? "SET CHARACTER SET " : "set character set ");
//        if (x.isDefault()) {
//            print0(ucase ? "DEFAULT" : "default");
//        } else {
//            print0(x.getCharSet());
//            if (x.getCollate() !is null) {
//                print0(ucase ? " COLLATE " : " collate ");
//                print0(x.getCollate());
//            }
//        }
//        return false;
//    }

    override
    public void endVisit(MySqlShowAuthorsStatement x) {

    }

    override
    public bool visit(MySqlShowAuthorsStatement x) {
        print0(ucase ? "SHOW AUTHORS" : "show authors");
        return false;
    }

    override
    public void endVisit(MySqlShowBinaryLogsStatement x) {

    }

    override
    public bool visit(MySqlShowBinaryLogsStatement x) {
        print0(ucase ? "SHOW BINARY LOGS" : "show binary logs");
        return false;
    }

    override
    public bool visit(MySqlShowMasterLogsStatement x) {
        print0(ucase ? "SHOW MASTER LOGS" : "show master logs");
        return false;
    }

    override
    public void endVisit(MySqlShowMasterLogsStatement x) {

    }

    override
    public bool visit(MySqlShowCollationStatement x) {
        print0(ucase ? "SHOW COLLATION" : "show collation");
        if (x.getPattern() !is null) {
            print0(ucase ? " LIKE " : " like ");
            x.getPattern().accept(this);
        }
        if (x.getWhere() !is null) {
            print0(ucase ? " WHERE " : " where ");
            x.getWhere().accept(this);
        }
        return false;
    }

    override
    public void endVisit(MySqlShowCollationStatement x) {

    }

    override
    public bool visit(MySqlShowBinLogEventsStatement x) {
        print0(ucase ? "SHOW BINLOG EVENTS" : "show binlog events");
        if (x.getIn() !is null) {
            print0(ucase ? " IN " : " in ");
            x.getIn().accept(this);
        }
        if (x.getFrom() !is null) {
            print0(ucase ? " FROM " : " from ");
            x.getFrom().accept(this);
        }
        if (x.getLimit() !is null) {
            print(' ');
            x.getLimit().accept(this);
        }
        return false;
    }

    override
    public void endVisit(MySqlShowBinLogEventsStatement x) {

    }

    override
    public bool visit(MySqlShowCharacterSetStatement x) {
        print0(ucase ? "SHOW CHARACTER SET" : "show character set");
        if (x.getPattern() !is null) {
            print0(ucase ? " LIKE " : " like ");
            x.getPattern().accept(this);
        }
        if (x.getWhere() !is null) {
            print0(ucase ? " WHERE " : " where ");
            x.getWhere().accept(this);
        }
        return false;
    }

    override
    public void endVisit(MySqlShowCharacterSetStatement x) {

    }

    override
    public bool visit(MySqlShowContributorsStatement x) {
        print0(ucase ? "SHOW CONTRIBUTORS" : "show contributors");
        return false;
    }

    override
    public void endVisit(MySqlShowContributorsStatement x) {

    }

    override
    public bool visit(MySqlShowCreateDatabaseStatement x) {
        print0(ucase ? "SHOW CREATE DATABASE " : "show create database ");
        x.getDatabase().accept(this);
        return false;
    }

    override
    public void endVisit(MySqlShowCreateDatabaseStatement x) {

    }

    override
    public bool visit(MySqlShowCreateEventStatement x) {
        print0(ucase ? "SHOW CREATE EVENT " : "show create event ");
        x.getEventName().accept(this);
        return false;
    }

    override
    public void endVisit(MySqlShowCreateEventStatement x) {

    }

    override
    public bool visit(MySqlShowCreateFunctionStatement x) {
        print0(ucase ? "SHOW CREATE FUNCTION " : "show create function ");
        x.getName().accept(this);
        return false;
    }

    override
    public void endVisit(MySqlShowCreateFunctionStatement x) {

    }

    override
    public bool visit(MySqlShowCreateProcedureStatement x) {
        print0(ucase ? "SHOW CREATE PROCEDURE " : "show create procedure ");
        x.getName().accept(this);
        return false;
    }

    override
    public void endVisit(MySqlShowCreateProcedureStatement x) {

    }

    override
    public bool visit(MySqlShowCreateTableStatement x) {
        print0(ucase ? "SHOW CREATE TABLE " : "show create table ");
        x.getName().accept(this);
        return false;
    }

    override
    public void endVisit(MySqlShowCreateTableStatement x) {

    }

    override
    public bool visit(MySqlShowCreateTriggerStatement x) {
        print0(ucase ? "SHOW CREATE TRIGGER " : "show create trigger ");
        x.getName().accept(this);
        return false;
    }

    override
    public void endVisit(MySqlShowCreateTriggerStatement x) {

    }

    override
    public bool visit(MySqlShowCreateViewStatement x) {
        print0(ucase ? "SHOW CREATE VIEW " : "show create view ");
        x.getName().accept(this);
        return false;
    }

    override
    public void endVisit(MySqlShowCreateViewStatement x) {

    }

    override
    public bool visit(MySqlShowEngineStatement x) {
        print0(ucase ? "SHOW ENGINE " : "show engine ");
        x.getName().accept(this);
        print(' ');
        print0(x.getOption().name());
        return false;
    }

    override
    public void endVisit(MySqlShowEngineStatement x) {

    }

    override
    public bool visit(MySqlShowEventsStatement x) {
        print0(ucase ? "SHOW EVENTS" : "show events");
        if (x.getSchema() !is null) {
            print0(ucase ? " FROM " : " from ");
            x.getSchema().accept(this);
        }

        if (x.getLike() !is null) {
            print0(ucase ? " LIKE " : " like ");
            x.getLike().accept(this);
        }

        if (x.getWhere() !is null) {
            print0(ucase ? " WHERE " : " where ");
            x.getWhere().accept(this);
        }

        return false;
    }

    override
    public void endVisit(MySqlShowEventsStatement x) {

    }

    override
    public bool visit(MySqlShowFunctionCodeStatement x) {
        print0(ucase ? "SHOW FUNCTION CODE " : "show function code ");
        x.getName().accept(this);
        return false;
    }

    override
    public void endVisit(MySqlShowFunctionCodeStatement x) {

    }

    override
    public bool visit(MySqlShowFunctionStatusStatement x) {
        print0(ucase ? "SHOW FUNCTION STATUS" : "show function status");
        if (x.getLike() !is null) {
            print0(ucase ? " LIKE " : " like ");
            x.getLike().accept(this);
        }

        if (x.getWhere() !is null) {
            print0(ucase ? " WHERE " : " where ");
            x.getWhere().accept(this);
        }

        return false;
    }

    override
    public void endVisit(MySqlShowFunctionStatusStatement x) {

    }

    override
    public bool visit(MySqlShowEnginesStatement x) {
        if (x.isStorage()) {
            print0(ucase ? "SHOW STORAGE ENGINES" : "show storage engines");
        } else {
            print0(ucase ? "SHOW ENGINES" : "show engines");
        }
        return false;
    }

    override
    public void endVisit(MySqlShowEnginesStatement x) {

    }

    override
    public bool visit(MySqlShowErrorsStatement x) {
        if (x.isCount()) {
            print0(ucase ? "SHOW COUNT(*) ERRORS" : "show count(*) errors");
        } else {
            print0(ucase ? "SHOW ERRORS" : "show errors");
            if (x.getLimit() !is null) {
                print(' ');
                x.getLimit().accept(this);
            }
        }
        return false;
    }

    override
    public void endVisit(MySqlShowErrorsStatement x) {

    }

    override
    public bool visit(MySqlShowGrantsStatement x) {
        print0(ucase ? "SHOW GRANTS" : "show grants");
        if (x.getUser() !is null) {
            print0(ucase ? " FOR " : " for ");
            x.getUser().accept(this);
        }
        return false;
    }

    override
    public void endVisit(MySqlShowGrantsStatement x) {

    }

    override
    public bool visit(MySqlUserName x) {
        print0(x.getUserName());

        string host = x.getHost();
        if (host !is null) {
            print('@');
            print0(host);
        }

        string identifiedBy = x.getIdentifiedBy();
        if (identifiedBy !is null) {
            print0(ucase ? " IDENTIFIED BY '" : " identified by '");
            print0(identifiedBy);
            print('\'');
        }

        return false;
    }

    override
    public void endVisit(MySqlUserName x) {

    }

    override
    public bool visit(MySqlShowIndexesStatement x) {
        print0(ucase ? "SHOW INDEX" : "show index");

        if (x.getTable() !is null) {
            print0(ucase ? " FROM " : " from ");
            if (x.getDatabase() !is null) {
                x.getDatabase().accept(this);
                print('.');
            }
            x.getTable().accept(this);
        }

        if (x.getHints() !is null && x.getHints().size() > 0) {
            print(' ');
            printAndAccept!SQLCommentHint((x.getHints()), " ");
        }

        return false;
    }

    override
    public void endVisit(MySqlShowIndexesStatement x) {

    }

    override
    public bool visit(MySqlShowKeysStatement x) {
        print0(ucase ? "SHOW KEYS" : "show keys");

        if (x.getTable() !is null) {
            print0(ucase ? " FROM " : " from ");
            if (x.getDatabase() !is null) {
                x.getDatabase().accept(this);
                print('.');
            }
            x.getTable().accept(this);
        }
        return false;
    }

    override
    public void endVisit(MySqlShowKeysStatement x) {

    }

    override
    public bool visit(MySqlShowMasterStatusStatement x) {
        print0(ucase ? "SHOW MASTER STATUS" : "show master status");
        return false;
    }

    override
    public void endVisit(MySqlShowMasterStatusStatement x) {

    }

    override
    public bool visit(MySqlShowOpenTablesStatement x) {
        print0(ucase ? "SHOW OPEN TABLES" : "show open tables");

        if (x.getDatabase() !is null) {
            print0(ucase ? " FROM " : " from ");
            x.getDatabase().accept(this);
        }

        if (x.getLike() !is null) {
            print0(ucase ? " LIKE " : " like ");
            x.getLike().accept(this);
        }

        if (x.getWhere() !is null) {
            print0(ucase ? " WHERE " : " where ");
            x.getWhere().accept(this);
        }

        return false;
    }

    override
    public void endVisit(MySqlShowOpenTablesStatement x) {

    }

    override
    public bool visit(MySqlShowPluginsStatement x) {
        print0(ucase ? "SHOW PLUGINS" : "show plugins");
        return false;
    }

    override
    public void endVisit(MySqlShowPluginsStatement x) {

    }

    override
    public bool visit(MySqlShowPrivilegesStatement x) {
        print0(ucase ? "SHOW PRIVILEGES" : "show privileges");
        return false;
    }

    override
    public void endVisit(MySqlShowPrivilegesStatement x) {

    }

    override
    public bool visit(MySqlShowProcedureCodeStatement x) {
        print0(ucase ? "SHOW PROCEDURE CODE " : "show procedure code ");
        x.getName().accept(this);
        return false;
    }

    override
    public void endVisit(MySqlShowProcedureCodeStatement x) {

    }

    override
    public bool visit(MySqlShowProcedureStatusStatement x) {
        print0(ucase ? "SHOW PROCEDURE STATUS" : "show procedure status");
        if (x.getLike() !is null) {
            print0(ucase ? " LIKE " : " like ");
            x.getLike().accept(this);
        }

        if (x.getWhere() !is null) {
            print0(ucase ? " WHERE " : " where ");
            x.getWhere().accept(this);
        }
        return false;
    }

    override
    public void endVisit(MySqlShowProcedureStatusStatement x) {

    }

    override
    public bool visit(MySqlShowProcessListStatement x) {
        if (x.isFull()) {
            print0(ucase ? "SHOW FULL PROCESSLIST" : "show full processlist");
        } else {
            print0(ucase ? "SHOW PROCESSLIST" : "show processlist");
        }
        return false;
    }

    override
    public void endVisit(MySqlShowProcessListStatement x) {

    }

    override
    public bool visit(MySqlShowProfileStatement x) {
        print0(ucase ? "SHOW PROFILE" : "show profile");
        for (int i = 0; i < x.getTypes().size(); ++i) {
            if (i == 0) {
                print(' ');
            } else {
                print0(", ");
            }
            print0(x.getTypes().get(i).name);
        }

        if (x.getForQuery() !is null) {
            print0(ucase ? " FOR QUERY " : " for query ");
            x.getForQuery().accept(this);
        }

        if (x.getLimit() !is null) {
            print(' ');
            x.getLimit().accept(this);
        }
        return false;
    }

    override
    public void endVisit(MySqlShowProfileStatement x) {

    }

    override
    public bool visit(MySqlShowProfilesStatement x) {
        print0(ucase ? "SHOW PROFILES" : "show profiles");
        return false;
    }

    override
    public void endVisit(MySqlShowProfilesStatement x) {

    }

    override
    public bool visit(MySqlShowRelayLogEventsStatement x) {
        print0("SHOW RELAYLOG EVENTS");

        if (x.getLogName() !is null) {
            print0(ucase ? " IN " : " in ");
            x.getLogName().accept(this);
        }

        if (x.getFrom() !is null) {
            print0(ucase ? " FROM " : " from ");
            x.getFrom().accept(this);
        }

        if (x.getLimit() !is null) {
            print(' ');
            x.getLimit().accept(this);
        }

        return false;
    }

    override
    public void endVisit(MySqlShowRelayLogEventsStatement x) {

    }

    override
    public bool visit(MySqlShowSlaveHostsStatement x) {
        print0(ucase ? "SHOW SLAVE HOSTS" : "show slave hosts");
        return false;
    }

    override
    public void endVisit(MySqlShowSlaveHostsStatement x) {

    }

    override
    public bool visit(MySqlShowSlaveStatusStatement x) {
        print0(ucase ? "SHOW SLAVE STATUS" : "show slave status");
        return false;
    }

    override
    public void endVisit(MySqlShowSlaveStatusStatement x) {

    }

    override
    public bool visit(MySqlShowTableStatusStatement x) {
        print0(ucase ? "SHOW TABLE STATUS" : "show table status");
        if (x.getDatabase() !is null) {
            print0(ucase ? " FROM " : " from ");
            x.getDatabase().accept(this);
        }

        if (x.getLike() !is null) {
            print0(ucase ? " LIKE " : " like ");
            x.getLike().accept(this);
        }

        if (x.getWhere() !is null) {
            print0(ucase ? " WHERE " : " where ");
            x.getWhere().accept(this);
        }

        return false;
    }

    override
    public void endVisit(MySqlShowTableStatusStatement x) {

    }

    override
    public bool visit(MySqlShowTriggersStatement x) {
        print0(ucase ? "SHOW TRIGGERS" : "show triggers");

        if (x.getDatabase() !is null) {
            print0(ucase ? " FROM " : " from ");
            x.getDatabase().accept(this);
        }

        if (x.getLike() !is null) {
            print0(ucase ? " LIKE " : " like ");
            x.getLike().accept(this);
        }

        if (x.getWhere() !is null) {
            print0(ucase ? " WHERE " : " where ");
            x.getWhere().accept(this);
        }

        return false;
    }

    override
    public void endVisit(MySqlShowTriggersStatement x) {

    }

    override
    public bool visit(MySqlShowVariantsStatement x) {
        print0(ucase ? "SHOW " : "show ");

        if (x.isGlobal()) {
            print0(ucase ? "GLOBAL " : "global ");
        }

        if (x.isSession()) {
            print0(ucase ? "SESSION " : "session ");
        }

        print0(ucase ? "VARIABLES" : "variables");

        if (x.getLike() !is null) {
            print0(ucase ? " LIKE " : " like ");
            x.getLike().accept(this);
        }

        if (x.getWhere() !is null) {
            print0(ucase ? " WHERE " : " where ");
            x.getWhere().accept(this);
        }

        return false;
    }

    override
    public void endVisit(MySqlShowVariantsStatement x) {

    }

    override
    public bool visit(SQLAlterTableStatement x) {
        if (x.isIgnore()) {
            print0(ucase ? "ALTER IGNORE TABLE " : "alter ignore table ");
        } else {
            print0(ucase ? "ALTER TABLE " : "alter table ");
        }
        printTableSourceExpr(x.getName());
        this.indentCount++;
        for (int i = 0; i < x.getItems().size(); ++i) {
            SQLAlterTableItem item = x.getItems().get(i);
            if (i != 0) {
                print(',');
            }
            println();
            item.accept(this);
        }

        if (x.isRemovePatiting()) {
            println();
            print0(ucase ? "REMOVE PARTITIONING" : "remove partitioning");
        }

        if (x.isUpgradePatiting()) {
            println();
            print0(ucase ? "UPGRADE PARTITIONING" : "upgrade partitioning");
        }

        if (x.getTableOptions().size() > 0) {
            println();
        }

        this.indentCount--;

        int i = 0;
        foreach(string key, SQLObject v; x.getTableOptions()) {
            // string key = option.getKey();
            if (i != 0) {
                print(' ');
            }
            print0(ucase ? key : toLower(key));

            if ("TABLESPACE" == (key)) {
                print(' ');
                v.accept(this);
                continue;
            } else if ("UNION" == (key)) {
                print0(" = (");
                v.accept(this);
                print(')');
                continue;
            }

            print0(" = ");

            v.accept(this);
            i++;
        }

        return false;
    }

    override
    public bool visit(SQLAlterTableAddColumn x) {
        print0(ucase ? "ADD COLUMN " : "add column ");

        if (x.getColumns().size() > 1) {
            print('(');
        }
        printAndAccept!SQLColumnDefinition((x.getColumns()), ", ");
        if (x.getFirstColumn() !is null) {
            print0(ucase ? " FIRST " : " first ");
            x.getFirstColumn().accept(this);
        } else if (x.getAfterColumn() !is null) {
            print0(ucase ? " AFTER " : " after ");
            x.getAfterColumn().accept(this);
        } else if (x.isFirst()) {
            print0(ucase ? " FIRST" : " first");
        }

        if (x.getColumns().size() > 1) {
            print(')');
        }
        return false;
    }

    override
    public bool visit(MySqlRenameTableStatement.Item x) {
        x.getName().accept(this);
        print0(ucase ? " TO " : " to ");
        x.getTo().accept(this);
        return false;
    }

    override
    public void endVisit(MySqlRenameTableStatement.Item x) {

    }

    override
    public bool visit(MySqlRenameTableStatement x) {
        print0(ucase ? "RENAME TABLE " : "rename table ");
        printAndAccept!(MySqlRenameTableStatement.Item)((x.getItems()), ", ");
        return false;
    }

    override
    public void endVisit(MySqlRenameTableStatement x) {

    }

    override
    public bool visit(MySqlUseIndexHint x) {
        print0(ucase ? "USE INDEX " : "use index ");
        if (x.getOption().name.length != 0) {
            print0(ucase ? "FOR " : "for ");
            print0(x.getOption().name);
            print(' ');
        }
        print('(');
        printAndAccept!SQLName((x.getIndexList()), ", ");
        print(')');
        return false;
    }

    override
    public void endVisit(MySqlUseIndexHint x) {

    }

    override
    public bool visit(MySqlIgnoreIndexHint x) {
        print0(ucase ? "IGNORE INDEX " : "ignore index ");
        if (x.getOption().name.length != 0) {
            print0(ucase ? "FOR " : "for ");
            print0(ucase ? x.getOption().name : x.getOption().name_lcase);
            print(' ');
        }
        print('(');
        printAndAccept!SQLName((x.getIndexList()), ", ");
        print(')');
        return false;
    }

    override
    public void endVisit(MySqlIgnoreIndexHint x) {

    }

    override public bool visit(SQLExprTableSource x) {
        printTableSourceExpr(x.getExpr());

        string alias_p = x.getAlias();
        if (alias_p !is null) {
            print(' ');
            print0(alias_p);
        }

        for (int i = 0; i < x.getHintsSize(); ++i) {
            print(' ');
            x.getHints().get(i).accept(this);
        }

        if (x.getPartitionSize() > 0) {
            print0(ucase ? " PARTITION (" : " partition (");
            printlnAndAccept!(SQLName)((x.getPartitions()), ", ");
            print(')');
        }

        return false;
    }

    override
    public bool visit(MySqlLockTableStatement x) {
        print0(ucase ? "LOCK TABLES" : "lock tables");
        List!(MySqlLockTableStatement.Item) items = x.getItems();
        if(items.size() > 0) {
            print(' ');
            printAndAccept!(MySqlLockTableStatement.Item)((items), ", ");
        }
        return false;
    }

    override
    public void endVisit(MySqlLockTableStatement x) {

    }

    override
    public bool visit(MySqlLockTableStatement.Item x) {
        x.getTableSource().accept(this);
        if (x.getLockType().name.length != 0) {
            print(' ');
            print0(x.getLockType().name);
        }

        if (x.getHints() !is null && x.getHints().size() > 0) {
            print(' ');
            printAndAccept!SQLCommentHint((x.getHints()), " ");
        }
        return false;
    }

    override
    public void endVisit(MySqlLockTableStatement.Item x) {

    }

    override
    public bool visit(MySqlUnlockTablesStatement x) {
        print0(ucase ? "UNLOCK TABLES" : "unlock tables");
        return false;
    }

    override
    public void endVisit(MySqlUnlockTablesStatement x) {

    }

    override
    public bool visit(MySqlForceIndexHint x) {
        print0(ucase ? "FORCE INDEX " : "force index ");
        if (x.getOption().name.length != 0) {
            print0(ucase ? "FOR " : "for ");
            print0(x.getOption().name);
            print(' ');
        }
        print('(');
        printAndAccept!SQLName((x.getIndexList()), ", ");
        print(')');
        return false;
    }

    override
    public void endVisit(MySqlForceIndexHint x) {

    }

    override
    public bool visit(MySqlAlterTableChangeColumn x) {
        print0(ucase ? "CHANGE COLUMN " : "change column ");
        x.getColumnName().accept(this);
        print(' ');
        x.getNewColumnDefinition().accept(this);
        if (x.getFirstColumn() !is null) {
            print0(ucase ? " FIRST " : " first ");
            x.getFirstColumn().accept(this);
        } else if (x.getAfterColumn() !is null) {
            print0(ucase ? " AFTER " : " after ");
            x.getAfterColumn().accept(this);
        } else if (x.isFirst()) {
            print0(ucase ? " FIRST" : " first");
        }

        return false;
    }

    override
    public void endVisit(MySqlAlterTableChangeColumn x) {

    }

    override
    public bool visit(MySqlAlterTableModifyColumn x) {
        print0(ucase ? "MODIFY COLUMN " : "modify column ");
        x.getNewColumnDefinition().accept(this);
        if (x.getFirstColumn() !is null) {
            print0(ucase ? " FIRST " : " first ");
            x.getFirstColumn().accept(this);
        } else if (x.getAfterColumn() !is null) {
            print0(ucase ? " AFTER " : " after ");
            x.getAfterColumn().accept(this);
        } else if (x.isFirst()) {
            print0(ucase ? " FIRST" : " first");
        }

        return false;
    }

    override
    public void endVisit(MySqlAlterTableModifyColumn x) {

    }

    override
    public bool visit(MySqlAlterTableOption x) {
        print0(x.getName());
        print0(" = ");
        print0((cast(Object)(x.getValue())).toString());
        return false;
    }

    override
    public void endVisit(MySqlAlterTableOption x) {

    }

    override
    public void endVisit(MySqlCreateTableStatement x) {

    }

    override
    public bool visit(MySqlHelpStatement x) {
        print0(ucase ? "HELP " : "help ");
        x.getContent().accept(this);
        return false;
    }

    override
    public void endVisit(MySqlHelpStatement x) {

    }

    override
    public bool visit(MySqlCharExpr x) {
        if (this.parameterized) {
            print('?');
            incrementReplaceCunt();
            if (this.parameters !is null) {
                ExportParameterVisitorUtils.exportParameter(this.parameters, x);
            }
            return false;
        }

        print0((cast(Object)(x)).toString());
        return false;
    }

    override
    public void endVisit(MySqlCharExpr x) {

    }

    override
    public bool visit(MySqlUnique x) {
        if (x.isHasConstaint()) {
            print0(ucase ? "CONSTRAINT " : "constraint ");
            if (x.getName() !is null) {
                x.getName().accept(this);
                print(' ');
            }
        }

        print0(ucase ? "UNIQUE" : "unique");

        SQLName name = x.getName();
        if (name !is null) {
            print(' ');
            name.accept(this);
        }

        if (x.getIndexType() !is null) {
            print0(ucase ? " USING " : " using ");
            print0(x.getIndexType());
        }

        print0(" (");
        printAndAccept!SQLSelectOrderByItem((x.getColumns()), ", ");
        print(')');

        SQLExpr keyBlockSize = x.getKeyBlockSize();
        if (keyBlockSize !is null) {
            print0(ucase ? " KEY_BLOCK_SIZE = " : " key_block_size = ");
            keyBlockSize.accept(this);
        }

        SQLExpr comment = x.getComment();
        if (comment !is null) {
            print0(" COMMENT ");
            comment.accept(this);
        }

        return false;
    }

    override
    public bool visit(MysqlForeignKey x) {
        if (x.isHasConstraint()) {
            print0(ucase ? "CONSTRAINT " : "constraint ");
            if (x.getName() !is null) {
                x.getName().accept(this);
                print(' ');
            }
        }

        print0(ucase ? "FOREIGN KEY" : "foreign key");

        if (x.getIndexName() !is null) {
            print(' ');
            x.getIndexName().accept(this);
        }

        print0(" (");
        printAndAccept!SQLName((x.getReferencingColumns()), ", ");
        print(')');

        print0(ucase ? " REFERENCES " : " references ");
        x.getReferencedTableName().accept(this);

        print0(" (");
        printAndAccept!SQLName((x.getReferencedColumns()), ", ");
        print(')');

        SQLForeignKeyImpl.Match match = x.getReferenceMatch();
        if (match.name.length != 0 ) {
            print0(ucase ? " MATCH " : " match ");
            print0(ucase ? match.name : match.name_lcase);
        }

        if (x.getOnDelete().name.length != 0 ) {
            print0(ucase ? " ON DELETE " : " on delete ");
            print0(ucase ? x.getOnDelete().name : x.getOnDelete().name_lcase);
        }

        if (x.getOnUpdate().name.length != 0 ) {
            print0(ucase ? " ON UPDATE " : " on update ");
            print0(ucase ? x.getOnUpdate().name : x.getOnUpdate().name_lcase);
        }
        return false;
    }

    override
    public void endVisit(MySqlUnique x) {

    }

    override
    public bool visit(MySqlAlterTableDiscardTablespace x) {
        print0(ucase ? "DISCARD TABLESPACE" : "discard tablespace");
        return false;
    }

    override
    public void endVisit(MySqlAlterTableDiscardTablespace x) {

    }

    override
    public bool visit(MySqlAlterTableImportTablespace x) {
        print0(ucase ? "IMPORT TABLESPACE" : "import tablespace");
        return false;
    }

    override
    public void endVisit(MySqlAlterTableImportTablespace x) {

    }

    override
    public bool visit(SQLAssignItem x) {


        string tagetString = (cast(Object)(x.getTarget())).toString();

        bool mysqlSpecial = false;

        if (DBType.MYSQL.opEquals(dbType)) {
            mysqlSpecial = "NAMES".equalsIgnoreCase(tagetString)
                    || "CHARACTER SET".equalsIgnoreCase(tagetString)
                    || "CHARSET".equalsIgnoreCase(tagetString);
        }

        if (!mysqlSpecial) {
            x.getTarget().accept(this);
            print0(" = ");
        } else {
            print0(ucase ? toUpper(tagetString) : toLower(tagetString));
            print(' ');
        }
        x.getValue().accept(this);
        return false;
    }

    override
    public bool visit(MySqlCreateTableStatement.TableSpaceOption x) {
        x.getName().accept(this);

        if (x.getStorage() !is null) {
            print(' ');
            x.getStorage().accept(this);
        }
        return false;
    }

    override
    public void endVisit(MySqlCreateTableStatement.TableSpaceOption x) {

    }

    override protected void visitAggreateRest(SQLAggregateExpr aggregateExpr) {
        {
            SQLOrderBy value = cast(SQLOrderBy) aggregateExpr.getAttribute("ORDER BY");
            if (value !is null) {
                print(' ');
                (cast(SQLObject) value).accept(this);
            }
        }
        {
            Object value = aggregateExpr.getAttribute("SEPARATOR");
            if (value !is null) {
                print0(ucase ? " SEPARATOR " : " separator ");
                (cast(SQLObject) value).accept(this);
            }
        }
    }

    override
    public bool visit(MySqlAnalyzeStatement x) {
        print0(ucase ? "ANALYZE " : "analyze ");
        if (x.isNoWriteToBinlog()) {
            print0(ucase ? "NO_WRITE_TO_BINLOG " : "no_write_to_binlog ");
        }

        if (x.isLocal()) {
            print0(ucase ? "LOCAL " : "local ");
        }

        print0(ucase ? "TABLE " : "table ");

        printAndAccept!SQLExprTableSource((x.getTableSources()), ", ");
        return false;
    }

    override
    public void endVisit(MySqlAnalyzeStatement x) {

    }

    override
    public bool visit(MySqlOptimizeStatement x) {
        print0(ucase ? "OPTIMIZE " : "optimize ");
        if (x.isNoWriteToBinlog()) {
            print0(ucase ? "NO_WRITE_TO_BINLOG " : "No_write_to_binlog ");
        }

        if (x.isLocal()) {
            print0(ucase ? "LOCAL " : "local ");
        }

        print0(ucase ? "TABLE " : "table ");

        printAndAccept!SQLExprTableSource((x.getTableSources()), ", ");
        return false;
    }

    override
    public void endVisit(MySqlOptimizeStatement x) {

    }

    override
    public bool visit(MySqlAlterUserStatement x) {
        print0(ucase ? "ALTER USER" : "alter user");
        foreach(SQLExpr user ; x.getUsers()) {
            print(' ');
            user.accept(this);
            print0(ucase ? " PASSWORD EXPIRE" : " password expire");
        }
        return false;
    }

    override
    public void endVisit(MySqlAlterUserStatement x) {

    }

    override
    public bool visit(SQLSetStatement x) {
        bool printSet = x.getAttribute("parser.set") == Boolean.TRUE || !DBType.ORACLE.opEquals(dbType);
        if (printSet) {
            print0(ucase ? "SET " : "set ");
        }
        SQLSetStatement.Option option = x.getOption();
        if (option.name.length != 0 ) {
            print(option.name);
            print(' ');
        }

        if (option == SQLSetStatement.Option.PASSWORD) {
            print0("FOR ");
        }

        printAndAccept!SQLAssignItem((x.getItems()), ", ");

        if (x.getHints() !is null && x.getHints().size() > 0) {
            print(' ');
            printAndAccept!SQLCommentHint((x.getHints()), " ");
        }

        return false;
    }

    override
    public bool visit(MySqlHintStatement x) {
        List!(SQLCommentHint) hints = x.getHints();

        foreach(SQLCommentHint hint ; hints) {
            hint.accept(this);
        }
        return false;
    }

    override
    public void endVisit(MySqlHintStatement x) {

    }

    override
    public bool visit(MySqlOrderingExpr x) {
        x.getExpr().accept(this);
        if (x.getType().name.length != 0 ) {
            print(' ');
            print0(ucase ? x.getType().name : x.getType().name_lcase);
        }

        return false;
    }

    override
    public void endVisit(MySqlOrderingExpr x) {

    }

    override
    public bool visit(SQLBlockStatement x) {
        SQLObject parent = x.getParent();
        string labelName = x.getLabelName();

        if (labelName !is null && !(labelName == (""))) {
            print0(labelName);
            print0(": ");
        }

        List!(SQLParameter) parameters = x.getParameters();
        if (parameters.size() != 0) {
            this.indentCount++;
            if (cast(SQLCreateProcedureStatement)(parent) !is null) {
                printIndent();
            }
            if (!(cast(SQLCreateProcedureStatement)(parent) !is null)) {
                print0(ucase ? "DECLARE" : "declare");
                println();
            }

            for (int i = 0, size = parameters.size(); i < size; ++i) {
                if (i != 0) {
                    println();
                }
                SQLParameter param = parameters.get(i);
                visit(param);
                print(';');
            }

            this.indentCount--;
            println();
        }

        print0(ucase ? "BEGIN" : "begin");
        if (!x.isEndOfCommit()) {
            this.indentCount++;
        } else {
            print(';');
        }
        println();
        List!(SQLStatement) statementList = x.getStatementList();
        for (int i = 0, size = statementList.size(); i < size; ++i) {
            if (i != 0) {
                println();
            }
            SQLStatement stmt = statementList.get(i);
            stmt.accept(this);
        }

        if (!x.isEndOfCommit()) {
            this.indentCount--;
            println();
            print0(ucase ? "END" : "end");
            if (labelName !is null && !(labelName == (""))) {
                print(' ');
                print0(labelName);
            }
        }

        return false;
    }

    override
    public bool visit(SQLIfStatement x) {
        print0(ucase ? "IF " : "if ");
        x.getCondition().accept(this);
        print0(ucase ? " THEN" : " then");
        this.indentCount++;
        println();
        List!(SQLStatement) statements = x.getStatements();
        for (int i = 0, size = statements.size(); i < size; ++i) {
            SQLStatement item = statements.get(i);
            item.accept(this);
            if (i != size - 1) {
                println();
            }
        }
        this.indentCount--;
        println();
        foreach(SQLIfStatement.ElseIf iterable_element ; x.getElseIfList()) {
            iterable_element.accept(this);
        }

        if (x.getElseItem() !is null) {
            x.getElseItem().accept(this);
        }

        print0(ucase ? "END IF" : "end if");
        return false;
    }

    override
    public bool visit(SQLIfStatement.ElseIf x) {
        print0(ucase ? "ELSE IF " : "else if ");
        x.getCondition().accept(this);
        print0(ucase ? " THEN" : " then");
        this.indentCount++;
        println();
        for (int i = 0, size = x.getStatements().size(); i < size; ++i) {
            SQLStatement item = x.getStatements().get(i);
            item.accept(this);
            if (i != size - 1) {
                println();
            }
        }
        this.indentCount--;
        println();
        return false;
    }

    override
    public bool visit(SQLIfStatement.Else x) {
        print0(ucase ? "ELSE " : "else ");
        this.indentCount++;
        println();
        for (int i = 0, size = x.getStatements().size(); i < size; ++i) {
            SQLStatement item = x.getStatements().get(i);
            item.accept(this);
            if (i != size - 1) {
                println();
            }
        }
        this.indentCount--;
        println();
        return false;
    }

    override
    public bool visit(MySqlCaseStatement x) {
        print0(ucase ? "CASE " : "case ");
        x.getCondition().accept(this);
        println();
        for (int i = 0; i < x.getWhenList().size(); i++) {
            x.getWhenList().get(i).accept(this);
        }
        if (x.getElseItem() !is null) x.getElseItem().accept(this);
        print0(ucase ? "END CASE" : "end case");
        return false;
    }

    override
    public void endVisit(MySqlCaseStatement x) {

    }

    override
    public bool visit(MySqlDeclareStatement x) {
        print0(ucase ? "DECLARE " : "declare ");
        printAndAccept!SQLDeclareItem((x.getVarList()), ", ");
        return false;
    }

    override
    public void endVisit(MySqlDeclareStatement x) {

    }

    override
    public bool visit(MySqlSelectIntoStatement x) {
        x.getSelect().accept(this);
        print0(ucase ? " INTO " : " into ");
        for (int i = 0; i < x.getVarList().size(); i++) {
            x.getVarList().get(i).accept(this);
            if (i != x.getVarList().size() - 1) print0(", ");
        }
        return false;
    }

    override
    public void endVisit(MySqlSelectIntoStatement x) {

    }

    override
    public bool visit(MySqlCaseStatement.MySqlWhenStatement x) {
        print0(ucase ? "WHEN " : "when ");
        x.getCondition().accept(this);
        print0(" THEN");
        println();
        for (int i = 0; i < x.getStatements().size(); i++) {
            x.getStatements().get(i).accept(this);
            if (i != x.getStatements().size() - 1) {
                println();
            }
        }
        println();
        return false;
    }

    override
    public void endVisit(MySqlCaseStatement.MySqlWhenStatement x) {

    }

    override
    public bool visit(SQLLoopStatement x) {
        if (x.getLabelName() !is null && !(x.getLabelName() == (""))) {
            print0(x.getLabelName());
            print0(": ");
        }

        print0(ucase ? "LOOP " : "loop ");
        this.indentCount++;
        println();
        for (int i = 0, size = x.getStatements().size(); i < size; ++i) {
            SQLStatement item = x.getStatements().get(i);
            item.accept(this);
            if (i != size - 1) {
                println();
            }
        }
        this.indentCount--;
        println();
        print0(ucase ? "END LOOP" : "end loop");
        if (x.getLabelName() !is null && !(x.getLabelName() == (""))) {
            print0(" ");
            print0(x.getLabelName());
        }
        return false;
    }

    override
    public bool visit(MySqlLeaveStatement x) {
        print0(ucase ? "LEAVE " : "leave ");
        print0(x.getLabelName());
        return false;
    }

    override
    public void endVisit(MySqlLeaveStatement x) {
        // TODO Auto-generated method stub

    }

    override
    public bool visit(MySqlIterateStatement x) {
        print0(ucase ? "ITERATE " : "iterate ");
        print0(x.getLabelName());
        return false;
    }

    override
    public void endVisit(MySqlIterateStatement x) {
        // TODO Auto-generated method stub

    }

    override
    public bool visit(MySqlRepeatStatement x) {
        // TODO Auto-generated method stub
        if (x.getLabelName() !is null && !(x.getLabelName() == (""))) {
            print0(x.getLabelName());
            print0(": ");
        }

        print0(ucase ? "REPEAT " : "repeat ");
        this.indentCount++;
        println();
        for (int i = 0, size = x.getStatements().size(); i < size; ++i) {
            SQLStatement item = x.getStatements().get(i);
            item.accept(this);
            if (i != size - 1) {
                println();
            }
        }
        this.indentCount--;
        println();
        print0(ucase ? "UNTIL " : "until ");
        x.getCondition().accept(this);
        println();
        print0(ucase ? "END REPEAT" : "end repeat");
        if (x.getLabelName() !is null && !(x.getLabelName() == (""))) {
            print(' ');
            print0(x.getLabelName());
        }
        return false;
    }

    override
    public void endVisit(MySqlRepeatStatement x) {
        // TODO Auto-generated method stub

    }

    override
    public bool visit(MySqlCursorDeclareStatement x) {
        print0(ucase ? "DECLARE " : "declare ");
        printExpr(x.getCursorName());
        print0(ucase ? " CURSOR FOR" : " cursor for");
        this.indentCount++;
        println();
        x.getSelect().accept(this);
        this.indentCount--;
        return false;
    }

    override
    public void endVisit(MySqlCursorDeclareStatement x) {
        // TODO Auto-generated method stub

    }

    override
    public bool visit(MySqlUpdateTableSource x) {
        MySqlUpdateStatement update = x.getUpdate();
        if (update !is null) {
            update.accept0(this);
        }
        return false;
    }

    override
    public void endVisit(MySqlUpdateTableSource x) {

    }

    override
    public bool visit(MySqlAlterTableAlterColumn x) {
        print0(ucase ? "ALTER COLUMN " : "alter column ");
        x.getColumn().accept(this);
        if (x.getDefaultExpr() !is null) {
            print0(ucase ? " SET DEFAULT " : " set default ");
            x.getDefaultExpr().accept(this);
        } else if (x.isDropDefault()) {
            print0(ucase ? " DROP DEFAULT" : " drop default");
        }
        return false;
    }

    override
    public void endVisit(MySqlAlterTableAlterColumn x) {

    }

    override
    public bool visit(MySqlSubPartitionByKey x) {
        if (x.isLinear()) {
            print0(ucase ? "SUBPARTITION BY LINEAR KEY (" : "subpartition by linear key (");
        } else {
            print0(ucase ? "SUBPARTITION BY KEY (" : "subpartition by key (");
        }
        printAndAccept!SQLName((x.getColumns()), ", ");
        print(')');

        if (x.getSubPartitionsCount() !is null) {
            print0(ucase ? " SUBPARTITIONS " : " subpartitions ");
            x.getSubPartitionsCount().accept(this);
        }
        return false;
    }

    override
    public void endVisit(MySqlSubPartitionByKey x) {

    }

    override
    public bool visit(MySqlSubPartitionByList x) {
        print0(ucase ? "SUBPARTITION BY LIST " : "subpartition by list ");
        if (x.getExpr() !is null) {
            print('(');
            x.getExpr().accept(this);
            print0(") ");
        } else {
            if (x.getColumns().size() == 1 && Boolean.TRUE.opEquals(x.getAttribute("ads.subPartitionList"))) {
                print('(');
            } else {
                print0(ucase ? "COLUMNS (" : "columns (");
            }
            printAndAccept!SQLColumnDefinition((x.getColumns()), ", ");
            print(")");
        }

        if (x.getOptions().size() != 0) {
            println();
            print0(ucase ? "SUBPARTITION OPTIONS (" : "subpartition options (");
            printAndAccept!SQLAssignItem((x.getOptions()), ", ");
            print(')');
        }

        return false;
    }

    override
    public void endVisit(MySqlSubPartitionByList x) {

    }


    override
    public bool visit(MySqlDeclareHandlerStatement x) {
        string handleType = x.getHandleType().name;

        print0(ucase ? "DECLARE " : "declare ");
        print0(ucase ? handleType : toLower(handleType));
        print0(ucase ? " HANDLER FOR " : " handler for ");
        for (int i = 0; i < x.getConditionValues().size(); i++) {
            ConditionValue cv = x.getConditionValues().get(i);
            if (cv.getType() == ConditionValue.ConditionType.SQLSTATE) {
                print0(ucase ? " SQLSTATE " : " sqlstate ");
                print0(cv.getValue());
            } else if (cv.getType() == ConditionValue.ConditionType.MYSQL_ERROR_CODE) {
                print0(cv.getValue());
            } else if (cv.getType() == ConditionValue.ConditionType.SELF) {
                print0(cv.getValue());
            } else if (cv.getType() == ConditionValue.ConditionType.SYSTEM) {
                print0(ucase ? toUpper(cv.getValue()) : toLower(cv.getValue()));
            }

            if (i != x.getConditionValues().size() - 1) {
                print0(", ");
            }

        }
        this.indentCount++;
        println();
        x.getSpStatement().accept(this);
        this.indentCount--;
        return false;
    }

    override
    public void endVisit(MySqlDeclareHandlerStatement x) {

    }

    override
    public bool visit(MySqlDeclareConditionStatement x) {
        print0(ucase ? "DECLARE " : "declare ");
        print0(x.getConditionName());
        print0(ucase ? " CONDITION FOR " : " condition for ");

        if (x.getConditionValue().getType() == ConditionValue.ConditionType.SQLSTATE) {
            print0(ucase ? "SQLSTATE " : "sqlstate ");
            print0(x.getConditionValue().getValue());
        } else {
            print0(x.getConditionValue().getValue());
        }

        println();
        return false;
    }

    override
    public void endVisit(MySqlDeclareConditionStatement x) {

    }

    override
    public bool visit(SQLAlterTableDropColumnItem x) {

        for (int i = 0; i < x.getColumns().size(); ++i) {
            if (i != 0) {
                print0(", ");
            }

            SQLName columnn = x.getColumns().get(i);

            print0(ucase ? "DROP COLUMN " : "drop column ");
            columnn.accept(this);

            if (x.isCascade()) {
                print0(ucase ? " CASCADE" : " cascade");
            }
        }
        return false;
    }

    /**
     * visit procedure create node
     */
    override
    public bool visit(SQLCreateProcedureStatement x) {
        if (x.isOrReplace()) {
            print0(ucase ? "CREATE OR REPLACE PROCEDURE " : "create or replace procedure ");
        } else {
            print0(ucase ? "CREATE PROCEDURE " : "create procedure ");
        }
        x.getName().accept(this);

        int paramSize = x.getParameters().size();

        print0(" (");
        if (paramSize > 0) {
            this.indentCount++;
            println();

            for (int i = 0; i < paramSize; ++i) {
                if (i != 0) {
                    print0(", ");
                    println();
                }
                SQLParameter param = x.getParameters().get(i);
                param.accept(this);
            }

            this.indentCount--;
            println();
        }
        print(')');

        if (x.isDeterministic()) {
            println();
            print(ucase ? "DETERMINISTIC" : "deterministic");
        }

        if (x.isContainsSql()) {
            println();
            print0(ucase ? "CONTAINS SQL" : "contains sql");
        }

        if (x.isNoSql()) {
            println();
            print(ucase ? "NO SQL" : "no sql");
        }

        if (x.isModifiesSqlData()) {
            println();
            print(ucase ? "MODIFIES SQL DATA" : "modifies sql data");
        }

        SQLName authid = x.getAuthid();
        if (authid !is null) {
            println();
            print(ucase ? "SQL SECURITY " : "sql security ");
            authid.accept(this);
        }

        println();
        x.getBlock().accept(this);
        return false;
    }

    override
    public bool visit(SQLCreateFunctionStatement x) {
        print0(ucase ? "CREATE FUNCTION " : "create function ");
        x.getName().accept(this);

        int paramSize = x.getParameters().size();

        if (paramSize > 0) {
            print0(" (");
            this.indentCount++;
            println();

            for (int i = 0; i < paramSize; ++i) {
                if (i != 0) {
                    print0(", ");
                    println();
                }
                SQLParameter param = x.getParameters().get(i);
                param.accept(this);
            }

            this.indentCount--;
            println();
            print(')');
        }

        println();
        print(ucase ? "RETURNS " : "returns ");
        x.getReturnDataType().accept(this);

        if (x.isDeterministic()) {
            print(ucase ? " DETERMINISTIC" : " deterministic");
        }

        SQLStatement block = x.getBlock();

        println();

        block.accept(this);
        return false;
    }

    override
    public bool visit(SQLCommentStatement x) {
        SQLCommentStatement.Type type = x.getType();

        SQLExprTableSource on = x.getOn();
        if (type == SQLCommentStatement.Type.TABLE) {
            print0(ucase ? "ALTER TABLE " : "alter table ");
            on.accept(this);
            print0(ucase ? " COMMENT = " : " comment = ");
            x.getComment().accept(this);
        } else {
            SQLPropertyExpr propertyExpr = cast(SQLPropertyExpr) on.getExpr();

            SQLExpr table = propertyExpr.getOwner();
            string column = propertyExpr.getName();

            print0(ucase ? "ALTER TABLE " : "alter table ");
            printTableSourceExpr(table);
            print0(ucase ? " MODIFY COLUMN " : " modify column ");
            print(column);
            print0(ucase ? " COMMENT " : " comment ");
            x.getComment().accept(this);
        }

        return false;
    }

    override
    public bool visit(MySqlFlushStatement x) {
        print0(ucase ? "FLUSH" : "flush");

        if (x.isNoWriteToBinlog()) {
            print0(ucase ? " NO_WRITE_TO_BINLOG" : " no_write_to_binlog");
        } else if (x.isLocal()) {
            print0(ucase ? " LOCAL" : " local");
        }

        if(x.isBinaryLogs()) {
            print0(ucase ? " BINARY LOGS" : " binary logs");
        }
        if (x.isDesKeyFile()) {
            print0(ucase ? " DES_KEY_FILE" : " des_key_file");
        }
        if (x.isEngineLogs()) {
            print0(ucase ? " ENGINE LOGS" : " engine logs");
        }
        if (x.isErrorLogs()) {
            print0(ucase ? " ERROR LOGS" : " error logs");
        }
        if (x.isGeneralLogs()) {
            print0(ucase ? " GENERAL LOGS" : " general logs");
        }
        if (x.isHots()) {
            print0(ucase ? " HOSTS" : " hosts");
        }
        if (x.isLogs()) {
            print0(ucase ? " LOGS" : " logs");
        }
        if (x.isPrivileges()) {
            print0(ucase ? " PRIVILEGES" : " privileges");
        }
        if (x.isOptimizerCosts()) {
            print0(ucase ? " OPTIMIZER_COSTS" : " optimizer_costs");
        }
        if (x.isQueryCache()) {
            print0(ucase ? " QUERY CACHE" : " query cache");
        }
        if (x.isRelayLogs()) {
            print0(ucase ? " RELAY LOGS" : " relay logs");
            SQLExpr channel = x.getRelayLogsForChannel();
            if (channel !is null) {
                print(' ');
                channel.accept(this);
            }
        }
        if (x.isSlowLogs()) {
            print0(ucase ? " SLOW LOGS" : " slow logs");
        }
        if (x.isStatus()) {
            print0(ucase ? " STATUS" : " status");
        }
        if (x.isUserResources()) {
            print0(ucase ? " USER_RESOURCES" : " user_resources");
        }

        if(x.isTableOption()){
            print0(ucase ? " TABLES" : " tables");

            List!(SQLExprTableSource) tables = x.getTables();
            if (tables !is null && tables.size() > 0) {
                print(' ');
                printAndAccept!SQLExprTableSource((tables), ", ");
            }

            if (x.isWithReadLock()) {
                print0(ucase ? " WITH READ LOCK" : " with read lock");
            }

            if (x.isForExport()) {
                print0(ucase ? " FOR EXPORT" : " for export");
            }
        }
        return false;
    }

    override
    public void endVisit(MySqlFlushStatement x) {

    }

    override
    public bool visit(MySqlEventSchedule x) {
        int cnt = 0;
        if (x.getAt() !is null) {
            print0(ucase ? "AT " : "at ");
            printExpr(x.getAt());

            cnt++;
        }

        if (x.getEvery() !is null) {
            print0(ucase ? "EVERY " : "every ");
            SQLIntervalExpr interval = cast(SQLIntervalExpr) x.getEvery();
            printExpr(interval.getValue());
            print(' ');
            print(interval.getUnit().name());

            cnt++;
        }

        if (x.getStarts() !is null) {
            if (cnt > 0) {
                print(' ');
            }

            print0(ucase ? "STARTS " : "starts ");
            printExpr(x.getStarts());

            cnt++;
        }

        if (x.getEnds() !is null) {
            if (cnt > 0) {
                print(' ');
            }
            print0(ucase ? "ENDS " : "ends ");
            printExpr(x.getEnds());

            cnt++;
        }

        return false;
    }

    override
    public void endVisit(MySqlEventSchedule x) {

    }

    override
    public bool visit(MySqlCreateEventStatement x) {
        print0(ucase ? "CREATE " : "create ");

        SQLName definer = x.getDefiner();
        if (definer !is null) {
            print0(ucase ? "DEFINER = " : "definer = ");
        }

        print0(ucase ? "EVENT " : "evnet ");

        if (x.isIfNotExists()) {
            print0(ucase ? "IF NOT EXISTS " : "if not exists ");
        }

        printExpr(x.getName());

        MySqlEventSchedule schedule = x.getSchedule();
        print0(ucase ? " ON SCHEDULE " : " on schedule ");
        schedule.accept(this);

        auto enable = x.getEnable();
        if (enable !is null) {
            if (enable.booleanValue()) {
                print0(ucase ? " ENABLE" : " enable");
            } else {
                print0(ucase ? " DISABLE" : " disable");
                if (x.isDisableOnSlave()) {
                    print0(ucase ? " ON SLAVE" : " on slave");
                }
            }
        }

        SQLExpr comment = x.getComment();
        if (comment !is null) {
            print0(ucase ? "COMMENT " : "comment ");
            comment.accept(this);
        }

        println();
        SQLStatement body = x.getEventBody();
        if (!(cast(SQLExprStatement)(body) !is null)) {
            print0(ucase ? "DO" : "do");
            println();
        }
        body.accept(this);

        return false;
    }

    override
    public void endVisit(MySqlCreateEventStatement x) {

    }

    override
    public bool visit(MySqlCreateAddLogFileGroupStatement x) {
        print0(ucase ? "CREATE LOGFILE GROUP " : "create logfile group ");
        x.getName().accept(this);
        print(' ');
        print0(ucase ? "ADD UNDOFILE " : "add undofile ");
        printExpr(x.getAddUndoFile());

        SQLExpr initialSize = x.getInitialSize();
        if (initialSize !is null) {
            print0(ucase ? " INITIAL_SIZE " : " initial_size ");
            printExpr(initialSize);
        }

        SQLExpr undoBufferSize = x.getUndoBufferSize();
        if (undoBufferSize !is null) {
            print0(ucase ? " UNDO_BUFFER_SIZE " : " undo_buffer_size ");
            printExpr(undoBufferSize);
        }

        SQLExpr redoBufferSize = x.getRedoBufferSize();
        if (redoBufferSize !is null) {
            print0(ucase ? " REDO_BUFFER_SIZE " : " redo_buffer_size ");
            printExpr(redoBufferSize);
        }

        SQLExpr nodeGroup = x.getNodeGroup();
        if (nodeGroup !is null) {
            print0(ucase ? " NODEGROUP " : " nodegroup ");
            printExpr(nodeGroup);
        }

        if (x.isWait()) {
            print0(ucase ? " WAIT" : " wait");
        }

        SQLExpr comment = x.getComment();
        if (comment !is null) {
            print0(ucase ? " COMMENT " : " comment ");
            printExpr(comment);
        }

        SQLExpr engine = x.getEngine();
        if (engine !is null) {
            print0(ucase ? " ENGINE " : " engine ");
            printExpr(engine);
        }

        return false;
    }

    override
    public void endVisit(MySqlCreateAddLogFileGroupStatement x) {

    }

    override
    public bool visit(MySqlCreateServerStatement x) {
        print0(ucase ? "CREATE SERVER " : "create server ");
        x.getName().accept(this);
        print0(ucase ? " FOREIGN DATA WRAPPER " : " foreign data wrapper ");
        printExpr(x.getForeignDataWrapper());

        print(" OPTIONS(");
        int cnt = 0;
        SQLExpr host = x.getHost();
        if (host !is null) {
            print0(ucase ? "HOST " : "host ");
            printExpr(host);
            cnt++;
        }

        SQLExpr database = x.getDatabase();
        if (database !is null) {
            if (cnt++ > 0) {
                print(", ");
            }
            print0(ucase ? "DATABASE " : "database ");
            printExpr(database);
        }

        SQLExpr user = x.getUser();
        if (user !is null) {
            if (cnt++ > 0) {
                print(", ");
            }
            print0(ucase ? "USER " : "user ");
            printExpr(user);
        }

        SQLExpr password = x.getPassword();
        if (password !is null) {
            if (cnt++ > 0) {
                print(", ");
            }
            print0(ucase ? "PASSWORD " : "password ");
            printExpr(password);
        }

        SQLExpr socket = x.getSocket();
        if (socket !is null) {
            if (cnt++ > 0) {
                print(", ");
            }
            print0(ucase ? "SOCKET " : "socket ");
            printExpr(socket);
        }

        SQLExpr owner = x.getOwner();
        if (owner !is null) {
            if (cnt++ > 0) {
                print(", ");
            }
            print0(ucase ? "OWNER " : "owner ");
            printExpr(owner);
        }

        SQLExpr port = x.getPort();
        if (port !is null) {
            if (cnt++ > 0) {
                print(", ");
            }
            print0(ucase ? "PORT " : "port ");
            printExpr(port);
        }
        print(')');

        return false;
    }

    override
    public void endVisit(MySqlCreateServerStatement x) {

    }

    override
    public bool visit(MySqlCreateTableSpaceStatement x) {
        print0(ucase ? "CREATE TABLESPACE " : "create tablespace ");
        x.getName().accept(this);

        SQLExpr addDataFile = x.getAddDataFile();
        if (addDataFile !is null) {
            print0(ucase ? " ADD DATAFILE " : " add datafile ");
            addDataFile.accept(this);
        }

        SQLExpr fileBlockSize = x.getFileBlockSize();
        if (fileBlockSize !is null) {
            print0(ucase ? " FILE_BLOCK_SIZE = " : " file_block_size = ");
            fileBlockSize.accept(this);
        }

        SQLExpr logFileGroup = x.getLogFileGroup();
        if (logFileGroup !is null) {
            print0(ucase ? " USE LOGFILE GROUP " : " use logfile group ");
            logFileGroup.accept(this);
        }

        SQLExpr extentSize = x.getExtentSize();
        if (extentSize !is null) {
            print0(ucase ? " EXTENT_SIZE = " : " extent_size = ");
            extentSize.accept(this);
        }

        SQLExpr initialSize = x.getInitialSize();
        if (initialSize !is null) {
            print0(ucase ? " INITIAL_SIZE = " : " initial_size = ");
            initialSize.accept(this);
        }

        SQLExpr autoExtentSize = x.getAutoExtentSize();
        if (autoExtentSize !is null) {
            print0(ucase ? " AUTOEXTEND_SIZE = " : " autoextend_size = ");
            autoExtentSize.accept(this);
        }

        SQLExpr maxSize = x.getMaxSize();
        if (autoExtentSize !is null) {
            print0(ucase ? " MAX_SIZE = " : " max_size = ");
            maxSize.accept(this);
        }

        SQLExpr nodeGroup = x.getNodeGroup();
        if (nodeGroup !is null) {
            print0(ucase ? " NODEGROUP = " : " nodegroup = ");
            nodeGroup.accept(this);
        }

        if (x.isWait()) {
            print0(ucase ? " WAIT" : " wait");
        }

        SQLExpr comment = x.getComment();
        if (comment !is null) {
            print0(ucase ? " COMMENT " : " comment ");
            printExpr(comment);
        }

        SQLExpr engine = x.getEngine();
        if (engine !is null) {
            print0(ucase ? " ENGINE " : " engine ");
            printExpr(engine);
        }

        return false;
    }

    override
    public void endVisit(MySqlCreateTableSpaceStatement x) {

    }

    override
    public bool visit(MySqlAlterEventStatement x) {
        print0(ucase ? "ALTER " : "alter ");

        SQLName definer = x.getDefiner();
        if (definer !is null) {
            print0(ucase ? "DEFINER = " : "definer = ");
        }

        print0(ucase ? "EVENT " : "evnet ");
        printExpr(x.getName());

        MySqlEventSchedule schedule = x.getSchedule();
        if (schedule !is null) {
            print0(ucase ? " ON SCHEDULE " : " on schedule ");
            schedule.accept(this);
        }

        auto enable = x.getEnable();
        if (enable !is null) {
            if (enable.booleanValue()) {
                print0(ucase ? " ENABLE" : " enable");
            } else {
                print0(ucase ? " DISABLE" : " disable");
                if (x.isDisableOnSlave()) {
                    print0(ucase ? " ON SLAVE" : " on slave");
                }
            }
        }

        SQLExpr comment = x.getComment();
        if (comment !is null) {
            print0(ucase ? "COMMENT " : "comment ");
            comment.accept(this);
        }

        SQLStatement body = x.getEventBody();
        if (body !is null) {
            println();
            if (!(cast(SQLExprStatement)(body) !is null)) {
                print0(ucase ? "DO" : "do");
                println();
            }
            body.accept(this);
        }

        return false;
    }

    override
    public void endVisit(MySqlAlterEventStatement x) {

    }

    override
    public bool visit(MySqlAlterLogFileGroupStatement x) {
        print0(ucase ? "ALTER LOGFILE GROUP " : "alter logfile group ");
        x.getName().accept(this);
        print(' ');
        print0(ucase ? "ADD UNDOFILE " : "add undofile ");
        printExpr(x.getAddUndoFile());

        SQLExpr initialSize = x.getInitialSize();
        if (initialSize !is null) {
            print0(ucase ? " INITIAL_SIZE " : " initial_size ");
            printExpr(initialSize);
        }

        if (x.isWait()) {
            print0(ucase ? " WAIT" : " wait");
        }

        SQLExpr engine = x.getEngine();
        if (engine !is null) {
            print0(ucase ? " ENGINE " : " engine ");
            printExpr(engine);
        }

        return false;
    }

    override
    public void endVisit(MySqlAlterLogFileGroupStatement x) {

    }

    override
    public bool visit(MySqlAlterServerStatement x) {
        print0(ucase ? "ATLER SERVER " : "alter server ");
        x.getName().accept(this);

        print(" OPTIONS(");
        SQLExpr user = x.getUser();
        if (user !is null) {
            print0(ucase ? "USER " : "user ");
            printExpr(user);
        }

        print(')');

        return false;
    }

    override
    public void endVisit(MySqlAlterServerStatement x) {

    }

    override
    public bool visit(MySqlAlterTablespaceStatement x) {
        print0(ucase ? "CREATE TABLESPACE " : "create tablespace ");
        x.getName().accept(this);

        SQLExpr addDataFile = x.getAddDataFile();
        if (addDataFile !is null) {
            print0(ucase ? " ADD DATAFILE " : " add datafile ");
            addDataFile.accept(this);
        }

        SQLExpr initialSize = x.getInitialSize();
        if (initialSize !is null) {
            print0(ucase ? " INITIAL_SIZE = " : " initial_size = ");
            initialSize.accept(this);
        }

        if (x.isWait()) {
            print0(ucase ? " WAIT" : " wait");
        }

        SQLExpr engine = x.getEngine();
        if (engine !is null) {
            print0(ucase ? " ENGINE " : " engine ");
            printExpr(engine);
        }

        return false;
    }

    override
    public void endVisit(MySqlAlterTablespaceStatement x) {

    }

    override
    public bool visit(MySqlShowDatabasePartitionStatusStatement x) {
        print0(ucase ? "SHOW DATABASE PARTITION STATUS FOR " : "show database partition status for ");
        x.getDatabase().accept(this);
        return false;
    }

    override
    public void endVisit(MySqlShowDatabasePartitionStatusStatement x) {

    }

    override protected void printQuery(SQLSelectQuery x) {
        auto clazz = typeid(x);
        if (clazz == typeid(MySqlSelectQueryBlock)) {
            visit(cast(MySqlSelectQueryBlock) x);
        } else if (clazz == typeid(SQLSelectQueryBlock)) {
            visit(cast(SQLSelectQueryBlock) x);
        } else if (clazz == typeid(SQLUnionQuery)) {
            visit(cast(SQLUnionQuery) x);
        } else {
            x.accept(this);
        }
    }

    override public void printInsertColumns(List!(SQLExpr) columns) {
         int size = columns.size();
        if (size > 0) {
            if (size > 5) {
                this.indentCount++;
                print(' ');
            }
            print('(');
            for (int i = 0; i < size; ++i) {
                if (i != 0) {
                    if (i % 5 == 0) {
                        println();
                    }
                    print0(", ");
                }

                SQLExpr column = columns.get(i);
                if (cast(SQLIdentifierExpr)(column) !is null) {
                    visit(cast(SQLIdentifierExpr) column);
                } else {
                    printExpr(column);
                }

                String dataType = cast(String) column.getAttribute("dataType");
                if (dataType !is null) {
                    print(' ');
                    print(dataType);
                }
            }
            print(')');
            if (size > 5) {
                this.indentCount--;
            }
        }
    }

    override
    public void endVisit(MySqlChecksumTableStatement x) {

    }

    override
    public bool visit(MySqlChecksumTableStatement x) {
        print0(ucase ? "CHECKSUM TABLE " : "checksum table ");
        printAndAccept!SQLExprTableSource((x.getTables()), "，");
        return false;
    }

    
    override protected void print0(Bytes data) {
        // FIXME: Needing refactor or cleanup -@zhangxueping at 4/2/2019, 5:11:53 PM
        // need to be checked
        string s = format("unhex('%(%02X%)')", data.value());
        print0(s);
    }

    alias print0 = SQLASTOutputVisitor.print0;
} //
