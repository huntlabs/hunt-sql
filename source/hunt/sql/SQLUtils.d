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
module hunt.sql.SQLUtils;

import hunt.container;

import hunt.sql.ast;
import hunt.sql.ast.expr;
// import hunt.sql.ast.statement;
// import hunt.sql.dialect.db2.visitor.DB2OutputVisitor;
// import hunt.sql.dialect.db2.visitor.DB2SchemaStatVisitor;
// import hunt.sql.dialect.h2.visitor.H2OutputVisitor;
// import hunt.sql.dialect.h2.visitor.H2SchemaStatVisitor;
// import hunt.sql.dialect.hive.visitor.HiveOutputVisitor;
// import hunt.sql.dialect.hive.visitor.HiveSchemaStatVisitor;
import hunt.sql.dialect.mysql.visitor.MySqlOutputVisitor;
import hunt.sql.dialect.mysql.visitor.MySqlSchemaStatVisitor;
// import hunt.sql.dialect.odps.visitor.OdpsOutputVisitor;
// import hunt.sql.dialect.odps.visitor.OdpsSchemaStatVisitor;
// import hunt.sql.dialect.oracle.visitor.OracleOutputVisitor;
// import hunt.sql.dialect.oracle.visitor.OracleSchemaStatVisitor;
// import hunt.sql.dialect.oracle.visitor.OracleToMySqlOutputVisitor;
import hunt.sql.dialect.postgresql.visitor.PGOutputVisitor;
import hunt.sql.dialect.postgresql.visitor.PGSchemaStatVisitor;
// import hunt.sql.dialect.sqlserver.visitor.SQLServerOutputVisitor;
// import hunt.sql.dialect.sqlserver.visitor.SQLServerSchemaStatVisitor;
// import hunt.sql.parser;

import hunt.sql.parser.CharTypes;
import hunt.sql.parser.EOFParserException;
// import hunt.sql.parser.InsertColumnsCache;
import hunt.sql.parser.Keywords;
import hunt.sql.parser.LayoutCharacters;
import hunt.sql.parser.Lexer;
import hunt.sql.parser.NotAllowCommentException;
import hunt.sql.parser.ParserException;
import hunt.sql.parser.SQLCreateTableParser;
// import hunt.sql.parser.SQLDDLParser;
import hunt.sql.parser.SQLExprParser;
import hunt.sql.parser.SQLParseException;
import hunt.sql.parser.SQLParser;
import hunt.sql.parser.SQLParserFeature;
import hunt.sql.parser.SQLParserUtils;
import hunt.sql.parser.SQLSelectListCache;
import hunt.sql.parser.SQLSelectParser;
// import hunt.sql.parser.SQLStatementParser;
import hunt.sql.parser.SymbolTable;
import hunt.sql.parser.Token;

import hunt.sql.visitor.SQLASTOutputVisitor;
import hunt.sql.visitor.SchemaStatVisitor;
import hunt.sql.visitor.VisitorFeature;
import hunt.sql.ast.statement.SQLSelectOrderByItem;
import hunt.sql.ast.statement.SQLUpdateSetItem;
import hunt.sql.ast.statement.SQLSelectItem;
import hunt.sql.ast.statement.SQLSelectQueryBlock;
import hunt.sql.ast.statement.SQLSetStatement;
import hunt.sql.ast.statement.SQLSelectStatement;
import hunt.sql.ast.statement.SQLSelectQuery;
import hunt.sql.ast.statement.SQLDeleteStatement;
import hunt.sql.ast.statement.SQLUpdateStatement;
import hunt.sql.ast.statement.SQLCreateTableStatement;

// import entity.support.logging.Log;
// import entity.support.logging.LogFactory;
import hunt.sql.util;
import hunt.logging;
import hunt.container;
import hunt.util.string;
import std.array;

public class SQLUtils {
    private  static SQLParserFeature[] FORMAT_DEFAULT_FEATURES = [
            SQLParserFeature.KeepComments,
            SQLParserFeature.EnableSQLBinaryOpExprGroup
    ];

     public static FormatOption DEFAULT_FORMAT_OPTION;
     public static FormatOption DEFAULT_LCASE_FORMAT_OPTION;

