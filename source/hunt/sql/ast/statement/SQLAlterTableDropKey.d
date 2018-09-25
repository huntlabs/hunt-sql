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
module hunt.sql.ast.statement.SQLAlterTableDropKey;

import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLAlterTableItem;

public class SQLAlterTableDropKey : SQLObjectImpl , SQLAlterTableItem {

    private SQLName keyName;

    public SQLName getKeyName() {
        return keyName;
    }

    public void setKeyName(SQLName keyName) {
        this.keyName = keyName;
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        if(visitor.visit(this)) {
            acceptChild(visitor, keyName);
        }
        visitor.endVisit(this);
    }

}
