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
module hunt.sql.dialect.postgresql.ast.stmt.PGConnectToStatement;

import hunt.sql.SQLUtils;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLStatementImpl;
import hunt.sql.dialect.postgresql.visitor.PGASTVisitor;
import hunt.sql.visitor.SQLASTOutputVisitor;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.util.DBType;
import hunt.sql.dialect.postgresql.ast.stmt.PGSQLStatement;
import hunt.collection;
import hunt.util.StringBuilder;

public class PGConnectToStatement : SQLStatementImpl , PGSQLStatement {
    private SQLName target;

    public this() {
        super(DBType.POSTGRESQL.name);
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        this.accept0(cast(PGASTVisitor) visitor);
    }

    override public void output(StringBuilder buf) {
        SQLASTOutputVisitor visitor = SQLUtils.createOutputVisitor(buf, dbType);
        this.accept(visitor);
    }

    override
    public void accept0(PGASTVisitor v) {
        if (v.visit(this)) {
            acceptChild(v, target);
        }
        v.endVisit(this);
    }

    public SQLName getTarget() {
        return target;
    }

    public void setTarget(SQLName x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.target = x;
    }
}