    // private  static Log LOG = LogFactory.getLog(SQLUtils.class);
    //  static this(){
    //     DEFAULT_FORMAT_OPTION = new FormatOption(true, true);
    //     DEFAULT_LCASE_FORMAT_OPTION = new FormatOption(false, true);
    // }

    public static string toSQLString(SQLObject sqlObject, string dbType) {
        return toSQLString(sqlObject, dbType, null);
    }

    public static string toSQLString(SQLObject sqlObject, string dbType, FormatOption option) {
        StringBuilder _out = new StringBuilder();
        SQLASTOutputVisitor visitor = createOutputVisitor(_out, dbType);

        if (option is null) {
            option = DEFAULT_FORMAT_OPTION;
        }
        visitor.setUppCase(option.isUppCase());
        visitor.setPrettyFormat(option.isPrettyFormat());
        visitor.setParameterized(option.isParameterized());
        visitor.setFeatures(option.features);

        sqlObject.accept(visitor);

        string sql = _out.toString();
        return sql;
    }

    public static string toSQLString(SQLObject sqlObject) {
        StringBuilder _out = new StringBuilder();
        sqlObject.accept(new SQLASTOutputVisitor(_out));

        string sql = _out.toString();
        return sql;
    }

    // public static string toOdpsString(SQLObject sqlObject) {
    //     return toOdpsString(sqlObject, null);
    // }

    // public static string toOdpsString(SQLObject sqlObject, FormatOption option) {
    //     return toSQLString(sqlObject, DBType.ODPS, option);
    // }

    public static string toMySqlString(SQLObject sqlObject) {
        return toMySqlString(sqlObject, cast(FormatOption) null);
    }

    public static string toMySqlString(SQLObject sqlObject, VisitorFeature[] features...) {
        return toMySqlString(sqlObject, new FormatOption(features));
    }

    public static string toMySqlString(SQLObject sqlObject, FormatOption option) {
        return toSQLString(sqlObject, DBType.MYSQL.name(), option);
    }

    public static SQLExpr toMySqlExpr(string sql) {
        return toSQLExpr(sql, DBType.MYSQL.name());
    }

    public static string formatMySql(string sql) {
        return format(sql, DBType.MYSQL.name());
    }

    public static string formatMySql(string sql, FormatOption option) {
        return format(sql, DBType.MYSQL.name(), option);
    }

    // public static string formatOracle(string sql) {
    //     return format(sql, DBType.ORACLE);
    // }

    // public static string formatOracle(string sql, FormatOption option) {
    //     return format(sql, DBType.ORACLE, option);
    // }

    // public static string formatOdps(string sql) {
    //     return format(sql, DBType.ODPS);
    // }

    // public static string formatHive(string sql) {
    //     return format(sql, DBType.HIVE);
    // }

    // public static string formatOdps(string sql, FormatOption option) {
    //     return format(sql, DBType.ODPS, option);
    // }

    // public static string formatHive(string sql, FormatOption option) {
    //     return format(sql, DBType.HIVE, option);
    // }

    // public static string formatSQLServer(string sql) {
    //     return format(sql, DBType.SQL_SERVER);
    // }

    // public static string toOracleString(SQLObject sqlObject) {
    //     return toOracleString(sqlObject, null);
    // }

    // public static string toOracleString(SQLObject sqlObject, FormatOption option) {
    //     return toSQLString(sqlObject, DBType.ORACLE, option);
    // }

    public static string toPGString(SQLObject sqlObject) {
        return toPGString(sqlObject, null);
    }

    public static string toPGString(SQLObject sqlObject, FormatOption option) {
        return toSQLString(sqlObject, DBType.POSTGRESQL.name(), option);
    }

    // public static string toDB2String(SQLObject sqlObject) {
    //     return toDB2String(sqlObject, null);
    // }

    // public static string toDB2String(SQLObject sqlObject, FormatOption option) {
    //     return toSQLString(sqlObject, DBType.DB2, option);
    // }

    // public static string toSQLServerString(SQLObject sqlObject) {
    //     return toSQLServerString(sqlObject, null);
    // }

    // public static string toSQLServerString(SQLObject sqlObject, FormatOption option) {
    //     return toSQLString(sqlObject, DBType.SQL_SERVER, option);
    // }

    public static string formatPGSql(string sql, FormatOption option) {
        return format(sql, DBType.POSTGRESQL.name(), option);
    }

