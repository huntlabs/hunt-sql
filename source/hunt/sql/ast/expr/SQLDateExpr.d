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
module hunt.sql.ast.expr.SQLDateExpr;

import hunt.sql.ast.SQLDataType;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLExprImpl;
import hunt.sql.ast.SQLObject;
import hunt.sql.ast.statement.SQLCharacterDataType;
// import hunt.sql.dialect.oracle.ast.expr.OracleExpr;
// import hunt.sql.dialect.oracle.visitor.OracleASTVisitor;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.expr.SQLValuableExpr;
import hunt.sql.ast.expr.SQLLiteralExpr;
import hunt.container;
import hunt.sql.ast.expr.SQLCharExpr;
import hunt.sql.util.MyString;

public class SQLDateExpr : SQLExprImpl , SQLLiteralExpr, SQLValuableExpr {
    public static  SQLDataType DEFAULT_DATA_TYPE;

    private SQLExpr literal;

    // static this()
    // {
    //     DEFAULT_DATA_TYPE = new SQLCharacterDataType("date");
    // }

    public this(){

    }

    public this(MyString literal) {
        this.setLiteral(literal);
    }

    public this(string literal) {
        this.setLiteral(new MyString(literal));
    }

    public SQLExpr getLiteral() {
        return literal;
    }

    public void setLiteral(MyString literal) {
        setLiteral(new SQLCharExpr(literal));
    }

    public void setLiteral(SQLExpr x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.literal = x;
    }

    public MyString getValue() {
        if (cast(SQLCharExpr) literal !is null) {
            return (cast(SQLCharExpr) literal).getText();
        }
        return null;
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        visitor.visit(this);
        visitor.endVisit(this);
    }

   override
    public size_t toHash() @trusted nothrow {
         int prime = 31;
        size_t result = 1;
        result = prime * result + ((literal is null) ? 0 : (cast(Object)literal).toHash());
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
        SQLDateExpr other = cast(SQLDateExpr) obj;
        if (literal is null) {
            if (other.literal !is null) {
                return false;
            }
        } else if (!(cast(Object)(literal)).opEquals(cast(Object)(other.literal))) {
            return false;
        }
        return true;
    }

    override public SQLDateExpr clone() {
        SQLDateExpr x = new SQLDateExpr();

        if (this.literal !is null) {
            x.setLiteral(literal.clone());
        }

        return x;
    }

   override
    public List!SQLObject getChildren() {
        return Collections.emptyList!(SQLObject)();
    }
}
