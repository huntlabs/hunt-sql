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
module hunt.sql.ast.expr.SQLBlobExpr;

import hunt.sql.ast.SQLExprImpl;
import hunt.sql.ast.SQLObject;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.util.HexBin;
import hunt.sql.ast.expr.SQLValuableExpr;
import hunt.sql.ast.expr.SQLLiteralExpr;
import hunt.collection;
import hunt.logging.ConsoleLogger;
import hunt.Byte;
import hunt.Nullable;
import hunt.util.StringBuilder;

import std.format;

class SQLBlobExpr : SQLExprImpl, SQLLiteralExpr, SQLValuableExpr {

    private string hex;

    this(ubyte[] data) {
        hex = format("%(%02X%)", data);
    }

    this(string hex) {
        this.hex = hex;
    }

    string getHex() {
        return hex;
    }

    override void output(StringBuilder buf) {
        buf.append("0x");
        buf.append(this.hex);

        string charset = " not implement @gxc "; //cast(string) getAttribute("USING");
        if (charset !is null) {
            buf.append(" USING ");
            buf.append(charset);
        }
    }

    override protected void accept0(SQLASTVisitor visitor) {
        visitor.visit(this);
        visitor.endVisit(this);
    }

    override
    size_t toHash() @trusted nothrow {
        int prime = 31;
        size_t result = 1;
        result = prime * result + ((hex.length == 0) ? 0 : hashOf(hex));
        return result;
    }

    override
    bool opEquals(Object obj) {
        if (this is obj) {
            return true;
        }
        if (obj is null) {
            return false;
        }
        if (typeid(this) != typeid(obj)) {
            return false;
        }
        SQLBlobExpr other = cast(SQLBlobExpr) obj;
        if (hex is null) {
            if (other.hex !is null) {
                return false;
            }
        } else if (!(hex == other.hex)) {
            return false;
        }
        return true;
    }

    byte[] toBytes() {
        return HexBin.decode(this.hex);
    }

    override SQLBlobExpr clone() {
        return new SQLBlobExpr(hex);
    }

    override Object getValue() {
        return new Nullable!(byte[])(toBytes());
    }

    override
    List!SQLObject getChildren() {
        return Collections.emptyList!(SQLObject)();
    }
}