    public static SQLExpr toSQLExpr(string sql, string dbType) {
        SQLExprParser parser = SQLParserUtils.createExprParser(sql, dbType);
        SQLExpr expr = parser.expr();

        if (parser.getLexer().token() != Token.EOF) {
            throw new ParserException("illegal sql expr : " ~ sql);
        }

        return expr;
    }

    public static SQLSelectOrderByItem toOrderByItem(string sql, string dbType) {
        SQLExprParser parser = SQLParserUtils.createExprParser(sql, dbType);
        SQLSelectOrderByItem orderByItem = parser.parseSelectOrderByItem();

        if (parser.getLexer().token() != Token.EOF) {
            throw new ParserException("illegal sql expr : " ~ sql);
        }

        return orderByItem;
    }

    public static SQLUpdateSetItem toUpdateSetItem(string sql, string dbType) {
        SQLExprParser parser = SQLParserUtils.createExprParser(sql, dbType);
        SQLUpdateSetItem updateSetItem = parser.parseUpdateSetItem();

        if (parser.getLexer().token() != Token.EOF) {
            throw new ParserException("illegal sql expr : " ~ sql);
        }

        return updateSetItem;
    }

    public static SQLSelectItem toSelectItem(string sql, string dbType) {
        SQLExprParser parser = SQLParserUtils.createExprParser(sql, dbType);
        SQLSelectItem selectItem = parser.parseSelectItem();

        if (parser.getLexer().token() != Token.EOF) {
            throw new ParserException("illegal sql expr : " ~ sql);
        }

        return selectItem;
    }

    public static List!(SQLStatement) toStatementList(string sql, string dbType) {
        auto parser = SQLParserUtils.createSQLStatementParser(sql, dbType);
        return parser.parseStatementList();
    }

    public static SQLExpr toSQLExpr(string sql) {
        return toSQLExpr(sql, null);
    }

    public static string format(string sql, string dbType) {
        return format(sql, dbType, null, null);
    }

    public static string format(string sql, string dbType, FormatOption option) {
        return format(sql, dbType, null, option);
    }

    public static string format(string sql, string dbType, List!(Object) parameters) {
        return format(sql, dbType, parameters, null);
    }

    public static string format(string sql, string dbType, List!(Object) parameters, FormatOption option) {
        try {
            auto parser = SQLParserUtils.createSQLStatementParser(sql, dbType, FORMAT_DEFAULT_FEATURES);
            List!(SQLStatement) statementList = parser.parseStatementList();
            return toSQLString(statementList, dbType, parameters, option);
        } catch (Exception ex) {
            logWarning("format error, dbType : " ~ dbType, ex);
            return sql;
        }
        // } catch (ParserException ex) {
        //     logWarning("format error", ex);
        //     return sql;
        // }
    }

    public static string toSQLString(List!(SQLStatement) statementList, string dbType) {
        return toSQLString(statementList, dbType, cast(List!(Object)) null);
    }

    public static string toSQLString(List!(SQLStatement) statementList, string dbType, FormatOption option) {
        return toSQLString(statementList, dbType, null, option);
    }

    public static string toSQLString(List!(SQLStatement) statementList, DBType dbType, FormatOption option) {
        return toSQLString(statementList, dbType.name, null, option);
    }

    public static string toSQLString(List!(SQLStatement) statementList, string dbType, List!(Object) parameters) {
        return toSQLString(statementList, dbType, parameters, null, null);
    }

    public static string toSQLString(List!(SQLStatement) statementList, string dbType, List!(Object) parameters, FormatOption option) {
        return toSQLString(statementList, dbType, parameters, option, null);
    }

