module hunt.sql.ast.expr.SQLSequenceExpr;
import hunt.sql.ast.SQLExprImpl;
import hunt.sql.ast.SQLName;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.container;
import std.uni;
import hunt.sql.ast.SQLObject;

public class SQLSequenceExpr : SQLExprImpl {

    private SQLName  sequence;
    private Function _function;

    public this(){

    }

    public this(SQLName sequence, Function function_p){
        this.sequence = sequence;
        this._function = function_p;
    }

    override public SQLSequenceExpr clone() {
        SQLSequenceExpr x = new SQLSequenceExpr();
        if (sequence !is null) {
            x.setSequence(sequence.clone());
        }
        x._function = _function;
        return x;
    }

    protected override void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, sequence);
        }
        visitor.endVisit(this);
    }

    public static struct Function {
                                 enum Function NextVal = Function("NEXTVAL");
                                 enum Function CurrVal = Function("CURRVAL");
                                 enum Function PrevVal = Function("PREVVAL");

        public  string name;
        public  string name_lcase;

        private this(string name){
            this.name = name;
            this.name_lcase = toLower(name);
        }

        bool opEquals(const Function h) nothrow {
            return name == h.name ;
        } 

        bool opEquals(ref const Function h) nothrow {
            return name == h.name ;
        } 
    }

    override public List!SQLObject getChildren() {
        return Collections.singletonList!SQLObject(sequence);
    }

    public SQLName getSequence() {
        return sequence;
    }

    public void setSequence(SQLName sequence) {
        this.sequence = sequence;
    }

    public Function getFunction() {
        return _function;
    }

    public void setFunction(Function function_p) {
        this._function = function_p;
    }

    public override size_t toHash() @trusted nothrow {
         int prime = 31;
        size_t result = 1;
        result = prime * result + hashOf(_function);
        result = prime * result + ((sequence is null) ? 0 : (cast(Object)sequence).toHash());
        return result;
    }

    public override bool opEquals(Object obj) {
        if (this is obj) return true;
        if (obj is null) return false;
        if (typeid(SQLSequenceExpr) != typeid(obj)) return false;
        SQLSequenceExpr other = cast(SQLSequenceExpr) obj;
        if (_function != other._function) return false;
        if (sequence is null) {
            if (other.sequence !is null) return false;
        } else if (!(cast(Object)(sequence)).opEquals(cast(Object)(other.sequence))) return false;
        return true;
    }

}
