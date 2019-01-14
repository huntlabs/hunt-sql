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
module hunt.sql.ast.statement.SQLSelect;


import hunt.collection;

import hunt.sql.SQLUtils;
import hunt.sql.ast;
import hunt.sql.ast.expr.SQLAllColumnExpr;
//import hunt.sql.dialect.oracle.ast.OracleSQLObject; //@gxc
import hunt.sql.visitor.SQLASTOutputVisitor;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.util.DBType;
import hunt.sql.ast.statement.SQLWithSubqueryClause;
import hunt.sql.ast.statement.SQLSelectQuery;
import hunt.sql.ast.statement.SQLSelectQueryBlock;
import hunt.sql.ast.statement.SQLUnionQuery;

public class SQLSelect : SQLObjectImpl {

    protected SQLWithSubqueryClause withSubQuery;
    protected SQLSelectQuery        query;
    protected SQLOrderBy            orderBy;

    protected List!SQLHint         hints;

    protected SQLObject             restriction;

    protected bool               forBrowse;
    protected List!string          forXmlOptions = null;
    protected SQLExpr               xmlPath;

    protected SQLExpr                rowCount;
    protected SQLExpr                offset;

    public this(){

    }

    public List!SQLHint getHints() {
        if (hints is null) {
            hints = new ArrayList!SQLHint(2);
        }
        return hints;
    }
    
    public int getHintsSize() {
        if (hints is null) {
            return 0;
        }
        return hints.size();
    }

    public this(SQLSelectQuery query){
        this.setQuery(query);
    }

    public SQLWithSubqueryClause getWithSubQuery() {
        return withSubQuery;
    }

    public void setWithSubQuery(SQLWithSubqueryClause withSubQuery) {
        this.withSubQuery = withSubQuery;
    }

    public SQLSelectQuery getQuery() {
        return this.query;
    }

    public void setQuery(SQLSelectQuery query) {
        if (query !is null) {
            query.setParent(this);
        }
        this.query = query;
    }

    public SQLSelectQueryBlock getQueryBlock() {
        if (cast(SQLSelectQueryBlock)(query) !is null ) {
            return cast(SQLSelectQueryBlock) query;
        }

        return null;
    }

    public SQLOrderBy getOrderBy() {
        return this.orderBy;
    }