    public static string toSQLString(List!(SQLStatement) statementList
            , string dbType
            , List!(Object) parameters
            , FormatOption option
            , Map!(string , string) tableMapping) {
        StringBuilder _out = new StringBuilder();
        SQLASTOutputVisitor visitor = createFormatOutputVisitor(_out, statementList, dbType);
        if (parameters !is null) {
            visitor.setInputParameters(parameters);
        }

        if (option is null) {
            option = DEFAULT_FORMAT_OPTION;
        }
        visitor.setFeatures(option.features);

        if (tableMapping !is null) {
            visitor.setTableMapping(tableMapping);
        }

        bool printStmtSeperator;
        if (DBType.SQL_SERVER.opEquals(dbType)) {
            printStmtSeperator = false;
        } else {
            printStmtSeperator = !DBType.ORACLE.opEquals(dbType);
        }

        for (int i = 0, size = statementList.size(); i < size; i++) {
            SQLStatement stmt = statementList.get(i);

            if (i > 0) {
                SQLStatement preStmt = statementList.get(i - 1);
                if (printStmtSeperator && !preStmt.isAfterSemi()) {
                    visitor.print(";");
                }

                List!(string) comments = preStmt.getAfterCommentsDirect();
                if (comments !is null){
                    for (int j = 0; j < comments.size(); ++j) {
                        string comment = comments.get(j);
                        if (j != 0) {
                            visitor.println();
                        }
                        visitor.printComment(comment);
                    }
                }

                if (printStmtSeperator) {
                    visitor.println();
                }

                if (!(cast(SQLSetStatement)(stmt) !is null)) {
                    visitor.println();
                }
            }
            {
                List!(string) comments = stmt.getBeforeCommentsDirect();
                if (comments !is null){
                    foreach(string comment ; comments) {
                        visitor.printComment(comment);
                        visitor.println();
                    }
                }
            }
            stmt.accept(visitor);

            if (i == size - 1) {
                List!(string) comments = stmt.getAfterCommentsDirect();
                if (comments !is null){
                    for (int j = 0; j < comments.size(); ++j) {
                        string comment = comments.get(j);
                        if (j != 0) {
                            visitor.println();
                        }
                        visitor.printComment(comment);
                    }
                }
            }
        }

        return _out.toString();
    }

    public static SQLASTOutputVisitor createOutputVisitor(Appendable _out, string dbType) {
        return createFormatOutputVisitor(_out, null, dbType);
    }

    public static SQLASTOutputVisitor createFormatOutputVisitor(Appendable _out, //
                                                                List!(SQLStatement) statementList, //
                                                                string dbType) {
        // if (DBType.ORACLE.opEquals(dbType) || DBType.ALI_ORACLE.opEquals(dbType)) {
        //     if (statementList is null || statementList.size() == 1) {
        //         return new OracleOutputVisitor(_out, false);
        //     } else {
        //         return new OracleOutputVisitor(_out, true);
        //     }
        // }

        if (DBType.MYSQL.opEquals(dbType) //
                || DBType.MARIADB.opEquals(dbType)) {
            return new MySqlOutputVisitor(_out);
        }

        if (DBType.POSTGRESQL.opEquals(dbType)) {
            return new PGOutputVisitor(_out);
        }

        // if (DBType.SQL_SERVER.opEquals(dbType) || DBType.JTDS.opEquals(dbType)) {
        //     return new SQLServerOutputVisitor(_out);
        // }

        // if (DBType.DB2.opEquals(dbType)) {
        //     return new DB2OutputVisitor(_out);
        // }

        // if (DBType.ODPS.opEquals(dbType)) {
        //     return new OdpsOutputVisitor(_out);
        // }

        // if (DBType.H2.opEquals(dbType)) {
        //     return new H2OutputVisitor(_out);
        // }

        // if (DBType.HIVE.opEquals(dbType)) {
        //     return new HiveOutputVisitor(_out);
        // }

        if (DBType.ELASTIC_SEARCH.opEquals(dbType)) {
            return new MySqlOutputVisitor(_out);
        }

        return new SQLASTOutputVisitor(_out, dbType);
    }

    //@Deprecated
    public static SchemaStatVisitor createSchemaStatVisitor(List!(SQLStatement) statementList, string dbType) {
        return createSchemaStatVisitor(dbType);
    }

