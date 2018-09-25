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
module hunt.sql.dialect.mysql.ast.statement.MySqlRenameTableStatement;


import hunt.container;
import hunt.sql.ast.SQLObject;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.dialect.mysql.ast.MySqlObjectImpl;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;
import hunt.sql.dialect.mysql.ast.statement.MySqlStatementImpl;

public class MySqlRenameTableStatement : MySqlStatementImpl {

    alias accept0 = MySqlStatementImpl.accept0;
    
    private List!(Item) items;

    this()
    {
        items = new ArrayList!(Item)(2);
    }

    public List!(Item) getItems() {
        return items;
    }

    public void addItem(Item item) {
        if (item !is null) {
            item.setParent(this);
        }
        this.items.add(item);
    }

    override public void accept0(MySqlASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, cast(List!(SQLObject))items);
        }
        visitor.endVisit(this);
    }

    public static class Item : MySqlObjectImpl {

        alias accept0 = MySqlObjectImpl.accept0;

        private SQLName name;
        private SQLName to;

        public SQLName getName() {
            return name;
        }

        public void setName(SQLName name) {
            this.name = name;
        }

        public SQLName getTo() {
            return to;
        }

        public void setTo(SQLName to) {
            this.to = to;
        }

        override
        public void accept0(MySqlASTVisitor visitor) {
            if (visitor.visit(this)) {
                acceptChild(visitor, name);
                acceptChild(visitor, to);
            }
            visitor.endVisit(this);
        }

    }
}
