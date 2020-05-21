module hunt.sql.ast.SQLCommentHint;

import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.ast.SQLHint;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.collection;
import hunt.Exceptions;
import hunt.util.StringBuilder;


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

    public override void output(StringBuilder buf) {
        // new SQLASTOutputVisitor(buf).visit(this); @gxc
        implementationMissing();

    }
}