    public static SchemaStatVisitor createSchemaStatVisitor(string dbType) {
        // if (DBType.ORACLE.opEquals(dbType) || DBType.ALI_ORACLE.opEquals(dbType)) {
        //     return new OracleSchemaStatVisitor();
        // }

        if (DBType.MYSQL.opEquals(dbType) || //
                DBType.MARIADB.opEquals(dbType)) {
            return new MySqlSchemaStatVisitor();
        }

        if (DBType.POSTGRESQL.opEquals(dbType)) {
            return new PGSchemaStatVisitor();
        }

        // if (DBType.SQL_SERVER.opEquals(dbType) || DBType.JTDS.opEquals(dbType)) {
        //     return new SQLServerSchemaStatVisitor();
        // }

        // if (DBType.DB2.opEquals(dbType)) {
        //     return new DB2SchemaStatVisitor();
        // }

        // if (DBType.ODPS.opEquals(dbType)) {
        //     return new OdpsSchemaStatVisitor();
        // }

        // if (DBType.H2.opEquals(dbType)) {
        //     return new H2SchemaStatVisitor();
        // }

        // if (DBType.HIVE.opEquals(dbType)) {
        //     return new HiveSchemaStatVisitor();
        // }

        if (DBType.ELASTIC_SEARCH.opEquals(dbType)) {
            return new MySqlSchemaStatVisitor();
        }

        return new SchemaStatVisitor();
    }

    public static List!(SQLStatement) parseStatements(string sql, string dbType) {
        auto parser = SQLParserUtils.createSQLStatementParser(sql, dbType);
        List!(SQLStatement) stmtList = parser.parseStatementList();
        if (parser.getLexer().token() != Token.EOF) {
            throw new ParserException("syntax error : " ~ sql);
        }
        return stmtList;
    }

    public static List!(SQLStatement) parseStatements(string sql, string dbType, bool keepComments) {
        auto parser = SQLParserUtils.createSQLStatementParser(sql, dbType, keepComments);
        List!(SQLStatement) stmtList = parser.parseStatementList();
        if (parser.getLexer().token() != Token.EOF) {
            throw new ParserException("syntax error. " ~ sql);
        }
        return stmtList;
    }

    /**
     * @param columnName
     * @param tableAlias
     * @param pattern if pattern is null,it will be set {%Y-%m-%d %H:%i:%s} as mysql default value and set {yyyy-mm-dd
     * hh24:mi:ss} as oracle default value
     * @param dbType {@link DBType} if dbType is null ,it will be set the mysql as a default value
     */
    public static string buildToDate(string columnName, string tableAlias, string pattern, string dbType) {
        StringBuilder sql = new StringBuilder();
        if (columnName.length == 0) return "";
        if (dbType.length == 0) dbType = DBType.MYSQL.name();
        string formatMethod = "";
        if (equalsIgnoreCase(DBType.MYSQL.name(), dbType)) {
            formatMethod = "STR_TO_DATE";
            if (pattern.length == 0) pattern = "%Y-%m-%d %H:%i:%s";
        } else if (equalsIgnoreCase(DBType.ORACLE.name(), dbType)) {
            formatMethod = "TO_DATE";
            if (pattern.length == 0) pattern = "yyyy-mm-dd hh24:mi:ss";
        } else {
            return "";
            // expand date's handle method for other database
        }
        sql.append(formatMethod).append("(");
        if (!(tableAlias.length == 0)) sql.append(tableAlias).append(".");
        sql.append(columnName).append(",");
        sql.append("'");
        sql.append(pattern);
        sql.append("')");
        return sql.toString();
    }

    public static List!(SQLExpr) split(SQLBinaryOpExpr x) {
        return SQLBinaryOpExpr.split(x);
    }

    // public static string translateOracleToMySql(string sql) {
    //     List!(SQLStatement) stmtList = toStatementList(sql, DBType.ORACLE);

    //     StringBuilder _out = new StringBuilder();
    //     OracleToMySqlOutputVisitor visitor = new OracleToMySqlOutputVisitor(_out, false);
    //     for (int i = 0; i < stmtList.size(); ++i) {
    //         stmtList.get(i).accept(visitor);
    //     }

    //     string mysqlSql = _out.toString();
    //     return mysqlSql;

    // }

    public static string addCondition(string sql, string condition, string dbType) {
        string result = addCondition(sql, condition, SQLBinaryOperator.BooleanAnd, false, dbType);
        return result;
    }

