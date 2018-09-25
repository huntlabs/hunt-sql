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
module hunt.sql.ast.expr.SQLHexExpr;

import hunt.sql.ast.SQLExprImpl;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.util.HexBin;
import hunt.sql.ast.expr.SQLValuableExpr;
import hunt.sql.ast.expr.SQLLiteralExpr;
import hunt.container;
import hunt.sql.ast.SQLObject;
import hunt.math;

public class SQLHexExpr : SQLExprImpl , SQLLiteralExpr, SQLValuableExpr {

    private  string hex;

    public this(string hex){
        this.hex = hex;
    }

    public string getHex() {
        return hex;
    }

    override public void output(StringBuffer buf) {
        buf.append("0x");
        buf.append(this.hex);

        string charset = " not implement @gxc ";//cast(string) getAttribute("USING");
        if (charset !is null) {
            buf.append(" USING ");
            buf.append(charset);
        }
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        visitor.visit(this);
        visitor.endVisit(this);
    }

   override
    public size_t toHash() @trusted nothrow {
         int prime = 31;
        size_t result = 1;
        result = prime * result + ((hex.length == 0) ? 0 : hashOf(hex));
        return result;
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
        SQLHexExpr other = cast(SQLHexExpr) obj;
        if (hex is null) {
            if (other.hex !is null) {
                return false;
            }
        } else if (!(hex == other.hex)) {
            return false;
        }
        return true;
    }

    public byte[] toBytes() {
        return HexBin.decode(this.hex);
    }

    override public SQLHexExpr clone () {
        return new SQLHexExpr(hex);
    }

    override public Object getValue() {
        return new Bytes(toBytes());
    }

   override
    public List!SQLObject getChildren() {
        return Collections.emptyList!(SQLObject)();
    }
}
