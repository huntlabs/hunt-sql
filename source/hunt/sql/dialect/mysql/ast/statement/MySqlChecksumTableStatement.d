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
module hunt.sql.dialect.mysql.ast.statement.MySqlChecksumTableStatement;

import hunt.sql.ast.statement.SQLExprTableSource;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;
import hunt.sql.dialect.mysql.ast.statement.MySqlStatementImpl;


import hunt.collection;
import hunt.sql.ast.SQLObject;

public class MySqlChecksumTableStatement : MySqlStatementImpl {

    alias accept0 = MySqlStatementImpl.accept0;
    
    private  List!(SQLExprTableSource) tables;

    private bool quick;
    private bool extended;

    public this() {
        tables = new ArrayList!(SQLExprTableSource)();
    }

    public void addTable(SQLExprTableSource table) {
        if (table is null) {
            return;
        }

        table.setParent(this);
        tables.add(table);
    }

    public List!(SQLExprTableSource) getTables() {
        return tables;
    }

    public bool isQuick() {
        return quick;
    }

    public void setQuick(bool quick) {
        this.quick = quick;
    }

    public bool isExtended() {
        return extended;
    }

    public void setExtended(bool extended) {
        this.extended = extended;
    }

    override public void accept0(MySqlASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild!SQLExprTableSource(visitor, tables);
        }
        visitor.endVisit(this);
    }
}
