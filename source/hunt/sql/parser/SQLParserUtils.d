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
module hunt.sql.parser.SQLParserUtils;

import hunt.sql.ast.statement.SQLSelectQueryBlock;
// import hunt.sql.dialect.db2.ast.stmt.DB2SelectQueryBlock;
// import hunt.sql.dialect.db2.parser.DB2ExprParser;
// import hunt.sql.dialect.db2.parser.DB2Lexer;
// import hunt.sql.dialect.db2.parser.DB2StatementParser;
// import hunt.sql.dialect.h2.parser.H2StatementParser;
// import hunt.sql.dialect.hive.parser.HiveStatementParser;
import hunt.sql.dialect.mysql.ast.statement.MySqlSelectQueryBlock;
import hunt.sql.dialect.mysql.parser.MySqlExprParser;
import hunt.sql.dialect.mysql.parser.MySqlLexer;
import hunt.sql.dialect.mysql.parser.MySqlStatementParser;
// import hunt.sql.dialect.odps.parser.OdpsExprParser;
// import hunt.sql.dialect.odps.parser.OdpsLexer;
// import hunt.sql.dialect.odps.parser.OdpsStatementParser;
// import hunt.sql.dialect.oracle.ast.stmt.OracleSelectQueryBlock;
// import hunt.sql.dialect.oracle.parser.OracleExprParser;
// import hunt.sql.dialect.oracle.parser.OracleLexer;
// import hunt.sql.dialect.oracle.parser.OracleStatementParser;
// import hunt.sql.dialect.phoenix.parser.PhoenixExprParser;
// import hunt.sql.dialect.phoenix.parser.PhoenixLexer;
// import hunt.sql.dialect.phoenix.parser.PhoenixStatementParser;
import hunt.sql.dialect.postgresql.parser.PGExprParser;
import hunt.sql.dialect.postgresql.parser.PGLexer;
import hunt.sql.dialect.postgresql.parser.PGSQLStatementParser;
// import hunt.sql.dialect.sqlserver.parser.SQLServerExprParser;
// import hunt.sql.dialect.sqlserver.parser.SQLServerLexer;
// import hunt.sql.dialect.sqlserver.parser.SQLServerStatementParser;
import hunt.sql.util.DBType;
import hunt.sql.parser.SQLStatementParser;
import hunt.sql.parser.SQLExprParser;
import hunt.sql.parser.SQLParserFeature;
import hunt.sql.parser.Lexer;


public class SQLParserUtils {

    public static SQLStatementParser createSQLStatementParser(string sql, string dbType) {
        SQLParserFeature[] features;
        if (DBType.ODPS.opEquals(dbType) || DBType.MYSQL.opEquals(dbType)) {
            // features = new SQLParserFeature[]; 
            features ~= SQLParserFeature.KeepComments;
        } else {
            // features = new SQLParserFeature[];
        }
        return createSQLStatementParser(sql, dbType, features);
    }

    public static SQLStatementParser createSQLStatementParser(string sql, string dbType, bool keepComments) {
        SQLParserFeature[] features;
        if (keepComments) {
            // features = new SQLParserFeature[];
            features ~= SQLParserFeature.KeepComments;
        } else {
            // features = new SQLParserFeature[] ;
        }

        return createSQLStatementParser(sql, dbType, features);
    }

    public static SQLStatementParser createSQLStatementParser(string sql, string dbType, SQLParserFeature[] features...) {
        // if (DBType.ORACLE.opEquals(dbType) || DBType.ALI_ORACLE.opEquals(dbType)) {
        //     return new OracleStatementParser(sql);
        // }

        if (DBType.MYSQL.opEquals(dbType) /* || DBType.ALIYUN_DRDS.opEquals(dbType) */) {
            return new MySqlStatementParser(sql, features);
        }

        if (DBType.MARIADB.opEquals(dbType)) {
            return new MySqlStatementParser(sql, features);
        }

        if (DBType.POSTGRESQL.opEquals(dbType)
                /* || DBType.ENTERPRISEDB.opEquals(dbType) */) {
            return new PGSQLStatementParser(sql);
        }

        // if (DBType.SQL_SERVER.opEquals(dbType) || DBType.JTDS.opEquals(dbType)) {
        //     return new SQLServerStatementParser(sql);
        // }

        // if (DBType.H2.opEquals(dbType)) {
        //     return new H2StatementParser(sql);
        // }
        
        // if (DBType.DB2.opEquals(dbType)) {
        //     return new DB2StatementParser(sql);
        // }
        
        // if (DBType.ODPS.opEquals(dbType)) {
        //     return new OdpsStatementParser(sql);
        // }

        // if (DBType.PHOENIX.opEquals(dbType)) {
        //     return new PhoenixStatementParser(sql);
        // }

        // if (DBType.HIVE.opEquals(dbType)) {
        //     return new HiveStatementParser(sql);
        // }

        if (DBType.ELASTIC_SEARCH.opEquals(dbType)) {
            return new MySqlStatementParser(sql);
        }

        return new SQLStatementParser(sql, dbType);
    }

