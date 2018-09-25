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
module hunt.sql.visitor.SQLEvalVisitorUtils;

import  hunt.sql.visitor.SQLEvalVisitor;
// import  hunt.sql.visitor.cast(Object)(SQLEvalVisitor.EVAL_ERROR);
// import  hunt.sql.visitor.SQLEvalVisitor.EVAL_EXPR;
// import  hunt.sql.visitor.SQLEvalVisitor.EVAL_VALUE;
// import  hunt.sql.visitor.SQLEvalVisitor.EVAL_VALUE_NULL;


import hunt.util.exception;
import hunt.sql.util.String;
import hunt.util.string;
import std.random;
import hunt.container;
import std.uni;
import std.conv;
import std.math;
import std.exception;
import hunt.sql.SQLUtils;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLObject;
import hunt.sql.ast.expr;
import hunt.sql.ast.statement.SQLExprTableSource;
import hunt.sql.ast.statement.SQLSelect;
import hunt.sql.ast.statement.SQLSelectItem;
import hunt.sql.ast.statement.SQLSelectQueryBlock;
// import hunt.sql.dialect.db2.visitor.DB2EvalVisitor;
import hunt.sql.dialect.mysql.visitor.MySqlEvalVisitorImpl;
// import hunt.sql.dialect.oracle.visitor.OracleEvalVisitor;
import hunt.sql.dialect.postgresql.visitor.PGEvalVisitor;
// import hunt.sql.dialect.sqlserver.visitor.SQLServerEvalVisitor;
import hunt.sql.visitor.functions.Ascii;
import hunt.sql.visitor.functions.Bin;
import hunt.sql.visitor.functions.BitLength;
import hunt.sql.visitor.functions.Char;
import hunt.sql.visitor.functions.Concat;
import hunt.sql.visitor.functions.Elt;
import hunt.sql.visitor.functions.Function;
import hunt.sql.visitor.functions.Greatest;
import hunt.sql.visitor.functions.Hex;
import hunt.sql.visitor.functions.If;
import hunt.sql.visitor.functions.Insert;
import hunt.sql.visitor.functions.Instr;
import hunt.sql.visitor.functions.Isnull;
import hunt.sql.visitor.functions.Lcase;
import hunt.sql.visitor.functions.Least;
import hunt.sql.visitor.functions.Left;
import hunt.sql.visitor.functions.Length;
import hunt.sql.visitor.functions.Locate;
import hunt.sql.visitor.functions.Lpad;
import hunt.sql.visitor.functions.Ltrim;
import hunt.sql.visitor.functions.Now;
import hunt.sql.visitor.functions.OneParamFunctions;
import hunt.sql.visitor.functions.Reverse;
import hunt.sql.visitor.functions.Right;
import hunt.sql.visitor.functions.Substring;
import hunt.sql.visitor.functions.Trim;
import hunt.sql.visitor.functions.Ucase;
import hunt.sql.visitor.functions.Unhex;
import hunt.sql.util.HexBin;
import hunt.sql.util.DBType;
import hunt.sql.util.DBType;
import hunt.sql.util.Utils;
// import entity.wall.spi.WallVisitorUtils;
// import entity.wall.spi.WallVisitorUtils.WallConditionContext;
import hunt.sql.visitor.SQLEvalVisitorImpl;
import hunt.math;
import std.datetime;

public class SQLEvalVisitorUtils {

    private static Map!(string, Function) functions;

    static this() {
        functions = new HashMap!(string, Function)();
        registerBaseFunctions();
    }

    public static Object evalExpr(string dbType, string expr, Object[]  parameters...) {
        SQLExpr sqlExpr = SQLUtils.toSQLExpr(expr, dbType);
        return eval(dbType, sqlExpr, parameters);
    }

    public static Object evalExpr(string dbType, string expr, List!(Object) parameters) {
        SQLExpr sqlExpr = SQLUtils.toSQLExpr(expr);
        return eval(dbType, sqlExpr, parameters);
    }

    public static Object eval(string dbType, SQLObject sqlObject, Object[] parameters...) {
        List!Object ls = new ArrayList!Object();
        // ls.addAll(parameters);
        foreach(Object o ; parameters)
            ls.add(o);

        Object value = eval(dbType, sqlObject, ls);

        if (value == SQLEvalVisitor.EVAL_VALUE_NULL) {
            value = null;
        }

        return value;
    }

    public static Object getValue(SQLObject sqlObject) {
        if (cast(SQLNumericLiteralExpr)(sqlObject) !is null) {
            return (cast(SQLNumericLiteralExpr) sqlObject).getNumber();
        }

        return sqlObject.getAttributes().get(SQLEvalVisitor.EVAL_VALUE);
    }

    public static Object eval(string dbType, SQLObject sqlObject, List!(Object) parameters) {
        return eval(dbType, sqlObject, parameters, true);
    }

    public static Object eval(string dbType, SQLObject sqlObject, List!(Object) parameters, bool throwError) {
        SQLEvalVisitor visitor = createEvalVisitor(dbType);
        visitor.setParameters(parameters);

        Object value;
        if (cast(SQLValuableExpr)(sqlObject) !is null) {
            value = (cast(SQLValuableExpr) sqlObject).getValue();
        } else {
            sqlObject.accept(visitor);
  
            value = getValue(sqlObject);

            if (value is null) {
                if (throwError && !sqlObject.getAttributes().containsKey(SQLEvalVisitor.EVAL_VALUE)) {
                    throw new Exception("eval error : " ~ SQLUtils.toSQLString(sqlObject, dbType));
                }
            }
        }

        return value;
    }

    public static SQLEvalVisitor createEvalVisitor(string dbType) {
        if (DBType.MYSQL.opEquals(dbType)) {
            return new MySqlEvalVisitorImpl();
        }

        if (DBType.MARIADB.opEquals(dbType)) {
            return new MySqlEvalVisitorImpl();
        }

        if (DBType.H2.opEquals(dbType)) {
            return new MySqlEvalVisitorImpl();
        }

        // if (DBType.ORACLE.opEquals(dbType) || DBType.ALI_ORACLE.opEquals(dbType)) {
        //     return new OracleEvalVisitor();
        // }

        if (DBType.POSTGRESQL.opEquals(dbType)
                || DBType.ENTERPRISEDB.opEquals(dbType)) {
            return new PGEvalVisitor();
        }

        // if (DBType.SQL_SERVER.opEquals(dbType) || DBType.JTDS.opEquals(dbType)) {
        //     return new SQLServerEvalVisitor();
        // }

        // if (DBType.DB2.opEquals(dbType)) {
        //     return new DB2EvalVisitor();
        // }

        return new SQLEvalVisitorImpl();
    }

    static void registerBaseFunctions() {
        functions.put("now", Now.instance);
        functions.put("concat", Concat.instance);
        functions.put("concat_ws", Concat.instance);
        functions.put("ascii", Ascii.instance);
        functions.put("bin", Bin.instance);
        functions.put("bit_length", BitLength.instance);
        functions.put("insert", Insert.instance);
        functions.put("instr", Instr.instance);
        functions.put("char", Char.instance);
        functions.put("elt", Elt.instance);
        functions.put("left", Left.instance);
        functions.put("locate", Locate.instance);
        functions.put("lpad", Lpad.instance);
        functions.put("ltrim", Ltrim.instance);
        functions.put("mid", Substring.instance);
        functions.put("substr", Substring.instance);
        functions.put("substring", Substring.instance);
        functions.put("right", Right.instance);
        functions.put("reverse", Reverse.instance);
        functions.put("len", Length.instance);
        functions.put("length", Length.instance);
        functions.put("char_length", Length.instance);
        functions.put("character_length", Length.instance);
        functions.put("trim", Trim.instance);
        functions.put("ucase", Ucase.instance);
        functions.put("upper", Ucase.instance);
        functions.put("lcase", Lcase.instance);
        functions.put("lower", Lcase.instance);
        functions.put("hex", Hex.instance);
        functions.put("unhex", Unhex.instance);
        functions.put("greatest", Greatest.instance);
        functions.put("least", Least.instance);
        functions.put("isnull", Isnull.instance);
        functions.put("if", If.instance);

        functions.put("md5", OneParamFunctions.instance);
        functions.put("bit_count", OneParamFunctions.instance);
        functions.put("soundex", OneParamFunctions.instance);
        functions.put("space", OneParamFunctions.instance);
    }

