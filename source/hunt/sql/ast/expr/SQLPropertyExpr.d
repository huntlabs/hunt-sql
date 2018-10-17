module hunt.sql.ast.expr.SQLPropertyExpr;
import hunt.sql.ast.SQLExprImpl;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLObject;
import hunt.sql.ast.statement.SQLColumnDefinition;
import hunt.container;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLTableSource;
import hunt.sql.ast.statement.SQLCreateProcedureStatement;
import hunt.sql.ast.SQLDataType;
import hunt.sql.ast.statement.SQLSelectItem;
import hunt.sql.ast.statement.SQLSelect;
import hunt.sql.ast.statement.SQLSelectQueryBlock;
import hunt.sql.ast.expr.SQLIdentifierExpr;
import hunt.sql.util.FnvHash;
import hunt.string;
import hunt.sql.SQLUtils;
import hunt.sql.ast.statement.SQLSubqueryTableSource;

public  class SQLPropertyExpr : SQLExprImpl , SQLName {
    private   SQLExpr             owner;
    private   string              name;

    protected long                nameHashCod64;
    protected long                _hashCode64;

    protected SQLColumnDefinition resolvedColumn;
    protected SQLObject           resolvedOwnerObject;

    public this(string owner, string name){
        this(new SQLIdentifierExpr(owner), name);
    }

    public this(SQLExpr owner, string name){
        setOwner(owner);
        this.name = name;
    }

    public this(SQLExpr owner, string name, long nameHashCod64){
        setOwner(owner);
        this.name = name;
        this.nameHashCod64 = nameHashCod64;
    }

    public this(){

    }

    public string getSimpleName() {
        return name;
    }

    public SQLExpr getOwner() {
        return this.owner;
    }

    public string getOwnernName() {
        if ( cast(SQLName)owner !is null) {
            return (cast(Object) owner).toString();
        }

        return null;
    }

    public void setOwner(SQLExpr owner) {
        if (owner !is null) {
            owner.setParent(this);
        }

        if ( cast(SQLPropertyExpr)parent !is null) {
            SQLPropertyExpr propertyExpr = cast(SQLPropertyExpr) parent;
            propertyExpr.computeHashCode64();
        }

        this.owner = owner;
        this._hashCode64 = 0;
    }

    public  void computeHashCode64() {
        long hash;
        if ( cast(SQLName)owner !is null) {
            hash = (cast(SQLName) owner).hashCode64();

            hash ^= '.';
            hash *= FnvHash.PRIME;
        } else if (owner is null){
            hash = FnvHash.BASIC;
        } else {
            hash = FnvHash.fnv1a_64_lower((cast(Object)owner).toString());

            hash ^= '.';
            hash *= FnvHash.PRIME;
        }
        hash = FnvHash.hashCode64(hash, name);
        _hashCode64 = hash;
    }

    public void setOwner(string owner) {
        this.setOwner(new SQLIdentifierExpr(owner));
    }

    public string getName() {
        return this.name;
    }

    public void setName(string name) {
        this.name = name;
        this._hashCode64 = 0;
        this.nameHashCod64 = 0;

        SQLPropertyExpr propertyExpr = cast(SQLPropertyExpr) parent;
        if (propertyExpr !is null) {
            propertyExpr.computeHashCode64();
        }
    }

