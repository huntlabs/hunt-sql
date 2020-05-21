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
module hunt.sql.ast.expr.SQLIdentifierExpr;

import hunt.sql.SQLUtils;
import hunt.sql.ast;
import hunt.sql.ast.statement;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.util.FnvHash;
import hunt.collection;
import hunt.sql.ast.expr.SQLPropertyExpr;
import std.uni;
import hunt.String;
import hunt.text;
import hunt.util.StringBuilder;

public  class SQLIdentifierExpr : SQLExprImpl , SQLName {
    public  string    name;
    private   long      _hashCode64;

    private   SQLObject resolvedColumn;
    private   SQLObject resolvedOwnerObject;

    public this(){

    }

    public this(string name){
        this.name = name;
    }

    public this(string name, long hash_lower){
        this.name = name;
        this._hashCode64 = hash_lower;
    }

    public string getSimpleName() {
        return name;
    }

    public string getLowerName() {
        if (name is null) {
            return null;
        }

        return toLower(name);
    }

    public string getName() {
        return this.name;
    }

    public void setName(string name) {
        this.name = name;
        this._hashCode64 = 0L;

        if (cast(SQLPropertyExpr)parent !is null) {
            SQLPropertyExpr propertyExpr = cast(SQLPropertyExpr) parent;
            propertyExpr.computeHashCode64();
        }
    }

    public long nameHashCode64() {
        return hashCode64();
    }

   override
    public long hashCode64() {
        if (_hashCode64 == 0
                && name !is null) {
            _hashCode64 = FnvHash.hashCode64(name);
        }
        return _hashCode64;
    }

    override public void output(StringBuilder buf) {
        buf.append(this.name);
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        visitor.visit(this);

        visitor.endVisit(this);
    }

   override
    public size_t toHash() @trusted nothrow {
        long value ;
        try
        {
            value = hashCode64();
        }
        catch(Exception)
        {
        }
        return cast(size_t)(value ^ (value >>> 32));
    }

   override
    public bool opEquals(Object obj) {
        // if (!(cast(SQLIdentifierExpr)(obj) !is null)) {
        //     return false;
        // }

        SQLIdentifierExpr other = cast(SQLIdentifierExpr) obj;
        if(other is null)
            return false;
        return this.hashCode64() == other.hashCode64();
    }

    override public string toString() {
        return this.name;
    }

    override public SQLIdentifierExpr clone() {
        SQLIdentifierExpr x = new SQLIdentifierExpr(this.name, _hashCode64);
        x.resolvedColumn = resolvedColumn;
        x.resolvedOwnerObject = resolvedOwnerObject;
        return x;
    }

    public SQLIdentifierExpr simplify() {
        string normalized = SQLUtils.normalize(name);
        if (normalized != name) {
           return new SQLIdentifierExpr(normalized, _hashCode64);
        }
        return this;
    }

    public string normalizedName() {
        return SQLUtils.normalize(name);
    }

    public SQLColumnDefinition getResolvedColumn() {
        if ( cast(SQLColumnDefinition)resolvedColumn !is null) {
            return cast(SQLColumnDefinition) resolvedColumn;
        }

        return null;
    }

    public SQLObject getResolvedColumnObject() {
        return resolvedColumn;
    }

    public void setResolvedColumn(SQLColumnDefinition resolvedColumn) {
        this.resolvedColumn = resolvedColumn;
    }

    public SQLTableSource getResolvedTableSource() {
        if (cast(SQLTableSource)resolvedOwnerObject !is null) {
            return cast(SQLTableSource) resolvedOwnerObject;
        }

        return null;
    }

    public void setResolvedTableSource(SQLTableSource resolvedTableSource) {
        this.resolvedOwnerObject = resolvedTableSource;
    }

    public SQLObject getResolvedOwnerObject() {
        return resolvedOwnerObject;
    }

    public void setResolvedOwnerObject(SQLObject resolvedOwnerObject) {
        this.resolvedOwnerObject = resolvedOwnerObject;
    }

    public SQLParameter getResolvedParameter() {
        if (cast(SQLParameter)resolvedColumn !is null) {
            return cast(SQLParameter) this.resolvedColumn;
        }
        return null;
    }

    public void setResolvedParameter(SQLParameter resolvedParameter) {
        this.resolvedColumn = resolvedParameter;
    }

    public SQLDeclareItem getResolvedDeclareItem() {
        if ( cast(SQLDeclareItem)resolvedColumn !is null) {
            return cast(SQLDeclareItem) this.resolvedColumn;
        }
        return null;
    }

    public void setResolvedDeclareItem(SQLDeclareItem resolvedDeclareItem) {
        this.resolvedColumn = resolvedDeclareItem;
    }

    override public SQLDataType computeDataType() {
        SQLColumnDefinition resolvedColumn = getResolvedColumn();
        if (resolvedColumn !is null) {
            return resolvedColumn.getDataType();
        }

        if (resolvedOwnerObject !is null
                &&  (cast(SQLSubqueryTableSource)resolvedOwnerObject !is null)) {
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

   override
    public List!SQLObject getChildren() {
        return Collections.emptyList!(SQLObject)();
    }

    public static bool matchIgnoreCase(SQLExpr expr, string name) {
        // if (!(cast(SQLIdentifierExpr)(expr) !is null)) {
        //     return false;
        // }
        SQLIdentifierExpr ident = cast(SQLIdentifierExpr) expr;
        if(ident is null)
            return false;
        return equalsIgnoreCase(name,ident.getName());
    }
}
