module hunt.sql.ast.SQLMapDataType;

import hunt.sql.ast.SQLDataType;
import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.ast.SQLExpr;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.util.FnvHash;
import hunt.sql.ast.SQLObject;

import hunt.Boolean;
import hunt.collection;

public class SQLMapDataType : SQLObjectImpl , SQLDataType {
    private string dbType;
    private SQLDataType keyType;
    private SQLDataType valueType;

    public this() {

    }

    public this(SQLDataType keyType, SQLDataType valueType) {
        this.setKeyType(keyType);
        this.setValueType(valueType);
    }

    public this(SQLDataType keyType, SQLDataType valueType, string dbType) {
        this.setKeyType(keyType);
        this.setValueType(valueType);
        this.dbType = dbType;
    }

    public override string getName() {
        return "MAP";
    }

    public override long nameHashCode64() {
        return FnvHash.Constants.MAP;
    }

    public override void setName(string name) {
        throw new Exception("UnsupportedOperation");
    }

    public override List!SQLExpr getArguments() {
        return Collections.emptyList!(SQLExpr)();
    }

    
    public override Boolean getWithTimeZone() {
        return Boolean.FALSE;
    }

    public override void setWithTimeZone(Boolean value) {
        throw new Exception("UnsupportedOperation");
    }

    public override bool isWithLocalTimeZone() {
        return false;
    }

    public override void setWithLocalTimeZone(bool value) {
        throw new Exception("UnsupportedOperation");
    }

    public override void setDbType(string dbType) {
        dbType = dbType;
    }

    public override string getDbType() {
        return dbType;
    }

    protected override void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, keyType);
            acceptChild(visitor, valueType);
        }
        visitor.endVisit(this);
    }

    public override SQLMapDataType clone() {
        SQLMapDataType x = new SQLMapDataType();
        x.dbType = dbType;

        if (keyType !is null) {
            x.setKeyType(keyType.clone());
        }

        if (valueType !is null) {
            x.setValueType(valueType.clone());
        }

        return x;
    }

    public SQLDataType getKeyType() {
        return keyType;
    }

    public void setKeyType(SQLDataType x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.keyType = x;
    }

    public SQLDataType getValueType() {
        return valueType;
    }

    public void setValueType(SQLDataType x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.valueType = x;
    }
}
