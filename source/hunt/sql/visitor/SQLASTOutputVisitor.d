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
module hunt.sql.visitor.SQLASTOutputVisitor;


import std.uni;
import hunt.sql.SQLUtils;
import hunt.sql.ast;
import hunt.sql.ast.expr;
import hunt.sql.ast.statement;
import hunt.sql.ast.statement.SQLCreateTriggerStatement;
// import hunt.sql.ast.statement.SQLCreateTriggerStatement.TriggerEvent;
// import hunt.sql.ast.statement.SQLCreateTriggerStatement.TriggerType;
// import hunt.sql.ast.statement.ValuesClause;
// import hunt.sql.ast.statement.SQLJoinTableSource.JoinType;
import hunt.sql.ast.statement.SQLInsertStatement;
import hunt.sql.ast.statement.SQLJoinTableSource;
// import hunt.sql.ast.statement.SQLMergeStatement.MergeInsertClause;
// import hunt.sql.ast.statement.SQLMergeStatement.MergeUpdateClause;
import hunt.sql.ast.statement.SQLMergeStatement;
import hunt.sql.ast.statement.SQLWhileStatement;
// import hunt.sql.dialect.oracle.ast.OracleSegmentAttributes;
import hunt.sql.ast.statement.SQLDeclareStatement;
// import hunt.sql.dialect.oracle.ast.expr.OracleCursorExpr;
// import hunt.sql.dialect.oracle.ast.expr.OracleDatetimeExpr;
// import hunt.sql.dialect.oracle.ast.stmt.OracleCreatePackageStatement;
// import hunt.sql.dialect.oracle.ast.stmt.OracleForStatement;
// import hunt.sql.dialect.oracle.ast.stmt.OracleSelectPivot;
// import hunt.sql.dialect.oracle.parser.OracleFunctionDataType;
// import hunt.sql.dialect.oracle.parser.OracleProcedureDataType;
import hunt.sql.util.DBType;
import hunt.sql.visitor.SQLASTVisitorAdapter;
import hunt.sql.visitor.ParameterizedVisitor;
import hunt.sql.visitor.PrintableVisitor;
import hunt.sql.visitor.VisitorFeature;
import hunt.sql.ast.expr.SQLCaseStatement;
import hunt.sql.visitor.ExportParameterVisitorUtils;

import hunt.collection;
import hunt.Byte;
import hunt.Exceptions;
import hunt.logging.ConsoleLogger;
import hunt.String;
import hunt.Boolean;
import hunt.Number;
import hunt.Integer;
import hunt.Float;
import hunt.math;
import hunt.util.Common;
import hunt.util.Appendable;
import hunt.text;
import hunt.collection.Collections;

import std.array;
import std.concurrency : initOnce;
import std.conv;
import std.datetime;
import std.string;



class SQLASTOutputVisitor : SQLASTVisitorAdapter , ParameterizedVisitor, PrintableVisitor {

    alias visit = SQLASTVisitorAdapter.visit;
    alias endVisit = SQLASTVisitorAdapter.endVisit;

    static string[] variantValuesCache() {
        __gshared string[] inst;
        return initOnce!inst(initializeCache());
    }

    private static string[] initializeCache() {
        string[] v = new string[64];
        for (int len = 0; len < v.length; ++len) {
            StringBuilder buf = new StringBuilder();
            buf.append('(');
            for (int i = 0; i < len; ++i) {
                if (i != 0) {
                    if (i % 5 == 0) {
                        buf.append("\n\t\t");
                    }
                    buf.append(", ");
                }
                buf.append('?');
            }
            buf.append(')');
            v[len] = buf.toString();
        }

        return v;
    }

    protected  Appendable appender;
    protected int indentCount = 0;
    protected bool ucase = true;
    protected int selectListNumberOfLine = 5;

    protected bool groupItemSingleLine = false;

    protected List!Object parameters;
    protected List!Object inputParameters;
    protected Set!string  tables;
    protected string       table; // for improved

    protected bool exportTables = false;

    protected string dbType;

    protected Map!(string,string)tableMapping;

    protected int replaceCount;

    protected bool parameterizedMergeInList = false;
    protected bool parameterizedQuesUnMergeInList = false;

    protected bool parameterized = false;
    protected bool shardingSupport = false;

    protected  int lines = 0;

    protected Boolean printStatementAfterSemi ;
    private bool _haveQuotes = false;
    private char _quotes = '"';


    this() {
        printStatementAfterSemi = Boolean.FALSE;
        // features |= VisitorFeature.OutputPrettyFormat.mask;
        config(VisitorFeature.OutputPrettyFormat, true);
        initialization();
    }

    this(Appendable appender){
        this.appender = appender;
        initialization();
    }

    this(Appendable appender, string dbType){
        this.appender = appender;
        this.dbType = dbType;
        initialization();
    }

    this(Appendable appender, bool parameterized){
        this.appender = appender;
        this.config(VisitorFeature.OutputParameterized, parameterized);
        this.config(VisitorFeature.OutputParameterizedQuesUnMergeInList, parameterizedQuesUnMergeInList);
        initialization();
    }

    private void initialization() {
        if(dbType == DBType.MYSQL.name) {
            _quotes = '`';
        } else if(dbType == DBType.POSTGRESQL.name) {
            // https://stackoverflow.com/questions/20878932/are-postgresql-column-names-case-sensitive
            // https://blog.xojo.com/2016/09/28/about-postgresql-case-sensitivity/
            // https://lerner.co.il/2013/11/30/quoting-postgresql/
            _quotes = '"';
        }

        // config(VisitorFeature.OutputQuotedIdentifier, false);
    }

    // bool haveQuotes() {
    //     return _haveQuotes;
    // }

    int getReplaceCount() {
        return this.replaceCount;
    }

    void incrementReplaceCunt() {
        replaceCount++;
    }

    void addTableMapping(string srcTable, string destTable) {
        if (tableMapping is null) {
            tableMapping = new HashMap!(string, string)();
        }

        if (indexOf(srcTable,'.') >= 0) {
            SQLExpr expr = SQLUtils.toSQLExpr(srcTable, dbType);
            if (cast(SQLPropertyExpr)expr !is null){
                srcTable = (cast(SQLPropertyExpr) expr).simplify().toString();
            }
        } else {
            srcTable = SQLUtils.normalize(srcTable);
        }
        tableMapping.put(srcTable, destTable);
    }

    void setTableMapping(Map!(string,string)tableMapping) {
        this.tableMapping = tableMapping;
    }

    List!Object getParameters() {
        if (parameters is null) {
            parameters = new ArrayList!Object();
        }

        return parameters;
    }

    bool isDesensitize() {
        return isEnabled(VisitorFeature.OutputDesensitize);
    }

    void setDesensitize(bool desensitize) {
        config(VisitorFeature.OutputDesensitize, desensitize);
    }

    Set!string getTables() {
        if (this.table !is null && this.tables is null) {
            return Collections.singleton!string(this.table);
        }
        return this.tables;
    }

    //@Deprecated
    void setParameters(List!Object parameters) {
        if (parameters !is null && parameters.size() > 0) {
            this.inputParameters = parameters;
        } else {
            this.parameters = parameters;
        }
    }

    void setInputParameters(List!Object parameters) {
        this.inputParameters = parameters;
    }

    /**
     *
     * @since 1.1.5
     */
    void setOutputParameters(List!Object parameters) {
        this.parameters = parameters;
    }

    int getIndentCount() {
        return indentCount;
    }

    Appendable getAppender() {
        return appender;
    }

    bool isPrettyFormat() {
        return isEnabled(VisitorFeature.OutputPrettyFormat);
    }

    void setPrettyFormat(bool prettyFormat) {
        config(VisitorFeature.OutputPrettyFormat, prettyFormat);
    }

    void decrementIndent() {
        this.indentCount--;
    }

    void incrementIndent() {
        this.indentCount++;
    }

    bool isParameterized() {
        return isEnabled(VisitorFeature.OutputParameterized);
    }

    void setParameterized(bool parameterized) {
        config(VisitorFeature.OutputParameterized, parameterized);
    }

    bool isParameterizedMergeInList() {
        return parameterizedMergeInList;
    }

    void setParameterizedMergeInList(bool parameterizedMergeInList) {
        this.parameterizedMergeInList = parameterizedMergeInList;
    }

    bool isParameterizedQuesUnMergeInList() {
        return isEnabled(VisitorFeature.OutputParameterizedQuesUnMergeInList);
    }

    void setParameterizedQuesUnMergeInList(bool parameterizedQuesUnMergeInList) {
        config(VisitorFeature.OutputParameterizedQuesUnMergeInList, parameterizedQuesUnMergeInList);
    }

    bool isExportTables() {
        return exportTables;
    }

    void setExportTables(bool exportTables) {
        this.exportTables = exportTables;
    }

    void print(char value) {
        if (this.appender is null) {
            warning("The appender is null");
            return;
        }

        try {
            version(HUNT_SQL_DEBUG_MORE) tracef("Appending: %s", value);
            this.appender.append(value);
        } catch (Exception e) {
            warning(e.msg);
            throw new Exception("print error", e);
        }
    }

    void print(int value) {
        version(HUNT_SQL_DEBUG_MORE) tracef("Appending: %s", value);
        if (this.appender is null) {
            warning("The appender is null");
            return;
        }

        if (cast(StringBuilder)appender !is null) {
            (cast(StringBuilder) appender).append(value);
        } else if (cast(StringBuilder)appender !is null) {
            (cast(StringBuilder) appender).append(value);
        } else {
            print0(to!string(value));
        }
    }

    void print(long value) {
        version(HUNT_SQL_DEBUG_MORE) tracef("Appending: %s", value);
        if (this.appender is null) {
            warning("The appender is null");
            return;
        }

        if (cast(StringBuilder)appender !is null) {
            (cast(StringBuilder) appender).append(cast(int)value);
        } else if (cast(StringBuilder)appender !is null) {
            (cast(StringBuilder) appender).append(cast(int)value);
        } else {
            print0(to!string(value));
        }
    }


    // void print(Date date) {
    //     if (this.appender is null) {
    //         return;
    //     }

    //     SimpleDateFormat dateFormat;
    //     if (cast(java.sql.Timestamp)date !is null) {
    //         dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
    //     } else {
    //         dateFormat = new SimpleDateFormat("yyyy-MM-dd");
    //     }
    //     print0("'" ~ dateFormat.format(date) ~ "'");
    // }

    void print(String text)
    {
        print(text.value());
    }

    void print(string text) {
        if (this.appender is null) {
            return;
        }
        print0(text);
    }
     protected void print0(String text)
     {
         print0(text.value());
     }

    protected void print0(string text) {
        version(HUNT_SQL_DEBUG_MORE) tracef("Appending: %s", text);
        if (appender is null) {
            warning("appender is null");
            return;
        }

        this.appender.append(text);
    }

    protected void print0(Bytes data) {        
        implementationMissing(false);
    }

    protected void printAlias(string _alias) {
        if ((_alias !is null) && (_alias.length > 0)) {
            print(' ');
            print0(_alias);
        }
    }

    protected void printAndAccept(T = SQLObject)(List!(T) nodes, string seperator) {
        for (int i = 0, size = nodes.size(); i < size; ++i) {
            if (i != 0) {
                print0(seperator);
            }
            nodes.get(i).accept(this);
        }
    }

    private static int paramCount(SQLExpr x) {
        if (cast(SQLName)x !is null) {
            return 1;
        }

        if (cast(SQLMethodInvokeExpr)x !is null) {
            List!SQLExpr params = (cast(SQLMethodInvokeExpr) x).getParameters();
            int t_paramCount = 1;
            foreach(SQLExpr param  ;  params) {
                t_paramCount += paramCount(param);
            }
            return t_paramCount;
        }

        if (cast(SQLAggregateExpr)x !is null) {
            List!SQLExpr params = (cast(SQLAggregateExpr) x).getArguments();
            int t_paramCount = 1;
            foreach(SQLExpr param  ;  params) {
                t_paramCount += paramCount(param);
            }
            return t_paramCount;
        }

        if (cast(SQLBinaryOpExpr)x !is null) {
            return paramCount((cast(SQLBinaryOpExpr) x).getLeft())
                    + paramCount((cast(SQLBinaryOpExpr) x).getRight());
        }

        return 1;
    }

    protected void printSelectList(List!SQLSelectItem selectList) {
        this.indentCount++;
        for (int i = 0, lineItemCount = 0, size = selectList.size()
             ; i < size
                ; ++i, ++lineItemCount)
        {
            SQLSelectItem selectItem = selectList.get(i);
            SQLExpr selectItemExpr = selectItem.getExpr();

            int paramCount = paramCount(selectItemExpr);

            bool methodOrBinary = (!(cast(SQLName)selectItemExpr !is null))
                    && (cast(SQLMethodInvokeExpr)selectItemExpr !is null
                    || cast(SQLAggregateExpr)selectItemExpr !is null
                    || cast(SQLBinaryOpExpr)selectItemExpr !is null);

            if (methodOrBinary) {
                lineItemCount += (paramCount - 1);
            }

            if (i != 0) {
                SQLSelectItem preSelectItem = selectList.get(i - 1);
                if (preSelectItem.getAfterCommentsDirect() !is null) {
                    lineItemCount = 0;
                    println();
                } else if (methodOrBinary) {
                    if (lineItemCount >= selectListNumberOfLine) {
                        lineItemCount = paramCount;
                        println();
                    }
                } else if (lineItemCount >= selectListNumberOfLine
                        || cast(SQLQueryExpr)selectItemExpr !is null
                        || cast(SQLCaseExpr)selectItemExpr !is null) {
                    lineItemCount = 0;
                    println();
                }

                print0(", ");
            }

            if (typeid(selectItem) == typeid(SQLSelectItem)) {
                this.visit(selectItem);
            } else {
                selectItem.accept(this);
            }

            if (selectItem.hasAfterComment()) {
                print(' ');
                printlnComment(selectItem.getAfterCommentsDirect());
            }
        }
        this.indentCount--;
    }

    protected void printlnAndAccept(T = SQLObject)(List!(T) nodes, string seperator) {
        for (int i = 0, size = nodes.size(); i < size; ++i) {
            if (i != 0) {
                println(seperator);
            }

            (cast(T) nodes.get(i)).accept(this);
        }
    }

    protected void printIndent() {
        if (this.appender is null) {
            return;
        }

        try {
            for (int i = 0; i < this.indentCount; ++i) {
                this.appender.append('\t');
            }
        } catch (Exception e) {
            throw new Exception("print error", e);
        }
    }

    void println() {
        if (!isPrettyFormat()) {
            print(' ');
            return;
        }

        print('\n');
        lines++;
        printIndent();
    }

    void println(string text) {
        print(text);
        println();
    }

    // ////////////////////

    override bool visit(SQLBetweenExpr x) {
         SQLExpr testExpr = x.getTestExpr();
         SQLExpr beginExpr = x.getBeginExpr();
         SQLExpr endExpr = x.getEndExpr();

        bool quote = false;
        if (cast(SQLBinaryOpExpr)testExpr !is null) {
            SQLBinaryOperator t_operator = (cast(SQLBinaryOpExpr) testExpr).getOperator();
            switch (t_operator.name) {
                case SQLBinaryOperator.BooleanAnd.name:
                case SQLBinaryOperator.BooleanOr.name:
                case SQLBinaryOperator.BooleanXor.name:
                case SQLBinaryOperator.Assignment.name:
                    quote = true;
                    break;
                default:
                    quote = (cast(SQLBinaryOpExpr) testExpr).isBracket();
                    break;
            }
        } else if (cast(SQLNotExpr)testExpr !is null){
            quote = true;
        }

        if (testExpr !is null) {
            if (quote) {
                print('(');
                printExpr(testExpr);
                print(')');
            } else {
                printExpr(testExpr);
            }
        }

        if (x.isNot()) {
            print0(ucase ? " NOT BETWEEN " : " not between ");
        } else {
            print0(ucase ? " BETWEEN " : " between ");
        }

        int lines = this.lines;
        if (cast(SQLBinaryOpExpr)beginExpr !is null) {
            SQLBinaryOpExpr binaryOpBegin = cast(SQLBinaryOpExpr) beginExpr;
            incrementIndent();
            if (binaryOpBegin.isBracket() || binaryOpBegin.getOperator().isLogical()) {
                print('(');
                printExpr(beginExpr);
                print(')');
            } else {
                printExpr(beginExpr);
            }
            decrementIndent();
        } else {
            printExpr(beginExpr);
        }

        if (lines != this.lines) {
            println();
            print0(ucase ? "AND " : "and ");
        } else {
            print0(ucase ? " AND " : " and ");
        }

        printExpr(endExpr);

        return false;
    }

    override bool visit(SQLBinaryOpExprGroup x) {
        SQLObject parent = x.getParent();
        SQLBinaryOperator operator = x.getOperator();

        bool isRoot = cast(SQLSelectQueryBlock)parent !is null || cast(SQLBinaryOpExprGroup)parent !is null;

        List!SQLExpr items = x.getItems();
        if (isRoot) {
            this.indentCount++;
        }

        if (this.parameterized) {
            SQLExpr firstLeft = null;
            SQLBinaryOperator firstOp;
            List!Object parameters = new ArrayList!Object(items.size());

            List!SQLBinaryOpExpr literalItems = null;

            if (operator != SQLBinaryOperator.BooleanOr || !isEnabled(VisitorFeature.OutputParameterizedQuesUnMergeOr)) {
                for (int i = 0; i < items.size(); i++) {
                    SQLExpr item = items.get(i);
                    if (cast(SQLBinaryOpExpr)item !is null) {
                        SQLBinaryOpExpr binaryItem = cast(SQLBinaryOpExpr) item;
                        SQLExpr left = binaryItem.getLeft();
                        SQLExpr right = binaryItem.getRight();

                        if (cast(SQLLiteralExpr)right !is null && !(cast(SQLNullExpr)right !is null)) {
                            if (cast(SQLLiteralExpr)left !is null) {
                                if (literalItems is null) {
                                    literalItems = new ArrayList!SQLBinaryOpExpr();
                                }
                                literalItems.add(binaryItem);
                                continue;
                            }

                            if (this.parameters !is null) {
                                ExportParameterVisitorUtils.exportParameter(parameters, right);
                            }
                        } else if (cast(SQLVariantRefExpr)right !is null) {
                            // skip
                        } else {
                            firstLeft = null;
                            break;
                        }


                        if (firstLeft is null) {
                            firstLeft = binaryItem.getLeft();
                            firstOp = binaryItem.getOperator();
                        } else {
                            if (!SQLExprUtils.opEquals(firstLeft, left)) {
                                firstLeft = null;
                                break;
                            }
                        }
                    } else {
                        firstLeft = null;
                        break;
                    }
                }
            }

            if (firstLeft !is null) {
                if (literalItems !is null) {
                    foreach(SQLBinaryOpExpr literalItem  ;  literalItems) {
                        visit(literalItem);
                        println();
                        printOperator(operator);
                        print(' ');

                    }
                }
                printExpr(firstLeft);
                print(' ');
                printOperator(firstOp);
                print0(" ?");

                if (this.parameters !is null) {
                    if (parameters.size() > 0) {
                        this.parameters.addAll(parameters);
                    }
                }

                incrementReplaceCunt();
                if (isRoot) {
                    this.indentCount--;
                }
                return false;
            }
        }

        for (int i = 0; i < items.size(); i++) {
            SQLExpr item = items.get(i);

            if (i != 0) {
                println();
                printOperator(operator);
                print(' ');
            }

            if (item.hasBeforeComment()) {
                printlnComments(item.getBeforeCommentsDirect());
            }

            if (cast(SQLBinaryOpExpr)item !is null) {
                SQLBinaryOpExpr binaryOpExpr = cast(SQLBinaryOpExpr) item;
                SQLExpr binaryOpExprRight = binaryOpExpr.getRight();
                SQLBinaryOperator itemOp = binaryOpExpr.getOperator();

                bool isLogic = itemOp.isLogical();
                if (isLogic) {
                    indentCount++;
                }

                bool bracket;
                if (itemOp.priority > operator.priority) {
                    bracket = true;
                } else {
                    bracket = binaryOpExpr.isBracket() & !parameterized;
                }
                if (bracket) {
                    print('(');
                    visit(binaryOpExpr);
                    print(')');
                } else {
                    visit(binaryOpExpr);
                }

                if (item.hasAfterComment()) {
                    print(' ');
                    printlnComment(item.getAfterCommentsDirect());
                }

                if (isLogic) {
                    indentCount--;
                }
            } else if (cast(SQLBinaryOpExprGroup)item !is null) {
                print('(');
                visit(cast(SQLBinaryOpExprGroup) item);
                print(')');
            } else {
                printExpr(item);
            }
        }
        if (isRoot) {
            this.indentCount--;
        }
        return false;
    }

