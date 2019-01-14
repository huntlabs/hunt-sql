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
module hunt.sql.visitor.SchemaStatVisitor;


import std.string;
import std.uni;
import hunt.collection;
import std.array;
import hunt.String;
import hunt.sql.SQLUtils;
import hunt.sql.ast;
import hunt.sql.ast.expr;
import hunt.sql.ast.statement;
import hunt.sql.dialect.mysql.ast.expr.MySqlExpr;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitorAdapter;
import hunt.sql.ast.statement.SQLLateralViewTableSource;
// import hunt.sql.dialect.odps.ast.OdpsValuesTableSource;
// import hunt.sql.dialect.oracle.ast.expr.OracleDbLinkExpr;
// import hunt.sql.dialect.oracle.ast.expr.OracleExpr;
import hunt.sql.dialect.postgresql.visitor.PGASTVisitorAdapter;
import hunt.sql.repository.SchemaObject;
import hunt.sql.repository.SchemaRepository;
import hunt.sql.stat.TableStat;
// import hunt.sql.stat.TableStat.Column;
// import hunt.sql.stat.TableStat.Condition;
// import hunt.sql.stat.TableStat.Mode;
// import hunt.sql.stat.TableStat.Relationship;
import hunt.sql.util.FnvHash;
import hunt.sql.util.DBType;
import hunt.sql.visitor.SQLASTVisitorAdapter;
import hunt.Long;
import hunt.Boolean;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.visitor.SQLEvalVisitorUtils;
import hunt.sql.visitor.SQLEvalVisitor;
import hunt.text;

public class SchemaStatVisitor : SQLASTVisitorAdapter {

    alias visit = SQLASTVisitorAdapter.visit;
    alias endVisit = SQLASTVisitorAdapter.endVisit;

    protected SchemaRepository repository;

    protected  HashMap!(TableStat.Name, TableStat) tableStats  ;
    protected  Map!(Long, TableStat.Column)                  columns       ;
    protected  List!(TableStat.Condition)                    conditions    ;
    protected  Set!(TableStat.Relationship)                  relationships ;
    protected  List!(TableStat.Column)                       orderByColumns;
    protected  Set!(TableStat.Column)                        groupByColumns;
    protected  List!(SQLAggregateExpr)             aggregateFunctions;
    protected  List!(SQLMethodInvokeExpr)          functions         ;

    private List!(Object) parameters;

    private TableStat.Mode mode;

    protected string dbType;

    public this(){
        this(cast(string) null);
    }

    public this(string dbType){
        this(new SchemaRepository(dbType), new ArrayList!(Object)());
        this.dbType = dbType;
    }

    public SchemaRepository getRepository() {
        return repository;
    }

    public void setRepository(SchemaRepository repository) {
        this.repository = repository;
    }

    public this(List!(Object) parameters){
        this(cast(string) null, parameters);
    }

    public this(string dbType, List!(Object) parameters){
        this(new SchemaRepository(dbType), parameters);
        this.parameters = parameters;
    }

    public this(SchemaRepository repository, List!(Object) parameters){
        tableStats     = new LinkedHashMap!(TableStat.Name, TableStat);
        columns        = new LinkedHashMap!(Long, TableStat.Column)();
        conditions     = new ArrayList!(TableStat.Condition)();
        relationships  = new LinkedHashSet!(TableStat.Relationship)();
        orderByColumns = new ArrayList!(TableStat.Column)();
        groupByColumns = new LinkedHashSet!(TableStat.Column)();
        aggregateFunctions = new ArrayList!(SQLAggregateExpr)();
        functions          = new ArrayList!(SQLMethodInvokeExpr)(2);

        this.repository = repository;
        this.parameters = parameters;
        if (repository !is null) {
            string dbType = repository.getDbType();
            if (dbType !is null && this.dbType is null) {
                this.dbType = dbType;
            }
        }
    }

    public List!(Object) getParameters() {
        return parameters;
    }

    public void setParameters(List!(Object) parameters) {
        this.parameters = parameters;
    }

    public TableStat getTableStat(string tableName) {
        tableName = handleName(tableName);

        TableStat.Name tableNameObj = new TableStat.Name(tableName);
        TableStat stat = tableStats.get(tableNameObj);
        if (stat is null) {
            stat = new TableStat();
            tableStats.put(new TableStat.Name(tableName), stat);
        }
        return stat;
    }

    public TableStat getTableStat(SQLName tableName) {
        string strName = (cast(Object)(tableName)).toString();
        long hashCode64 = tableName.hashCode64();

        if (hashCode64 == FnvHash.Constants.DUAL) {
            return null;
        }

        TableStat.Name tableNameObj = new TableStat.Name(strName, hashCode64);
        TableStat stat = tableStats.get(tableNameObj);
        if (stat is null) {
            stat = new TableStat();
            tableStats.put(new TableStat.Name(strName, hashCode64), stat);
        }
        return stat;
    }

    protected TableStat.Column addColumn(string tableName, string columnName) {
        TableStat.Column column = this.getColumn(tableName, columnName);
        if (column is null && columnName !is null) {
            column = new TableStat.Column(tableName, columnName);
            columns.put(new Long(column.hashCode64()), column);
        }
        return column;
    }

    protected TableStat.Column addColumn(SQLName table, string columnName) {
        string tableName = (cast(Object)(table)).toString();
        long tableHashCode64 = table.hashCode64();

        long basic = tableHashCode64;
        basic ^= '.';
        basic *= FnvHash.PRIME;
        long columnHashCode64 = FnvHash.hashCode64(basic, columnName);

        TableStat.Column column = this.columns.get(new Long(columnHashCode64));
        if (column is null && columnName !is null) {
            column = new TableStat.Column(tableName, columnName, columnHashCode64);
            columns.put(new Long(columnHashCode64), column);
        }
        return column;
    }

    private string handleName(string ident) {
        int len = cast(int)(ident.length);
        if (charAt(ident, 0) == '[' && charAt(ident, len - 1) == ']') {
            ident = ident.substring(1, len - 1);
        } else {
            bool flag0 = false;
            bool flag1 = false;
            bool flag2 = false;
            bool flag3 = false;
            for (int i = 0; i < len; ++i) {
                 char ch = charAt(ident, i);
                if (ch == '\"') {
                    flag0 = true;
                } else if (ch == '`') {
                    flag1 = true;
                } else if (ch == ' ') {
                    flag2 = true;
                } else if (ch == '\'') {
                    flag3 = true;
                }
            }
            if (flag0) {
                ident = ident.replace("\"", "");
            }

            if (flag1) {
                ident = ident.replace("`", "");
            }

            if (flag2) {
                ident = ident.replace(" ", "");
            }

            if (flag3) {
                ident = ident.replace("'", "");
            }
        }
        return ident;
    }

    protected TableStat.Mode getMode() {
        return mode;
    }

    protected void setModeOrigin(SQLObject x) {
        TableStat.Mode originalMode = cast(TableStat.Mode) x.getAttribute("_original_use_mode");
        mode = originalMode;
    }

    protected TableStat.Mode setMode(SQLObject x, const TableStat.Mode mode) {
        TableStat.Mode oldMode = this.mode;
        x.putAttribute("_original_use_mode", oldMode);
        this.mode = cast(TableStat.Mode)mode;
        return oldMode;
    }

    private bool visitOrderBy(SQLIdentifierExpr x) {
        SQLTableSource tableSource = x.getResolvedTableSource();

        string tableName = null;
        if (cast(SQLExprTableSource)(tableSource) !is null) {
            SQLExpr expr = (cast(SQLExprTableSource) tableSource).getExpr();
            if (cast(SQLIdentifierExpr)(expr) !is null) {
                SQLIdentifierExpr table = cast(SQLIdentifierExpr) expr;
                tableName = table.getName();
            } else if (cast(SQLPropertyExpr)(expr) !is null) {
                SQLPropertyExpr table = cast(SQLPropertyExpr) expr;
                tableName = (cast(Object)(table)).toString();
            } else if (cast(SQLMethodInvokeExpr)(expr) !is null) {
                SQLMethodInvokeExpr methodInvokeExpr = cast(SQLMethodInvokeExpr) expr;
                if ("table".equalsIgnoreCase(methodInvokeExpr.getMethodName())
                        && methodInvokeExpr.getParameters().size() == 1
                        && cast(SQLName)methodInvokeExpr.getParameters().get(0) !is null) {
                    SQLName table = cast(SQLName) methodInvokeExpr.getParameters().get(0);

                    if (cast(SQLPropertyExpr)table !is null) {
                        SQLPropertyExpr propertyExpr = cast(SQLPropertyExpr) table;
                        SQLIdentifierExpr owner = cast(SQLIdentifierExpr) propertyExpr.getOwner();
                        if (propertyExpr.getResolvedTableSource() !is null
                                && (cast(SQLExprTableSource) propertyExpr.getResolvedTableSource()) !is null) {
                            SQLExpr resolveExpr = (cast(SQLExprTableSource) propertyExpr.getResolvedTableSource()).getExpr();
                            if (cast(SQLName)(resolveExpr) !is null) {
                                tableName = (cast(Object)(resolveExpr)).toString() ~ "." ~ propertyExpr.getName();
                            }
                        }
                    }

                    if (tableName is null) {
                        tableName = (cast(Object)(table)).toString();
                    }
                }
            }
        } else if (cast(SQLWithSubqueryClause.Entry)(tableSource) !is null) {
            return false;
        } else if (cast(SQLSubqueryTableSource)(tableSource) !is null) {
            SQLSelectQueryBlock queryBlock = (cast(SQLSubqueryTableSource) tableSource).getSelect().getQueryBlock();
            if (queryBlock is null) {
                return false;
            }

            SQLSelectItem selectItem = queryBlock.findSelectItem(x.nameHashCode64());
            if (selectItem is null) {
                return false;
            }

            SQLExpr selectItemExpr = selectItem.getExpr();
            SQLTableSource columnTableSource = null;
            if (cast(SQLIdentifierExpr)(selectItemExpr) !is null) {
                columnTableSource = (cast(SQLIdentifierExpr) selectItemExpr).getResolvedTableSource();
            } else if (cast(SQLPropertyExpr)(selectItemExpr) !is null) {
                columnTableSource = (cast(SQLPropertyExpr) selectItemExpr).getResolvedTableSource();
            }

            if (cast(SQLExprTableSource)(columnTableSource) !is null && cast(SQLName) (cast(SQLExprTableSource) columnTableSource).getExpr() !is null) {
                SQLName tableExpr = cast(SQLName) (cast(SQLExprTableSource) columnTableSource).getExpr();
                if (cast(SQLIdentifierExpr)(tableExpr) !is null) {
                    tableName = (cast(SQLIdentifierExpr) tableExpr).normalizedName();
                } else if (cast(SQLPropertyExpr)(tableExpr) !is null) {
                    tableName = (cast(SQLPropertyExpr) tableExpr).normalizedName();
                }
            }
        } else {
            bool skip = false;
            for (SQLObject parent = x.getParent();parent !is null;parent = parent.getParent()) {
                if (cast(SQLSelectQueryBlock)(parent) !is null) {
                    SQLTableSource from = (cast(SQLSelectQueryBlock) parent).getFrom();

                    // if (cast(OdpsValuesTableSource)(from) !is null) {
                    //     skip = true;
                    //     break;
                    // }//@gxc
                } else if (cast(SQLSelectQuery)(parent) !is null) {
                    break;
                }
            }
        }

        string identName = x.getName();
        if (tableName !is null) {
            orderByAddColumn(tableName, identName, x);
        } else {
            orderByAddColumn("UNKOWN", identName, x);
        }
        return false;
    }

