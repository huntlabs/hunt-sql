/*
 * Copyright 2015-2018 HuntLabs.cn
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance _with the License.
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
module hunt.sql.ast.statement.SQLDeleteStatement;

import hunt.sql.SQLUtils;
import hunt.sql.ast;
import hunt.sql.ast.expr.SQLBinaryOpExpr;
import hunt.sql.ast.expr.SQLBinaryOpExprGroup;
import hunt.sql.ast.expr.SQLBinaryOperator;
import hunt.sql.ast.expr.SQLIdentifierExpr;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLWithSubqueryClause;
import hunt.sql.ast.statement.SQLExprTableSource;
import hunt.sql.ast.statement.SQLTableSource;
import hunt.sql.ast.statement.SQLSelectQueryBlock;
import hunt.sql.ast.statement.SQLSubqueryTableSource;
import hunt.sql.ast.statement.SQLSelectQuery;

import hunt.container;

public class SQLDeleteStatement : SQLStatementImpl , SQLReplaceable {
    protected SQLWithSubqueryClause  _with;

    protected SQLTableSource tableSource;
    protected SQLExpr        where;
    protected SQLTableSource from;
    protected SQLTableSource using;

    protected bool        only      = false;

    public this(){

    }
    
    public this(string dbType){
        super (dbType);
    }

    protected void cloneTo(SQLDeleteStatement x) {
        if (headHints !is null) {
            foreach (SQLCommentHint h ; headHints) {
                SQLCommentHint h2 = h.clone();
                h2.setParent(x);
                x.headHints.add(h2);
            }
        }

        if (_with !is null) {
            x.setWith(_with.clone());
        }

        if (tableSource !is null) {
            x.setTableSource(tableSource.clone());
        }
        if (where !is null) {
            x.setWhere(where.clone());
        }
        if (from !is null) {
            x.setFrom(from.clone());
        }
        if (using !is null) {
            x.setUsing(using.clone());
        }
        x.only = only;
    }

    override public SQLDeleteStatement clone() {
        SQLDeleteStatement x = new SQLDeleteStatement();
        cloneTo(x);
        return x;
    }

    public SQLTableSource getTableSource() {
        return tableSource;
    }

    public SQLExprTableSource getExprTableSource() {
        return cast(SQLExprTableSource) getTableSource();
    }

    public void setTableSource(SQLExpr expr) {
        this.setTableSource(new SQLExprTableSource(expr));
    }

    public void setTableSource(SQLTableSource tableSource) {
        if (tableSource !is null) {
            tableSource.setParent(this);
        }
        this.tableSource = tableSource;
    }

    public SQLName getTableName() {
        if (cast(SQLExprTableSource)(this.tableSource) !is null ) {
            SQLExprTableSource exprTableSource = cast(SQLExprTableSource) this.tableSource;
            return cast(SQLName) exprTableSource.getExpr();
        }

        if (cast(SQLSubqueryTableSource)(tableSource) !is null ) {
            SQLSelectQuery selectQuery = (cast(SQLSubqueryTableSource) tableSource).getSelect().getQuery();
            if (cast(SQLSelectQueryBlock)(selectQuery) !is null ) {
                SQLTableSource subQueryTableSource = (cast(SQLSelectQueryBlock) selectQuery).getFrom();
                if (cast(SQLExprTableSource)(subQueryTableSource) !is null ) {
                    SQLExpr subQueryTableSourceExpr = (cast(SQLExprTableSource) subQueryTableSource).getExpr();
                    return cast(SQLName) subQueryTableSourceExpr;
                }
            }
        }

        return null;
    }

    public void setTableName(SQLName tableName) {
        this.setTableSource(new SQLExprTableSource(tableName));
    }

    public void setTableName(string name) {
        setTableName(new SQLIdentifierExpr(name));
    }

    public SQLExpr getWhere() {
        return where;
    }

    public void setWhere(SQLExpr where) {
        if (where !is null) {
            where.setParent(this);
        }
        this.where = where;
    }

    public string getAlias() {
        return this.tableSource.getAlias();
    }

    public void setAlias(string alias_p) {
        this.tableSource.setAlias(alias_p);
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, _with);
            acceptChild(visitor, tableSource);
            acceptChild(visitor, where);
        }

        visitor.endVisit(this);
    }

    override
    public List!SQLObject getChildren() {
        List!SQLObject children = new ArrayList!SQLObject();
        if (_with !is null) {
            children.add(_with);
        }
        children.add(tableSource);
        if (where !is null) {
            children.add(where);
        }
        return children;
    }

    public SQLTableSource getFrom() {
        return from;
    }

    public void setFrom(SQLTableSource from) {
        if (from !is null) {
            from.setParent(this);
        }
        this.from = from;
    }

    override
    public bool replace(SQLExpr expr, SQLExpr target) {
        if (where == expr) {
            setWhere(target);
            return true;
        }
        return false;
    }

    public bool isOnly() {
        return only;
    }

    public void setOnly(bool only) {
        this.only = only;
    }

    public SQLTableSource getUsing() {
        return using;
    }

    public void setUsing(SQLTableSource using) {
        this.using = using;
    }

    public SQLWithSubqueryClause getWith() {
        return _with;
    }

    public void setWith(SQLWithSubqueryClause _with) {
        if (_with !is null) {
            _with.setParent(this);
        }
        this._with = _with;
    }

    public void addCondition(string conditionSql) {
        if (conditionSql is null || conditionSql.length == 0) {
            return;
        }

        SQLExpr condition = SQLUtils.toSQLExpr(conditionSql, dbType);
        addCondition(condition);
    }

    public void addCondition(SQLExpr expr) {
        if (expr is null) {
            return;
        }

        this.setWhere(SQLBinaryOpExpr.and(where, expr));
    }

    public bool removeCondition(string conditionSql) {
        if (conditionSql is null || conditionSql.length == 0) {
            return false;
        }

        SQLExpr condition = SQLUtils.toSQLExpr(conditionSql, dbType);

        return removeCondition(condition);
    }

    public bool removeCondition(SQLExpr condition) {
        if (condition is null) {
            return false;
        }

        if (cast(SQLBinaryOpExprGroup)(where) !is null ) {
            SQLBinaryOpExprGroup group = cast(SQLBinaryOpExprGroup) where;

            int removedCount = 0;
            List!SQLExpr items = group.getItems();
            for (int i = items.size() - 1; i >= 0; i--) {
                if ((cast(Object)(items.get(i))).opEquals(cast(Object)(condition))) {
                    items.removeAt(i);
                    removedCount++;
                }
            }
            if (items.size() == 0) {
                where = null;
            }

            return removedCount > 0;
        }

        if (cast(SQLBinaryOpExpr)(where) !is null ) {
            SQLBinaryOpExpr binaryOpWhere = cast(SQLBinaryOpExpr) where;
            SQLBinaryOperator operator = binaryOpWhere.getOperator();
            if (operator == SQLBinaryOperator.BooleanAnd || operator == SQLBinaryOperator.BooleanOr) {
                List!SQLExpr items = SQLBinaryOpExpr.split(binaryOpWhere);

                int removedCount = 0;
                for (int i = items.size() - 1; i >= 0; i--) {
                    SQLExpr item = items.get(i);
                    if ((cast(Object)(item)).opEquals(cast(Object)(condition))) {
                        if (SQLUtils.replaceInParent(item, null)) {
                            removedCount++;
                        }
                    }
                }

                return removedCount > 0;
            }
        }

        if ((cast(Object)(condition)).opEquals(cast(Object)(where))) {
            where = null;
            return true;
        }

        return false;
    }

    public bool addWhere(SQLExpr where) {
        if (where is null) {
            return false;
        }

        this.addCondition(where);
        return true;
    }
}
