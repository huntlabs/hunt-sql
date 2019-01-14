module test.MySqlUpdateTest_1;

import hunt.logging;
import hunt.collection;
import hunt.String;
import hunt.sql;

import std.conv;
import std.traits;
import test.base;
import std.string;

public class MySqlUpdateTest_1  {

    public void test_0() {
        mixin(DO_TEST);
        
        string sql = "UPDATE t_price, t_basic_store s " ~ //
                "SET purchasePrice = :purchasePrice, operaterId = :operaterId, " ~ //
                "    operaterRealName = :operaterRealName, operateDateline = :operateDateline " ~ //
                "WHERE goodsId = :goodsId AND s.id = storeId AND s.areaId = :areaId";

        MySqlStatementParser parser = new MySqlStatementParser(sql);
        List!SQLStatement statementList = parser.parseStatementList();
        SQLStatement statemen = statementList.get(0);
        // print(statementList);
        logDebug("sql type : %s".format(typeid(statemen)));
        assert(1 ==  statementList.size());

        MySqlSchemaStatVisitor visitor = new MySqlSchemaStatVisitor();
        statemen.accept(visitor);


        assert(2 == visitor.getTables().size());
        assert(8 == visitor.getColumns().length);
        assert(4 == visitor.getConditions().size());

        // assert(search(visitor.getTables() , new TableStat.Name("t_price")) != -1);
        // assert(search(visitor.getTables() , new TableStat.Name("t_basic_store")) != -1);

    }

    public void test_1() {
        mixin(DO_TEST);
        
        string sql = " update UInfo u set u.age = ? where u.id = ? ";
        logDebug(" sql : %s ".format(sql));
        // MySqlStatementParser parser = new MySqlStatementParser(sql);
        List!SQLStatement statementList = SQLUtils.parseStatements(sql,"mysql");
        SQLStatement statemen = statementList.get(0);
        SQLSelectStatement stmt = cast(SQLSelectStatement)statemen ;
        logDebug("cast select is null : ",stmt is null);
        auto update = cast(SQLUpdateStatement)statemen;
        // logDebug("sql type : %s".format(typeid(update)));
        assert(1 ==  statementList.size());
        
        auto fromExpr = update.getTableSource();
            logDebug("update From : %s".format(SQLUtils.toSQLString(fromExpr)));

        foreach(updateItem; update.getItems()) {
            logDebug(" update item ( %s , %s)".format(updateItem.getColumn(),updateItem.getValue()));
        }

        MySqlSchemaStatVisitor visitor = new MySqlSchemaStatVisitor();
        statemen.accept(visitor);


        // assert(2 == visitor.getTables().size());
        // assert(8 == visitor.getColumns().length);
        // assert(4 == visitor.getConditions().size());

        // assert(search(visitor.getTables() , new TableStat.Name("t_price")) != -1);
        // assert(search(visitor.getTables() , new TableStat.Name("t_basic_store")) != -1);

    }
}