    private bool visitOrderBy(SQLPropertyExpr x) {
        if (isSubQueryOrParamOrVariant(x)) {
            return false;
        }

        string owner = null;

        SQLTableSource tableSource = x.getResolvedTableSource();
        if (cast(SQLExprTableSource)(tableSource) !is null) {
            SQLExpr tableSourceExpr = (cast(SQLExprTableSource) tableSource).getExpr();
            if (cast(SQLName)(tableSourceExpr) !is null) {
                owner = (cast(Object)(tableSourceExpr)).toString();
            }
        }

        if (owner is null && (cast(SQLIdentifierExpr) x.getOwner()).getName() !is null) {
            owner = (cast(SQLIdentifierExpr) x.getOwner()).getName();
        }

        if (owner is null) {
            return false;
        }

        if (owner !is null) {
            orderByAddColumn(owner, x.getName(), x);
        }

        return false;
    }

    private void orderByAddColumn(string table, string columnName, SQLObject expr) {
        TableStat.Column column = new TableStat.Column(table, columnName);

        SQLObject parent = expr.getParent();
        if (cast(SQLSelectOrderByItem)(parent) !is null) {
            SQLOrderingSpecification type = (cast(SQLSelectOrderByItem) parent).getType();
            column.getAttributes().put("orderBy.type", cast(Object)type);
        }

        orderByColumns.add(column);
    }

    protected class OrderByStatVisitor : SQLASTVisitorAdapter {

        alias visit = SQLASTVisitorAdapter.visit;
        alias endVisit = SQLASTVisitorAdapter.endVisit;

        private  SQLOrderBy orderBy;

        public this(SQLOrderBy orderBy){
            this.orderBy = orderBy;
            foreach(SQLSelectOrderByItem item ; orderBy.getItems()) {
                item.getExpr().setParent(item);
            }
        }

        public SQLOrderBy getOrderBy() {
            return orderBy;
        }

        override public bool visit(SQLIdentifierExpr x) {
            return visitOrderBy(x);
        }

        override public bool visit(SQLPropertyExpr x) {
            return visitOrderBy(x);
        }
    }

    protected class MySqlOrderByStatVisitor : MySqlASTVisitorAdapter {

        alias visit = MySqlASTVisitorAdapter.visit;
        alias endVisit = MySqlASTVisitorAdapter.endVisit;

        private  SQLOrderBy orderBy;

        public this(SQLOrderBy orderBy){
            this.orderBy = orderBy;
            foreach(SQLSelectOrderByItem item ; orderBy.getItems()) {
                item.getExpr().setParent(item);
            }
        }

        public SQLOrderBy getOrderBy() {
            return orderBy;
        }

        override public bool visit(SQLIdentifierExpr x) {
            return visitOrderBy(x);
        }

        override public bool visit(SQLPropertyExpr x) {
            return visitOrderBy(x);
        }
    }

    protected class PGOrderByStatVisitor : PGASTVisitorAdapter {

        alias visit = PGASTVisitorAdapter.visit;
        alias endVisit = PGASTVisitorAdapter.endVisit;

        private  SQLOrderBy orderBy;

        public this(SQLOrderBy orderBy){
            this.orderBy = orderBy;
            foreach(SQLSelectOrderByItem item ; orderBy.getItems()) {
                item.getExpr().setParent(item);
            }
        }

        public SQLOrderBy getOrderBy() {
            return orderBy;
        }

        override public bool visit(SQLIdentifierExpr x) {
            return visitOrderBy(x);
        }

        override public bool visit(SQLPropertyExpr x) {
            return visitOrderBy(x);
        }
    }

    protected class OracleOrderByStatVisitor : PGASTVisitorAdapter {

        alias visit = PGASTVisitorAdapter.visit;
        alias endVisit = PGASTVisitorAdapter.endVisit;
        
        private  SQLOrderBy orderBy;

        public this(SQLOrderBy orderBy){
            this.orderBy = orderBy;
            foreach(SQLSelectOrderByItem item ; orderBy.getItems()) {
                item.getExpr().setParent(item);
            }
        }

        public SQLOrderBy getOrderBy() {
            return orderBy;
        }

        override public bool visit(SQLIdentifierExpr x) {
            return visitOrderBy(x);
        }

        override public bool visit(SQLPropertyExpr x) {
            SQLExpr unwrapped = unwrapExpr(x);
            if (cast(SQLPropertyExpr)(unwrapped) !is null) {
                visitOrderBy(cast(SQLPropertyExpr) unwrapped);
            } else if (cast(SQLIdentifierExpr)(unwrapped) !is null) {
                visitOrderBy(cast(SQLIdentifierExpr) unwrapped);
            }
            return false;
        }
    }

    override public bool visit(SQLOrderBy x) {
         SQLASTVisitor orderByVisitor = createOrderByVisitor(x);

        SQLSelectQueryBlock query = null;
        if ( cast(SQLSelectQueryBlock) x.getParent() !is null) {
            query = cast(SQLSelectQueryBlock) x.getParent();
        }
        if (query !is null) {
            foreach(SQLSelectOrderByItem item ; x.getItems()) {
                SQLExpr expr = item.getExpr();
                if (cast(SQLIntegerExpr)(expr) !is null) {
                    int intValue = (cast(SQLIntegerExpr) expr).getNumber().intValue() - 1;
                    if (intValue < query.getSelectList().size()) {
                        SQLSelectItem selectItem = query.getSelectList().get(intValue);
                        selectItem.getExpr().accept(orderByVisitor);
                    }
                } else if (cast(MySqlExpr)(expr) !is null /* || cast(OracleExpr)(expr) !is null */) {
                    continue;
                }
            }
        }
        x.accept(orderByVisitor);

        foreach(SQLSelectOrderByItem orderByItem ; x.getItems()) {
            statExpr(
                    orderByItem.getExpr());
        }

        return false;
    }

    override public bool visit(SQLOver x) {
        SQLName of = x.getOf();
        SQLOrderBy orderBy = x.getOrderBy();
        List!(SQLExpr) partitionBy = x.getPartitionBy();


        if (of is null // skip if of is not null
                && orderBy !is null) {
            orderBy.accept(this);
        }

        if (partitionBy !is null) {
            foreach(SQLExpr expr ; partitionBy) {
                expr.accept(this);
            }
        }

        return false;
    }

    protected SQLASTVisitor createOrderByVisitor(SQLOrderBy x) {
         SQLASTVisitor orderByVisitor;
        if (DBType.MYSQL.opEquals(dbType)) {
            orderByVisitor = new MySqlOrderByStatVisitor(x);
        } else if (DBType.POSTGRESQL.opEquals(dbType)) {
            orderByVisitor = new PGOrderByStatVisitor(x);
        } else if (DBType.ORACLE.opEquals(dbType)) {
            orderByVisitor = new OracleOrderByStatVisitor(x);
        } else {
            orderByVisitor = new OrderByStatVisitor(x);
        }
        return orderByVisitor;
    }

    public Set!(TableStat.Relationship) getRelationships() {
        return relationships;
    }

    public List!(TableStat.Column) getOrderByColumns() {
        return orderByColumns;
    }

    public Set!(TableStat.Column) getGroupByColumns() {
        return groupByColumns;
    }

    public List!(TableStat.Condition) getConditions() {
        return conditions;
    }
    
    public List!(SQLAggregateExpr) getAggregateFunctions() {
        return aggregateFunctions;
    }

    override public bool visit(SQLBetweenExpr x) {
        SQLObject parent = x.getParent();

        SQLExpr test = x.getTestExpr();
        SQLExpr begin = x.getBeginExpr();
        SQLExpr end = x.getEndExpr();

        statExpr(test);
        statExpr(begin);
        statExpr(end);

        handleCondition(test, "BETWEEN", begin, end);

        return false;
    }

