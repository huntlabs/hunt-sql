module test.Demo0;

import hunt.sql.ast.SQLStatement;
import hunt.sql.dialect.mysql.parser.MySqlStatementParser;
import hunt.sql.dialect.mysql.visitor.MySqlOutputVisitor;
import hunt.sql.parser.SQLStatementParser;
import hunt.sql.GlobalInit;
import hunt.sql.SQLUtils;
import hunt.sql.util.DBType;
import hunt.logging;
import hunt.container;
import hunt.util.string;
import std.stdio;
import test.base;

public class Demo0  {

    public void test_demo_0() {
        mixin(DO_TEST);

        string sql = "SELECT UUID();";

        // parser得到AST
        SQLStatementParser parser = new MySqlStatementParser(sql);
        List!SQLStatement stmtList = parser.parseStatementList(); //

        // 将AST通过visitor输出
        StringBuilder _out = new StringBuilder();
        MySqlOutputVisitor visitor = new MySqlOutputVisitor(_out);

        foreach ( stmt ; stmtList) {
        // logInfo("class : ",stmt.classinfo);

            stmt.accept(visitor);
            _out.append(";");
        }

        logDebug("--visit-> : ",_out.toString());
        logDebug("--ast---> : ",SQLUtils.toSQLString(stmtList,DBType.MYSQL.name));
    }
}