    override bool visit(SQLBinaryOpExpr x) {
        SQLBinaryOperator operator = x.getOperator();
        if (this.parameterized
                && operator == SQLBinaryOperator.BooleanOr
                && !isEnabled(VisitorFeature.OutputParameterizedQuesUnMergeOr)) {
            x = SQLBinaryOpExpr.merge(this, x);

            operator = x.getOperator();
        }

        if (inputParameters !is null
                && inputParameters.size() > 0
                && operator == SQLBinaryOperator.Equality
                && cast(SQLVariantRefExpr)x.getRight() !is null
                ) {
            SQLVariantRefExpr right = cast(SQLVariantRefExpr) x.getRight();
            int index = right.getIndex();
            if (index >= 0 && index < inputParameters.size()) {
                Object param = inputParameters.get(index);
                if (cast(Collection!Object)param !is null) {
                    x.getLeft().accept(this);
                    print0(" IN (");
                    right.accept(this);
                    print(')');
                    return false;
                }
            }
        }

        SQLObject parent = x.getParent();
        bool isRoot = cast(SQLSelectQueryBlock)parent !is null;
        bool relational = operator == SQLBinaryOperator.BooleanAnd
                             || operator == SQLBinaryOperator.BooleanOr;

        if (isRoot && relational) {
            this.indentCount++;
        }

        List!SQLExpr groupList = new ArrayList!SQLExpr();
        SQLExpr left = x.getLeft();
        SQLExpr right = x.getRight();

        if (inputParameters !is null
                && operator != SQLBinaryOperator.Equality) {
            int varIndex = -1;
            if (cast(SQLVariantRefExpr)right !is null) {
                varIndex = (cast(SQLVariantRefExpr) right).getIndex();
            }

            Object param = null;
            if (varIndex >= 0 && varIndex < inputParameters.size()) {
                param = inputParameters.get(varIndex);
            }

            if (cast(Collection!Object)param !is null) {
                Collection!Object values  = cast(Collection!Object) param;

                if (values.size() > 0) {
                    print('(');
                    int valIndex = 0;
                    foreach(Object value  ;  values) {
                        if (valIndex++ != 0) {
                            print0(ucase ? " OR " : " or ");
                        }
                        printExpr(left);
                        print(' ');
                        if (operator == SQLBinaryOperator.Is) {
                            print('=');
                        } else {
                            printOperator(operator);
                        }
                        print(' ');
                        printParameter(value);
                    }
                    print(')');
                    return false;
                }
            }
        }

        if (operator.isRelational()
                && cast(SQLIntegerExpr)left !is null
                && cast(SQLIntegerExpr)right !is null) {
            print((cast(SQLIntegerExpr) left).getNumber().longValue());
            print(' ');
            printOperator(operator);
            print(' ');
            print((cast(SQLIntegerExpr) right).getNumber().longValue());
            return false;
        }

        for (;;) {
            if (cast(SQLBinaryOpExpr)left !is null && (cast(SQLBinaryOpExpr) left).getOperator() == operator) {
                SQLBinaryOpExpr binaryLeft = cast(SQLBinaryOpExpr) left;
                groupList.add(binaryLeft.getRight());
                left = binaryLeft.getLeft();
            } else {
                groupList.add(left);
                break;
            }
        }

        for (int i = groupList.size() - 1; i >= 0; --i) {
            SQLExpr item = groupList.get(i);

            if (relational) {
                if (isPrettyFormat() && item.hasBeforeComment()) {
                    printlnComments(item.getBeforeCommentsDirect());
                }
            }

            if (isPrettyFormat() && item.hasBeforeComment()) {
                printlnComments(item.getBeforeCommentsDirect());
            }

            visitBinaryLeft(item, operator);

            if (isPrettyFormat() && item.hasAfterComment()) {
                print(' ');
                printlnComment(item.getAfterCommentsDirect());
            }

            if (i != groupList.size() - 1 && isPrettyFormat() && item.getParent().hasAfterComment()) {
                print(' ');
                printlnComment(item.getParent().getAfterCommentsDirect());
            }

            bool printOpSpace = true;
            if (relational) {
                println();
            } else {
                if (operator == SQLBinaryOperator.Modulus
                        && DBType.ORACLE.opEquals(dbType)
                        && cast(SQLIdentifierExpr)left !is null
                        && cast(SQLIdentifierExpr)right !is null
                        && (cast(SQLIdentifierExpr) right).getName().equalsIgnoreCase("NOTFOUND")) {
                    printOpSpace = false;
                }
                if (printOpSpace) {
                    print(' ');
                }
            }
            printOperator(operator);
            if (printOpSpace) {
                print(' ');
            }
        }

        visitorBinaryRight(x);

        if (isRoot && relational) {
            this.indentCount--;
        }

        return false;
    }

    protected void printOperator(SQLBinaryOperator operator) {
        print0(ucase ? operator.name : operator.name_lcase);
    }

    private void visitorBinaryRight(SQLBinaryOpExpr x) {
        if (isPrettyFormat() && x.getRight().hasBeforeComment()) {
            printlnComments(x.getRight().getBeforeCommentsDirect());
        }

        if ( cast(SQLBinaryOpExpr)x.getRight() !is null) {
            SQLBinaryOpExpr right = cast(SQLBinaryOpExpr) x.getRight();
            SQLBinaryOperator rightOp = right.getOperator();
            SQLBinaryOperator op = x.getOperator();
            bool rightRational = rightOp == SQLBinaryOperator.BooleanAnd
                                    || rightOp == SQLBinaryOperator.BooleanOr;

            if (rightOp.priority >= op.priority
                    || (right.isBracket()
                    && rightOp != op
                    && rightOp.isLogical()
                    && op.isLogical()
            )) {
                if (rightRational) {
                    this.indentCount++;
                }

                print('(');
                printExpr(right);
                print(')');

                if (rightRational) {
                    this.indentCount--;
                }
            } else {
                printExpr(right);
            }
        } else {
            printExpr(x.getRight());
        }

        if (x.getRight().hasAfterComment() && isPrettyFormat()) {
            print(' ');
            printlnComment(x.getRight().getAfterCommentsDirect());
        }
    }

    private void visitBinaryLeft(SQLExpr left, SQLBinaryOperator op) {
        if (cast(SQLBinaryOpExpr)left !is null) {
            SQLBinaryOpExpr binaryLeft = cast(SQLBinaryOpExpr) left;
            SQLBinaryOperator leftOp = binaryLeft.getOperator();
            bool leftRational = leftOp == SQLBinaryOperator.BooleanAnd
                                   || leftOp == SQLBinaryOperator.BooleanOr;

            if (leftOp.priority > op.priority
                    || (binaryLeft.isBracket()
                        && leftOp != op
                        && leftOp.isLogical()
                        && op.isLogical()
            )) {
                if (leftRational) {
                    this.indentCount++;
                }
                print('(');
                printExpr(left);
                print(')');

                if (leftRational) {
                    this.indentCount--;
                }
            } else {
                printExpr(left);
            }
        } else {
            printExpr(left);
        }
    }

    protected void printTableSource(SQLTableSource x) {
        auto clazz = typeid(x);
        if (clazz == typeid(SQLJoinTableSource)) {
            visit(cast(SQLJoinTableSource) x);
        } else  if (clazz == typeid(SQLExprTableSource)) {
            visit(cast(SQLExprTableSource) x);
        } else  if (clazz == typeid(SQLSubqueryTableSource)) {
            visit(cast(SQLSubqueryTableSource) x);
        } else {
            x.accept(this);
        }
    }

    protected void printQuery(SQLSelectQuery x) {
        auto clazz = typeid(x);
        if (clazz == typeid(SQLSelectQueryBlock)) {
            visit(cast(SQLSelectQueryBlock) x);
        } else if (clazz == typeid(SQLUnionQuery)) {
            visit(cast(SQLUnionQuery) x);
        } else {
            x.accept(this);
        }
    }

    protected  void printExpr(SQLExpr x) {
        auto clazz = typeid((cast(Object)x)); //typeid(x);
        version(HUNT_DEBUG) {
            // tracef("SQLExpr: %s", clazz.name);
            // tracef("SQLExpr2: %s", typeid((cast(Object)x)).name);
        } 

        if (clazz == typeid(SQLIdentifierExpr)) {
            visit(cast(SQLIdentifierExpr) x);
        } else if (clazz == typeid(SQLPropertyExpr)) {
            visit(cast(SQLPropertyExpr) x);
        } else if (clazz == typeid(SQLAllColumnExpr)) {
            print('*');
        } else if (clazz == typeid(SQLAggregateExpr)) {
            visit(cast(SQLAggregateExpr) x);
        } else if (clazz == typeid(SQLBinaryOpExpr)) {
            visit(cast(SQLBinaryOpExpr) x);
        } else if (clazz == typeid(SQLCharExpr)) {
            visit(cast(SQLCharExpr) x);
        } else if (clazz == typeid(SQLNullExpr)) {
            visit(cast(SQLNullExpr) x);
        } else if (clazz == typeid(SQLIntegerExpr)) {
            visit(cast(SQLIntegerExpr) x);
        } else if (clazz == typeid(SQLNumberExpr)) {
            visit(cast(SQLNumberExpr) x);
        } else if (clazz == typeid(SQLMethodInvokeExpr)) {
            visit(cast(SQLMethodInvokeExpr) x);
        } else if (clazz == typeid(SQLVariantRefExpr)) {
            visit(cast(SQLVariantRefExpr) x);
        } else if (clazz == typeid(SQLBinaryOpExprGroup)) {
            visit(cast(SQLBinaryOpExprGroup) x);
        } else if (clazz == typeid(SQLCaseExpr)) {
            visit(cast(SQLCaseExpr) x);
        } else if (clazz == typeid(SQLInListExpr)) {
            visit(cast(SQLInListExpr) x);
        } else if (clazz == typeid(SQLNotExpr)) {
            visit(cast(SQLNotExpr) x);
        } else {
            x.accept(this);
        }
    }

    override bool visit(SQLCaseExpr x) {
        this.indentCount++;
        print0(ucase ? "CASE " : "case ");

        SQLExpr valueExpr = x.getValueExpr();
        if (valueExpr !is null) {
            printExpr(valueExpr);
        }

        List!(SQLCaseExpr.Item) items = x.getItems();
        for (int i = 0, size = items.size(); i < size; ++i) {
            println();
            visit(items.get(i));
        }

        SQLExpr elExpr = x.getElseExpr();
        if (elExpr !is null) {
            println();
            print0(ucase ? "ELSE " : "else ");
            if (cast(SQLCaseExpr)elExpr !is null) {
                this.indentCount++;
                println();
                visit(cast(SQLCaseExpr) elExpr);
                this.indentCount--;
            } else {
                printExpr(elExpr);
            }
        }

        this.indentCount--;
        println();
        print0(ucase ? "END" : "end");

        return false;
    }

    override bool visit(SQLCaseExpr.Item x) {
        print0(ucase ? "WHEN " : "when ");
        SQLExpr conditionExpr = x.getConditionExpr();
        printExpr(conditionExpr);

        print0(ucase ? " THEN " : " then ");
        SQLExpr valueExpr = x.getValueExpr();
        if (cast(SQLCaseExpr)valueExpr !is null) {
            this.indentCount++;
            println();
            visit(cast(SQLCaseExpr) valueExpr);
            this.indentCount--;
        } else {
            printExpr(valueExpr);
        }

        return false;
    }

    override bool visit(SQLCaseStatement x) {
        print0(ucase ? "CASE" : "case");
        SQLExpr valueExpr = x.getValueExpr();
        if (valueExpr !is null) {
            print(' ');
            printExpr(valueExpr);
        }
        this.indentCount++;
        println();
        printlnAndAccept!(SQLCaseStatement.Item)((x.getItems()), " ");

        if (x.getElseStatements().size() > 0) {
            println();
            print0(ucase ? "ELSE " : "else ");
            printlnAndAccept!(SQLStatement)((x.getElseStatements()), "");
        }

        this.indentCount--;

        println();
        print0(ucase ? "END CASE" : "end case");
        if (DBType.ORACLE.opEquals(dbType)) {
            print(';');
        }
        return false;
    }

    override bool visit(SQLCaseStatement.Item x) {
        print0(ucase ? "WHEN " : "when ");
        printExpr(x.getConditionExpr());
        print0(ucase ? " THEN " : " then ");

        SQLStatement stmt = x.getStatement();
        if (stmt !is null) {
            stmt.accept(this);
            print(';');
        }
        return false;
    }

    override bool visit(SQLCastExpr x) {
        print0(ucase ? "CAST(" : "cast(");
        x.getExpr().accept(this);
        print0(ucase ? " AS " : " as ");
        x.getDataType().accept(this);
        print0(")");

        return false;
    }

    override bool visit(SQLCharExpr x) {
        if (this.parameterized) {
            print('?');
            incrementReplaceCunt();
            if (this.parameters !is null) {
                ExportParameterVisitorUtils.exportParameter(this.parameters, x);
            }
            return false;
        }

        printChars(x.getText().value());

        return false;
    }

    protected void printChars(string text) {
        if (text is null) {
            print0(ucase ? "NULL" : "null");
        } else {
            print('\'');
            int index = cast(int)(text.indexOf('\''));
            if (index >= 0) {
                text = text.replace("'", "''");//@gxc
            }
            print0(text);
            print('\'');
        }
    }

    override bool visit(SQLDataType x) {
        printDataType(x);

        return false;
    }

    protected void printDataType(SQLDataType x) {
        bool parameterized = this.parameterized;
        this.parameterized = false;

        print0(x.getName());
        if (x.getArguments().size() > 0) {
            print('(');
            printAndAccept!SQLExpr(x.getArguments(), ", ");
            print(')');
        }

        bool withTimeZone = x.getWithTimeZone();
        /* if (withTimeZone !is null) */ {
            if (withTimeZone) {
                if (x.isWithLocalTimeZone()) {
                    print0(ucase ? " WITH LOCAL TIME ZONE" : " with local time zone");
                } else {
                    print0(ucase ? " WITH TIME ZONE" : " with time zone");
                }
            } else {
                print0(ucase ? " WITHOUT TIME ZONE" : " without time zone");
            }
        }
        this.parameterized = parameterized;
    }

    override bool visit(SQLCharacterDataType x) {
        visit(cast(SQLDataType) x);

        List!SQLCommentHint hints = (cast(SQLCharacterDataType) x).hints;
        if (hints !is null) {
            print(' ');
            foreach(SQLCommentHint hint  ;  hints) {
                hint.accept(this);
            }
        }

        return false;
    }

    override bool visit(SQLExistsExpr x) {
        if (x.isNot()) {
            print0(ucase ? "NOT EXISTS (" : "not exists (");
        } else {
            print0(ucase ? "EXISTS (" : "exists (");
        }
        this.indentCount++;
        println();
        visit(x.getSubQuery());
        this.indentCount--;
        println();
        print(')');
        return false;
    }

    override bool visit(SQLIdentifierExpr x) {
        string name = x.getName();
        if(isEnabled(VisitorFeature.OutputQuotedIdentifier)) {
            print0(_quotes ~ name ~ _quotes);
        } else {
            print0(name);
        }
        return false;
    }

    protected bool printName(SQLName x, string name) {
        bool shardingSupport = this.shardingSupport
                && this.parameterized;
        return printName(x, name, shardingSupport);
    }

    string unwrapShardingTable(string name) {
        char c0 = charAt(name, 0);
        char c_last = charAt(name, name.length - 1);
         bool quote = (c0 == '`' && c_last == '`') || (c0 == '"' && c_last == '"');

        int end = cast(int)(name.length);
        if (quote) {
            end--;
        }

        int num_cnt = 0, postfixed_cnt = 0;
        for (int i = end - 1; i > 0; --i, postfixed_cnt++) {
            char ch = charAt(name, i);
            if (ch >= '0' && ch <= '9') {
                num_cnt++;
            }

            if (ch != '_' && (ch < '0' || ch > '9')) {
                break;
            }
        }
        if (num_cnt < 1 || postfixed_cnt < 2) {
            return name;
        }

        int start = end - postfixed_cnt;
        if (start < 1) {
            return name;
        }

        string realName = name.substring(quote ? 1 : 0, start);
        return realName;
    }

    protected bool printName(SQLName x, string name, bool shardingSupport) {

        if (shardingSupport) {
            SQLObject parent = x.getParent();
            shardingSupport = cast(SQLExprTableSource)parent !is null || cast(SQLPropertyExpr)parent !is null;

            if (cast(SQLPropertyExpr)parent !is null &&  cast(SQLExprTableSource)parent.getParent() !is null) {
                shardingSupport = false;
            }
        }

        if (shardingSupport) {
             bool quote = charAt(name, 0) == '`' && charAt(name, name.length - 1) == '`';

            string unwrappedName = unwrapShardingTable(name);
            if (unwrappedName != name) {
                bool isAlias = false;
                for (SQLObject parent = x.getParent(); parent !is null; parent = parent.getParent()) {
                    if (cast(SQLSelectQueryBlock)parent !is null) {
                        SQLTableSource from = (cast(SQLSelectQueryBlock) parent).getFrom();
                        if (quote) {
                            // string name2 = name.substring(1, name.length - 1);
                            string name2 = name[1 .. $-1];
                            if (isTableSourceAlias(from, name, name2)) {
                                isAlias = true;
                            }
                        } else {
                            if (isTableSourceAlias(from, name)) {
                                isAlias = true;
                            }
                        }
                        break;
                    }
                }

                if (!isAlias) {
                    print0(unwrappedName);
                    incrementReplaceCunt();
                    return false;
                } else {
                    print0(name);
                    return false;
                }
            }
        }

        print0(name);
        return false;
    }

    override bool visit(SQLInListExpr x) {
        if (this.parameterized) {
            List!SQLExpr targetList = x.getTargetList();

            bool allLiteral = true;
            foreach(SQLExpr item  ;  targetList) {
                if (!(cast(SQLLiteralExpr)item !is null || cast(SQLVariantRefExpr)item !is null)) {
                    if (cast(SQLListExpr)item !is null) {
                        SQLListExpr list = cast(SQLListExpr) item;
                        foreach(SQLExpr listItem ;list.getItems()) {
                            if (!(cast(SQLLiteralExpr)listItem !is null || cast(SQLVariantRefExpr)listItem !is null)) {
                                allLiteral = false;
                                break;
                            }
                        }
                        if (allLiteral) {
                            break;
                        }
                        continue;
                    }
                    allLiteral = false;
                    break;
                }
            }

            if (allLiteral) {
                bool changed = true;
                if (targetList.size() == 1 && cast(SQLVariantRefExpr)targetList.get(0) !is null) {
                    changed = false;
                }

                printExpr(x.getExpr());

                if (x.isNot()) {
                    print(ucase ? " NOT IN" : " not in");
                } else {
                    print(ucase ? " IN" : " in");
                }

                if(!isParameterizedQuesUnMergeInList() || targetList.size() == 1) {
                    print(" (?)");
                } else {
                    print(" (");
                    for (int i = 0; i < targetList.size(); i++) {
                        if(i != 0) {
                            print(",");
                        }
                        print(" ?");
                    }
                    print(")");
                }

                if (changed) {
                    incrementReplaceCunt();
                    if (this.parameters !is null) {
                        if (parameterizedMergeInList) {
                            List!Object subList = new ArrayList!Object(x.getTargetList().size());
                            foreach (SQLExpr target ; x.getTargetList()) {
                                ExportParameterVisitorUtils.exportParameter(subList, target);
                            }
                            if (subList !is null) {
                                parameters.addAll(subList);
                            }
                        } else {
                            foreach (SQLExpr target ; x.getTargetList()) {
                                ExportParameterVisitorUtils.exportParameter(this.parameters, target);
                            }
                        }
                    }
                }

                return false;
            }
        }

        printExpr(x.getExpr());

        if (x.isNot()) {
            print0(ucase ? " NOT IN (" : " not in (");
        } else {
            print0(ucase ? " IN (" : " in (");
        }

         List!SQLExpr list = x.getTargetList();

        bool _printLn = false;
        if (list.size() > 5) {
            _printLn = true;
            for (int i = 0, size = list.size(); i < size; ++i) {
                if (!(cast(SQLCharExpr)list.get(i) !is null)) {
                    _printLn = false;
                    break;
                }
            }
        }

        if (_printLn) {
            this.indentCount++;
            println();
            for (int i = 0, size = list.size(); i < size; ++i) {
                if (i != 0) {
                    print0(", ");
                    println();
                }
                SQLExpr item = list.get(i);
                printExpr(item);
            }
            this.indentCount--;
            println();
        } else {
            List!SQLExpr targetList = x.getTargetList();
            for (int i = 0; i < targetList.size(); i++) {
                if (i != 0) {
                    print0(", ");
                }
                printExpr(targetList.get(i));
            }
        }

        print(')');
        return false;
    }

    override bool visit(SQLIntegerExpr x) {
        bool parameterized = this.parameterized;
        printInteger(x, parameterized);
        return false;
    }

    protected void printInteger(SQLIntegerExpr x, bool parameterized) {
        Number number = x.getNumber();

        if (number == (Integer.valueOf(1))) {
            if (DBType.ORACLE.opEquals(dbType)) {
                SQLObject parent = x.getParent();
                if (cast(SQLBinaryOpExpr)parent !is null) {
                    SQLBinaryOpExpr binaryOpExpr = cast(SQLBinaryOpExpr) parent;
                    SQLExpr left = binaryOpExpr.getLeft();
                    SQLBinaryOperator op = binaryOpExpr.getOperator();
                    if (cast(SQLIdentifierExpr)left !is null
                            && op == SQLBinaryOperator.Equality) {
                        string name = (cast(SQLIdentifierExpr) left).getName();
                        if ("rownum" == (name)) {
                            print(1);
                            return;
                        }
                    }
                }
            }
        }
        if (parameterized) {
            print('?');
            incrementReplaceCunt();

            if(this.parameters !is null){
                ExportParameterVisitorUtils.exportParameter(this.parameters, x);
            }
            return;
        }

        if (cast(BigDecimal)number !is null || cast(BigInteger)number !is null) {
            print((cast(Object)(number)).toString());
        } else {
            print(number.longValue());
        }
    }

    override bool visit(SQLMethodInvokeExpr x) {
        SQLExpr owner = x.getOwner();
        if (owner !is null) {
            printMethodOwner(owner);
        }

        string _function = x.getMethodName();
        List!SQLExpr parameters = x.getParameters();

        printFunctionName(_function);
        print('(');

        string trimOption = x.getTrimOption();
        if (trimOption !is null) {
            print0(trimOption);

            if (parameters.size() > 0) {
                print(' ');
            }
        }


        for (int i = 0, size = parameters.size(); i < size; ++i) {
            if (i != 0) {
                print0(", ");
            }
            SQLExpr param = parameters.get(i);

            if (this.parameterized) {
                if (size == 2 && i == 1 && cast(SQLCharExpr)param !is null) {
                    if (DBType.ORACLE.opEquals(dbType)) {
                        if ("TO_CHAR".equalsIgnoreCase(_function)
                                || "TO_DATE".equalsIgnoreCase(_function)) {
                            printChars((cast(SQLCharExpr) param).getText().value());
                            continue;
                        }
                    } else if (DBType.MYSQL.opEquals(dbType)) {
                        if ("DATE_FORMAT".equalsIgnoreCase(_function)) {
                            printChars((cast(SQLCharExpr) param).getText().value());
                            continue;
                        }
                    }
                }

            }

            if (cast(SQLBinaryOpExpr)param !is null) {
                SQLBinaryOpExpr binaryOpExpr = cast(SQLBinaryOpExpr) param;
                SQLBinaryOperator op = binaryOpExpr.getOperator();
                if (op == SQLBinaryOperator.BooleanAnd || op == SQLBinaryOperator.BooleanOr) {
                    this.indentCount++;
                    printExpr(param);
                    this.indentCount--;
                    continue;
                }
            }

            printExpr(param);
        }

        SQLExpr from = x.getFrom();
        if (from !is null) {
            print0(ucase ? " FROM " : " from ");
            printExpr(from);

            SQLExpr _for = x.getFor();
            if (_for !is null) {
                print0(ucase ? " FOR " : " for ");
                printExpr(_for);
            }
        }

        SQLExpr using = x.getUsing();
        if (using !is null) {
            print0(ucase ? " USING " : " using ");
            printExpr(using);
        }

        print(')');
        return false;
    }

