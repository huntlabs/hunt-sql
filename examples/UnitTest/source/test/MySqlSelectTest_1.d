module test.MySqlSelectTest_1;

import hunt.logging;
import hunt.container;
import hunt.util.string;
import hunt.sql.parser;
import hunt.sql.visitor.SchemaStatVisitor;
import hunt.sql.dialect.mysql.parser.MySqlStatementParser;
import hunt.sql.dialect.mysql.visitor.MySqlSchemaStatVisitor;
import hunt.sql.stat.TableStat;
import hunt.sql.util.Utils;

import std.conv;
import std.traits;
import test.base;
import hunt.sql.SQLUtils;
import hunt.sql.ast.SQLStatement;
import hunt.sql.util.DBType;

public class MySqlSelectTest_1  {

    public void test_0()  {
        mixin(DO_TEST);

        string sql = "SELECT t1.name, t2.salary FROM employee t1, info t2  WHERE t1.name = t2.name;";

        MySqlStatementParser parser = new MySqlStatementParser(sql);
        List!SQLStatement statementList = parser.parseStatementList();
        SQLStatement statemen = statementList.get(0);
        // print(statementList);

        assert(1 == statementList.size());

        MySqlSchemaStatVisitor visitor = new MySqlSchemaStatVisitor();
        statemen.accept(visitor);

        logDebug("Tables : " , visitor.getTables());
        logDebug("fields : " , visitor.getColumns());
        logDebug("coditions : " , visitor.getConditions());
        logDebug("orderBy : " , visitor.getOrderByColumns());

        assert(2 == visitor.getTables().size());
        assert(3 == visitor.getColumns().length);
        assert(2 == visitor.getConditions().size());

        assert(visitor.getTables().containsKey(new TableStat.Name("employee")));
        assert(visitor.getTables().containsKey(new TableStat.Name("info")));

        assert(search(visitor.getColumns(),new TableStat.Column("employee", "name")) != -1);
        assert(search(visitor.getColumns(),new TableStat.Column("info", "name")) != -1);
        assert(search(visitor.getColumns(), new TableStat.Column("info", "salary")) != -1);
    }
}