    public static string addCondition(string sql, string condition, SQLBinaryOperator op, bool left, string dbType) {
        if (sql is null) {
            throw new Exception("IllegalArgument : sql is null");
        }

        if (condition is null) {
            return sql;
        }

        if (op.getName == string.init) {
            op = SQLBinaryOperator.BooleanAnd;
        }

        if (op != SQLBinaryOperator.BooleanAnd //
                && op != SQLBinaryOperator.BooleanOr) {
            throw new Exception("add condition not support : " ~ op.getName());
        }

        List!(SQLStatement) stmtList = parseStatements(sql, dbType);

        if (stmtList.size() == 0) {
            throw new Exception("not support empty-statement :" ~ sql);
        }

        if (stmtList.size() > 1) {
            throw new Exception("not support multi-statement :" ~ sql);
        }

        SQLStatement stmt = stmtList.get(0);

        SQLExpr conditionExpr = toSQLExpr(condition, dbType);

        addCondition(stmt, op, conditionExpr, left);

        return toSQLString(stmt, dbType);
    }

    public static void addCondition(SQLStatement stmt, SQLBinaryOperator op, SQLExpr condition, bool left) {
        if (cast(SQLSelectStatement)(stmt) !is null) {
            SQLSelectQuery query = (cast(SQLSelectStatement) stmt).getSelect().getQuery();
            if (cast(SQLSelectQueryBlock)(query) !is null) {
                SQLSelectQueryBlock queryBlock = cast(SQLSelectQueryBlock) query;
                SQLExpr newCondition = buildCondition(op, condition, left, queryBlock.getWhere());
                queryBlock.setWhere(newCondition);
            } else {
                throw new Exception("add condition not support " ~ typeid(stmt).stringof);
            }

            return;
        }

        if (cast(SQLDeleteStatement)(stmt) !is null) {
            SQLDeleteStatement _delete = cast(SQLDeleteStatement) stmt;

            SQLExpr newCondition = buildCondition(op, condition, left, _delete.getWhere());
            _delete.setWhere(newCondition);

            return;
        }

        if (cast(SQLUpdateStatement)(stmt) !is null) {
            SQLUpdateStatement update = cast(SQLUpdateStatement) stmt;

            SQLExpr newCondition = buildCondition(op, condition, left, update.getWhere());
            update.setWhere(newCondition);

            return;
        }

        throw new Exception("add condition not support " ~ typeid(stmt).stringof);
    }

    public static SQLExpr buildCondition(SQLBinaryOperator op, SQLExpr condition, bool left, SQLExpr where) {
        if (where is null) {
            return condition;
        }

        SQLBinaryOpExpr newCondition;
        if (left) {
            newCondition = new SQLBinaryOpExpr(condition, op, where);
        } else {
            newCondition = new SQLBinaryOpExpr(where, op, condition);
        }
        return newCondition;
    }

    public static string addSelectItem(string selectSql, string expr, string _alias, string dbType) {
        return addSelectItem(selectSql, expr, _alias, false, dbType);
    }

    public static string addSelectItem(string selectSql, string expr, string _alias, bool first, string dbType) {
        List!(SQLStatement) stmtList = parseStatements(selectSql, dbType);

        if (stmtList.size() == 0) {
            throw new Exception("not support empty-statement :" ~ selectSql);
        }

        if (stmtList.size() > 1) {
            throw new Exception("not support multi-statement :" ~ selectSql);
        }

        SQLStatement stmt = stmtList.get(0);

        SQLExpr columnExpr = toSQLExpr(expr, dbType);

        addSelectItem(stmt, columnExpr, _alias, first);

        return toSQLString(stmt, dbType);
    }

    public static void addSelectItem(SQLStatement stmt, SQLExpr expr, string _alias, bool first) {
        if (expr is null) {
            return;
        }

        if (cast(SQLSelectStatement)(stmt) !is null) {
            SQLSelectQuery query = (cast(SQLSelectStatement) stmt).getSelect().getQuery();
            if (cast(SQLSelectQueryBlock)(query) !is null) {
                SQLSelectQueryBlock queryBlock = cast(SQLSelectQueryBlock) query;
                addSelectItem(queryBlock, expr, _alias, first);
            } else {
                throw new Exception("add condition not support " ~ typeid(stmt).stringof);
            }

            return;
        }

        throw new Exception("add selectItem not support " ~ typeid(stmt).stringof);
    }

    public static void addSelectItem(SQLSelectQueryBlock queryBlock, SQLExpr expr, string _alias, bool first) {
        SQLSelectItem selectItem = new SQLSelectItem(expr, _alias);
        queryBlock.getSelectList().add(selectItem);
        selectItem.setParent(selectItem);
    }

