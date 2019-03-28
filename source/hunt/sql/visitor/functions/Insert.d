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
module hunt.sql.visitor.functions.Insert;

// import hunt.sql.visitor.SQLEvalVisitor.EVAL_VALUE;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.expr.SQLMethodInvokeExpr;
import hunt.sql.visitor.SQLEvalVisitor;
import hunt.sql.visitor.functions.Function;
import hunt.Number;
import hunt.sql.util.MyString;
import hunt.String;
import hunt.collection;
import std.conv;
import std.uni;
import hunt.text;

public class Insert : Function {

    public  static Insert instance;
    // static this()
    // {
    //     instance = new Insert();
    // }

    public Object eval(SQLEvalVisitor visitor, SQLMethodInvokeExpr x) {
        if (x.getParameters().size() != 4) {
            return cast(Object)(SQLEvalVisitor.EVAL_ERROR);
        }

        SQLExpr param0 = x.getParameters().get(0);
        SQLExpr param1 = x.getParameters().get(1);
        SQLExpr param2 = x.getParameters().get(2);
        SQLExpr param3 = x.getParameters().get(3);
        param0.accept(visitor);
        param1.accept(visitor);
        param2.accept(visitor);
        param3.accept(visitor);

        Object param0Value = param0.getAttributes().get(SQLEvalVisitor.EVAL_VALUE);
        Object param1Value = param1.getAttributes().get(SQLEvalVisitor.EVAL_VALUE);
        Object param2Value = param2.getAttributes().get(SQLEvalVisitor.EVAL_VALUE);
        Object param3Value = param3.getAttributes().get(SQLEvalVisitor.EVAL_VALUE);

        if (!(cast(MyString)(param0Value) !is null)) {
            return cast(Object)(SQLEvalVisitor.EVAL_ERROR);
        }
        if (!(cast(Number)(param1Value) !is null)) {
            return cast(Object)(SQLEvalVisitor.EVAL_ERROR);
        }
        if (!(cast(Number)(param2Value) !is null)) {
            return cast(Object)(SQLEvalVisitor.EVAL_ERROR);
        }
        if (!(cast(MyString)(param3Value) !is null)) {
            return cast(Object)(SQLEvalVisitor.EVAL_ERROR);
        }

        string str = (cast(MyString) param0Value).value();
        int pos = (cast(Number) param1Value).intValue();
        int len = (cast(Number) param2Value).intValue();
        string newstr = (cast(MyString) param3Value).value();
        
        if (pos <= 0) {
            return new MyString(str);
        }
        
        if (pos == 1) {
            if (len > str.length) {
                return new MyString(newstr);
            }
            return new MyString(newstr ~ str.substring(len));
        }
        
        string first = str.substring(0, pos - 1);
        if (pos + len - 1 > str.length) {
            return new MyString(first ~ newstr);
        }
        
        return new MyString(first ~ newstr ~ str.substring(pos + len - 1));
    }
}
