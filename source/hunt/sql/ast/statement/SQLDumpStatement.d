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
module hunt.sql.ast.statement.SQLDumpStatement;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLStatementImpl;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLExprTableSource;
import hunt.sql.ast.statement.SQLSelect;

public class SQLDumpStatement : SQLStatementImpl {
    private bool overwrite;
    private SQLExprTableSource into;

    private SQLSelect select;

    public this() {

    }

    public SQLSelect getSelect() {
        return select;
    }

    public void setSelect(SQLSelect x) {
        if (x !is null) {
            x.setParent(this);
        }

        this.select = x;
    }

    public SQLExprTableSource getInto() {
        return into;
    }

    public void setInto(SQLExpr x) {
        if (x is null) {
            return;
        }

        setInto(new SQLExprTableSource(x));
    }

    public void setInto(SQLExprTableSource x) {
        if (x !is null) {
            x.setParent(this);
        }

        this.into = x;
    }

    public bool isOverwrite() {
        return overwrite;
    }

    public void setOverwrite(bool overwrite) {
        this.overwrite = overwrite;
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            if (into !is null) {
                into.accept(visitor);
            }

            if (select !is null) {
                select.accept(visitor);
            }
        }
        visitor.endVisit(this);
    }
}
