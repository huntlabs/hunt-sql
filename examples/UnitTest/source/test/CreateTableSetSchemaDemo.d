module test.CreateTableSetSchemaDemo;

import hunt.logging;
import hunt.container;
import hunt.util.string;
import hunt.sql.parser;
import hunt.sql.visitor.SchemaStatVisitor;
import hunt.sql.ast.statement.SQLCreateTableStatement;

import std.conv;
import std.traits;
import test.base;
import hunt.sql.SQLUtils;
import hunt.sql.ast.SQLStatement;
import hunt.sql.util.DBType;

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
