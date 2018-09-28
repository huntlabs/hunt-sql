module test.Demo0;

import hunt.sql.ast.SQLStatement;
import hunt.sql.dialect.mysql.parser.MySqlStatementParser;
import hunt.sql.dialect.postgresql.parser.PGSQLStatementParser;

import hunt.sql.dialect.mysql.visitor.MySqlOutputVisitor;
import hunt.sql.dialect.postgresql.visitor.PGOutputVisitor;
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

        string sql = "create table t(fid FLOA)";

        // parser得到AST
        MySqlStatementParser parser = new MySqlStatementParser(sql);
        List!SQLStatement stmtList = parser.parseStatementList(); //

        // 将AST通过visitor输出
        StringBuilder _out = new StringBuilder();
        MySqlOutputVisitor visitor = new MySqlOutputVisitor(_out);
        logDebug("--ast---> : ",SQLUtils.toSQLString(stmtList,DBType.MYSQL.name));

        foreach ( stmt ; stmtList) {

            stmt.accept(visitor);
            _out.append(";");
            
        }

        logDebug("--visit-> : ",_out.toString());
    }
}