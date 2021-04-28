module hunt.sql.ast.SQLExprImpl;

import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLObject;
import hunt.sql.ast.SQLDataType;

import hunt.collection;


abstract class SQLExprImpl : SQLObjectImpl, SQLExpr {

    public this(){

    }

    override public abstract bool opEquals(Object o);

    override public abstract size_t toHash();

    public override SQLExpr clone() {
        throw new Exception("Unsupported Operation");
    }

    public override SQLDataType computeDataType() {
        return null;
    }


    public List!SQLObject getChildren() {
        return new ArrayList!SQLObject();
    }
}
