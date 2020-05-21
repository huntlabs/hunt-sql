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
module hunt.sql.ast.expr.SQLCurrentOfCursorExpr;

import hunt.sql.ast.SQLExprImpl;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLObject;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.collection;
import hunt.util.StringBuilder;

public class SQLCurrentOfCursorExpr : SQLExprImpl {

    private SQLName cursorName;

    public this(){

    }

    public this(SQLName cursorName){
        this.cursorName = cursorName;
    }

    override public SQLCurrentOfCursorExpr clone() {
        SQLCurrentOfCursorExpr x = new SQLCurrentOfCursorExpr();
        if (cursorName !is null) {
            x.setCursorName(cursorName.clone());
        }
        return x;
    }

    public SQLName getCursorName() {
        return cursorName;
    }

    public void setCursorName(SQLName cursorName) {
        if (cursorName !is null) {
            cursorName.setParent(this);
        }
        this.cursorName = cursorName;
    }

    override public void output(StringBuilder buf) {
        buf.append("CURRENT OF ");
        cursorName.output(buf);
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, this.cursorName);
        }
        visitor.endVisit(this);
    }

    override public List!SQLObject getChildren() {
        return Collections.singletonList!SQLObject(this.cursorName);
    }


   override
    public size_t toHash() @trusted nothrow {
         int prime = 31;
        size_t result = 1;
        result = prime * result + ((cursorName is null) ? 0 : (cast(Object)cursorName).toHash());
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
        SQLCurrentOfCursorExpr other = cast(SQLCurrentOfCursorExpr) obj;
        if (cursorName is null) {
            if (other.cursorName !is null) {
                return false;
            }
        } else if (!(cast(Object)(cursorName)).opEquals(cast(Object)(other.cursorName))) {
            return false;
        }
        return true;
    }

}
