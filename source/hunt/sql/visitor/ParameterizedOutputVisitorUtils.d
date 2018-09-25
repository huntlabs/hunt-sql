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
module hunt.sql.visitor.ParameterizedOutputVisitorUtils;

import hunt.container;

import hunt.sql.SQLUtils;
import hunt.sql.ast;
import hunt.sql.ast.statement;
// import hunt.sql.dialect.db2.visitor.DB2OutputVisitor;
import hunt.sql.dialect.mysql.ast.statement.MySqlInsertStatement;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;
import hunt.sql.dialect.mysql.visitor.MySqlOutputVisitor;
// import hunt.sql.dialect.oracle.visitor.OracleParameterizedOutputVisitor;
// import hunt.sql.dialect.phoenix.visitor.PhoenixOutputVisitor;
import hunt.sql.dialect.postgresql.visitor.PGOutputVisitor;
// import hunt.sql.dialect.sqlserver.visitor.SQLServerOutputVisitor;
import hunt.sql.parser;
import hunt.sql.util.FnvHash;
import hunt.sql.util.DBType;
import hunt.sql.visitor.ParameterizedVisitor;
import hunt.sql.visitor.VisitorFeature;
import hunt.util.string;
import hunt.sql.visitor.SQLASTOutputVisitor;

public class ParameterizedOutputVisitorUtils {
    private  static SQLParserFeature[] defaultFeatures = [
            SQLParserFeature.EnableSQLBinaryOpExprGroup,
            SQLParserFeature.UseInsertColumnsCache,
            SQLParserFeature.OptimizedForParameterized
    ];

    private  static SQLParserFeature[] defaultFeatures2 = [
            SQLParserFeature.EnableSQLBinaryOpExprGroup,
            SQLParserFeature.UseInsertColumnsCache,
            SQLParserFeature.OptimizedForParameterized,
            SQLParserFeature.OptimizedForForParameterizedSkipValue,
    ];

    public static string parameterize(string sql, string dbType) {
        return parameterize(sql, dbType, null, null,null);
    }

    public static string parameterize(string sql
            , string dbType
            , SQLSelectListCache selectListCache) {
        return parameterize(sql, dbType, selectListCache, null);
    }

    public static string parameterize(string sql
            , string dbType
            , List!(Object) outParameters) {
        return parameterize(sql, dbType, null, outParameters);
    }


    private static void configVisitorFeatures(ParameterizedVisitor visitor, VisitorFeature[] features...) {
        if(features !is null) {
            for (int i = 0; i < features.length; i++) {
                visitor.config(features[i], true);
            }
        }
    }

    public static string parameterize(string sql
            , string dbType
            , List!(Object) outParameters, VisitorFeature[] features...) {
        return parameterize(sql, dbType, null, outParameters, features);
    }

    public static string parameterize(string sql
            , string dbType
            , SQLSelectListCache selectListCache, List!(Object) outParameters, VisitorFeature[] visitorFeatures...) {

         SQLParserFeature[] features = outParameters is null
                ? defaultFeatures2
                : defaultFeatures;

        SQLStatementParser parser = SQLParserUtils.createSQLStatementParser(sql, dbType, features);

        if (selectListCache !is null) {
            parser.setSelectListCache(selectListCache);
        }

        List!(SQLStatement) statementList = parser.parseStatementList();
        if (statementList.size() == 0) {
            return sql;
        }

        StringBuilder out_p = new StringBuilder(sql.length);
        ParameterizedVisitor visitor = createParameterizedOutputVisitor(out_p, dbType);
        if (outParameters !is null) {
            visitor.setOutputParameters(outParameters);
        }
        configVisitorFeatures(visitor, visitorFeatures);

        for (int i = 0; i < statementList.size(); i++) {
            SQLStatement stmt = statementList.get(i);

            if (i > 0) {
                SQLStatement preStmt = statementList.get(i - 1);

                if (typeid(preStmt) == typeid(stmt)) {
                    StringBuilder buf = new StringBuilder();
                    ParameterizedVisitor v1 = createParameterizedOutputVisitor(buf, dbType);
                    preStmt.accept(v1);
                    if (out_p.toString() == (buf.toString())) {
                        continue;
                    }
                }

                if (!preStmt.isAfterSemi()) {
                    out_p.append(";\n");
                } else {
                    out_p.append('\n');
                }
            }

            if (stmt.hasBeforeComment()) {
                stmt.getBeforeCommentsDirect().clear();
            }

            auto stmtClass = typeid(stmt);
            if (stmtClass == typeid(SQLSelectStatement)) { // only for performance
                SQLSelectStatement selectStatement = cast(SQLSelectStatement) stmt;
                visitor.visit(selectStatement);
                visitor.postVisit(selectStatement);
            } else {
                stmt.accept(visitor);
            }
        }

        if (visitor.getReplaceCount() == 0
                && parser.getLexer().getCommentCount() == 0 && charAt(sql, 0) != '/') {
            return sql;
        }

        return out_p.toString();
    }

    public static long parameterizeHash(string sql
            , string dbType
            , List!(Object) outParameters) {
        return parameterizeHash(sql, dbType, null, outParameters, null);
    }

