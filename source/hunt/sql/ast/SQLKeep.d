module hunt.sql.ast.SQLKeep;

import hunt.sql.ast.SQLObject;
import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.ast.SQLOrderBy;
import hunt.sql.visitor.SQLASTVisitor;


public  class SQLKeep : SQLObjectImpl {

    protected DenseRank  denseRank;

    protected SQLOrderBy orderBy;

    protected override void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, this.orderBy);
        }
        visitor.endVisit(this);
    }

    public DenseRank getDenseRank() {
        return denseRank;
    }

    public void setDenseRank(DenseRank denseRank) {
        this.denseRank = denseRank;
    }

    public SQLOrderBy getOrderBy() {
        return orderBy;
    }

    public void setOrderBy(SQLOrderBy orderBy) {
        if (orderBy !is null) {
            orderBy.setParent(this);
        }
        this.orderBy = orderBy;
    }


    public override SQLKeep clone() {
        SQLKeep x = new SQLKeep();

        x.denseRank = denseRank;

        if (orderBy !is null) {
            x.setOrderBy(orderBy.clone());
        }

        return x;
    }

    public static enum DenseRank {
                                  FIRST, //
                                  LAST
    }
}
