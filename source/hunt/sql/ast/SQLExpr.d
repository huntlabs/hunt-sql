module hunt.sql.ast.SQLExpr;

import hunt.collection;
import hunt.sql.ast.SQLObject;
import hunt.sql.ast.SQLDataType;


public interface SQLExpr : SQLObject//, Cloneable 
{
    SQLExpr     clone();
    SQLDataType computeDataType();
    List!SQLObject getChildren();
}
