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
module hunt.sql.dialect.postgresql.ast.expr.PGExtractExpr;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLObject;
import hunt.sql.dialect.postgresql.visitor.PGASTVisitor;
import hunt.sql.dialect.postgresql.ast.expr.PGDateField;
import hunt.sql.dialect.postgresql.ast.expr.PGExprImpl;


import hunt.collection;

public class PGExtractExpr : PGExprImpl {
     alias accept0 = PGExprImpl.accept0;
    private PGDateField field;
    private SQLExpr     source;

    override public PGExtractExpr clone() {
        PGExtractExpr x = new PGExtractExpr();
        x.field = field;
        if (source !is null) {
            x.setSource(source.clone());
        }
        return x;
    }

    public PGDateField getField() {
        return field;
    }

    public void setField(PGDateField field) {
        this.field = field;
    }

    public SQLExpr getSource() {
        return source;
    }

    public void setSource(SQLExpr source) {
        if (source !is null) {
            source.setParent(this);
        }
        this.source = source;
    }

    override
    public void accept0(PGASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, source);
        }
        visitor.endVisit(this);
    }

    override public List!(SQLObject) getChildren() {
        return Collections.singletonList!(SQLObject)(source);
    }

    override
    public size_t toHash() @trusted nothrow {
         int prime = 31;
        size_t result = 1;
        result = prime * result + hashOf(field);
        result = prime * result + ((source is null) ? 0 : (cast(Object)source).toHash());
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
        PGExtractExpr other = cast(PGExtractExpr) obj;
        if (field != other.field) {
            return false;
        }
        if (source is null) {
            if (other.source !is null) {
                return false;
            }
        } else if (!(cast(Object)(source)).opEquals(cast(Object)(other.source))) {
            return false;
        }
        return true;
    }

}
