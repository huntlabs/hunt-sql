module hunt.sql.ast.SQLPartitionByList;

import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLPartitionBy;
import hunt.container;
import hunt.sql.ast.SQLObject;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLPartition;
public class SQLPartitionByList : SQLPartitionBy {

    protected override void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild!SQLExpr(visitor, columns);
            acceptChild(visitor, partitionsCount);
            acceptChild!SQLPartition(visitor, getPartitions());
            acceptChild(visitor, subPartitionBy);
        }
        visitor.endVisit(this);
    }

    public override SQLPartitionByList clone() {
        SQLPartitionByList x = new SQLPartitionByList();

        foreach (SQLExpr column ; columns) {
            SQLExpr c2 = column.clone();
            c2.setParent(x);
            x.columns.add(c2);
        }

        return x;
    }
}
