module hunt.sql.ast.SQLSubPartitionByList;

import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLSubPartitionBy;
import hunt.collection;

public class SQLSubPartitionByList : SQLSubPartitionBy {

    protected SQLName column;

    override protected  void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, column);
            acceptChild(visitor, subPartitionsCount);
        }
        visitor.endVisit(this);
    }

    public SQLName getColumn() {
        return column;
    }

    public void setColumn(SQLName column) {
        if (column !is null) {
            column.setParent(this);
        }
        this.column = column;
    }

    override public SQLSubPartitionByList clone() {
        SQLSubPartitionByList x = new SQLSubPartitionByList();
        if (column !is null) {
            x.setColumn(column.clone());
        }
        return x;
    }
}
