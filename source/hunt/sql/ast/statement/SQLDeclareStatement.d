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
module hunt.sql.ast.statement.SQLDeclareStatement;


import hunt.container;

import hunt.sql.ast;
// import hunt.sql.dialect.sqlserver.ast.SQLServerObjectImpl;
// import hunt.sql.dialect.sqlserver.ast.SQLServerStatement;
// import hunt.sql.dialect.sqlserver.visitor.SQLServerASTVisitor;
import hunt.sql.visitor.SQLASTVisitor;

public class SQLDeclareStatement : SQLStatementImpl {

    protected List!SQLDeclareItem items;
    
    public this() {
        items = new ArrayList!SQLDeclareItem();
    }

    public this(SQLName name, SQLDataType dataType) {
        this.addItem(new SQLDeclareItem(name, dataType));
    }

    public this(SQLName name, SQLDataType dataType, SQLExpr value) {
        this.addItem(new SQLDeclareItem(name, dataType, value));
    }

    override
    public void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            this.acceptChild!SQLDeclareItem(visitor, items);
        }
        visitor.endVisit(this);
    }

    public List!SQLDeclareItem getItems() {
        return items;
    }

    public void addItem(SQLDeclareItem item) {
        if (item !is null) {
            item.setParent(this);
        }
        this.items.add(item);
    }
}
