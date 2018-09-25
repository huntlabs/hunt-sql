module hunt.sql.ast.SQLDataType;

import hunt.sql.ast.SQLObject;
import hunt.sql.ast.SQLExpr;

import hunt.container;


public interface SQLDataType : SQLObject {

    string getName();

    long nameHashCode64();

    void setName(string name);

    List!SQLExpr getArguments();

    bool getWithTimeZone();
    void  setWithTimeZone(bool value);

    bool isWithLocalTimeZone();
    void setWithLocalTimeZone(bool value);

    SQLDataType clone();

    void setDbType(string dbType);
    string getDbType();

    interface Constants {
        enum string CHAR = "CHAR";
        enum string NCHAR = "NCHAR";
        enum string VARCHAR = "VARCHAR";
        enum string DATE = "DATE";
        enum string TIMESTAMP = "TIMESTAMP";
        enum string XML = "XML";

        enum string DECIMAL = "DECIMAL";
        enum string NUMBER = "NUMBER";
        enum string REAL = "REAL";
        enum string DOUBLE_PRECISION = "DOUBLE PRECISION";

        enum string TINYINT = "TINYINT";
        enum string SMALLINT = "SMALLINT";
        enum string INT = "INT";
        enum string BIGINT = "BIGINT";
        enum string TEXT = "TEXT";
        enum string BYTEA = "BYTEA";
        enum string BOOLEAN = "bool";
    }
}