    protected void printMethodOwner(SQLExpr owner) {
        printExpr(owner);
        print('.');
    }

    protected void printFunctionName(string name) {
        print0(name);
    }

    override bool visit(SQLAggregateExpr x) {
        bool parameterized = this.parameterized;
        this.parameterized = false;

        string methodName = x.getMethodName();
        print0(ucase ? methodName : toLower(methodName));
        print('(');

        SQLAggregateOption option = x.getOption();
        if (option.name.length != 0) {
            print0(option.name);
            print(' ');
        }

        List!SQLExpr arguments = x.getArguments();
        for (int i = 0, size = arguments.size(); i < size; ++i) {
            if (i != 0) {
                print0(", ");
            }
            printExpr(arguments.get(i));
        }

        visitAggreateRest(x);

        print(')');

        if (DBType.POSTGRESQL != dbType) {
            SQLOrderBy withGroup = x.getWithinGroup();
            if (withGroup !is null) {
                print0(ucase ? " WITHIN GROUP (" : " within group (");
                visit(withGroup);
                print(')');
            }
        }

        SQLKeep keep = x.getKeep();
        if (keep !is null) {
            print(' ');
            visit(keep);
        }

        SQLOver over = x.getOver();
        if (over !is null) {
            print(' ');
            over.accept(this);
        }

         SQLExpr filter = x.getFilter();
        if (filter !is null) {
            print0(ucase ? "FILTER (WHERE " : "filter (where ");
            printExpr(filter);
            print(')');
        }

        this.parameterized = parameterized;
        return false;
    }

    protected void visitAggreateRest(SQLAggregateExpr aggregateExpr) {

    }

    override bool visit(SQLAllColumnExpr x) {
        print('*');
        return true;
    }

    override bool visit(SQLNCharExpr x) {
        if (this.parameterized) {
            print('?');
            incrementReplaceCunt();

            if(this.parameters !is null){
                ExportParameterVisitorUtils.exportParameter(this.parameters, x);
            }
            return false;
        }

        if ((x.getText() is null) || (x.getText().value.length == 0)) {
            print0(ucase ? "NULL" : "null");
        } else {
            print0(ucase ? "N'" : "n'");
            print0(x.getText().value().replace("'", "''"));
            print('\'');
        }
        return false;
    }

    override bool visit(SQLNotExpr x) {
        print0(ucase ? "NOT " : "not ");
        SQLExpr expr = x.getExpr();

        bool needQuote = false;

        if (cast(SQLBinaryOpExpr)expr !is null) {
            SQLBinaryOpExpr binaryOpExpr = cast(SQLBinaryOpExpr) expr;
            needQuote = binaryOpExpr.getOperator().isLogical();
        } else if (cast(SQLInListExpr)expr !is null || cast(SQLNotExpr)expr !is null) {
            needQuote = true;
        }

        if (needQuote) {
            print('(');
        }
        printExpr(expr);

        if (needQuote) {
            print(')');
        }
        return false;
    }

    override bool visit(SQLNullExpr x) {
        if (this.parameterized
                && cast(ValuesClause)x.getParent() !is null) {
            print('?');
            incrementReplaceCunt();

            if(this.parameters !is null){
                this.getParameters().add(null);
            }
            return false;
        }

        print0(ucase ? "NULL" : "null");
        return false;
    }

    override bool visit(SQLNumberExpr x) {
        if (this.parameterized) {
            print('?');
            incrementReplaceCunt();

            if(this.parameters !is null){
                ExportParameterVisitorUtils.exportParameter((this).getParameters(), x);
            }
            return false;
        }

        if (cast(StringBuilder)appender !is null) {
            x.output(cast(StringBuilder) appender);
        } else if (cast(StringBuilder)appender !is null) {
            x.output(cast(StringBuilder) appender);
        } else {
            print0(x.getNumber().toString());
        }
        return false;
    }

    override bool visit(SQLPropertyExpr x) {
        SQLExpr owner = x.getOwner();
        SQLIdentifierExpr ownerIdent = cast(SQLIdentifierExpr)owner;

        string mapTableName = null, ownerName = null;
        if (ownerIdent !is null) {
            ownerName = ownerIdent.getName();
            if (tableMapping !is null) {
                mapTableName = tableMapping.get(ownerName);

                //tracef("mapTableName: %s, ownerName=%s", mapTableName, ownerName);
                if (mapTableName.empty()
                        && ownerName.length > 2
                        && ownerName[0] == '`'
                        && ownerName[$-1] == '`') {
                    ownerName = ownerName[1 .. $ - 1];
                    mapTableName = tableMapping.get(ownerName);
                }
            }
        }


        if (!mapTableName.empty()) {
            for (SQLObject parent = x.getParent();parent !is null; parent = parent.getParent()) {
                if (cast(SQLSelectQueryBlock)parent !is null) {
                    SQLTableSource from = (cast(SQLSelectQueryBlock) parent).getFrom();
                    if (isTableSourceAlias(from, mapTableName, ownerName)) {
                        mapTableName = null;
                    }
                    break;
                }
            }
        }

        // version(HUNT_SQL_DEBUG_MORE) tracef("mapTableName: %s, ownerName=%s", mapTableName, ownerName);
        
        if (!mapTableName.empty()) {
            print0(mapTableName);
            print('.');
        } else if (ownerIdent !is null) {
            ownerName = ownerIdent.getName();
            if(!ownerName.empty()) {
                if(isEnabled(VisitorFeature.OutputQuotedIdentifier)) {
                    print(_quotes);
                    printName(ownerIdent, ownerName, this.shardingSupport && this.parameterized);
                    print(_quotes);
                } else {
                    printName(ownerIdent, ownerName, this.shardingSupport && this.parameterized);
                }

                print('.');
            }
        } else {
            printExpr(owner);
            print('.');
        }

       string name = x.getName();
        if(isEnabled(VisitorFeature.OutputQuotedIdentifier)) {
            print0(_quotes ~ name ~ _quotes);
        } else {
            print0(name);
        }

        return false;
    }

    protected bool isTableSourceAlias(SQLTableSource from, string[] tableNames...) {
        string _alias = from.getAlias();

        if (_alias !is null) {
            foreach(string tableName  ;  tableNames) {
                if (equalsIgnoreCase(_alias, tableName)) {
                    return true;
                }
            }

            if (_alias.length > 2 && charAt(_alias, 0) == '`' && charAt(_alias, _alias.length -1) == '`') {
                _alias = _alias.substring(1, _alias.length -1);
                foreach(string tableName  ;  tableNames) {
                    if (equalsIgnoreCase(_alias, tableName)) {
                        return true;
                    }
                }
            }
        }
        if (cast(SQLJoinTableSource)from !is null) {
            SQLJoinTableSource join = cast(SQLJoinTableSource) from;
            return isTableSourceAlias(join.getLeft(), tableNames)
                    || isTableSourceAlias(join.getRight(), tableNames);
        }
        return false;
    }

    override bool visit(SQLQueryExpr x) {
        SQLObject parent = x.getParent();
        if (cast(SQLSelect)parent !is null) {
            parent = parent.getParent();
        }

        SQLSelect subQuery = x.getSubQuery();
        if (cast(ValuesClause)parent !is null) {
            println();
            print('(');
            visit(subQuery);
            print(')');
            println();
        // } else if ((cast(SQLStatement)parent !is null
        //         && !(cast(OracleForStatement)parent !is null))
        //         || cast(OracleSelectPivot.Item)parent !is null) {
        //     this.indentCount++;

        //     println();
        //     visit(subQuery);

        //     this.indentCount--;
        } else if (cast(SQLOpenStatement)parent !is null) {
            visit(subQuery);
        } else {
            print('(');
            this.indentCount++;
            println();
            visit(subQuery);
            this.indentCount--;
            println();
            print(')');
        }
        return false;
    }

    override bool visit(SQLSelectGroupByClause x) {

        bool oracle = DBType.ORACLE.opEquals(dbType);
        bool rollup = x.isWithRollUp();
        bool cube = x.isWithCube();

        int itemSize = x.getItems().size();
        if (itemSize > 0) {
            print0(ucase ? "GROUP BY " : "group by ");
            if (oracle && rollup) {
                print0(ucase ? "ROLLUP (" : "rollup (");
            } else if (oracle && cube) {
                print0(ucase ? "CUBE (" : "cube (");
            }
            this.indentCount++;
            for (int i = 0; i < itemSize; ++i) {
                if (i != 0) {
                    if (groupItemSingleLine) {
                        println(", ");
                    } else {
                        print(", ");
                    }
                }
                x.getItems().get(i).accept(this);
            }
            if (oracle && rollup) {
                print(')');
            }
            this.indentCount--;
        }

        if (x.getHaving() !is null) {
            println();
            print0(ucase ? "HAVING " : "having ");
            x.getHaving().accept(this);
        }

        if (x.isWithRollUp() && !oracle) {
            print0(ucase ? " WITH ROLLUP" : " with rollup");
        }

        if (x.isWithCube() && !oracle) {
            print0(ucase ? " WITH CUBE" : " with cube");
        }

        return false;
    }

    override bool visit(SQLSelect x) {
        SQLWithSubqueryClause withSubQuery = x.getWithSubQuery();
        if (withSubQuery !is null) {
            withSubQuery.accept(this);
            println();
        }

        printQuery(x.getQuery());

        SQLOrderBy orderBy = x.getOrderBy();
        if (orderBy !is null) {
            println();
            orderBy.accept(this);
        }

        if (x.getHintsSize() > 0) {
            printAndAccept!SQLHint((x.getHints()), "");
        }

        return false;
    }

    override bool visit(SQLSelectQueryBlock x) {
        if (isPrettyFormat() && x.hasBeforeComment()) {
            printlnComments(x.getBeforeCommentsDirect());
        }

        print0(ucase ? "SELECT " : "select ");

         bool informix =DBType.INFORMIX.opEquals(dbType);
        if (informix) {
            printFetchFirst(x);
        }

         int distinctOption = x.getDistionOption();
        if (SQLSetQuantifier.ALL == distinctOption) {
            print0(ucase ? "ALL " : "all ");
        } else if (SQLSetQuantifier.DISTINCT == distinctOption) {
            print0(ucase ? "DISTINCT " : "distinct ");
        } else if (SQLSetQuantifier.UNIQUE == distinctOption) {
            print0(ucase ? "UNIQUE " : "unique ");
        }

        printSelectList(
                x.getSelectList());

        SQLExprTableSource into = x.getInto();
        if (into !is null) {
            println();
            print0(ucase ? "INTO " : "into ");
            into.accept(this);
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
            orderBy.accept(this);
        }

        if (!informix) {
            printFetchFirst(x);
        }

        if (x.isForUpdate()) {
            println();
            print0(ucase ? "FOR UPDATE" : "for update");
        }

        return false;
    }

    protected void printFetchFirst(SQLSelectQueryBlock x) {
        SQLLimit limit = x.getLimit();
        if (limit is null) {
            return;
        }

        SQLExpr offset = limit.getOffset();
        SQLExpr first = limit.getRowCount();

        if (limit !is null) {
            if (DBType.INFORMIX.opEquals(dbType)) {
                if (offset !is null) {
                    print0(ucase ? "SKIP " : "skip ");
                    offset.accept(this);
                }

                print0(ucase ? " FIRST " : " first ");
                first.accept(this);
                print(' ');
            } else if (DBType.DB2.opEquals(dbType)
                    || DBType.ORACLE.opEquals(dbType)
                    || DBType.SQL_SERVER.opEquals(dbType)) {
                //order by 语句必须在FETCH FIRST ROWS ONLY之前
                SQLObject parent = x.getParent();
                if (cast(SQLSelect)parent !is null) {
                    SQLOrderBy orderBy = (cast(SQLSelect) parent).getOrderBy();
                    if (orderBy !is null && orderBy.getItems().size() > 0) {
                        println();
                        print0(ucase ? "ORDER BY " : "order by ");
                        printAndAccept!SQLSelectOrderByItem((orderBy.getItems()), ", ");
                    }
                }

                println();

                if (offset !is null) {
                    print0(ucase ? "OFFSET " : "offset ");
                    offset.accept(this);
                    print0(ucase ? " ROWS" : " rows");
                }

                if (first !is null) {
                    if (offset !is null) {
                        print(' ');
                    }
                    if (DBType.SQL_SERVER.opEquals(dbType) && offset !is null) {
                        print0(ucase ? "FETCH NEXT " : "fetch next ");
                    } else {
                        print0(ucase ? "FETCH FIRST " : "fetch first ");
                    }
                    first.accept(this);
                    print0(ucase ? " ROWS ONLY" : " rows only");
                }
            } else {
                println();
                limit.accept(this);
            }
        }
    }

    override bool visit(SQLSelectItem x) {
        if (x.isConnectByRoot()) {
            print0(ucase ? "CONNECT_BY_ROOT " : "connect_by_root ");
        }

        SQLExpr expr = x.getExpr();
        SQLIdentifierExpr identifierExpr = cast(SQLIdentifierExpr)expr;

        if (identifierExpr !is null) {
            string name = identifierExpr.getName();
            print0(name);
            // if(isEnabled(VisitorFeature.OutputQuotedIdentifier)) {
            //     print0(_quotes ~ name ~ _quotes);
            // } else {
            //     print0(name);
            // }
        } else if (cast(SQLPropertyExpr)expr !is null) {
            visit(cast(SQLPropertyExpr) expr);
        } else {
            printExpr(expr);
        }

        string _alias = x.getAlias();
        if (!_alias.empty) {
            print0(ucase ? " AS " : " as ");
            _alias = _alias.strip();
            char c0 = _alias[0];
            if (c0 == '"' || c0 == '\'') { // _alias.indexOf(' ') == -1 || 
                print0(_alias);
            } else {
                if(isEnabled(VisitorFeature.OutputQuotedIdentifier)) {
                    print0(_quotes ~ _alias ~ _quotes);
                } else {
                    print0(_alias);
                }
            }
        }
        return false;
    }

    override bool visit(SQLOrderBy x) {
        List!SQLSelectOrderByItem items = x.getItems();

        if (items.size() > 0) {
            if (x.isSibings()) {
                print0(ucase ? "ORDER SIBLINGS BY " : "order siblings by ");
            } else {
                print0(ucase ? "ORDER BY " : "order by ");
            }

            for (int i = 0, size = items.size(); i < size; ++i) {
                if (i != 0) {
                    print0(", ");
                }
                SQLSelectOrderByItem item = items.get(i);
                visit(item);
            }
        }
        return false;
    }

    override bool visit(SQLSelectOrderByItem x) {
        SQLExpr expr = x.getExpr();

        if (cast(SQLIntegerExpr)expr !is null) {
            print((cast(SQLIntegerExpr) expr).getNumber().longValue());
        } else {
            printExpr(expr);
        }

        SQLOrderingSpecification type = x.getType();
        if (type !is null) {
            print(' ');
            print0(ucase ? type.name : type.name_lcase);
        }

        string collate = x.getCollate();
        if (collate !is null) {
            print0(ucase ? " COLLATE " : " collate ");
            print0(collate);
        }

        SQLSelectOrderByItem.NullsOrderType nullsOrderType = x.getNullsOrderType();
        if (nullsOrderType.name.length != 0) {
            print(' ');
            print0(nullsOrderType.toFormalString());
        }

        return false;
    }

    protected void addTable(string table) {
        if (tables is null) {
            if (this.table is null) {
                this.table = table;
                return;
            } else {
                tables = new LinkedHashSet!string();
                tables.add(this.table);
            }
        }
        this.tables.add(table);
    }

    protected void printTableSourceExpr(SQLExpr expr) {
        if (exportTables) {
            addTable((cast(Object)(expr)).toString());
        }

        if (isEnabled(VisitorFeature.OutputDesensitize)) {
            string ident = null;
            if (cast(SQLIdentifierExpr)expr !is null) {
                ident = (cast(SQLIdentifierExpr) expr).getName();
            } else if (cast(SQLPropertyExpr)expr !is null) {
                SQLPropertyExpr propertyExpr = cast(SQLPropertyExpr) expr;
                propertyExpr.getOwner().accept(this);
                print('.');

                ident = propertyExpr.getName();
            }

            if (ident !is null) {
                string desensitizeTable = SQLUtils.desensitizeTable(ident);
                print0(desensitizeTable);
                return;
            }
        }

        if (tableMapping !is null && cast(SQLName)expr !is null) {
            string tableName;
            if (cast(SQLIdentifierExpr)expr !is null) {
                tableName = (cast(SQLIdentifierExpr) expr).normalizedName();
            } else if (cast(SQLPropertyExpr)expr !is null) {
                tableName = (cast(SQLPropertyExpr) expr).normalizedName();
            } else {
                tableName = (cast(Object)(expr)).toString();
            }

            string destTableName = tableMapping.get(tableName);
            if (destTableName is null) {
                if (cast(SQLPropertyExpr)expr !is null) {
                    SQLPropertyExpr propertyExpr = cast(SQLPropertyExpr) expr;
                    string propName = propertyExpr.getName();
                    destTableName = tableMapping.get(propName);
                    if (destTableName is null
                            && propName.length > 2 && charAt(propName, 0) == '`' && charAt(propName, propName.length - 1) == '`') {
                        destTableName = tableMapping.get(propName.substring(1, propName.length - 1));
                    }

                    if (destTableName !is null) {
                        propertyExpr.getOwner().accept(this);
                        print('.');
                        print(destTableName);
                        return;
                    }
                } else if (cast(SQLIdentifierExpr)expr !is null) {
                    bool quote = tableName.length > 2 && charAt(tableName, 0) == '`' && charAt(tableName, tableName.length - 1) == '`';
                    if (quote) {
                        destTableName = tableMapping.get(tableName.substring(1, tableName.length - 1));
                    }
                }
            }
            if (destTableName !is null) {
                tableName = destTableName;
                print0(tableName);
                return;
            }
        }

        SQLIdentifierExpr identifierExpr = cast(SQLIdentifierExpr) expr;
        SQLPropertyExpr propertyExpr = cast(SQLPropertyExpr) expr;

        if (identifierExpr !is null) {
             string name = identifierExpr.getName();
            if (!this.parameterized) {
                if(isEnabled(VisitorFeature.OutputQuotedIdentifier)) {
                    print0(_quotes ~ name ~ _quotes);
                } else {
                    print0(name);
                }
                return;
            }

            bool shardingSupport = this.shardingSupport
                    && this.parameterized;

            if (shardingSupport) {
                string nameUnwrappe = unwrapShardingTable(name);

                if (!(name == nameUnwrappe)) {
                    incrementReplaceCunt();
                }

                print0(nameUnwrappe);
            } else {
                print0(name);
            }
        } else if (propertyExpr !is null) {
            SQLExpr owner = propertyExpr.getOwner();

            printTableSourceExpr(owner);
            print('.');

             string name = propertyExpr.getName();
            if (!this.parameterized) {
                print0(propertyExpr.getName());
                return;
            }

            bool shardingSupport = this.shardingSupport
                    && this.parameterized;

            if (shardingSupport) {
                string nameUnwrappe = unwrapShardingTable(name);

                if (!(name == nameUnwrappe)) {
                    incrementReplaceCunt();
                }

                print0(nameUnwrappe);
            } else {
                print0(name);
            }
        } else {
            expr.accept(this);
        }

    }

    override bool visit(SQLExprTableSource x) {
        printTableSourceExpr(x.getExpr());

        string _alias = x.getAlias();
        if (_alias !is null) {
            print(' ');
            print0(_alias);
        }

        if (isPrettyFormat() && x.hasAfterComment()) {
            print(' ');
            printlnComment(x.getAfterCommentsDirect());
        }

        return false;
    }

    override bool visit(SQLSelectStatement stmt) {
        List!SQLCommentHint headHints = stmt.getHeadHintsDirect();
        if (headHints !is null) {
            foreach(SQLCommentHint hint  ;  headHints) {
                hint.accept(this);
                println();
            }
        }

        SQLSelect select = stmt.getSelect();
        this.visit(select);

        return false;
    }

    override bool visit(SQLVariantRefExpr x) {
        int index = x.getIndex();

        if (index < 0 || inputParameters is null || index >= inputParameters.size()) {
            print0(x.getName());
            return false;
        }

        Object param = inputParameters.get(index);

        SQLObject parent = x.getParent();

        bool _in;
        if (cast(SQLInListExpr)parent !is null) {
            _in = true;
        } else if (cast(SQLBinaryOpExpr)parent !is null) {
            SQLBinaryOpExpr binaryOpExpr = cast(SQLBinaryOpExpr) parent;
            if (binaryOpExpr.getOperator() == SQLBinaryOperator.Equality) {
                _in = true;
            } else {
                _in = false;
            }
        } else {
            _in = false;
        }

        if (_in && cast(Collection!Object)param !is null) {
            bool first = true;
            foreach (Object item ; cast(Collection!Object) param) {
                if (!first) {
                    print0(", ");
                }
                printParameter(item);
                first = false;
            }
        } else {
            printParameter(param);
        }
        return false;
    }

    void printParameter(Object param) {
        if (param is null) {
            print0(ucase ? "NULL" : "null");
            return;
        }

        if (cast(String)param !is null) {
            SQLCharExpr charExpr = new SQLCharExpr(cast(String) param);
            visit(charExpr);
            return;
        }

        if (cast(Number)param !is null //
            || cast(Boolean)param !is null) {
            print0((cast(Object)(param)).toString());
            return;
        }

        Bytes bytesData = cast(Bytes)param;
        if(bytesData !is null) {
            print0(bytesData);
            return;
        }

        //@gxc
        // if (cast(Date)param !is null) {
        //     print(cast(Date) param);
        //     return;
        // }

        // if (cast(InputStream)param !is null) {
        //     print0("'!(InputStream)");
        //     return;
        // }

        // if (cast(Reader)param !is null) {
        //     print0("'!(Reader)");
        //     return;
        // }

        // if (cast(Blob)param !is null) {
        //     print0("'!(Blob)");
        //     return;
        // }

        // if (cast(NClob)param !is null) {
        //     print0("'!(NClob)");
        //     return;
        // }

        // if (cast(Clob)param !is null) {
        //     print0("'!(Clob)");
        //     return;
        // }

        // if (cast(byte[])param !is null) {
        //     byte[] bytes = cast(byte[]) param;
        //     int bytesLen = bytes.length;
        //     char[] chars = new char[bytesLen * 2 + 3];
        //     chars[0] = 'x';
        //     chars[1] = '\'';
        //     for (int i = 0; i < bytes.length; i++) {
        //         int a = bytes[i] & 0xFF;
        //         int b0 = a >> 4;
        //         int b1 = a & 0xf;

        //         chars[i * 2 + 2] = cast(char) (b0 + (b0 < 10 ? 48 : 55)); //hexChars[b0];
        //         chars[i * 2 + 3] = cast(char) (b1 + (b1 < 10 ? 48 : 55));
        //     }
        //     chars[chars.length - 1] = '\'';
        //     print0(new String(chars));
        //     return;
        // }
        warningf("unhandled parameter: %s", typeid(param).name);
        print0("'" ~ typeid(param).name ~ "'");
    }