    public static class FormatOption {
        private int features = VisitorFeature.of(VisitorFeature.OutputUCase
                , VisitorFeature.OutputPrettyFormat);

        public this() {

        }

        public this(VisitorFeature[] features...) {
            this.features = VisitorFeature.of(features);
        }

        public this(bool ucase) {
            this(ucase, true);
        }

        public this(bool ucase, bool prettyFormat) {
            this(ucase, prettyFormat, false);
        }

        public this(bool ucase, bool prettyFormat, bool parameterized) {
            this.features = VisitorFeature.config(this.features, VisitorFeature.OutputUCase, ucase);
            this.features = VisitorFeature.config(this.features, VisitorFeature.OutputPrettyFormat, prettyFormat);
            this.features = VisitorFeature.config(this.features, VisitorFeature.OutputParameterized, parameterized);
        }

        public bool isDesensitize() {
            return isEnabled(VisitorFeature.OutputDesensitize);
        }

        public void setDesensitize(bool val) {
            config(VisitorFeature.OutputDesensitize, val);
        }

        public bool isUppCase() {
            return isEnabled(VisitorFeature.OutputUCase);
        }

        public void setUppCase(bool val) {
            config(VisitorFeature.OutputUCase, val);
        }

        public bool isPrettyFormat() {
            return isEnabled(VisitorFeature.OutputPrettyFormat);
        }

        public void setPrettyFormat(bool prettyFormat) {
            config(VisitorFeature.OutputPrettyFormat, prettyFormat);
        }

        public bool isParameterized() {
            return isEnabled(VisitorFeature.OutputParameterized);
        }

        public void setParameterized(bool parameterized) {
            config(VisitorFeature.OutputParameterized, parameterized);
        }

        public void config(VisitorFeature feature, bool state) {
            features = VisitorFeature.config(features, feature, state);
        }

        public  bool isEnabled(VisitorFeature feature) {
            return VisitorFeature.isEnabled(this.features, feature);
        }
    }

    public static string refactor(string sql, string dbType, Map!(string , string) tableMapping) {
        List!(SQLStatement) stmtList = parseStatements(sql, dbType);
        return SQLUtils.toSQLString(stmtList, dbType, null, null, tableMapping);
    }

    public static long hash(string sql, string dbType) {
        Lexer lexer = SQLParserUtils.createLexer(sql, dbType);

        StringBuilder buf = new StringBuilder(sql.length);

        for (;;) {
            lexer.nextToken();

            Token token = lexer.token();
            if (token == Token.EOF) {
                break;
            }

            if (token == Token.ERROR) {
                return FnvHash.fnv1a_64(sql);
            }

            if (buf.length != 0) {

            }
        }

        return (cast(Object)buf).toHash();
    }

    public static SQLExpr not(SQLExpr expr) {
        if (cast(SQLBinaryOpExpr)(expr) !is null) {
            SQLBinaryOpExpr binaryOpExpr = cast(SQLBinaryOpExpr) expr;
            SQLBinaryOperator op = binaryOpExpr.getOperator();

            SQLBinaryOperator notOp;

            switch (op.getName){
                case SQLBinaryOperator.Equality.getName:
                    notOp = SQLBinaryOperator.LessThanOrGreater;
                    break;
                case SQLBinaryOperator.LessThanOrEqualOrGreaterThan.getName:
                    notOp = SQLBinaryOperator.Equality;
                    break;
                case SQLBinaryOperator.LessThan.getName:
                    notOp = SQLBinaryOperator.GreaterThanOrEqual;
                    break;
                case SQLBinaryOperator.LessThanOrEqual.getName:
                    notOp = SQLBinaryOperator.GreaterThan;
                    break;
                case SQLBinaryOperator.GreaterThan.getName:
                    notOp = SQLBinaryOperator.LessThanOrEqual;
                    break;
                case SQLBinaryOperator.GreaterThanOrEqual.getName:
                    notOp = SQLBinaryOperator.LessThan;
                    break;
                case SQLBinaryOperator.Is.getName:
                    notOp = SQLBinaryOperator.IsNot;
                    break;
                case SQLBinaryOperator.IsNot.getName:
                    notOp = SQLBinaryOperator.Is;
                    break;
                default:
                    break;
            }


            if (notOp.getName != string.init) {
                return new SQLBinaryOpExpr(binaryOpExpr.getLeft(), notOp, binaryOpExpr.getRight());
            }
        }

        if (cast(SQLInListExpr)(expr) !is null) {
            SQLInListExpr inListExpr = cast(SQLInListExpr) expr;

            SQLInListExpr newInListExpr = new SQLInListExpr(inListExpr);
            newInListExpr.getTargetList().addAll(inListExpr.getTargetList());
            newInListExpr.setNot(!inListExpr.isNot());
            return newInListExpr;
        }

        return new SQLUnaryExpr(SQLUnaryOperator.Not, expr);
    }

