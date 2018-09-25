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
module hunt.sql.ast.statement.SQLErrorLoggingClause;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.visitor.SQLASTVisitor;

public class SQLErrorLoggingClause : SQLObjectImpl {

    private SQLName into;
    private SQLExpr simpleExpression;
    private SQLExpr limit;

    override
    public void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, into);
            acceptChild(visitor, simpleExpression);
            acceptChild(visitor, limit);
        }
        visitor.endVisit(this);
    }

    public SQLName getInto() {
        return into;
    }

    public void setInto(SQLName into) {
        this.into = into;
    }

    public SQLExpr getSimpleExpression() {
        return simpleExpression;
    }

    public void setSimpleExpression(SQLExpr simpleExpression) {
        this.simpleExpression = simpleExpression;
    }

    public SQLExpr getLimit() {
        return limit;
    }

    public void setLimit(SQLExpr limit) {
        this.limit = limit;
    }

    override public SQLErrorLoggingClause clone() {
        SQLErrorLoggingClause x = new SQLErrorLoggingClause();
        if (into !is null) {
            x.setInto(into.clone());
        }
        if (simpleExpression !is null) {
            x.setSimpleExpression(simpleExpression.clone());
        }
        if (limit !is null) {
            x.setLimit(limit.clone());
        }
        return x;
    }

}
