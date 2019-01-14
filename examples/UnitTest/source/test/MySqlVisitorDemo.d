module test.MySqlVisitorDemo;

import hunt.logging;
import hunt.collection;
import hunt.String;
import hunt.sql;

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
}
