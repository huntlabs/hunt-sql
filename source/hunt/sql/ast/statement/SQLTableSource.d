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
module hunt.sql.ast.statement.SQLTableSource;

import hunt.container;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLHint;
import hunt.sql.ast.SQLObject;
import hunt.sql.ast.statement.SQLColumnDefinition;

public interface SQLTableSource : SQLObject {

    string getAlias();
    long aliasHashCode64();

    void setAlias(string alias_p);
    
    List!SQLHint getHints();

    SQLTableSource clone();

    string computeAlias();
    bool containsAlias(string alias_p);

    SQLExpr getFlashback();
    void setFlashback(SQLExpr flashback);

    SQLColumnDefinition findColumn(string columnName);
    SQLColumnDefinition findColumn(long columnNameHash);

    SQLTableSource findTableSourceWithColumn(string columnName);
    SQLTableSource findTableSourceWithColumn(long columnName_hash);

    SQLTableSource findTableSource(string alias_p);
    SQLTableSource findTableSource(long alias_hash);
}
