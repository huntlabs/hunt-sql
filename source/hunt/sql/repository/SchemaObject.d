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
module hunt.sql.repository.SchemaObject;

import hunt.sql.ast.SQLStatement;
import hunt.sql.ast.statement.SQLColumnDefinition;
import hunt.sql.repository.SchemaObjectType;

/**
 * Created by wenshao on 03/06/2017.
 */
public interface SchemaObject {

    SQLStatement getStatement();

    SQLColumnDefinition findColumn(string columName);
    SQLColumnDefinition findColumn(long columNameHash);

    bool matchIndex(string columnName);

    bool matchKey(string columnName);

    SchemaObjectType getType();

    string getName();
    long nameHashCode64();

    long getRowCount();
}
