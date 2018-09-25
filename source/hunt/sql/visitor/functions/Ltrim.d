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
module hunt.sql.visitor.functions.Ltrim;

// import hunt.sql.visitor.SQLEvalVisitor.EVAL_VALUE;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.expr.SQLMethodInvokeExpr;
import hunt.sql.visitor.SQLEvalVisitor;
import hunt.sql.visitor.functions.Function;
import hunt.math;
import hunt.sql.util.String;
import hunt.util.string;
import hunt.container;
import std.conv;
import std.uni;
import hunt.sql.parser.CharTypes;

public class Ltrim : Function {

    public  static Ltrim instance;

    // static this()
    // {
    //     instance = new Ltrim();
    // }

    public Object eval(SQLEvalVisitor visitor, SQLMethodInvokeExpr x) {
        if (x.getParameters().size() != 1) {
            return cast(Object)(SQLEvalVisitor.EVAL_ERROR);
        }

        SQLExpr param0 = x.getParameters().get(0);
        param0.accept(visitor);

        Object param0Value = param0.getAttributes().get(SQLEvalVisitor.EVAL_VALUE);
        if (param0Value is null) {
            return cast(Object)(SQLEvalVisitor.EVAL_ERROR);
        }

        string strValue = param0Value.toString();
        
        int index = -1;
        for (int i = 0; i < strValue.length; ++i) {
            if (!CharTypes.isWhitespace(charAt(strValue, i))) {
                index = i;
                break;
            }
        }
        
        if (index <= 0) {
            return new String(strValue);
        } else {
            return new String(strValue.substring(index));
        }
    }
}