    override public bool visit(SQLBinaryOpExpr x) {
        SQLObject parent = x.getParent();

        if (cast(SQLIfStatement)(parent) !is null) {
            return true;
        }

         SQLBinaryOperator op = x.getOperator();
         SQLExpr left = x.getLeft();
         SQLExpr right = x.getRight();

        switch (op.name) {
            case SQLBinaryOperator.Equality.name:
            case SQLBinaryOperator.NotEqual.name:
            case SQLBinaryOperator.GreaterThan.name:
            case SQLBinaryOperator.GreaterThanOrEqual.name:
            case SQLBinaryOperator.LessThan.name:
            case SQLBinaryOperator.LessThanOrGreater.name:
            case SQLBinaryOperator.LessThanOrEqual.name:
            case SQLBinaryOperator.LessThanOrEqualOrGreaterThan.name:
            case SQLBinaryOperator.Like.name:
            case SQLBinaryOperator.NotLike.name:
            case SQLBinaryOperator.Is.name:
            case SQLBinaryOperator.IsNot.name:
                handleCondition(left, x.getOperator().name, right);
                handleCondition(right, x.getOperator().name, left);

                handleRelationship(left, x.getOperator().name, right);
                break;
            case SQLBinaryOperator.BooleanOr.name: {
                List!(SQLExpr) list = SQLBinaryOpExpr.split(x, op);

                foreach(SQLExpr item ; list) {
                    if (cast(SQLBinaryOpExpr)(item) !is null) {
                        visit(cast(SQLBinaryOpExpr) item);
                    } else {
                        item.accept(this);
                    }
                }

                return false;
            }
            case SQLBinaryOperator.Modulus.name:
                if (cast(SQLIdentifierExpr)(right) !is null) {
                    long hashCode64 = (cast(SQLIdentifierExpr) right).hashCode64();
                    if (hashCode64 == FnvHash.Constants.ISOPEN) {
                        left.accept(this);
                        return false;
                    }
                }
                break;
            default:
                break;
        }

        statExpr(left);
        statExpr(right);

        return false;
    }

    protected void handleRelationship(SQLExpr left, string operator, SQLExpr right) {
        TableStat.Column leftColumn = getColumn(left);
        if (leftColumn is null) {
            return;
        }

        TableStat.Column rightColumn = getColumn(right);
        if (rightColumn is null) {
            return;
        }

        TableStat.Relationship relationship = new TableStat.Relationship(leftColumn, rightColumn, operator);
        this.relationships.add(relationship);
    }

    protected void handleCondition(SQLExpr expr, string operator, List!(SQLExpr) values) {
        handleCondition(expr, operator, values.toArray());
    }

    protected void handleCondition(SQLExpr expr, string operator, SQLExpr[] valueExprs...) {
        if (cast(SQLCastExpr)(expr) !is null) {
            expr = (cast(SQLCastExpr) expr).getExpr();
        }
        
        TableStat.Column column = getColumn(expr);
        if (column is null) {
            return;
        }
        
        TableStat.Condition condition = null;
        foreach(TableStat.Condition item ; this.getConditions()) {
            if (item.getColumn().opEquals(column) && item.getOperator() == (operator)) {
                condition = item;
                break;
            }
        }

        if (condition is null) {
            condition = new TableStat.Condition(column, operator);
            this.conditions.add(condition);
        }

        foreach(SQLExpr item ; valueExprs) {
            TableStat.Column valueColumn = getColumn(item);
            if (valueColumn !is null) {
                continue;
            }

            Object value;
            if (cast(SQLMethodInvokeExpr)(item) !is null) {
                value = (cast(Object)(item));
            } else {
                value = SQLEvalVisitorUtils.eval(dbType, item, parameters, false);
                if (value == SQLEvalVisitor.EVAL_VALUE_NULL) {
                    value = null;
                }
            }

            condition.addValue(value);
        }
    }

    public string getDbType() {
        return dbType;
    }

    protected TableStat.Column getColumn(SQLExpr expr) {
         SQLExpr original = expr;

        // unwrap
        expr = unwrapExpr(expr);

        if (cast(SQLPropertyExpr)(expr) !is null) {
            SQLPropertyExpr propertyExpr = cast(SQLPropertyExpr) expr;

            SQLExpr owner = propertyExpr.getOwner();
            string column = propertyExpr.getName();

            if (cast(SQLName)(owner) !is null) {
                SQLName table = cast(SQLName) owner;

                SQLObject resolvedOwnerObject = propertyExpr.getResolvedOwnerObject();
                if (cast(SQLSubqueryTableSource)(resolvedOwnerObject) !is null
                        || cast(SQLCreateProcedureStatement)(resolvedOwnerObject) !is null
                        || cast(SQLCreateFunctionStatement)(resolvedOwnerObject) !is null) {
                    table = null;
                }

                if (cast(SQLExprTableSource)(resolvedOwnerObject) !is null) {
                    SQLExpr tableSourceExpr = (cast(SQLExprTableSource) resolvedOwnerObject).getExpr();
                    if (cast(SQLName)(tableSourceExpr) !is null) {
                        table = cast(SQLName) tableSourceExpr;
                    }
                }

                if (table !is null) {
                    long tableHashCode64 = table.hashCode64();

                    long basic = tableHashCode64;
                    basic ^= '.';
                    basic *= FnvHash.PRIME;
                    long columnHashCode64 = FnvHash.hashCode64(basic, column);

                    return new TableStat.Column((cast(Object)(table)).toString(), column, columnHashCode64);
                }
            }

            return null;
        }

        if (cast(SQLIdentifierExpr)(expr) !is null) {
            SQLIdentifierExpr identifierExpr = cast(SQLIdentifierExpr) expr;
            if (identifierExpr.getResolvedParameter() !is null) {
                return null;
            }

            if (cast(SQLSubqueryTableSource)identifierExpr.getResolvedTableSource() !is null) {
                return null;
            }

            if (identifierExpr.getResolvedDeclareItem() !is null || identifierExpr.getResolvedParameter() !is null) {
                return null;
            }

            string column = identifierExpr.getName();

            SQLName table = null;
            SQLTableSource tableSource = identifierExpr.getResolvedTableSource();
            if (cast(SQLExprTableSource)(tableSource) !is null) {
                SQLExpr tableSourceExpr = (cast(SQLExprTableSource) tableSource).getExpr();

                if (tableSourceExpr !is null && !(cast(SQLName)(tableSourceExpr) !is null)) {
                    tableSourceExpr = unwrapExpr(tableSourceExpr);
                }

                if (cast(SQLName)(tableSourceExpr) !is null) {
                    table = cast(SQLName) tableSourceExpr;
                }
            }

            if (table !is null) {
                long tableHashCode64 = table.hashCode64();
                long basic = tableHashCode64;
                basic ^= '.';
                basic *= FnvHash.PRIME;
                long columnHashCode64 = FnvHash.hashCode64(basic, column);

                return new TableStat.Column((cast(Object)(table)).toString(), column, columnHashCode64);
            }

            return new TableStat.Column("UNKNOWN", column);
        }

        if (cast(SQLMethodInvokeExpr)(expr) !is null) {
            SQLMethodInvokeExpr methodInvokeExpr = cast(SQLMethodInvokeExpr) expr;
            List!(SQLExpr) arguments = methodInvokeExpr.getParameters();
            long nameHash = methodInvokeExpr.methodNameHashCode64();
            if (nameHash == FnvHash.Constants.DATE_FORMAT) {
                if (arguments.size() == 2
                        && cast(SQLName)arguments.get(0) !is null
                        && cast(SQLCharExpr)arguments.get(1) !is null) {
                    return getColumn(arguments.get(0));
                }
            }
        }

        return null;
    }

