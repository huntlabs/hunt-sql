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
module hunt.sql.ast.statement.SQLAlterSequenceStatement;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLObject;
import hunt.sql.ast.SQLStatementImpl;
import hunt.sql.ast.expr.SQLPropertyExpr;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLAlterStatement;
import hunt.lang;
import hunt.container;

public class SQLAlterSequenceStatement : SQLStatementImpl , SQLAlterStatement {
    private SQLName name;

    private SQLExpr startWith;
    private SQLExpr incrementBy;
    private SQLExpr minValue;
    private SQLExpr maxValue;
    private bool noMaxValue;
    private bool noMinValue;

    private Boolean cycle;
    private Boolean cache;
    private SQLExpr cacheValue;

    private Boolean order;

    override
    public void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, name);
            acceptChild(visitor, startWith);
            acceptChild(visitor, incrementBy);
            acceptChild(visitor, minValue);
            acceptChild(visitor, maxValue);
        }
        visitor.endVisit(this);
    }

    override
    public List!SQLObject getChildren() {
        List!SQLObject children = new ArrayList!SQLObject();
        if (name !is null) {
            children.add(name);
        }
        if (startWith !is null) {
            children.add(startWith);
        }
        if (incrementBy !is null) {
            children.add(incrementBy);
        }
        if (minValue !is null) {
            children.add(minValue);
        }
        if (maxValue !is null) {
            children.add(maxValue);
        }
        return children;
    }

    public SQLName getName() {
        return name;
    }

    public void setName(SQLName name) {
        this.name = name;
    }

    public SQLExpr getStartWith() {
        return startWith;
    }

    public void setStartWith(SQLExpr startWith) {
        this.startWith = startWith;
    }

    public SQLExpr getIncrementBy() {
        return incrementBy;
    }

    public void setIncrementBy(SQLExpr incrementBy) {
        this.incrementBy = incrementBy;
    }

    public SQLExpr getMaxValue() {
        return maxValue;
    }

    public void setMaxValue(SQLExpr maxValue) {
        this.maxValue = maxValue;
    }

    public Boolean getCycle() {
        return cycle;
    }

    public void setCycle(Boolean cycle) {
        this.cycle = cycle;
    }

    public Boolean getCache() {
        return cache;
    }

    public void setCache(Boolean cache) {
        this.cache = cache;
    }

    public Boolean getOrder() {
        return order;
    }

    public void setOrder(Boolean order) {
        this.order = order;
    }

    public SQLExpr getMinValue() {
        return minValue;
    }

    public void setMinValue(SQLExpr minValue) {
        this.minValue = minValue;
    }

    public bool isNoMaxValue() {
        return noMaxValue;
    }

    public void setNoMaxValue(bool noMaxValue) {
        this.noMaxValue = noMaxValue;
    }

    public bool isNoMinValue() {
        return noMinValue;
    }

    public void setNoMinValue(bool noMinValue) {
        this.noMinValue = noMinValue;
    }

    public string getSchema() {
        SQLName name = getName();
        if (name is null) {
            return null;
        }

        if ( cast(SQLPropertyExpr)name !is null) {
            return (cast(SQLPropertyExpr) name).getOwnernName();
        }

        return null;
    }

    public SQLExpr getCacheValue() {
        return cacheValue;
    }

    public void setCacheValue(SQLExpr cacheValue) {
        if (cacheValue !is null) {
            cacheValue.setParent(this);
        }
        this.cacheValue = cacheValue;
    }
}
