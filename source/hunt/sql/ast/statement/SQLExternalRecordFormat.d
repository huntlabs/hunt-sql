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
module hunt.sql.ast.statement.SQLExternalRecordFormat;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLObjectImpl;
// import hunt.sql.dialect.oracle.ast.OracleSQLObjectImpl;
// import hunt.sql.dialect.oracle.visitor.OracleASTVisitor;
import hunt.sql.visitor.SQLASTVisitor;

public class SQLExternalRecordFormat : SQLObjectImpl {
    private SQLExpr delimitedBy;
    private SQLExpr terminatedBy;

    override
    public void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, delimitedBy);
            acceptChild(visitor, terminatedBy);
        }
        visitor.endVisit(this);
    }

    public SQLExpr getDelimitedBy() {
        return delimitedBy;
    }

    public void setDelimitedBy(SQLExpr delimitedBy) {
        if (delimitedBy !is null) {
            delimitedBy.setParent(this);
        }
        this.delimitedBy = delimitedBy;
    }

    public SQLExpr getTerminatedBy() {
        return terminatedBy;
    }

    public void setTerminatedBy(SQLExpr terminatedBy) {
        if (terminatedBy !is null) {
            terminatedBy.setParent(this);
        }
        this.terminatedBy = terminatedBy;
    }
}