    private SQLExpr unwrapExpr(SQLExpr expr) {
        SQLExpr original = expr;

        for (;;) {
            if (cast(SQLMethodInvokeExpr)(expr) !is null) {
                SQLMethodInvokeExpr methodInvokeExp = cast(SQLMethodInvokeExpr) expr;
                if (methodInvokeExp.getParameters().size() == 1) {
                    SQLExpr firstExpr = methodInvokeExp.getParameters().get(0);
                    expr = firstExpr;
                    continue;
                }
            }

            if (cast(SQLCastExpr)(expr) !is null) {
                expr = (cast(SQLCastExpr) expr).getExpr();
                continue;
            }

            if (cast(SQLPropertyExpr)(expr) !is null) {
                SQLPropertyExpr propertyExpr = cast(SQLPropertyExpr) expr;

                SQLTableSource resolvedTableSource = propertyExpr.getResolvedTableSource();
                if (cast(SQLSubqueryTableSource)(resolvedTableSource) !is null) {
                    SQLSelect select = (cast(SQLSubqueryTableSource) resolvedTableSource).getSelect();
                    SQLSelectQueryBlock queryBlock = select.getFirstQueryBlock();
                    if (queryBlock !is null) {
                        if (queryBlock.getGroupBy() !is null) {
                            if (cast(SQLBinaryOpExpr)original.getParent() !is null) {
                                SQLExpr other = (cast(SQLBinaryOpExpr) original.getParent()).other(original);
                                if (!SQLExprUtils.isLiteralExpr(other)) {
                                    break;
                                }
                            }
                        }

                        SQLSelectItem selectItem = queryBlock.findSelectItem(propertyExpr
                                .nameHashCode64());
                        if (selectItem !is null) {
                            expr = selectItem.getExpr();
                            continue;

                        } else if (queryBlock.selectItemHasAllColumn()) {
                            SQLTableSource allColumnTableSource = null;

                            SQLTableSource from = queryBlock.getFrom();
                            if (cast(SQLJoinTableSource)(from) !is null) {
                                SQLSelectItem allColumnSelectItem = queryBlock.findAllColumnSelectItem();
                                if (allColumnSelectItem !is null && cast(SQLPropertyExpr) allColumnSelectItem.getExpr() !is null) {
                                    SQLExpr owner = (cast(SQLPropertyExpr) allColumnSelectItem.getExpr()).getOwner();
                                    if (cast(SQLName)(owner) !is null) {
                                        allColumnTableSource = from.findTableSource((cast(SQLName) owner).nameHashCode64());
                                    }
                                }
                            } else {
                                allColumnTableSource = from;
                            }

                            if (allColumnTableSource is null) {
                                break;
                            }

                            propertyExpr = propertyExpr.clone();
                            propertyExpr.setResolvedTableSource(allColumnTableSource);

                            if (cast(SQLExprTableSource)(allColumnTableSource) !is null) {
                                propertyExpr.setOwner((cast(SQLExprTableSource) allColumnTableSource).getExpr().clone());
                            }
                            expr = propertyExpr;
                            continue;
                        }
                    }
                } else if (cast(SQLExprTableSource)(resolvedTableSource) !is null) {
                    SQLExprTableSource exprTableSource = cast(SQLExprTableSource) resolvedTableSource;
                    if (exprTableSource.getSchemaObject() !is null) {
                        break;
                    }

                    SQLTableSource redirectTableSource = null;
                    SQLExpr tableSourceExpr = exprTableSource.getExpr();
                    if (cast(SQLIdentifierExpr)(tableSourceExpr) !is null) {
                        redirectTableSource = (cast(SQLIdentifierExpr) tableSourceExpr).getResolvedTableSource();
                    } else if (cast(SQLPropertyExpr)(tableSourceExpr) !is null) {
                        redirectTableSource = (cast(SQLPropertyExpr) tableSourceExpr).getResolvedTableSource();
                    }

                    if (redirectTableSource == resolvedTableSource) {
                        redirectTableSource = null;
                    }

                    if (redirectTableSource !is null) {
                        propertyExpr = propertyExpr.clone();
                        if (cast(SQLExprTableSource)(redirectTableSource) !is null) {
                            propertyExpr.setOwner((cast(SQLExprTableSource) redirectTableSource).getExpr().clone());
                        }
                        propertyExpr.setResolvedTableSource(redirectTableSource);
                        expr = propertyExpr;
                        continue;
                    }

                    propertyExpr = propertyExpr.clone();
                    propertyExpr.setOwner(tableSourceExpr);
                    expr = propertyExpr;
                    break;
                }
            }
            break;
        }

        return expr;
    }

    override
    public bool visit(SQLTruncateStatement x) {
        setMode(x, TableStat.Mode.Delete);

        foreach(SQLExprTableSource tableSource ; x.getTableSources()) {
            SQLName name = cast(SQLName) tableSource.getExpr();
            TableStat stat = getTableStat(name);
            stat.incrementDeleteCount();
        }

        return false;
    }

    override
    public bool visit(SQLDropViewStatement x) {
        setMode(x, TableStat.Mode.Drop);
        return true;
    }

    override
    public bool visit(SQLDropTableStatement x) {
        setMode(x, TableStat.Mode.Insert);

        foreach(SQLExprTableSource tableSource ; x.getTableSources()) {
            SQLName name = cast(SQLName) tableSource.getExpr();
            TableStat stat = getTableStat(name);
            stat.incrementDropCount();
        }

        return false;
    }

    override
    public bool visit(SQLInsertStatement x) {
        if (repository !is null
                && x.getParent() is null) {
            repository.resolve(x);
        }

        setMode(x, TableStat.Mode.Insert);

        if ( cast(SQLName)x.getTableName() !is null) {
            string ident = (cast(Object)((cast(SQLName) x.getTableName()))).toString();

            TableStat stat = getTableStat(x.getTableName());
            stat.incrementInsertCount();
        }

        accept!SQLExpr(x.getColumns());
        accept(x.getQuery());

        return false;
    }
    
    protected static void putAliasMap(Map!(string, string) aliasMap, string name, string value) {
        if (aliasMap is null || name is null) {
            return;
        }
        aliasMap.put(toLower(name), value);
    }

    protected void accept(SQLObject x) {
        if (x !is null) {
            x.accept(this);
        }
    }

    protected void accept(T = SQLObject)(List!(T) nodes) {
        import std.stdio;
        if(nodes is null ) writeln("***** : ");
        for (int i = 0, size = nodes.size(); i < size; ++i) {
            accept(nodes.get(i));
        }
    }

    override public bool visit(SQLSelectQueryBlock x) {
        if (x.getFrom() is null) {
            foreach(SQLSelectItem selectItem ; x.getSelectList()) {
                statExpr(
                        selectItem.getExpr());
            }
            return false;
        }

        setMode(x, TableStat.Mode.Select);

//        if (x.getFrom(cast(SQLSubqueryTableSource)()) !is null) {
//            x.getFrom().accept(this);
//            return false;
//        }

        SQLTableSource from = x.getFrom();
        if (from !is null) {
            from.accept(this); // 提前执行，获得aliasMap
        }

        SQLExprTableSource into = x.getInto();
        if (into !is null && cast(SQLName)into.getExpr() !is null) {
            SQLName intoExpr = cast(SQLName) into.getExpr();

            bool isParam = cast(SQLIdentifierExpr)intoExpr !is null && isParam(cast(SQLIdentifierExpr) intoExpr);

            if (!isParam) {
                TableStat stat = getTableStat(intoExpr);
                if (stat !is null) {
                    stat.incrementInsertCount();
                }
            }
            into.accept(this);
        }

        foreach(SQLSelectItem selectItem ; x.getSelectList()) {
            statExpr(
                    selectItem.getExpr());
        }

        SQLExpr where = x.getWhere();
        if (where !is null) {
            statExpr(where);
        }

        SQLExpr startWith = x.getStartWith();
        if (startWith !is null) {
            statExpr(startWith);
        }

        SQLExpr connectBy = x.getConnectBy();
        if (connectBy !is null) {
            statExpr(connectBy);
        }

        SQLSelectGroupByClause groupBy = x.getGroupBy();
        if (groupBy !is null) {
            foreach(SQLExpr expr ; groupBy.getItems()) {
                statExpr(expr);
            }
        }

        SQLOrderBy orderBy = x.getOrderBy();
        if (orderBy !is null) {
            this.visit(orderBy);
        }

        SQLExpr first = x.getFirst();
        if(first !is null) {
            statExpr(first);
        }

        List!(SQLExpr) distributeBy = x.getDistributeBy();
        if (distributeBy !is null) {
            foreach(SQLExpr expr ; distributeBy) {
                statExpr(expr);
            }
        }

        List!(SQLSelectOrderByItem) sortBy = x.getSortBy();
        if (sortBy !is null) {
            foreach(SQLSelectOrderByItem orderByItem ; sortBy) {
                visit(orderBy);
            }
        }

        foreach(SQLExpr expr ; x.getForUpdateOf()) {
            statExpr(expr);
        }

        return false;
    }

    private static bool isParam(SQLIdentifierExpr x) {
        if (x.getResolvedParameter() !is null
                || x.getResolvedDeclareItem() !is null) {
            return true;
        }
        return false;
    }

    override public void endVisit(SQLSelectQueryBlock x) {
        setModeOrigin(x);
    }

    override public bool visit(SQLJoinTableSource x) {
        SQLTableSource left = x.getLeft(), right = x.getRight();

        left.accept(this);
        right.accept(this);

        SQLExpr condition = x.getCondition();
        if (condition !is null) {
            condition.accept(this);
        }

        if (x.getUsing().size() > 0
                && cast(SQLExprTableSource)(left) !is null && cast(SQLExprTableSource)(right) !is null) {
            SQLExpr leftExpr = (cast(SQLExprTableSource) left).getExpr();
            SQLExpr rightExpr = (cast(SQLExprTableSource) right).getExpr();

            foreach(SQLExpr expr ; x.getUsing()) {
                if (cast(SQLIdentifierExpr)(expr) !is null) {
                    string name = (cast(SQLIdentifierExpr) expr).getName();
                    SQLPropertyExpr leftPropExpr = new SQLPropertyExpr(leftExpr, name);
                    SQLPropertyExpr rightPropExpr = new SQLPropertyExpr(rightExpr, name);

                    leftPropExpr.setResolvedTableSource(left);
                    rightPropExpr.setResolvedTableSource(right);

                    SQLBinaryOpExpr usingCondition = new SQLBinaryOpExpr(leftPropExpr, SQLBinaryOperator.Equality, rightPropExpr);
                    usingCondition.accept(this);
                }
            }
        }

        return false;
    }

