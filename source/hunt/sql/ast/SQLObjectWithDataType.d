module hunt.sql.ast.SQLObjectWithDataType;

import hunt.sql.ast.SQLObject;
import hunt.sql.ast.SQLDataType;

interface SQLObjectWithDataType : SQLObject {
    SQLDataType getDataType();
    void setDataType(SQLDataType dataType);
}
