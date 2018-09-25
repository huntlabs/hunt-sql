module hunt.sql.ast.SQLOrderBy;

import hunt.sql.ast.SQLObject;
import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLOrderingSpecification;
import hunt.container;
import hunt.sql.ast.statement.SQLSelectOrderByItem;



public  class SQLOrderBy : SQLObjectImpl {

    protected  List!SQLSelectOrderByItem items;
    
    // for postgres
    private bool                            sibings;

    public this(){
        items = new ArrayList!SQLSelectOrderByItem();
    }

    public this(SQLExpr expr){
        this();
        SQLSelectOrderByItem item = new SQLSelectOrderByItem(expr);
        addItem(item);
    }

    public void addItem(SQLSelectOrderByItem item) {
        if (item !is null) {
            item.setParent(this);
        }
        this.items.add(item);
    }

    public List!SQLSelectOrderByItem getItems() {
        return this.items;
    }
    
    public bool isSibings() {
        return this.sibings;
    }

    public void setSibings(bool sibings) {
        this.sibings = sibings;
    }

    protected override void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild!SQLSelectOrderByItem(visitor, this.items);
        }

        visitor.endVisit(this);
    }

    override public size_t toHash() @trusted nothrow {
         int prime = 31;
        size_t result = 1;
        result = prime * result + ((items is null) ? 0 : (cast(Object)items).toHash());
        result = prime * result + (sibings ? 1231 : 1237);
        return result;
    }

    override public bool opEquals(Object obj) {
        if (this is obj) return true;
        if (obj is null) return false;
        if (typeid(SQLOrderBy) != typeid(obj)) return false;
        SQLOrderBy other = cast(SQLOrderBy) obj;
        if (items is null) {
            if (other.items !is null) return false;
        } else if (!(items == other.items)) return false;
        if (sibings != other.sibings) return false;
        return true;
    }

    public void addItem(SQLExpr expr, SQLOrderingSpecification type) {
        SQLSelectOrderByItem item = createItem();
        item.setExpr(expr);
        item.setType(type);
        addItem(item);
    }

    protected SQLSelectOrderByItem createItem() {
        return new SQLSelectOrderByItem();
    }

    public override SQLOrderBy clone() {
        SQLOrderBy x = new SQLOrderBy();

        foreach (SQLSelectOrderByItem item ; items) {
            SQLSelectOrderByItem item1 = item.clone();
            item1.setParent(x);
            x.items.add(item1);
        }

        x.sibings = sibings;

        return x;
    }
}
