module hunt.sql.ast.expr.SQLUnaryOperator;


public struct SQLUnaryOperator {
    enum SQLUnaryOperator Plus = SQLUnaryOperator("+");//
    enum SQLUnaryOperator Negative = SQLUnaryOperator("-"); //
    enum SQLUnaryOperator Not = SQLUnaryOperator("!"); //
    enum SQLUnaryOperator Compl = SQLUnaryOperator("~"); //
    enum SQLUnaryOperator Prior = SQLUnaryOperator("PRIOR"); //
    enum SQLUnaryOperator ConnectByRoot = SQLUnaryOperator("CONNECT BY"); //
    enum SQLUnaryOperator BINARY = SQLUnaryOperator("BINARY"); //
    enum SQLUnaryOperator RAW = SQLUnaryOperator("RAW"); //
    enum SQLUnaryOperator NOT = SQLUnaryOperator("NOT");
    enum SQLUnaryOperator Pound = SQLUnaryOperator("#") ;// Number of points in path or polygon
    

    public  string name;

    this(string name){
        this.name = name;
    }

    bool opEquals(const SQLUnaryOperator h) nothrow {
        return name == h.name ;
    } 

    bool opEquals(ref const SQLUnaryOperator h) nothrow {
        return name == h.name ;
    } 
}
