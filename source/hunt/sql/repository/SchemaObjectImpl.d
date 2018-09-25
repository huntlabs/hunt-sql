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
module hunt.sql.repository.SchemaObjectImpl;

import hunt.sql.ast.SQLStatement;
import hunt.sql.ast.statement.SQLColumnDefinition;
import hunt.sql.ast.statement.SQLCreateTableStatement;
import hunt.sql.ast.statement.SQLTableElement;
import hunt.sql.ast.statement.SQLUniqueConstraint;
import hunt.sql.util.FnvHash;
import hunt.sql.repository.SchemaObjectType;
import hunt.sql.repository.SchemaObject;

/**
 * Created by wenshao on 08/06/2017.
 */
public class SchemaObjectImpl : SchemaObject {
    private  string name;
    private  long   hashCode64;

    private  SchemaObjectType type;
    private SQLStatement statement;

    public long rowCount = -1;

    public this(string name, SchemaObjectType type) {
        this(name, type, null);
    }

    public this(string name, SchemaObjectType type, SQLStatement statement) {
        this.name = name;
        this.type = type;
        this.statement = statement;

        this.hashCode64 = FnvHash.hashCode64(name);
    }

    public long nameHashCode64() {
        return hashCode64;
    }

    public static enum Type {
        Sequence, Table, View, Index, Function
    }

    public SQLStatement getStatement() {
        return statement;
    }

    public SQLColumnDefinition findColumn(string columName) {
        long hash = FnvHash.hashCode64(columName);
        return findColumn(hash);
    }

    public SQLColumnDefinition findColumn(long columNameHash) {
        if (statement is null) {
            return null;
        }

        if (cast(SQLCreateTableStatement)(statement) !is null) {
            return (cast(SQLCreateTableStatement) statement).findColumn(columNameHash);
        }

        return null;
    }

    public bool matchIndex(string columnName) {
        if (statement is null) {
            return false;
        }

        if (cast(SQLCreateTableStatement)(statement) !is null) {
            SQLTableElement index = (cast(SQLCreateTableStatement) statement).findIndex(columnName);
            return index !is null;
        }

        return false;
    }

    public bool matchKey(string columnName) {
        if (statement is null) {
            return false;
        }

        if (cast(SQLCreateTableStatement)(statement) !is null) {
            SQLTableElement index = (cast(SQLCreateTableStatement) statement).findIndex(columnName);
            return cast(SQLUniqueConstraint)(index) !is null;
        }

        return false;
    }

    override
    public string getName() {
        return name;
    }

    override
    public SchemaObjectType getType() {
        return type;
    }

    override
    public long getRowCount() {
        return rowCount;
    }
}
