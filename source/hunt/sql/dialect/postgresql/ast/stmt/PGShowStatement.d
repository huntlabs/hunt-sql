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
module hunt.sql.dialect.postgresql.ast.stmt.PGShowStatement;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLStatementImpl;
import hunt.sql.dialect.postgresql.visitor.PGASTVisitor;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.dialect.postgresql.ast.stmt.PGSQLStatement;

public class PGShowStatement : SQLStatementImpl , PGSQLStatement {

    private SQLExpr expr;

    public SQLExpr getExpr() {
        return expr;
    }

    public void setExpr(SQLExpr expr) {
        this.expr = expr;
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        accept0(cast(PGASTVisitor) visitor);
    }

    override
    public void accept0(PGASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, this.expr);
        }
        visitor.endVisit(this);
    }
}
