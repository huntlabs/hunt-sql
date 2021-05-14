module hunt.sql.ast.SQLSetQuantifier;


public interface SQLSetQuantifier {

    // SQL 92
    enum int ALL         = 1;
    enum int DISTINCT    = 2;

    enum int UNIQUE      = 3;
    enum int DISTINCTROW = 4;

    // !SetQuantifier
}
