/*
 * Copyright 2015-2018 HuntLabs.cn
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except _in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to _in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
module hunt.sql.dialect.mysql.ast.statement.MySqlShowBinLogEventsStatement;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLLimit;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;
import hunt.sql.dialect.mysql.ast.statement.MySqlStatementImpl;
import hunt.sql.dialect.mysql.ast.statement.MySqlShowStatement;

public class MySqlShowBinLogEventsStatement : MySqlStatementImpl , MySqlShowStatement {

    alias accept0 = MySqlStatementImpl.accept0;
    
    private SQLExpr _in;
    private SQLExpr from;
    private SQLLimit limit;

    override public void accept0(MySqlASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, _in);
            acceptChild(visitor, from);
            acceptChild(visitor, limit);
        }
        visitor.endVisit(this);
    }

    public SQLExpr getIn() {
        return _in;
    }

    public void setIn(SQLExpr _in) {
        this._in = _in;
    }

    public SQLExpr getFrom() {
        return from;
    }

    public void setFrom(SQLExpr from) {
        this.from = from;
    }

    public SQLLimit getLimit() {
        return limit;
    }

    public void setLimit(SQLLimit limit) {
        if (limit !is null) {
            limit.setParent(this);
        }
        this.limit = limit;
    }

}
