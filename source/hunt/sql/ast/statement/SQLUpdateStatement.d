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
module hunt.sql.ast.statement.SQLUpdateStatement;


import hunt.collection;

import hunt.sql.SQLUtils;
import hunt.sql.ast;
import hunt.sql.ast.expr.SQLBinaryOpExpr;
import hunt.sql.ast.expr.SQLBinaryOpExprGroup;
import hunt.sql.ast.expr.SQLBinaryOperator;
import hunt.sql.visitor.SQLASTOutputVisitor;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLExprTableSource;
import hunt.sql.ast.statement.SQLTableSource;
import hunt.sql.ast.statement.SQLWithSubqueryClause;
import hunt.sql.ast.statement.SQLUpdateSetItem;
import hunt.sql.ast.statement.SQLJoinTableSource;

public class SQLUpdateStatement : SQLStatementImpl , SQLReplaceable {
    protected SQLWithSubqueryClause _with; // for pg

    protected  List!SQLUpdateSetItem items;
    protected SQLExpr                      where;
    protected SQLTableSource               from;

    protected SQLTableSource               tableSource;
    protected List!SQLExpr                returning;

    protected List!SQLHint                hints;

    // for mysql
    protected SQLOrderBy orderBy;

    public this(){
        items = new ArrayList!SQLUpdateSetItem();
    }

    public this(string dbType){
        items = new ArrayList!SQLUpdateSetItem();
        super (dbType);
    }

    public SQLTableSource getTableSource() {
        return tableSource;
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
        if (cast(SQLExprTableSource)(tableSource) !is null ) {
            return (cast(SQLExprTableSource) tableSource).getName();
        }

        if (cast(SQLJoinTableSource)(tableSource) !is null ) {
            SQLTableSource left = (cast(SQLJoinTableSource) tableSource).getLeft();
            if (cast(SQLExprTableSource)(left) !is null ) {
                return (cast(SQLExprTableSource) left).getName();
            }
        }
        return null;
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

    public List!SQLUpdateSetItem getItems() {
        return items;
    }

    public void addItem(SQLUpdateSetItem item) {
        this.items.add(item);
        item.setParent(this);
    }

    public List!SQLExpr getReturning() {
        if (returning is null) {
            returning = new ArrayList!SQLExpr(2);
        }

        return returning;
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

    public int getHintsSize() {
        if (hints is null) {
            return 0;
        }

        return hints.size();
    }

    public List!SQLHint getHints() {
        if (hints is null) {
            hints = new ArrayList!SQLHint(2);
        }
        return hints;
    }

    public void setHints(List!SQLHint hints) {
        this.hints = hints;
    }

    override public void output(StringBuffer buf) {
        SQLASTOutputVisitor visitor = SQLUtils.createOutputVisitor(buf, dbType);
        this.accept(visitor);
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, tableSource);
            acceptChild(visitor, from);
            acceptChild!SQLUpdateSetItem(visitor, items);
            acceptChild(visitor, where);
            acceptChild(visitor, orderBy);
            acceptChild!SQLHint(visitor, hints);
        }
        visitor.endVisit(this);
    }

    override public List!SQLObject getChildren() {
        List!SQLObject children = new ArrayList!SQLObject();
        if (tableSource !is null) {
            children.add(tableSource);
        }
        if (from !is null) {
            children.add(from);
        }
        children.addAll(cast(List!SQLObject)(this.items));
        if (where !is null) {
            children.add(where);
        }
        if (orderBy !is null) {
            children.add(orderBy);
        }
        return children;
    }

    override
    public bool replace(SQLExpr expr, SQLExpr target) {
        if (where == expr) {
            setWhere(target);
            return true;
        }
        return false;
    }


    public SQLOrderBy getOrderBy() {
        return orderBy;
    }

    public void setOrderBy(SQLOrderBy orderBy) {
        if (orderBy !is null) {
            orderBy.setParent(this);
        }
        this.orderBy = orderBy;
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

    override
    public bool opEquals(Object o) {
        if (this == o) return true;
        if (o is null || typeid(this) != typeid(o)) return false;

        SQLUpdateStatement that = cast(SQLUpdateStatement) o;

        if (_with !is null ? !(cast(Object)(_with)).opEquals(cast(Object)(that._with)) : that._with !is null) return false;
        if (items !is null ? !(cast(Object)(items)).opEquals(cast(Object)(that.items)) : that.items !is null) return false;
        if (where !is null ? !(cast(Object)(where)).opEquals(cast(Object)(that.where)) : that.where !is null) return false;
        if (from !is null ? !(cast(Object)(from)).opEquals(cast(Object)(that.from)) : that.from !is null) return false;
        if (hints !is null ? !(cast(Object)(hints)).opEquals(cast(Object)(that.hints)) : that.hints !is null) return false;
        if (tableSource !is null ? !(cast(Object)(tableSource)).opEquals(cast(Object)(that.tableSource)) : that.tableSource !is null) return false;
        if (returning !is null ? !(cast(Object)(returning)).opEquals(cast(Object)(that.returning)) : that.returning !is null) return false;
        return orderBy !is null ? (cast(Object)(orderBy)).opEquals(cast(Object)(that.orderBy)) : that.orderBy is null;
    }

    override
    public size_t toHash() @trusted nothrow {
        size_t result = _with !is null ? (cast(Object)_with).toHash() : 0;
        result = 31 * result + (items !is null ? (cast(Object)items).toHash() : 0);
        result = 31 * result + (where !is null ? (cast(Object)where).toHash() : 0);
        result = 31 * result + (from !is null ? (cast(Object)from).toHash() : 0);
        result = 31 * result + (tableSource !is null ? (cast(Object)tableSource).toHash() : 0);
        result = 31 * result + (returning !is null ? (cast(Object)returning).toHash() : 0);
        result = 31 * result + (orderBy !is null ? (cast(Object)orderBy).toHash() : 0);
        result = 31 * result + (hints !is null ? (cast(Object)hints).toHash() : 0);
        return result;
    }

    public bool addWhere(SQLExpr where) {
        if (where is null) {
            return false;
        }

        this.addCondition(where);
        return true;
    }
}
