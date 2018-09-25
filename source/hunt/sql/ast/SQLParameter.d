module hunt.sql.ast.SQLParameter;

import hunt.sql.visitor.SQLASTVisitor;

import hunt.container;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLDataType;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.ast.SQLObjectWithDataType;



public  class SQLParameter : SQLObjectImpl , SQLObjectWithDataType {
    private SQLName                  name;
    private SQLDataType              dataType;
    private SQLExpr                  defaultValue;
    private ParameterType            paramType;
    private bool                  noCopy = false;
    private bool                  constant = false;
    private SQLName                  cursorName;
    private List!SQLParameter cursorParameters ;
    private bool                  order;
    private bool                  map;
    private bool                  member;

    this()
    {
        cursorParameters = new ArrayList!SQLParameter();
    }
    public SQLExpr getDefaultValue() {
        return defaultValue;
    }

    public void setDefaultValue(SQLExpr deaultValue) {
        if (deaultValue !is null) {
            deaultValue.setParent(this);
        }
        this.defaultValue = deaultValue;
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
    
    public ParameterType getParamType() {
        return paramType;
    }

    public void setParamType(ParameterType paramType) {
        this.paramType = paramType;
    }

    public override void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, name);
            acceptChild(visitor, dataType);
            acceptChild(visitor, defaultValue);
        }
        visitor.endVisit(this);
    }
    
    public static struct ParameterType {
        enum ParameterType DEFAULT = ParameterType("DEFAULT"); //
        enum ParameterType IN = ParameterType("IN"); // in
        enum ParameterType OUT = ParameterType("OUT"); // out_p
        enum ParameterType INOUT = ParameterType("INOUT");// inout

        private string _name;

        this(string name)
        {
            _name = name;
        }

        @property string name()
        {
            return _name;
        }

        bool opEquals(const ParameterType h) nothrow {
            return _name == h._name ;
        } 

        bool opEquals(ref const ParameterType h) nothrow {
            return _name == h._name ;
        } 
    }

    public bool isNoCopy() {
        return noCopy;
    }

    public void setNoCopy(bool noCopy) {
        this.noCopy = noCopy;
    }

    public bool isConstant() {
        return constant;
    }

    public void setConstant(bool constant) {
        this.constant = constant;
    }

    public List!SQLParameter getCursorParameters() {
        return cursorParameters;
    }

    public SQLName getCursorName() {
        return cursorName;
    }

    public void setCursorName(SQLName cursorName) {
        if (cursorName !is null) {
            cursorName.setParent(this);
        }
        this.cursorName = cursorName;
    }

    public override SQLParameter clone() {
        SQLParameter x = new SQLParameter();
        if (name !is null) {
            x.setName(name.clone());
        }
        if (dataType !is null) {
            x.setDataType(dataType.clone());
        }
        if (defaultValue !is null) {
            x.setDefaultValue(defaultValue.clone());
        }
        x.paramType = paramType;
        x.noCopy = noCopy;
        x.constant = constant;
        x.order = order;
        x.map = map;
        if (cursorName !is null) {
            x.setCursorName(cursorName.clone());
        }
        foreach(SQLParameter p ; cursorParameters) {
            SQLParameter p2 = p.clone();
            p2.setParent(x);
            x.cursorParameters.add(p2);
        }
        return x;
    }

    public bool isOrder() {
        return order;
    }

    public void setOrder(bool order) {
        this.order = order;
    }

    public bool isMap() {
        return map;
    }

    public void setMap(bool map) {
        this.map = map;
    }

    public bool isMember() {
        return member;
    }

    public void setMember(bool member) {
        this.member = member;
    }
}
