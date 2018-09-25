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
module hunt.sql.dialect.mysql.ast.MySqlPrimaryKey;

import hunt.sql.ast.statement.SQLPrimaryKey;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;
import hunt.sql.util.DBType;
import hunt.sql.dialect.mysql.ast.MySqlKey;
import hunt.sql.ast.SQLObject;
import hunt.container;
import hunt.sql.ast.statement.SQLSelectOrderByItem;

public class MySqlPrimaryKey : MySqlKey , SQLPrimaryKey {

    alias accept0 = MySqlKey.accept0;

    public this(){
        dbType = DBType.MYSQL.name;
    }

    override protected void accept0(MySqlASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, this.getName());
            acceptChild!SQLSelectOrderByItem(visitor, this.getColumns());
        }
        visitor.endVisit(this);
    }

    override public MySqlPrimaryKey clone() {
        MySqlPrimaryKey x = new MySqlPrimaryKey();
        cloneTo(x);
        return x;
    }
}
