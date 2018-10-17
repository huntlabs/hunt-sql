module test.SchemaStatVisitorTest;

import hunt.logging;
import hunt.container;
import hunt.string;
import hunt.sql;

import std.conv;
import std.traits;
import test.base;

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

    public void test3()
    {
        mixin(DO_TEST);
        string sql = "select name, age from t_user where id = 1";
        string dbType = DBType.MYSQL.name;
        List!SQLStatement stmtList = SQLUtils.parseStatements(sql, dbType);

        foreach ( stmt ; stmtList) 
        {
            MySqlSchemaStatVisitor visitor = new MySqlSchemaStatVisitor();
            stmt.accept(visitor);
            //获取表名称
            // logDebug("Tables : " , visitor.getCurrentTable());
            //获取操作方法名称,依赖于表名称
            logDebug("Manipulation : " , visitor.getTables());
            //获取字段名称
            logDebug("fields : " , visitor.getColumns());
        }
    }
}