    public static bool visit(SQLEvalVisitor visitor, SQLMethodInvokeExpr x) {
        string methodName =toLower(x.getMethodName());

        Function function_p = visitor.getFunction(methodName);

        if (function_p is null) {
            function_p = functions.get(methodName);
        }

        if (function_p !is null) {
            Object result = function_p.eval(visitor, x);

            if (result != SQLEvalVisitor.EVAL_ERROR) {
                x.getAttributes().put(SQLEvalVisitor.EVAL_VALUE, result);
            }
            return false;
        }

        if ("mod" == (methodName)) {
            if (x.getParameters().size() != 2) {
                return false;
            }

            SQLExpr param0 = x.getParameters().get(0);
            SQLExpr param1 = x.getParameters().get(1);
            param0.accept(visitor);
            param1.accept(visitor);

            Object param0Value = param0.getAttributes().get(SQLEvalVisitor.EVAL_VALUE);
            Object param1Value = param1.getAttributes().get(SQLEvalVisitor.EVAL_VALUE);
            if (param0Value is null || param1Value is null) {
                return false;
            }

            Long intValue0 = castToLong(param0Value);
            Long intValue1 = castToLong(param1Value);

            long result = intValue0.longValue % intValue1.longValue;
            if (result >= Integer.MIN_VALUE && result <= Integer.MAX_VALUE) {
                int intResult = cast(int) result;
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, new Integer(intResult));
            } else {
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, new Long(result));
            }
        } else if ("abs" == (methodName)) {
            if (x.getParameters().size() != 1) {
                return false;
            }

            SQLExpr param0 = x.getParameters().get(0);
            param0.accept(visitor);

            Object paramValue = param0.getAttributes().get(SQLEvalVisitor.EVAL_VALUE);
            if (paramValue is null) {
                return false;
            }

            Object result;
            if (cast(Integer)(paramValue) !is null) {
                result = new Integer(abs((cast(Integer) paramValue).intValue()));
            } else if (cast(Long)(paramValue) !is null) {
                result = new Long(abs((cast(Long) paramValue).longValue()));
            } else {
                // result = new BigDecimal(abs(castToDecimal(paramValue)));//@gxc
            }

            x.putAttribute(SQLEvalVisitor.EVAL_VALUE, result);
        } else if ("acos" == (methodName)) {
            if (x.getParameters().size() != 1) {
                return false;
            }

            SQLExpr param0 = x.getParameters().get(0);
            param0.accept(visitor);

            Object paramValue = param0.getAttributes().get(SQLEvalVisitor.EVAL_VALUE);
            if (paramValue is null) {
                return false;
            }

            auto dv = castToDouble(paramValue);
            double result = acos(dv.doubleValue);

            if (isNaN(result)) {
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, null);
            } else {
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, new Double(result));
            }
        } else if ("asin" == (methodName)) {
            if (x.getParameters().size() != 1) {
                return false;
            }

            SQLExpr param0 = x.getParameters().get(0);
            param0.accept(visitor);

            Object paramValue = param0.getAttributes().get(SQLEvalVisitor.EVAL_VALUE);
            if (paramValue is null) {
                return false;
            }

            auto dv = castToDouble(paramValue);
            double result = asin(dv.doubleValue);

            if (isNaN(result)) {
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, null);
            } else {
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, new Double(result));
            }
        } else if ("atan" == (methodName)) {
            if (x.getParameters().size() != 1) {
                return false;
            }

            SQLExpr param0 = x.getParameters().get(0);
            param0.accept(visitor);

            Object paramValue = param0.getAttributes().get(SQLEvalVisitor.EVAL_VALUE);
            if (paramValue is null) {
                return false;
            }

            auto dv = castToDouble(paramValue);
            double result = atan(dv.doubleValue);

            if (isNaN(result)) {
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, null);
            } else {
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, new Double(result));
            }
        } else if ("atan2" == (methodName)) {
            if (x.getParameters().size() != 2) {
                return false;
            }

            SQLExpr param0 = x.getParameters().get(0);
            SQLExpr param1 = x.getParameters().get(1);
            param0.accept(visitor);
            param1.accept(visitor);

            Object param0Value = param0.getAttributes().get(SQLEvalVisitor.EVAL_VALUE);
            Object param1Value = param1.getAttributes().get(SQLEvalVisitor.EVAL_VALUE);
            if (param0Value is null || param1Value is null) {
                return false;
            }

            auto doubleValue0 = castToDouble(param0Value);
            auto doubleValue1 = castToDouble(param1Value);
            double result = atan2(doubleValue0.doubleValue, doubleValue1.doubleValue);

            if (isNaN(result)) {
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, null);
            } else {
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, new Double(result));
            }
        } else if ("ceil" == (methodName) || "ceiling" == (methodName)) {
            if (x.getParameters().size() != 1) {
                return false;
            }

            SQLExpr param0 = x.getParameters().get(0);
            param0.accept(visitor);

            Object paramValue = param0.getAttributes().get(SQLEvalVisitor.EVAL_VALUE);
            if (paramValue is null) {
                return false;
            }

            auto dv = castToDouble(paramValue);
            int result = cast(int) ceil(dv.doubleValue);

            if (result == int.init) {
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, null);
            } else {
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, new Integer(result));
            }
        } else if ("cos" == (methodName)) {
            if (x.getParameters().size() != 1) {
                return false;
            }

            SQLExpr param0 = x.getParameters().get(0);
            param0.accept(visitor);

            Object paramValue = param0.getAttributes().get(SQLEvalVisitor.EVAL_VALUE);
            if (paramValue is null) {
                return false;
            }

            auto dv = castToDouble(paramValue);
            double result = cos(dv.doubleValue);

            if (isNaN(result)) {
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, null);
            } else {
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, new Double(result));
            }
        } else if ("sin" == (methodName)) {
            if (x.getParameters().size() != 1) {
                return false;
            }

            SQLExpr param0 = x.getParameters().get(0);
            param0.accept(visitor);

            Object paramValue = param0.getAttributes().get(SQLEvalVisitor.EVAL_VALUE);
            if (paramValue is null) {
                return false;
            }

            auto dv = castToDouble(paramValue);
            double result = sin(dv.doubleValue);

            if (isNaN(result)) {
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, null);
            } else {
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, new Double(result));
            }
        } else if ("log" == (methodName)) {
            if (x.getParameters().size() != 1) {
                return false;
            }

            SQLExpr param0 = x.getParameters().get(0);
            param0.accept(visitor);

            Object paramValue = param0.getAttributes().get(SQLEvalVisitor.EVAL_VALUE);
            if (paramValue is null) {
                return false;
            }

            auto dv = castToDouble(paramValue);
            double result = log(dv.doubleValue);

            if (isNaN(result)) {
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, null);
            } else {
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, new Double(result));
            }
        } else if ("log10" == (methodName)) {
            if (x.getParameters().size() != 1) {
                return false;
            }

            SQLExpr param0 = x.getParameters().get(0);
            param0.accept(visitor);

            Object paramValue = param0.getAttributes().get(SQLEvalVisitor.EVAL_VALUE);
            if (paramValue is null) {
                return false;
            }

            auto dv = castToDouble(paramValue);
            double result = log10(dv.doubleValue);

            if (isNaN(result)) {
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, null);
            } else {
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, new Double(result));
            }
        } else if ("tan" == (methodName)) {
            if (x.getParameters().size() != 1) {
                return false;
            }

            SQLExpr param0 = x.getParameters().get(0);
            param0.accept(visitor);

            Object paramValue = param0.getAttributes().get(SQLEvalVisitor.EVAL_VALUE);
            if (paramValue is null) {
                return false;
            }

            auto dv = castToDouble(paramValue);
            double result = tan(dv.doubleValue);

            if (isNaN(result)) {
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, null);
            } else {
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, new Double(result));
            }
        } else if ("sqrt" == (methodName)) {
            if (x.getParameters().size() != 1) {
                return false;
            }

            SQLExpr param0 = x.getParameters().get(0);
            param0.accept(visitor);

            Object paramValue = param0.getAttributes().get(SQLEvalVisitor.EVAL_VALUE);
            if (paramValue is null) {
                return false;
            }

            auto dv = castToDouble(paramValue);
            double result = sqrt(dv.doubleValue);

            if (isNaN!double(result)) {
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, null);
            } else {
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, new Double(result));
            }
        } else if ("power" == (methodName) || "pow" == (methodName)) {
            if (x.getParameters().size() != 2) {
                return false;
            }

            SQLExpr param0 = x.getParameters().get(0);
            SQLExpr param1 = x.getParameters().get(1);
            param0.accept(visitor);
            param1.accept(visitor);

            Object param0Value = param0.getAttributes().get(SQLEvalVisitor.EVAL_VALUE);
            Object param1Value = param1.getAttributes().get(SQLEvalVisitor.EVAL_VALUE);
            if (param0Value is null || param1Value is null) {
                return false;
            }

            auto doubleValue0 = castToDouble(param0Value);
            auto doubleValue1 = castToDouble(param1Value);
            double result = pow!(double,double)(doubleValue0.doubleValue, doubleValue1.doubleValue);

            if (isNaN!double(result)) {
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, null);
            } else {
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, new Double(result));
            }
        } else if ("pi" == (methodName)) {
            x.putAttribute(SQLEvalVisitor.EVAL_VALUE, new Double(3.1415));
        } else if ("rand" == (methodName)) {
            x.putAttribute(SQLEvalVisitor.EVAL_VALUE, new Double(uniform(0.0f,1000.0f)));
        } else if ("chr" == (methodName) && x.getParameters().size() == 1) {
            SQLExpr first = x.getParameters().get(0);
            Object firstResult = getValue(first);
            if (cast(Number)(firstResult) !is null) {
                int intValue = (cast(Number) firstResult).intValue();
                char ch = cast(char) intValue;
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, new String(ch));
            }
        } else if ("current_user" == (methodName)) {
            x.putAttribute(SQLEvalVisitor.EVAL_VALUE, new String("CURRENT_USER"));
        }
        return false;
    }

    public static bool visit(SQLEvalVisitor visitor, SQLCharExpr x) {
        x.putAttribute(SQLEvalVisitor.EVAL_VALUE, x.getText());
        return true;
    }

    public static bool visit(SQLEvalVisitor visitor, SQLHexExpr x) {
        string hex = x.getHex();
        byte[] bytes = HexBin.decode(hex);
        if (bytes is null) {
            x.putAttribute(SQLEvalVisitor.EVAL_VALUE, cast(Object)(SQLEvalVisitor.EVAL_ERROR));
        } else {
            String val = new String(bytes);
            x.putAttribute(SQLEvalVisitor.EVAL_VALUE, val);
        }
        return true;
    }

    public static bool visit(SQLEvalVisitor visitor, SQLBinaryExpr x) {
        string text = x.getText();

        long[] words = new long[text.length / 64 + 1];
        for (int i = cast(int)(text.length-1); i >= 0 ; --i) {
            char ch = charAt(text, i);
            if (ch == '1') {
                int wordIndex = i >> 6;
                words[wordIndex] |= (1L << (text.length - 1 - i));
            }
        }

        Object val;

        if (words.length == 1) {
            val = new Long(words[0]);
        } else {
            byte[] bytes = new byte[words.length * 8];

            for (int i = 0; i < words.length; ++i) {
                Utils.putLong(bytes, cast(int)(words.length-1-i) * 8, cast(int)words[i]);
            }

            val = new BigInteger(bytes);
        }

        x.putAttribute(SQLEvalVisitor.EVAL_VALUE, val);

        return false;
    }

    public static SQLExpr unwrap(SQLExpr expr) {
        if (expr is null) {
            return null;
        }

        if (cast(SQLQueryExpr)(expr) !is null) {
            SQLSelect select = (cast(SQLQueryExpr) expr).getSubQuery();
            if (select is null) {
                return null;
            }
            if (cast(SQLSelectQueryBlock) select.getQuery() !is null) {
                SQLSelectQueryBlock queryBlock = cast(SQLSelectQueryBlock) select.getQuery();
                if (queryBlock.getFrom() is null) {
                    if (queryBlock.getSelectList().size() == 1) {
                        return queryBlock.getSelectList().get(0).getExpr();
                    }
                }
            }
        }

        return expr;
    }

    public static bool visit(SQLEvalVisitor visitor, SQLBetweenExpr x) {
        SQLExpr testExpr = unwrap(x.getTestExpr());
        testExpr.accept(visitor);

        if (!testExpr.getAttributes().containsKey(SQLEvalVisitor.EVAL_VALUE)) {
            return false;
        }

        Object value = testExpr.getAttribute(SQLEvalVisitor.EVAL_VALUE);

        SQLExpr beginExpr = unwrap(x.getBeginExpr());
        beginExpr.accept(visitor);
        if (!beginExpr.getAttributes().containsKey(SQLEvalVisitor.EVAL_VALUE)) {
            return false;
        }

        Object begin = beginExpr.getAttribute(SQLEvalVisitor.EVAL_VALUE);

        if (lt(value, begin)) {
            x.getAttributes().put(SQLEvalVisitor.EVAL_VALUE, x.isNot() ? Boolean.TRUE : Boolean.FALSE);
            return false;
        }

        SQLExpr endExpr = unwrap(x.getEndExpr());
        endExpr.accept(visitor);
        if (!endExpr.getAttributes().containsKey(SQLEvalVisitor.EVAL_VALUE)) {
            return false;
        }

        Object end = endExpr.getAttribute(SQLEvalVisitor.EVAL_VALUE);

        if (gt(value, end)) {
            x.getAttributes().put(SQLEvalVisitor.EVAL_VALUE, x.isNot() ? Boolean.TRUE : Boolean.FALSE);
            return false;
        }

        x.getAttributes().put(SQLEvalVisitor.EVAL_VALUE, x.isNot() ? Boolean.FALSE : Boolean.TRUE);
        return false;
    }

    public static bool visit(SQLEvalVisitor visitor, SQLNullExpr x) {
        x.getAttributes().put(SQLEvalVisitor.EVAL_VALUE, cast(Object)(SQLEvalVisitor.EVAL_VALUE_NULL));
        return false;
    }

    public static bool visit(SQLEvalVisitor visitor, SQLCaseExpr x) {
        Object value;
        if (x.getValueExpr() !is null) {
            x.getValueExpr().accept(visitor);

            if (!x.getValueExpr().getAttributes().containsKey(SQLEvalVisitor.EVAL_VALUE)) {
                return false;
            }

            value = x.getValueExpr().getAttribute(SQLEvalVisitor.EVAL_VALUE);
        } else {
            value = null;
        }

        foreach(SQLCaseExpr.Item item ; x.getItems()) {
            item.getConditionExpr().accept(visitor);

            if (!item.getConditionExpr().getAttributes().containsKey(SQLEvalVisitor.EVAL_VALUE)) {
                return false;
            }

            Object conditionValue = item.getConditionExpr().getAttribute(SQLEvalVisitor.EVAL_VALUE);

            if ((x.getValueExpr() !is null && eq(value, conditionValue).booleanValue)
                || (x.getValueExpr() is null && cast(Boolean)(conditionValue) !is null && cast(Boolean) conditionValue == Boolean.TRUE)) {
                item.getValueExpr().accept(visitor);

                if (item.getValueExpr().getAttributes().containsKey(SQLEvalVisitor.EVAL_VALUE)) {
                    x.getAttributes().put(SQLEvalVisitor.EVAL_VALUE, item.getValueExpr().getAttribute(SQLEvalVisitor.EVAL_VALUE));
                }

                return false;
            }
        }

        if (x.getElseExpr() !is null) {
            x.getElseExpr().accept(visitor);

            if (x.getElseExpr().getAttributes().containsKey(SQLEvalVisitor.EVAL_VALUE)) {
                x.getAttributes().put(SQLEvalVisitor.EVAL_VALUE, x.getElseExpr().getAttribute(SQLEvalVisitor.EVAL_VALUE));
            }
        }

        return false;
    }

    public static bool visit(SQLEvalVisitor visitor, SQLInListExpr x) {
        SQLExpr valueExpr = x.getExpr();
        valueExpr.accept(visitor);
        if (!valueExpr.getAttributes().containsKey(SQLEvalVisitor.EVAL_VALUE)) {
            return false;
        }
        Object value = valueExpr.getAttribute(SQLEvalVisitor.EVAL_VALUE);

        foreach(SQLExpr item ; x.getTargetList()) {
            item.accept(visitor);
            if (!item.getAttributes().containsKey(SQLEvalVisitor.EVAL_VALUE)) {
                return false;
            }
            Object itemValue = item.getAttribute(SQLEvalVisitor.EVAL_VALUE);
            if (eq(value, itemValue).booleanValue) {
                x.getAttributes().put(SQLEvalVisitor.EVAL_VALUE, x.isNot() ? Boolean.FALSE : Boolean.TRUE);
                return false;
            }
        }

        x.getAttributes().put(SQLEvalVisitor.EVAL_VALUE, x.isNot() ? Boolean.TRUE : Boolean.FALSE);
        return false;
    }

    public static bool visit(SQLEvalVisitor visitor, SQLQueryExpr x) {
        // if (WallVisitorUtils.isSimpleCountTableSource(null, (cast(SQLQueryExpr) x).getSubQuery())) {
        //     x.putAttribute(SQLEvalVisitor.EVAL_VALUE, 1);
        //     return false;
        // }

        if ( cast(SQLSelectQueryBlock) x.getSubQuery().getQuery() !is null) {
            SQLSelectQueryBlock queryBlock = cast(SQLSelectQueryBlock) x.getSubQuery().getQuery();

            bool nullFrom = false;
            if (queryBlock.getFrom() is null) {
                nullFrom = true;
            } else if ((cast(SQLExprTableSource) queryBlock.getFrom()).getExpr() !is null) {
                SQLExpr expr = (cast(SQLExprTableSource) queryBlock.getFrom()).getExpr();
                if (cast(SQLIdentifierExpr)(expr) !is null) {
                    if ("dual".equalsIgnoreCase((cast(SQLIdentifierExpr) expr).getName())) {
                        nullFrom = true;
                    }
                }
            }

            if (nullFrom) {
                List!(Object) row = new ArrayList!(Object)(queryBlock.getSelectList().size());
                for (int i = 0; i < queryBlock.getSelectList().size(); ++i) {
                    SQLSelectItem item = queryBlock.getSelectList().get(i);
                    item.getExpr().accept(visitor);
                    Object cell = item.getExpr().getAttribute(SQLEvalVisitor.EVAL_VALUE);
                    row.add(cell);
                }
                List!(List!Object) rows = new ArrayList!(List!(Object))(1);
                rows.add(row);

                Object result = cast(Object)rows;
                queryBlock.putAttribute(SQLEvalVisitor.EVAL_VALUE, result);
                x.getSubQuery().putAttribute(SQLEvalVisitor.EVAL_VALUE, result);
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, result);

                return false;
            }
        }

        return false;
    }

    public static bool visit(SQLEvalVisitor visitor, SQLUnaryExpr x) {
        //  WallConditionContext wallConditionContext = WallVisitorUtils.getWallConditionContext();
        // if (x.getOperator() == SQLUnaryOperator.Compl && wallConditionContext !is null) {
        //     wallConditionContext.setBitwise(true);
        // }

        x.getExpr().accept(visitor);

        Object val = x.getExpr().getAttribute(SQLEvalVisitor.EVAL_VALUE);
        if (val == SQLEvalVisitor.EVAL_ERROR) {
            x.putAttribute(SQLEvalVisitor.EVAL_VALUE, cast(Object)(SQLEvalVisitor.EVAL_ERROR));
            return false;
        }

        if (val is null) {
            x.putAttribute(SQLEvalVisitor.EVAL_VALUE, cast(Object)(SQLEvalVisitor.EVAL_VALUE_NULL));
            return false;
        }

        switch (x.getOperator().name) {
            case SQLUnaryOperator.BINARY.name:
            case SQLUnaryOperator.RAW.name:
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, val);
                break;
            case SQLUnaryOperator.NOT.name:
            case SQLUnaryOperator.Not.name: {
                Boolean bl = castToBoolean(val);
                if (bl !is null) {
                    x.putAttribute(SQLEvalVisitor.EVAL_VALUE, new Boolean(!(bl.booleanValue)));
                }
                break;
            }
            case SQLUnaryOperator.Plus.name:
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, val);
                break;
            case SQLUnaryOperator.Negative.name:
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, multi(val, new Integer(-1)));
                break;
            case SQLUnaryOperator.Compl.name:
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, new Integer(~castToInteger(val).intValue));
                break;
            default:
                break;
        }

        return false;
    }

    public static bool visit(SQLEvalVisitor visitor, SQLBinaryOpExpr x) {
        SQLExpr left = unwrap(x.getLeft());
        SQLExpr right = unwrap(x.getRight());

        //  WallConditionContext old = wallConditionContextLocal.get();

        left.accept(visitor);
        right.accept(visitor);

        //  WallConditionContext wallConditionContext = WallVisitorUtils.getWallConditionContext();
        // if (x.getOperator() == SQLBinaryOperator.BooleanOr) {
        //     if (wallConditionContext !is null) {
        //         if (left.getAttribute(SQLEvalVisitor.EVAL_VALUE) == Boolean.TRUE || right.getAttribute(SQLEvalVisitor.EVAL_VALUE) == Boolean.TRUE) {
        //             wallConditionContext.setPartAlwayTrue(true);
        //         }
        //     }
        // } else if (x.getOperator() == SQLBinaryOperator.BooleanAnd) {
        //     if (wallConditionContext !is null) {
        //         if (left.getAttribute(SQLEvalVisitor.EVAL_VALUE) == Boolean.FALSE || right.getAttribute(SQLEvalVisitor.EVAL_VALUE) == Boolean.FALSE) {
        //             wallConditionContext.setPartAlwayFalse(true);
        //         }
        //     }
        // } else if (x.getOperator() == SQLBinaryOperator.BooleanXor) {
        //     if (wallConditionContext !is null) {
        //         wallConditionContext.setXor(true);
        //     }
        // } else if (x.getOperator() == SQLBinaryOperator.BitwiseAnd //
        //            || x.getOperator() == SQLBinaryOperator.BitwiseNot //
        //            || x.getOperator() == SQLBinaryOperator.BitwiseOr //
        //            || x.getOperator() == SQLBinaryOperator.BitwiseXor) {
        //     if (wallConditionContext !is null) {
        //         wallConditionContext.setBitwise(true);
        //     }
        // }

        Object leftValue = left.getAttribute(SQLEvalVisitor.EVAL_VALUE);
        Object rightValue = right.getAttributes().get(SQLEvalVisitor.EVAL_VALUE);

        if (x.getOperator() == SQLBinaryOperator.Like) {
            if (isAlwayTrueLikePattern(x.getRight())) {
                // x.putAttribute(WallVisitorUtils.HAS_TRUE_LIKE, Boolean.TRUE);
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, Boolean.TRUE);
                return false;
            }
        }

        if (x.getOperator() == SQLBinaryOperator.NotLike) {
            if (isAlwayTrueLikePattern(x.getRight())) {
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, Boolean.FALSE);
                return false;
            }
        }

        bool leftHasValue = left.getAttributes().containsKey(SQLEvalVisitor.EVAL_VALUE);
        bool rightHasValue = right.getAttributes().containsKey(SQLEvalVisitor.EVAL_VALUE);

        if ((!leftHasValue) && !rightHasValue) {
            SQLExpr leftEvalExpr = cast(SQLExpr) left.getAttribute(SQLEvalVisitor.EVAL_EXPR);
            SQLExpr rightEvalExpr = cast(SQLExpr) right.getAttribute(SQLEvalVisitor.EVAL_EXPR);

            if (leftEvalExpr !is null && (cast(Object)leftEvalExpr).opEquals(cast(Object)rightEvalExpr)) {
                switch (x.getOperator().name) {
                    case SQLBinaryOperator.Like.name:
                    case SQLBinaryOperator.Equality.name:
                    case SQLBinaryOperator.GreaterThanOrEqual.name:
                    case SQLBinaryOperator.LessThanOrEqual.name:
                    case SQLBinaryOperator.NotLessThan.name:
                    case SQLBinaryOperator.NotGreaterThan.name:
                        x.putAttribute(SQLEvalVisitor.EVAL_VALUE, Boolean.TRUE);
                        return false;
                    case SQLBinaryOperator.NotEqual.name:
                    case SQLBinaryOperator.NotLike.name:
                    case SQLBinaryOperator.GreaterThan.name:
                    case SQLBinaryOperator.LessThan.name:
                        x.putAttribute(SQLEvalVisitor.EVAL_VALUE, Boolean.FALSE);
                        return false;
                    default:
                        break;
                }
            }
        }

        if (!leftHasValue) {
            return false;
        }

        if (!rightHasValue) {
            return false;
        }

        // if (wallConditionContext !is null) {
        //     wallConditionContext.setConstArithmetic(true);
        // }

        leftValue = processValue(leftValue);
        rightValue = processValue(rightValue);

        if (leftValue is null || rightValue is null) {
            return false;
        }

        Object value = null;
        switch (x.getOperator().name) {
            case SQLBinaryOperator.Add.name:
                value = add(leftValue, rightValue);
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, value);
                break;
            case SQLBinaryOperator.Subtract.name:
                value = sub(leftValue, rightValue);
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, value);
                break;
            case SQLBinaryOperator.Multiply.name:
                value = multi(leftValue, rightValue);
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, value);
                break;
            case SQLBinaryOperator.Divide.name:
                value = div(leftValue, rightValue);
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, value);
                break;
            case SQLBinaryOperator.RightShift.name:
                value = rightShift(leftValue, rightValue);
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, value);
                break;
            case SQLBinaryOperator.BitwiseAnd.name:
                value = bitAnd(leftValue, rightValue);
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, value);
                break;
            case SQLBinaryOperator.BitwiseOr.name:
                value = bitOr(leftValue, rightValue);
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, value);
                break;
            case SQLBinaryOperator.GreaterThan.name:
                value = gt(leftValue, rightValue);
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, value);
                break;
            case SQLBinaryOperator.GreaterThanOrEqual.name:
                value = gteq(leftValue, rightValue);
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, value);
                break;
            case SQLBinaryOperator.LessThan.name:
                value = lt(leftValue, rightValue);
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, value);
                break;
            case SQLBinaryOperator.LessThanOrEqual.name:
                value = lteq(leftValue, rightValue);
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, value);
                break;
            case SQLBinaryOperator.Is.name:
                if (rightValue == SQLEvalVisitor.EVAL_VALUE_NULL) {
                    if (leftValue !is null) {
                        value = new Boolean(leftValue == SQLEvalVisitor.EVAL_VALUE_NULL);
                        x.putAttribute(SQLEvalVisitor.EVAL_VALUE, value);
                        break;
                    }
                }
                break;
            case SQLBinaryOperator.Equality.name:
                value = eq(leftValue, rightValue);
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, value);
                break;
            case SQLBinaryOperator.NotEqual.name:
                value = new Boolean(!(eq(leftValue, rightValue).booleanValue));
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, value);
                break;
            case SQLBinaryOperator.IsNot.name:
                if (leftValue == SQLEvalVisitor.EVAL_VALUE_NULL) {
                    x.putAttribute(SQLEvalVisitor.EVAL_VALUE, new Boolean(false));
                } else if (leftValue !is null) {
                    x.putAttribute(SQLEvalVisitor.EVAL_VALUE, new Boolean(true));
                }
                break;
            case SQLBinaryOperator.RegExp.name:
            case SQLBinaryOperator.RLike.name: {
                string pattern = castToString(rightValue);
                string input = castToString(left.getAttributes().get(SQLEvalVisitor.EVAL_VALUE));
                bool matchResult = Utils.matches(pattern, input);
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, new Boolean(matchResult));
                break;
            }
            case SQLBinaryOperator.NotRegExp.name:
            case SQLBinaryOperator.NotRLike.name: {
                string pattern = castToString(rightValue);
                string input = castToString(left.getAttributes().get(SQLEvalVisitor.EVAL_VALUE));
                bool matchResult = !Utils.matches(pattern, input);
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, new Boolean(matchResult));
                break;
            }
            case SQLBinaryOperator.Like.name: {
                string pattern = castToString(rightValue);
                string input = castToString(left.getAttributes().get(SQLEvalVisitor.EVAL_VALUE));
                auto matchResult = like(input, pattern);
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, (matchResult));
                break;
            }
            case SQLBinaryOperator.NotLike.name: {
                string pattern = castToString(rightValue);
                string input = castToString(left.getAttributes().get(SQLEvalVisitor.EVAL_VALUE));
                bool matchResult = !(like(input, pattern).booleanValue);
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE,new Boolean(matchResult));
                break;
            }
            case SQLBinaryOperator.Concat.name: {
                string result = (cast(Object)(leftValue)).toString() ~ (cast(Object)(rightValue)).toString();
                x.putAttribute(SQLEvalVisitor.EVAL_VALUE, new String(result));
                break;
            }
            case SQLBinaryOperator.BooleanAnd.name:
            {
            	bool first = eq(leftValue, Boolean.TRUE).booleanValue;
            	bool second = eq(rightValue, Boolean.TRUE).booleanValue;
            	x.putAttribute(SQLEvalVisitor.EVAL_VALUE, new Boolean(first&&second));
            	break;
            }
            case SQLBinaryOperator.BooleanOr.name:
            {
            	bool first = eq(leftValue, Boolean.TRUE).booleanValue;
            	bool second = eq(rightValue, Boolean.TRUE).booleanValue;
            	x.putAttribute(SQLEvalVisitor.EVAL_VALUE, new Boolean(first||second));
            	break;
            }
            default:
                break;
        }

        return false;
    }

    //@SuppressWarnings("rawtypes")
    private static Object processValue(Object value) {
        if (cast(List!Object)(value) !is null) {
            List!Object list = cast(List!Object) value;
            if (list.size() == 1) {
                return processValue(list.get(0));
            }
         } //else if (cast(Date)(value) !is null) {
        //     return (cast(Date) value).getTime();
        // }//@gxc
        return value;
    }

    private static bool isAlwayTrueLikePattern(SQLExpr x) {
        if (cast(SQLCharExpr)(x) !is null) {
            string text = (cast(SQLCharExpr) x).getText().str;

            if (text.length > 0) {
                foreach(char ch ; text) {
                    if (ch != '%') {
                        return false;
                    }
                }
                return true;
            }
        }
        return false;
    }

    public static bool visit(SQLEvalVisitor visitor, SQLNumericLiteralExpr x) {
        x.getAttributes().put(SQLEvalVisitor.EVAL_VALUE, x.getNumber());
        return false;
    }

    public static bool visit(SQLEvalVisitor visitor, SQLVariantRefExpr x) {
        if (!("?" == x.getName())) {
            return false;
        }

        Map!(string, Object) attributes = x.getAttributes();

        int varIndex = x.getIndex();

        if (varIndex != -1 && visitor.getParameters().size() > varIndex) {
            bool containsValue = attributes.containsKey(SQLEvalVisitor.EVAL_VALUE);
            if (!containsValue) {
                Object value = visitor.getParameters().get(varIndex);
                if (value is null) {
                    value = cast(Object)(SQLEvalVisitor.EVAL_VALUE_NULL);
                }
                attributes.put(SQLEvalVisitor.EVAL_VALUE, value);
            }
        }

        return false;
    }

    public static Boolean castToBoolean(Object val) {
        if (val is null) {
            return null;
        }

        if (val == SQLEvalVisitor.EVAL_VALUE_NULL) {
            return null;
        }

        if (cast(Boolean)(val) !is null) {
            return cast(Boolean) val;
        }

        if (cast(Number)(val) !is null) {
            return new Boolean((cast(Number) val).intValue() > 0);
        }

        if (cast(String)(val) !is null) {
            if ("1" == (cast(String)(val)).str || equalsIgnoreCase("true",(cast(String) val).str)) {
                return new Boolean(true);
            }

            return new Boolean(false);
        }

        throw new Exception(typeid(val).name ~ " not supported.");
    }

    public static string castToString(Object val) {
        Object value = val;

        if (value is null) {
            return null;
        }

        return (cast(Object)(value)).toString();
    }

    public static Byte castToByte(Object val) {
        if (val is null) {
            return null;
        }

        if (cast(Byte)(val) !is null) {
            return cast(Byte) val;
        }

        if (cast(String)(val) !is null) {
            return new Byte(Byte.parseByte((cast(String) val).str));
        }

        return new Byte((cast(Number) val).byteValue());
    }

    public static Short castToShort(Object val) {
        if (val is null || val == SQLEvalVisitor.EVAL_VALUE_NULL) {
            return null;
        }

        if (cast(Short)(val) !is null) {
            return cast(Short) val;
        }

        if (cast(String)(val) !is null) {
            return new Short(Short.parseShort((cast(String) val).str));
        }

        return new Short((cast(Number) val).shortValue());
    }

    //@SuppressWarnings("rawtypes")
    public static Integer castToInteger(Object val) {
        if (val is null) {
            return null;
        }

        if (cast(Integer)(val) !is null) {
            return cast(Integer) val;
        }

        if (cast(String)(val) !is null) {
            return new Integer(Integer.parseInt((cast(String) val).str));
        }

        if (cast(List!Object)(val) !is null) {
            List!Object list = cast(List!Object) val;
            if (list.size() == 1) {
                return castToInteger(list.get(0));
            }
        }

        if (cast(Boolean)(val) !is null) {
            if ((cast(Boolean) val).booleanValue()) {
                return new Integer(1);
            } else {
                return new Integer(0);
            }
        }

        if (cast(Number)(val) !is null) {
            return new Integer((cast(Number) val).intValue());
        }

        throw new Exception("cast error");
    }

    //@SuppressWarnings("rawtypes")
    public static Long castToLong(Object val) {
        if (val is null) {
            return null;
        }

        if (cast(Long)(val) !is null) {
            return cast(Long) val;
        }

        if (cast(String)(val) !is null) {
            return new Long(Long.parseLong((cast(String) val).str));
        }

        if (cast(List!Object)(val) !is null) {
            List!Object list = cast(List!Object) val;
            if (list.size() == 1) {
                return castToLong(list.get(0));
            }
        }

        if (cast(Boolean)(val) !is null) {
            if ((cast(Boolean) val).booleanValue()) {
                return new Long(1L);
            } else {
                return new Long(0L);
            }
        }

        return new Long((cast(Number) val).longValue());
    }

    public static Float castToFloat(Object val) {
        if (val is null || val == SQLEvalVisitor.EVAL_VALUE_NULL) {
            return null;
        }

        if (cast(Float)(val) !is null) {
            return cast(Float) val;
        }

        return new Float((cast(Number) val).floatValue());
    }

    public static Double castToDouble(Object val) {
        if (val is null || val == SQLEvalVisitor.EVAL_VALUE_NULL) {
            return null;
        }

        if (cast(Double)(val) !is null) {
            return cast(Double) val;
        }

        return new Double((cast(Number) val).doubleValue());
    }

    public static BigInteger castToBigInteger(Object val) {
        if (val is null) {
            return null;
        }

        if (cast(BigInteger)(val) !is null) {
            return cast(BigInteger) val;
        }

        if (cast(String)(val) !is null) {
            return new BigInteger((cast(String) val).str);
        }

        return BigInteger.valueOf((cast(Number) val).longValue());
    }

    public static Number castToNumber(string val) {
        if (val is null) {
            return null;
        }

        try {
            return new Byte(Byte.parseByte(val));
        } catch (Exception e) {
        }

        try {
            return new Short(Short.parseShort(val));
        } catch (Exception e) {
        }

        try {
            return new Integer(Integer.parseInt(val));
        } catch (Exception e) {
        }

        try {
            return new Long(Long.parseLong(val));
        } catch (Exception e) {
        }

        try {
            return new Float(Float.parseFloat(val));
        } catch (Exception e) {
        }

        try {
            return new Double(to!double(val));
        } catch (Exception e) {
        }

        try {
            return new BigInteger(val);
        } catch (Exception e) {
        }

        try {
            return new BigDecimal(val);
        } catch (Exception e) {
            return null;
        }
    }

    public static Date castToDate(Object val) {
        // if (val is null) {
        //     return null;
        // }

        // if (cast(Number)(val) !is null) {
        //     return new Date((cast(Number) val).longValue());
        // } //@gxc

        // if (cast(String)(val) !is null) {
        //     return castToDate(cast(String) val);
        // }

        throw new Exception("can cast to date");
    }

    public static Date castToDate(string text) {

        implementationMissing();

        return Date.init;
        // if (text is null || text.length == 0) {
        //     return null;
        // }

        // string format;

        // if (text.length == "yyyy-MM-dd".length) {
        //     format = "yyyy-MM-dd";
        // } else {
        //     format = "yyyy-MM-dd HH:mm:ss";
        // }

        // try {
        //     return new SimpleDateFormat(format).parse(text);
        // } catch (ParseException e) {
        //     throw new Exception("format : " ~ format ~ ", value : " ~ text, e);
        // }
    }

    public static BigDecimal castToDecimal(Object val) {
        if (val is null) {
            return null;
        }

        if (cast(BigDecimal)(val) !is null) {
            return cast(BigDecimal) val;
        }

        if (cast(String)(val) !is null) {
            return new BigDecimal((cast(String) val).str);
        }

        if (cast(Float)(val) !is null) {
            return new BigDecimal((cast(Float) val).floatValue);
        }

        if (cast(Double)(val) !is null) {
            return new BigDecimal((cast(Double) val).doubleValue);
        }

        return BigDecimal.valueOf((cast(Number) val).longValue());
    }

    public static Object rightShift(Object a, Object b) {
        if (a is null || b is null) {
            return null;
        }

        if (cast(Long)(a) !is null || cast(Long)(b) !is null) {
            return new Long(castToLong(a).longValue() >> castToLong(b).longValue());
        }

        return new Integer(castToInteger(a).intValue() >> castToInteger(b).intValue());
    }

    public static Object bitAnd(Object a, Object b) {
        if (a is null || b is null) {
            return null;
        }

        if(a == SQLEvalVisitor.EVAL_VALUE_NULL || b == SQLEvalVisitor.EVAL_VALUE_NULL) {
            return null;
        }

        if (cast(String)(a) !is null) {
            a = castToNumber((cast(String) a).str);
        }

        if (cast(String)(b) !is null) {
            b = castToNumber((cast(String) b).str);
        }

        if (cast(Long)(a) !is null || cast(Long)(b) !is null) {
            return new Long(castToLong(a).longValue() & castToLong(b).longValue());
        }

        return new Integer(castToInteger(a).intValue() & castToInteger(b).intValue());
    }

    public static Object bitOr(Object a, Object b) {
        if (a is null || b is null) {
            return null;
        }

        if(a == SQLEvalVisitor.EVAL_VALUE_NULL || b == SQLEvalVisitor.EVAL_VALUE_NULL) {
            return null;
        }

        if (cast(String)(a) !is null) {
            a = castToNumber((cast(String) a).str);
        }

        if (cast(String)(b) !is null) {
            b = castToNumber((cast(String) b).str);
        }

        if (cast(Long)(a) !is null || cast(Long)(b) !is null) {
            return new Long(castToLong(a).longValue() | castToLong(b).longValue());
        }

        return new Integer(castToInteger(a).intValue() | castToInteger(b).intValue());
    }

    public static Object div(Object a, Object b) {
        if (a is null || b is null) {
            return null;
        }

        if(a == SQLEvalVisitor.EVAL_VALUE_NULL || b == SQLEvalVisitor.EVAL_VALUE_NULL) {
            return null;
        }

        if (cast(String)(a) !is null) {
            a = castToNumber((cast(String) a).str);
        }

        if (cast(String)(b) !is null) {
            b = castToNumber((cast(String) b).str);
        }

        if (cast(BigDecimal)(a) !is null || cast(BigDecimal)(b) !is null) {
            BigDecimal decimalA = castToDecimal(a);
            BigDecimal decimalB = castToDecimal(b);
            if (decimalB.scale() < decimalA.scale()) {
                decimalB = decimalB.setScale(decimalA.scale());
            }
            try {
                return decimalA.divide(decimalB);
            } catch (ArithmeticException ex) {
                return decimalA.divide(decimalB, BigDecimal.ROUND_HALF_UP);
            }
        }

        if (cast(Double)(a) !is null || cast(Double)(b) !is null) {
            Double doubleA = castToDouble(a);
            Double doubleB = castToDouble(b);
            if (doubleA is null || doubleB is null) {
                return null;
            }
            return new Double(doubleA.doubleValue / doubleB.doubleValue);
        }

        if (cast(Float)(a) !is null || cast(Float)(b) !is null) {
            Float floatA = castToFloat(a);
            Float floatB = castToFloat(b);
            if (floatA is null || floatB is null) {
                return null;
            }
            return new Float(floatA.floatValue / floatB.floatValue);
        }

        if (cast(BigInteger)(a) !is null || cast(BigInteger)(b) !is null) {
            return castToBigInteger(a).divide(castToBigInteger(b));
        }

        if (cast(Long)(a) !is null || cast(Long)(b) !is null) {
            Long longA = castToLong(a);
            Long longB = castToLong(b);
            if (longB.longValue == 0) {
                if (longA.longValue > 0) {
                    return new Double(Double.POSITIVE_INFINITY);
                } else if (longA.longValue < 0) {
                    return new Double(Double.NEGATIVE_INFINITY);
                } else {
                    return new Double(Double.NaN);
                }
            }
            return new Long(longA.longValue / longB.longValue);
        }

        if (cast(Integer)(a) !is null || cast(Integer)(b) !is null) {
            Integer intA = castToInteger(a);
            Integer intB = castToInteger(b);
            if (intB.intValue == 0) {
                if (intA.intValue > 0) {
                    return new Double(Double.POSITIVE_INFINITY);
                } else if (intA.intValue < 0) {
                    return new Double(Double.NEGATIVE_INFINITY);
                } else {
                    return new Double(Double.NaN);
                }
            }
            return new Integer(intA.intValue / intB.intValue);
        }

        if (cast(Short)(a) !is null || cast(Short)(b) !is null) {
            return new Short(castToShort(a).shortValue / castToShort(b).shortValue);
        }

        if (cast(Byte)(a) !is null || cast(Byte)(b) !is null) {
            return new Byte(castToByte(a).byteValue / castToByte(b).byteValue);
        }

        throw new Exception(typeid(a).name ~ " and " ~ typeid(b).name ~ " not supported.");
    }

    public static Boolean gt(Object a, Object b) {
        if (a is null || a == SQLEvalVisitor.EVAL_VALUE_NULL) {
            return new Boolean(false);
        }

        if (b is null || a == SQLEvalVisitor.EVAL_VALUE_NULL) {
            return new Boolean(true);
        }

        if (cast(String)(a) !is null || cast(String)(b) !is null) {
            return new Boolean(castToString(a).compareTo(castToString(b)) > 0);
        }

        if (cast(BigDecimal)(a) !is null || cast(BigDecimal)(b) !is null) {
            // return new Boolean(castToDecimal(a).compareTo(castToDecimal(b)) > 0);//@gxc
        }

        if (cast(BigInteger)(a) !is null || cast(BigInteger)(b) !is null) {
            return new Boolean(castToBigInteger(a).compareTo(castToBigInteger(b)) > 0);
        }

        if (cast(Long)(a) !is null || cast(Long)(b) !is null) {
            return new Boolean(castToLong(a) > castToLong(b));
        }

        if (cast(Integer)(a) !is null || cast(Integer)(b) !is null) {
            return new Boolean(castToInteger(a) > castToInteger(b));
        }

        if (cast(Short)(a) !is null || cast(Short)(b) !is null) {
            return new Boolean(castToShort(a) > castToShort(b));
        }

        if (cast(Byte)(a) !is null || cast(Byte)(b) !is null) {
            return new Boolean(castToByte(a) > castToByte(b));
        }

        //@gxc
        // if (cast(Date)(a) !is null || cast(Date)(b) !is null) {
        //     Date d1 = castToDate(a);
        //     Date d2 = castToDate(b);

        //     if (d1 == d2) {
        //         return new Boolean(false);
        //     }

        //     if (d1 is null) {
        //         return new Boolean(false);
        //     }

        //     if (d2 is null) {
        //         return new Boolean(true);
        //     }

        //     return new Boolean(d1.compareTo(d2) > 0);
        // }

        throw new Exception(typeid(a).name ~ " and " ~ typeid(b).name ~ " not supported.");
    }

    public static Boolean gteq(Object a, Object b) {
        if (eq(a, b).booleanValue) {
            return new Boolean(true);
        }

        return gt(a, b);
    }

    public static Boolean lt(Object a, Object b) {
        if (a is null) {
            return new Boolean(true);
        }

        if (b is null) {
            return new Boolean(false);
        }

        if (cast(String)(a) !is null || cast(String)(b) !is null) {
            return new Boolean((castToString(a)).compareTo(castToString(b)) < 0);
        }

        if (cast(BigDecimal)(a) !is null || cast(BigDecimal)(b) !is null) {
            // return new Boolean(castToDecimal(a).compareTo(castToDecimal(b)) < 0);//@gxc
        }

        if (cast(BigInteger)(a) !is null || cast(BigInteger)(b) !is null) {
            return new Boolean(castToBigInteger(a).compareTo(castToBigInteger(b)) < 0);
        }

        if (cast(Long)(a) !is null || cast(Long)(b) !is null) {
            return new Boolean(castToLong(a) < castToLong(b));
        }

        if (cast(Integer)(a) !is null || cast(Integer)(b) !is null) {
            Integer intA = castToInteger(a);
            Integer intB = castToInteger(b);
            return new Boolean(intA < intB);
        }

        if (cast(Short)(a) !is null || cast(Short)(b) !is null) {
            return new Boolean(castToShort(a) < castToShort(b));
        }

        if (cast(Byte)(a) !is null || cast(Byte)(b) !is null) {
            return new Boolean(castToByte(a) < castToByte(b));
        }

        // if (cast(Date)(a) !is null || cast(Date)(b) !is null) {
        //     Date d1 = castToDate(a);
        //     Date d2 = castToDate(b);

        //     if (d1 == d2) {
        //         return new Boolean(false);
        //     }

        //     if (d1 is null) {
        //         return new Boolean(true);
        //     }

        //     if (d2 is null) {
        //         return new Boolean(false);
        //     }

        //     return new Boolean(d1.compareTo(d2) < 0);
        // }//@gxc

        throw new Exception(typeid(a).name ~ " and " ~ typeid(b).name ~ " not supported.");
    }

    public static Boolean lteq(Object a, Object b) {
        if (eq(a, b).booleanValue) {
            return new Boolean(true);
        }

        return lt(a, b);
    }

    public static Boolean eq(Object a, Object b) {
        if (a == b) {
            return new Boolean(true);
        }

        if (a is null || b is null) {
            return new Boolean(false);
        }

        if (a == SQLEvalVisitor.EVAL_VALUE_NULL || b == SQLEvalVisitor.EVAL_VALUE_NULL) {
            return new Boolean(false);
        }

        if (a.opEquals(b)) {
            return new Boolean(true);
        }

        if (cast(String)(a) !is null || cast(String)(b) !is null) {
            return new Boolean(castToString(a) == (castToString(b)));
        }

        if (cast(BigDecimal)(a) !is null || cast(BigDecimal)(b) !is null) {
            // return new Boolean(castToDecimal(a).compareTo(castToDecimal(b)) == 0);//@gxc
        }

        if (cast(BigInteger)(a) !is null || cast(BigInteger)(b) !is null) {
            return new Boolean(castToBigInteger(a).compareTo(castToBigInteger(b)) == 0);
        }

        if (cast(Long)(a) !is null || cast(Long)(b) !is null) {
            return new Boolean(castToLong(a).opEquals(castToLong(b)));
        }

        if (cast(Integer)(a) !is null || cast(Integer)(b) !is null) {
            Integer inta = castToInteger(a);
            Integer intb = castToInteger(b);
            if (inta is null || intb is null) {
                return new Boolean(false);
            }
            return new Boolean(inta.opEquals(intb));
        }

        if (cast(Short)(a) !is null || cast(Short)(b) !is null) {
            return new Boolean(castToShort(a).opEquals(castToShort(b)));
        }

        if (cast(Boolean)(a) !is null || cast(Boolean)(b) !is null) {
            return new Boolean(castToBoolean(a).opEquals(castToBoolean(b)));
        }

        if (cast(Byte)(a) !is null || cast(Byte)(b) !is null) {
            return new Boolean(castToByte(a).opEquals(castToByte(b)));
        }

        //@gxc
        // if (cast(Date)(a) !is null || cast(Date)(b) !is null) {
        //     Date d1 = castToDate(a);
        //     Date d2 = castToDate(b);

        //     if (d1 == d2) {
        //         return new Boolean(true);
        //     }

        //     if (d1 is null || d2 is null) {
        //         return new Boolean(false);
        //     }

        //     return new Boolean(d1.opEquals(d2));
        // }

        throw new Exception(typeid(a).name ~ " and " ~ typeid(b).name ~ " not supported.");
    }

    public static Object add(Object a, Object b) {
        if (a is null) {
            return b;
        }

        if (b is null) {
            return a;
        }

        if (a == SQLEvalVisitor.EVAL_VALUE_NULL || b == SQLEvalVisitor.EVAL_VALUE_NULL) {
            return cast(Object)SQLEvalVisitor.EVAL_VALUE_NULL;
        }

        if (cast(String)(a) !is null && !(cast(String)(b) !is null)) {
            a = castToNumber((cast(String) a).str);
        }

        if (cast(String)(b) !is null && !(cast(String)(a) !is null)) {
            b = castToNumber((cast(String) b).str);
        }

        if (cast(BigDecimal)(a) !is null || cast(BigDecimal)(b) !is null) {
            return castToDecimal(a).add(castToDecimal(b));
        }

        if (cast(BigInteger)(a) !is null || cast(BigInteger)(b) !is null) {
            return castToBigInteger(a).add(castToBigInteger(b));
        }

        if (cast(Double)(a) !is null || cast(Double)(b) !is null) {
            return new Double(castToDouble(a).doubleValue + castToDouble(b).doubleValue);
        }

        if (cast(Float)(a) !is null || cast(Float)(b) !is null) {
            return new Float(castToFloat(a).floatValue + castToFloat(b).floatValue);
        }

        if (cast(Long)(a) !is null || cast(Long)(b) !is null) {
            return new Long(castToLong(a).longValue + castToLong(b).longValue);
        }

        if (cast(Integer)(a) !is null || cast(Integer)(b) !is null) {
            return new Integer(castToInteger(a).intValue+ castToInteger(b).intValue);
        }

        if (cast(Short)(a) !is null || cast(Short)(b) !is null) {
            return new Short(cast(short)(castToShort(a).shortValue + castToShort(b).shortValue));
        }

        if (cast(Boolean)(a) !is null || cast(Boolean)(b) !is null) {
            int aI = 0, bI = 0;
            if (castToBoolean(a)) aI = 1;
            if (castToBoolean(b)) bI = 1;
            return new Integer(aI + bI);
        }

        if (cast(Byte)(a) !is null || cast(Byte)(b) !is null) {
            return new Byte(cast(byte)(castToByte(a).byteValue + castToByte(b).byteValue));
        }

        if (cast(String)(a) !is null && cast(String)(b) !is null) {
            return new String(castToString(a) ~ castToString(b));
        }

        throw new Exception(typeid(a).name ~ " and " ~ typeid(b).name ~ " not supported.");
    }

    public static Object sub(Object a, Object b) {
        if (a is null) {
            return null;
        }

        if (b is null) {
            return a;
        }

        if (a == SQLEvalVisitor.EVAL_VALUE_NULL || b == SQLEvalVisitor.EVAL_VALUE_NULL) {
            return cast(Object)SQLEvalVisitor.EVAL_VALUE_NULL;
        }

        // if (cast(Date)(a) !is null || cast(Date)(b) !is null) {
        //     return cast(Object)(SQLEvalVisitor.EVAL_ERROR);
        // }//@gxc

        if (cast(String)(a) !is null) {
            a = castToNumber((cast(String) a).str);
        }

        if (cast(String)(b) !is null) {
            b = castToNumber((cast(String) b).str);
        }

        if (cast(BigDecimal)(a) !is null || cast(BigDecimal)(b) !is null) {
            return castToDecimal(a).subtract(castToDecimal(b));
        }

        if (cast(BigInteger)(a) !is null || cast(BigInteger)(b) !is null) {
            return castToBigInteger(a).subtract(castToBigInteger(b));
        }

        if (cast(Double)(a) !is null || cast(Double)(b) !is null) {
            return new Double(castToDouble(a).doubleValue - castToDouble(b).doubleValue);
        }

        if (cast(Float)(a) !is null || cast(Float)(b) !is null) {
            return new Float(castToFloat(a).floatValue - castToFloat(b).floatValue);
        }

        if (cast(Long)(a) !is null || cast(Long)(b) !is null) {
            return new Long(castToLong(a).longValue - castToLong(b).longValue);
        }

        if (cast(Integer)(a) !is null || cast(Integer)(b) !is null) {
            return new Integer(castToInteger(a).intValue - castToInteger(b).intValue);
        }

        if (cast(Short)(a) !is null || cast(Short)(b) !is null) {
            return new Short(cast(short)(castToShort(a).shortValue - castToShort(b).shortValue));
        }

        if (cast(Boolean)(a) !is null || cast(Boolean)(b) !is null) {
            int aI = 0, bI = 0;
            if (castToBoolean(a)) aI = 1;
            if (castToBoolean(b)) bI = 1;
            return new Boolean((aI - bI));
        }

        if (cast(Byte)(a) !is null || cast(Byte)(b) !is null) {
            return new Byte(cast(byte)(castToByte(a).byteValue - castToByte(b).byteValue));
        }

        // return cast(Object)(SQLEvalVisitor.EVAL_ERROR);
        throw new Exception(typeid(a).name ~ " and " ~ typeid(b).name ~ " not supported.");
    }

    public static Object multi(Object a, Object b) {
        if (a is null || b is null) {
            return null;
        }

        if (cast(String)(a) !is null) {
            a = castToNumber((cast(String) a).str);
        }

        if (cast(String)(b) !is null) {
            b = castToNumber((cast(String) b).str);
        }

        if (cast(BigDecimal)(a) !is null || cast(BigDecimal)(b) !is null) {
            return castToDecimal(a).multiply(castToDecimal(b));
        }

        if (cast(BigInteger)(a) !is null || cast(BigInteger)(b) !is null) {
            return castToBigInteger(a).multiply(castToBigInteger(b));
        }

        if (cast(Double)(a) !is null || cast(Double)(b) !is null) {
            return new Double(castToDouble(a).doubleValue * castToDouble(b).doubleValue);
        }

        if (cast(Float)(a) !is null || cast(Float)(b) !is null) {
            return new Float(castToFloat(a).floatValue * castToFloat(b).floatValue);
        }

        if (cast(Long)(a) !is null || cast(Long)(b) !is null) {
            return new Long(castToLong(a).longValue * castToLong(b).longValue);
        }

        if (cast(Integer)(a) !is null || cast(Integer)(b) !is null) {
            return new Integer(castToInteger(a).intValue * castToInteger(b).intValue);
        }

        if (cast(Short)(a) !is null || cast(Short)(b) !is null) {
            Short shortA = castToShort(a);
            Short shortB = castToShort(b);

            if (shortA is null || shortB is null) {
                return  null;
            }

            return new Short(cast(short)(shortA.shortValue * shortB.shortValue));
        }

        if (cast(Byte)(a) !is null || cast(Byte)(b) !is null) {
            return new Byte(cast(byte)(castToByte(a).byteValue * castToByte(b).byteValue));
        }

        throw new Exception(typeid(a).name ~ " and " ~ typeid(b).name ~ " not supported.");
    }

    public static Boolean like(string input, string pattern) {
        if (pattern is null) {
            throw new Exception("pattern is null");
        }

        StringBuilder regexprBuilder = new StringBuilder(pattern.length + 4);

         int STAT_NOTSET = 0;
         int STAT_RANGE = 1;
         int STAT_LITERAL = 2;

        int stat = STAT_NOTSET;

        int blockStart = -1;
        for (int i = 0; i < pattern.length; ++i) {
            char ch = charAt(pattern, i);

            if (stat == STAT_LITERAL //
                && (ch == '%' || ch == '_' || ch == '[')) {
                string block = pattern.substring(blockStart, i);
                regexprBuilder.append("\\Q");
                regexprBuilder.append(block);
                regexprBuilder.append("\\E");
                blockStart = -1;
                stat = STAT_NOTSET;
            }

            if (ch == '%') {
                regexprBuilder.append("");
            } else if (ch == '_') {
                regexprBuilder.append('.');
            } else if (ch == '[') {
                if (stat == STAT_RANGE) {
                    throw new Exception("illegal pattern : " ~ pattern);
                }
                stat = STAT_RANGE;
                blockStart = i;
            } else if (ch == ']') {
                if (stat != STAT_RANGE) {
                    throw new Exception("illegal pattern : " ~ pattern);
                }
                string block = pattern.substring(blockStart, i + 1);
                regexprBuilder.append(block);

                blockStart = -1;
            } else {
                if (stat == STAT_NOTSET) {
                    stat = STAT_LITERAL;
                    blockStart = i;
                }

                if (stat == STAT_LITERAL && i == pattern.length - 1) {
                    string block = pattern.substring(blockStart, i + 1);
                    regexprBuilder.append("\\Q");
                    regexprBuilder.append(block);
                    regexprBuilder.append("\\E");
                }
            }
        }
        if ("%" == (pattern) || "%%" == (pattern)) {
            return new Boolean(true);
        }

        string regexpr = (cast(Object)(regexprBuilder)).toString();
        return new Boolean(Utils.matches(regexpr, input));
    }

    public static bool visit(SQLEvalVisitor visitor, SQLIdentifierExpr x) {
        x.putAttribute(SQLEvalVisitor.EVAL_EXPR, x);
        return false;
    }
}
