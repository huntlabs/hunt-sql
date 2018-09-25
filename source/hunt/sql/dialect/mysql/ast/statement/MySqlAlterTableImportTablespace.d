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
module hunt.sql.dialect.mysql.ast.statement.MySqlAlterTableImportTablespace;

import hunt.sql.ast.statement.SQLAlterTableItem;
import hunt.sql.dialect.mysql.ast.MySqlObject;
import hunt.sql.dialect.mysql.ast.MySqlObjectImpl;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;
import hunt.sql.visitor.SQLASTVisitor;

public class MySqlAlterTableImportTablespace : MySqlObjectImpl , SQLAlterTableItem, MySqlObject {

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (cast(MySqlASTVisitor)(visitor) !is null) {
            accept0(cast(MySqlASTVisitor) visitor);
        } else {
            throw new Exception("not support visitor type : " ~ typeof(visitor).stringof);
        }
    }

    override public void accept0(MySqlASTVisitor visitor) {
        visitor.visit(this);
        visitor.endVisit(this);
    }

}
