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
module hunt.sql.ast.statement.SQLFetchStatement;


import hunt.collection;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLStatementImpl;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.SQLObject;

public class SQLFetchStatement : SQLStatementImpl {

    private SQLName       cursorName;

    private bool       bulkCollect;

    private List!SQLExpr into;

    this()
    {
        into = new ArrayList!SQLExpr();
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, cursorName);
            acceptChild!SQLExpr(visitor, into);
        }
        visitor.endVisit(this);
    }

    public SQLName getCursorName() {
        return cursorName;
    }

    public void setCursorName(SQLName cursorName) {
        this.cursorName = cursorName;
    }

    public List!SQLExpr getInto() {
        return into;
    }

    public void setInto(List!SQLExpr into) {
        this.into = into;
    }

    public bool isBulkCollect() {
        return bulkCollect;
    }

    public void setBulkCollect(bool bulkCollect) {
        this.bulkCollect = bulkCollect;
    }
}
