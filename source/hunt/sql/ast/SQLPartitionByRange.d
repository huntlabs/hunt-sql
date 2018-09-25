module hunt.sql.ast.SQLPartitionByRange;

import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLPartitionBy;
import hunt.container;
import hunt.sql.ast.SQLObject;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLPartition;

public class SQLPartitionByRange : SQLPartitionBy {
    protected SQLExpr       interval;

    public this() {

    }

    public SQLExpr getInterval() {
        return interval;
    }

    public void setInterval(SQLExpr interval) {
        if (interval !is null) {
            interval.setParent(this);
        }
        
        this.interval = interval;
    }

    protected override void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild!SQLExpr(visitor, columns);
            acceptChild(visitor, interval);
            acceptChild!SQLName(visitor, storeIn);
            acceptChild!SQLPartition(visitor, partitions);
        }
        visitor.endVisit(this);
    }

    public override SQLPartitionByRange clone() {
        SQLPartitionByRange x = new SQLPartitionByRange();

        if (interval !is null) {
            x.setInterval(interval.clone());
        }

        foreach (SQLExpr column ; columns) {
            SQLExpr c2 = column.clone();
            c2.setParent(x);
            x.columns.add(c2);
        }

        return x;
    }
}