    override public bool visit(SQLPropertyExpr x) {
        TableStat.Column column = null;
        string ident = x.getName();

        SQLTableSource tableSource = x.getResolvedTableSource();
        if (cast(SQLExprTableSource)(tableSource) !is null) {
            SQLExpr expr = (cast(SQLExprTableSource) tableSource).getExpr();

            if (cast(SQLIdentifierExpr)(expr) !is null) {
                SQLIdentifierExpr table = cast(SQLIdentifierExpr) expr;
                SQLTableSource resolvedTableSource = table.getResolvedTableSource();
                if (cast(SQLExprTableSource)(resolvedTableSource) !is null) {
                    expr = (cast(SQLExprTableSource) resolvedTableSource).getExpr();
                }
            } else if (cast(SQLPropertyExpr)(expr) !is null) {
                SQLPropertyExpr table = cast(SQLPropertyExpr) expr;
                SQLTableSource resolvedTableSource = table.getResolvedTableSource();
                if (cast(SQLExprTableSource)(resolvedTableSource) !is null) {
                    expr = (cast(SQLExprTableSource) resolvedTableSource).getExpr();
                }
            }

            if (cast(SQLIdentifierExpr)(expr) !is null) {
                SQLIdentifierExpr table = cast(SQLIdentifierExpr) expr;

                SQLTableSource resolvedTableSource = table.getResolvedTableSource();
                if (cast(SQLWithSubqueryClause.Entry)(resolvedTableSource) !is null) {
                    return false;
                }

                column = addColumn(table.getName(), ident);

                if (column !is null && isParentGroupBy(x)) {
                    this.groupByColumns.add(column);
                }
            } else if (cast(SQLPropertyExpr)(expr) !is null) {
                SQLPropertyExpr table = cast(SQLPropertyExpr) expr;
                string tableName = (cast(Object)(table)).toString();
                column = addColumn(tableName, ident);

                if (column !is null && isParentGroupBy(x)) {
                    this.groupByColumns.add(column);
                }
            } else if (cast(SQLMethodInvokeExpr)(expr) !is null) {
                SQLMethodInvokeExpr methodInvokeExpr = cast(SQLMethodInvokeExpr) expr;
                if ("table".equalsIgnoreCase(methodInvokeExpr.getMethodName())
                        && methodInvokeExpr.getParameters().size() == 1
                        &&  cast(SQLName)methodInvokeExpr.getParameters().get(0) !is null) {
                    SQLName table = cast(SQLName) methodInvokeExpr.getParameters().get(0);

                    string tableName = null;
                    if (cast(SQLPropertyExpr)(table) !is null) {
                        SQLPropertyExpr propertyExpr = cast(SQLPropertyExpr) table;
                        SQLIdentifierExpr owner = cast(SQLIdentifierExpr) propertyExpr.getOwner();
                        if (propertyExpr.getResolvedTableSource() !is null
                                && cast(SQLExprTableSource)propertyExpr.getResolvedTableSource() !is null) {
                            SQLExpr resolveExpr = (cast(SQLExprTableSource) propertyExpr.getResolvedTableSource()).getExpr();
                            if (cast(SQLName)(resolveExpr) !is null) {
                                tableName = (cast(Object)(resolveExpr)).toString() ~ "." ~ propertyExpr.getName();
                            }
                        }
                    }

                    if (tableName is null) {
                        tableName = (cast(Object)(table)).toString();
                    }

                    column = addColumn(tableName, ident);
                }
            }
        } else if (cast(SQLWithSubqueryClause.Entry)(tableSource) !is null
                || cast(SQLSubqueryTableSource)(tableSource) !is null
                || cast(SQLUnionQueryTableSource)(tableSource) !is null
                || cast(SQLLateralViewTableSource)(tableSource) !is null
                || cast(SQLValuesTableSource)(tableSource) !is null) {
            return false;
        } else {
            if (x.getResolvedProcudure() !is null) {
                return false;
            }

            if (cast(SQLParameter)x.getResolvedOwnerObject() !is null) {
                return false;
            }

            bool skip = false;
            for (SQLObject parent = x.getParent();parent !is null;parent = parent.getParent()) {
                if (cast(SQLSelectQueryBlock)(parent) !is null) {
                    SQLTableSource from = (cast(SQLSelectQueryBlock) parent).getFrom();

                    // if (cast(OdpsValuesTableSource)(from) !is null) {
                    //     skip = true;
                    //     break;
                    // }
                } else if (cast(SQLSelectQuery)(parent) !is null) {
                    break;
                }
            }
            if (!skip) {
                column = handleUnkownColumn(ident);
            }
        }

        if (column !is null) {
            SQLObject parent = x.getParent();
            if (cast(SQLSelectOrderByItem)(parent) !is null) {
                parent = parent.getParent();
            }
            if (cast(SQLPrimaryKey)(parent) !is null) {
                column.setPrimaryKey(true);
            } else if (cast(SQLUnique)(parent) !is null) {
                column.setUnique(true);
            }

            setColumn(x, column);
        }

        return false;
    }

    protected bool isPseudoColumn(long hash) {
        return false;
    }

    override public bool visit(SQLIdentifierExpr x) {
        if (isParam(x)) {
            return false;
        }

        SQLTableSource tableSource = x.getResolvedTableSource();
        if (cast(SQLSelectOrderByItem)x.getParent() !is null) {
            SQLSelectOrderByItem selectOrderByItem = cast(SQLSelectOrderByItem) x.getParent();
            if (selectOrderByItem.getResolvedSelectItem() !is null) {
                return false;
            }
        }

        if (tableSource is null
                && (x.getResolvedParameter() !is null
                    || x.getResolvedDeclareItem() !is null))
        {
            return false;
        }

        long hash = x.nameHashCode64();
        if (isPseudoColumn(hash)) {
            return false;
        }

        if ((hash == FnvHash.Constants.LEVEL
                || hash == FnvHash.Constants.CONNECT_BY_ISCYCLE
                || hash == FnvHash.Constants.ROWNUM)
                && x.getResolvedColumn() is null
                && tableSource is null) {
            return false;
        }

        TableStat.Column column = null;
        string ident = x.getName();

        if (cast(SQLExprTableSource)(tableSource) !is null) {
            SQLExpr expr = (cast(SQLExprTableSource) tableSource).getExpr();
            if (cast(SQLIdentifierExpr)(expr) !is null) {
                SQLIdentifierExpr table = cast(SQLIdentifierExpr) expr;
                column = addColumn(table, ident);

                if (column !is null && isParentGroupBy(x)) {
                    this.groupByColumns.add(column);
                }
            } else if (cast(SQLPropertyExpr)(expr) !is null /* || cast(OracleDbLinkExpr)(expr) !is null */) {
                string tableName = (cast(Object)(expr)).toString();
                column = addColumn(tableName, ident);

                if (column !is null && isParentGroupBy(x)) {
                    this.groupByColumns.add(column);
                }
            } else if (cast(SQLMethodInvokeExpr)(expr) !is null) {
                SQLMethodInvokeExpr methodInvokeExpr = cast(SQLMethodInvokeExpr) expr;
                if ("table".equalsIgnoreCase(methodInvokeExpr.getMethodName())
                        && methodInvokeExpr.getParameters().size() == 1
                        && cast(SQLName)(methodInvokeExpr.getParameters().get(0)) !is null) {
                    SQLName table = cast(SQLName) methodInvokeExpr.getParameters().get(0);

                    string tableName = null;
                    if (cast(SQLPropertyExpr)(table) !is null) {
                        SQLPropertyExpr propertyExpr = cast(SQLPropertyExpr) table;
                        SQLIdentifierExpr owner = cast(SQLIdentifierExpr) propertyExpr.getOwner();
                        if (propertyExpr.getResolvedTableSource() !is null
                                && cast(SQLExprTableSource) propertyExpr.getResolvedTableSource() !is null) {
                            SQLExpr resolveExpr = (cast(SQLExprTableSource) propertyExpr.getResolvedTableSource()).getExpr();
                            if (cast(SQLName)(resolveExpr) !is null) {
                                tableName = (cast(Object)(resolveExpr)).toString() ~ "." ~ propertyExpr.getName();
                            }
                        }
                    }

                    if (tableName is null) {
                        tableName = (cast(Object)(table)).toString();
                    }

                    column = addColumn(tableName, ident);
                }
            }
        } else if (cast(SQLWithSubqueryClause.Entry)(tableSource) !is null
                || cast(SQLSubqueryTableSource)(tableSource) !is null
                || cast(SQLValuesTableSource)(tableSource) !is null
                || cast(SQLLateralViewTableSource)(tableSource) !is null) {
            return false;
        } else {
            bool skip = false;
            for (SQLObject parent = x.getParent();parent !is null;parent = parent.getParent()) {
                if (cast(SQLSelectQueryBlock)(parent) !is null) {
                    SQLTableSource from = (cast(SQLSelectQueryBlock) parent).getFrom();

                    // if (cast(OdpsValuesTableSource)(from) !is null) {
                    //     skip = true;
                    //     break;
                    // }
                } else if (cast(SQLSelectQuery)(parent) !is null) {
                    break;
                }
            }
            if (!skip) {
                column = handleUnkownColumn(ident);
            }
        }

        if (column !is null) {
            SQLObject parent = x.getParent();
            if (cast(SQLSelectOrderByItem)(parent) !is null) {
                parent = parent.getParent();
            }
            if (cast(SQLPrimaryKey)(parent) !is null) {
                column.setPrimaryKey(true);
            } else if (cast(SQLUnique)(parent) !is null) {
                column.setUnique(true);
            }

            setColumn(x, column);
        }

        return false;
    }

    private bool isParentSelectItem(SQLObject parent) {
        for (; parent !is null; parent = parent.getParent()) {
            if (cast(SQLSelectItem)(parent) !is null) {
                return true;
            }

            if (cast(SQLSelectQueryBlock)(parent) !is null) {
                return false;
            }
        }
        return false;
    }
    
    private bool isParentGroupBy(SQLObject parent) {
        for (; parent !is null; parent = parent.getParent()) {
            if (cast(SQLSelectItem)(parent) !is null) {
                return false;
            }

            if (cast(SQLSelectGroupByClause)(parent) !is null) {
                return true;
            }
        }
        return false;
    }

    private void setColumn(SQLExpr x, TableStat.Column column) {
        SQLObject current = x;
        for (;;) {
            SQLObject parent = current.getParent();

            if (parent is null) {
                break;
            }

            if (cast(SQLSelectQueryBlock)(parent) !is null) {
                SQLSelectQueryBlock query = cast(SQLSelectQueryBlock) parent;
                if (query.getWhere() == current) {
                    column.setWhere(true);
                }
                break;
            }

            if (cast(SQLSelectGroupByClause)(parent) !is null) {
                SQLSelectGroupByClause groupBy = cast(SQLSelectGroupByClause) parent;
                if (current == groupBy.getHaving()) {
                    column.setHaving(true);
                } else if (groupBy.getItems().contains(cast(SQLExpr)current)) {
                    column.setGroupBy(true);
                }
                break;
            }

            if (isParentSelectItem(parent)) {
                column.setSelec(true);
                break;
            }

            if (cast(SQLJoinTableSource)(parent) !is null) {
                SQLJoinTableSource join = cast(SQLJoinTableSource) parent;
                if (join.getCondition() == current) {
                    column.setJoin(true);
                }
                break;
            }

            current = parent;
        }
    }

