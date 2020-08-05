module hunt.sql.ast.SQLDataTypeImpl;

import hunt.collection;
import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.ast.SQLDataType;
import hunt.sql.ast.SQLExpr;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.SQLObject;
import hunt.sql.util.FnvHash;
import hunt.sql.SQLUtils;



public class SQLDataTypeImpl : SQLObjectImpl , SQLDataType {

    private         string        name;
    private         long          _nameHashCode64;
    protected  List!SQLExpr arguments;
    private         bool       withTimeZone;
    private         bool       withLocalTimeZone = false;
    private         string        dbType;

    private         bool       unsigned;
    private         bool       zerofill;

    public this(){
        arguments = new ArrayList!SQLExpr();
    }

    public this(string name){
        this.name = name;
        arguments = new ArrayList!SQLExpr();
    }

    public this(string name, int precision) {
        this(name);
        // addArgument(new SQLIntegerExpr(precision));@gxc
    }

    public this(string name, SQLExpr arg) {
        this(name);
        addArgument(arg);
    }

    public this(string name, int precision, int scale) {
        this(name);
        // addArgument(new SQLIntegerExpr(precision)); @gxc
        // addArgument(new SQLIntegerExpr(scale)); @gxc
    }

    protected override void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild!SQLExpr(visitor, this.arguments);
        }

        visitor.endVisit(this);
    }

    public string getName() {
        return this.name;
    }

    public long nameHashCode64() @trusted nothrow {
        if (_nameHashCode64 == 0) {
            _nameHashCode64 = FnvHash.hashCode64(name);
        }
        return _nameHashCode64;
    }

    public void setName(string name) {
        this.name = name;
        _nameHashCode64 = 0L;
    }

    public List!SQLExpr getArguments() {
        return this.arguments;
    }
    
    public void addArgument(SQLExpr argument) {
        if (argument !is null) {
            argument.setParent(this);
        }
        this.arguments.add(argument);
    }

    override public  bool opEquals(Object o) {
        if (this == o) return true;
        // if (o is null || typeid(this) != typeid(o)) return false;

        SQLDataTypeImpl dataType = cast(SQLDataTypeImpl) o;

        if (name !is null ? !(name == dataType.name) : dataType.name !is null) return false;
        if (arguments !is null ? !(arguments == dataType.arguments) : dataType.arguments !is null) return false;
        return withTimeZone !is false ? withTimeZone == (dataType.withTimeZone) : dataType.withTimeZone == false;
    }

    override public  size_t toHash() @trusted nothrow {
        long value = nameHashCode64();
        return cast(size_t)(value ^ (value >>> 32));
    }

    public override bool getWithTimeZone() {
        return withTimeZone;
    }

    public void setWithTimeZone(bool withTimeZone) {
        this.withTimeZone = withTimeZone;
    }

    public bool isWithLocalTimeZone() {
        return withLocalTimeZone;
    }

    public void setWithLocalTimeZone(bool withLocalTimeZone) {
        this.withLocalTimeZone = withLocalTimeZone;
    }

    public string getDbType() {
        return dbType;
    }

    public void setDbType(string dbType) {
        this.dbType = dbType;
    }

    public  override SQLDataTypeImpl clone() {
        SQLDataTypeImpl x = new SQLDataTypeImpl();

        cloneTo(x);

        return x;
    }

    public void cloneTo(SQLDataTypeImpl x) {
        x.dbType = dbType;
        x.name = name;
        x._nameHashCode64 = _nameHashCode64;

        foreach(SQLExpr arg ; arguments) {
            x.addArgument(arg.clone());
        }

        x.withTimeZone = withTimeZone;
        x.withLocalTimeZone = withLocalTimeZone;
        x.zerofill = zerofill;
        x.unsigned = unsigned;
    }

    public override string toString() {
        return SQLUtils.toSQLString(this, dbType);
    }

    public bool isUnsigned() {
        return unsigned;
    }

    public void setUnsigned(bool unsigned) {
        this.unsigned = unsigned;
    }

    public bool isZerofill() {
        return zerofill;
    }

    public void setZerofill(bool zerofill) {
        this.zerofill = zerofill;
    }
}