    public void setOrderBy(SQLOrderBy orderBy) {
        if (orderBy !is null) {
            orderBy.setParent(this);
        }
        this.orderBy = orderBy;
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, this.withSubQuery);
            acceptChild(visitor, this.query);
            acceptChild(visitor, this.restriction);
            acceptChild(visitor, this.orderBy);
            acceptChild!SQLHint(visitor, this.hints);
            acceptChild(visitor, this.offset);
            acceptChild(visitor, this.rowCount);
        }

        visitor.endVisit(this);
    }

    override
    public size_t toHash() @trusted nothrow {
         int prime = 31;
        size_t result = 1;
        result = prime * result + ((orderBy is null) ? 0 : (cast(Object)orderBy).toHash());
        result = prime * result + ((query is null) ? 0 : (cast(Object)query).toHash());
        result = prime * result + ((withSubQuery is null) ? 0 : (cast(Object)withSubQuery).toHash());
        return result;
    }

    override
    public bool opEquals(Object obj) {
        if (this == obj) return true;
        if (obj is null) return false;
        if (typeid(this) != typeid(obj)) return false;
        SQLSelect other = cast(SQLSelect) obj;
        if (orderBy is null) {
            if (other.orderBy !is null) return false;
        } else if (!(cast(Object)(orderBy)).opEquals(cast(Object)(other.orderBy))) return false;
        if (query is null) {
            if (other.query !is null) return false;
        } else if (!(cast(Object)(query)).opEquals(cast(Object)(other.query))) return false;
        if (withSubQuery is null) {
            if (other.withSubQuery !is null) return false;
        } else if (!(cast(Object)(withSubQuery)).opEquals(cast(Object)(other.withSubQuery))) return false;
        return true;
    }

    override public void output(StringBuffer buf) {
        string dbType = null;

        SQLObject parent = this.getParent();
        if (cast(SQLStatement)(parent) !is null ) {
            dbType = (cast(SQLStatement) parent).getDbType();
        }

        // if (dbType is null && (cast(OracleSQLObject)parent) !is null ) {
        //     dbType = DBType.ORACLE;
        // }    //@gxc

        if (dbType is null && (cast(SQLSelectQueryBlock)query) !is null ) {
            dbType = (cast(SQLSelectQueryBlock) query).dbType;
        }

        SQLASTOutputVisitor visitor = SQLUtils.createOutputVisitor(buf, dbType);
        this.accept(visitor);
    }

    override public string toString() {
        SQLObject parent = this.getParent();
        if (cast(SQLStatement)(parent) !is null ) {
            string dbType = (cast(SQLStatement) parent).getDbType();
            
            if (dbType !is null) {
                return SQLUtils.toSQLString(this, dbType);
            }
        }

        // if (cast(OracleSQLObject)(parent) !is null ) {
        //     return SQLUtils.toSQLString(this, DBType.ORACLE);
        // }    //@gxc

        if (cast(SQLSelectQueryBlock)(query) !is null ) {
            string dbType = (cast(SQLSelectQueryBlock) query).dbType;

            if (dbType !is null) {
                return SQLUtils.toSQLString(this, dbType);
            }
        }
        
        return super.toString();
    }

    override public SQLSelect clone() {
        SQLSelect x = new SQLSelect();

        x.withSubQuery = this.withSubQuery;
        if (query !is null) {
            x.setQuery(query.clone());
        }

        if (orderBy !is null) {
            x.setOrderBy(this.orderBy.clone());
        }
        if (restriction !is null) {
            x.setRestriction(restriction.clone());
        }

        if (this.hints !is null) {
            foreach (SQLHint hint ; this.hints) {
                x.hints.add(hint);
            }
        }

        x.forBrowse = forBrowse;

        if (forXmlOptions !is null) {
            x.forXmlOptions = (forXmlOptions);
        }

        if (xmlPath !is null) {
            x.setXmlPath(xmlPath.clone());
        }

        if (rowCount !is null) {
            x.setRowCount(rowCount.clone());
        }

        if (offset !is null) {
            x.setOffset(offset.clone());
        }

        return x;
    }

    public bool isSimple() {
        return withSubQuery is null
                && (hints is null || hints.size() == 0)
                && restriction is null
                && (!forBrowse)
                && (forXmlOptions is null || forXmlOptions.size() == 0)
                && xmlPath is null
                && rowCount is null
                && offset is null;
    }

    public SQLObject getRestriction() {
        return this.restriction;
    }

    public void setRestriction(SQLObject restriction) {
        if (restriction !is null) {
            restriction.setParent(this);
        }
        this.restriction = restriction;
    }

    public bool isForBrowse() {
        return forBrowse;
    }

    public void setForBrowse(bool forBrowse) {
        this.forBrowse = forBrowse;
    }

    public List!string getForXmlOptions() {
        if (forXmlOptions is null) {
            forXmlOptions = new ArrayList!string(4);
        }

        return forXmlOptions;
    }

    public int getForXmlOptionsSize() {
        if (forXmlOptions is null) {
            return 0;
        }
        return forXmlOptions.size();
    }

    public SQLExpr getRowCount() {
        return rowCount;
    }

    public void setRowCount(SQLExpr rowCount) {
        if (rowCount !is null) {
            rowCount.setParent(this);
        }

        this.rowCount = rowCount;
    }

    public SQLExpr getOffset() {
        return offset;
    }

    public void setOffset(SQLExpr offset) {
        if (offset !is null) {
            offset.setParent(this);
        }
        this.offset = offset;
    }

    public SQLExpr getXmlPath() {
        return xmlPath;
    }

    public void setXmlPath(SQLExpr xmlPath) {
        if (xmlPath !is null) {
            xmlPath.setParent(this);
        }
        this.xmlPath = xmlPath;
    }

    public SQLSelectQueryBlock getFirstQueryBlock() {
        if (cast(SQLSelectQueryBlock)(query) !is null ) {
            return cast(SQLSelectQueryBlock) query;
        }

        if (cast(SQLUnionQuery)(query) !is null ) {
            return (cast(SQLUnionQuery) query).getFirstQueryBlock();
        }

        return null;
    }

    public bool addWhere(SQLExpr where) {
        if (where is null) {
            return false;
        }

        if (cast(SQLSelectQueryBlock)(query) !is null ) {
            (cast(SQLSelectQueryBlock) query).addWhere(where);
            return true;
        }

        if (cast(SQLUnionQuery)(query) !is null ) {
            SQLSelectQueryBlock queryBlock = new SQLSelectQueryBlock();
            queryBlock.setFrom(new SQLSelect(query), "u");
            queryBlock.addSelectItem(new SQLAllColumnExpr());
            queryBlock.setParent(queryBlock);
            query = queryBlock;
            return true;
        }

        return false;
    }
}