    protected TableStat.Column handleUnkownColumn(string columnName) {
        return addColumn("UNKNOWN", columnName);
    }

    override public bool visit(SQLAllColumnExpr x) {
        SQLTableSource tableSource = x.getResolvedTableSource();
        if (tableSource is null) {
            return false;
        }

        statAllColumn(x, tableSource);

        return false;
    }

    private void statAllColumn(SQLAllColumnExpr x, SQLTableSource tableSource) {
        if (cast(SQLExprTableSource)(tableSource) !is null) {
            statAllColumn(x, cast(SQLExprTableSource) tableSource);
            return;
        }

        if (cast(SQLJoinTableSource)(tableSource) !is null) {
            SQLJoinTableSource join = cast(SQLJoinTableSource) tableSource;
            statAllColumn(x, join.getLeft());
            statAllColumn(x, join.getRight());
        }
    }

    private void statAllColumn(SQLAllColumnExpr x, SQLExprTableSource tableSource) {
        SQLExprTableSource exprTableSource = tableSource;
        SQLName expr = exprTableSource.getName();

        SQLCreateTableStatement createStmt = null;

        SchemaObject tableObject = exprTableSource.getSchemaObject();
        if (tableObject !is null) {
            SQLStatement stmt = tableObject.getStatement();
            if (cast(SQLCreateTableStatement)(stmt) !is null) {
                createStmt = cast(SQLCreateTableStatement) stmt;
            }
        }

        if (createStmt !is null
                && createStmt.getTableElementList().size() > 0) {
            SQLName tableName = createStmt.getName();
            foreach(SQLTableElement e ; createStmt.getTableElementList()) {
                if (cast(SQLColumnDefinition)(e) !is null) {
                    SQLColumnDefinition columnDefinition = cast(SQLColumnDefinition) e;
                    SQLName columnName = columnDefinition.getName();
                    TableStat.Column column = addColumn((cast(Object)(tableName)).toString(), (cast(Object)(columnName)).toString());
                    if (isParentSelectItem(x.getParent())) {
                        column.setSelec(true);
                    }
                }
            }
        } else if (expr !is null) {
            TableStat.Column column = addColumn((cast(Object)(expr)).toString(), "*");
            if (isParentSelectItem(x.getParent())) {
                column.setSelec(true);
            }
        }
    }

    public Map!(TableStat.Name, TableStat) getTables() {
        return tableStats;
    }

    public bool containsTable(string tableName) {
        return tableStats.containsKey(new TableStat.Name(tableName));
    }

    public bool containsColumn(string tableName, string columnName) {
        long hashCode;

        int p = cast(int)(tableName.indexOf('.'));
        if (p != -1) {
            SQLExpr owner = SQLUtils.toSQLExpr(tableName, dbType);
            hashCode = new SQLPropertyExpr(owner, columnName).hashCode64();
        } else {
            hashCode = FnvHash.hashCode64(tableName, columnName);
        }
        return columns.containsKey(new Long(hashCode));
    }

    public TableStat.Column[] getColumns() {
        return columns.values();
    }

    public TableStat.Column getColumn(string tableName, string columnName) {
        TableStat.Column column = new TableStat.Column(tableName, columnName);
        
        return this.columns.get(new Long(column.hashCode64()));
    }

    override  public bool visit(SQLSelectStatement x) {
        if (repository !is null
                && x.getParent() is null) {
            repository.resolve(x);
        }

        visit(x.getSelect());

        return false;
    }

    override public void endVisit(SQLSelectStatement x) {
    }

    override
    public bool visit(SQLWithSubqueryClause.Entry x) {
        string alias_p = x.getAlias();
        SQLWithSubqueryClause with_p = cast(SQLWithSubqueryClause) x.getParent();

        if (Boolean.TRUE.booleanValue == with_p.getRecursive()) {
            SQLSelect select = x.getSubQuery();
            if (select !is null) {
                select.accept(this);
            } else {
                x.getReturningStatement().accept(this);
            }
        } else {
            SQLSelect select = x.getSubQuery();
            if (select !is null) {
                select.accept(this);
            } else {
                x.getReturningStatement().accept(this);
            }
        }

        return false;
    }

    override public bool visit(SQLSubqueryTableSource x) {
        x.getSelect().accept(this);
        return false;
    }

    protected bool isSimpleExprTableSource(SQLExprTableSource x) {
        return  cast(SQLName)x.getExpr() !is null;
    }

    public TableStat getTableStat(SQLExprTableSource tableSource) {
        return getTableStatWithUnwrap(
                tableSource.getExpr());
    }

    private TableStat getTableStatWithUnwrap(SQLExpr expr) {
        SQLExpr identExpr = null;

        expr = unwrapExpr(expr);

        if (cast(SQLIdentifierExpr)(expr) !is null) {
            SQLIdentifierExpr identifierExpr = cast(SQLIdentifierExpr) expr;

            if (identifierExpr.nameHashCode64() == FnvHash.Constants.DUAL) {
                return null;
            }

            if (isSubQueryOrParamOrVariant(identifierExpr)) {
                return null;
            }
        }

        SQLTableSource tableSource = null;
        if (cast(SQLIdentifierExpr)(expr) !is null) {
            tableSource = (cast(SQLIdentifierExpr) expr).getResolvedTableSource();
        } else if (cast(SQLPropertyExpr)(expr) !is null) {
            tableSource = (cast(SQLPropertyExpr) expr).getResolvedTableSource();
        }

        if (cast(SQLExprTableSource)(tableSource) !is null) {
            SQLExpr tableSourceExpr = (cast(SQLExprTableSource) tableSource).getExpr();
            if (cast(SQLName)(tableSourceExpr) !is null) {
                identExpr = tableSourceExpr;
            }
        }

        if (identExpr is null) {
            identExpr = expr;
        }

        if (cast(SQLName)(identExpr) !is null) {
            return getTableStat(cast(SQLName) identExpr);
        }
        return getTableStat((cast(Object)(identExpr)).toString());
    }

    override public bool visit(SQLExprTableSource x) {
        if (isSimpleExprTableSource(x)) {
            SQLExpr expr = x.getExpr();
            TableStat stat = getTableStatWithUnwrap(expr);
            if (stat is null) {
                return false;
            }

            TableStat.Mode mode = getMode();
            if (mode !is null) {
                switch (mode.mark) {
                    case TableStat.Mode.Delete.mark:
                        stat.incrementDeleteCount();
                        break;
                    case TableStat.Mode.Insert.mark:
                        stat.incrementInsertCount();
                        break;
                    case TableStat.Mode.Update.mark:
                        stat.incrementUpdateCount();
                        break;
                    case TableStat.Mode.Select.mark:
                        stat.incrementSelectCount();
                        break;
                    case TableStat.Mode.Merge.mark:
                        stat.incrementMergeCount();
                        break;
                    case TableStat.Mode.Drop.mark:
                        stat.incrementDropCount();
                        break;
                    default:
                        break;
                }
            }
        } else {
            accept(x.getExpr());
        }

        return false;
    }

    protected bool isSubQueryOrParamOrVariant(SQLIdentifierExpr identifierExpr) {
        SQLObject resolvedColumnObject = identifierExpr.getResolvedColumnObject();
        if (cast(SQLWithSubqueryClause.Entry)(resolvedColumnObject) !is null
                || cast(SQLParameter)(resolvedColumnObject) !is null
                || cast(SQLDeclareItem)(resolvedColumnObject) !is null) {
            return true;
        }

        SQLObject resolvedOwnerObject = identifierExpr.getResolvedOwnerObject();
        if (cast(SQLSubqueryTableSource)(resolvedOwnerObject) !is null
                || cast(SQLWithSubqueryClause.Entry)(resolvedOwnerObject) !is null) {
            return true;
        }

        return false;
    }

    protected bool isSubQueryOrParamOrVariant(SQLPropertyExpr x) {
        SQLObject resolvedOwnerObject = x.getResolvedOwnerObject();
        if (cast(SQLSubqueryTableSource)(resolvedOwnerObject) !is null
                || cast(SQLWithSubqueryClause.Entry)(resolvedOwnerObject) !is null) {
            return true;
        }

        SQLExpr owner = x.getOwner();
        if (cast(SQLIdentifierExpr)(owner) !is null) {
            if (isSubQueryOrParamOrVariant(cast(SQLIdentifierExpr) owner)) {
                return true;
            }
        }

        SQLTableSource tableSource = x.getResolvedTableSource();
        if (cast(SQLExprTableSource)(tableSource) !is null) {
            SQLExprTableSource exprTableSource = cast(SQLExprTableSource) tableSource;
            if (exprTableSource.getSchemaObject() !is null) {
                return false;
            }

            SQLExpr expr = exprTableSource.getExpr();

            if (cast(SQLIdentifierExpr)(expr) !is null) {
                return isSubQueryOrParamOrVariant(cast(SQLIdentifierExpr) expr);
            }

            if (cast(SQLPropertyExpr)(expr) !is null) {
                return isSubQueryOrParamOrVariant(cast(SQLPropertyExpr) expr);
            }
        }

        return false;
    }

    override public bool visit(SQLSelectItem x) {
        statExpr(
                x.getExpr());

        return false;
    }

    override public void endVisit(SQLSelect x) {
    }

    override public bool visit(SQLSelect x) {
        SQLWithSubqueryClause with_p = x.getWithSubQuery();
        if (with_p !is null) {
            with_p.accept(this);
        }

        SQLSelectQuery query = x.getQuery();
        if (query !is null) {
            query.accept(this);
        }

        SQLOrderBy orderBy = x.getOrderBy();
        if (orderBy !is null) {
            accept(x.getOrderBy());
        }


        return false;
    }

