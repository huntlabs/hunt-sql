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
module hunt.sql.dialect.mysql.ast.statement.MySqlEventSchedule;

import hunt.sql.ast.SQLExpr;
import hunt.sql.dialect.mysql.ast.MySqlObject;
import hunt.sql.dialect.mysql.ast.MySqlObjectImpl;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;

public class MySqlEventSchedule : MySqlObjectImpl {
    alias accept0 = MySqlObjectImpl.accept0;
    
    private SQLExpr at;
    private SQLExpr every;
    private SQLExpr starts;
    private SQLExpr ends;

    override
    public void accept0(MySqlASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, at);
            acceptChild(visitor, every);
            acceptChild(visitor, starts);
            acceptChild(visitor, ends);
        }
        visitor.endVisit(this);
    }

    public SQLExpr getAt() {
        return at;
    }

    public void setAt(SQLExpr x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.at = x;
    }

    public SQLExpr getEvery() {
        return every;
    }

    public void setEvery(SQLExpr x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.every = x;
    }

    public SQLExpr getStarts() {
        return starts;
    }

    public void setStarts(SQLExpr x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.starts = x;
    }

    public SQLExpr getEnds() {
        return ends;
    }

    public void setEnds(SQLExpr x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.ends = x;
    }
}
