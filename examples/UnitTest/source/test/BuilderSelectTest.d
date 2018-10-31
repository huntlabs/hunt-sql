module test.BuilderSelectTest;


import hunt.logging;
import hunt.container;
import hunt.string;
import hunt.sql;
import hunt.lang;
import std.conv;
import std.traits;
import test.base;


public class BuilderSelectTest  {

    public void test_0()  {
        mixin(DO_TEST);

        auto builder = SQLBuilderFactory.createSQLBuilder!(SQLSelectBuilderImpl)(DBType.MYSQL.name);

        builder.from("mytable","a");
        builder.join("user","b","a.uid = b.id")
               .leftJoin("App","c","a.appid = c.id");
        builder.select("f1", "f2", "f3 F3", "count(*) cnt");
        builder.groupBy("f1");
        builder.having("count(*) > 1");
        builder.orderBy("f1", "f2 desc");
        builder.whereAnd("f1 > 0");


        string sql = builder.toString();
        logDebug("builder result : ",sql);
        // assert("SELECT f1, f2, f3 AS F3, COUNT(*) AS cnt\n" ~
        //         "FROM mytable\n" ~
        //         "WHERE f1 > 0\n" ~
        //         "GROUP BY f1\n" ~
        //         "HAVING COUNT(*) > 1\n" ~
        //         "ORDER BY f1, f2 DESC" ==  sql);
    }

    // public void test_1()  {
    //     mixin(DO_TEST);

    //     auto builder = new QueryBuilder(DBType.MYSQL.name);

    //     builder.from("mytable","a");
    //     builder.leftJoin("user","b","a.uid = b.id")
    //            .leftJoin("App","c","a.appid = c.id");
    //     builder.select("f1", "f2", "f3 F3", "count(*) cnt");
    //     builder.groupBy("f1");
    //     builder.having("count(*) > 1");
    //     builder.orderBy("f1", "f2 desc");
    //     builder.where("f1 > 0").whereAnd("f1 < 10");


    //     string sql = builder.toString();
    //     logDebug("builder result : ",sql);
    // }

    // public void test_2()
    // {
    //     mixin(DO_TEST);

    //     auto builder = new QueryBuilder(DBType.MYSQL.name);

    //     builder.from("UserInfo","u");
    //     builder.set("u.name","gxc");
    //     builder.set("age",18);
    //     builder.where(builder.expr.eq("u.id","1"));
    //     builder.update();
    //     string sql = builder.toString();
    //     logDebug("builder result : ",sql);
    // }

    // public void test_3()
    // {
    //     mixin(DO_TEST);

    //     auto builder = new QueryBuilder(DBType.MYSQL.name);

    //     builder.from("UserInfo","u");
    //     builder.where("u.id = :id");
    //     builder.whereAnd("u.name = :name");
    //     builder.setParameter("id",3).setParameter("name","gxc's name");
    //     builder.del();
    //     string sql = builder.toString();
    //     logDebug("builder result : ",sql);
    // }


    // public void test_4()
    // {
    //     mixin(DO_TEST);

    //     auto builder = new QueryBuilder(DBType.MYSQL.name);
    //     string[string] values;
    //     values["name"] = "gxc's name";
    //     builder.insert("UserInfo");
    //     builder.values(values);
    //     builder.set("age",18);
    //     builder.set("desc","man");
    //     string sql = builder.toString();
    //     logDebug("builder result : ",sql);
    // }
}
