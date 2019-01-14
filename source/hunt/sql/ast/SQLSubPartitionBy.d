module hunt.sql.ast.SQLSubPartitionBy;

import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLSubPartition;
import hunt.collection;
import hunt.sql.ast.statement.SQLAssignItem;


public abstract class SQLSubPartitionBy : SQLObjectImpl {

    protected SQLExpr               subPartitionsCount;
    protected bool               linear;
    protected List!SQLAssignItem   options;
    protected List!SQLSubPartition subPartitionTemplate;

    this()
    {
        options              = new ArrayList!SQLAssignItem();
        subPartitionTemplate = new ArrayList!SQLSubPartition();
    }

    public SQLExpr getSubPartitionsCount() {
        return subPartitionsCount;
    }

    public void setSubPartitionsCount(SQLExpr subPartitionsCount) {
        if (subPartitionsCount !is null) {
            subPartitionsCount.setParent(this);
        }

        this.subPartitionsCount = subPartitionsCount;
    }

    public bool isLinear() {
        return linear;
    }

    public void setLinear(bool linear) {
        this.linear = linear;
    }

    public List!SQLAssignItem getOptions() {
        return options;
    }

    public List!SQLSubPartition getSubPartitionTemplate() {
        return subPartitionTemplate;
    }

    public void cloneTo(SQLSubPartitionBy x) {
        if (subPartitionsCount !is null) {
            x.setSubPartitionsCount(subPartitionsCount.clone());
        }
        x.linear = linear;
        foreach (SQLAssignItem option ; options) {
            SQLAssignItem option2 = option.clone();
            option2.setParent(x);
            x.options.add(option2);
        }

        foreach (SQLSubPartition p ; subPartitionTemplate) {
            SQLSubPartition p2 = p.clone();
            p2.setParent(x);
            x.subPartitionTemplate.add(p2);
        }
    }

    public override abstract SQLSubPartitionBy clone();
}
