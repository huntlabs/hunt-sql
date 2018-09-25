module hunt.sql.ast.SQLWindow;


import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLOver;
import hunt.container;

public class SQLWindow : SQLObjectImpl {
    private SQLName name;
    private SQLOver over;

    public this(SQLName name, SQLOver over) {
        this.setName(name);
        this.setOver(over);
    }

    public SQLName getName() {
        return name;
    }

    public void setName(SQLName x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.name = x;
    }

    public SQLOver getOver() {
        return over;
    }

    public void setOver(SQLOver x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.over = x;
    }

    protected override void accept0(SQLASTVisitor v) {
        if (v.visit(this)) {
            acceptChild(v, name);
            acceptChild(v, over);
        }
        v.endVisit(this);
    }
}
