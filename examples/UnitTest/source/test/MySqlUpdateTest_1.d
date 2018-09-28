module test.MySqlUpdateTest_1;

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

        assert(1 ==  statementList.size());

        MySqlSchemaStatVisitor visitor = new MySqlSchemaStatVisitor();
        statemen.accept(visitor);

        // System.out.println("Tables : " ~ visitor.getTables());
        // System.out.println("fields : " ~ visitor.getColumns());
        // System.out.println("coditions : " ~ visitor.getConditions());
        // System.out.println("orderBy : " ~ visitor.getOrderByColumns());

        assert(2 == visitor.getTables().size());
        assert(8 == visitor.getColumns().length);
        assert(4 == visitor.getConditions().size());

        // assert(search(visitor.getTables() , new TableStat.Name("t_price")) != -1);
        // assert(search(visitor.getTables() , new TableStat.Name("t_basic_store")) != -1);

    }
}
