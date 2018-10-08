module test.SelectTest;

import hunt.logging;
import hunt.container;
import hunt.util.string;
import hunt.sql;

import std.conv;
import std.traits;
import test.base;


public class SelectTest  {

    public void test_0()  {
        mixin(DO_TEST);

        string sql = "SELECT t1.name as tname, t2.salary FROM employee t1 left join info t2  on t1.name = t2.name where t1.id > 5 order by t1.id desc;";
        logDebug("SQL : ",sql);

        MySqlStatementParser parser = new MySqlStatementParser(sql);
        List!SQLStatement statementList = parser.parseStatementList();
        SQLStatement statemen = statementList.get(0);
        
        ExportTableAliasVisitor aliasVisitor = new ExportTableAliasVisitor();

        statemen.accept(aliasVisitor);

        logDebug(aliasVisitor.getAliasMap());


        SchemaStatVisitor visitor = SQLUtils.createSchemaStatVisitor(DBType.MYSQL.name);
        statemen.accept(visitor);
        foreach(col; visitor.getColumns()) {
            logDebug("column : %s , isSelectItem : %s ".format(col.getFullName(),col.isSelect()));
        }

        logDebug("Tables : " , visitor.getTables());
        // logDebug("fields : " , visitor.getColumns());
        // logDebug("coditions : " , visitor.getConditions());
        // logDebug("orderBy : " , visitor.getOrderByColumns());

        // assert(2 == visitor.getTables().size());
        // assert(4 == visitor.getColumns().length);
        // assert(3 == visitor.getConditions().size());

        // assert(visitor.getTables().containsKey(new TableStat.Name("employee")));
        // assert(visitor.getTables().containsKey(new TableStat.Name("info")));

        // assert(search(visitor.getColumns(),new TableStat.Column("employee", "name")) != -1);
        // assert(search(visitor.getColumns(),new TableStat.Column("info", "name")) != -1);
        // assert(search(visitor.getColumns(), new TableStat.Column("info", "salary")) != -1);
    }

}