    override public void output(StringBuffer buf) {
        this.owner.output(buf);
        buf.append(".");
        buf.append(this.name);
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, this.owner);
        }

        visitor.endVisit(this);
    }

   override
    public List!SQLObject getChildren() {
        return Collections.singletonList!SQLObject(this.owner);
    }

   override
    public size_t toHash() @trusted nothrow {
        long hash;
        try{
              hash= hashCode64();
        }catch(Exception){}
       
        return cast(size_t)(hash ^ (hash >>> 32));
    }

    public long hashCode64() {
        if (_hashCode64 == 0) {
            computeHashCode64();
        }

        return _hashCode64;
    }

   override
    public bool opEquals(Object obj) {
        if (this is obj) {
            return true;
        }
        if (obj is null) {
            return false;
        }
        // if (!(cast(SQLPropertyExpr)(obj) !is null)) {
        //     return false;
        // }
        SQLPropertyExpr other = cast(SQLPropertyExpr) obj;
        if(other is null)
            return false;

        if (name is null) {
            if (other.name !is null) {
                return false;
            }
        } else if (name != (other.name)) {
            return false;
        }
        if (owner is null) {
            if (other.owner !is null) {
                return false;
            }
        } else if (owner != (other.owner)) {
            return false;
        }
        return true;
    }
    
    //  override bool opEquals(Object o) {
    //     if (o is this)
    //         return true;
            
    //     return opEquals(o);
    // }

    // override size_t toHash() @trusted nothrow {
    //     return hashCode();
    // }

    override public SQLPropertyExpr clone() {
        SQLExpr owner_x = null;
        if (owner !is null) {
            owner_x = owner.clone();
        }

        SQLPropertyExpr x = new SQLPropertyExpr(owner_x, name, nameHashCod64);

        x._hashCode64 = _hashCode64;
        x.resolvedColumn = resolvedColumn;
        x.resolvedOwnerObject = resolvedOwnerObject;

        return x;
    }

    public bool matchOwner(string alias_p) {
        auto obj = cast(SQLIdentifierExpr) owner;
        if (obj !is null) {
            return equalsIgnoreCase(obj.getName(),alias_p);
        }

        return false;
    }

    public long nameHashCode64() {
        if (nameHashCod64 == 0
                && name !is null) {
            nameHashCod64 = FnvHash.hashCode64(name);
        }
        return nameHashCod64;
    }

    public string normalizedName() {

        string ownerName;
        if ( cast(SQLIdentifierExpr)owner !is null) {
            ownerName = (cast(SQLIdentifierExpr) owner).normalizedName();
        } else if ( cast(SQLPropertyExpr)owner !is null) {
            ownerName = (cast(SQLPropertyExpr) owner).normalizedName();
        } else {
            ownerName = (cast(Object)owner).toString();
        }

        return ownerName ~ '.' ~ SQLUtils.normalize(name);
    }

    public SQLColumnDefinition getResolvedColumn() {
        return resolvedColumn;
    }

    public void setResolvedColumn(SQLColumnDefinition resolvedColumn) {
        this.resolvedColumn = resolvedColumn;
    }

    public SQLTableSource getResolvedTableSource() {
        if ( cast(SQLTableSource)resolvedOwnerObject !is null) {
            return cast(SQLTableSource) resolvedOwnerObject;
        }

        return null;
    }

    public void setResolvedTableSource(SQLTableSource resolvedTableSource) {
        this.resolvedOwnerObject = resolvedTableSource;
    }

    public void setResolvedProcedure(SQLCreateProcedureStatement stmt) {
        this.resolvedOwnerObject = stmt;
    }

    public void setResolvedOwnerObject(SQLObject resolvedOwnerObject) {
        this.resolvedOwnerObject = resolvedOwnerObject;
    }

    public SQLCreateProcedureStatement getResolvedProcudure() {
        // if (cast(SQLCreateProcedureStatement)(this.resolvedOwnerObject) !is null) {
        //     return (SQLCreateProcedureStatement) this.resolvedOwnerObject;
        // }

        return cast(SQLCreateProcedureStatement) this.resolvedOwnerObject;
    }

    public SQLObject getResolvedOwnerObject() {
        return resolvedOwnerObject;
    }

    override public SQLDataType computeDataType() {
        if (resolvedColumn !is null) {
            return resolvedColumn.getDataType();
        }

        if (resolvedOwnerObject !is null
                &&  cast(SQLSubqueryTableSource)resolvedOwnerObject !is null) {
            SQLSelect select = (cast(SQLSubqueryTableSource) resolvedOwnerObject).getSelect();
            SQLSelectQueryBlock queryBlock = select.getFirstQueryBlock();
            if (queryBlock is null) {
                return null;
            }
            SQLSelectItem selectItem = queryBlock.findSelectItem(nameHashCode64());
            if (selectItem !is null) {
                return selectItem.computeDataType();
            }
        }

        return null;
    }

    public bool nameEquals(string name) {
        return SQLUtils.nameEquals(this.name, name);
    }

    public SQLPropertyExpr simplify() {
        string normalizedName = SQLUtils.normalize(name);
        SQLExpr normalizedOwner = this.owner;
        if ( cast(SQLIdentifierExpr)normalizedOwner !is null) {
            normalizedOwner = (cast(SQLIdentifierExpr) normalizedOwner).simplify();
        }

        if (normalizedName != name || normalizedOwner != owner) {
            return new SQLPropertyExpr(normalizedOwner, normalizedName, _hashCode64);
        }

        return this;
    }

    override public string toString() {
        if (owner is null) {
            return this.name;
        }

        return (cast(Object)owner).toString() ~ '.' ~ name;
    }
}
