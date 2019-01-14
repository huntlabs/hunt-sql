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
module hunt.sql.ast.statement.SQLSelectItem;

import hunt.sql.SQLUtils;
import hunt.sql.ast;
import hunt.sql.ast.expr.SQLAllColumnExpr;
import hunt.sql.ast.expr.SQLIdentifierExpr;
import hunt.sql.ast.expr.SQLPropertyExpr;
// import hunt.sql.dialect.oracle.ast.OracleSQLObject;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.util.FnvHash;
import hunt.sql.util.DBType;
import hunt.collection;
import hunt.sql.ast.statement.SQLTableSource;

public class SQLSelectItem : SQLObjectImpl , SQLReplaceable {

    protected SQLExpr expr;
    protected string  _alias;

    protected bool connectByRoot = false;

    protected long aliasHashCode64;

    public this(){

    }

    public this(SQLExpr expr){
        this(expr, null);
    }

    public this(SQLExpr expr, string alias_p){
        this.expr = expr;
        this._alias = alias_p;

        if (expr !is null) {
            expr.setParent(this);
        }
    }
    
    public this(SQLExpr expr, string alias_p, bool connectByRoot){
        this.connectByRoot = connectByRoot;
        this.expr = expr;
        this._alias = alias_p;
        
        if (expr !is null) {
            expr.setParent(this);
        }
    }

    public SQLExpr getExpr() {
        return this.expr;
    }

    public void setExpr(SQLExpr expr) {
        if (expr !is null) {
            expr.setParent(this);
        }
        this.expr = expr;
    }

    public string computeAlias() {
        string alias_p = this.getAlias();
        if (alias_p is null) {
            if (cast(SQLIdentifierExpr)(expr) !is null ) {
                alias_p = (cast(SQLIdentifierExpr) expr).getName();
            } else if (cast(SQLPropertyExpr)(expr) !is null ) {
                alias_p = (cast(SQLPropertyExpr) expr).getName();
            }
        }

        return SQLUtils.normalize(alias_p);
    }

    override public SQLDataType computeDataType() {
        if (expr is null) {
            return null;
        }

        return expr.computeDataType();
    }

    public string getAlias() {
        return this._alias;
    }

    public void setAlias(string alias_p) {
        this._alias = alias_p;
    }

    override public void output(StringBuffer buf) {
        if(this.connectByRoot) {
            buf.append(" CONNECT_BY_ROOT ");
        }
        this.expr.output(buf);
        if ((this._alias !is null) && (this._alias.length != 0)) {
            buf.append(" AS ");
            buf.append(this._alias);
        }
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, this.expr);
        }
        visitor.endVisit(this);
    }

    override
    public size_t toHash() @trusted nothrow {
         int prime = 31;
        size_t result = 1;
        result = prime * result + hashOf(_alias);
        result = prime * result + ((expr is null) ? 0 : (cast(Object)expr).toHash());
        return result;
    }

    override
    public bool opEquals(Object obj) {
        if (this == obj) return true;
        if (obj is null) return false;
        if (typeid(this) != typeid(obj)) return false;
        SQLSelectItem other = cast(SQLSelectItem) obj;
        if (_alias is null) {
            if (other._alias !is null) return false;
        } else if (!(_alias == other._alias)) return false;
        if (expr is null) {
            if (other.expr !is null) return false;
        } else if (!(cast(Object)(expr)).opEquals(cast(Object)(other.expr))) return false;
        return true;
    }

    public bool isConnectByRoot() {
        return connectByRoot;
    }

    public void setConnectByRoot(bool connectByRoot) {
        this.connectByRoot = connectByRoot;
    }

    override public SQLSelectItem clone() {
        SQLSelectItem x = new SQLSelectItem();
        x._alias = _alias;
        if (expr !is null) {
            x.setExpr(expr.clone());
        }
        x.connectByRoot = connectByRoot;
        return x;
    }

    override
    public bool replace(SQLExpr expr, SQLExpr target) {
        if (this.expr == expr) {
            setExpr(target);
            return true;
        }

        return false;
    }

    public bool match(string alias_p) {
        if (alias_p is null) {
            return false;
        }

        long hash = FnvHash.hashCode64(alias_p);
        return match(hash);
    }

    public long alias_hash() {
        if (this.aliasHashCode64 == 0) {
            this.aliasHashCode64 = FnvHash.hashCode64(_alias);
        }
        return aliasHashCode64;
    }

    public bool match(long _alias_hash) {
        long hash = alias_hash();

        if (hash == _alias_hash) {
            return true;
        }

        if (cast(SQLAllColumnExpr)(expr) !is null ) {
            SQLTableSource resolvedTableSource = (cast(SQLAllColumnExpr) expr).getResolvedTableSource();
            if (resolvedTableSource !is null
                    && resolvedTableSource.findColumn(_alias_hash) !is null) {
                return true;
            }
            return false;
        }

        if (cast(SQLIdentifierExpr)(expr) !is null ) {
            return (cast(SQLIdentifierExpr) expr).nameHashCode64() == _alias_hash;
        }

        if (cast(SQLPropertyExpr)(expr) !is null ) {
            string ident = (cast(SQLPropertyExpr) expr).getName();
            if ("*" == (ident)) {
                SQLTableSource resolvedTableSource = (cast(SQLPropertyExpr) expr).getResolvedTableSource();
                if (resolvedTableSource !is null
                        && resolvedTableSource.findColumn(_alias_hash) !is null) {
                    return true;
                }
                return false;
            }

            return (cast(SQLPropertyExpr) expr).nameHashCode64() == _alias_hash;
        }

        return false;
    }

    override public string toString() {
        string dbType = null;
        // if (cast(OracleSQLObject)(parent) !is null ) {
        //     dbType = DBType.ORACLE;
        // }
        return SQLUtils.toSQLString(this, dbType);
    }
}
