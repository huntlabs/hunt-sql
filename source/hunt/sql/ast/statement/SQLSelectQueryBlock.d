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
module hunt.sql.ast.statement.SQLSelectQueryBlock;

import hunt.sql.ast.statement.SQLSelectGroupByClause;

import hunt.collection;

import hunt.sql.SQLUtils;
import hunt.sql.ast;
import hunt.sql.ast.expr;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.util.FnvHash;
import hunt.sql.ast.statement.SQLSelectItem;
import hunt.sql.ast.statement.SQLSelectOrderByItem;
import hunt.sql.ast.statement.SQLExprTableSource;
import hunt.sql.ast.statement.SQLSelect;
import hunt.sql.ast.statement.SQLSelectQuery;
import hunt.sql.ast.statement.SQLTableSource;
import hunt.sql.ast.statement.SQLColumnDefinition;
import hunt.sql.ast.statement.SQLSubqueryTableSource;

public class SQLSelectQueryBlock : SQLObjectImpl , SQLSelectQuery, SQLReplaceable {
    private bool                      bracket         = false;
    protected int                        distionOption;
    protected  List!SQLSelectItem  selectList;

    protected SQLTableSource             from;
    protected SQLExprTableSource         into;
    protected SQLExpr                    where;

    // for oracle & oceanbase
    protected SQLExpr                    startWith;
    protected SQLExpr                    connectBy;
    protected bool                    prior           = false;
    protected bool                    noCycle         = false;
    protected SQLOrderBy                 orderBySiblings;

    protected SQLSelectGroupByClause     groupBy;
    protected List!SQLWindow            windows;
    protected SQLOrderBy                 orderBy;
    protected bool                    parenthesized   = false;
    protected bool                    forUpdate       = false;
    protected bool                    noWait          = false;
    protected SQLExpr                    waitTime;
    protected SQLLimit                   _limit;

    // for oracle
    protected List!SQLExpr              forUpdateOf;
    protected List!SQLExpr              distributeBy;
    protected List!SQLSelectOrderByItem sortBy;

    protected string                     cachedSelectList; // optimized for SelectListCache
    protected long                       cachedSelectListHash; // optimized for SelectListCache

    protected List!SQLCommentHint       hints;
    public  string                     dbType;

    public this(){
        selectList      = new ArrayList!SQLSelectItem();
    }

    public SQLExprTableSource getInto() {
        return into;
    }

    public void setInto(SQLExpr into) {
        this.setInto(new SQLExprTableSource(into));
    }

    public void setInto(SQLExprTableSource into) {
        if (into !is null) {
            into.setParent(this);
        }
        this.into = into;
    }

    public SQLSelectGroupByClause getGroupBy() {
        return this.groupBy;
    }

    public void setGroupBy(SQLSelectGroupByClause groupBy) {
        if (groupBy !is null) {
            groupBy.setParent(this);
        }
        this.groupBy = groupBy;
    }

    public SQLExpr getWhere() {
        return this.where;
    }

    public void setWhere(SQLExpr where) {
        if (where !is null) {
            where.setParent(this);
        }
        this.where = where;
    }

