module hunt.sql.ast.SQLSubPartition;


import hunt.sql.ast.SQLDataType;
import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLPartitionValue;
import hunt.sql.ast.SQLObject;
import hunt.sql.visitor.SQLASTVisitor;

import hunt.collection;

public class SQLSubPartition : SQLObjectImpl {
    protected SQLName           name;
    protected SQLPartitionValue values;
    protected SQLName           tableSpace;

    public SQLName getName() {
        return name;
    }

    public void setName(SQLName name) {
        if (name !is null) {
            name.setParent(this);
        }
        this.name = name;
    }
    
    public SQLPartitionValue getValues() {
        return values;
    }

    public void setValues(SQLPartitionValue values) {
        if (values !is null) {
            values.setParent(this);
        }
        this.values = values;
    }

    public SQLName getTableSpace() {
        return tableSpace;
    }

    public void setTableSpace(SQLName tableSpace) {
        if (tableSpace !is null) {
            tableSpace.setParent(this);
        }
        this.tableSpace = tableSpace;
    }

    protected override void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, name);
            acceptChild(visitor, tableSpace);
            acceptChild(visitor, values);
        }
        visitor.endVisit(this);
    }

    public override SQLSubPartition clone() {
        SQLSubPartition x = new SQLSubPartition();

        if (name !is null) {
            x.setName(name.clone());
        }

        if (values !is null) {
            x.setValues(values.clone());
        }

        if (tableSpace !is null) {
            x.setTableSpace(tableSpace.clone());
        }

        return x;
    }
}
