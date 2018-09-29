module test.CreateTableSetSchemaDemo;

import hunt.logging;
import hunt.container;
import hunt.util.string;
import hunt.sql;

import std.conv;
import std.traits;
import test.base;


public class CreateTableSetSchemaDemo{

    public void test_schemaStat()   {
        mixin(DO_TEST);

        string sql = "create table t(fid varchar(20))";

        string dbType = DBType.MYSQL.name;
        SQLStatementParser parser = SQLParserUtils.createSQLStatementParser(sql, dbType);
        List!SQLStatement stmtList = parser.parseStatementList();

        SchemaStatVisitor statVisitor = SQLUtils.createSchemaStatVisitor(dbType);
        foreach (SQLStatement stmt ; stmtList) {
            SQLCreateTableStatement createTable = (cast(SQLCreateTableStatement) stmt);
            createTable.setSchema("sc001");
        }

        string sql2 = SQLUtils.toSQLString(stmtList, DBType.MYSQL.name);
        logDebug(sql2);
    }
}
