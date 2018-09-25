
module hunt.sql.parser.ParserException;

// import hunt.util.serialize;
import std.exception;

public class ParserException : Exception {

    private static long serialVersionUID = 1L;

    public this(){
        this(null);
    }

    public this(string message){
        super(message);
    }

    public this(string message, Throwable e){
        super(message, e);
    }

    public this(string message, int line, int col){
        super(message);
    }

    public this(Throwable ex, string ksql){
        super("parse error. detail message is :\n" ~ ex.msg ~ "\nsource sql is : \n" ~ ksql, ex);
    }
}
