module hunt.sql.ast.SQLName;

import hunt.sql.ast.SQLExpr;

public interface SQLName : SQLExpr {
    string  getSimpleName();
    SQLName clone();
    long    nameHashCode64();
    long    hashCode64();
}
