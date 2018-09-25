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
module hunt.sql.ast.expr.SQLNCharExpr;

import hunt.sql.ast.SQLDataType;
import hunt.sql.ast.statement.SQLCharacterDataType;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.expr.SQLTextLiteralExpr;
import hunt.container;
import std.array;
import hunt.sql.util.String;

public class SQLNCharExpr : SQLTextLiteralExpr {
    public static SQLDataType defaultDataType;

    // static this()
    // {
    //     defaultDataType = new SQLCharacterDataType("nvarchar");
    // }
    public this(){

    }

    public this(String text){
        super(text);
    }

    public this(string text){
        super(new String(text));
    }

    override public void output(StringBuffer buf) {
        if ((this.text is null) || (this.text.length == 0)) {
            buf.append("NULL");
            return;
        }

        buf.append("N'");
        buf.append(this.text.str.replace("'", "''"));
        buf.append("'");
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        visitor.visit(this);
        visitor.endVisit(this);
    }

    override public SQLNCharExpr clone() {
        return new SQLNCharExpr(text);
    }

    override public SQLDataType computeDataType() {
        return defaultDataType;
    }
}