    public void addWhere(SQLExpr condition) {
        if (condition is null) {
            return;
        }

        if (where is null) {
            where = condition;
        } else {
            where = SQLBinaryOpExpr.and(where, condition);
        }
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

    public SQLOrderBy getOrderBySiblings() {
        return orderBySiblings;
    }

    public void setOrderBySiblings(SQLOrderBy orderBySiblings) {
        if (orderBySiblings !is null) {
            orderBySiblings.setParent(this);
        }
        this.orderBySiblings = orderBySiblings;
    }

    public int getDistionOption() {
        return this.distionOption;
    }

    public void setDistionOption(int distionOption) {
        this.distionOption = distionOption;
    }

    public List!SQLSelectItem getSelectList() {
        return this.selectList;
    }
    
    public void addSelectItem(SQLSelectItem item) {
        this.selectList.add(item);
        item.setParent(this);
    }

    public void addSelectItem(SQLExpr expr) {
        this.addSelectItem(new SQLSelectItem(expr));
    }

    public void addSelectItem(SQLExpr expr, string alias_p) {
        this.addSelectItem(new SQLSelectItem(expr, alias_p));
    }

    public SQLTableSource getFrom() {
        return this.from;
    }

    public void setFrom(SQLTableSource from) {
        if (from !is null) {
            from.setParent(this);
        }
        this.from = from;
    }

    public void setFrom(SQLSelectQueryBlock queryBlock, string alias_p) {
        if (queryBlock is null) {
            this.from = null;
            return;
        }

        this.setFrom(new SQLSelect(queryBlock), alias_p);
    }

    public void setFrom(SQLSelect select, string alias_p) {
        if (select is null) {
            this.from = null;
            return;
        }

        SQLSubqueryTableSource from = new SQLSubqueryTableSource(select);
        from.setAlias(alias_p);
        this.setFrom(from);
    }

    public void setFrom(string tableName, string alias_p) {
        SQLExprTableSource from;
        if (tableName is null || tableName.length == 0) {
            from = null;
        } else {
            from = new SQLExprTableSource(new SQLIdentifierExpr(tableName), alias_p);
        }
        this.setFrom(from);
    }

    public bool isParenthesized() {
		return parenthesized;
	}

	public void setParenthesized(bool parenthesized) {
		this.parenthesized = parenthesized;
	}
	
    public bool isForUpdate() {
        return forUpdate;
    }

    public void setForUpdate(bool forUpdate) {
        this.forUpdate = forUpdate;
    }
    
    public bool isNoWait() {
        return noWait;
    }

    public void setNoWait(bool noWait) {
        this.noWait = noWait;
    }
    
    public SQLExpr getWaitTime() {
        return waitTime;
    }
    
    public void setWaitTime(SQLExpr waitTime) {
        if (waitTime !is null) {
            waitTime.setParent(this);
        }
        this.waitTime = waitTime;
    }

    public SQLLimit getLimit() {
        return _limit;
    }

    public void setLimit(SQLLimit _limit) {
        if (_limit !is null) {
            _limit.setParent(this);
        }
        this._limit = _limit;
    }

    public SQLExpr getFirst() {
        if (_limit is null) {
            return null;
        }

        return _limit.getRowCount();
    }

    public void setFirst(SQLExpr first) {
        if (_limit is null) {
            _limit = new SQLLimit();
        }
        this._limit.setRowCount(first);
    }

    public SQLExpr getOffset() {
        if (_limit is null) {
            return null;
        }

        return _limit.getOffset();
    }

    public void setOffset(SQLExpr offset) {
        if (_limit is null) {
            _limit = new SQLLimit();
        }
        this._limit.setOffset(offset);
    }

    public bool isPrior() {
        return prior;
    }

    public void setPrior(bool prior) {
        this.prior = prior;
    }

    public SQLExpr getStartWith() {
        return this.startWith;
    }

    public void setStartWith(SQLExpr startWith) {
        if (startWith !is null) {
            startWith.setParent(this);
        }
        this.startWith = startWith;
    }

    public SQLExpr getConnectBy() {
        return this.connectBy;
    }

    public void setConnectBy(SQLExpr connectBy) {
        if (connectBy !is null) {
            connectBy.setParent(this);
        }
        this.connectBy = connectBy;
    }

    public bool isNoCycle() {
        return this.noCycle;
    }

    public void setNoCycle(bool noCycle) {
        this.noCycle = noCycle;
    }

    public List!SQLExpr getDistributeBy() {
        return distributeBy;
    }

    public List!SQLSelectOrderByItem getSortBy() {
        return sortBy;
    }

    public void addSortBy(SQLSelectOrderByItem item) {
        if (sortBy is null) {
            sortBy = new ArrayList!SQLSelectOrderByItem();
        }
        if (item !is null) {
            item.setParent(this);
        }
        this.sortBy.add(item);
    }

	
    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild!SQLSelectItem(visitor, this.selectList);
            acceptChild(visitor, this.from);
            acceptChild(visitor, this.into);
            acceptChild(visitor, this.where);
            acceptChild(visitor, this.startWith);
            acceptChild(visitor, this.connectBy);
            acceptChild(visitor, this.groupBy);
            acceptChild(visitor, this.orderBy);
            acceptChild!SQLExpr(visitor, this.distributeBy);
            acceptChild!SQLSelectOrderByItem(visitor, this.sortBy);
            acceptChild(visitor, this.waitTime);
            acceptChild(visitor, this._limit);
        }
        visitor.endVisit(this);
    }

    override
    public size_t toHash() @trusted nothrow {
         int prime = 31;
        size_t result = 1;
        result = prime * result + hashOf(parenthesized);
        result = prime * result + distionOption;
        result = prime * result + ((from is null) ? 0 : (cast(Object)from).toHash());
        result = prime * result + ((groupBy is null) ? 0 : (cast(Object)groupBy).toHash());
        result = prime * result + ((into is null) ? 0 : (cast(Object)into).toHash());
        result = prime * result + ((selectList is null) ? 0 : (cast(Object)selectList).toHash());
        result = prime * result + ((where is null) ? 0 : (cast(Object)where).toHash());
        return result;
    }

    override
    public bool opEquals(Object obj) {
        if (this == obj) return true;
        if (obj is null) return false;
        if (typeid(this) != typeid(obj)) return false;
        SQLSelectQueryBlock other = cast(SQLSelectQueryBlock) obj;
        if (parenthesized ^ other.parenthesized) return false;
        if (distionOption != other.distionOption) return false;
        if (from is null) {
            if (other.from !is null) return false;
        } else if (!(cast(Object)(from)).opEquals(cast(Object)(other.from))) return false;
        if (groupBy is null) {
            if (other.groupBy !is null) return false;
        } else if (!(cast(Object)(groupBy)).opEquals(cast(Object)(other.groupBy))) return false;
        if (into is null) {
            if (other.into !is null) return false;
        } else if (!(cast(Object)(into)).opEquals(cast(Object)(other.into))) return false;
        if (selectList is null) {
            if (other.selectList !is null) return false;
        } else if (!(cast(Object)(selectList)).opEquals(cast(Object)(other.selectList))) return false;
        if (where is null) {
            if (other.where !is null) return false;
        } else if (!(cast(Object)(where)).opEquals(cast(Object)(other.where))) return false;
        return true;
    }

    override public SQLSelectQueryBlock clone() {
        SQLSelectQueryBlock x = new SQLSelectQueryBlock();
        cloneTo(x);
        return x;
    }

    public List!SQLExpr getForUpdateOf() {
        if (forUpdateOf is null) {
            forUpdateOf = new ArrayList!SQLExpr(1);
        }
        return forUpdateOf;
    }

    public int getForUpdateOfSize() {
        if (forUpdateOf is null) {
            return 0;
        }

        return forUpdateOf.size();
    }

    public void cloneSelectListTo(SQLSelectQueryBlock x) {
        x.distionOption = distionOption;
        foreach (SQLSelectItem item ; this.selectList) {
            SQLSelectItem item2 = item.clone();
            item2.setParent(x);
            x.selectList.add(item2);
        }
    }

    public void cloneTo(SQLSelectQueryBlock x) {

        x.distionOption = distionOption;

        foreach (SQLSelectItem item ; this.selectList) {
            x.addSelectItem(item.clone());
        }

        if (from !is null) {
            x.setFrom(from.clone());
        }

        if (into !is null) {
            x.setInto(into.clone());
        }

        if (where !is null) {
            x.setWhere(where.clone());
        }

        if (startWith !is null) {
            x.setStartWith(startWith.clone());
        }

        if (connectBy !is null) {
            x.setConnectBy(connectBy.clone());
        }

        x.prior = prior;
        x.noCycle = noCycle;

        if (orderBySiblings !is null) {
            x.setOrderBySiblings(orderBySiblings.clone());
        }

        if (groupBy !is null) {
            x.setGroupBy(groupBy.clone());
        }

        if (orderBy !is null) {
            x.setOrderBy(orderBy.clone());
        }

        x.parenthesized = parenthesized;
        x.forUpdate = forUpdate;
        x.noWait = noWait;
        if (waitTime !is null) {
            x.setWaitTime(waitTime.clone());
        }

        if (_limit !is null) {
            x.setLimit(_limit.clone());
        }
    }

    override
    public bool isBracket() {
        return bracket;
    }

    override
    public void setBracket(bool bracket) {
        this.bracket = bracket;
    }

    public SQLTableSource findTableSource(string alias_p) {
        if (from is null) {
            return null;
        }
        return from.findTableSource(alias_p);
    }

    public SQLTableSource findTableSourceWithColumn(string column) {
        if (from is null) {
            return null;
        }
        return from.findTableSourceWithColumn(column);
    }

    public SQLTableSource findTableSourceWithColumn(long columnHash) {
        if (from is null) {
            return null;
        }
        return from.findTableSourceWithColumn(columnHash);
    }

    override
    public bool replace(SQLExpr expr, SQLExpr target) {
        if (where == expr) {
            setWhere(target);
            return true;
        }
        return false;
    }

    public SQLSelectItem findSelectItem(string ident) {
        if (ident is null) {
            return null;
        }

        long hash = FnvHash.hashCode64(ident);
        return findSelectItem(hash);
    }

    public SQLSelectItem findSelectItem(long identHash) {
        foreach (SQLSelectItem item ; this.selectList) {
            if (item.match(identHash)) {
                return item;
            }
        }

        return null;
    }

    public bool selectItemHasAllColumn() {
        return selectItemHasAllColumn(true);
    }

    public bool selectItemHasAllColumn(bool recursive) {
        foreach (SQLSelectItem item ; this.selectList) {
            SQLExpr expr = item.getExpr();

            bool allColumn = (cast(SQLAllColumnExpr)expr !is null)
                    || ( cast(SQLPropertyExpr)expr !is null && (cast(SQLPropertyExpr) expr).getName() == ("*"));

            if (allColumn) {
                if (recursive &&  cast(SQLSubqueryTableSource)from !is null) {
                    SQLSelect subSelect = (cast(SQLSubqueryTableSource) from).select;
                    SQLSelectQueryBlock queryBlock = subSelect.getQueryBlock();
                    if (queryBlock !is null) {
                        return queryBlock.selectItemHasAllColumn();
                    }
                }
                return true;
            }
        }

        return false;
    }

    public SQLSelectItem findAllColumnSelectItem() {
        SQLSelectItem allColumnItem = null;
        foreach (SQLSelectItem item ; this.selectList) {
            SQLExpr expr = item.getExpr();

            bool allColumn = (cast(SQLAllColumnExpr)expr !is null)
                    || ( cast(SQLPropertyExpr)expr !is null && (cast(SQLPropertyExpr) expr).getName() == ("*"));

            if (allColumnItem !is null) {
                return null; // duplicateAllColumn
            }
            allColumnItem = item;
        }

        return allColumnItem;
    }

    public SQLColumnDefinition findColumn(string columnName) {
        if (from is null) {
            return null;
        }

        long hash = FnvHash.hashCode64(columnName);
        return from.findColumn(hash);
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

        if ( cast(SQLBinaryOpExprGroup)where !is null) {
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

        if ( cast(SQLBinaryOpExpr)where !is null) {
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

    public void limit(int rowCount, int offset) {
        SQLLimit _limit = new SQLLimit();
        _limit.setRowCount(new SQLIntegerExpr(rowCount));
        if (offset > 0) {
            _limit.setOffset(new SQLIntegerExpr(offset));
        }

        setLimit(_limit);
    }

    public string getCachedSelectList() {
        return cachedSelectList;
    }

    public void setCachedSelectList(string cachedSelectList, long cachedSelectListHash) {
        this.cachedSelectList = cachedSelectList;
        this.cachedSelectListHash = cachedSelectListHash;
    }

    public long getCachedSelectListHash() {
        return cachedSelectListHash;
    }

    public List!SQLCommentHint getHintsDirect() {
        return hints;
    }

    public List!SQLCommentHint getHints() {
        if (hints is null) {
            hints = new ArrayList!SQLCommentHint(2);
        }
        return hints;
    }

    public void setHints(List!SQLCommentHint hints) {
        this.hints = hints;
    }

    public int getHintsSize() {
        if (hints is null) {
            return 0;
        }

        return hints.size();
    }

    public string getDbType() {
        return dbType;
    }

    public void setDbType(string dbType) {
        this.dbType = dbType;
    }

    public List!SQLWindow getWindows() {
        return windows;
    }

    public void addWindow(SQLWindow x) {
        if (x !is null) {
            x.setParent(this);
        }
        if (windows is null) {
            windows = new ArrayList!SQLWindow(4);
        }
        this.windows.add(x);
    }
}
