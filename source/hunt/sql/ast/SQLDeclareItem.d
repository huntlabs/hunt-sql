module hunt.sql.ast.SQLDeclareItem;

import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.ast.SQLObjectWithDataType;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLDataType;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLObject;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLTableElement;

import hunt.container;




public class SQLDeclareItem : SQLObjectImpl , SQLObjectWithDataType {

    protected Type                  type;

    protected SQLName               name;

    protected SQLDataType           dataType;

    protected SQLExpr               value;

    protected List!SQLTableElement tableElementList ;

    protected SQLObject             resolvedObject;

    public this() {
        tableElementList = new ArrayList!SQLTableElement();
    }

    public this(SQLName name, SQLDataType dataType) {
        this();
        this.setName(name);
        this.setDataType(dataType);
    }

    public this(SQLName name, SQLDataType dataType, SQLExpr value) {
        this();
        this.setName(name);
        this.setDataType(dataType);
        this.setValue(value);
    }

    protected override void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, this.name);
            acceptChild(visitor, this.dataType);
            acceptChild(visitor, this.value);
            acceptChild!SQLTableElement(visitor, this.tableElementList);
        }
        visitor.endVisit(this);
    }

    public SQLName getName() {
        return name;
    }

    public void setName(SQLName name) {
        if (name !is null) {
            name.setParent(this);
        }
        this.name = name;
    }

    public SQLDataType getDataType() {
        return dataType;
    }

    public void setDataType(SQLDataType dataType) {
        if (dataType !is null) {
            dataType.setParent(this);
        }
        this.dataType = dataType;
    }

    public SQLExpr getValue() {
        return value;
    }

    public void setValue(SQLExpr value) {
        if (value !is null) {
            value.setParent(this);
        }
        this.value = value;
    }

    public List!SQLTableElement getTableElementList() {
        return tableElementList;
    }

    public void setTableElementList(List!SQLTableElement tableElementList) {
        this.tableElementList = tableElementList;
    }

    public enum Type {
        TABLE, LOCAL, CURSOR
    }

    public Type getType() {
        return type;
    }

    public void setType(Type type) {
        this.type = type;
    }

    public SQLObject getResolvedObject() {
        return resolvedObject;
    }

    public void setResolvedObject(SQLObject resolvedObject) {
        this.resolvedObject = resolvedObject;
    }
}
