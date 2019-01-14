module hunt.sql.ast.SQLSubPartitionByRange;


import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLSubPartitionBy;
import hunt.collection;


public class SQLSubPartitionByRange : SQLSubPartitionBy {
    private List!SQLName columns;

    this()
    {
        columns = new ArrayList!SQLName();
    }
    public List!SQLName getColumns() {
        return columns;
    }

    override protected  void accept0(SQLASTVisitor visitor) {
        
    }

    override public SQLSubPartitionByRange clone() {
        SQLSubPartitionByRange x = new SQLSubPartitionByRange();

        foreach (SQLName column ; columns) {
            SQLName c2 = column.clone();
            c2.setParent(x);
            x.columns.add(c2);
        }

        return x;
    }
}
