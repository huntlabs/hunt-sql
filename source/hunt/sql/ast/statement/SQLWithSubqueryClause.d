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
module hunt.sql.ast.statement.SQLWithSubqueryClause;


import hunt.container;

import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.ast.SQLStatement;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLTableSourceImpl;
import hunt.sql.ast.statement.SQLSelect;
import hunt.sql.ast.statement.SQLTableSource;
import hunt.sql.ast.statement.SQLSelectQueryBlock;
import hunt.sql.ast.SQLObject;

public class SQLWithSubqueryClause : SQLObjectImpl {

    private bool           recursive;
    private  List!Entry entries;

    this()
    {
        entries = new ArrayList!Entry();
    }

    override public SQLWithSubqueryClause clone() {
        SQLWithSubqueryClause x = new SQLWithSubqueryClause();
        x.recursive = recursive;

        foreach (Entry entry ; entries) {
            Entry entry2 = entry.clone();
            entry2.setParent(x);
            x.entries.add(entry2);
        }

        return x;
    }

    public List!Entry getEntries() {
        return entries;
    }
    
    public void addEntry(Entry entrie) {
        if (entrie !is null) {
            entrie.setParent(this);
        }
        this.entries.add(entrie);
    }

    public bool getRecursive() {
        return recursive;
    }

    public void setRecursive(bool recursive) {
        this.recursive = recursive;
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild!(SQLWithSubqueryClause.Entry)(visitor, entries);
        }
        visitor.endVisit(this);
    }

    public static class Entry : SQLTableSourceImpl {

        protected  List!SQLName columns;
        protected SQLSelect           subQuery;
        protected SQLStatement        returningStatement;

        this()
        {
            columns = new ArrayList!SQLName();
        }

        public void cloneTo(Entry x) {
            foreach (SQLName column ; columns) {
                SQLName column2 = column.clone();
                column2.setParent(x);
                x.columns.add(column2);
            }

            if (subQuery !is null) {
                x.setSubQuery(subQuery.clone());
            }

            if (returningStatement !is null) {
                setReturningStatement(returningStatement.clone());
            }
        }

        override public Entry clone() {
            Entry x = new Entry();
            cloneTo(x);
            return x;
        }

        
        override  protected void accept0(SQLASTVisitor visitor) {
            if (visitor.visit(this)) {
                acceptChild!SQLName(visitor, columns);
                acceptChild(visitor, subQuery);
                acceptChild(visitor, returningStatement);
            }
            visitor.endVisit(this);
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

        public SQLStatement getReturningStatement() {
            return returningStatement;
        }

        public void setReturningStatement(SQLStatement returningStatement) {
            if (returningStatement !is null) {
                returningStatement.setParent(this);
            }
            this.returningStatement = returningStatement;
        }

        public List!SQLName getColumns() {
            return columns;
        }

        override public SQLTableSource findTableSourceWithColumn(long columnNameHash) {
            foreach (SQLName column ; columns) {
                if (column.nameHashCode64() == columnNameHash) {
                    return this;
                }
            }

            if (subQuery !is null) {
                SQLSelectQueryBlock queryBlock = subQuery.getFirstQueryBlock();
                if (queryBlock !is null) {
                    if (queryBlock.findSelectItem(columnNameHash) !is null) {
                        return this;
                    }
                }
            }
            return null;
        }
    }

    public Entry findEntry(long alias_hash) {
        if (alias_hash == 0) {
            return null;
        }

        foreach (Entry entry ; entries) {
            if (entry.aliasHashCode64() == alias_hash) {
                return entry;
            }
        }

        return null;
    }
}