    override public bool visit(SQLAggregateExpr x) {
        this.aggregateFunctions.add(x);
        
        accept!SQLExpr(x.getArguments());
        accept(x.getWithinGroup());
        accept(x.getOver());
        return false;
    }

    override public bool visit(SQLMethodInvokeExpr x) {
        this.functions.add(x);

        accept!SQLExpr(x.getParameters());
        return false;
    }

    override public bool visit(SQLUpdateStatement x) {
        if (repository !is null
                && x.getParent() is null) {
            repository.resolve(x);
        }

        setMode(x, TableStat.Mode.Update);

        SQLTableSource tableSource = x.getTableSource();
        if (cast(SQLExprTableSource)(tableSource) !is null) {
            SQLName identName = (cast(SQLExprTableSource) tableSource).getName();
            TableStat stat = getTableStat(identName);
            stat.incrementUpdateCount();
        } else {
            tableSource.accept(this);
        }

        accept(x.getFrom());

        accept!SQLUpdateSetItem((x.getItems()));
        accept(x.getWhere());

        return false;
    }

    override public bool visit(SQLDeleteStatement x) {
        if (repository !is null
                && x.getParent() is null) {
            repository.resolve(x);
        }

        setMode(x, TableStat.Mode.Delete);

        if (cast(SQLSubqueryTableSource) x.getTableSource() !is null) {
            SQLSelectQuery selectQuery = (cast(SQLSubqueryTableSource) x.getTableSource()).getSelect().getQuery();
            if (cast(SQLSelectQueryBlock)(selectQuery) !is null) {
                SQLSelectQueryBlock subQueryBlock = (cast(SQLSelectQueryBlock) selectQuery);
                subQueryBlock.getWhere().accept(this);
            }
        }

        TableStat stat = getTableStat(x.getTableName());
        stat.incrementDeleteCount();

        accept(x.getWhere());

        return false;
    }

    override public bool visit(SQLInListExpr x) {
        if (x.isNot()) {
            handleCondition(x.getExpr(), "NOT IN", x.getTargetList());
        } else {
            handleCondition(x.getExpr(), "IN", x.getTargetList());
        }

        return true;
    }

    override
    public bool visit(SQLInSubQueryExpr x) {
        if (x.isNot()) {
            handleCondition(x.getExpr(), "NOT IN");
        } else {
            handleCondition(x.getExpr(), "IN");
        }
        return true;
    }

    override public bool visit(SQLCreateTableStatement x) {
        if (repository !is null
                && x.getParent() is null) {
            repository.resolve(x);
        }

        foreach(SQLTableElement e ; x.getTableElementList()) {
            e.setParent(x);
        }

        TableStat stat = getTableStat(x.getName());
        stat.incrementCreateCount();

        accept!SQLTableElement(x.getTableElementList());

        if (x.getInherits() !is null) {
            x.getInherits().accept(this);
        }

        if (x.getSelect() !is null) {
            x.getSelect().accept(this);
        }

        return false;
    }

    override public bool visit(SQLColumnDefinition x) {
        string tableName = null;
        {
            SQLObject parent = x.getParent();
            if (cast(SQLCreateTableStatement)(parent) !is null) {
                tableName = (cast(Object)(cast(SQLCreateTableStatement) parent).getName()).toString();
            }
        }

        if (tableName is null) {
            return true;
        }

        string columnName = (cast(Object)x.getName()).toString();
        TableStat.Column column = addColumn(tableName, columnName);
        if (x.getDataType() !is null) {
            column.setDataType(x.getDataType().getName());
        }

        foreach(SQLColumnConstraint item ; x.getConstraints()) {
            if (cast(SQLPrimaryKey)(item) !is null) {
                column.setPrimaryKey(true);
            } else if (cast(SQLUnique)(item) !is null) {
                column.setUnique(true);
            }
        }

        return false;
    }

    override
    public bool visit(SQLCallStatement x) {
        return false;
    }

    override
    public void endVisit(SQLCommentStatement x) {

    }

    override
    public bool visit(SQLCommentStatement x) {
        return false;
    }

    override public bool visit(SQLCurrentOfCursorExpr x) {
        return false;
    }

    override
    public bool visit(SQLAlterTableAddColumn x) {
        SQLAlterTableStatement stmt = cast(SQLAlterTableStatement) x.getParent();
        string table = (cast(Object)stmt.getName()).toString();

        foreach(SQLColumnDefinition column ; x.getColumns()) {
            string columnName = (cast(Object)column.getName()).toString();
            addColumn(table, columnName);
        }
        return false;
    }

    override
    public void endVisit(SQLAlterTableAddColumn x) {

    }

    override
    public bool visit(SQLRollbackStatement x) {
        return false;
    }

    override public bool visit(SQLCreateViewStatement x) {
        if (repository !is null
                && x.getParent() is null) {
            repository.resolve(x);
        }

        x.getSubQuery().accept(this);
        return false;
    }

    override public bool visit(SQLAlterViewStatement x) {
        if (repository !is null
                && x.getParent() is null) {
            repository.resolve(x);
        }

        x.getSubQuery().accept(this);
        return false;
    }

    override
    public bool visit(SQLAlterTableDropForeignKey x) {
        return false;
    }

    override
    public bool visit(SQLUseStatement x) {
        return false;
    }

    override
    public bool visit(SQLAlterTableDisableConstraint x) {
        return false;
    }

    override
    public bool visit(SQLAlterTableEnableConstraint x) {
        return false;
    }

    override
    public bool visit(SQLAlterTableStatement x) {
        if (repository !is null
                && x.getParent() is null) {
            repository.resolve(x);
        }

        TableStat stat = getTableStat(x.getName());
        stat.incrementAlterCount();


        foreach(SQLAlterTableItem item ; x.getItems()) {
            item.setParent(x);
            item.accept(this);
        }

        return false;
    }

    override
    public bool visit(SQLAlterTableDropConstraint x) {
        return false;
    }

    override
    public bool visit(SQLDropIndexStatement x) {
        setMode(x, TableStat.Mode.DropIndex);
        SQLExprTableSource table = x.getTableName();
        if (table !is null) {
            SQLName name = cast(SQLName) table.getExpr();
            TableStat stat = getTableStat(name);
            stat.incrementDropIndexCount();
        }
        return false;
    }

    override
    public bool visit(SQLCreateIndexStatement x) {
        setMode(x, TableStat.Mode.CreateIndex);

        SQLName name = cast(SQLName) (cast(SQLExprTableSource) x.getTable()).getExpr();

        string table = (cast(Object)(name)).toString();

        TableStat stat = getTableStat(name);
        stat.incrementCreateIndexCount();

        foreach(SQLSelectOrderByItem item ; x.getItems()) {
            SQLExpr expr = item.getExpr();
            if (cast(SQLIdentifierExpr)(expr) !is null) {
                SQLIdentifierExpr identExpr = cast(SQLIdentifierExpr) expr;
                string columnName = identExpr.getName();
                addColumn(table, columnName);
            }
        }

        return false;
    }

    override
    public bool visit(SQLForeignKeyImpl x) {

        foreach(SQLName column ; x.getReferencingColumns()) {
            column.accept(this);
        }

        string table = x.getReferencedTableName().getSimpleName();

        TableStat stat = getTableStat(x.getReferencedTableName());
        stat.incrementReferencedCount();
        foreach(SQLName column ; x.getReferencedColumns()) {
            string columnName = column.getSimpleName();
            addColumn(table, columnName);
        }

        return false;
    }

    override
    public bool visit(SQLDropSequenceStatement x) {
        return false;
    }

    override
    public bool visit(SQLDropTriggerStatement x) {
        return false;
    }

    override
    public bool visit(SQLDropUserStatement x) {
        return false;
    }

    override
    public bool visit(SQLGrantStatement x) {
        if (x.getOn() !is null && (x.getObjectType().name.length == 0 || x.getObjectType() == SQLObjectType.TABLE)) {
            x.getOn().accept(this);
        }
        return false;
    }

    override
    public bool visit(SQLRevokeStatement x) {
        if (x.getOn() !is null) {
            x.getOn().accept(this);
        }
        return false;
    }

    override
    public bool visit(SQLDropDatabaseStatement x) {
        return false;
    }

    override
    public bool visit(SQLAlterTableAddIndex x) {
        foreach(SQLSelectOrderByItem item ; x.getItems()) {
            item.accept(this);
        }

        SQLName table = (cast(SQLAlterTableStatement) x.getParent()).getName();
        TableStat tableStat = this.getTableStat(table);
        tableStat.incrementCreateIndexCount();
        return false;
    }

    override public bool visit(SQLCheck x) {
        x.getExpr().accept(this);
        return false;
    }

    override public bool visit(SQLCreateTriggerStatement x) {
        SQLExprTableSource on = x.getOn();
        on.accept(this);
        return false;
    }

    override public bool visit(SQLDropFunctionStatement x) {
        return false;
    }

    override public bool visit(SQLDropTableSpaceStatement x) {
        return false;
    }

    override public bool visit(SQLDropProcedureStatement x) {
        return false;
    }

    override
    public bool visit(SQLAlterTableRename x) {
        return false;
    }

    override
    public bool visit(SQLArrayExpr x) {
        accept!SQLExpr(x.getValues());

        SQLExpr exp = x.getExpr();
        if (cast(SQLIdentifierExpr)(exp) !is null) {
            if ((cast(SQLIdentifierExpr) exp).getName() == ("ARRAY")) {
                return false;
            }
        }
        exp.accept(this);
        return false;
    }
    
    override
    public bool visit(SQLOpenStatement x) {
        return false;
    }
    
