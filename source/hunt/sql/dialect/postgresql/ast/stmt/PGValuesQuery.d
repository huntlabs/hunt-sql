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
module hunt.sql.dialect.postgresql.ast.stmt.PGValuesQuery;


import hunt.collection;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.statement.SQLSelectQuery;
import hunt.sql.dialect.postgresql.ast.PGSQLObjectImpl;
import hunt.sql.dialect.postgresql.visitor.PGASTVisitor;
import hunt.sql.ast.SQLObject;

public class PGValuesQuery : PGSQLObjectImpl , SQLSelectQuery {

    alias accept0 = PGSQLObjectImpl.accept0;
    
    private bool          bracket  = false;

    private List!(SQLExpr) values;
    
    this()
    {
        values = new ArrayList!(SQLExpr)();
    }

    public List!(SQLExpr) getValues() {
        return values;
    }

    override
    public void accept0(PGASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild!SQLExpr(visitor, values);
        }
        visitor.endVisit(this);
    }

    override
    public bool isBracket() {
        return bracket;
    }

    override
    public void setBracket(bool bracket) {
        this.bracket = bracket;
    }

    override public PGValuesQuery clone() {
        PGValuesQuery x = new PGValuesQuery();
        x.bracket = bracket;

        for (int i = 0; i < values.size(); ++i) {
            SQLExpr value = values.get(i).clone();
            value.setParent(x);
            x.values.add(value);
        }

        return x;
    }
}
