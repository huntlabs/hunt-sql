module hunt.sql.ast.expr.SQLVariantRefExpr;

import hunt.sql.ast.SQLExprImpl;
import hunt.collection;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.SQLObject;
import hunt.util.StringBuilder;

public class SQLVariantRefExpr : SQLExprImpl {

    private string  name;

    private bool global = false;

    private bool session = false;

    private int     index  = -1;

    public this(string name){
        this.name = name;
    }

    public this(string name, bool global){
        this.name = name;
        this.global = global;
    }

    public this(string name, bool global,bool session){
        this.name = name;
        this.global = global;
        this.session = session;
    }

    public this(){

    }

    public int getIndex() {
        return index;
    }

    public void setIndex(int index) {
        this.index = index;
    }

    public string getName() {
        return this.name;
    }

    public void setName(string name) {
        this.name = name;
    }

    override public void output(StringBuilder buf) {
        buf.append(this.name);
    }


    public bool isSession() {
        return session;
    }

    public void setSession(bool session) {
        this.session = session;
    }

    protected override void accept0(SQLASTVisitor visitor) {
        visitor.visit(this);

        visitor.endVisit(this);
    }

    public override size_t toHash() @trusted nothrow {
         int prime = 31;
        size_t result = 1;
        result = prime * result + hashOf(name);
        return result;
    }

    public override bool opEquals(Object obj) {
        if (this is obj) {
            return true;
        }
        if (obj is null) {
            return false;
        }
        // if (!(cast(SQLVariantRefExpr)(obj) !is null)) {
        //     return false;
        // }
        SQLVariantRefExpr other = cast(SQLVariantRefExpr) obj;
        if(other is null)
            return false;
        if (name is null) {
            if (other.name !is null) {
                return false;
            }
        } else if (!(name == other.name)) {
            return false;
        }
        return true;
    }

    public bool isGlobal() {
        return global;
    }

    public void setGlobal(bool global) {
        this.global = global;
    }

    override public SQLVariantRefExpr clone() {
        SQLVariantRefExpr var =  new SQLVariantRefExpr(name, global);
        var.index = index;

        if (attributes !is null) {
            var.attributes = new HashMap!(string, Object)(attributes.size());
            foreach (string k,Object v ; attributes) {
                // string k = entry.getKey();
                // Object v = entry.getValue();

                if (cast(SQLObject)v !is null) {
                    var.attributes.put(k, cast(Object)((cast(SQLObject) v).clone()));
                } else {
                    var.attributes.put(k, v);
                }
            }
        }

        return var;
    }

    public override List!SQLObject getChildren() {
        return Collections.emptyList!(SQLObject)();
    }
}
