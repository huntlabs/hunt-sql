module hunt.sql.ast.SQLCommentHint;

import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.ast.SQLHint;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.container;
import hunt.util.exception;


public class SQLCommentHint : SQLObjectImpl , SQLHint {

    private string text;

    public this(){

    }

    public this(string text){

        this.text = text;
    }

    public string getText() {
        return this.text;
    }

    public void setText(string text) {
        this.text = text;
    }

    protected override void accept0(SQLASTVisitor visitor) {
        visitor.visit(this);
        visitor.endVisit(this);
    }

    public override SQLCommentHint clone() {
        return new SQLCommentHint(text);
    }

    public override void output(StringBuffer buf) {
        // new SQLASTOutputVisitor(buf).visit(this); @gxc
        implementationMissing();

    }
}