    override
    public bool visit(SQLFetchStatement x) {
        return false;
    }
    
    override
    public bool visit(SQLCloseStatement x) {
        return false;
    }

    override
    public bool visit(SQLCreateProcedureStatement x) {
        if (repository !is null
                && x.getParent() is null) {
            repository.resolve(x);
        }

        accept(x.getBlock());
        return false;
    }

    override
    public bool visit(SQLCreateFunctionStatement x) {
        if (repository !is null
                && x.getParent() is null) {
            repository.resolve(x);
        }

        accept(x.getBlock());
        return false;
    }
    
    override
    public bool visit(SQLBlockStatement x) {
        if (repository !is null
                && x.getParent() is null) {
            repository.resolve(x);
        }

        foreach(SQLParameter param ; x.getParameters()) {
            param.setParent(x);
            param.accept(this);
        }

        foreach(SQLStatement stmt ; x.getStatementList()) {
            stmt.accept(this);
        }

        SQLStatement exception = x.getException();
        if (exception !is null) {
            exception.accept(this);
        }

        return false;
    }
    
    override
    public bool visit(SQLShowTablesStatement x) {
        return false;
    }
    
    override
    public bool visit(SQLDeclareItem x) {
        return false;
    }
    
    override
    public bool visit(SQLPartitionByHash x) {
        return false;
    }
    
    override
    public bool visit(SQLPartitionByRange x) {
        return false;
    }
    
    override
    public bool visit(SQLPartitionByList x) {
        return false;
    }
    
    override
    public bool visit(SQLPartition x) {
        return false;
    }
    
    override
    public bool visit(SQLSubPartition x) {
        return false;
    }
    
    override
    public bool visit(SQLSubPartitionByHash x) {
        return false;
    }
    
    override
    public bool visit(SQLPartitionValue x) {
        return false;
    }
    
    override
    public bool visit(SQLAlterDatabaseStatement x) {
        return true;
    }
    
    override
    public bool visit(SQLAlterTableConvertCharSet x) {
        return false;
    }
    
    override
    public bool visit(SQLAlterTableDropPartition x) {
        return false;
    }
    
    override
    public bool visit(SQLAlterTableReOrganizePartition x) {
        return false;
    }
    
    override
    public bool visit(SQLAlterTableCoalescePartition x) {
        return false;
    }
    
    override
    public bool visit(SQLAlterTableTruncatePartition x) {
        return false;
    }
    
    override
    public bool visit(SQLAlterTableDiscardPartition x) {
        return false;
    }
    
    override
    public bool visit(SQLAlterTableImportPartition x) {
        return false;
    }
    
    override
    public bool visit(SQLAlterTableAnalyzePartition x) {
        return false;
    }
    
    override
    public bool visit(SQLAlterTableCheckPartition x) {
        return false;
    }
    
    override
    public bool visit(SQLAlterTableOptimizePartition x) {
        return false;
    }
    
    override
    public bool visit(SQLAlterTableRebuildPartition x) {
        return false;
    }
    
    override
    public bool visit(SQLAlterTableRepairPartition x) {
        return false;
    }
    
    override public bool visit(SQLSequenceExpr x) {
        return false;
    }
    
    override
    public bool visit(SQLMergeStatement x) {
        if (repository !is null
                && x.getParent() is null) {
            repository.resolve(x);
        }

        setMode(x.getUsing(), TableStat.Mode.Select);
        x.getUsing().accept(this);

        setMode(x, TableStat.Mode.Merge);

        SQLTableSource into = x.getInto();
        if (cast(SQLExprTableSource)(into) !is null) {
            string ident = (cast(Object)(cast(SQLExprTableSource) into).getExpr()).toString();
            TableStat stat = getTableStat(ident);
            stat.incrementMergeCount();
        } else {
            into.accept(this);
        }

        x.getOn().accept(this);

        if (x.getUpdateClause() !is null) {
            x.getUpdateClause().accept(this);
        }

        if (x.getInsertClause() !is null) {
            x.getInsertClause().accept(this);
        }

        return false;
    }
    
    override
    public bool visit(SQLSetStatement x) {
        return false;
    }

    public List!(SQLMethodInvokeExpr) getFunctions() {
        return this.functions;
    }

    override public bool visit(SQLCreateSequenceStatement x) {
        return false;
    }

    override
    public bool visit(SQLAlterTableAddConstraint x) {
        SQLConstraint constraint = x.getConstraint();
        if (cast(SQLUniqueConstraint)(constraint) !is null) {
            SQLAlterTableStatement stmt = cast(SQLAlterTableStatement) x.getParent();
            TableStat tableStat = this.getTableStat(stmt.getName());
            tableStat.incrementCreateIndexCount();
        }
        return true;
    }

    override
    public bool visit(SQLAlterTableDropIndex x) {
        SQLAlterTableStatement stmt = cast(SQLAlterTableStatement) x.getParent();
        TableStat tableStat = this.getTableStat(stmt.getName());
        tableStat.incrementDropIndexCount();
        return false;
    }

    override
    public bool visit(SQLAlterTableDropPrimaryKey x) {
        SQLAlterTableStatement stmt = cast(SQLAlterTableStatement) x.getParent();
        TableStat tableStat = this.getTableStat(stmt.getName());
        tableStat.incrementDropIndexCount();
        return false;
    }

    override
    public bool visit(SQLAlterTableDropKey x) {
        SQLAlterTableStatement stmt = cast(SQLAlterTableStatement) x.getParent();
        TableStat tableStat = this.getTableStat(stmt.getName());
        tableStat.incrementDropIndexCount();
        return false;
    }

    override
    public bool visit(SQLDescribeStatement x) {
        string tableName = (cast(Object)x.getObject()).toString();

        TableStat tableStat = this.getTableStat(x.getObject());
        tableStat.incrementDropIndexCount();

        SQLName column = x.getColumn();
        if (column !is null) {
            string columnName = (cast(Object)(column)).toString();
            this.addColumn(tableName, columnName);
        }
        return false;
    }

    override public bool visit(SQLExplainStatement x) {
        if (repository !is null
                && x.getParent() is null) {
            repository.resolve(x);
        }

        if (x.getStatement() !is null) {
            accept(x.getStatement());
        }

        return false;
    }

    override public bool visit(SQLCreateMaterializedViewStatement x) {
        if (repository !is null
                && x.getParent() is null) {
            repository.resolve(x);
        }
        return true;
    }

    override public bool visit(SQLReplaceStatement x) {
        if (repository !is null
                && x.getParent() is null) {
            repository.resolve(x);
        }

        setMode(x, TableStat.Mode.Replace);

        SQLName tableName = x.getTableName();

        TableStat stat = getTableStat(tableName);

        if (stat !is null) {
            stat.incrementInsertCount();
        }

        accept!SQLExpr(x.getColumns());
        accept!(ValuesClause)(x.getValuesList());
        accept(x.getQuery());

        return false;
    }

    protected  void statExpr(SQLExpr x) {
        auto clazz = typeid(x);
        if (clazz == typeid(SQLIdentifierExpr)) {
            visit(cast(SQLIdentifierExpr) x);
        } else if (clazz == typeid(SQLPropertyExpr)) {
            visit(cast(SQLPropertyExpr) x);
//        } else if (clazz == typeid(SQLAggregateExpr)) {
//            visit(cast(SQLAggregateExpr) x);
        } else if (clazz == typeid(SQLBinaryOpExpr)) {
            visit(cast(SQLBinaryOpExpr) x);
//        } else if (clazz == typeid(SQLCharExpr)) {
//            visit(cast(SQLCharExpr) x);
//        } else if (clazz == typeid(SQLNullExpr)) {
//            visit(cast(SQLNullExpr) x);
//        } else if (clazz == typeid(SQLIntegerExpr)) {
//            visit(cast(SQLIntegerExpr) x);
//        } else if (clazz == typeid(SQLNumberExpr)) {
//            visit(cast(SQLNumberExpr) x);
//        } else if (clazz == typeid(SQLMethodInvokeExpr)) {
//            visit(cast(SQLMethodInvokeExpr) x);
//        } else if (clazz == typeid(SQLVariantRefExpr)) {
//            visit(cast(SQLVariantRefExpr) x);
//        } else if (clazz == typeid(SQLBinaryOpExprGroup)) {
//            visit(cast(SQLBinaryOpExprGroup) x);
        } else if (cast(SQLLiteralExpr)(x) !is null) {
            // skip
        } else {
            x.accept(this);
        }
    }

    override public bool visit(SQLAlterFunctionStatement x) {
        return false;
    }
    override public bool visit(SQLDropSynonymStatement x) {
        return false;
    }

    override public bool visit(SQLAlterTypeStatement x) {
        return false;
    }
    override public bool visit(SQLAlterProcedureStatement x) {
        return false;
    }

    override public bool visit(SQLExprStatement x) {
        SQLExpr expr = x.getExpr();

        if (cast(SQLName)(expr) !is null) {
            return false;
        }

        return true;
    }

    override
    public bool visit(SQLDropTypeStatement x) {
        return false;
    }

    override
    public bool visit(SQLExternalRecordFormat x) {
        return false;
    }

    override public bool visit(SQLCreateDatabaseStatement x) {
        return false;
    }

    override
    public bool visit(SQLAlterTableExchangePartition x) {
        SQLExprTableSource table = x.getTable();
        if (table !is null) {
            table.accept(this);
        }
        return false;
    }

    override public bool visit(SQLDumpStatement x) {
        if (repository !is null
                && x.getParent() is null) {
            repository.resolve(x);
        }

         SQLExprTableSource into = x.getInto();
        if (into !is null) {
            into.accept(this);
        }

         SQLSelect select = x.getSelect();
        if (select !is null) {
            select.accept(this);
        }

        return false;
    }
}
