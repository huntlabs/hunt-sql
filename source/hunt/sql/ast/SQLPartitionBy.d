module hunt.sql.ast.SQLPartitionBy;

import hunt.sql.ast.SQLDataType;
import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLPartition;
import hunt.sql.ast.SQLSubPartitionBy;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.container;


public abstract class SQLPartitionBy : SQLObjectImpl {
    protected SQLSubPartitionBy  subPartitionBy;
    protected SQLExpr            partitionsCount;
    protected bool            linear;
    protected List!SQLPartition partitions;
    protected List!SQLName      storeIn;
    protected List!SQLExpr      columns;

    this()
    {
        partitions = new ArrayList!SQLPartition();
        storeIn    = new ArrayList!SQLName();
        columns    = new ArrayList!SQLExpr();
    }

    public List!SQLPartition getPartitions() {
        return partitions;
    }
    
    public void addPartition(SQLPartition partition) {
        if (partition !is null) {
            partition.setParent(this);
        }
        this.partitions.add(partition);
    }

    public SQLSubPartitionBy getSubPartitionBy() {
        return subPartitionBy;
    }

    public void setSubPartitionBy(SQLSubPartitionBy subPartitionBy) {
        if (subPartitionBy !is null) {
            subPartitionBy.setParent(this);
        }
        this.subPartitionBy = subPartitionBy;
    }

    public SQLExpr getPartitionsCount() {
        return partitionsCount;
    }

    public void setPartitionsCount(SQLExpr partitionsCount) {
        if (partitionsCount !is null) {
            partitionsCount.setParent(this);
        }
        this.partitionsCount = partitionsCount;
    }

    public bool isLinear() {
        return linear;
    }

    public void setLinear(bool linear) {
        this.linear = linear;
    }

    public List!SQLName getStoreIn() {
        return storeIn;
    }

    public List!SQLExpr getColumns() {
        return columns;
    }

    public void addColumn(SQLExpr column) {
        if (column !is null) {
            column.setParent(this);
        }
        this.columns.add(column);
    }

    public void cloneTo(SQLPartitionBy x) {
        if (subPartitionBy !is null) {
            x.setSubPartitionBy(subPartitionBy.clone());
        }
        if (partitionsCount !is null) {
            x.setPartitionsCount(partitionsCount.clone());
        }
        x.linear = linear;
        foreach (SQLPartition p ; partitions) {
            SQLPartition p2 = p.clone();
            p2.setParent(x);
            x.partitions.add(p2);
        }
        foreach (SQLName name ; storeIn) {
            SQLName name2 = name.clone();
            name2.setParent(x);
            x.storeIn.add(name2);
        }
    }

    public override abstract SQLPartitionBy clone();
}
