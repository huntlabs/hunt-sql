module hunt.sql.ast.SQLHint;

import hunt.sql.ast.SQLObject;


public interface SQLHint : SQLObject {
    SQLHint clone();
}
