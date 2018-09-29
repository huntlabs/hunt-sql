module test.ExportParameters;

import hunt.sql;
import hunt.logging;
import hunt.container;
import hunt.util.string;
import std.stdio;
import test.base;

public class ExportParameters  {
    public void test_export_parameters() {
        mixin(DO_TEST);

        string sql = "select * from t where id = 3 and name = 'abc'";
        
        List!SQLStatement stmtList = SQLUtils.parseStatements(sql, DBType.MYSQL.name);
        
        StringBuilder _out = new StringBuilder();
        ExportParameterVisitor visitor = new MySqlExportParameterVisitor(_out);
        foreach (SQLStatement stmt ; stmtList) {
            stmt.accept(visitor);
        }
        
        string paramteredSql = _out.toString();
        logDebug(paramteredSql);
        
        List!Object paramters = visitor.getParameters(); // [3, "abc"]
        foreach (Object param ; paramters) {
            logDebug(param.toString);
        }
    }
}
