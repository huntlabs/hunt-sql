module test.PostgresqlTest;

import hunt.logging;
import hunt.container;
import hunt.string;
import hunt.sql;

import std.conv;
import std.traits;
import test.base;


public class PostgresqlTest  {

    public void test_0()  {
        mixin(DO_TEST);

        string sql = "SELECT t1.name as tname, t2.salary FROM employee t1, info t2  WHERE t1.name = t2.name order by name desc limit 4 offset 3;";
        logDebug("TEST SQL : ",sql);

        List!SQLStatement statementList = SQLUtils.parseStatements(sql , DBType.POSTGRESQL.name);
        SQLStatement statemen = statementList.get(0);
        // print(statementList);
        SQLSelectStatement stmt = cast(SQLSelectStatement)statemen ;
        SQLSelectQueryBlock queryBlock = stmt.getSelect().getQueryBlock();
        foreach(selectItem; queryBlock.getSelectList()) {
            logDebug(" selcet : ( %s , %s ) ".format(SQLUtils.toSQLString(selectItem.getExpr()),selectItem.getAlias()));
        }

        auto select_copy = queryBlock.clone();
        logDebug("query select : ",SQLUtils.toSQLString(select_copy,DBType.POSTGRESQL.name));

        assert(1 == statementList.size());

        SchemaStatVisitor visitor =  SQLUtils.createSchemaStatVisitor(DBType.POSTGRESQL.name);
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
