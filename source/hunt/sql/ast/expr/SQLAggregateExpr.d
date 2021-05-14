module hunt.sql.ast.expr.SQLAggregateExpr;

import hunt.sql.ast;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.expr.SQLAggregateOption;
import hunt.sql.util.FnvHash;
import hunt.sql.SQLUtils;
import hunt.sql.ast.expr.SQLIntegerExpr;
import hunt.sql.ast.expr.SQLCharExpr;

import hunt.collection;


public class SQLAggregateExpr : SQLExprImpl , SQLReplaceable {

    protected string              methodName;
    protected long                _methodNameHashCod64;

    protected SQLAggregateOption  option;
    protected List!SQLExpr arguments;
    protected SQLKeep             keep;
    protected SQLExpr             filter;
    protected SQLOver             over;
    protected SQLName             overRef;
    protected SQLOrderBy          withinGroup;
    protected bool             ignoreNulls      = false;

    this()
    {
        arguments        = new ArrayList!SQLExpr();
    }

    public this(string methodName){
        this();
        this.methodName = methodName;
    }

    public this(string methodName, SQLAggregateOption option){
        this();
        this.methodName = methodName;
        this.option = option;
    }

    public string getMethodName() {
        return this.methodName;
    }

    public void setMethodName(string methodName) {
        this.methodName = methodName;
    }

    public long methodNameHashCod64() {
        if (_methodNameHashCod64 == 0) {
            _methodNameHashCod64 = FnvHash.hashCode64(methodName);
        }
        return _methodNameHashCod64;
    }

    public SQLOrderBy getWithinGroup() {
        return withinGroup;
    }

    public void setWithinGroup(SQLOrderBy withinGroup) {
        if (withinGroup !is null) {
            withinGroup.setParent(this);
        }

        this.withinGroup = withinGroup;
    }

    public SQLAggregateOption getOption() {
        return this.option;
    }

    public void setOption(SQLAggregateOption option) {
        this.option = option;
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

    public SQLOver getOver() {
        return over;
    }

    public void setOver(SQLOver over) {
        if (over !is null) {
            over.setParent(this);
        }
        this.over = over;
    }

    public SQLName getOverRef() {
        return overRef;
    }

    public void setOverRef(SQLName x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.overRef = x;
    }
    
    public SQLKeep getKeep() {
        return keep;
    }

    public void setKeep(SQLKeep keep) {
        if (keep !is null) {
            keep.setParent(this);
        }
        this.keep = keep;
    }
    
    public bool isIgnoreNulls() {
        return /*this.ignoreNulls !is null && */this.ignoreNulls;
    }

    public bool getIgnoreNulls() {
        return this.ignoreNulls;
    }

    public void setIgnoreNulls(bool ignoreNulls) {
        this.ignoreNulls = ignoreNulls;
    }

    public override string toString() {
        return SQLUtils.toSQLString(this);
    }


    protected override void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild!SQLExpr(visitor, this.arguments);
            acceptChild(visitor, this.keep);
            acceptChild(visitor, this.over);
            acceptChild(visitor, this.overRef);
            acceptChild(visitor, this.withinGroup);
        }

