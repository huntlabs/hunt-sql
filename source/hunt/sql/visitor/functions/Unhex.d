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
module hunt.sql.visitor.functions.Unhex;

// import hunt.sql.visitor.SQLEvalVisitor.EVAL_EXPR;
// import hunt.sql.visitor.SQLEvalVisitor.EVAL_VALUE;


import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.expr.SQLMethodInvokeExpr;
import hunt.sql.visitor.SQLEvalVisitor;
import hunt.sql.util.HexBin;
import hunt.sql.visitor.functions.Function;
import hunt.math;
import hunt.sql.util.String;
import hunt.util.string;
import hunt.container;
import std.conv;
import std.uni;
public class Unhex : Function {

    public  static Unhex instance;

    // static this()
    // {
    //     instance = new Unhex();
    // }

    public Object eval(SQLEvalVisitor visitor, SQLMethodInvokeExpr x) {
        if (x.getParameters().size() != 1) {
            return cast(Object)(SQLEvalVisitor.EVAL_ERROR);
        }

        SQLExpr param0 = x.getParameters().get(0);

        if (cast(SQLMethodInvokeExpr)(param0) !is null) {
            SQLMethodInvokeExpr paramMethodExpr = cast(SQLMethodInvokeExpr) param0;
            if (paramMethodExpr.getMethodName().equalsIgnoreCase("hex")) {
                SQLExpr subParamExpr = paramMethodExpr.getParameters().get(0);
                subParamExpr.accept(visitor);

                Object param0Value = subParamExpr.getAttributes().get(SQLEvalVisitor.EVAL_VALUE);
                if (param0Value is null) {
                    x.putAttribute(SQLEvalVisitor.EVAL_EXPR,cast(Object)subParamExpr);
                    return cast(Object)(SQLEvalVisitor.EVAL_ERROR);
                }

                return param0Value;
            }
        }

        param0.accept(visitor);

        Object param0Value = param0.getAttributes().get(SQLEvalVisitor.EVAL_VALUE);
        if (param0Value is null) {
            return cast(Object)(SQLEvalVisitor.EVAL_ERROR);
        }

        if (cast(String)(param0Value) !is null) {
            byte[] bytes = HexBin.decode((cast(String) param0Value).str);
            if (bytes is null) {
                return cast(Object)(SQLEvalVisitor.EVAL_VALUE_NULL);
            }
            
            string result;
            try {
                result = cast(string)(bytes);
            } catch (Exception e) {
                throw new Exception(e.msg, e);
            }
            return new String(result);
        }

        return cast(Object)(SQLEvalVisitor.EVAL_ERROR);
    }
}
