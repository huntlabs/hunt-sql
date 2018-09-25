module hunt.sql.ast.SQLReplaceable;

import hunt.sql.ast.SQLExpr;

/**
 * Created by wenshao on 06/06/2017.
 */
public interface SQLReplaceable {
    bool replace(SQLExpr expr, SQLExpr target);
}
