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
module hunt.sql.dialect.mysql.ast.statement.MySqlShowEnginesStatement;

import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;
import hunt.sql.dialect.mysql.ast.statement.MySqlStatementImpl;
import hunt.sql.dialect.mysql.ast.statement.MySqlShowStatement;

public class MySqlShowEnginesStatement : MySqlStatementImpl , MySqlShowStatement {
    alias accept0 = MySqlStatementImpl.accept0;
    private bool storage = false;

    override public void accept0(MySqlASTVisitor visitor) {
        visitor.visit(this);
        visitor.endVisit(this);
    }

    public bool isStorage() {
        return storage;
    }

    public void setStorage(bool storage) {
        this.storage = storage;
    }

}
