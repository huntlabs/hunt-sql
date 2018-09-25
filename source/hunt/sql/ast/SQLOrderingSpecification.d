module hunt.sql.ast.SQLOrderingSpecification;

import std.uni;

public class SQLOrderingSpecification {

    public static  SQLOrderingSpecification ASC ;
    public static  SQLOrderingSpecification DESC ;

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

    bool opEquals(const SQLOrderingSpecification h) nothrow {
        return name == h.name ;
    } 

    bool opEquals(ref const SQLOrderingSpecification h) nothrow {
        return name == h.name ;
    } 
}
