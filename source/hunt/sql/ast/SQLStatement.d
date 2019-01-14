module hunt.sql.ast.SQLStatement;

import hunt.sql.ast.SQLObject;
import hunt.collection;


public interface SQLStatement : SQLObject {
    string          getDbType();
    bool            isAfterSemi();
    void            setAfterSemi(bool afterSemi);
    SQLStatement    clone();
    List!SQLObject  getChildren();
    string          toLowerCaseString();
}
