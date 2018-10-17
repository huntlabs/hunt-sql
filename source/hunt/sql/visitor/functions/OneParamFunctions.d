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
module hunt.sql.visitor.functions.OneParamFunctions;

// import hunt.sql.visitor.SQLEvalVisitor.EVAL_VALUE;
// import hunt.sql.visitor.SQLEvalVisitor.EVAL_VALUE_NULL;


import std.xml;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.expr.SQLMethodInvokeExpr;
import hunt.sql.visitor.SQLEvalVisitor;
import hunt.sql.visitor.SQLEvalVisitorUtils;
import hunt.sql.util.Utils;
import hunt.sql.visitor.functions.Function;
import hunt.lang;
import hunt.sql.util.String;
import hunt.string;
import hunt.container;
import std.conv;
import std.uni;
import std.digest.md;
import std.string;
import hunt.math;

public class OneParamFunctions : Function {

    public  static OneParamFunctions instance;

    // static this()
    // {
    //     instance = new OneParamFunctions();
    // }

    public Object eval(SQLEvalVisitor visitor, SQLMethodInvokeExpr x) {
        if (x.getParameters().size() == 0) {
            return cast(Object)(SQLEvalVisitor.EVAL_ERROR);
        }

        SQLExpr param = x.getParameters().get(0);
        param.accept(visitor);

        Object paramValue = param.getAttributes().get(SQLEvalVisitor.EVAL_VALUE);
        if (paramValue is null) {
            return cast(Object)(SQLEvalVisitor.EVAL_ERROR);
        }

        if (paramValue == SQLEvalVisitor.EVAL_VALUE_NULL) {
            return cast(Object)(SQLEvalVisitor.EVAL_VALUE_NULL);
        }

        string method = x.getMethodName();
        if ("md5".equalsIgnoreCase(method)) {
            string text = paramValue.toString();
            return new String(cast(string)(md5Of(text)));
        }

        if ("bit_count".equalsIgnoreCase(method)) {
            if (cast(BigInteger)(paramValue) !is null) {
                return new Integer((cast(BigInteger) paramValue).bitCount());
            }

            if (cast(BigDecimal)(paramValue) !is null) {
                import hunt.lang.exception;
                implementationMissing(false);
                BigDecimal decimal = cast(BigDecimal) paramValue;
                BigInteger bigInt = decimal.setScale(0,  BigDecimal.ROUND_HALF_UP).toBigInteger();
                return new Integer(bigInt.bitCount());
            }
            Long val = SQLEvalVisitorUtils.castToLong(paramValue);
            return new Integer(Long.bitCount(val.longValue));
        }
        
        if ("soundex".equalsIgnoreCase(method)) {
            string text = paramValue.toString();
            return new String(soundex(text));
        }
        
        if ("space".equalsIgnoreCase(method)) {
            int intVal = (SQLEvalVisitorUtils.castToInteger(paramValue)).intValue;
            char[] chars = new char[intVal];
            for (int i = 0; i < chars.length; ++i) {
                chars[i] = ' ';
            }
            return new String(cast(string)chars);
        }

        throw new Exception(method);
    }

    public static string soundex(string str) {
        if (str is null) {
            return null;
        }
        str = clean(str);
        if (str.length == 0) {
            return str;
        }
        char[] out_p = ['0', '0', '0', '0'];
        char last, mapped;
        int incount = 1, count = 1;
        out_p[0] = charAt(str, 0);
        // getMappingCode() throws Exception
        last = getMappingCode(str, 0);
        while ((incount < str.length) && (count < out_p.length)) {
            mapped = getMappingCode(str, incount++);
            if (mapped != 0) {
                if ((mapped != '0') && (mapped != last)) {
                    out_p[count++] = mapped;
                }
                last = mapped;
            }
        }
        return cast(string)out_p;
    }
    
    static string clean(string str) {
        if (str is null || str.length == 0) {
            return str;
        }
        int len = cast(int)(str.length);
        char[] chars = new char[len];
        int count = 0;
        for (int i = 0; i < len; i++) {
            if (isLetter(charAt(str, i))) {
                chars[count++] = charAt(str, i);
            }
        }
        if (count == len) {
            // return str.toUpperCase(java.util.Locale.ENGLISH);
            return toUpper(str);
        }
        // return new String(chars, 0, count).toUpperCase(java.util.Locale.ENGLISH);
        return toUpper(cast(string)chars[0..count]);
    }
    
    private static char getMappingCode(string str, int index) {
        // map() throws Exception
        char mappedChar = map(charAt(str, index));
        // HW rule check
        if (index > 1 && mappedChar != '0') {
            char hwChar = charAt(str, index - 1);
            if ('H' == hwChar || 'W' == hwChar) {
                char preHWChar = charAt(str, index - 2);
                char firstCode = map(preHWChar);
                if (firstCode == mappedChar || 'H' == preHWChar || 'W' == preHWChar) {
                    return 0;
                }
            }
        }
        return mappedChar;
    }
    
    private static char map(char ch) {
        string soundexMapping = "01230120022455012623010202";
        int index = ch - 'A';
        if (index < 0 || index >= soundexMapping.length) {
            throw new Exception("The character is not mapped: " ~ ch);
        }
        return charAt(soundexMapping, index);
    }
    
    
}
