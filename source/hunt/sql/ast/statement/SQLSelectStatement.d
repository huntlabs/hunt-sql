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
module hunt.sql.ast.statement.SQLSelectStatement;

import hunt.sql.ast.SQLCommentHint;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLObject;
import hunt.sql.ast.SQLStatementImpl;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLSelect;

import hunt.collection;

public class SQLSelectStatement : SQLStatementImpl {

    protected SQLSelect select;

    public this(){

    }

    public this(string dbType){
        super (dbType);
    }

    public this(SQLSelect select){
        this.setSelect(select);
    }

    public this(SQLSelect select, string dbType){
        this(dbType);
        this.setSelect(select);
    }

    public SQLSelect getSelect() {
        return this.select;
    }

    public void setSelect(SQLSelect select) {
        if (select !is null) {
            select.setParent(this);
        }
        this.select = select;
    }

    override public void output(StringBuffer buf) {
        this.select.output(buf);
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, this.select);
        }
        visitor.endVisit(this);
    }

    override public SQLSelectStatement clone() {
        SQLSelectStatement x = new SQLSelectStatement();
        if (select !is null) {
            x.setSelect(select.clone());
        }
        if (headHints !is null) {
            foreach (SQLCommentHint h ; headHints) {
                SQLCommentHint h2 = h.clone();
                h2.setParent(x);
                x.headHints.add(h2);
            }
        }
        return x;
    }

    override
    public List!SQLObject getChildren() {
        return Collections.singletonList!SQLObject(select);
    }

    public bool addWhere(SQLExpr where) {
        return select.addWhere(where);
    }
}
