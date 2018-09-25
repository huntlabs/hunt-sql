module hunt.sql.ast.SQLPartitionValue;

import hunt.sql.ast.SQLDataType;
import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.container;
import hunt.sql.ast.SQLObject;

public class SQLPartitionValue : SQLObjectImpl {

    protected Operator            operator;
    protected  List!SQLExpr items;

    public this(Operator operator){
        super();
        items = new ArrayList!SQLExpr();
        this.operator = operator;
    }

    public List!SQLExpr getItems() {
        return items;
    }
    
    public void addItem(SQLExpr item) {
        if (item !is null) {
            item.setParent(this);
        }
        this.items.add(item);
    }

    public Operator getOperator() {
        return operator;
    }

    public static enum Operator {
                                 LessThan, //
                                 In, //
                                 List
    }

    protected override void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild!SQLExpr(visitor, getItems());
        }
        visitor.endVisit(this);
    }

    public override SQLPartitionValue clone() {
        SQLPartitionValue x = new SQLPartitionValue(operator);

        foreach (SQLExpr item ; items) {
            SQLExpr item2 = item.clone();
            item2.setParent(x);
            x.items.add(item2);
        }

        return x;
    }
}
