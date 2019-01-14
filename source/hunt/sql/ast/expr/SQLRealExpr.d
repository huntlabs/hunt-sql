module hunt.sql.ast.expr.SQLRealExpr;
import hunt.sql.ast.expr.SQLValuableExpr;
import hunt.sql.ast.expr.SQLNumericLiteralExpr;
import hunt.collection;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.Number;
import hunt.Float;
import hunt.sql.ast.SQLObject;

public class SQLRealExpr : SQLNumericLiteralExpr , SQLValuableExpr {

    private float value;

    public this(){

    }

    public this(float value){
        super();
        this.value = value;
    }

    override public SQLRealExpr clone() {
        return new SQLRealExpr(value);
    }

    public override List!SQLObject getChildren() {
        return Collections.emptyList!(SQLObject)();
    }

    public override Number getNumber() {
        return cast(Number)(new Float(value));
    }

    override public Object getValue() {
        return new Float(value);
    }

    public void setValue(float value) {
        this.value = value;
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        visitor.visit(this);

        visitor.endVisit(this);
    }

    public override size_t toHash() @trusted nothrow {
         int prime = 31;
        size_t result = 1;
        result = prime * result + hashOf(value);
        return result;
    }

    public override bool opEquals(Object obj) {
        if (this is obj) {
            return true;
        }
        if (obj is null) {
            return false;
        }
        if (typeid("SQLRealExpr") != typeid(obj)) {
            return false;
        }
        SQLRealExpr other = cast(SQLRealExpr) obj;
        if (value == float.init) {
            if (other.value !is float.init) {
                return false;
            }
        } else if (!(value == other.value)) {
            return false;
        }
        return true;
    }

    public override void setNumber(Number number) {
        if (number is null) {
            this.setValue(float.init);
            return;
        }

        this.setValue(number.floatValue());
    }

}
