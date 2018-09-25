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
module hunt.sql.ast.expr.SQLBinaryExpr;

import hunt.sql.ast.SQLExprImpl;
import hunt.sql.ast.SQLObject;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.util.Utils;
import hunt.sql.ast.expr.SQLValuableExpr;
import hunt.sql.ast.expr.SQLLiteralExpr;
import hunt.container;
import hunt.math;
import hunt.util.string;

public class SQLBinaryExpr : SQLExprImpl , SQLLiteralExpr, SQLValuableExpr {

    private string text;

    private  Number val;

    public this(){

    }

    public this(string value){
        super();
        this.text = value;
    }

    public string getText() {
        return text;
    }

    public Number getValue() {
        if (text is null) {
            return null;
        }

        if (val is null) {
            long[] words = new long[text.length / 64 + 1];
            for (int i = cast(int)(text.length) - 1; i >= 0; --i) {
                char ch = charAt(text, i);
                if (ch == '1') {
                    int wordIndex = i >> 6;
                    words[wordIndex] |= (1L << (text.length - 1 - i));
                }
            }

            if (words.length == 1) {
                val = new Long(words[0]);
            } else {
                byte[] bytes = new byte[words.length * 8];

                for (int i = 0; i < words.length; ++i) {
                    Utils.putLong(bytes, cast(int)(words.length - 1 - i) * 8, words[i]);
                }

                val = new BigInteger(bytes);
            }
        }

        return val;
    }

    public void setValue(string value) {
        this.text = value;
    }

    override public void accept0(SQLASTVisitor visitor) {
        visitor.visit(this);

        visitor.endVisit(this);
    }

    override public void output(StringBuffer buf) {
        buf.append("b'");
        buf.append(text);
        buf.append('\'');
    }

   override
    public size_t toHash() @trusted nothrow {
         int prime = 31;
        size_t result = 1;
        result = prime * result + ((text is null) ? 0 : hashOf(text));
        return result;
    }

    override public SQLBinaryExpr clone() {
        return new SQLBinaryExpr(text);
    }

   override
    public List!SQLObject getChildren() {
        return Collections.emptyList!(SQLObject)();
    }

   override
    public bool opEquals(Object obj) {
        if (this is obj) {
            return true;
        }
        if (obj is null) {
            return false;
        }
        if (typeid(this) != typeid(obj)) {
            return false;
        }
        SQLBinaryExpr other = cast(SQLBinaryExpr) obj;
        if (text is null) {
            if (other.text !is null) {
                return false;
            }
        } else if (!(text == other.text)) {
            return false;
        }
        return true;
    }

}
