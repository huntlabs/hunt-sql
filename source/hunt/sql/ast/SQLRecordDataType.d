module hunt.sql.ast.SQLRecordDataType;

import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLDataTypeImpl;
import hunt.sql.ast.SQLDataType;
import hunt.collection;
import hunt.sql.ast.statement.SQLColumnDefinition;
import hunt.sql.ast.SQLObject;


public class SQLRecordDataType : SQLDataTypeImpl/*  , SQLDataType  */{
    private  List!SQLColumnDefinition columns;

    this()
    {
        columns = new ArrayList!SQLColumnDefinition();
    }

    public List!SQLColumnDefinition getColumns() {
        return columns;
    }

    public void addColumn(SQLColumnDefinition column) {
        column.setParent(this);
        this.columns.add(column);
    }

    public override SQLRecordDataType clone() {
        SQLRecordDataType x = new SQLRecordDataType();
        cloneTo(x);

        foreach (SQLColumnDefinition c ; columns) {
            SQLColumnDefinition c2 = c.clone();
            c2.setParent(x);
            x.columns.add(c2);
        }

        return x;
    }

    protected override void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild!SQLColumnDefinition(visitor, this.columns);
        }

        visitor.endVisit(this);
    }
}
