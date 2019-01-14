module test.ExportParameters;

import hunt.sql;
import hunt.logging;
import hunt.collection;
import hunt.String;
import std.stdio;
import test.base;
import hunt.Integer;
import hunt.text;
import std.string;

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

    public void test_sql_format() {
        mixin(DO_TEST);

        string sql = "select * from t where id = ? and age = 8 and name = :name";
        
        List!Object params = new ArrayList!Object();
        params.add(new Integer(3));
        params.add(new MyString("abc"));
        
        auto format_string = SQLUtils.format(sql, DBType.ORACLE.name,params);
        
        logDebug("format_string : %s".format(format_string));
      
    }
}