    public static long parameterizeHash(string sql
            , string dbType
            , SQLSelectListCache selectListCache
            , List!(Object) outParameters, VisitorFeature[] visitorFeatures...) {

         SQLParserFeature[] features = outParameters is null
                ? defaultFeatures2
                : defaultFeatures;

        SQLStatementParser parser = SQLParserUtils.createSQLStatementParser(sql, dbType, features);

        if (selectListCache !is null) {
            parser.setSelectListCache(selectListCache);
        }

        List!(SQLStatement) statementList = parser.parseStatementList();
         int stmtSize = statementList.size();
        if (stmtSize == 0) {
            return 0L;
        }

        StringBuilder out_p = new StringBuilder(sql.length);
        ParameterizedVisitor visitor = createParameterizedOutputVisitor(out_p, dbType);
        if (outParameters !is null) {
            visitor.setOutputParameters(outParameters);
        }
        configVisitorFeatures(visitor, visitorFeatures);

        if (stmtSize == 1) {
            SQLStatement stmt = statementList.get(0);
            if (typeid(stmt) == typeid(SQLSelectStatement)) {
                SQLSelectStatement selectStmt = cast(SQLSelectStatement) stmt;

                if (selectListCache !is null) {
                    SQLSelectQueryBlock queryBlock = selectStmt.getSelect().getQueryBlock();
                    if (queryBlock !is null) {
                        string cachedSelectList = queryBlock.getCachedSelectList();
                        long cachedSelectListHash = queryBlock.getCachedSelectListHash();
                        if (cachedSelectList !is null) {
                            visitor.config(VisitorFeature.OutputSkipSelectListCacheString, true);
                        }

                        visitor.visit(selectStmt);
                        return FnvHash.fnv1a_64_lower(cachedSelectListHash, out_p);
                    }
                }

                visitor.visit(selectStmt);
            } else if (typeid(stmt) == typeid(MySqlInsertStatement)) {
                MySqlInsertStatement insertStmt = cast(MySqlInsertStatement) stmt;
                string columnsString = insertStmt.getColumnsString();
                if (columnsString !is null) {
                    long columnsStringHash = insertStmt.getColumnsStringHash();
                    visitor.config(VisitorFeature.OutputSkipInsertColumnsString, true);

                    (cast(MySqlASTVisitor) visitor).visit(insertStmt);
                    return FnvHash.fnv1a_64_lower(columnsStringHash, out_p);
                }
            } else {
                stmt.accept(visitor);
            }

            return FnvHash.fnv1a_64_lower(out_p);
        }

        for (int i = 0; i < statementList.size(); i++) {
            if (i > 0) {
                out_p.append(";\n");
            }
            SQLStatement stmt = statementList.get(i);

            if (stmt.hasBeforeComment()) {
                stmt.getBeforeCommentsDirect().clear();
            }

            auto stmtClass = typeid(stmt);
            if (stmtClass == typeid(SQLSelectStatement)) { // only for performance
                SQLSelectStatement selectStatement = cast(SQLSelectStatement) stmt;
                visitor.visit(selectStatement);
                visitor.postVisit(selectStatement);
            } else {
                stmt.accept(visitor);
            }
        }

        return FnvHash.fnv1a_64_lower(out_p);
    }

    public static string parameterize(List!(SQLStatement) statementList, string dbType) {
        StringBuilder out_p = new StringBuilder();
        ParameterizedVisitor visitor = createParameterizedOutputVisitor(out_p, dbType);

        for (int i = 0; i < statementList.size(); i++) {
            if (i > 0) {
                out_p.append(";\n");
            }
            SQLStatement stmt = statementList.get(i);

            if (stmt.hasBeforeComment()) {
                stmt.getBeforeCommentsDirect().clear();
            }
            stmt.accept(visitor);
        }

        return out_p.toString();
    }

    public static ParameterizedVisitor createParameterizedOutputVisitor(Appendable out_p, string dbType) {
        // if (DBType.ORACLE.opEquals(dbType) || DBType.ALI_ORACLE.opEquals(dbType)) {
        //     return new OracleParameterizedOutputVisitor(out_p);
        // }

        if (DBType.MYSQL.opEquals(dbType)
            || DBType.MARIADB.opEquals(dbType)
            || DBType.H2.opEquals(dbType)) {
            return new MySqlOutputVisitor(out_p, true);
        }

        if (DBType.POSTGRESQL.opEquals(dbType)
                || DBType.ENTERPRISEDB.opEquals(dbType)) {
            return new PGOutputVisitor(out_p, true);
        }

        // if (DBType.SQL_SERVER.opEquals(dbType) || DBType.JTDS.opEquals(dbType)) {
        //     return new SQLServerOutputVisitor(out_p, true);
        // }

        // if (DBType.DB2.opEquals(dbType)) {
        //     return new DB2OutputVisitor(out_p, true);
        // }

        // if (DBType.PHOENIX.opEquals(dbType)) {
        //     return new PhoenixOutputVisitor(out_p, true);
        // }

        if (DBType.ELASTIC_SEARCH.opEquals(dbType)) {
            return new MySqlOutputVisitor(out_p, true);
        }

        return new SQLASTOutputVisitor(out_p, true);
    }

    public static string restore(string sql, string dbType, List!(Object) parameters) {
        List!(SQLStatement) stmtList = SQLUtils.parseStatements(sql, dbType);

        StringBuilder out_p = new StringBuilder();
        SQLASTOutputVisitor visitor = SQLUtils.createOutputVisitor(out_p, dbType);
        visitor.setInputParameters(parameters);

        foreach(SQLStatement stmt ; stmtList) {
            stmt.accept(visitor);
        }

        return out_p.toString();
    }
}
