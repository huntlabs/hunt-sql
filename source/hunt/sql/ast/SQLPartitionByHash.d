module hunt.sql.ast.SQLPartitionByHash;

import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLPartitionBy;
import hunt.collection;
import hunt.sql.ast.SQLObject;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLPartition;

public class SQLPartitionByHash : SQLPartitionBy {

    alias cloneTo = SQLPartitionBy.cloneTo;
    // for aliyun ads
    protected bool key;
    protected bool unique;

    public bool isKey() {
        return key;
    }

    public void setKey(bool key) {
        this.key = key;
    }

    public bool isUnique() {
        return unique;
    }

    public void setUnique(bool unique) {
        this.unique = unique;
    }

    protected override void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, partitionsCount);
            acceptChild!SQLPartition(visitor, getPartitions());
            acceptChild(visitor, subPartitionBy);
        }
        visitor.endVisit(this);
    }

    public override SQLPartitionByHash clone() {
        SQLPartitionByHash x = new SQLPartitionByHash();

        this.cloneTo(x);

        x.key = key;
        x.unique = unique;

        foreach (SQLExpr column ; columns) {
            SQLExpr c2 = column.clone();
            c2.setParent(x);
            x.columns.add(c2);
        }

        return x;
    }

    public void cloneTo(SQLPartitionByHash x) {
        super.cloneTo(cast(SQLPartitionBy)x);
    }
}
