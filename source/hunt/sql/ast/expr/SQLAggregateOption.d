module hunt.sql.ast.expr.SQLAggregateOption;


public struct SQLAggregateOption {

    enum SQLAggregateOption DISTINCT = SQLAggregateOption("DISTINCT");
    enum SQLAggregateOption ALL = SQLAggregateOption("ALL");
    enum SQLAggregateOption UNIQUE = SQLAggregateOption("UNIQUE"); //

    enum SQLAggregateOption DEDUPLICATION  = SQLAggregateOption("DEDUPLICATION");// just for nut

    private string _name;

    this(string name)
    {
        _name = name;
    }

    @property string name()
    {
        return _name;
    }

    bool opEquals(const SQLAggregateOption h) nothrow {
        return _name == h._name ;
    } 

    bool opEquals(ref const SQLAggregateOption h) nothrow {
        return _name == h._name ;
    } 
}
