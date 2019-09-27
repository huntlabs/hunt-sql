module hunt.sql.ast.SQLOrderingSpecification;

import std.uni;
import std.concurrency : initOnce;

public class SQLOrderingSpecification {

    // public static  SQLOrderingSpecification ASC;
    // public static  SQLOrderingSpecification DESC;
    
    static SQLOrderingSpecification ASC() {
        __gshared SQLOrderingSpecification inst;
        return initOnce!inst(new SQLOrderingSpecification("ASC"));
    }

    static SQLOrderingSpecification DESC() {
        __gshared SQLOrderingSpecification inst;
        return initOnce!inst(new SQLOrderingSpecification("DESC"));
    }

    // static this()
    // {
    //     ASC = new SQLOrderingSpecification("ASC");
    //     DESC = new  SQLOrderingSpecification("DESC");
    // }
    
    public  string name;
    public  string name_lcase;

    public this(string name){
        this.name = name;
        this.name_lcase = toLower(name);
    }

    override public size_t toHash() @trusted nothrow {
        return hashOf(name);
    }


    bool opEquals(const SQLOrderingSpecification h) nothrow {
        return name == h.name ;
    } 

    bool opEquals(ref const SQLOrderingSpecification h) nothrow {
        return name == h.name ;
    } 
}
