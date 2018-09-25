module hunt.sql.ast.expr.SQLTextLiteralExpr;

import hunt.sql.ast.expr.SQLTextLiteralExpr;
import hunt.sql.ast.expr.SQLLiteralExpr;
import hunt.sql.ast.SQLExprImpl;
import hunt.container;
import hunt.sql.ast.SQLObject;
import hunt.sql.util.String;

public abstract class SQLTextLiteralExpr : SQLExprImpl , SQLLiteralExpr {

    protected String text;

    public this(){

    }

    public this(String text){

        this.text = text;
    }

    public String getText() {
        return this.text;
    }

    public void setText(String text) {
        this.text = text;
    }

    public override size_t toHash() @trusted nothrow {
         int prime = 31;
        size_t result = 1;
        result = prime * result + hashOf(text);
        return result;
    }

    public override bool opEquals(Object obj) {
        if (this is obj) {
            return true;
        }
        if (obj is null) {
            return false;
        }
        if (typeid(SQLTextLiteralExpr) != typeid(obj)) {
            return false;
        }
        SQLTextLiteralExpr other = cast(SQLTextLiteralExpr) obj;
        if (text is null) {
            if (other.text !is null) {
                return false;
            }
        } else if (!(text == other.text)) {
            return false;
        }
        return true;
    }

    override public abstract SQLTextLiteralExpr clone();

    public override List!SQLObject getChildren() {
        return Collections.emptyList!(SQLObject)();
    }
}
