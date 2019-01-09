module test.PageTest;

import hunt.logging;
import hunt.container;
import hunt.string;
import hunt.sql;

import std.conv;
import std.traits;
import test.base;


public class PageTest  {

    public void test()
    {
        mixin(DO_TEST);
        
        test_0();
        test_mysql_1();
        test_mysql_2();
        test_mysql_3();
        test_mysql_4();
        test_mysql_group_0();
    }

    public void test_0()  {

        string sql = "select * from t";
        string result = PagerUtils.count(sql, DBType.MYSQL.name);
        assert("SELECT COUNT(*)\n" ~ //
                            "FROM t" == result);
       
    }

    public void test_mysql_1() {
        string sql = "select id, name from t";
        string result = PagerUtils.count(sql, DBType.MYSQL.name);
        assert("SELECT COUNT(*)\n" ~ //
                            "FROM t" == result);
    }

    public void test_mysql_2()  {
        string sql = "select id, name from t order by id";
        string result = PagerUtils.count(sql, DBType.MYSQL.name);
        assert("SELECT COUNT(*)\n" ~ //
                            "FROM t" == result);
    }
    
    public void test_mysql_3()  {
        string sql = "select distinct id from t order by id";
        string result = PagerUtils.count(sql, DBType.MYSQL.name);
        assert("SELECT COUNT(DISTINCT id)\n" ~ //
                            "FROM t" == result);
    }

    public void test_mysql_4()  {
        string sql = "select distinct a.col1,a.col2 from test a";
        string result = PagerUtils.count(sql, DBType.MYSQL.name);
        assert("SELECT COUNT(DISTINCT a.col1, a.col2)\n" ~
                "FROM test a" == result);
    }

    public void test_mysql_group_0()  {
        string sql = "select type, count(*) from t group by type";
        string result = PagerUtils.count(sql, DBType.MYSQL.name);
        assert("SELECT COUNT(*)\n" ~
                "FROM (\n" ~
                "\tSELECT type, COUNT(*)\n" ~
                "\tFROM t\n" ~
                "\tGROUP BY type\n" ~
                ") ALIAS_COUNT" == result);
    }
}
