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
module hunt.sql.ast.statement.SQLSelectGroupByClause;


import hunt.container;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.SQLObject;

public class SQLSelectGroupByClause : SQLObjectImpl {

    private  List!SQLExpr items;
    private SQLExpr             having;
    private bool             withRollUp = false;
    private bool             withCube = false;

    public this(){
        items = new ArrayList!SQLExpr();
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild!SQLExpr(visitor, this.items);
            acceptChild(visitor, this.having);
        }

        visitor.endVisit(this);
    }
    
    public bool isWithRollUp() {
        return withRollUp;
    }

    public void setWithRollUp(bool withRollUp) {
        this.withRollUp = withRollUp;
    }
    
    
    public bool isWithCube() {
        return withCube;
    }

    public void setWithCube(bool withCube) {
        this.withCube = withCube;
    }

    public SQLExpr getHaving() {
        return this.having;
    }

    public void setHaving(SQLExpr having) {
        if (having !is null) {
            having.setParent(this);
        }
        
        this.having = having;
    }

    public List!SQLExpr getItems() {
        return this.items;
    }

    public void addItem(SQLExpr sqlExpr) {
        if (sqlExpr !is null) {
            sqlExpr.setParent(this);
            this.items.add(sqlExpr);
        }
    }

    override public SQLSelectGroupByClause clone() {
        SQLSelectGroupByClause x = new SQLSelectGroupByClause();
        foreach (SQLExpr item ; items) {
            SQLExpr item2 = item.clone();
            item2.setParent(x);
            x.items.add(item2);
        }
        if (having !is null) {
            x.setHaving(having.clone());
        }
        x.withRollUp = withRollUp;
        x.withCube = withCube;
        return x;
    }
}
