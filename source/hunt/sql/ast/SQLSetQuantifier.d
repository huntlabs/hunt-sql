module hunt.sql.ast.SQLSetQuantifier;


public interface SQLSetQuantifier {

    // SQL 92
    public  static int ALL         = 1;
    public  static int DISTINCT    = 2;

    public  static int UNIQUE      = 3;
    public  static int DISTINCTROW = 4;

    // !SetQuantifier
}
