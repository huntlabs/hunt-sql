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
module hunt.sql.dialect.postgresql.ast.stmt.PGSelectQueryBlock;


import hunt.container;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLOrderBy;
import hunt.sql.ast.statement.SQLSelectQueryBlock;
import hunt.sql.dialect.postgresql.ast.PGSQLObject;
import hunt.sql.dialect.postgresql.ast.PGSQLObjectImpl;
import hunt.sql.dialect.postgresql.visitor.PGASTVisitor;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.util.DBType;
import hunt.sql.ast.SQLObject;
import hunt.sql.ast.statement.SQLSelectItem;

public class PGSelectQueryBlock : SQLSelectQueryBlock , PGSQLObject{

    private List!(SQLExpr) distinctOn;
    private WindowClause  window;

    private SQLOrderBy    orderBy;
    private FetchClause   fetch;
    private ForClause     forClause;
    private IntoOption    intoOption;


    public static struct IntoOption {
        enum IntoOption TEMPORARY = IntoOption("TEMPORARY");
        enum IntoOption TEMP = IntoOption("TEMP");
        enum IntoOption UNLOGGED = IntoOption("UNLOGGED");

        private string _name;

        this(string name)
        {
            _name = name;
        }

        @property name()
        {
            return _name;
        }

        bool opEquals(const IntoOption h) nothrow {
        return _name == h._name ;
        } 

        bool opEquals(ref const IntoOption h) nothrow {
            return _name == h._name ;
        } 
    }

    public this() {
        distinctOn = new ArrayList!(SQLExpr)(2);
        dbType = DBType.POSTGRESQL.name;
    }

    public IntoOption getIntoOption() {
        return intoOption;
    }

    public void setIntoOption(IntoOption intoOption) {
        this.intoOption = intoOption;
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (cast(PGASTVisitor)(visitor) !is null) {
            accept0(cast(PGASTVisitor) visitor);
        } else {
            super.accept0(visitor);
        }
    }

    override
    public void accept0(PGASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild!SQLExpr(visitor, this.distinctOn);
            acceptChild!SQLSelectItem(visitor, this.selectList);
            acceptChild(visitor, this.into);
            acceptChild(visitor, this.from);
            acceptChild(visitor, this.where);
            acceptChild(visitor, this.groupBy);
            acceptChild(visitor, this.window);
            acceptChild(visitor, this.orderBy);
            acceptChild(visitor, this._limit);
            acceptChild(visitor, this.fetch);
            acceptChild(visitor, this.forClause);
        }
        visitor.endVisit(this);
    }

    public FetchClause getFetch() {
        return fetch;
    }

    public void setFetch(FetchClause fetch) {
        this.fetch = fetch;
    }

    public ForClause getForClause() {
        return forClause;
    }

    public void setForClause(ForClause forClause) {
        this.forClause = forClause;
    }

    public WindowClause getWindow() {
        return window;
    }

    public void setWindow(WindowClause window) {
        this.window = window;
    }

    override public SQLOrderBy getOrderBy() {
        return orderBy;
    }

    override public void setOrderBy(SQLOrderBy orderBy) {
        this.orderBy = orderBy;
    }

    public List!(SQLExpr) getDistinctOn() {
        return distinctOn;
    }

    public void setDistinctOn(List!(SQLExpr) distinctOn) {
        this.distinctOn = distinctOn;
    }

    public static class WindowClause : PGSQLObjectImpl {
        alias accept0 = PGSQLObjectImpl.accept0;
        private SQLExpr       name;
        private List!(SQLExpr) definition;

        this()
        {
            definition = new ArrayList!(SQLExpr)(2);
        }

        public SQLExpr getName() {
            return name;
        }

        public void setName(SQLExpr name) {
            this.name = name;
        }

        public List!(SQLExpr) getDefinition() {
            return definition;
        }

        public void setDefinition(List!(SQLExpr) definition) {
            this.definition = definition;
        }

        override
        public void accept0(PGASTVisitor visitor) {
            if (visitor.visit(this)) {
                acceptChild(visitor, name);
                acceptChild!SQLExpr(visitor, definition);
            }
            visitor.endVisit(this);
        }
    }

    public static class FetchClause : PGSQLObjectImpl {
        alias accept0 = PGSQLObjectImpl.accept0;
        public static enum Option {
            FIRST, NEXT
        }

        private Option  option;
        private SQLExpr count;

        public Option getOption() {
            return option;
        }

        public void setOption(Option option) {
            this.option = option;
        }

        public SQLExpr getCount() {
            return count;
        }

        public void setCount(SQLExpr count) {
            this.count = count;
        }

        override
        public void accept0(PGASTVisitor visitor) {
            if (visitor.visit(this)) {
                acceptChild(visitor, count);
            }
            visitor.endVisit(this);
        }

    }

    public static class ForClause : PGSQLObjectImpl {
        alias accept0 = PGSQLObjectImpl.accept0;
        public static enum Option {
            UPDATE, SHARE
        }

        private List!(SQLExpr) of;
        private bool       noWait;
        private Option        option;

        this()
        {
            of = new ArrayList!(SQLExpr)(2);
        }

        public Option getOption() {
            return option;
        }

        public void setOption(Option option) {
            this.option = option;
        }

        public List!(SQLExpr) getOf() {
            return of;
        }

        public void setOf(List!(SQLExpr) of) {
            this.of = of;
        }

        public bool isNoWait() {
            return noWait;
        }

        public void setNoWait(bool noWait) {
            this.noWait = noWait;
        }

        override
        public void accept0(PGASTVisitor visitor) {
            if (visitor.visit(this)) {
                acceptChild!SQLExpr(visitor, of);
            }
            visitor.endVisit(this);
        }
    }
}