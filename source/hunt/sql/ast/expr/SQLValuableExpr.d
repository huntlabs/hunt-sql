module hunt.sql.ast.expr.SQLValuableExpr;
import hunt.sql.ast.SQLExpr;


public interface SQLValuableExpr : SQLExpr {

    Object getValue();

}
