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
module hunt.sql.ast.statement.SQLExprTableSource;


import hunt.container;

import hunt.sql.SQLUtils;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLReplaceable;
import hunt.sql.ast.SQLStatement;
import hunt.sql.ast.expr.SQLIdentifierExpr;
import hunt.sql.ast.expr.SQLPropertyExpr;
import hunt.sql.repository.SchemaObject;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.util.FnvHash;
import hunt.sql.ast.statement.SQLColumnDefinition;
import hunt.sql.ast.statement.SQLTableSourceImpl;
import hunt.sql.ast.statement.SQLTableSource;
import hunt.sql.ast.statement.SQLCreateTableStatement;


public class SQLExprTableSource : SQLTableSourceImpl , SQLReplaceable {

    public SQLExpr     expr;
    private List!SQLName partitions;
    private SchemaObject  schemaObject;

    public this(){

    }

    public this(SQLExpr expr){
        this(expr, null);
    }

    public this(SQLExpr expr, string alias_P){
        this.setExpr(expr);
        this.setAlias(alias_P);
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

    public void setExpr(string name) {
        this.setExpr(new SQLIdentifierExpr(name));
    }

    public SQLName getName() {
        if (cast(SQLName)(expr) !is null ) {
            return cast(SQLName) expr;
        }
        return null;
    }

    public string getSchema() {
        if (expr is null) {
            return null;
        }

        if (cast(SQLPropertyExpr)(expr) !is null ) {
            return (cast(SQLPropertyExpr) expr).getOwnernName();
        }

        return null;
    }

    public void setSchema(string schema) {
        if (cast(SQLIdentifierExpr)(expr) !is null ) {
            if (schema is null) {
                return;
            }

            string ident = (cast(SQLIdentifierExpr) expr).getName();
            this.setExpr(new SQLPropertyExpr(schema, ident));
        } else if (cast(SQLPropertyExpr)(expr) !is null ) {
            SQLPropertyExpr propertyExpr = cast(SQLPropertyExpr) expr;
            if (schema is null) {
                setExpr(new SQLIdentifierExpr(propertyExpr.getName()));
            } else {
                propertyExpr.setOwner(schema);
            }
        }
    }

    public List!SQLName getPartitions() {
        if (this.partitions is null) {
            this.partitions = new ArrayList!SQLName(2);
        }
        
        return partitions;
    }
    
    public int getPartitionSize() {
        if (this.partitions is null) {
            return 0;
        }
        return this.partitions.size();
    }

    public void addPartition(SQLName partition) {
        if (partition !is null) {
            partition.setParent(this);
        }
        
        if (this.partitions is null) {
            this.partitions = new ArrayList!SQLName(2);
        }
        this.partitions.add(partition);
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, this.expr);
        }
        visitor.endVisit(this);
    }

    override public void output(StringBuffer buf) {
        this.expr.output(buf);
    }

    override
    public bool opEquals(Object o) {
        if (this == o) return true;
        if (o is null || typeid(this) != typeid(o)) return false;

        SQLExprTableSource that = cast(SQLExprTableSource) o;

        if (expr !is null ? !(cast(Object)(expr)).opEquals(cast(Object)(that.expr)) : that.expr !is null) return false;
        return partitions !is null ? (cast(Object)(partitions)).opEquals(cast(Object)(that.partitions)) : that.partitions is null;
    }

    override
    public size_t toHash() @trusted nothrow {
        size_t result = expr !is null ? (cast(Object)expr).toHash() : 0;
        result = 31 * result + (partitions !is null ? (cast(Object)partitions).toHash() : 0);
        return result;
    }

    override public string computeAlias() {
        string alias_p = this.getAlias();

        if (alias_p is null) {
            if (cast(SQLName)(expr) !is null ) {
                alias_p =(cast(SQLName) expr).getSimpleName();
            }
        }

        return SQLUtils.normalize(alias_p);
    }

    override public SQLExprTableSource clone() {
        SQLExprTableSource x = new SQLExprTableSource();
        cloneTo(x);
        return x;
    }

    public void cloneTo(SQLExprTableSource x) {
        x._alias = _alias;

        if (expr !is null) {
            x.expr = expr.clone();
        }

        if (partitions !is null) {
            foreach (SQLName p ; partitions) {
                SQLName p1 = p.clone();
                x.addPartition(p1);
            }
        }
    }

    public SchemaObject getSchemaObject() {
        return schemaObject;
    }

    public void setSchemaObject(SchemaObject schemaObject) {
        this.schemaObject = schemaObject;
    }

    override public bool containsAlias(string alias_p) {
        long hashCode64 = FnvHash.hashCode64(alias_p);

        return containsAlias(hashCode64);
    }

    public bool containsAlias(long aliasHash) {
        if (this.aliasHashCode64() == aliasHash) {
            return true;
        }

        if (cast(SQLPropertyExpr)(expr) !is null ) {
            long exprNameHash = (cast(SQLPropertyExpr) expr).hashCode64();
            if (exprNameHash == aliasHash) {
                return true;
            }
        }

        if (cast(SQLName)(expr) !is null ) {
            long exprNameHash = (cast(SQLName) expr).nameHashCode64();
            return exprNameHash == aliasHash;
        }

        return false;
    }

    override public SQLColumnDefinition findColumn(string columnName) {
        if (columnName is null) {
            return null;
        }

        long hash = FnvHash.hashCode64(columnName);
        return findColumn(hash);
    }

    override public SQLColumnDefinition findColumn(long columnNameHash) {
        if (schemaObject is null) {
            return null;
        }

        SQLStatement stmt = schemaObject.getStatement();
        if (cast(SQLCreateTableStatement)(stmt) !is null ) {
            SQLCreateTableStatement createTableStmt = cast(SQLCreateTableStatement) stmt;
            return createTableStmt.findColumn(columnNameHash);
        }
        return null;
    }

    override public SQLTableSource findTableSourceWithColumn(string columnName) {
        if (columnName is null) {
            return null;
        }

        long hash = FnvHash.hashCode64(columnName);
        return findTableSourceWithColumn(hash);
    }

    override public SQLTableSource findTableSourceWithColumn(long columnName_hash) {
        if (schemaObject !is null) {
            SQLStatement stmt = schemaObject.getStatement();
            if (cast(SQLCreateTableStatement)(stmt) !is null ) {
                SQLCreateTableStatement createTableStmt = cast(SQLCreateTableStatement) stmt;
                if (createTableStmt.findColumn(columnName_hash) !is null) {
                    return this;
                }
            }
        }

        if (cast(SQLIdentifierExpr)(expr) !is null ) {
            SQLTableSource tableSource = (cast(SQLIdentifierExpr) expr).getResolvedTableSource();
            if (tableSource !is null) {
                return tableSource.findTableSourceWithColumn(columnName_hash);
            }
        }

        return null;
    }

    override public SQLTableSource findTableSource(long alias_hash) {
        if (alias_hash == 0) {
            return null;
        }

        if (aliasHashCode64() == alias_hash) {
            return this;
        }

        if (cast(SQLName)(expr) !is null ) {
            long exprNameHash = (cast(SQLName) expr).nameHashCode64();
            if (exprNameHash == alias_hash) {
                return this;
            }
        }

        if (cast(SQLPropertyExpr)(expr) !is null ) {
            long hash = (cast(SQLPropertyExpr) expr).hashCode64();
            if (hash == alias_hash) {
                return this;
            }
        }

        return null;
    }

    override
    public bool replace(SQLExpr expr, SQLExpr target) {
        if (expr == this.expr) {
            this.setExpr(target);
            return true;
        }
        return false;
    }
}
