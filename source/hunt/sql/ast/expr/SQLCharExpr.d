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
module hunt.sql.ast.expr.SQLCharExpr;

import hunt.sql.SQLUtils;
import hunt.sql.ast.SQLDataType;
import hunt.sql.ast.SQLObject;
import hunt.sql.ast.statement.SQLCharacterDataType;
import hunt.sql.visitor.SQLASTOutputVisitor;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.expr.SQLTextLiteralExpr;
import hunt.sql.ast.expr.SQLValuableExpr;
import hunt.collection;
import hunt.sql.util.MyString;
import hunt.String;
import hunt.util.Common;
//import hunt.lang;

public class SQLCharExpr : SQLTextLiteralExpr , SQLValuableExpr{
    public static  SQLDataType DEFAULT_DATA_TYPE;

    // static this()
    // {
    //     DEFAULT_DATA_TYPE = new SQLCharacterDataType("varchar");
    // }
    public this(){

    }

    public this(String text){
        super(text);
    }

    // public this(String text){
    //     super(new MyString(text.value));
    // }

    public this(string text){
        super(new MyString(text));
    }

    override public void output(StringBuffer buf) {
        output(cast(Appendable) buf);
    }

    public void output(Appendable buf) {
        this.accept(new SQLASTOutputVisitor(buf));
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        visitor.visit(this);
        visitor.endVisit(this);
    }

    override
    public Object getValue() {
        return this.text;
    }
    
    override public string toString() {
        return SQLUtils.toSQLString(this);
    }

    override public SQLCharExpr clone() {
        return new SQLCharExpr(this.text);
    }

    override public SQLDataType computeDataType() {
        return DEFAULT_DATA_TYPE;
    }

    override public List!SQLObject getChildren() {
        return Collections.emptyList!(SQLObject)();
    }
}