    public static string normalize(string name) {
        return normalize(name, null);
    }

    public static string normalize(string name, string dbType) {
        if (name is null) {
            return null;
        }

        if (name.length > 2) {
            char c0 = charAt(name, 0);
            char x0 = charAt(name, name.length - 1);
            if ((c0 == '"' && x0 == '"') || (c0 == '`' && x0 == '`')) {
                string normalizeName = name.substring(1, cast(int)name.length - 1);
                if (c0 == '`') {
                    normalizeName = normalizeName.replace("`\\.`", ".");
                }

                if (DBType.ORACLE.opEquals(dbType)) {
                    // if (OracleUtils.isKeyword(normalizeName)) {
                    //     return name;
                    // }
                } else if (DBType.MYSQL.opEquals(dbType)) {
                    if (MySqlUtils.isKeyword(normalizeName)) {
                        return name;
                    }
                } else if (DBType.POSTGRESQL.opEquals(dbType)
                        /* || DBType.ENTERPRISEDB.opEquals(dbType) */) {
                    if (PGUtils.isKeyword(normalizeName)) {
                        return name;
                    }
                }

                return normalizeName;
            }
        }

        return name;
    }

    public static bool nameEquals(SQLName a, SQLName b) {
        if (a == b) {
            return true;
        }

        if (a is null || b is null) {
            return false;
        }

        return a.nameHashCode64() == b.nameHashCode64();
    }

    public static bool nameEquals(string a, string b) {
        if (a == b) {
            return true;
        }

        if (a is null || b is null) {
            return false;
        }

        if (equalsIgnoreCase(a, b)) {
            return true;
        }

        string normalize_a = normalize(a);
        string normalize_b = normalize(b);

        return equalsIgnoreCase(normalize_a, normalize_b);
    }

    public static bool isValue(SQLExpr expr) {
        if (cast(SQLLiteralExpr)(expr) !is null) {
            return true;
        }

        if (cast(SQLVariantRefExpr)(expr) !is null) {
            return true;
        }

        if (cast(SQLBinaryOpExpr)(expr) !is null) {
            SQLBinaryOpExpr binaryOpExpr = cast(SQLBinaryOpExpr) expr;
            SQLBinaryOperator op = binaryOpExpr.getOperator();
            if (op == SQLBinaryOperator.Add
                    || op == SQLBinaryOperator.Subtract
                    || op == SQLBinaryOperator.Multiply) {
                return isValue(binaryOpExpr.getLeft())
                        && isValue(binaryOpExpr.getRight());
            }
        }

        return false;
    }

    public static bool replaceInParent(SQLExpr expr, SQLExpr target) {
        if (expr is null) {
            return false;
        }

        SQLObject parent = expr.getParent();

        if (cast(SQLReplaceable)(parent) !is null) {
            return (cast(SQLReplaceable) parent).replace(expr, target);
        }

        return false;
    }

    public static string desensitizeTable(string tableName) {
        if (tableName is null) {
            return null;
        }

        tableName = normalize(tableName);
        long hash = FnvHash.hashCode64(tableName);
        return Utils.hex_t(hash);
    }

    /**
     * 重新排序建表语句，解决建表语句的依赖关系
     * @param sql
     * @param dbType
     * @return
     */
    public static string sort(string sql, string dbType) {
        List!(SQLStatement) stmtList = SQLUtils.parseStatements(sql, DBType.ORACLE.name());
        SQLCreateTableStatement.sort(stmtList);
        return SQLUtils.toSQLString(stmtList, dbType);
    }
}

