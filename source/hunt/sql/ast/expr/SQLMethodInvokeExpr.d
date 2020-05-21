/*
 * Copyright 2015-2018 HuntLabs.cn
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
module hunt.sql.ast.expr.SQLMethodInvokeExpr;



import hunt.sql.SQLUtils;
import hunt.sql.ast;
// import hunt.sql.dialect.oracle.visitor.OracleASTVisitor;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.util.FnvHash;
import hunt.collection;
import hunt.sql.ast.expr.SQLIdentifierExpr;
import hunt.sql.ast.expr.SQLDateExpr;
import hunt.util.StringBuilder;

public class SQLMethodInvokeExpr : SQLExprImpl , SQLReplaceable//, Serializable 
{

    private static  long   serialVersionUID = 1L;
    private string              name;
    private SQLExpr             owner;
    private List!SQLExpr parameters;

    private SQLExpr             from;
    private SQLExpr             using;
    private SQLExpr             _for;

    private string              trimOption;

    private long                nameHashCode64;

    public this(){
        parameters       = new ArrayList!SQLExpr();
    }

    public this(string methodName){
        this();
        this.name = methodName;
    }

    public this(string methodName, long nameHashCode64){
        this();
        this.name = methodName;
        this.nameHashCode64 = nameHashCode64;
    }

    public this(string methodName, SQLExpr owner){
        this();
        this.name = methodName;
        setOwner(owner);
    }

    public this(string methodName, SQLExpr owner, SQLExpr[] params...){
        this();
        this.name = methodName;
        setOwner(owner);
        foreach (SQLExpr param ; params) {
            this.addParameter(param);
        }
    }

    public long methodNameHashCode64() {
        if (nameHashCode64 == 0
                && name !is null) {
            nameHashCode64 = FnvHash.hashCode64(name);
        }
        return nameHashCode64;
    }

    public string getMethodName() {
        return this.name;
    }

    public void setMethodName(string methodName) {
        this.name = methodName;
        this.nameHashCode64 = 0L;
    }

    public SQLExpr getOwner() {
        return this.owner;
    }

    public void setOwner(SQLExpr owner) {
        if (owner !is null) {
            owner.setParent(this);
        }
        this.owner = owner;
    }

    public SQLExpr getFrom() {
        return from;
    }

    public void setFrom(SQLExpr x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.from = x;
    }

    public List!SQLExpr getParameters() {
        return this.parameters;
    }
    
    public void addParameter(SQLExpr param) {
        if (param !is null) {
            param.setParent(this);
        }
        this.parameters.add(param);
    }

    public void addArgument(SQLExpr arg) {
        if (arg !is null) {
            arg.setParent(this);
        }
        this.parameters.add(arg);
    }

    override public void output(StringBuilder buf) {
        if (this.owner !is null) {
            this.owner.output(buf);
            buf.append(".");
        }

        buf.append(this.name);
        buf.append("(");
        for (int i = 0, size = this.parameters.size(); i < size; ++i) {
            if (i != 0) {
                buf.append(", ");
            }

            this.parameters.get(i).output(buf);
        }
        buf.append(")");
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, this.owner);
            acceptChild!SQLExpr(visitor, this.parameters);
            acceptChild(visitor, this.from);
            acceptChild(visitor, this.using);
            acceptChild(visitor, this._for);
        }

        visitor.endVisit(this);
    }

    override public List!SQLObject getChildren() {
        if (this.owner is null) {
            return cast(List!SQLObject)this.parameters;
        }

        List!SQLObject children = new ArrayList!SQLObject();
        children.add(owner);
        children.addAll(cast(List!SQLObject)(this.parameters));
        return children;
    }

    // protected void accept0(OracleASTVisitor visitor) {
    //     if (visitor.visit(this)) {
    //         acceptChild(visitor, this.owner);
    //         acceptChild(visitor, this.parameters);
    //         acceptChild(visitor, this.from);
    //         acceptChild(visitor, this.using);
    //         acceptChild(visitor, this._for);
    //     }

    //     visitor.endVisit(this);
    // }

   override
    public bool opEquals(Object o) {
        if (this == o) return true;
        if (o is null || typeid(this) != typeid(o)) return false;

        SQLMethodInvokeExpr that = cast(SQLMethodInvokeExpr) o;

        if (name !is null ? !(name == that.name) : that.name !is null) return false;
        if (owner !is null ? !(cast(Object)(owner)).opEquals(cast(Object)(that.owner)) : that.owner !is null) return false;
        if (parameters !is null ? !(cast(Object)(parameters)).opEquals(cast(Object)(that.parameters)) : that.parameters !is null) return false;
        return from !is null ? (cast(Object)(from)).opEquals(cast(Object)(that.from)) : that.from is null;

    }

   override
    public size_t toHash() @trusted nothrow {
        size_t result = name !is null ? hashOf(name) : 0;
        result = 31 * result + (owner !is null ? (cast(Object)owner).toHash() : 0);
        result = 31 * result + (parameters !is null ? (cast(Object)parameters).toHash() : 0);
        result = 31 * result + (from !is null ? (cast(Object)from).toHash() : 0);
        return result;
    }

    override public SQLMethodInvokeExpr clone() {
        SQLMethodInvokeExpr x = new SQLMethodInvokeExpr();

        x.name = name;

        if (owner !is null) {
            x.setOwner(owner.clone());
        }

        foreach (SQLExpr param ; parameters) {
            x.addParameter(param.clone());
        }

        if (from !is null) {
            x.setFrom(from.clone());
        }

        if (using !is null) {
            x.setUsing(using.clone());
        }

        return x;
    }

   override
    public bool replace(SQLExpr expr, SQLExpr target) {
        if (target is null) {
            return false;
        }

        for (int i = 0; i < parameters.size(); ++i) {
            if (parameters.get(i) == expr) {
                parameters.set(i, target);
                target.setParent(this);
                return true;
            }
        }

        if (from == expr) {
            setFrom(target);
            return true;
        }

        if (using == expr) {
            setUsing(target);
            return true;
        }

        if (_for == expr) {
            setFor(target);
            return true;
        }

        return false;
    }

    public bool match(string owner, string function_p) {
        if (function_p is null) {
            return false;
        }

        if (!SQLUtils.nameEquals(function_p, name)) {
            return false;
        }

        if (owner is null && this.owner is null) {
            return true;
        }

        if (owner is null || this.owner is null) {
            return false;
        }
        auto obj = cast(SQLIdentifierExpr) this.owner;
        if (obj !is null) {
            return SQLUtils.nameEquals(obj.name, owner);
        }

        return false;
    }

    override public SQLDataType  computeDataType() {
        if (SQLUtils.nameEquals("to_date", name)
                || SQLUtils.nameEquals("add_months", name)) {
            return SQLDateExpr.DEFAULT_DATA_TYPE;
        }

        if (parameters.size() == 1) {
            if (SQLUtils.nameEquals("trunc", name)) {
                return parameters.get(0).computeDataType();
            }
        } else if (parameters.size() == 2) {
            SQLExpr param0 = parameters.get(0);
            SQLExpr param1 = parameters.get(1);
            if (SQLUtils.nameEquals("nvl", name) || SQLUtils.nameEquals("ifnull", name)) {
                SQLDataType dataType = param0.computeDataType();
                if (dataType !is null) {
                    return dataType;
                }

                return param1.computeDataType();
            }
        }
        return null;
    }

    public SQLExpr getUsing() {
        return using;
    }

    public void setUsing(SQLExpr x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.using = x;
    }

    public SQLExpr getFor() {
        return _for;
    }

    public void setFor(SQLExpr x) {
        if (x !is null) {
            x.setParent(this);
        }
        this._for = x;
    }

    public string getTrimOption() {
        return trimOption;
    }

    public void setTrimOption(string trimOption) {
        this.trimOption = trimOption;
    }
}