    override bool visit(SQLDropTableStatement x) {
        print0(ucase ? "DROP " : "drop ");
        List!SQLCommentHint hints = x.getHints();
        if (hints !is null) {
            printAndAccept!SQLCommentHint(hints, " ");
            print(' ');
        }

        if (x.isTemporary()) {
            print0(ucase ? "TEMPORARY TABLE " : "temporary table ");
        } else {
            print0(ucase ? "TABLE " : "table ");
        }

        if (x.isIfExists()) {
            print0(ucase ? "IF EXISTS " : "if exists ");
        }

        printAndAccept!SQLExprTableSource((x.getTableSources()), ", ");

        if (x.isCascade()) {
            printCascade();
        }

        if (x.isRestrict()) {
            print0(ucase ? " RESTRICT" : " restrict");
        }

        if (x.isPurge()) {
            print0(ucase ? " PURGE" : " purge");
        }

        return false;
    }

    protected void printCascade() {
        print0(ucase ? " CASCADE" : " cascade");
    }

    override bool visit(SQLDropViewStatement x) {
        print0(ucase ? "DROP VIEW " : "drop view ");

        if (x.isIfExists()) {
            print0(ucase ? "IF EXISTS " : "if exists ");
        }

        printAndAccept!SQLExprTableSource((x.getTableSources()), ", ");

        if (x.isCascade()) {
            printCascade();
        }
        return false;
    }

    override bool visit(SQLDropMaterializedViewStatement x) {
        print0(ucase ? "DROP VIEW " : "drop view ");

        if (x.isIfExists()) {
            print0(ucase ? "IF EXISTS " : "if exists ");
        }

        x.getName().accept(this);

        return false;
    }

    override bool visit(SQLDropEventStatement x) {
        print0(ucase ? "DROP EVENT " : "drop event ");

        if (x.isIfExists()) {
            print0(ucase ? "IF EXISTS " : "if exists ");
        }

        printExpr(x.getName());
        return false;
    }

    override bool visit(SQLColumnDefinition x) {
        bool parameterized = this.parameterized;
        this.parameterized = false;

        x.getName().accept(this);

        if (x.getDataType() !is null) {
            print(' ');
            x.getDataType().accept(this);
        }

        if (x.getDefaultExpr() !is null) {
            visitColumnDefault(x);
        }

        if (x.isAutoIncrement()) {
            print0(ucase ? " AUTO_INCREMENT" : " auto_increment");
        }

        foreach (SQLColumnConstraint item ; x.getConstraints()) {
            bool newLine = cast(SQLForeignKeyConstraint)item !is null //
                              || cast(SQLPrimaryKey)item !is null //
                              || cast(SQLColumnCheck)item !is null //
                              || cast(SQLColumnCheck)item !is null //
                              || item.getName() !is null;
            if (newLine) {
                this.indentCount++;
                println();
            } else {
                print(' ');
            }

            item.accept(this);

            if (newLine) {
                this.indentCount--;
            }
        }

        SQLExpr generatedAlawsAs = x.getGeneratedAlawsAs();
        if (generatedAlawsAs !is null) {
            print0(ucase ? " GENERATED ALWAYS AS " : " generated always as ");
            printExpr(generatedAlawsAs);
        }

        SQLColumnDefinition.Identity identity = x.getIdentity();
        if (identity !is null) {
            print(' ');
            identity.accept(this);
        }

        if (x.getEnable() !is null) {
            if (x.getEnable().booleanValue()) {
                print0(ucase ? " ENABLE" : " enable");
            }
        }

        if (x.getComment() !is null) {
            print0(ucase ? " COMMENT " : " comment ");
            x.getComment().accept(this);
        }

        this.parameterized = parameterized;

        return false;
    }

    override
    bool visit(SQLColumnDefinition.Identity x) {
        print0(ucase ? "IDENTITY" : "identity");
        if (x.getSeed() !is null) {
            print0(" (");
            print(x.getSeed().intValue());
            print0(", ");
            print(x.getIncrement().intValue());
            print(')');
        }
        return false;
    }

    protected void visitColumnDefault(SQLColumnDefinition x) {
        print0(ucase ? " DEFAULT " : " default ");
        x.getDefaultExpr().accept(this);
    }

    override bool visit(SQLDeleteStatement x) {
        SQLTableSource from = x.getFrom();
        string _alias = x.getAlias();

        if (from is null) {
            print0(ucase ? "DELETE FROM " : "delete from ");
            printTableSourceExpr(x.getTableName());

            if (_alias !is null) {
                print(' ');
                print0(_alias);
            }
        } else {
            print0(ucase ? "DELETE " : "delete ");
            printTableSourceExpr(x.getTableName());
            print0(ucase ? " FROM " : " from ");
            from.accept(this);
        }

        SQLExpr where = x.getWhere();
        if (where !is null) {
            println();
            print0(ucase ? "WHERE " : "where ");
            this.indentCount++;
            where.accept(this);
            this.indentCount--;
        }

        return false;
    }

    override bool visit(SQLCurrentOfCursorExpr x) {
        print0(ucase ? "CURRENT OF " : "current of ");
        printExpr(x.getCursorName());
        return false;
    }

    override bool visit(SQLInsertStatement x) {
        if (x.isUpsert()) {
            print0(ucase ? "UPSERT INTO " : "upsert into ");
        } else {
            print0(ucase ? "INSERT INTO " : "insert into ");
        }

        x.getTableSource().accept(this);

        string columnsString = x.getColumnsString();
        if (columnsString !is null) {
            print0(columnsString);
        } else {
            printInsertColumns(x.getColumns());
        }

        if (!x.getValuesList().isEmpty()) {
            println();
            print0(ucase ? "VALUES " : "values ");
            printAndAccept!ValuesClause((x.getValuesList()), ", ");
        } else {
            if (x.getQuery() !is null) {
                println();
                x.getQuery().accept(this);
            }
        }

        return false;
    }

    void printInsertColumns(List!SQLExpr columns) {
         int size = columns.size();
        if (size > 0) {
            if (size > 5) {
                this.indentCount++;
                println();
            } else {
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
                if (cast(SQLIdentifierExpr)column !is null) {
                    visit(cast(SQLIdentifierExpr) column);
                } else {
                    printExpr(column);
                }

                String dataType = cast(String) column.getAttribute("dataType");
                if (dataType !is null) {
                    print(' ');
                    print(dataType.value());
                }
            }
            print(')');
            if (size > 5) {
                this.indentCount--;
            }
        }
    }

    override bool visit(SQLUpdateSetItem x) {
        printExpr(x.getColumn());
        print0(" = ");
        printExpr(x.getValue());
        return false;
    }

