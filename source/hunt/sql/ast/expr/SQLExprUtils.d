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
module hunt.sql.ast.expr.SQLExprUtils;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.expr.SQLIdentifierExpr;
import hunt.sql.ast.expr.SQLBinaryOpExpr;
import hunt.sql.ast.expr.SQLLiteralExpr;

public class SQLExprUtils {

    public static bool opEquals(SQLExpr a, SQLExpr b) {
        if (a == b) {
            return true;
        }

        if (a is null || b is null) {
            return false;
        }

        auto clazz_a = typeid(a);
        auto clazz_b = typeid(b);
        if (clazz_a != clazz_b) {
            return false;
        }

        if (clazz_a == typeid(SQLIdentifierExpr)) {
            SQLIdentifierExpr x_a = cast(SQLIdentifierExpr) a;
            SQLIdentifierExpr x_b = cast(SQLIdentifierExpr) b;
            return (cast(Object)x_a).toHash() == (cast(Object)x_b).toHash();
        }

        if (clazz_a == typeid(SQLBinaryOpExpr)) {
            SQLBinaryOpExpr x_a = cast(SQLBinaryOpExpr) a;
            SQLBinaryOpExpr x_b = cast(SQLBinaryOpExpr) b;

            return x_a.opEquals(cast(Object)(x_b));
        }

        return (cast(Object)a).opEquals(cast(Object)(b));
    }

    public static bool isLiteralExpr(SQLExpr expr) {
        if (cast(SQLLiteralExpr)expr !is null) {
            return true;
        }
        SQLBinaryOpExpr binary = cast(SQLBinaryOpExpr) expr;
        if (binary !is null) {
            return isLiteralExpr(binary.left) && isLiteralExpr(binary.right);
        }

        return false;
    }
}
