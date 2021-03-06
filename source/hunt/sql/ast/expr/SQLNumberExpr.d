module hunt.sql.ast.expr.SQLNumberExpr;
import hunt.sql.ast.expr.SQLValuableExpr;
import hunt.sql.ast.expr.SQLNumericLiteralExpr;
import hunt.sql.ast.SQLDataType;
import hunt.Number;
import hunt.math;
import hunt.collection;
import hunt.String;
import hunt.text;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.SQLDataTypeImpl;
import hunt.sql.util.Utils;
import hunt.util.StringBuilder;

public class SQLNumberExpr : SQLNumericLiteralExpr, SQLValuableExpr
{

    public static SQLDataType defaultDataType;

    private Number number;

    private char[] chars;

    public this()
    {
        defaultDataType = new SQLDataTypeImpl("number");
    }

    public this(Number number)
    {
        this.number = number;
    }

    public this(char[] chars)
    {
        this.chars = chars;
    }

    public override Number getNumber()
    {
        try
        {
            if (chars !is null && number is null)
            {
                this.number = new BigDecimal(chars);
            }
        }
        catch (Exception)
        {
        }

        return this.number;
    }

    public Object getValue()
    {
        return cast(Object)getNumber();
    }

    override public void setNumber(Number number)
    {
        this.number = number;
        this.chars = null;
    }

    override void output(StringBuilder buf)
    {
        if (chars !is null)
        {
            buf.append(chars);
        }
        else
        {
            buf.append((cast(Object)(this.number)).toString());
        }
    }

    override protected void accept0(SQLASTVisitor visitor)
    {
        visitor.visit(this);
        visitor.endVisit(this);
    }

    override public size_t toHash() @trusted nothrow
    {
        Number number;
        try
        {
             number = getNumber();
            if (number is null)
            {
                return 0;
            }
        }
        catch (Exception)
        {
        }

        return (cast(Object) number).toHash();
    }

    override public bool opEquals(Object obj)
    {
        if (chars !is null && number is null)
        {
            this.number = new BigDecimal(chars);
        }

        if (this is obj)
        {
            return true;
        }
        if (obj is null)
        {
            return false;
        }
        if (typeid(this) != typeid(obj))
        {
            return false;
        }

        SQLNumberExpr other = cast(SQLNumberExpr) obj;
        return Utils.equals(cast(Object)getNumber(), cast(Object)(other.getNumber()));
    }

    override public SQLNumberExpr clone()
    {
        SQLNumberExpr x = new SQLNumberExpr();
        x.chars = chars;
        x.number = number;
        return x;
    }

    override public SQLDataType computeDataType()
    {
        return defaultDataType;
    }
}
