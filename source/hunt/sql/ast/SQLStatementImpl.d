module hunt.sql.ast.SQLStatementImpl;

import hunt.sql.ast.SQLObject;
import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.ast.SQLStatement;
import hunt.sql.ast.SQLCommentHint;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.SQLUtils;

import hunt.container;
import hunt.util.exception;


public abstract class SQLStatementImpl : SQLObjectImpl , SQLStatement {
    protected string               dbType;
    protected bool              afterSemi;
    protected List!SQLCommentHint headHints;

    public this(){

    }
    
    public this(string dbType){
        this.dbType = dbType;
    }
    
    public string getDbType() {
        return dbType;
    }

    public void setDbType(string dbType) {
        this.dbType = dbType;
    }

    public override string toString() {
        return SQLUtils.toSQLString(this, dbType);
    }

    public override string toLowerCaseString() {
        // return SQLUtils.toSQLString(this, dbType, SQLUtils.DEFAULT_LCASE_FORMAT_OPTION);@gxc
        implementationMissing();
        return string.init;
    }

    protected override void accept0(SQLASTVisitor visitor) {
        throw new Exception("UnsupportedOperation");
    }

    public List!SQLObject getChildren() {
        throw new Exception("UnsupportedOperation");
    }

    public bool isAfterSemi() {
        return afterSemi;
    }

    public void setAfterSemi(bool afterSemi) {
        this.afterSemi = afterSemi;
    }

    public override SQLStatement clone() {
        throw new Exception("UnsupportedOperation");
    }

    public List!SQLCommentHint getHeadHintsDirect() {
        return headHints;
    }

    public void setHeadHints(List!SQLCommentHint headHints) {
        this.headHints = headHints;
    }
}
