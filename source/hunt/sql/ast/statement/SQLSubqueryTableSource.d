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
module hunt.sql.ast.statement.SQLSubqueryTableSource;

import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLTableSourceImpl;
import hunt.sql.ast.statement.SQLSelect;
import hunt.sql.ast.statement.SQLSelectQuery;
import hunt.sql.ast.statement.SQLSelectQueryBlock;
import hunt.sql.ast.statement.SQLTableSource;
import hunt.collection;

public class SQLSubqueryTableSource : SQLTableSourceImpl {

    public SQLSelect select;

    public this(){

    }

    public this(string alias_p){
        super(alias_p);
    }

    public this(SQLSelect select, string alias_p){
        super(alias_p);
        this.setSelect(select);
    }

    public this(SQLSelect select){
        this.setSelect(select);
    }

    public this(SQLSelectQuery query){
        this(new SQLSelect(query));
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

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, select);
        }
        visitor.endVisit(this);
    }

    override public void output(StringBuffer buf) {
        buf.append("(");
        this.select.output(buf);
        buf.append(")");
    }

    public void cloneTo(SQLSubqueryTableSource x) {
        x._alias = _alias;

        if (select !is null) {
            x.select = select.clone();
        }
    }

    override public SQLSubqueryTableSource clone() {
        SQLSubqueryTableSource x = new SQLSubqueryTableSource();
        cloneTo(x);
        return x;
    }

    override public SQLTableSource findTableSourceWithColumn(string columnName) {
        if (select is null) {
            return null;
        }

        SQLSelectQueryBlock queryBlock = select.getFirstQueryBlock();
        if (queryBlock is null) {
            return null;
        }

        if (queryBlock.findSelectItem(columnName) !is null) {
            return this;
        }

        return null;
    }

    override public SQLTableSource findTableSourceWithColumn(long columnNameHash) {
        if (select is null) {
            return null;
        }

        SQLSelectQueryBlock queryBlock = select.getFirstQueryBlock();
        if (queryBlock is null) {
            return null;
        }

        if (queryBlock.findSelectItem(columnNameHash) !is null) {
            return this;
        }

        return null;
    }
}
