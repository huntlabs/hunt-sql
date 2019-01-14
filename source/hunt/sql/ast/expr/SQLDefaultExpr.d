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
module hunt.sql.ast.expr.SQLDefaultExpr;

import hunt.sql.ast.SQLExprImpl;
import hunt.sql.ast.SQLObject;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.expr.SQLLiteralExpr;
import hunt.collection;

public class SQLDefaultExpr : SQLExprImpl , SQLLiteralExpr {

   override
    public bool opEquals(Object o) {
        return cast(SQLDefaultExpr)o !is null;
    }

   override
    public size_t toHash() @trusted nothrow {
        return 0;
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        visitor.visit(this);
        visitor.endVisit(this);
    }

    override public string toString() {
        return "DEFAULT";
    }

    override public SQLDefaultExpr clone() {
        return new SQLDefaultExpr();
    }

    override public List!SQLObject getChildren() {
        return Collections.emptyList!(SQLObject)();
    }
}
