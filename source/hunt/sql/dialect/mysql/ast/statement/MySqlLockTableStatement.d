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
module hunt.sql.dialect.mysql.ast.statement.MySqlLockTableStatement;

import hunt.collection;
import hunt.sql.ast.SQLObject;

import hunt.sql.ast.SQLCommentHint;
import hunt.sql.ast.statement.SQLExprTableSource;
import hunt.sql.dialect.mysql.ast.MySqlObjectImpl;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;
import hunt.sql.dialect.mysql.ast.statement.MySqlStatementImpl;

public class MySqlLockTableStatement : MySqlStatementImpl
{
    alias accept0 = MySqlStatementImpl.accept0;
    
    private List!(Item) items;

    this()
    {
        items = new ArrayList!(Item)();
    }

    override public void accept0(MySqlASTVisitor visitor)
    {
        if (visitor.visit(this))
        {
            acceptChild(visitor, cast(List!(SQLObject))items);
        }
        visitor.endVisit(this);
    }

    public static struct LockType
    {
        enum LockType READ = LockType("READ");
        enum LockType READ_LOCAL = LockType("READ LOCAL");
        enum LockType WRITE = LockType("WRITE");
        enum LOW_PRIORITY_WRITE = LockType("LOW_PRIORITY WRITE");

        public string name;

        this(string name)
        {
            this.name = name;
        }

        bool opEquals(const LockType h) nothrow
        {
            return name == h.name;
        }

        bool opEquals(ref const LockType h) nothrow
        {
            return name == h.name;
        }
    }

    public List!(Item) getItems()
    {
        return items;
    }

    public void setItems(List!(Item) items)
    {
        this.items = items;
    }

    public LockType getLockType()
    {
        if (items.size() == 1)
        {
            return items.get(0).lockType;
        }
        return LockType(string.init);
    }

    public SQLExprTableSource getTableSource()
    {
        if (items.size() == 1)
        {
            return items.get(0).tableSource;
        }
        return null;
    }

    public static class Item : MySqlObjectImpl
    {

        alias accept0 = MySqlObjectImpl.accept0;

        private SQLExprTableSource tableSource;

        private LockType lockType;

        private List!(SQLCommentHint) hints;

        this()
        {
            tableSource = new SQLExprTableSource();
        }
    
        override public void accept0(MySqlASTVisitor visitor)
        {
            if (visitor.visit(this))
            {
                acceptChild(visitor, tableSource);
            }
            visitor.endVisit(this);
        }

        public SQLExprTableSource getTableSource()
        {
            return tableSource;
        }

        public void setTableSource(SQLExprTableSource tableSource)
        {
            if (tableSource !is null)
            {
                tableSource.setParent(this);
            }
            this.tableSource = tableSource;
        }

        public LockType getLockType()
        {
            return lockType;
        }

        public void setLockType(LockType lockType)
        {
            this.lockType = lockType;
        }

        public List!(SQLCommentHint) getHints()
        {
            return hints;
        }

        public void setHints(List!(SQLCommentHint) hints)
        {
            this.hints = hints;
        }
    }
}
