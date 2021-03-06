module test.MySqlSelectTest_1;

import hunt.logging;
import hunt.collection;
import hunt.String;
import hunt.sql;

import std.conv;
import std.traits;
import test.base;
import std.string;

public class MySqlSelectTest_1 {

    void test() {
        testLike();
        // testLeftJoinQuery();
        // testInSubQuery();
        // test_0();
        // test_1();
    }

    void testLike() {
        string sql = "select a from UserInfo a where id::text like '12%' ";

        PGSQLStatementParser parser = new PGSQLStatementParser(sql);
        List!SQLStatement statementList = parser.parseStatementList();
        SQLStatement statemen = statementList.get(0);

        PGSchemaStatVisitor visitor = new PGSchemaStatVisitor();
        statemen.accept(visitor);

        // trace("Tables : " ~ visitor.getTables().toString());
        // trace("fields : " ~ visitor.getColumns().to!string());
        // trace("coditions : " ~ visitor.getConditions().toString());

        SQLSelectStatement selStmt = cast(SQLSelectStatement) statemen;
        SQLSelectQueryBlock queryBlock = selStmt.getSelect().getQueryBlock();
        SQLExpr sqlExpr = queryBlock.getWhere();
        string w = SQLUtils.toSQLString(queryBlock);

        trace(w);

    }

    private void testLeftJoinQuery() {

        mixin(DO_TEST);

        string sql = "select a, b from UserInfo a left join Car b on a.id = b.uid " ~
            " where a.age = 5";

        MySqlStatementParser parser = new MySqlStatementParser(sql);
        List!SQLStatement statementList = parser.parseStatementList();
        SQLStatement statemen = statementList.get(0);
        // print(statementList);
        SQLSelectStatement stmt = cast(SQLSelectStatement) statemen;
        SQLSelectQueryBlock queryBlock = stmt.getSelect().getQueryBlock();
        foreach (selectItem; queryBlock.getSelectList()) {
            logDebug(" select : ( %s , %s ) ".format(SQLUtils.toSQLString(selectItem.getExpr()), selectItem.getAlias()));
        }

        assert(1 == statementList.size());

        SQLJoinTableSource tableSource = cast(SQLJoinTableSource) queryBlock.getFrom();
        SQLExprTableSource exprTableSource = cast(SQLExprTableSource) tableSource.getLeft();
        string name = exprTableSource.getAlias();
        warning("alias: ", name);
        assert(name == "a");

        SQLExpr sqlExpr = queryBlock.getWhere();
        string tableAlias = tableSource.getAlias();
    }

    private void testInSubQuery() {

        mixin(DO_TEST);

        string sql = "select columnName from table1 where id in (select id from table3 where name = ?)";
        // string sql = "SELECT t1.name as tname, t2.salary FROM employee t1, info t2  WHERE t1.name = t2.name order by name desc;";

        MySqlStatementParser parser = new MySqlStatementParser(sql);
        List!SQLStatement statementList = parser.parseStatementList();
        SQLStatement statemen = statementList.get(0);
        // print(statementList);
        SQLSelectStatement stmt = cast(SQLSelectStatement) statemen;
        SQLSelectQueryBlock queryBlock = stmt.getSelect().getQueryBlock();
        foreach (selectItem; queryBlock.getSelectList()) {
            logDebug(" select : ( %s , %s ) ".format(SQLUtils.toSQLString(selectItem.getExpr()), selectItem.getAlias()));
        }

        assert(1 == statementList.size());

        SQLInSubQueryExpr subQueryExpr = cast(SQLInSubQueryExpr) queryBlock.getWhere();
        assert(subQueryExpr !is null);
        string w = SQLUtils.toSQLString(subQueryExpr);
        tracef("where: %s", w);

        MySqlSchemaStatVisitor visitor = new MySqlSchemaStatVisitor();
        statemen.accept(visitor);

        logDebug("Tables : ", visitor.getTables());
        logDebug("fields : ", visitor.getColumns());
        logDebug("coditions : ", visitor.getConditions());
        logDebug("orderBy : ", visitor.getOrderByColumns());
    }

