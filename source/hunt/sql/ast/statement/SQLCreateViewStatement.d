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
module hunt.sql.ast.statement.SQLCreateViewStatement;


import hunt.collection;

import hunt.sql.SQLUtils;
import hunt.sql.ast;
import hunt.sql.ast.expr.SQLCharExpr;
import hunt.sql.ast.expr.SQLIdentifierExpr;
import hunt.sql.ast.expr.SQLLiteralExpr;
import hunt.sql.ast.expr.SQLPropertyExpr;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLTableElement;
import hunt.sql.ast.statement.SQLExprTableSource;
import hunt.sql.ast.statement.SQLSelect;
import hunt.sql.ast.statement.SQLCreateStatement;

public class SQLCreateViewStatement : SQLStatementImpl , SQLCreateStatement {

    private bool     orReplace   = false;
    private bool     force       = false;
    // protected SQLName   name;
    protected SQLSelect subQuery;
    protected bool   ifNotExists = false;

    protected string    algorithm;
    protected SQLName   definer;
    protected string    sqlSecurity;

    protected SQLExprTableSource tableSource;

    protected  List!SQLTableElement columns;

    private bool withCheckOption;
    private bool withCascaded;
    private bool withLocal;
    private bool withReadOnly;

    private SQLLiteralExpr comment;

    public this(){
        columns = new ArrayList!SQLTableElement();
    }

    public this(string dbType){
        columns = new ArrayList!SQLTableElement();
        super(dbType);
    }

    public string computeName() {
        if (tableSource is null) {
            return null;
        }

        SQLExpr expr = tableSource.getExpr();
        if (cast(SQLName)(expr) !is null ) {
            string name = (cast(SQLName) expr).getSimpleName();
            return SQLUtils.normalize(name);
        }

        return null;
    }

    public string getSchema() {
        SQLName name = getName();
        if (name is null) {
            return null;
        }

        if (cast(SQLPropertyExpr)(name) !is null ) {
            return (cast(SQLPropertyExpr) name).getOwnernName();
        }

        return null;
    }

    public bool isOrReplace() {
        return orReplace;
    }

    public void setOrReplace(bool orReplace) {
        this.orReplace = orReplace;
    }

    public SQLName getName() {
        if (tableSource is null) {
            return null;
        }

        return cast(SQLName) tableSource.getExpr();
    }

    public void setName(SQLName name) {
        this.setTableSource(new SQLExprTableSource(name));
    }

    public void setName(string name) {
        this.setName(new SQLIdentifierExpr(name));
    }

    public SQLExprTableSource getTableSource() {
        return tableSource;
    }

    public void setTableSource(SQLExprTableSource tableSource) {
        if (tableSource !is null) {
            tableSource.setParent(this);
        }
        this.tableSource = tableSource;
    }

    public bool isWithCheckOption() {
        return withCheckOption;
    }

    public void setWithCheckOption(bool withCheckOption) {
        this.withCheckOption = withCheckOption;
    }

    public bool isWithCascaded() {
        return withCascaded;
    }

    public void setWithCascaded(bool withCascaded) {
        this.withCascaded = withCascaded;
    }

    public bool isWithLocal() {
        return withLocal;
    }

    public void setWithLocal(bool withLocal) {
        this.withLocal = withLocal;
    }

    public bool isWithReadOnly() {
        return withReadOnly;
    }

    public void setWithReadOnly(bool withReadOnly) {
        this.withReadOnly = withReadOnly;
    }

    public SQLSelect getSubQuery() {
        return subQuery;
    }

    public void setSubQuery(SQLSelect subQuery) {
        if (subQuery !is null) {
            subQuery.setParent(this);
        }
        this.subQuery = subQuery;
    }

    public List!SQLTableElement getColumns() {
        return columns;
    }
    
    public void addColumn(SQLTableElement column) {
        if (column !is null) {
            column.setParent(this);
        }
        this.columns.add(column);
    }

    public bool isIfNotExists() {
        return ifNotExists;
    }

    public void setIfNotExists(bool ifNotExists) {
        this.ifNotExists = ifNotExists;
    }

    public SQLLiteralExpr getComment() {
        return comment;
    }

    public void setComment(SQLLiteralExpr comment) {
        if (comment !is null) {
            comment.setParent(this);
        }
        this.comment = comment;
    }

    public string getAlgorithm() {
        return algorithm;
    }

    public void setAlgorithm(string algorithm) {
        this.algorithm = algorithm;
    }

    public SQLName getDefiner() {
        return definer;
    }

    public void setDefiner(SQLName definer) {
        if (definer !is null) {
            definer.setParent(this);
        }
        this.definer = definer;
    }

    public string getSqlSecurity() {
        return sqlSecurity;
    }

    public void setSqlSecurity(string sqlSecurity) {
        this.sqlSecurity = sqlSecurity;
    }

    public bool isForce() {
        return force;
    }

    public void setForce(bool force) {
        this.force = force;
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, this.tableSource);
            acceptChild!SQLTableElement(visitor, this.columns);
            acceptChild(visitor, this.comment);
            acceptChild(visitor, this.subQuery);
        }
        visitor.endVisit(this);
    }

    override public List!SQLObject getChildren() {
        List!SQLObject children = new ArrayList!SQLObject();
        if (tableSource !is null) {
            children.add(tableSource);
        }
        children.addAll(cast(List!SQLObject)(this.columns));
        if (comment !is null) {
            children.add(comment);
        }
        if (subQuery !is null) {
            children.add(subQuery);
        }
        return children;
    }

    public static enum Level {
                              CASCADED, LOCAL
    }

    public static class Column : SQLObjectImpl {

        private SQLExpr     expr;
        private SQLCharExpr comment;

        public SQLExpr getExpr() {
            return expr;
        }

        public void setExpr(SQLExpr expr) {
            if (expr !is null) {
                expr.setParent(this);
            }
            this.expr = expr;
        }

        public SQLCharExpr getComment() {
            return comment;
        }

        public void setComment(SQLCharExpr comment) {
            if (comment !is null) {
                comment.setParent(this);
            }
            this.comment = comment;
        }

        
        override  protected void accept0(SQLASTVisitor visitor) {
            if (visitor.visit(this)) {
                acceptChild(visitor, expr);
                acceptChild(visitor, comment);
            }
        }
    }


    override public SQLCreateViewStatement clone() {
        SQLCreateViewStatement x = new SQLCreateViewStatement();

        x.orReplace = orReplace;
        x.force = force;
        if (subQuery !is null) {
            x.setSubQuery(subQuery.clone());
        }
        x.ifNotExists = ifNotExists;

        x.algorithm = algorithm;
        if (definer !is null) {
            x.setDefiner(definer.clone());
        }
        x.sqlSecurity = sqlSecurity;
        if (tableSource !is null) {
            x.setTableSource(tableSource.clone());
        }
        foreach (SQLTableElement column ; columns) {
            SQLTableElement column2 = column.clone();
            column2.setParent(x);
            x.columns.add(column2);
        }
        x.withCheckOption = withCheckOption;
        x.withCascaded = withCascaded;
        x.withLocal = withLocal;
        x.withReadOnly = withReadOnly;

        if (comment !is null) {
            x.setComment(comment.clone());
        }

        return x;
    }
}
