module hunt.sql.ast.SQLSubPartitionByHash;

import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLSubPartitionBy;
import hunt.container;

public class SQLSubPartitionByHash : SQLSubPartitionBy {

    protected SQLExpr expr;

    // for aliyun ads
    private bool   key;

    public SQLExpr getExpr() {
        return expr;
    }

    public void setExpr(SQLExpr expr) {
        if (expr !is null) {
            expr.setParent(this);
        }
        this.expr = expr;
    }

    protected override void  accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, expr);
            acceptChild(visitor, subPartitionsCount);
        }
        visitor.endVisit(this);
    }

    public bool isKey() {
        return key;
    }

    public void setKey(bool key) {
        this.key = key;
    }

    override public  SQLSubPartitionByHash clone() {
        SQLSubPartitionByHash x = new SQLSubPartitionByHash();
        if (expr !is null) {
            x.setExpr(expr.clone());
        }
        x.key = key;
        return x;
    }

}