    override bool visit(SQLUpdateStatement x) {
        print0(ucase ? "UPDATE " : "update ");

        printTableSource(x.getTableSource());

        println();
        print0(ucase ? "SET " : "set ");
        for (int i = 0, size = x.getItems().size(); i < size; ++i) {
            if (i != 0) {
                print0(", ");
            }
            SQLUpdateSetItem item = x.getItems().get(i);
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

        return false;
    }

    protected void printTableElements(List!SQLTableElement tableElementList) {
        int size = tableElementList.size();
        if (size == 0) {
            return;
        }

        print0(" (");

        this.indentCount++;
        println();
        for (int i = 0; i < size; ++i) {
            SQLTableElement element = tableElementList.get(i);
            element.accept(this);

            if (i != size - 1) {
                print(',');
            }
            if (this.isPrettyFormat() && element.hasAfterComment()) {
                print(' ');
                printlnComment(element.getAfterCommentsDirect());
            }

            if (i != size - 1) {
                println();
            }
        }
        this.indentCount--;
        println();
        print(')');
    }

    override bool visit(SQLCreateTableStatement x) {
        printCreateTable(x, true);

        Map!(string, SQLObject) options = x.getTableOptions();
        if (options.size() > 0) {
            println();
            print0(ucase ? "WITH (" : "with (");
            int i = 0;
            foreach (string key, SQLObject v ; x.getTableOptions()) {
                if (i > 0) {
                    print0(", ");
                }
                // string key = option.getKey();
                print0(key);

                print0(" = ");

                v.accept(this);
                ++i;
            }
            print(')');
        }

        return false;
    }

    protected void printCreateTable(SQLCreateTableStatement x, bool printSelect) {
        print0(ucase ? "CREATE " : "create ");

         SQLCreateTableStatement.Type tableType = x.getType();
        if (SQLCreateTableStatement.Type.GLOBAL_TEMPORARY == (tableType)) {
            print0(ucase ? "GLOBAL TEMPORARY " : "global temporary ");
        } else if (SQLCreateTableStatement.Type.LOCAL_TEMPORARY == (tableType)) {
            print0(ucase ? "LOCAL TEMPORARY " : "local temporary ");
        }
        print0(ucase ? "TABLE " : "table ");

        if (x.isIfNotExiists()) {
            print0(ucase ? "IF NOT EXISTS " : "if not exists ");
        }

        printTableSourceExpr(x.getName());

        printTableElements(x.getTableElementList());

        SQLExprTableSource inherits = x.getInherits();
        if (inherits !is null) {
            print0(ucase ? " INHERITS (" : " inherits (");
            inherits.accept(this);
            print(')');
        }

        SQLName storedAs = x.getStoredAs();
        if (storedAs !is null) {
            print0(ucase ? " STORE AS " : " store as ");
            printExpr(storedAs);
        }

        SQLSelect select = x.getSelect();
        if (printSelect && select !is null) {
            println();
            print0(ucase ? "AS" : "as");

            println();
            visit(select);
        }
    }

     bool visit(SQLUniqueConstraint x) {
        if (x.getName() !is null) {
            print0(ucase ? "CONSTRAINT " : "constraint ");
            x.getName().accept(this);
            print(' ');
        }

        print0(ucase ? "UNIQUE (" : "unique (");
        List!SQLSelectOrderByItem columns = x.getColumns();
        for (int i = 0, size = columns.size(); i < size; ++i) {
            if (i != 0) {
                print0(", ");
            }
            visit(columns.get(i));
        }
        print(')');
        return false;
    }

    override bool visit(SQLNotNullConstraint x) {
        SQLName name = x.getName();
        if (name !is null) {
            print0(ucase ? "CONSTRAINT " : "constraint ");
            name.accept(this);
            print(' ');
        }
        print0(ucase ? "NOT NULL" : "not null");

        List!SQLCommentHint hints = x.hints;
        if (hints !is null) {
            print(' ');
            foreach (SQLCommentHint hint ; hints) {
                hint.accept(this);
            }
        }

        return false;
    }

    override bool visit(SQLNullConstraint x) {
        SQLName name = x.getName();
    	if (name !is null) {
    		print0(ucase ? "CONSTRAINT " : "constraint ");
            name.accept(this);
    		print(' ');
    	}
    	print0(ucase ? "NULL" : "null");
    	return false;
    }

    override
    bool visit(SQLUnionQuery x) {
        SQLUnionOperator operator = x.getOperator();
        SQLSelectQuery left = x.getLeft();
        SQLSelectQuery right = x.getRight();

        bool bracket = x.isBracket() && !( cast(SQLUnionQueryTableSource)x.getParent() !is null);

        SQLOrderBy orderBy = x.getOrderBy();
        if ((!bracket)
                && cast(SQLUnionQuery)left !is null
                && (cast(SQLUnionQuery) left).getOperator() == operator
                && !right.isBracket()
                && orderBy is null) {

            SQLUnionQuery leftUnion = cast(SQLUnionQuery) left;

            List!SQLSelectQuery rights = new ArrayList!SQLSelectQuery();
            rights.add(right);

            for (;;) {
                SQLSelectQuery leftLeft = leftUnion.getLeft();
                SQLSelectQuery leftRight = leftUnion.getRight();

                if ((!leftUnion.isBracket())
                        && leftUnion.getOrderBy() is null
                        && (!leftLeft.isBracket())
                        && (!leftRight.isBracket())
                        && cast(SQLUnionQuery)leftLeft !is null
                        && (cast(SQLUnionQuery) leftLeft).getOperator() == operator) {
                    rights.add(leftRight);
                    leftUnion =  cast(SQLUnionQuery) leftLeft;
                    continue;
                } else {
                    rights.add(leftRight);
                    rights.add(leftLeft);
                }
                break;
            }

            for (int i = rights.size() - 1; i >= 0; i--) {
                SQLSelectQuery item = rights.get(i);
                item.accept(this);

                if (i > 0) {
                    println();
                    print0(ucase ? operator.name : operator.name_lcase);
                    println();
                }
            }
            return false;
        }

        if (bracket) {
            print('(');
        }

        if (left !is null) {
            for (;;) {
                if (typeid(left) == typeid(SQLUnionQuery)) {
                    SQLUnionQuery leftUnion = cast(SQLUnionQuery) left;
                    SQLSelectQuery leftLeft = leftUnion.getLeft();
                    SQLSelectQuery leftRigt = leftUnion.getRight();
                    if ((!leftUnion.isBracket())
                            && cast(SQLSelectQueryBlock)leftUnion.getRight() !is null
                            && leftUnion.getLeft() !is null
                            && leftUnion.getOrderBy() is null)
                    {
                        if (typeid(leftLeft) == typeid(SQLUnionQuery)) {
                            visit(cast(SQLUnionQuery) leftLeft);
                        } else {
                            printQuery(leftLeft);
                        }
                        println();
                        print0(ucase ? leftUnion.getOperator().name : leftUnion.getOperator().name_lcase);
                        println();
                        leftRigt.accept(this);
                    } else {
                        visit(leftUnion);
                    }
                } else {
                    left.accept(this);
                }
                break;
            }
        }

        if (right is null) {
            return false;
        }

        println();
        print0(ucase ? operator.name : operator.name_lcase);
        println();

        bool needParen = false;
        if (orderBy !is null
                && (!right.isBracket()) && cast(SQLSelectQueryBlock)right !is null) {
            SQLSelectQueryBlock rightQuery = cast(SQLSelectQueryBlock) right;
            if (rightQuery.getOrderBy() !is null || rightQuery.getLimit() !is null) {
                needParen = true;
            }
        }

        if (needParen) {
            print('(');
            right.accept(this);
            print(')');
        } else {
            right.accept(this);
        }

        if (orderBy !is null) {
            println();
            orderBy.accept(this);
        }

        SQLLimit limit = x.getLimit();
        if (limit !is null) {
            println();
            limit.accept(this);
        }

        if (bracket) {
            print(')');
        }

        return false;
    }

    override
    bool visit(SQLUnaryExpr x) {
        print0(x.getOperator().name);

        SQLExpr expr = x.getExpr();

        switch (x.getOperator().name) {
            case SQLUnaryOperator.BINARY.name:
            case SQLUnaryOperator.Prior.name:
            case SQLUnaryOperator.ConnectByRoot.name:
                print(' ');
                expr.accept(this);
                return false;
            default:
                break;
        }

        if (cast(SQLBinaryOpExpr)expr !is null) {
            print('(');
            expr.accept(this);
            print(')');
        } else if (cast(SQLUnaryExpr)expr !is null) {
            print('(');
            expr.accept(this);
            print(')');
        } else {
            expr.accept(this);
        }
        return false;
    }

    override
    bool visit(SQLHexExpr x) {
        if (this.parameterized) {
            print('?');
            incrementReplaceCunt();

            if(this.parameters !is null){
                ExportParameterVisitorUtils.exportParameter(this.parameters, x);
            }
            return false;
        }

        print0("0x");
        print0(x.getHex());

        String charset = cast(String) x.getAttribute("USING");
        if (charset !is null) {
            print0(ucase ? " USING " : " using ");
            print0(charset.value());
        }

        return false;
    }

    override
    bool visit(SQLSetStatement x) {
        bool printSet = x.getAttribute("parser.set") == Boolean.TRUE || !DBType.ORACLE.opEquals(dbType);
        if (printSet) {
            print0(ucase ? "SET " : "set ");
        }
        SQLSetStatement.Option option = x.getOption();
        if (option.name.length != 0) {
            print(option.name());
            print(' ');
        }

        printAndAccept!SQLAssignItem((x.getItems()), ", ");

        if (x.getHints() !is null && x.getHints().size() > 0) {
            print(' ');
            printAndAccept!SQLCommentHint((x.getHints()), " ");
        }

        return false;
    }

    override
    bool visit(SQLAssignItem x) {
        x.getTarget().accept(this);
        print0(" = ");
        x.getValue().accept(this);
        return false;
    }

    override
    bool visit(SQLCallStatement x) {
        if (x.isBrace()) {
            print('{');
        }
        if (x.getOutParameter() !is null) {
            x.getOutParameter().accept(this);
            print0(" = ");
        }

        print0(ucase ? "CALL " : "call ");
        x.getProcedureName().accept(this);
        print('(');

        printAndAccept!SQLExpr((x.getParameters()), ", ");
        print(')');
        if (x.isBrace()) {
            print('}');
        }
        return false;
    }

    override
    bool visit(SQLJoinTableSource x) {
        SQLTableSource left = x.getLeft();

        if (cast(SQLJoinTableSource)left !is null
                && (cast(SQLJoinTableSource) left).getJoinType() == SQLJoinTableSource.JoinType.COMMA
                && x.getJoinType() != SQLJoinTableSource.JoinType.COMMA
                && !DBType.POSTGRESQL.opEquals(dbType)) {
            print('(');
            printTableSource(left);
            print(')');
        } else {
            printTableSource(left);
        }
        this.indentCount++;

        if (x.getJoinType() == SQLJoinTableSource.JoinType.COMMA) {
            print(',');
        } else {
            println();

            if (x.isNatural()) {
                print0(ucase ? "NATURAL " : "natural ");
            }

            printJoinType(x.getJoinType());
        }
        print(' ');

        SQLTableSource right = x.getRight();
        if (cast(SQLJoinTableSource)right !is null) {
            print('(');
            printTableSource(right);
            print(')');
        } else {
            printTableSource(right);
        }

        SQLExpr condition = x.getCondition();
        if (condition !is null) {
            bool newLine = false;

            if(cast(SQLSubqueryTableSource)right !is null) {
                newLine = true;
            } else if (cast(SQLBinaryOpExpr)condition !is null) {
                SQLBinaryOperator op = (cast(SQLBinaryOpExpr) condition).getOperator();
                if (op == SQLBinaryOperator.BooleanAnd || op == SQLBinaryOperator.BooleanOr) {
                    newLine = true;
                }
            } else if (cast(SQLBinaryOpExprGroup)condition !is null) {
                newLine = true;
            }
            if (newLine) {
                println();
            } else {
                print(' ');
            }
            this.indentCount++;
            print0(ucase ? "ON " : "on ");
            printExpr(condition);
            this.indentCount--;
        }

        if (x.getUsing().size() > 0) {
            print0(ucase ? " USING (" : " using (");
            printAndAccept!SQLExpr((x.getUsing()), ", ");
            print(')');
        }

        if (x.getAlias() !is null) {
            print0(ucase ? " AS " : " as ");
            print0(x.getAlias());
        }

        this.indentCount--;

        return false;
    }

    protected void printJoinType(SQLJoinTableSource.JoinType joinType) {
        print0(ucase ? joinType.name : joinType.name_lcase);
    }

    // static {
    //     for (int len = 0; len < variantValuesCache.length; ++len) {
    //         StringBuilder buf = new StringBuilder();
    //         buf.append('(');
    //         for (int i = 0; i < len; ++i) {
    //             if (i != 0) {
    //                 if (i % 5 == 0) {
    //                     buf.append("\n\t\t");
    //                 }
    //                 buf.append(", ");
    //             }
    //             buf.append('?');
    //         }
    //         buf.append(')');
    //         variantValuesCache[len] = buf.toString();
    //     }
    // }

    override
    bool visit(ValuesClause x) {
        if ((!this.parameterized)
                && isEnabled(VisitorFeature.OutputUseInsertValueClauseOriginalString)
                && x.getOriginalString() !is null) {
            print0(x.getOriginalString());
            return false;
        }

        int xReplaceCount = x.getReplaceCount();
         List!SQLExpr values = x.getValues();

        this.replaceCount += xReplaceCount;

        if (xReplaceCount == values.size() && xReplaceCount < variantValuesCache.length) {
            string variantValues = variantValuesCache[xReplaceCount];
            print0(variantValues);
            return false;
        }

        print('(');
        this.indentCount++;


        for (int i = 0, size = values.size(); i < size; ++i) {
            if (i != 0) {
                if (i % 5 == 0) {
                    println();
                }
                print0(", ");
            }

            SQLExpr expr = values.get(i);
            if (cast(SQLIntegerExpr)expr !is null) {
                printInteger(cast(SQLIntegerExpr) expr, parameterized);
            } else if (cast(SQLCharExpr)expr !is null) {
                visit(cast(SQLCharExpr) expr);
            } else if (cast(SQLBooleanExpr)expr !is null) {
                visit(cast(SQLBooleanExpr) expr);
            } else if (cast(SQLNumberExpr)expr !is null) {
                visit(cast(SQLNumberExpr) expr);
            } else if (cast(SQLNullExpr)expr !is null) {
                visit(cast(SQLNullExpr) expr);
            } else if (cast(SQLVariantRefExpr)expr !is null) {
                visit(cast(SQLVariantRefExpr) expr);
            } else if (cast(SQLNCharExpr)expr !is null) {
                visit(cast(SQLNCharExpr) expr);
            } else {
                expr.accept(this);
            }
        }

        this.indentCount--;
        print(')');
        return false;
    }

    override
    bool visit(SQLSomeExpr x) {
        print0(ucase ? "SOME (" : "some (");
        this.indentCount++;
        println();
        x.getSubQuery().accept(this);
        this.indentCount--;
        println();
        print(')');
        return false;
    }

    override
    bool visit(SQLAnyExpr x) {
        print0(ucase ? "ANY (" : "any (");
        this.indentCount++;
        println();
        x.getSubQuery().accept(this);
        this.indentCount--;
        println();
        print(')');
        return false;
    }

    override
    bool visit(SQLAllExpr x) {
        print0(ucase ? "ALL (" : "all (");
        this.indentCount++;
        println();
        x.getSubQuery().accept(this);
        this.indentCount--;
        println();
        print(')');
        return false;
    }

    override
    bool visit(SQLInSubQueryExpr x) {
        x.getExpr().accept(this);
        if (x.isNot()) {
            print0(ucase ? " NOT IN (" : " not in (");
        } else {
            print0(ucase ? " IN (" : " in (");
        }

        this.indentCount++;
        println();
        x.getSubQuery().accept(this);
        this.indentCount--;
        println();
        print(')');

        return false;
    }

    override
    bool visit(SQLListExpr x) {
        print('(');
        printAndAccept!SQLExpr((x.getItems()), ", ");
        print(')');

        return false;
    }

    override
    bool visit(SQLSubqueryTableSource x) {
        print('(');
        this.indentCount++;
        println();
        this.visit(x.getSelect());
        this.indentCount--;
        println();
        print(')');

        if (x.getAlias() !is null) {
            print(' ');
            print0(x.getAlias());
        }

        return false;
    }

    override
    bool visit(SQLTruncateStatement x) {
        print0(ucase ? "TRUNCATE TABLE " : "truncate table ");
        printAndAccept!SQLExprTableSource((x.getTableSources()), ", ");
        
        if (x.isDropStorage()) {
            print0(ucase ? " DROP STORAGE" : " drop storage");    
        }
        
        if (x.isReuseStorage()) {
            print0(ucase ? " REUSE STORAGE" : " reuse storage");    
        }
        
        if (x.isIgnoreDeleteTriggers()) {
            print0(ucase ? " IGNORE DELETE TRIGGERS" : " ignore delete triggers");    
        }
        
        if (x.isRestrictWhenDeleteTriggers()) {
            print0(ucase ? " RESTRICT WHEN DELETE TRIGGERS" : " restrict when delete triggers");    
        }
        
        if (x.isContinueIdentity()) {
            print0(ucase ? " CONTINUE IDENTITY" : " continue identity");
        }
        
        if (x.isImmediate()) {
            print0(ucase ? " IMMEDIATE" : " immediate");    
        }
        
        return false;
    }

    override
    bool visit(SQLDefaultExpr x) {
        print0(ucase ? "DEFAULT" : "default");
        return false;
    }

    override
    void endVisit(SQLCommentStatement x) {

    }

    override
    bool visit(SQLCommentStatement x) {
        print0(ucase ? "COMMENT ON " : "comment on ");
        if (x.getType().name.length != 0) {
            print0(x.getType().name);
            print(' ');
        }
        x.getOn().accept(this);

        print0(ucase ? " IS " : " is ");
        x.getComment().accept(this);

        return false;
    }

    override
    bool visit(SQLUseStatement x) {
        print0(ucase ? "USE " : "use ");
        x.getDatabase().accept(this);
        return false;
    }

    protected bool isOdps() {
        return DBType.ODPS.opEquals(dbType);
    }

    override
    bool visit(SQLAlterTableAddColumn x) {
        bool odps = isOdps();
        if (odps) {
            print0(ucase ? "ADD COLUMNS (" : "add columns (");
        } else {
            print0(ucase ? "ADD (" : "add (");
        }
        printAndAccept!SQLColumnDefinition((x.getColumns()), ", ");
        print(')');
        return false;
    }

    override
    bool visit(SQLAlterTableDropColumnItem x) {
        print0(ucase ? "DROP COLUMN " : "drop column ");
        this.printAndAccept!SQLName((x.getColumns()), ", ");

        if (x.isCascade()) {
            print0(ucase ? " CASCADE" : " cascade");
        }
        return false;
    }

    override
    void endVisit(SQLAlterTableAddColumn x) {

    }

    override
    bool visit(SQLDropIndexStatement x) {
        print0(ucase ? "DROP INDEX " : "drop index ");
        x.getIndexName().accept(this);

        SQLExprTableSource table = x.getTableName();
        if (table !is null) {
            print0(ucase ? " ON " : " on ");
            table.accept(this);
        }

        SQLExpr algorithm = x.getAlgorithm();
        if (algorithm !is null) {
            print0(ucase ? " ALGORITHM " : " algorithm ");
            algorithm.accept(this);
        }

        SQLExpr lockOption = x.getLockOption();
        if (lockOption !is null) {
            print0(ucase ? " LOCK " : " lock ");
            lockOption.accept(this);
        }

        return false;
    }

    override
    bool visit(SQLDropLogFileGroupStatement x) {
        print0(ucase ? "DROP LOGFILE GROUP " : "drop logfile group ");
        x.getName().accept(this);

        return false;
    }

    override
    bool visit(SQLDropServerStatement x) {
        print0(ucase ? "DROP SERVER " : "drop server ");
        if (x.isIfExists()) {
            print0(ucase ? "IF EXISTS " : "if exists ");
        }
        x.getName().accept(this);

        return false;
    }

    override
    bool visit(SQLDropTypeStatement x) {
        print0(ucase ? "DROP TYPE " : "drop type ");
        if (x.isIfExists()) {
            print0(ucase ? "IF EXISTS " : "if exists ");
        }
        x.getName().accept(this);

        return false;
    }

    override
    bool visit(SQLDropSynonymStatement x) {
        if (x.isPublic()) {
            print0(ucase ? "DROP PUBLIC SYNONYM " : "drop synonym ");
        } else {
            print0(ucase ? "DROP SYNONYM " : "drop synonym ");
        }

        if (x.isIfExists()) {
            print0(ucase ? "IF EXISTS " : "if exists ");
        }

        x.getName().accept(this);

        if (x.isForce()) {
            print0(ucase ? " FORCE" : " force");
        }

        return false;
    }

    override
    bool visit(SQLSavePointStatement x) {
        print0(ucase ? "SAVEPOINT" : "savepoint");
        if (x.getName() !is null) {
            print(' ');
            x.getName().accept(this);
        }
        return false;
    }

    override
    bool visit(SQLReleaseSavePointStatement x) {
        print0(ucase ? "RELEASE SAVEPOINT " : "release savepoint ");
        x.getName().accept(this);
        return false;
    }

    override
    bool visit(SQLRollbackStatement x) {
        print0(ucase ? "ROLLBACK" : "rollback");
        if (x.getTo() !is null) {
            print0(ucase ? " TO " : " to ");
            x.getTo().accept(this);
        }
        return false;
    }

    override bool visit(SQLCommentHint x) {
        if (x.hasBeforeComment()) {
            printlnComment(x.getBeforeCommentsDirect());
            print0(" ");
        }

        print0("/*");
        print0(x.getText());
        print0("*/");
        return false;
    }

    override
    bool visit(SQLCreateDatabaseStatement x) {
        print0(ucase ? "CREATE DATABASE " : "create database ");
        if (x.isIfNotExists()) {
            print0(ucase ? "IF NOT EXISTS " : "if not exists ");
        }
        x.getName().accept(this);

        if (x.getCharacterSet() !is null) {
            print0(ucase ? " CHARACTER SET " : " character set ");
            print0(x.getCharacterSet());
        }

        if (x.getCollate() !is null) {
            print0(ucase ? " COLLATE " : " collate ");
            print0(x.getCollate());
        }

        return false;
    }

    override
    bool visit(SQLAlterViewStatement x) {
        print0(ucase ? "ALTER " : "atler ");

        this.indentCount++;
        string algorithm = x.getAlgorithm();
        if (algorithm !is null && algorithm.length > 0) {
            print0(ucase ? "ALGORITHM = " : "algorithm = ");
            print0(algorithm);
            println();
        }

        SQLName definer = x.getDefiner();
        if (definer !is null) {
            print0(ucase ? "DEFINER = " : "definer = ");
            definer.accept(this);
            println();
        }

        string sqlSecurity = x.getSqlSecurity();
        if (sqlSecurity !is null && sqlSecurity.length > 0) {
            print0(ucase ? "SQL SECURITY = " : "sql security = ");
            print0(sqlSecurity);
            println();
        }

        this.indentCount--;

        print0(ucase ? "VIEW " : "view ");

        if (x.isIfNotExists()) {
            print0(ucase ? "IF NOT EXISTS " : "if not exists ");
        }

        x.getTableSource().accept(this);

        if (x.getColumns().size() > 0) {
            print0(" (");
            this.indentCount++;
            println();
            for (int i = 0; i < x.getColumns().size(); ++i) {
                if (i != 0) {
                    print0(", ");
                    println();
                }
                x.getColumns().get(i).accept(this);
            }
            this.indentCount--;
            println();
            print(')');
        }

        if (x.getComment() !is null) {
            println();
            print0(ucase ? "COMMENT " : "comment ");
            x.getComment().accept(this);
        }

        println();
        print0(ucase ? "AS" : "as");
        println();

        x.getSubQuery().accept(this);

        if (x.isWithCheckOption()) {
            println();
            print0(ucase ? "WITH CHECK OPTION" : "with check option");
        }

        return false;
    }

    override
    bool visit(SQLCreateViewStatement x) {
        print0(ucase ? "CREATE " : "create ");
        if (x.isOrReplace()) {
            print0(ucase ? "OR REPLACE " : "or replace ");
        }

        this.indentCount++;
        string algorithm = x.getAlgorithm();
        if (algorithm !is null && algorithm.length > 0) {
            print0(ucase ? "ALGORITHM = " : "algorithm = ");
            print0(algorithm);
            println();
        }

        SQLName definer = x.getDefiner();
        if (definer !is null) {
            print0(ucase ? "DEFINER = " : "definer = ");
            definer.accept(this);
            println();
        }

        string sqlSecurity = x.getSqlSecurity();
        if (sqlSecurity !is null && sqlSecurity.length > 0) {
            print0(ucase ? "SQL SECURITY = " : "sql security = ");
            print0(sqlSecurity);
            println();
        }

        this.indentCount--;

        print0(ucase ? "VIEW " : "view ");

        if (x.isIfNotExists()) {
            print0(ucase ? "IF NOT EXISTS " : "if not exists ");
        }

        x.getTableSource().accept(this);

        if (x.getColumns().size() > 0) {
            print0(" (");
            this.indentCount++;
            println();
            for (int i = 0; i < x.getColumns().size(); ++i) {
                if (i != 0) {
                    print0(", ");
                    println();
                }
                x.getColumns().get(i).accept(this);
            }
            this.indentCount--;
            println();
            print(')');
        }

        if (x.getComment() !is null) {
            println();
            print0(ucase ? "COMMENT " : "comment ");
            x.getComment().accept(this);
        }

        println();
        print0(ucase ? "AS" : "as");
        println();

        x.getSubQuery().accept(this);

        if (x.isWithCheckOption()) {
            println();
            print0(ucase ? "WITH CHECK OPTION" : "with check option");
        }

        return false;
    }

    override bool visit(SQLCreateViewStatement.Column x) {
        x.getExpr().accept(this);

        if (x.getComment() !is null) {
            print0(ucase ? " COMMENT " : " comment ");
            x.getComment().accept(this);
        }

        return false;
    }

    override
    bool visit(SQLAlterTableDropIndex x) {
        print0(ucase ? "DROP INDEX " : "drop index ");
        x.getIndexName().accept(this);
        return false;
    }

    override
    bool visit(SQLOver x) {
        print0(ucase ? "OVER (" : "over (");
        if (x.getPartitionBy().size() > 0) {
            print0(ucase ? "PARTITION BY " : "partition by ");
            printAndAccept!SQLExpr((x.getPartitionBy()), ", ");
            print(' ');
        }
        
        if (x.getOrderBy() !is null) {
            x.getOrderBy().accept(this);
        }
        
        if (x.getOf() !is null) {
            print0(ucase ? " OF " : " of ");
            x.getOf().accept(this);
        }

        if (x.getWindowing() !is null) {
            if (SQLOver.WindowingType.ROWS == (x.getWindowingType())) {
                print0(ucase ? " ROWS " : " rows ");
            } else if (SQLOver.WindowingType.RANGE == (x.getWindowingType())) {
                print0(ucase ? " RANGE " : " range ");
            }

            printWindowingExpr(x.getWindowing());

            if (x.isWindowingPreceding()) {
                print0(ucase ? " PRECEDING" : " preceding");
            } else if (x.isWindowingFollowing()) {
                print0(ucase ? " FOLLOWING" : " following");
            }
        }

        if (x.getWindowingBetweenBegin() !is null) {
            if (SQLOver.WindowingType.ROWS == (x.getWindowingType())) {
                print0(ucase ? " ROWS BETWEEN " : " rows between ");
            } else if (SQLOver.WindowingType.RANGE == (x.getWindowingType())) {
                print0(ucase ? " RANGE BETWEEN " : " range between ");
            }

            printWindowingExpr(x.getWindowingBetweenBegin());

            if (x.isWindowingBetweenBeginPreceding()) {
                print0(ucase ? " PRECEDING" : " preceding");
            } else if (x.isWindowingBetweenBeginFollowing()) {
                print0(ucase ? " FOLLOWING" : " following");
            }

            print0(ucase ? " AND " : " and ");

            printWindowingExpr(x.getWindowingBetweenEnd());

            if (x.isWindowingBetweenEndPreceding()) {
                print0(ucase ? " PRECEDING" : " preceding");
            } else if (x.isWindowingBetweenEndFollowing()) {
                print0(ucase ? " FOLLOWING" : " following");
            }
        }
        
        print(')');
        return false;
    }

    void printWindowingExpr(SQLExpr expr) {
        if (cast(SQLIdentifierExpr)expr !is null) {
            string ident = (cast(SQLIdentifierExpr) expr).getName();
            print0(ucase ? ident : toLower(ident));
        } else {
            expr.accept(this);
        }
    }
    
    override
    bool visit(SQLKeep x) {
        if (x.getDenseRank() == SQLKeep.DenseRank.FIRST) {
            print0(ucase ? "KEEP (DENSE_RANK FIRST " : "keep (dense_rank first ");    
        } else {
            print0(ucase ? "KEEP (DENSE_RANK LAST " : "keep (dense_rank last ");
        }
        
        x.getOrderBy().accept(this);
        print(')');
        
        return false;
    }

    override
    bool visit(SQLColumnPrimaryKey x) {
        if (x.getName() !is null) {
            print0(ucase ? "CONSTRAINT " : "constraint ");
            x.getName().accept(this);
            print(' ');
        }
        print0(ucase ? "PRIMARY KEY" : "primary key");
        return false;
    }

    override
    bool visit(SQLColumnUniqueKey x) {
        if (x.getName() !is null) {
            print0(ucase ? "CONSTRAINT " : "constraint ");
            x.getName().accept(this);
            print(' ');
        }
        print0(ucase ? "UNIQUE" : "unique");
        return false;
    }

    override
    bool visit(SQLColumnCheck x) {
        if (x.getName() !is null) {
            print0(ucase ? "CONSTRAINT " : "constraint ");
            x.getName().accept(this);
            print(' ');
        }
        print0(ucase ? "CHECK (" : "check (");
        x.getExpr().accept(this);
        print(')');

        if (x.getEnable() !is null) {
            if (x.getEnable().booleanValue()) {
                print0(ucase ? " ENABLE" : " enable");
            } else {
                print0(ucase ? " DISABLE" : " disable");
            }
        }
        return false;
    }

    override
    bool visit(SQLWithSubqueryClause x) {
        print0(ucase ? "WITH " : "with ");
        if (x.getRecursive() == true) {
            print0(ucase ? "RECURSIVE " : "recursive ");
        }
        this.indentCount++;
        printlnAndAccept!(SQLWithSubqueryClause.Entry)((x.getEntries()), ", ");
        this.indentCount--;
        return false;
    }

    override
    bool visit(SQLWithSubqueryClause.Entry x) {
        print0(x.getAlias());

        if (x.getColumns().size() > 0) {
            print0(" (");
            printAndAccept!SQLName((x.getColumns()), ", ");
            print(')');
        }
        print(' ');
        print0(ucase ? "AS " : "as ");
        print('(');
        this.indentCount++;
        println();
        SQLSelect query = x.getSubQuery();
        if (query !is null) {
            query.accept(this);
        } else {
            x.getReturningStatement().accept(this);
        }
        this.indentCount--;
        println();
        print(')');

        return false;
    }

    override
    bool visit(SQLAlterTableAlterColumn x) {
        bool odps = isOdps();
        if (odps) {
            print0(ucase ? "CHANGE COLUMN " : "change column ");
        } else {
            print0(ucase ? "ALTER COLUMN " : "alter column ");
        }
        x.getColumn().accept(this);

        if (x.isSetNotNull()) { // postgresql
            print0(ucase ? " SET NOT NULL" : " set not null");
        }

        if (x.isDropNotNull()) { // postgresql
            print0(ucase ? " DROP NOT NULL" : " drop not null");
        }

        if (x.getSetDefault() !is null) { // postgresql
            print0(ucase ? " SET DEFAULT " : " set default ");
            x.getSetDefault().accept(this);
        }

         SQLDataType dataType = x.getDataType();
        if (dataType !is null) {
            print0(ucase ? " SET DATA TYPE " : " set data type ");
            dataType.accept(this);
        }

        if (x.isDropDefault()) { // postgresql
            print0(ucase ? " DROP DEFAULT" : " drop default");
        }

        return false;
    }

    override
    bool visit(SQLCheck x) {
        if (x.getName() !is null) {
            print0(ucase ? "CONSTRAINT " : "constraint ");
            x.getName().accept(this);
            print(' ');
        }
        print0(ucase ? "CHECK (" : "check (");
        this.indentCount++;
        x.getExpr().accept(this);
        this.indentCount--;
        print(')');
        return false;
    }

    override
    bool visit(SQLAlterTableDropForeignKey x) {
        print0(ucase ? "DROP FOREIGN KEY " : "drop foreign key ");
        x.getIndexName().accept(this);
        return false;
    }

    override
    bool visit(SQLAlterTableDropPrimaryKey x) {
        print0(ucase ? "DROP PRIMARY KEY" : "drop primary key");
        return false;
    }

    override
    bool visit(SQLAlterTableDropKey x) {
        print0(ucase ? "DROP KEY " : "drop key ");
        x.getKeyName().accept(this);
        return false;
    }

    override
    bool visit(SQLAlterTableEnableKeys x) {
        print0(ucase ? "ENABLE KEYS" : "enable keys");
        return false;
    }

    override
    bool visit(SQLAlterTableDisableKeys x) {
        print0(ucase ? "DISABLE KEYS" : "disable keys");
        return false;
    }

    override bool visit(SQLAlterTableDisableConstraint x) {
        print0(ucase ? "DISABLE CONSTRAINT " : "disable constraint ");
        x.getConstraintName().accept(this);
        return false;
    }

    override bool visit(SQLAlterTableEnableConstraint x) {
        print0(ucase ? "ENABLE CONSTRAINT " : "enable constraint ");
        x.getConstraintName().accept(this);
        return false;
    }

    override
    bool visit(SQLAlterTableDropConstraint x) {
        print0(ucase ? "DROP CONSTRAINT " : "drop constraint ");
        x.getConstraintName().accept(this);
        return false;
    }

    override
    bool visit(SQLAlterTableStatement x) {
        print0(ucase ? "ALTER TABLE " : "alter table ");
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
        this.indentCount--;

        if (x.isMergeSmallFiles()) {
            print0(ucase ? " MERGE SMALLFILES" : " merge smallfiles");
        }
        return false;
    }

    override
    bool visit(SQLExprHint x) {
        x.getExpr().accept(this);
        return false;
    }

    override
    bool visit(SQLCreateIndexStatement x) {
        print0(ucase ? "CREATE " : "create ");
        if (x.getType() !is null) {
            print0(x.getType());
            print(' ');
        }

        print0(ucase ? "INDEX " : "index ");

        x.getName().accept(this);
        print0(ucase ? " ON " : " on ");
        x.getTable().accept(this);
        print0(" (");
        printAndAccept!SQLSelectOrderByItem((x.getItems()), ", ");
        print(')');

        // for mysql
        if (x.getUsing() !is null) {
            print0(ucase ? " USING " : " using ");
            // ;
            print0(x.getUsing());
        }

        SQLExpr comment = x.getComment();
        if (comment !is null) {
            print0(ucase ? " COMMENT " : " comment ");
            comment.accept(this);
        }

        return false;
    }

    override
    bool visit(SQLUnique x) {
        SQLName name = x.getName();
        if (name !is null) {
            print0(ucase ? "CONSTRAINT " : "constraint ");
            name.accept(this);
            print(' ');
        }

        print0(ucase ? "UNIQUE (" : "unique (");
        printAndAccept!SQLSelectOrderByItem((x.getColumns()), ", ");
        print(')');
        return false;
    }

    override
    bool visit(SQLPrimaryKeyImpl x) {
        SQLName name = x.getName();
        if (name !is null) {
            print0(ucase ? "CONSTRAINT " : "constraint ");
            name.accept(this);
            print(' ');
        }

        print0(ucase ? "PRIMARY KEY " : "primary key ");

        if (x.isClustered()) {
            print0(ucase ? "CLUSTERED " : "clustered ");
        }

        print('(');
        printAndAccept!SQLSelectOrderByItem((x.getColumns()), ", ");
        print(')');

        return false;
    }

    override
    bool visit(SQLAlterTableRenameColumn x) {
        print0(ucase ? "RENAME COLUMN " : "rename column ");
        x.getColumn().accept(this);
        print0(ucase ? " TO " : " to ");
        x.getTo().accept(this);
        return false;
    }

    override
    bool visit(SQLColumnReference x) {
        SQLName name = x.getName();
        if (name !is null) {
            print0(ucase ? "CONSTRAINT " : "constraint ");
            name.accept(this);
            print(' ');
        }

        print0(ucase ? "REFERENCES " : "references ");
        x.getTable().accept(this);
        print0(" (");
        printAndAccept!SQLName((x.getColumns()), ", ");
        print(')');

        SQLForeignKeyImpl.Match match = x.getReferenceMatch();
        if (match.name.length != 0) {
            print0(ucase ? " MATCH " : " match ");
            print0(ucase ? match.name : match.name_lcase);
        }

        if (x.getOnDelete().name.length != 0) {
            print0(ucase ? " ON DELETE " : " on delete ");
            print0(ucase ? x.getOnDelete().name : x.getOnDelete().name_lcase);
        }

        if (x.getOnUpdate().name.length != 0) {
            print0(ucase ? " ON UPDATE " : " on update ");
            print0(ucase ? x.getOnUpdate().name : x.getOnUpdate().name_lcase);
        }

        return false;
    }

    override
    bool visit(SQLForeignKeyImpl x) {
        if (x.getName() !is null) {
            print0(ucase ? "CONSTRAINT " : "constraint ");
            x.getName().accept(this);
            print(' ');
        }

        print0(ucase ? "FOREIGN KEY (" : "foreign key (");
        printAndAccept!SQLName((x.getReferencingColumns()), ", ");
        print(')');

        this.indentCount++;
        println();
        print0(ucase ? "REFERENCES " : "references ");
        x.getReferencedTableName().accept(this);

        if (x.getReferencedColumns().size() > 0) {
            print0(" (");
            printAndAccept!SQLName((x.getReferencedColumns()), ", ");
            print(')');
        }

        if (x.isOnDeleteCascade()) {
            println();
            print0(ucase ? "ON DELETE CASCADE" : "on delete cascade");
        } else if (x.isOnDeleteSetNull()) {
            print0(ucase ? "ON DELETE SET NULL" : "on delete set null");
        }
        this.indentCount--;
        return false;
    }

    override
    bool visit(SQLDropSequenceStatement x) {
        print0(ucase ? "DROP SEQUENCE " : "drop sequence ");
        if (x.isIfExists()) {
            print0(ucase ? "IF EXISTS " : "if exists ");
        }
        x.getName().accept(this);
        return false;
    }

    override
    void endVisit(SQLDropSequenceStatement x) {

    }

    override
    bool visit(SQLDropTriggerStatement x) {
        print0(ucase ? "DROP TRIGGER " : "drop trigger ");
        if (x.isIfExists()) {
            print0(ucase ? "IF EXISTS " : "if exists ");
        }

        x.getName().accept(this);
        return false;
    }

    override
    void endVisit(SQLDropUserStatement x) {

    }

    override
    bool visit(SQLDropUserStatement x) {
        print0(ucase ? "DROP USER " : "drop user ");
        printAndAccept!SQLExpr((x.getUsers()), ", ");
        return false;
    }

    override
    bool visit(SQLExplainStatement x) {
        print0(ucase ? "EXPLAIN" : "explain");
        if (x.getHints() !is null && x.getHints().size() > 0) {
            print(' ');
            printAndAccept!SQLCommentHint((x.getHints()), " ");
        }

        if (x.getType() !is null) {
            print(' ');
            print0(x.getType());
        }
        println();
        x.getStatement().accept(this);
        return false;
    }

    protected void printGrantPrivileges(SQLGrantStatement x) {

    }

    override
    bool visit(SQLGrantStatement x) {
        print0(ucase ? "GRANT " : "grant ");
        printAndAccept!SQLExpr((x.getPrivileges()), ", ");

        printGrantOn(x);

        if (x.getTo() !is null) {
            print0(ucase ? " TO " : " to ");
            x.getTo().accept(this);
        }

        bool _with = false;
        if (x.getMaxQueriesPerHour() !is null) {
            if (!_with) {
                print0(ucase ? " WITH" : " with");
                _with = true;
            }
            print0(ucase ? " MAX_QUERIES_PER_HOUR " : " max_queries_per_hour ");
            x.getMaxQueriesPerHour().accept(this);
        }

        if (x.getMaxUpdatesPerHour() !is null) {
            if (!_with) {
                print0(ucase ? " WITH" : " with");
                _with = true;
            }
            print0(ucase ? " MAX_UPDATES_PER_HOUR " : " max_updates_per_hour ");
            x.getMaxUpdatesPerHour().accept(this);
        }

        if (x.getMaxConnectionsPerHour() !is null) {
            if (!_with) {
                print0(ucase ? " WITH" : " with");
                _with = true;
            }
            print0(ucase ? " MAX_CONNECTIONS_PER_HOUR " : " max_connections_per_hour ");
            x.getMaxConnectionsPerHour().accept(this);
        }

        if (x.getMaxUserConnections() !is null) {
            if (!_with) {
                print0(ucase ? " WITH" : " with");
                _with = true;
            }
            print0(ucase ? " MAX_USER_CONNECTIONS " : " max_user_connections ");
            x.getMaxUserConnections().accept(this);
        }

        if (x.isAdminOption()) {
            if (!_with) {
                print0(ucase ? " WITH" : " with");
                _with = true;
            }
            print0(ucase ? " ADMIN OPTION" : " admin option");
        }

        if (x.getIdentifiedBy() !is null) {
            print0(ucase ? " IDENTIFIED BY " : " identified by ");
            x.getIdentifiedBy().accept(this);
        }

        return false;
    }

    protected void printGrantOn(SQLGrantStatement x) {
        if (x.getOn() !is null) {
            print0(ucase ? " ON " : " on ");

            SQLObjectType objectType = x.getObjectType();
            if (objectType.name.length != 0) {
                print0(ucase ? objectType.name : objectType.name_lcase);
                print(' ');
            }

            x.getOn().accept(this);
        }
    }

    override
    bool visit(SQLRevokeStatement x) {
        print0(ucase ? "REVOKE " : "revoke ");
        printAndAccept!SQLExpr((x.getPrivileges()), ", ");

        if (x.getOn() !is null) {
            print0(ucase ? " ON " : " on ");

            if (x.getObjectType().name.length != 0) {
                print0(x.getObjectType().name);
                print(' ');
            }

            x.getOn().accept(this);
        }

        if (x.getFrom() !is null) {
            print0(ucase ? " FROM " : " from ");
            x.getFrom().accept(this);
        }

        return false;
    }

    override
    bool visit(SQLDropDatabaseStatement x) {
        print0(ucase ? "DROP DATABASE " : "drop databasE ");

        if (x.isIfExists()) {
            print0(ucase ? "IF EXISTS " : "if exists ");
        }

        x.getDatabase().accept(this);

        return false;
    }

    override
    bool visit(SQLDropFunctionStatement x) {
        print0(ucase ? "DROP FUNCTION " : "drop function ");

        if (x.isIfExists()) {
            print0(ucase ? "IF EXISTS " : "if exists ");
        }

        x.getName().accept(this);

        return false;
    }

    override
    bool visit(SQLDropTableSpaceStatement x) {
        print0(ucase ? "DROP TABLESPACE " : "drop tablespace ");

        if (x.isIfExists()) {
            print0(ucase ? "IF EXISTS " : "if exists ");
        }

        x.getName().accept(this);

        SQLExpr engine = x.getEngine();
        if (engine !is null) {
            print0(ucase ? " ENGINE " : " engine ");
            engine.accept(this);
        }

        return false;
    }

    override
    bool visit(SQLDropProcedureStatement x) {
        print0(ucase ? "DROP PROCEDURE " : "drop procedure ");

        if (x.isIfExists()) {
            print0(ucase ? "IF EXISTS " : "if exists ");
        }

        x.getName().accept(this);

        return false;
    }

    override
    bool visit(SQLAlterTableAddIndex x) {
        print0(ucase ? "ADD " : "add ");
        string type = x.getType();

        bool mysql = DBType.MYSQL.opEquals(dbType);

        if (type !is null && !mysql) {
            print0(type);
            print(' ');
        }

        if (x.isUnique()) {
            print0(ucase ? "UNIQUE " : "unique ");
        }

        if (x.isKey()) {
            print0(ucase ? "KEY " : "key ");    
        } else {
            print0(ucase ? "INDEX " : "index ");
        }
        
        if (x.getName() !is null) {
            x.getName().accept(this);
            print(' ');
        }

        if (type !is null && mysql) {
            print0(ucase ? "USING " : "using ");
            print0(type);
            print(' ');
        }

        print('(');
        printAndAccept!SQLSelectOrderByItem((x.getItems()), ", ");
        print(')');

        if (x.getUsing() !is null) {
            print0(ucase ? " USING " : " using ");
            print0(x.getUsing());
        }

        SQLExpr comment = x.getComment();
        if (comment !is null) {
            print0(ucase ? " COMMENT " : " comment ");
            printExpr(comment);
        }
        return false;
    }

    override
    bool visit(SQLAlterTableAddConstraint x) {
        if (x.isWithNoCheck()) {
            print0(ucase ? "WITH NOCHECK " : "with nocheck ");
        }

        print0(ucase ? "ADD " : "add ");

        x.getConstraint().accept(this);
        return false;
    }

    override bool visit(SQLCreateTriggerStatement x) {
        print0(ucase ? "CREATE " : "create ");

        if (x.isOrReplace()) {
            print0(ucase ? "OR REPLACE " : "or replace ");
        }

        print0(ucase ? "TRIGGER " : "trigger ");

        x.getName().accept(this);

        this.indentCount++;
        println();
        if (SQLCreateTriggerStatement.TriggerType.INSTEAD_OF == (x.getTriggerType())) {
            print0(ucase ? "INSTEAD OF" : "instead of");
        } else {
            string triggerTypeName = x.getTriggerType().name;
            print0(ucase ? triggerTypeName : toLower(triggerTypeName));
        }

        if (x.isInsert()) {
            print0(ucase ? " INSERT" : " insert");
        }

        if (x.isDelete()) {
            if (x.isInsert()) {
                print0(ucase ? " OR" : " or");
            }
            print0(ucase ? " DELETE" : " delete");
        }

        if (x.isUpdate()) {
            if (x.isInsert() || x.isDelete()) {
                print0(ucase ? " OR" : " or");
            }
            print0(ucase ? " UPDATE" : " update");

            List!SQLName colums = x.getUpdateOfColumns();
            foreach(SQLName colum  ;  colums) {
                print(' ');
                colum.accept(this);
            }
        }

        println();
        print0(ucase ? "ON " : "on ");
        x.getOn().accept(this);

        if (x.isForEachRow()) {
            println();
            print0(ucase ? "FOR EACH ROW" : "for each row");
        }

        SQLExpr when = x.getWhen();
        if (when !is null) {
            println();
            print0(ucase ? "WHEN " : "when ");
            when.accept(this);
        }
        this.indentCount--;
        println();
        x.getBody().accept(this);
        return false;
    }

    override bool visit(SQLBooleanExpr x) {
        print0(x.getBooleanValue().booleanValue ? "true" : "false");
        return false;
    }

    override void endVisit(SQLBooleanExpr x) {
    }

    override
    bool visit(SQLUnionQueryTableSource x) {
        print('(');
        this.indentCount++;
        println();
        x.getUnion().accept(this);
        this.indentCount--;
        println();
        print(')');

        if (x.getAlias() !is null) {
            print(' ');
            print0(x.getAlias());
        }

        return false;
    }

    override
    bool visit(SQLTimestampExpr x) {
        if (this.parameterized) {
            print('?');
            incrementReplaceCunt();

            if(this.parameters !is null){
                ExportParameterVisitorUtils.exportParameter(this.parameters, x);
            }
            return false;
        }

        print0(ucase ? "TIMESTAMP " : "timestamp ");

        if (x.isWithTimeZone()) {
            print0(ucase ? " WITH TIME ZONE " : " with time zone ");
        }

        print('\'');
        print0(x.getLiteral());
        print('\'');

        if (x.getTimeZone() !is null) {
            print0(ucase ? " AT TIME ZONE '" : " at time zone '");
            print0(x.getTimeZone());
            print('\'');
        }

        return false;
    }

    override
    bool visit(SQLBinaryExpr x) {
        print0("b'");
        print0(x.getText());
        print('\'');

        return false;
    }

    override
    bool visit(SQLAlterTableRename x) {
        print0(ucase ? "RENAME TO " : "rename to ");
        x.getTo().accept(this);
        return false;
    }

    override
    bool visit(SQLShowTablesStatement x) {
        print0(ucase ? "SHOW TABLES" : "show tables");
        if (x.getDatabase() !is null) {
            print0(ucase ? " FROM " : " from ");
            x.getDatabase().accept(this);
        }

        if (x.getLike() !is null) {
            print0(ucase ? " LIKE " : " like ");
            x.getLike().accept(this);
        }
        return false;
    }

    protected void printlnComment(List!string comments) {
        if (comments !is null) {
            for (int i = 0; i < comments.size(); ++i) {
                string comment = comments.get(i);
                if (i != 0 && comment.startsWith("--")) {
                    println();
                }

                printComment(comment);
            }
        }
    }

    void printComment(string comment) {
        if (comment is null) {
            return;
        }

        if (comment.startsWith("--") && comment.length > 2 && charAt(comment, 2) != ' ') {
            print0("-- ");
            print0(comment.substring(2));
        } else {
            print0(comment);
        }
    }

    protected void printlnComments(List!string comments) {
        if (comments !is null) {
            for (int i = 0; i < comments.size(); ++i) {
                string comment = comments.get(i);
                printComment(comment);
                println();
            }
        }
    }

    override
    bool visit(SQLAlterViewRenameStatement x) {
        print0(ucase ? "ALTER VIEW " : "alter view ");
        x.getName().accept(this);
        print0(ucase ? " RENAME TO " : " rename to ");
        x.getTo().accept(this);
        return false;
    }

    override
    bool visit(SQLAlterTableAddPartition x) {
        print0(ucase ? "ADD " : "add ");
        if (x.isIfNotExists()) {
            print0(ucase ? "IF NOT EXISTS " : "if not exists ");
        }
        
        if (x.getPartitionCount() !is null) {
            print0(ucase ? "PARTITION PARTITIONS " : "partition partitions ");
            x.getPartitionCount().accept(this);
        }

        if (x.getPartitions().size() > 0) {
            print0(ucase ? "PARTITION (" : "partition (");
            printAndAccept((x.getPartitions()), ", ");
            print(')');
        }
        
        return false;
    }

    override
    bool visit(SQLAlterTableReOrganizePartition x) {
        print0(ucase ? "REORGANIZE " : "reorganize ");

        printAndAccept!SQLName((x.getNames()), ", ");

        print0(ucase ? " INTO (" : " into (");
        printAndAccept((x.getPartitions()), ", ");
        print(')');
        return false;
    }

    override
    bool visit(SQLAlterTableDropPartition x) {
        print0(ucase ? "DROP " : "drop ");
        if (x.isIfExists()) {
            print0(ucase ? "IF EXISTS " : "if exists ");
        }
        print0(ucase ? "PARTITION " : "partition ");

        if (x.getPartitions().size() == 1 &&  cast(SQLName)x.getPartitions().get(0) !is null) {
            x.getPartitions().get(0).accept(this);
        } else {
            print('(');
            printAndAccept((x.getPartitions()), ", ");
            print(')');
        }

        if (x.isPurge()) {
            print0(ucase ? " PURGE" : " purge");
        }
        return false;
    }

    override
    bool visit(SQLAlterTableRenamePartition x) {
        print0(ucase ? "PARTITION (" : "partition (");
        printAndAccept!SQLAssignItem((x.getPartition()), ", ");
        print0(ucase ? ") RENAME TO PARTITION(" : ") rename to partition(");
        printAndAccept!SQLAssignItem((x.getTo()), ", ");
        print(')');
        return false;
    }

    override
    bool visit(SQLAlterTableSetComment x) {
        print0(ucase ? "SET COMMENT " : "set comment ");
        x.getComment().accept(this);
        return false;
    }

    override
    bool visit(SQLAlterTableSetLifecycle x) {
        print0(ucase ? "SET LIFECYCLE " : "set lifecycle ");
        x.getLifecycle().accept(this);
        return false;
    }

    override
    bool visit(SQLAlterTableEnableLifecycle x) {
        if (x.getPartition().size() != 0) {
            print0(ucase ? "PARTITION (" : "partition (");
            printAndAccept!SQLAssignItem((x.getPartition()), ", ");
            print0(") ");
        }

        print0(ucase ? "ENABLE LIFECYCLE" : "enable lifecycle");
        return false;
    }

    override
    bool visit(SQLAlterTableDisableLifecycle x) {
        if (x.getPartition().size() != 0) {
            print0(ucase ? "PARTITION (" : "partition (");
            printAndAccept!SQLAssignItem((x.getPartition()), ", ");
            print0(") ");
        }

        print0(ucase ? "DISABLE LIFECYCLE" : "disable lifecycle");
        return false;
    }

    override
    bool visit(SQLAlterTableTouch x) {
        print0(ucase ? "TOUCH" : "touch");
        if (x.getPartition().size() != 0) {
            print0(ucase ? " PARTITION (" : " partition (");
            printAndAccept!SQLAssignItem((x.getPartition()), ", ");
            print(')');
        }
        return false;
    }

    override
    bool visit(SQLArrayExpr x) {
        x.getExpr().accept(this);
        print('[');
        printAndAccept!SQLExpr((x.getValues()), ", ");
        print(']');
        return false;
    }

    override
    bool visit(SQLOpenStatement x) {
        print0(ucase ? "OPEN " : "open ");
        printExpr(x.getCursorName());

        List!SQLName columns = x.getColumns();
        if (columns.size() > 0) {
            print('(');
            printAndAccept!SQLName((columns), ", ");
            print(')');
        }

        SQLExpr forExpr = x.getFor();
        if (forExpr !is null) {
            print0(ucase ? " FOR " : "for ");
            forExpr.accept(this);
        }
        return false;
    }

    override
    bool visit(SQLFetchStatement x) {
        print0(ucase ? "FETCH " : "fetch ");
        x.getCursorName().accept(this);
        if (x.isBulkCollect()) {
            print0(ucase ? " BULK COLLECT INTO " : " bulk collect into ");
        } else {
            print0(ucase ? " INTO " : " into ");
        }
        printAndAccept!SQLExpr((x.getInto()), ", ");
        return false;
    }

    override
    bool visit(SQLCloseStatement x) {
        print0(ucase ? "CLOSE " : "close ");
        printExpr(x.getCursorName());
        return false;
    }

    override
    bool visit(SQLGroupingSetExpr x) {
        print0(ucase ? "GROUPING SETS" : "grouping sets");
        print0(" (");
        printAndAccept!SQLExpr((x.getParameters()), ", ");
        print(')');
        return false;
    }

    override
    bool visit(SQLIfStatement x) {
        print0(ucase ? "IF " : "if ");
        x.getCondition().accept(this);
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

        foreach (SQLIfStatement.ElseIf elseIf ; x.getElseIfList()) {
            println();
            elseIf.accept(this);
        }

        if (x.getElseItem() !is null) {
            println();
            x.getElseItem().accept(this);
        }
        return false;
    }

    override
    bool visit(SQLIfStatement.Else x) {
        print0(ucase ? "ELSE" : "else");
        this.indentCount++;
        println();

        for (int i = 0, size = x.getStatements().size(); i < size; ++i) {
            if (i != 0) {
                println();
            }
            SQLStatement item = x.getStatements().get(i);
            item.accept(this);
        }

        this.indentCount--;
        return false;
    }

    override
    bool visit(SQLIfStatement.ElseIf x) {
        print0(ucase ? "ELSE IF" : "else if");
        x.getCondition().accept(this);
        print0(ucase ? " THEN" : " then");
        this.indentCount++;
        println();

        for (int i = 0, size = x.getStatements().size(); i < size; ++i) {
            if (i != 0) {
                println();
            }
            SQLStatement item = x.getStatements().get(i);
            item.accept(this);
        }

        this.indentCount--;
        return false;
    }

    override
    bool visit(SQLLoopStatement x) {
        print0(ucase ? "LOOP" : "loop");
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
        if (x.getLabelName() !is null) {
            print(' ');
            print0(x.getLabelName());
        }
        return false;
    }

    // bool visit(OracleFunctionDataType x) {
    //     if (x.isStatic()) {
    //         print0(ucase ? "STATIC " : "static ");
    //     }

    //     print0(ucase ? "FUNCTION " : "function ");

    //     print0(x.getName());

    //     print(" (");
    //     printAndAccept(x.getParameters(), ", ");
    //     print(")");
    //     print0(ucase ? " RETURN " : " return ");
    //     x.getReturnDataType().accept(this);

    //     SQLStatement block = x.getBlock();
    //     if (block !is null) {
    //         println();
    //         print0(ucase ? "IS" : "is");
    //         println();
    //         block.accept(this);
    //     }

    //     return false;
    // }

    // bool visit(OracleProcedureDataType x) {
    //     if (x.isStatic()) {
    //         print0(ucase ? "STATIC " : "static ");
    //     }

    //     print0(ucase ? "PROCEDURE " : "procedure ");

    //     print0(x.getName());

    //     if (x.getParameters().size() > 0) {
    //         print(" (");
    //         printAndAccept(x.getParameters(), ", ");
    //         print(")");
    //     }

    //     SQLStatement block = x.getBlock();
    //     if (block !is null) {
    //         println();
    //         print0(ucase ? "IS" : "is");
    //         println();
    //         block.accept(this);
    //     }

    //     return false;
    // }

    override
    bool visit(SQLParameter x) {
        SQLName name = x.getName();
        if (x.getDataType().getName().equalsIgnoreCase("CURSOR")) {
            print0(ucase ? "CURSOR " : "cursor ");
            x.getName().accept(this);
            print0(ucase ? " IS" : " is");
            this.indentCount++;
            println();
            SQLSelect select = (cast(SQLQueryExpr) x.getDefaultValue()).getSubQuery();
            select.accept(this);
            this.indentCount--;

        } else {
            if (x.isMap()) {
                print0(ucase ? "MAP MEMBER " : "map member ");
            } else if (x.isOrder()) {
                print0(ucase ? "ORDER MEMBER " : "order member ");
            } else if (x.isMember()) {
                print0(ucase ? "MEMBER " : "member ");
            }
            SQLDataType dataType = x.getDataType();

            /*if (DBType.ORACLE.opEquals(dbType)
                    || cast(OracleFunctionDataType)dataType !is null
                    || cast(OracleProcedureDataType)dataType !is null) {
                if (cast(OracleFunctionDataType)dataType !is null) {
                    OracleFunctionDataType functionDataType = cast(OracleFunctionDataType) dataType;
                    visit(functionDataType);
                    return false;
                }

                if (cast(OracleProcedureDataType)dataType !is null) {
                    OracleProcedureDataType procedureDataType = cast(OracleProcedureDataType) dataType;
                    visit(procedureDataType);
                    return false;
                }

                string dataTypeName = dataType.getName();
                bool printType = (dataTypeName.startsWith("TABLE OF") && x.getDefaultValue() is null)
                        || equalsIgnoreCase(dataTypeName, "REF CURSOR")
                        || dataTypeName.startsWith("VARRAY(");
                if (printType) {
                    print0(ucase ? "TYPE " : "type ");
                }

                name.accept(this);
                if (x.getParamType() == SQLParameter.ParameterType.IN) {
                    print0(ucase ? " IN " : " in ");
                } else if (x.getParamType() == SQLParameter.ParameterType.OUT) {
                    print0(ucase ? " OUT " : " out ");
                } else if (x.getParamType() == SQLParameter.ParameterType.INOUT) {
                    print0(ucase ? " IN OUT " : " in out ");
                } else {
                    print(' ');
                }

                if (x.isNoCopy()) {
                    print0(ucase ? "NOCOPY " : "nocopy ");
                }

                if (x.isConstant()) {
                    print0(ucase ? "CONSTANT " : "constant ");
                }

                if (printType) {
                    print0(ucase ? "IS " : "is ");
                }
            } else */{
                if (x.getParamType() == SQLParameter.ParameterType.IN) {
                    bool skip = DBType.MYSQL.opEquals(dbType)
                            && cast(SQLCreateFunctionStatement)x.getParent() !is null;

                    if (!skip) {
                        print0(ucase ? "IN " : "in ");
                    }
                } else if (x.getParamType() == SQLParameter.ParameterType.OUT) {
                    print0(ucase ? "OUT " : "out ");
                } else if (x.getParamType() == SQLParameter.ParameterType.INOUT) {
                    print0(ucase ? "INOUT " : "inout ");
                }
                x.getName().accept(this);
                print(' ');
            }

            dataType.accept(this);

            printParamDefaultValue(x);
        }

        return false;
    }

    protected void printParamDefaultValue(SQLParameter x) {
        if (x.getDefaultValue() !is null) {
            print0(" := ");
            x.getDefaultValue().accept(this);
        }
    }

    override
    bool visit(SQLDeclareItem x) {
        SQLDataType dataType = x.getDataType();

        if (cast(SQLRecordDataType)dataType !is null) {
            print0(ucase ? "TYPE " : "type ");
        }

        x.getName().accept(this);


        if (x.getType() == SQLDeclareItem.Type.TABLE) {
            print0(ucase ? " TABLE" : " table");
            int size = x.getTableElementList().size();

            if (size > 0) {
                print0(" (");
                this.indentCount++;
                println();
                for (int i = 0; i < size; ++i) {
                    if (i != 0) {
                        print(',');
                        println();
                    }
                    x.getTableElementList().get(i).accept(this);
                }
                this.indentCount--;
                println();
                print(')');
            }
        } else if (x.getType() == SQLDeclareItem.Type.CURSOR) {
            print0(ucase ? " CURSOR" : " cursor");
        } else {

            if (dataType !is null) {
                if (cast(SQLRecordDataType)dataType !is null) {
                    print0(ucase ? " IS " : " is ");
                } else {
                    print(' ');
                }
                dataType.accept(this);
            }
            if (x.getValue() !is null) {
                if (DBType.MYSQL.opEquals(getDbType())) {
                    print0(ucase ? " DEFAULT " : " default ");
                } else {
                    print0(" = ");
                }
                x.getValue().accept(this);
            }
        }

        return false;
    }

    override
    bool visit(SQLPartitionValue x) {
        if (x.getOperator() == SQLPartitionValue.Operator.LessThan //
            && (!DBType.ORACLE.opEquals(getDbType())) && x.getItems().size() == 1 //
            && cast(SQLIdentifierExpr)x.getItems().get(0) !is null)  {
            SQLIdentifierExpr ident = cast(SQLIdentifierExpr) x.getItems().get(0);
            if ("MAXVALUE".equalsIgnoreCase(ident.getName())) {
                print0(ucase ? "VALUES LESS THAN MAXVALUE" : "values less than maxvalue");
                return false;
            }
        }

        if (x.getOperator() == SQLPartitionValue.Operator.LessThan) {
            print0(ucase ? "VALUES LESS THAN (" : "values less than (");
        } else if (x.getOperator() == SQLPartitionValue.Operator.In) {
            print0(ucase ? "VALUES IN (" : "values in (");
        } else {
            print(ucase ? "VALUES (" : "values (");
        }
        printAndAccept!SQLExpr((x.getItems()), ", ");
        print(')');
        return false;
    }

    string getDbType() {
        return dbType;
    }

    bool isUppCase() {
        return ucase;
    }

    void setUppCase(bool val) {
        this.config(VisitorFeature.OutputUCase, true);
    }

    override
    bool visit(SQLPartition x) {
        print0(ucase ? "PARTITION " : "partition ");
        x.getName().accept(this);
        if (x.getValues() !is null) {
            print(' ');
            x.getValues().accept(this);
        }

        if (x.getDataDirectory() !is null) {
            this.indentCount++;
            println();
            print0(ucase ? "DATA DIRECTORY " : "data directory ");
            x.getDataDirectory().accept(this);
            this.indentCount--;
        }

        if (x.getIndexDirectory() !is null) {
            this.indentCount++;
            println();
            print0(ucase ? "INDEX DIRECTORY " : "index directory ");
            x.getIndexDirectory().accept(this);
            this.indentCount--;
        }

        this.indentCount++;
        // printOracleSegmentAttributes(x);//@gxc


        if (x.getEngine() !is null) {
            println();
            print0(ucase ? "STORAGE ENGINE " : "storage engine ");
            x.getEngine().accept(this);
        }
        this.indentCount--;

        if (x.getMaxRows() !is null) {
            print0(ucase ? " MAX_ROWS " : " max_rows ");
            x.getMaxRows().accept(this);
        }

        if (x.getMinRows() !is null) {
            print0(ucase ? " MIN_ROWS " : " min_rows ");
            x.getMinRows().accept(this);
        }

        if (x.getComment() !is null) {
            print0(ucase ? " COMMENT " : " comment ");
            x.getComment().accept(this);
        }

        if (x.getSubPartitionsCount() !is null) {
            this.indentCount++;
            println();
            print0(ucase ? "SUBPARTITIONS " : "subpartitions ");
            x.getSubPartitionsCount().accept(this);
            this.indentCount--;
        }

        if (x.getSubPartitions().size() > 0) {
            print(" (");
            this.indentCount++;
            for (int i = 0; i < x.getSubPartitions().size(); ++i) {
                if (i != 0) {
                    print(',');
                }
                println();
                x.getSubPartitions().get(i).accept(this);
            }
            this.indentCount--;
            println();
            print(')');
        }

        return false;
    }

    override
    bool visit(SQLPartitionByRange x) {
        print0(ucase ? "RANGE" : "range");
        if (x.getColumns().size() == 1) {
            print0(" (");
            x.getColumns().get(0).accept(this);
            print(')');
        } else {
            if (DBType.MYSQL.opEquals(getDbType())) {
                print0(ucase ? " COLUMNS (" : " columns (");
            } else {
                print0(" (");
            }
            printAndAccept!SQLExpr((x.getColumns()), ", ");
            print(')');
        }

        SQLExpr interval = x.getInterval();
        if (interval !is null) {
            print0(ucase ? " INTERVAL (" : " interval (");
            interval.accept(this);
            print(')');
        }

        printPartitionsCountAndSubPartitions(x);

        print(" (");
        this.indentCount++;
        for (int i = 0, size = x.getPartitions().size(); i < size; ++i) {
            if (i != 0) {
                print(',');
            }
            println();
            x.getPartitions().get(i).accept(this);
        }
        this.indentCount--;
        println();
        print(')');

        return false;
    }

    override
    bool visit(SQLPartitionByList x) {
        print0(ucase ? "LIST " : "list ");
        if (x.getColumns().size() == 1) {
            print('(');
            x.getColumns().get(0).accept(this);
            print0(")");
        } else {
            print0(ucase ? "COLUMNS (" : "columns (");
            printAndAccept!SQLExpr((x.getColumns()), ", ");
            print0(")");
        }

        printPartitionsCountAndSubPartitions(x);

        printSQLPartitions(x.getPartitions());
        return false;
    }

    override
    bool visit(SQLPartitionByHash x) {
        if (x.isLinear()) {
            print0(ucase ? "LINEAR HASH " : "linear hash ");
        } else {
            print0(ucase ? "HASH " : "hash ");
        }

        if (x.isKey()) {
            print0(ucase ? "KEY" : "key");
        }

        print('(');
        printAndAccept!SQLExpr((x.getColumns()), ", ");
        print(')');

        printPartitionsCountAndSubPartitions(x);

        printSQLPartitions(x.getPartitions());

        return false;
    }

    private void printSQLPartitions(List!SQLPartition partitions) {
        int partitionsSize = partitions.size();
        if (partitionsSize > 0) {
            print0(" (");
            this.indentCount++;
            for (int i = 0; i < partitionsSize; ++i) {
                println();
                partitions.get(i).accept(this);
                if (i != partitionsSize - 1) {
                    print0(", ");
                }
            }
            this.indentCount--;
            println();
            print(')');
        }
    }

    protected void printPartitionsCountAndSubPartitions(SQLPartitionBy x) {
        if (x.getPartitionsCount() !is null) {

            if (Boolean.TRUE.opEquals(x.getAttribute("ads.partition"))) {
                print0(ucase ? " PARTITION NUM " : " partition num ");
            } else {
                print0(ucase ? " PARTITIONS " : " partitions ");
            }

            x.getPartitionsCount().accept(this);
        }

        if (x.getSubPartitionBy() !is null) {
            println();
            x.getSubPartitionBy().accept(this);
        }

        if (x.getStoreIn().size() > 0) {
            println();
            print0(ucase ? "STORE IN (" : "store in (");
            printAndAccept!SQLName((x.getStoreIn()), ", ");
            print(')');
        }
    }

    override
    bool visit(SQLSubPartitionByHash x) {
        if (x.isLinear()) {
            print0(ucase ? "SUBPARTITION BY LINEAR HASH " : "subpartition by linear hash ");
        } else {
            print0(ucase ? "SUBPARTITION BY HASH " : "subpartition by hash ");
        }

        if (x.isKey()) {
            print0(ucase ? "KEY" : "key");
        }

        print('(');
        x.getExpr().accept(this);
        print(')');

        if (x.getSubPartitionsCount() !is null) {
            print0(ucase ? " SUBPARTITIONS " : " subpartitions ");
            x.getSubPartitionsCount().accept(this);
        }

        return false;
    }

    override
    bool visit(SQLSubPartitionByList x) {
        if (x.isLinear()) {
            print0(ucase ? "SUBPARTITION BY LINEAR HASH " : "subpartition by linear hash ");
        } else {
            print0(ucase ? "SUBPARTITION BY HASH " : "subpartition by hash ");
        }

        print('(');
        x.getColumn().accept(this);
        print(')');

        if (x.getSubPartitionsCount() !is null) {
            print0(ucase ? " SUBPARTITIONS " : " subpartitions ");
            x.getSubPartitionsCount().accept(this);
        }

        if (x.getSubPartitionTemplate().size() > 0) {
            this.indentCount++;
            println();
            print0(ucase ? "SUBPARTITION TEMPLATE (" : "subpartition template (");
            this.indentCount++;
            println();
            printlnAndAccept!(SQLSubPartition)((x.getSubPartitionTemplate()), ",");
            this.indentCount--;
            println();
            print(')');
            this.indentCount--;
        }

        return false;
    }

    override
    bool visit(SQLSubPartition x) {
        print0(ucase ? "SUBPARTITION " : "subpartition ");
        x.getName().accept(this);

        if (x.getValues() !is null) {
            print(' ');
            x.getValues().accept(this);
        }

        SQLName tableSpace = x.getTableSpace();
        if (tableSpace !is null) {
            print0(ucase ? " TABLESPACE " : " tablespace ");
            tableSpace.accept(this);
        }

        return false;
    }

    override
    bool visit(SQLAlterDatabaseStatement x) {
        print0(ucase ? "ALTER DATABASE " : "alter database ");
        x.getName().accept(this);
        if (x.isUpgradeDataDirectoryName()) {
            print0(ucase ? " UPGRADE DATA DIRECTORY NAME" : " upgrade data directory name");
        }

        SQLAlterCharacter character = x.getCharacter();
        if (character !is null) {
            print(' ');
            character.accept(this);
        }
        return false;
    }

    override
    bool visit(SQLAlterTableConvertCharSet x) {
        print0(ucase ? "CONVERT TO CHARACTER SET " : "convert to character set ");
        x.getCharset().accept(this);

        if (x.getCollate() !is null) {
            print0(ucase ? "COLLATE " : "collate ");
            x.getCollate().accept(this);
        }
        return false;
    }

    override
    bool visit(SQLAlterTableCoalescePartition x) {
        print0(ucase ? "COALESCE PARTITION " : "coalesce partition ");
        x.getCount().accept(this);
        return false;
    }
    
    override
    bool visit(SQLAlterTableTruncatePartition x) {
        print0(ucase ? "TRUNCATE PARTITION " : "truncate partition ");
        printPartitions(x.getPartitions());
        return false;
    }
    
    override
    bool visit(SQLAlterTableDiscardPartition x) {
        print0(ucase ? "DISCARD PARTITION " : "discard partition ");
        printPartitions(x.getPartitions());

        if (x.isTablespace()) {
            print0(ucase ? " TABLESPACE" : " tablespace");
        }

        return false;
    }
    
    override
    bool visit(SQLAlterTableImportPartition x) {
        print0(ucase ? "IMPORT PARTITION " : "import partition ");
        printPartitions(x.getPartitions());
        return false;
    }
    
    override
    bool visit(SQLAlterTableAnalyzePartition x) {
        print0(ucase ? "ANALYZE PARTITION " : "analyze partition ");
        
        printPartitions(x.getPartitions());
        return false;
    }
    
    protected void printPartitions(List!SQLName partitions) {
        if (partitions.size() == 1 && "ALL".equalsIgnoreCase(partitions.get(0).getSimpleName())) {
            print0(ucase ? "ALL" : "all");    
        } else {
            printAndAccept!SQLName((partitions), ", ");
        }
    }
    
    override
    bool visit(SQLAlterTableCheckPartition x) {
        print0(ucase ? "CHECK PARTITION " : "check partition ");
        printPartitions(x.getPartitions());
        return false;
    }
    
    override
    bool visit(SQLAlterTableOptimizePartition x) {
        print0(ucase ? "OPTIMIZE PARTITION " : "optimize partition ");
        printPartitions(x.getPartitions());
        return false;
    }
    
    override
    bool visit(SQLAlterTableRebuildPartition x) {
        print0(ucase ? "REBUILD PARTITION " : "rebuild partition ");
        printPartitions(x.getPartitions());
        return false;
    }
    
    override
    bool visit(SQLAlterTableRepairPartition x) {
        print0(ucase ? "REPAIR PARTITION " : "repair partition ");
        printPartitions(x.getPartitions());
        return false;
    }
    
    override
    bool visit(SQLSequenceExpr x) {
        x.getSequence().accept(this);
        print('.');
        print0(ucase ? x.getFunction().name : x.getFunction().name_lcase);
        return false;
    }
    
    override
    bool visit(SQLMergeStatement x) {
        print0(ucase ? "MERGE " : "merge ");
        if (x.getHints().size() > 0) {
            printAndAccept!SQLHint((x.getHints()), ", ");
            print(' ');
        }

        print0(ucase ? "INTO " : "into ");
        x.getInto().accept(this);

        println();
        print0(ucase ? "USING " : "using ");
        x.getUsing().accept(this);

        print0(ucase ? " ON (" : " on (");
        x.getOn().accept(this);
        print0(") ");

        if (x.getUpdateClause() !is null) {
            println();
            x.getUpdateClause().accept(this);
        }

        if (x.getInsertClause() !is null) {
            println();
            x.getInsertClause().accept(this);
        }

        if (x.getErrorLoggingClause() !is null) {
            println();
            x.getErrorLoggingClause().accept(this);
        }

        return false;
    }

    override
    bool visit(SQLMergeStatement.MergeUpdateClause x) {
        print0(ucase ? "WHEN MATCHED THEN UPDATE SET " : "when matched then update set ");
        printAndAccept!SQLUpdateSetItem((x.getItems()), ", ");

        SQLExpr where = x.getWhere();
        if (where !is null) {
            this.indentCount++;
            println();
            print0(ucase ? "WHERE " : "where ");
            printExpr(where);
            this.indentCount--;
        }

        SQLExpr deleteWhere = x.getDeleteWhere();
        if (deleteWhere !is null) {
            this.indentCount++;
            println();
            print0(ucase ? "DELETE WHERE " : "delete where ");
            printExpr(deleteWhere);
            this.indentCount--;
        }

        return false;
    }

    override
    bool visit(SQLMergeStatement.MergeInsertClause x) {
        print0(ucase ? "WHEN NOT MATCHED THEN INSERT" : "when not matched then insert");
        if (x.getColumns().size() > 0) {
            print(" (");
            printAndAccept!SQLExpr((x.getColumns()), ", ");
            print(')');
        }
        print0(ucase ? " VALUES (" : " values (");
        printAndAccept!SQLExpr((x.getValues()), ", ");
        print(')');
        if (x.getWhere() !is null) {
            this.indentCount++;
            println();
            print0(ucase ? "WHERE " : "where ");
            x.getWhere().accept(this);
            this.indentCount--;
        }

        return false;
    }

    override
    bool visit(SQLErrorLoggingClause x) {
        print0(ucase ? "LOG ERRORS " : "log errors ");
        if (x.getInto() !is null) {
            print0(ucase ? "INTO " : "into ");
            x.getInto().accept(this);
            print(' ');
        }

        if (x.getSimpleExpression() !is null) {
            print('(');
            x.getSimpleExpression().accept(this);
            print(')');
        }

        if (x.getLimit() !is null) {
            print0(ucase ? " REJECT LIMIT " : " reject limit ");
            x.getLimit().accept(this);
        }

        return false;
    }

    override
    bool visit(SQLCreateSequenceStatement x) {
        print0(ucase ? "CREATE SEQUENCE " : "create sequence ");
        x.getName().accept(this);

        if (x.getStartWith() !is null) {
            print0(ucase ? " START WITH " : " start with ");
            x.getStartWith().accept(this);
        }

        if (x.getIncrementBy() !is null) {
            print0(ucase ? " INCREMENT BY " : " increment by ");
            x.getIncrementBy().accept(this);
        }

        if (x.getMaxValue() !is null) {
            print0(ucase ? " MAXVALUE " : " maxvalue ");
            x.getMaxValue().accept(this);
        }

        if (x.isNoMaxValue()) {
            if (DBType.POSTGRESQL.opEquals(dbType)) {
                print0(ucase ? " NO MAXVALUE" : " no maxvalue");
            } else {
                print0(ucase ? " NOMAXVALUE" : " nomaxvalue");
            }
        }

        if (x.getMinValue() !is null) {
            print0(ucase ? " MINVALUE " : " minvalue ");
            x.getMinValue().accept(this);
        }

        if (x.isNoMinValue()) {
            if (DBType.POSTGRESQL.opEquals(dbType)) {
                print0(ucase ? " NO MINVALUE" : " no minvalue");
            } else {
                print0(ucase ? " NOMINVALUE" : " nominvalue");
            }
        }

        if (x.getCycle() !is null) {
            if (x.getCycle().booleanValue()) {
                print0(ucase ? " CYCLE" : " cycle");
            } else {
                if (DBType.POSTGRESQL.opEquals(dbType)) {
                    print0(ucase ? " NO CYCLE" : " no cycle");
                } else {
                    print0(ucase ? " NOCYCLE" : " nocycle");
                }
            }
        }

        Boolean cache = x.getCache();
        if (cache !is null) {
            if (cache.booleanValue()) {
                print0(ucase ? " CACHE" : " cache");

                SQLExpr cacheValue = x.getCacheValue();
                if (cacheValue !is null) {
                    print(' ');
                    cacheValue.accept(this);
                }
            } else {
                print0(ucase ? " NOCACHE" : " nocache");
            }
        }

        Boolean order = x.getOrder();
        if (order !is null) {
            if (order.booleanValue()) {
                print0(ucase ? " ORDER" : " order");
            } else {
                print0(ucase ? " NOORDER" : " noorder");
            }
        }

        return false;
    }

    override
    bool visit(SQLAlterSequenceStatement x) {
        print0(ucase ? "ALTER SEQUENCE " : "alter sequence ");
        x.getName().accept(this);

        if (x.getStartWith() !is null) {
            print0(ucase ? " START WITH " : " start with ");
            x.getStartWith().accept(this);
        }

        if (x.getIncrementBy() !is null) {
            print0(ucase ? " INCREMENT BY " : " increment by ");
            x.getIncrementBy().accept(this);
        }

        if (x.getMaxValue() !is null) {
            print0(ucase ? " MAXVALUE " : " maxvalue ");
            x.getMaxValue().accept(this);
        }

        if (x.isNoMaxValue()) {
            if (DBType.POSTGRESQL.opEquals(dbType)) {
                print0(ucase ? " NO MAXVALUE" : " no maxvalue");
            } else {
                print0(ucase ? " NOMAXVALUE" : " nomaxvalue");
            }
        }

        if (x.getMinValue() !is null) {
            print0(ucase ? " MINVALUE " : " minvalue ");
            x.getMinValue().accept(this);
        }

        if (x.isNoMinValue()) {
            if (DBType.POSTGRESQL.opEquals(dbType)) {
                print0(ucase ? " NO MINVALUE" : " no minvalue");
            } else {
                print0(ucase ? " NOMINVALUE" : " nominvalue");
            }
        }

        if (x.getCycle() !is null) {
            if (x.getCycle().booleanValue()) {
                print0(ucase ? " CYCLE" : " cycle");
            } else {
                if (DBType.POSTGRESQL.opEquals(dbType)) {
                    print0(ucase ? " NO CYCLE" : " no cycle");
                } else {
                    print0(ucase ? " NOCYCLE" : " nocycle");
                }
            }
        }

        Boolean cache = x.getCache();
        if (cache !is null) {
            if (cache.booleanValue()) {
                print0(ucase ? " CACHE" : " cache");

                SQLExpr cacheValue = x.getCacheValue();
                if (cacheValue !is null) {
                    print(' ');
                    cacheValue.accept(this);
                }
            } else {
                print0(ucase ? " NOCACHE" : " nocache");
            }
        }

        Boolean order = x.getOrder();
        if (order !is null) {
            if (order.booleanValue()) {
                print0(ucase ? " ORDER" : " order");
            } else {
                print0(ucase ? " NOORDER" : " noorder");
            }
        }

        return false;
    }

    override bool visit(SQLDateExpr x) {
        if (this.parameterized) {
            print('?');
            incrementReplaceCunt();

            if(this.parameters !is null){
                ExportParameterVisitorUtils.exportParameter(this.parameters, x);
            }
            return false;
        }

        SQLExpr literal = x.getLiteral();
        print0(ucase ? "DATE " : "date ");
        printExpr(literal);

        return false;
    }

    override bool visit(SQLLimit x) {
        print0(ucase ? "LIMIT " : "limit ");
        SQLExpr offset = x.getOffset();
        if (offset !is null) {
            printExpr(offset);
            print0(", ");
        }

        SQLExpr rowCount = x.getRowCount();
        printExpr(rowCount);

        return false;
    }

    override bool visit(SQLDescribeStatement x) {
        print0(ucase ? "DESC " : "desc ");
        if (x.getObjectType().name.length != 0) {
            print0(x.getObjectType().name);
            print(' ');
        }

        if(x.getObject() !is null) {
            x.getObject().accept(this);
        }

        if (x.getPartition().size() > 0) {
            print0(ucase ? " PARTITION (" : " partition (");
            printAndAccept!SQLExpr((x.getPartition()), ", ");
            print(')');
        }
        return false;
    }

    protected void printHierarchical(SQLSelectQueryBlock x) {
        SQLExpr startWith = x.getStartWith(), connectBy = x.getConnectBy();
        if (startWith !is null || connectBy !is null){
            println();
            if (x.getStartWith() !is null) {
                print0(ucase ? "START WITH " : "start with ");
                x.getStartWith().accept(this);
                println();
            }

            print0(ucase ? "CONNECT BY " : "connect by ");

            if (x.isNoCycle()) {
                print0(ucase ? "NOCYCLE " : "nocycle ");
            }

            if (x.isPrior()) {
                print0(ucase ? "PRIOR " : "prior ");
            }

            x.getConnectBy().accept(this);
        }
    }

    // void printOracleSegmentAttributes(OracleSegmentAttributes x) {

    //     if (x.getPctfree() !is null) {
    //         println();
    //         print0(ucase ? "PCTFREE " : "pctfree ");
    //         print(x.getPctfree());
    //     }

    //     if (x.getPctused() !is null) {
    //         println();
    //         print0(ucase ? "PCTUSED " : "pctused ");
    //         print(x.getPctused());
    //     }

    //     if (x.getInitrans() !is null) {
    //         println();
    //         print0(ucase ? "INITRANS " : "initrans ");
    //         print(x.getInitrans());
    //     }

    //     if (x.getMaxtrans() !is null) {
    //         println();
    //         print0(ucase ? "MAXTRANS " : "maxtrans ");
    //         print(x.getMaxtrans());
    //     }

    //     if (x.getCompress() == bool.FALSE) {
    //         println();
    //         print0(ucase ? "NOCOMPRESS" : "nocompress");
    //     } else if (x.getCompress() == bool.TRUE) {
    //         println();
    //         print0(ucase ? "COMPRESS" : "compress");

    //         if (x.getCompressLevel() !is null) {
    //             print(' ');
    //             print(x.getCompressLevel());
    //         }
    //     }

    //     if (x.getLogging() == bool.TRUE) {
    //         println();
    //         print0(ucase ? "LOGGING" : "logging");
    //     } else if (x.getLogging() == bool.FALSE) {
    //         println();
    //         print0(ucase ? "NOLOGGING" : "nologging");
    //     }

    //     if (x.getTablespace() !is null) {
    //         println();
    //         print0(ucase ? "TABLESPACE " : "tablespace ");
    //         x.getTablespace().accept(this);
    //     }

    //     if (x.getStorage() !is null) {
    //         println();
    //         x.getStorage().accept(this);
    //     }
    // }

    override
    bool visit(SQLWhileStatement x) {
        string label = x.getLabelName();

        if (label !is null && label.length != 0) {
            print0(x.getLabelName());
            print0(": ");
        }
        print0(ucase ? "WHILE " : "while ");
        x.getCondition().accept(this);
        print0(ucase ? " DO" : " do");
        println();
        for (int i = 0, size = x.getStatements().size(); i < size; ++i) {
            SQLStatement item = x.getStatements().get(i);
            item.accept(this);
            if (i != size - 1) {
                println();
            }
        }
        println();
        print0(ucase ? "END WHILE" : "end while");
        if (label !is null && label.length != 0) {
            print(' ');
            print0(label);
        }
        return false;
    }

    override
    bool visit(SQLDeclareStatement x) {
        // bool printDeclare = !(cast(OracleCreatePackageStatement)x.getParent() !is null);
        // if (printDeclare) {
        //     print0(ucase ? "DECLARE " : "declare ");
        // }  //@gxc
        this.printAndAccept!SQLDeclareItem((x.getItems()), ", ");
        return false;
    }

    override
    bool visit(SQLReturnStatement x) {
        print0(ucase ? "RETURN" : "return");

        if (x.getExpr() !is null) {
            print(' ');
            x.getExpr().accept(this);
        }
        return false;
    }

    override void postVisit(SQLObject x) {
        if (cast(SQLStatement)x !is null) {
            SQLStatement stmt = cast(SQLStatement) x;
            bool printSemi = printStatementAfterSemi is null
                    ? stmt.isAfterSemi()
                    : printStatementAfterSemi.booleanValue();
            if (printSemi) {
                print(';');
            }
        }
    }

    override
    bool visit(SQLArgument x) {
        SQLParameter.ParameterType type = x.getType();
        if (type.name.length != 0) {
            print0(type.name);
            print(' ');
        }

        x.getExpr().accept(this);
        return false;
    }

    override
    bool visit(SQLCommitStatement x) {
        print0(ucase ? "COMMIT" : "commit");

        if (x.isWrite()) {
            print0(ucase ? " WRITE" : " write");
            if (x.getWait() !is null) {
                if (x.getWait().booleanValue()) {
                    print0(ucase ? " WAIT" : " wait");
                } else {
                    print0(ucase ? " NOWAIT" : " nowait");
                }
            }

            if (x.getImmediate() !is null) {
                if (x.getImmediate().booleanValue()) {
                    print0(ucase ? " IMMEDIATE" : " immediate");
                } else {
                    print0(ucase ? " BATCH" : " batch");
                }
            }
        }

        if (x.isWork()) {
            print0(ucase ? " WORK" : " work");
        }

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

        return false;
    }

    override bool visit(SQLFlashbackExpr x) {
        print0(x.getType().name);
        print(' ');
        SQLExpr expr = x.getExpr();
        if (cast(SQLBinaryOpExpr)expr !is null) {
            print('(');
            expr.accept(this);
            print(')');
        } else {
            expr.accept(this);
        }
        return false;
    }

    override bool visit(SQLCreateMaterializedViewStatement x) {
        print0(ucase ? "CREATE MATERIALIZED VIEW " : "create materialized view ");
        x.getName().accept(this);

        SQLPartitionBy partitionBy = x.getPartitionBy();
        if (partitionBy !is null) {
            println();
            print0(ucase ? "PARTITION BY " : "partition by ");
            partitionBy.accept(this);
        }

        // this.printOracleSegmentAttributes(x);//@gxc
        println();

        Boolean cache = x.getCache();
        if (cache !is null) {
            print(cache.booleanValue ? "CACHE" : "NOCACHE");
            println();
        }

        auto parallel = x.getParallel();
        if (parallel !is null) {
            if (parallel.booleanValue) {
                print(ucase ? "PARALLEL" : "parallel");
                Integer parallelValue = x.getParallelValue();
                if (parallelValue !is null) {
                    print(' ');
                    print(parallelValue.intValue());
                }
            } else {
                print(ucase ? "NOPARALLEL" : "noparallel");
            }
            println();
        }

        if (x.isBuildImmediate()) {
            println(ucase ? "BUILD IMMEDIATE" : "build immediate");
        }

        if (x.isRefresh()) {
            print(ucase ? "REFRESH" : "refresh");

            if (x.isRefreshFast()) {
                print(ucase ? " FAST" : " fast");
            } else if (x.isRefreshComlete()) {
                print(ucase ? " COMPLETE" : " complete");
            } else if (x.isRefreshForce()) {
                print(ucase ? " FORCE" : " force");
            }

            if (x.isRefreshOnCommit()) {
                print(ucase ? " ON COMMIT" : " on commit");
            } else if (x.isRefreshOnDemand()) {
                print(ucase ? " ON DEMAND" : " on demand");
            }

            println();
        }

        Boolean enableQueryRewrite = x.getEnableQueryRewrite();
        if (enableQueryRewrite !is null) {
            if (enableQueryRewrite.booleanValue) {
                print(ucase ? "ENABLE QUERY REWRITE" : "enable query rewrite");
            } else {
                print(ucase ? "DISABLE QUERY REWRITE" : "disable query rewrite");
            }
            println();
        }

        println(ucase ? "AS" : "as");
        x.getQuery().accept(this);
        return false;
    }

    override bool visit(SQLCreateUserStatement x) {
        print0(ucase ? "CREATE USER " : "create user ");
        x.getUser().accept(this);
        print0(ucase ? " IDENTIFIED BY " : " identified by ");
        x.getPassword().accept(this);
        return false;
    }

    override bool visit(SQLAlterFunctionStatement x) {
        print0(ucase ? "ALTER FUNCTION " : "alter function ");
        x.getName().accept(this);

        if (x.isDebug()) {
            print0(ucase ? " DEBUG" : " debug");
        }

        if (x.isReuseSettings()) {
            print0(ucase ? " REUSE SETTINGS" : " reuse settings");
        }

        return false;
    }

    override bool visit(SQLAlterTypeStatement x) {
        print0(ucase ? "ALTER TYPE " : "alter type ");
        x.getName().accept(this);

        if (x.isCompile()) {
            print0(ucase ? " COMPILE" : " compile");
        }

        if (x.isBody()) {
            print0(ucase ? " BODY" : " body");
        }

        if (x.isDebug()) {
            print0(ucase ? " DEBUG" : " debug");
        }

        if (x.isReuseSettings()) {
            print0(ucase ? " REUSE SETTINGS" : " reuse settings");
        }

        return false;
    }

    override
    bool visit(SQLIntervalExpr x) {
        print0(ucase ? "INTERVAL " : "interval ");
        SQLExpr value = x.getValue();
        value.accept(this);

        SQLIntervalUnit unit = x.getUnit();
        if (unit.name.length != 0) {
            print(' ');
            print0(ucase ? unit.name : unit.name_lcase);
        }
        return false;
    }

    Boolean getPrintStatementAfterSemi() {
        return printStatementAfterSemi;
    }

    void setPrintStatementAfterSemi(Boolean printStatementAfterSemi) {
        this.printStatementAfterSemi = printStatementAfterSemi;
    }

    override void config(VisitorFeature feature, bool state) {
        super.config(feature, state);
        if (feature == VisitorFeature.OutputUCase) {
            this.ucase = state;
        } else if (feature == VisitorFeature.OutputParameterized) {
            this.parameterized = state;
        }
    }

    override void setFeatures(int features) {
        super.setFeatures(features);
        this.ucase = isEnabled(VisitorFeature.OutputUCase);
        this.parameterized = isEnabled(VisitorFeature.OutputParameterized);
        this.parameterizedQuesUnMergeInList = isEnabled(VisitorFeature.OutputParameterizedQuesUnMergeInList);
    }

    /////////////// for oracle
    // bool visit(OracleCursorExpr x) {
    //     print0(ucase ? "CURSOR(" : "cursor(");
    //     this.indentCount++;
    //     println();
    //     x.getQuery().accept(this);
    //     this.indentCount--;
    //     println();
    //     print(')');
    //     return false;
    // }

    // bool visit(OracleDatetimeExpr x) {
    //     x.getExpr().accept(this);
    //     SQLExpr timeZone = x.getTimeZone();

    //     if (cast(SQLIdentifierExpr)timeZone !is null) {
    //         if ((cast(SQLIdentifierExpr) timeZone).getName().equalsIgnoreCase("LOCAL")) {
    //             print0(ucase ? " AT LOCAL" : "alter session set ");
    //             return false;
    //         }
    //     }

    //     print0(ucase ? " AT TIME ZONE " : " at time zone ");
    //     timeZone.accept(this);

    //     return false;
    // }

    ///////////// for odps & hive
    override
    bool visit(SQLLateralViewTableSource x) {
        x.getTableSource().accept(this);
        this.indentCount++;
        println();
        print0(ucase ? "LATERAL VIEW " : "lateral view ");
        x.getMethod().accept(this);
        print(' ');
        print0(x.getAlias());
        print0(ucase ? " AS " : " as ");
        printAndAccept!SQLName((x.getColumns()), ", ");
        this.indentCount--;
        return false;
    }

    override
    bool visit(SQLShowErrorsStatement x) {
        print0(ucase ? "SHOW ERRORS" : "show errors");
        return true;
    }

    override
    bool visit(SQLAlterCharacter x) {
        print0(ucase ? "CHARACTER SET = " : "character set = ");
        x.getCharacterSet().accept(this);

        if (x.getCollate() !is null) {
            print0(ucase ? ", COLLATE = " : ", collate = ");
            x.getCollate().accept(this);
        }

        return false;
    }

    override
    bool visit(SQLRecordDataType x) {
        print0(ucase ? "RECORD (" : "record (");
        indentCount++;
        println();
        List!SQLColumnDefinition columns = x.getColumns();
        for (int i = 0; i < columns.size(); i++) {
            if (i != 0) {
                println();
            }
            columns.get(i).accept(this);
            if (i != columns.size() - 1) {
                print0(", ");
            }
        }
        indentCount--;
        println();
        print(')');

        return false;
    }

    override
    bool visit(SQLExprStatement x) {
        x.getExpr().accept(this);
        return false;
    }

    override
    bool visit(SQLBlockStatement x) {
        if (x.getParameters().size() != 0) {
            this.indentCount++;
            if (cast(SQLCreateProcedureStatement)x.getParent() !is null) {
                SQLCreateProcedureStatement procedureStatement = cast(SQLCreateProcedureStatement) x.getParent();
                if (procedureStatement.isCreate()) {
                    printIndent();
                }
            }
            if (!( cast(SQLCreateProcedureStatement)x.getParent() !is null
                    || cast(SQLCreateFunctionStatement)x.getParent() !is null
                    /*|| cast(OracleFunctionDataType)x.getParent() !is null
                    || cast(OracleProcedureDataType)x.getParent() !is null*/)
                    ) {
                print0(ucase ? "DECLARE" : "declare");
                println();
            }

            for (int i = 0, size = x.getParameters().size(); i < size; ++i) {
                if (i != 0) {
                    println();
                }
                SQLParameter param = x.getParameters().get(i);
                param.accept(this);
                print(';');
            }

            this.indentCount--;
            println();
        }
        print0(ucase ? "BEGIN" : "begin");
        this.indentCount++;

        for (int i = 0, size = x.getStatementList().size(); i < size; ++i) {
            println();
            SQLStatement stmt = x.getStatementList().get(i);
            stmt.accept(this);
        }
        this.indentCount--;

        SQLStatement exception = x.getException();
        if (exception !is null) {
            println();
            exception.accept(this);
        }

        println();
        print0(ucase ? "END;" : "end;");
        return false;
    }

    override
    bool visit(SQLCreateProcedureStatement x) {
        bool create = x.isCreate();
        if (!create) {
            print0(ucase ? "PROCEDURE " : "procedure ");
        } else if (x.isOrReplace()) {
            print0(ucase ? "CREATE OR REPLACE PROCEDURE " : "create or replace procedure ");
        } else {
            print0(ucase ? "CREATE PROCEDURE " : "create procedure ");
        }
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

        SQLName authid = x.getAuthid();
        if (authid !is null) {
            print(ucase ? " AUTHID " : " authid ");
            authid.accept(this);
        }

        SQLStatement block = x.getBlock();
        string wrappedSource = x.getWrappedSource();
        if (wrappedSource !is null) {
            print0(ucase ? " WRAPPED " : " wrapped ");
            print0(wrappedSource);
        } else {
            if (block !is null && !create) {
                println();
                print("IS");
                println();
            } else {
                println();
                if (cast(SQLBlockStatement)block !is null) {
                    SQLBlockStatement blockStatement = cast(SQLBlockStatement) block;
                    if (blockStatement.getParameters().size() > 0 || authid !is null) {
                        println(ucase ? "AS" : "as");
                    } else {
                        println(ucase ? "IS" : "is");
                    }
                }
            }

            string javaCallSpec = x.getJavaCallSpec();
            if (javaCallSpec !is null) {
                print0(ucase ? "LANGUAGE JAVA NAME '" : "language java name '");
                print0(javaCallSpec);
                print('\'');
                return false;
            }
        }

        bool afterSemi = false;
        if (block !is null) {
            block.accept(this);

            if (cast(SQLBlockStatement)block !is null
                    && (cast(SQLBlockStatement) block).getStatementList().size() > 0) {
                afterSemi = (cast(SQLBlockStatement) block).getStatementList().get(0).isAfterSemi();
            }
        }

        // if ((!afterSemi) && cast(OracleCreatePackageStatement)x.getParent() !is null) {
        //     print(';');
        // }
        return false;
    }

    override bool visit(SQLExternalRecordFormat x) {
        if (x.getDelimitedBy() !is null) {
            println();
            print0(ucase ? "RECORDS DELIMITED BY " : "records delimited by ");
            x.getDelimitedBy().accept(this);
        }

        if (x.getTerminatedBy() !is null) {
            println();
            print0(ucase ? "FIELDS TERMINATED BY " : "fields terminated by ");
            x.getTerminatedBy().accept(this);
        }

        return false;
    }

    override
    bool visit(SQLArrayDataType x) {
        print0(ucase ? "ARRAY<" : "array<");
        x.getComponentType().accept(this);
        print('>');
        return false;
    }

    override
    bool visit(SQLMapDataType x) {
        print0(ucase ? "MAP<" : "map<");
        x.getKeyType().accept(this);
        print0(", ");
        x.getValueType().accept(this);
        print('>');
        return false;
    }

    override
    bool visit(SQLStructDataType x) {
        print0(ucase ? "STRUCT<" : "struct<");
        printAndAccept!(SQLStructDataType.Field)((x.getFields()), ", ");
        print('>');
        return false;
    }

    override
    bool visit(SQLStructDataType.Field x) {
        x.getName().accept(this);
        print(':');
        x.getDataType().accept(this);
        print('>');
        return false;
    }

    override bool visit(SQLAlterTableRenameIndex x) {
        print0(ucase ? "RENAME INDEX " : "rename index ");
        x.getName().accept(this);
        print0(ucase ? " TO " : " to ");
        x.getTo().accept(this);
        return false;
    }

    override
    bool visit(SQLAlterTableExchangePartition x) {
        print0(ucase ? "EXCHANGE PARTITION " : "exchange partition ");
        x.getPartition().accept(this);
        print0(ucase ? " WITH TABLE " : " with table ");
        x.getTable().accept(this);

        auto validation = x.getValidation();
        if (validation !is null) {
            if (validation.booleanValue) {
                print0(ucase ? " WITH VALIDATION" : " with validation");
            } else {
                print0(ucase ? " WITHOUT VALIDATION" : " without validation");
            }
        }

        return false;
    }

    override
    bool visit(SQLValuesExpr x) {
        print0(ucase ? "VALUES (" : "values (");
        printAndAccept!SQLListExpr((x.getValues()), ", ");
        return false;
    }

    override
    bool visit(SQLValuesTableSource x) {
        List!SQLName columns = x.getColumns();

        if (columns.size() > 0) {
            print('(');
        }
        print0(ucase ? "VALUES " : "values ");
        printAndAccept!SQLListExpr((x.getValues()), ", ");

        if (columns.size() > 0) {
            print(") ");
        }

        print0(ucase ? "AS " : "as ");
        print0(x.getAlias());
        print0(" (");
        printAndAccept!SQLName(columns, ", ");
        print(')');

        return false;
    }

    override bool visit(SQLContainsExpr x) {
        SQLExpr expr = x.getExpr();
        if (expr !is null) {
            printExpr(expr);
            print(' ');
        }

        if (x.isNot()) {
            print0(ucase ? "NOT CONTAINS (" : " not contains (");
        } else {
            print0(ucase ? "CONTAINS (" : " contains (");
        }

         List!SQLExpr list = x.getTargetList();

        bool printLn = false;
        if (list.size() > 5) {
            printLn = true;
            for (int i = 0, size = list.size(); i < size; ++i) {
                if (!(cast(SQLCharExpr)list.get(i) !is null)) {
                    printLn = false;
                    break;
                }
            }
        }

        if (printLn) {
            this.indentCount++;
            println();
            for (int i = 0, size = list.size(); i < size; ++i) {
                if (i != 0) {
                    print0(", ");
                    println();
                }
                SQLExpr item = list.get(i);
                printExpr(item);
            }
            this.indentCount--;
            println();
        } else {
            List!SQLExpr targetList = x.getTargetList();
            for (int i = 0; i < targetList.size(); i++) {
                if (i != 0) {
                    print0(", ");
                }
                printExpr(targetList.get(i));
            }
        }

        print(')');
        return false;
    }

    override bool visit(SQLRealExpr x) {
        float value = (cast(Float)(x.getValue())).floatValue;
        print0(ucase ? "REAL '" : "real '");
        print(value);
        print('\'');

        return false;
    }

    override
    bool visit(SQLWindow x) {
        x.getName().accept(this);
        print0(ucase ? " AS " : " as ");
        x.getOver().accept(this);
        return false;
    }

    override
    bool visit(SQLDumpStatement x) {
        List!SQLCommentHint headHints = x.getHeadHintsDirect();
        if (headHints !is null) {
            foreach(SQLCommentHint hint  ;  headHints) {
                hint.accept(this);
                println();
            }
        }

        print0(ucase ? "DUMP DATA " : "dump data ");


        if (x.isOverwrite()) {
            print0(ucase ? "OVERWRITE " : "overwrite ");
        }

        SQLExprTableSource into = x.getInto();
        if (into !is null) {
            into.accept(this);
        }

        x.getSelect().accept(this);
        return false;
    }

    void print(float value) {
        if (this.appender is null) {
            return;
        }

        if (cast(StringBuilder)appender !is null) {
            (cast(StringBuilder) appender).append(value);
        } else if (cast(StringBuilder)appender !is null) {
            (cast(StringBuilder) appender).append(value);
        } else {
            print0(to!string(value));
        }
    }
}