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
module hunt.sql.ast.expr.SQLListExpr;



import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLExprImpl;
import hunt.sql.ast.SQLObject;
import hunt.container;
import hunt.sql.visitor.SQLASTVisitor;

public class SQLListExpr : SQLExprImpl {

    private  List!SQLExpr items;

    this()
    {
        items = new ArrayList!SQLExpr();
    }

    public List!SQLExpr getItems() {
        return items;
    }
    
    public void addItem(SQLExpr item) {
        if (item !is null) {
            item.setParent(this);
        }
        this.items.add(item);
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild!SQLExpr(visitor, items);
        }
        visitor.endVisit(this);
    }

   override
    public size_t toHash() @trusted nothrow {
         int prime = 31;
        size_t result = 1;
        result = prime * result + ((items is null) ? 0 : (cast(Object)items).toHash());
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
        SQLListExpr other = cast(SQLListExpr) obj;
        if (items is null) {
            if (other.items !is null) {
                return false;
            }
        } else if (!(cast(Object)(items)).opEquals(cast(Object)(other.items))) {
            return false;
        }
        return true;
    }

    public override SQLListExpr clone() {
        SQLListExpr x = new SQLListExpr();
        foreach (SQLExpr item ; items) {
            SQLExpr item2 = item.clone();
            item2.setParent(x);
            x.items.add(item2);
        }
        return x;
    }

    public override List!SQLObject getChildren() {
        return cast(List!SQLObject)this.items;
    }
}