    public static SQLExprParser createExprParser(string sql, string dbType) {
        // if (DBType.ORACLE.opEquals(dbType) || DBType.ALI_ORACLE.opEquals(dbType)) {
        //     return new OracleExprParser(sql);
        // }

        if (DBType.MYSQL.opEquals(dbType) || //
            DBType.MARIADB.opEquals(dbType) /* || //
            DBType.H2.opEquals(dbType) */) {
            return new MySqlExprParser(sql);
        }

        if (DBType.POSTGRESQL.opEquals(dbType)
                /* || DBType.ENTERPRISEDB.opEquals(dbType) */) {
            return new PGExprParser(sql);
        }

        // if (DBType.SQL_SERVER.opEquals(dbType) || DBType.JTDS.opEquals(dbType)) {
        //     return new SQLServerExprParser(sql);
        // }
        
        // if (DBType.DB2.opEquals(dbType)) {
        //     return new DB2ExprParser(sql);
        // }
        
        // if (DBType.ODPS.opEquals(dbType)) {
        //     return new OdpsExprParser(sql);
        // }

        // if (DBType.PHOENIX.opEquals(dbType)) {
        //     return new PhoenixExprParser(sql);
        // }

        return new SQLExprParser(sql);
    }

    public static Lexer createLexer(string sql, string dbType) {
        // if (DBType.ORACLE.opEquals(dbType) || DBType.ALI_ORACLE.opEquals(dbType)) {
        //     return new OracleLexer(sql);
        // }

        if (DBType.MYSQL.opEquals(dbType) || //
                DBType.MARIADB.opEquals(dbType) /* || //
                DBType.H2.opEquals(dbType) */) {
            return new MySqlLexer(sql);
        }

        if (DBType.POSTGRESQL.opEquals(dbType)
                || DBType.ENTERPRISEDB.opEquals(dbType)) {
            return new PGLexer(sql);
        }

        // if (DBType.SQL_SERVER.opEquals(dbType) || DBType.JTDS.opEquals(dbType)) {
        //     return new SQLServerLexer(sql);
        // }

        // if (DBType.DB2.opEquals(dbType)) {
        //     return new DB2Lexer(sql);
        // }

        // if (DBType.ODPS.opEquals(dbType)) {
        //     return new OdpsLexer(sql);
        // }

        // if (DBType.PHOENIX.opEquals(dbType)) {
        //     return new PhoenixLexer(sql);
        // }

        return new Lexer(sql);
    }

    public static SQLSelectQueryBlock createSelectQueryBlock(string dbType) {
        if (DBType.MYSQL.opEquals(dbType)) {
            return new MySqlSelectQueryBlock();
        }

        // if (DBType.ORACLE.opEquals(dbType)) {
        //     return new OracleSelectQueryBlock();
        // }

        // if (DBType.DB2.opEquals(dbType)) {
        //     return new DB2SelectQueryBlock();
        // }

        // if (DBType.POSTGRESQL.opEquals(dbType)) {
        //     return new DB2SelectQueryBlock();
        // }

        // if (DBType.ODPS.opEquals(dbType)) {
        //     return new DB2SelectQueryBlock();
        // }

        // if (DBType.SQL_SERVER.opEquals(dbType)) {
        //     return new DB2SelectQueryBlock();
        // }

        return new SQLSelectQueryBlock();
     }
}
