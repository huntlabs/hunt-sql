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
module hunt.sql.ast.statement.SQLPrimaryKeyImpl;

import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLUnique;
import hunt.sql.ast.statement.SQLPrimaryKey;
import hunt.container;
import hunt.sql.ast.SQLObject;
import hunt.sql.ast.statement.SQLSelectOrderByItem;

public class SQLPrimaryKeyImpl : SQLUnique , SQLPrimaryKey {

    alias cloneTo = SQLUnique.cloneTo;

    protected bool clustered         = false; // sql server

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, this.getName());
            acceptChild!SQLSelectOrderByItem(visitor, this.getColumns());
        }
        visitor.endVisit(this);
    }

    override public SQLPrimaryKeyImpl clone() {
        SQLPrimaryKeyImpl x = new SQLPrimaryKeyImpl();
        cloneTo(x);
        return x;
    }

    public void cloneTo(SQLPrimaryKeyImpl x) {
        super.cloneTo(x);
        x.clustered = clustered;
    }

    public bool isClustered() {
        return clustered;
    }

    public void setClustered(bool clustered) {
        this.clustered = clustered;
    }
}
