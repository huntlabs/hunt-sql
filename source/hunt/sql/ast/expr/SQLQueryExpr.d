module hunt.sql.ast.expr.SQLQueryExpr;

import hunt.sql.ast.statement.SQLSelectItem;
import hunt.sql.ast.statement.SQLSelect;
import hunt.sql.ast.statement.SQLSelectQueryBlock;
import hunt.sql.ast.SQLExprImpl;
import hunt.collection;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.SQLDataType;
import hunt.sql.ast.SQLObject;

public class SQLQueryExpr : SQLExprImpl //, Serializable 
{

    private static  long serialVersionUID = 1L;
    public SQLSelect          subQuery;

    public this(){

    }

    public this(SQLSelect select){
        setSubQuery(select);
    }

    public SQLSelect getSubQuery() {
        return this.subQuery;
    }

    public void setSubQuery(SQLSelect subQuery) {
        if (subQuery !is null) {
            subQuery.setParent(this);
        }
        this.subQuery = subQuery;
    }

    override public void output(StringBuffer buf) {
        this.subQuery.output(buf);
    }

    protected override void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, this.subQuery);
        }

        visitor.endVisit(this);
    }

    override public List!SQLObject getChildren() {
        return Collections.singletonList!SQLObject(subQuery);
    }

    public override size_t toHash() @trusted nothrow {
         int prime = 31;
        size_t result = 1;
        result = prime * result + ((subQuery is null) ? 0 : (cast(Object)subQuery).toHash());
        return result;
    }

    override public bool opEquals(Object obj) {
        if (this is obj) {
            return true;
        }
        if (obj is null) {
            return false;
        }
        if (typeid(SQLQueryExpr) != typeid(obj)) {
            return false;
        }
        SQLQueryExpr other = cast(SQLQueryExpr) obj;
        if (subQuery is null) {
            if (other.subQuery !is null) {
                return false;
            }
        } else if (!(cast(Object)(subQuery)).opEquals(cast(Object)(other.subQuery))) {
            return false;
        }
        return true;
    }

    override public SQLQueryExpr clone() {
        SQLQueryExpr x = new SQLQueryExpr();

        if (subQuery !is null) {
            x.setSubQuery(subQuery.clone());
        }

        return x;
    }

    override public SQLDataType computeDataType() {
        if (subQuery is null) {
            return null;
        }

        SQLSelectQueryBlock queryBlock = subQuery.getFirstQueryBlock();
        if (queryBlock is null) {
            return null;
        }

        List!SQLSelectItem selectList = queryBlock.getSelectList();
        if (selectList.size() == 1) {
            return selectList.get(0).computeDataType();
        }

        return null;
    }
}
