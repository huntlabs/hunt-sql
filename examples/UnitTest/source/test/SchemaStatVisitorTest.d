module test.SchemaStatVisitorTest;

import hunt.logging;
import hunt.container;
import hunt.util.string;
import hunt.sql.parser;
import hunt.sql.visitor.SchemaStatVisitor;

import std.conv;
import std.traits;
import test.base;
import hunt.sql.SQLUtils;
import hunt.sql.ast.SQLStatement;
import hunt.sql.util.DBType;

class SchemaStatVisitorTest
{
    public void test1()
    {
        mixin(DO_TEST);

        string sql = "select name, age from t_user where id = 1";

        string dbType = DBType.MYSQL.name;
        List!SQLStatement stmtList = SQLUtils.parseStatements(sql, dbType);
        SQLStatement stmt = stmtList.get(0);

        SchemaStatVisitor statVisitor = SQLUtils.createSchemaStatVisitor(dbType);
        stmt.accept(statVisitor);

        logDebug(statVisitor.getColumns()); // [t_user.name, t_user.age, t_user.id]
        logDebug(statVisitor.getTables()); // {t_user=Select}
        logDebug(statVisitor.getConditions()); // [t_user.id = 1]
    }

    public void test2()
    {
        mixin(DO_TEST);

        string sql = "create table t_org (fid int, name varchar(256))";

        string dbType = DBType.MYSQL.name;
        List!SQLStatement stmtList = SQLUtils.parseStatements(sql, dbType);
        SQLStatement stmt = stmtList.get(0);

        SchemaStatVisitor statVisitor = SQLUtils.createSchemaStatVisitor(dbType);
        stmt.accept(statVisitor);

        logDebug(statVisitor.getTables()); //{t_org=Create}
        logDebug(statVisitor.getColumns()); // [t_org.fid, t_org.name]
    }
}