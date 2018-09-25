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
module hunt.sql.dialect.mysql.ast.statement.MySqlUpdateTableSource;

import hunt.sql.ast.statement.SQLTableSourceImpl;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.dialect.mysql.ast.statement.MySqlUpdateStatement;

public class MySqlUpdateTableSource : SQLTableSourceImpl {

    private MySqlUpdateStatement update;

    public this(MySqlUpdateStatement update){
        this.update = update;
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (cast(MySqlASTVisitor)(visitor) !is null) {
            accept0(cast(MySqlASTVisitor) visitor);
        } else {
            throw new Exception("not support visitor type : " ~ typeof(visitor).stringof);
        }
    }

    public void accept0(MySqlASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, update);
        }
        visitor.endVisit(this);
    }

    public MySqlUpdateStatement getUpdate() {
        return update;
    }

    public void setUpdate(MySqlUpdateStatement update) {
        this.update = update;
    }

}
