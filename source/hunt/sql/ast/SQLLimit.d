module hunt.sql.ast.SQLLimit;

import hunt.sql.ast.SQLObject;
import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.ast.SQLExpr;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.expr.SQLIntegerExpr;

public  class SQLLimit : SQLObjectImpl {

    public this() {

    }

    public this(SQLExpr rowCount) {
        this.setRowCount(rowCount);
    }

    public this(SQLExpr offset, SQLExpr rowCount) {
        this.setOffset(offset);
        this.setRowCount(rowCount);
    }

    private SQLExpr rowCount;
    private SQLExpr offset;

    public SQLExpr getRowCount() {
        return rowCount;
    }

    public void setRowCount(SQLExpr rowCount) {
        if (rowCount !is null) {
            rowCount.setParent(this);
        }
        this.rowCount = rowCount;
    }

    public void setRowCount(int rowCount) {
        this.setRowCount(new SQLIntegerExpr(rowCount));
    }

    public SQLExpr getOffset() {
        return offset;
    }

    public void setOffset(int offset) {
        this.setOffset(new SQLIntegerExpr(offset));
    }

    public void setOffset(SQLExpr offset) {
        if (offset !is null) {
            offset.setParent(this);
        }
        this.offset = offset;
    }

    protected override void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, offset);
            acceptChild(visitor, rowCount);
        }
        visitor.endVisit(this);
    }

    public override SQLLimit clone() {
        SQLLimit x = new SQLLimit();

        if (offset !is null) {
            x.setOffset(offset.clone());
        }

        if (rowCount !is null) {
            x.setRowCount(rowCount.clone());
        }

        return x;
    }

}
