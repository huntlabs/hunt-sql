module hunt.sql.ast.SQLArrayDataType;


import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLDataType;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.util.FnvHash;
import hunt.container;


public class SQLArrayDataType : SQLObjectImpl , SQLDataType {
    private string dbType;
    private SQLDataType componentType;

    public this(SQLDataType componentType) {
        setComponentType(componentType);
    }

    public this(SQLDataType componentType, string dbType) {
        this.dbType = dbType;
        setComponentType(componentType);
    }

    public string getName() {
        return "ARRAY";
    }

    public long nameHashCode64() {
        return FnvHash.Constants.ARRAY;
    }

    public void setName(string name) {
        throw new Exception("UnsupportedOperation");
    }

    public List!SQLExpr getArguments() {
        return new ArrayList!SQLExpr();
    }

    public bool getWithTimeZone() {
        return false;
    }

    public void setWithTimeZone(bool value) {
        throw new Exception("UnsupportedOperation");
    }

    public bool isWithLocalTimeZone() {
        return false;
    }

    public void setWithLocalTimeZone(bool value) {
        throw new Exception("UnsupportedOperation");
    }

    public void setDbType(string dbType) {
        dbType = dbType;
    }

    public string getDbType() {
        return dbType;
    }

    
    protected override void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, componentType);
        }
        visitor.endVisit(this);
    }

    public override SQLArrayDataType clone() {
        return null;
    }

    public SQLDataType getComponentType() {
        return componentType;
    }

    public void setComponentType(SQLDataType x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.componentType = x;
    }
}
