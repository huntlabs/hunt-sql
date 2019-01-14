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
module hunt.sql.dialect.postgresql.ast.stmt.PGUpdateStatement;

import hunt.sql.ast.statement.SQLUpdateStatement;
import hunt.sql.ast.statement.SQLWithSubqueryClause;
import hunt.sql.dialect.postgresql.visitor.PGASTVisitor;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.util.DBType;
import hunt.sql.dialect.postgresql.ast.stmt.PGSQLStatement;
import hunt.sql.ast.SQLObject;
import hunt.collection;
import hunt.sql.ast.statement.SQLUpdateSetItem;

public class PGUpdateStatement : SQLUpdateStatement , PGSQLStatement {

    private bool        only      = false;

    public this(){
        super (DBType.POSTGRESQL.name);
    }

    public bool isOnly() {
        return only;
    }

    public void setOnly(bool only) {
        this.only = only;
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        if (cast(PGASTVisitor)(visitor) !is null) {
            accept0(cast(PGASTVisitor) visitor);
            return;
        }

        super.accept0(visitor);
    }

    override
    public void accept0(PGASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, _with);
            acceptChild(visitor, tableSource);
            acceptChild!SQLUpdateSetItem(visitor, items);
            acceptChild(visitor, where);
        }
        visitor.endVisit(this);
    }

}
