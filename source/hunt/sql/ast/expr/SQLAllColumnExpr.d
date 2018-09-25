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
module hunt.sql.ast.expr.SQLAllColumnExpr;

import hunt.sql.ast.SQLExprImpl;
import hunt.sql.ast.statement.SQLTableSource;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.container;
import hunt.sql.ast.SQLObject;

public  class SQLAllColumnExpr : SQLExprImpl {
    private  SQLTableSource resolvedTableSource;

    public this(){

    }

    override public void output(StringBuffer buf) {
        buf.append("*");
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        visitor.visit(this);
        visitor.endVisit(this);
    }

    override public size_t toHash() @trusted nothrow {
        return 0;
    }

    override public bool opEquals(Object o) {
        return cast(SQLAllColumnExpr)o is null ? false : true;
    }

    override public SQLAllColumnExpr clone() {
        SQLAllColumnExpr x = new SQLAllColumnExpr();

        x.resolvedTableSource = resolvedTableSource;
        return x;
    }

    public SQLTableSource getResolvedTableSource() {
        return resolvedTableSource;
    }

    public void setResolvedTableSource(SQLTableSource resolvedTableSource) {
        this.resolvedTableSource = resolvedTableSource;
    }

   override
    public List!SQLObject getChildren() {
        return Collections.emptyList!(SQLObject)();
    }
}
