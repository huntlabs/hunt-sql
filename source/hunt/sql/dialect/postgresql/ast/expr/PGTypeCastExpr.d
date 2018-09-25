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
module hunt.sql.dialect.postgresql.ast.expr.PGTypeCastExpr;

import hunt.sql.SQLUtils;
import hunt.sql.ast.expr.SQLCastExpr;
import hunt.sql.dialect.postgresql.visitor.PGASTVisitor;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.dialect.postgresql.ast.expr.PGExpr;

public class PGTypeCastExpr : SQLCastExpr , PGExpr {

    override
    public void accept0(PGASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, this.expr);
            acceptChild(visitor, this.dataType);
        }
        visitor.endVisit(this);
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (cast(PGASTVisitor)(visitor) !is null) {
            accept0(cast(PGASTVisitor) visitor);
            return;
        }

        super.accept0(visitor);
    }

    override public string toString() {
        return SQLUtils.toPGString(this);
    }
}
