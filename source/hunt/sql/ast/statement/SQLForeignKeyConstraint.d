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
module hunt.sql.ast.statement.SQLForeignKeyConstraint;

import hunt.collection;

import hunt.sql.ast.SQLName;
import hunt.sql.ast.statement.SQLConstraint;
import hunt.sql.ast.statement.SQLTableElement;
import hunt.sql.ast.statement.SQLTableConstraint;
import hunt.sql.ast.statement.SQLExprTableSource;

public interface SQLForeignKeyConstraint : SQLConstraint, SQLTableElement, SQLTableConstraint {

    List!SQLName getReferencingColumns();

    SQLExprTableSource getReferencedTable();
    SQLName getReferencedTableName();

    void setReferencedTableName(SQLName value);

    List!SQLName getReferencedColumns();
}