    public void test_0() {
        mixin(DO_TEST);

        string sql = "SELECT t1.name as tname, t2.salary FROM employee t1, info t2  WHERE t1.name = t2.name order by name desc;";

        MySqlStatementParser parser = new MySqlStatementParser(sql);
        List!SQLStatement statementList = parser.parseStatementList();
        SQLStatement statemen = statementList.get(0);
        // print(statementList);
        SQLSelectStatement stmt = cast(SQLSelectStatement) statemen;
        SQLSelectQueryBlock queryBlock = stmt.getSelect().getQueryBlock();
        foreach (selectItem; queryBlock.getSelectList()) {
            logDebug(" select : ( %s , %s ) ".format(SQLUtils.toSQLString(selectItem.getExpr()), selectItem.getAlias()));
        }

        assert(1 == statementList.size());

        MySqlSchemaStatVisitor visitor = new MySqlSchemaStatVisitor();
        statemen.accept(visitor);

        logDebug("Tables : ", visitor.getTables());
        logDebug("fields : ", visitor.getColumns());
        logDebug("coditions : ", visitor.getConditions());
        logDebug("orderBy : ", visitor.getOrderByColumns());

        assert(2 == visitor.getTables().size());
        assert(3 == visitor.getColumns().length);
        assert(2 == visitor.getConditions().size());

        assert(visitor.getTables().containsKey(new TableStat.Name("employee")));
        assert(visitor.getTables().containsKey(new TableStat.Name("info")));

        assert(search(visitor.getColumns(), new TableStat.Column("employee", "name")) != -1);
        assert(search(visitor.getColumns(), new TableStat.Column("info", "name")) != -1);
        assert(search(visitor.getColumns(), new TableStat.Column("info", "salary")) != -1);
    }

    public void test_1() {
        mixin(DO_TEST);

        string sql = "SELECT t1, t2.salary FROM employee t1 left join t1.add t2 where t1.id > 0 and t1.name = 'gxc' order by t1.id desc;"; //on t1.name = t2.name 
        logDebug(sql);

        MySqlStatementParser parser = new MySqlStatementParser(sql);
        List!SQLStatement statementList = parser.parseStatementList();
        SQLStatement statemen = statementList.get(0);
        // print(statementList);
        SQLSelectStatement stmt = cast(SQLSelectStatement) statemen;
        SQLSelectQueryBlock queryBlock = stmt.getSelect().getQueryBlock();

        foreach (selectItem; queryBlock.getSelectList()) {
            logDebug(" select : ( %s , %s ) ".format(SQLUtils.toSQLString(selectItem.getExpr()), selectItem.getAlias()));
        }

        auto whe = SQLUtils.toSQLString(queryBlock.getWhere());
        logDebug("where : ", whe);
        logDebug("order : ", SQLUtils.toSQLString(queryBlock.getOrderBy()));
        foreach (item; queryBlock.getOrderBy().getItems) {
            logDebug("order item : %s".format(SQLUtils.toSQLString(item.getExpr())));
            item.replace(item.getExpr(), SQLUtils.toSQLExpr("t1.name"));
        }

        MySqlSchemaStatVisitor visitor = new MySqlSchemaStatVisitor();
        statemen.accept(visitor);

        logDebug("Tables : ", visitor.getTables());
        logDebug("fields : ", visitor.getColumns());
        logDebug("coditions : ", visitor.getConditions());
        logDebug("orderBy : ", visitor.getOrderByColumns());

        auto select_copy = queryBlock.clone();
        foreach (selectItem; select_copy.getSelectList()) {
            logDebug("clone select: ( %s , %s ) ".format(SQLUtils.toSQLString(selectItem.getExpr()), selectItem
                    .computeAlias()));
            selectItem.setAlias("_as_b_");
            auto expr = selectItem.getExpr();
            if (cast(SQLIdentifierExpr) expr !is null)
                selectItem.setAlias("_as_idnt_");
            if (cast(SQLPropertyExpr) expr !is null)
                selectItem.setAlias("_as_proper_");

        }

        logDebug("clone : %s".format(SQLUtils.toSQLString(select_copy)));

        // SQLSelectBuilder builder = SQLBuilderFactory.createSelectSQLBuilder(DBType.MYSQL.name);

        // builder.from("mytable");
        // builder.select("f1", "f2", "f3 F3", "count(*) cnt");
        // builder.groupBy("f1");
        // builder.having("count(*) > 1");
        // builder.orderBy("f1", "f2 desc");
        // builder.whereAnd("f1 > 0");
        // assert(2 == visitor.getTables().size());
        // assert(3 == visitor.getColumns().length);
        // assert(2 == visitor.getConditions().size());

        // assert(visitor.getTables().containsKey(new TableStat.Name("employee")));
        // assert(visitor.getTables().containsKey(new TableStat.Name("info")));

        // assert(search(visitor.getColumns(),new TableStat.Column("employee", "name")) != -1);
        // assert(search(visitor.getColumns(),new TableStat.Column("info", "name")) != -1);
        // assert(search(visitor.getColumns(), new TableStat.Column("info", "salary")) != -1);
    }
}
