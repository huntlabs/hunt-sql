module test.BuilderSelectTest;


import hunt.logging;
import hunt.container;
import hunt.string;
import hunt.sql;

import std.conv;
import std.traits;
import test.base;


public class BuilderSelectTest  {

    public void test_0()  {
        mixin(DO_TEST);

        SQLSelectBuilder builder = SQLBuilderFactory.createSelectSQLBuilder(DBType.MYSQL.name);

        builder.from("mytable");
        builder.select("f1", "f2", "f3 F3", "count(*) cnt");
        builder.groupBy("f1");
        builder.having("count(*) > 1");
        builder.orderBy("f1", "f2 desc");
        builder.whereAnd("f1 > 0");


        string sql = builder.toString();
        logDebug("builder result : ",sql);
        assert("SELECT f1, f2, f3 AS F3, COUNT(*) AS cnt\n" ~
                "FROM mytable\n" ~
                "WHERE f1 > 0\n" ~
                "GROUP BY f1\n" ~
                "HAVING COUNT(*) > 1\n" ~
                "ORDER BY f1, f2 DESC" ==  sql);
    }
}
