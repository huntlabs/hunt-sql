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
module hunt.sql.dialect.postgresql.ast.expr.PGLineSegmentsExpr;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLObject;
import hunt.sql.dialect.postgresql.visitor.PGASTVisitor;

import hunt.sql.dialect.postgresql.ast.expr.PGExprImpl;

import hunt.container;

public class PGLineSegmentsExpr : PGExprImpl {
    alias accept0 = PGExprImpl.accept0;
    private SQLExpr value;

    override public PGLineSegmentsExpr clone() {
        PGLineSegmentsExpr x = new PGLineSegmentsExpr();
        if (value !is null) {
            x.setValue(value.clone());
        }
        return x;
    }

    public SQLExpr getValue() {
        return value;
    }

    public void setValue(SQLExpr value) {
        this.value = value;
    }

    override
    public void accept0(PGASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, value);
        }
        visitor.endVisit(this);
    }

    override
    public List!(SQLObject) getChildren() {
        return Collections.singletonList!(SQLObject)(value);
    }

    override
    public size_t toHash() @trusted nothrow {
         int prime = 31;
        size_t result = 1;
        result = prime * result + ((value is null) ? 0 : (cast(Object)value).toHash());
        return result;
    }

    override
    public bool opEquals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj is null) {
            return false;
        }
        if ( typeid(this) != typeid(obj)) {
            return false;
        }
        PGLineSegmentsExpr other = cast(PGLineSegmentsExpr) obj;
        if (value is null) {
            if (other.value !is null) {
                return false;
            }
        } else if (!(cast(Object)(value)).opEquals(cast(Object)(other.value))) {
            return false;
        }
        return true;
    }

}
