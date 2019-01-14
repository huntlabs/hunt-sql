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
module hunt.sql.dialect.mysql.ast.statement.MySqlShowIndexesStatement;

import hunt.collection;

import hunt.sql.ast.SQLCommentHint;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.expr.SQLIdentifierExpr;
import hunt.sql.ast.expr.SQLPropertyExpr;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;
import hunt.sql.dialect.mysql.ast.statement.MySqlShowStatement;
import hunt.sql.dialect.mysql.ast.statement.MySqlStatementImpl;

public class MySqlShowIndexesStatement : MySqlStatementImpl , MySqlShowStatement {
    alias accept0 = MySqlStatementImpl.accept0;
    private SQLName              table;
    private SQLName              database;
    private List!(SQLCommentHint) hints;

    public SQLName getTable() {
        return table;
    }

    public void setTable(SQLName table) {
        if (cast(SQLPropertyExpr)(table) !is null) {
            SQLPropertyExpr propExpr = cast(SQLPropertyExpr) table;
            this.setDatabase(cast(SQLName) propExpr.getOwner());
            this.table = new SQLIdentifierExpr(propExpr.getName());
            return;
        }
        this.table = table;
    }

    public SQLName getDatabase() {
        return database;
    }

    public void setDatabase(SQLName database) {
        this.database = database;
    }

    override public void accept0(MySqlASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, table);
            acceptChild(visitor, database);
        }
        visitor.endVisit(this);
    }

    public List!(SQLCommentHint) getHints() {
        return hints;
    }

    public void setHints(List!(SQLCommentHint) hints) {
        this.hints = hints;
    }
}
