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
module hunt.sql.dialect.postgresql.ast.stmt.PGDeleteStatement;


import hunt.collection;

import hunt.sql.ast.SQLName;
import hunt.sql.ast.statement.SQLDeleteStatement;
import hunt.sql.ast.statement.SQLWithSubqueryClause;
import hunt.sql.dialect.postgresql.visitor.PGASTVisitor;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.util.DBType;
import hunt.sql.dialect.postgresql.ast.stmt.PGSQLStatement;

public class PGDeleteStatement : SQLDeleteStatement , PGSQLStatement {

    private bool       returning;

    public this() {
        super (DBType.POSTGRESQL.name);
    }

    public bool isReturning() {
        return returning;
    }

    public void setReturning(bool returning) {
        this.returning = returning;
    }

    override public string getAlias() {
        if (tableSource is null) {
            return null;
        }
        return tableSource.getAlias();
    }

    override public void setAlias(string alias_p) {
        this.tableSource.setAlias(alias_p);
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        // accept0(cast(PGASTVisitor) visitor);
        if (cast(PGASTVisitor)(visitor) !is null) {
            accept0(cast(PGASTVisitor) visitor);
        } else {
            super.accept0(visitor);
        }
    }

    override
    public void accept0(PGASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, _with);
            acceptChild(visitor, tableSource);
            acceptChild(visitor, using);
            acceptChild(visitor, where);
        }

        visitor.endVisit(this);
    }

    override public PGDeleteStatement clone() {
        PGDeleteStatement x = new PGDeleteStatement();
        cloneTo(x);

        x.returning = returning;

        return x;
    }
}
