module hunt.sql.ast.expr.SQLTimestampExpr;
import hunt.sql.ast.expr.SQLValuableExpr;
import hunt.sql.ast.SQLDataType;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.SQLExprImpl;
import hunt.collection;
import hunt.sql.ast.SQLObject;
import hunt.sql.ast.statement.SQLCharacterDataType;
import hunt.sql.SQLUtils;
//import hunt.lang;
import hunt.String;

public class SQLTimestampExpr : SQLExprImpl , SQLValuableExpr {
    public static  SQLDataType DEFAULT_DATA_TYPE ;

    protected string  literal;
    protected string  timeZone;
    protected bool withTimeZone = false;

    // static this(){
    //     DEFAULT_DATA_TYPE = new SQLCharacterDataType("datetime");
    // }
    this()
    {
    }
    public this(string literal){
        this.literal = literal;
    }


    override public SQLTimestampExpr clone() {
        SQLTimestampExpr x = new SQLTimestampExpr();
        x.literal = literal;
        x.timeZone = timeZone;
        x.withTimeZone = withTimeZone;
        return x;
    }

    override public Object getValue() {
        return new String(literal);
    }

    public string getLiteral() {
        return literal;
    }

    public void setLiteral(string literal) {
        this.literal = literal;
    }

    public string getTimeZone() {
        return this.timeZone;
    }

    public void setTimeZone(string timeZone) {
        this.timeZone = timeZone;
    }

    public bool isWithTimeZone() {
        return withTimeZone;
    }

    public void setWithTimeZone(bool withTimeZone) {
        this.withTimeZone = withTimeZone;
    }

    public override size_t toHash() @trusted nothrow {
         int prime = 31;
        size_t result = 1;
        result = prime * result + hashOf(literal);
        result = prime * result + hashOf(timeZone);
        result = prime * result + (withTimeZone ? 1231 : 1237);
        return result;
    }

    public override bool opEquals(Object obj) {
        if (this is obj) {
            return true;
        }
        if (obj is null) {
            return false;
        }
        if (typeid(SQLTimestampExpr) != typeid(obj)) {
            return false;
        }
        SQLTimestampExpr other = cast(SQLTimestampExpr) obj;
        if (literal is null) {
            if (other.literal !is null) {
                return false;
            }
        } else if (!(literal == other.literal)) {
            return false;
        }
        if (timeZone is null) {
            if (other.timeZone !is null) {
                return false;
            }
        } else if (!(timeZone == other.timeZone)) {
            return false;
        }
        if (withTimeZone != other.withTimeZone) {
            return false;
        }
        return true;
    }

    protected override void accept0(SQLASTVisitor visitor) {
        visitor.visit(this);

        visitor.endVisit(this);
    }

    override public string toString() {
        return SQLUtils.toSQLString(this, null);
    }

    override public SQLDataType computeDataType() {
        return DEFAULT_DATA_TYPE;
    }

    public override List!SQLObject getChildren() {
        return Collections.emptyList!(SQLObject)();
    }
}
