module test.MySqlVisitorDemo;

import hunt.logging;
import hunt.collection;
import hunt.String;
import hunt.sql;
import hunt.util.StringBuilder;
import std.conv;
import std.traits;
import test.base;

public class MySqlVisitorDemo {

    public void test_for_demo() {
        mixin(DO_TEST);

        string sql = "select * from mytable a left join info b on a.id = b.id where a.id = 3";
        List!SQLStatement stmtList = SQLUtils.parseStatements(sql, DBType.MYSQL.name);

        ExportTableAliasVisitor visitor = new ExportTableAliasVisitor();
        foreach (SQLStatement stmt ; stmtList) {
            stmt.accept(visitor);
        }

        SQLTableSource tableSource = visitor.getAliasMap().get("b");
        logDebug(visitor.getAliasMap());
    }


    public void test_for_insert() {
        mixin(DO_TEST);

        string sql = "INSERT INTO User t(t.nickename,t.age) values(?,123)";
        List!Object params = new ArrayList!Object();
        params.add(new String("tom"));

        logInfo("format sql : ",SQLUtils.format(sql,DBType.POSTGRESQL.name,params));

        List!SQLStatement stmtList = SQLUtils.parseStatements(sql, DBType.POSTGRESQL.name);

        ExportTableAliasVisitor visitor = new ExportTableAliasVisitor();
        auto schema = SQLUtils.createSchemaStatVisitor(DBType.POSTGRESQL.name);

        StringBuilder buf = new StringBuilder();
        auto output = SQLUtils.createOutputVisitor(buf,DBType.POSTGRESQL.name);
        foreach (SQLStatement stmt ; stmtList) {
            stmt.accept(visitor);
            stmt.accept(schema);
            stmt.accept(output);
        }

        SQLTableSource tableSource = visitor.getAliasMap().get("a");
        logDebug(visitor.getAliasMap());
        logDebug("output : ",buf.toString);
    }
}