        visitor.endVisit(this);
    }

    public override List!SQLObject getChildren() {
        List!SQLObject children = new ArrayList!SQLObject();
        children.addAll(cast(List!SQLObject)(this.arguments));
        if (keep !is null) {
            children.add(this.keep);
        }
        if (over !is null) {
            children.add(over);
        }
        if (withinGroup !is null) {
            children.add(withinGroup);
        }
        return children;
    }

    public override bool opEquals(Object o) {
        if (this == o) return true;
        if (o is null || typeid(SQLAggregateExpr) != typeid(o)) return false;

        SQLAggregateExpr that = cast(SQLAggregateExpr) o;

        if (_methodNameHashCod64 != that._methodNameHashCod64) return false;
        if (methodName !is null ? !(methodName == that.methodName) : that.methodName !is null) return false;
        if (option != that.option) return false;
        if (arguments !is null ? !(cast(Object)arguments).opEquals(cast(Object)(that.arguments)) : that.arguments !is null) return false;
        if (keep !is null ? !(cast(Object)(keep)).opEquals(cast(Object)(that.keep)) : that.keep !is null) return false;
        if (filter !is null ? !(cast(Object)filter).opEquals(cast(Object)(that.filter)) : that.filter !is null) return false;
        if (over !is null ? !(cast(Object)(over)).opEquals(cast(Object)(that.over)) : that.over !is null) return false;
        if (overRef !is null ? !(cast(Object)overRef).opEquals(cast(Object)(that.overRef)) : that.overRef !is null) return false;
        if (withinGroup !is null ? !(cast(Object)(withinGroup)).opEquals(cast(Object)(that.withinGroup)) : that.withinGroup !is null) return false;
        return ignoreNulls == that.ignoreNulls;
    }

    public override size_t toHash() @trusted nothrow {
        size_t result = methodName !is null ? hashOf(methodName) : 0;
        result = 31 * result + cast(int) (_methodNameHashCod64 ^ (_methodNameHashCod64 >>> 32));
        result = 31 * result + hashOf(option);
        result = 31 * result + (arguments !is null ? (cast(Object)arguments).toHash() : 0);
        result = 31 * result + (keep !is null ? (cast(Object)keep).toHash() : 0);
        result = 31 * result + (filter !is null ? (cast(Object)filter).toHash() : 0);
        result = 31 * result + (over !is null ? (cast(Object)over).toHash() : 0);
        result = 31 * result + (overRef !is null ? (cast(Object)overRef).toHash() : 0);
        result = 31 * result + (withinGroup !is null ? (cast(Object)withinGroup).toHash() : 0);
        result = 31 * result + hashOf(ignoreNulls);
        return result;
    }

    public override SQLAggregateExpr clone() {
        SQLAggregateExpr x = new SQLAggregateExpr(methodName);

        x.option = option;

        foreach (SQLExpr arg ; arguments) {
            x.addArgument(arg.clone());
        }

        if (keep !is null) {
            x.setKeep(keep.clone());
        }

        if (filter !is null) {
            x.setFilter(filter.clone());
        }

        if (over !is null) {
            x.setOver(over.clone());
        }

        if (overRef !is null) {
            x.setOverRef(overRef.clone());
        }

        if (withinGroup !is null) {
            x.setWithinGroup(withinGroup.clone());
        }

        x.ignoreNulls = ignoreNulls;

        return x;
    }

    public SQLExpr getFilter() {
        return filter;
    }

    public void setFilter(SQLExpr x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.filter = x;
    }

    public override SQLDataType computeDataType() {
        long hash = methodNameHashCod64();

        if (hash == FnvHash.Constants.COUNT
                || hash == FnvHash.Constants.ROW_NUMBER) {
            return SQLIntegerExpr.DEFAULT_DATA_TYPE;
        }

        if (arguments.size() > 0) {
            SQLDataType dataType = arguments.get(0).computeDataType();
            if (dataType !is null) {
                return dataType;
            }
        }

        if (hash == FnvHash.Constants.WM_CONCAT
                || hash == FnvHash.Constants.GROUP_CONCAT) {
            return SQLCharExpr.DEFAULT_DATA_TYPE;
        }

        return null;
    }

    public bool replace(SQLExpr expr, SQLExpr target) {
        if (target is null) {
            return false;
        }

        for (int i = 0; i < arguments.size(); ++i) {
            if (arguments.get(i) == expr) {
                arguments.set(i, target);
                target.setParent(this);
                return true;
            }
        }

        if (overRef == expr) {
            setOverRef(cast(SQLName) target);
            return true;
        }

        if (filter == expr) {
            this.filter = target;
            target.setParent(this);
        }

        return false;
    }
}
