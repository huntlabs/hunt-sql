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
module hunt.sql.visitor.functions.Hex;

// import hunt.sql.visitor.SQLEvalVisitor.EVAL_VALUE;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.expr.SQLMethodInvokeExpr;
import hunt.sql.parser.ParserException;
import hunt.sql.visitor.SQLEvalVisitor;
import hunt.sql.util.HexBin;
import hunt.sql.visitor.functions.Function;
import hunt.Number;
import hunt.Long;
import hunt.String;
import hunt.String;
import hunt.collection;
import std.conv;
import std.uni;

public class Hex : Function {

    public  static Hex instance;

    // static this()
    // {
    //     instance = new Hex();
    // }

    public Object eval(SQLEvalVisitor visitor, SQLMethodInvokeExpr x) {
        if (x.getParameters().size() != 1) {
            throw new ParserException("argument's != 1, " ~ x.getParameters().size().to!string);
        }

        SQLExpr param0 = x.getParameters().get(0);
        param0.accept(visitor);

        Object param0Value = param0.getAttributes().get(SQLEvalVisitor.EVAL_VALUE);
        if (param0Value is null) {
            return cast(Object)(SQLEvalVisitor.EVAL_ERROR);
        }

        if (cast(String)(param0Value) !is null) {
            byte[] bytes = (cast(String) param0Value).getBytes();
            string result = HexBin.encode(bytes);
            return new String(result);
        }

        if (cast(Number)(param0Value) !is null) {
            long value = (cast(Number) param0Value).longValue();
            string result = toUpper(Long.toHexString(value));
            return new String(result);
        }

        return cast(Object)(SQLEvalVisitor.EVAL_ERROR);
    }
}
