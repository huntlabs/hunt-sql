module hunt.sql.ast.SQLStructDataType;

import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.ast.SQLObject;
import hunt.sql.ast.SQLDataType;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLExpr;
import hunt.sql.util.FnvHash;
import hunt.sql.visitor.SQLASTVisitor;

import hunt.container;


public class SQLStructDataType : SQLObjectImpl , SQLDataType {
    private string dbType;
    private List!Field fields;

    public this() {
        fields = new ArrayList!Field();
    }

    public this(string dbType) {
        this.dbType = dbType;
        this();
    }

    public override string getName() {
        return "STRUCT";
    }

    public override long nameHashCode64() {
        return FnvHash.Constants.STRUCT;
    }

    public override void setName(string name) {
        throw new Exception("UnsupportedOperation");
    }

    public override List!SQLExpr getArguments() {
        return new ArrayList!SQLExpr();
    }

    public override bool getWithTimeZone() {
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

    public override void setDbType(string dbType) {
        dbType = dbType;
    }

    public override string getDbType() {
        return dbType;
    }

    protected override void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild!(SQLStructDataType.Field)(visitor, fields);
        }
        visitor.endVisit(this);
    }

    public override SQLStructDataType clone() {
        SQLStructDataType x = new SQLStructDataType(dbType);

        foreach (Field field ; fields) {
            x.addField(field.name, field.dataType.clone());
        }

        return x;
    }

    public List!Field getFields() {
        return fields;
    }

    public void addField(SQLName name, SQLDataType dataType) {
        Field field = new Field(name, dataType);
        field.setParent(this);
        fields.add(field);
    }

    public static class Field : SQLObjectImpl {
        private SQLName name;
        private SQLDataType dataType;

        public this(SQLName name, SQLDataType dataType) {
            setName(name);
            setDataType(dataType);
        }

        protected override void accept0(SQLASTVisitor visitor) {
            if (visitor.visit(this)) {
                acceptChild(visitor, name);
                acceptChild(visitor, dataType);
            }
            visitor.endVisit(this);
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

        public SQLDataType getDataType() {
            return dataType;
        }

        public void setDataType(SQLDataType x) {
            if (x !is null) {
                x.setParent(this);
            }
            this.dataType = x;
        }
    }
}
