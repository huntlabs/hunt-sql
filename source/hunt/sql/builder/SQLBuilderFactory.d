/*
 * Copyright 2015-2018 HuntLabs.cn.
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
module hunt.sql.builder.SQLBuilderFactory;

import hunt.sql.builder.impl.SQLDeleteBuilderImpl;
import hunt.sql.builder.impl.SQLSelectBuilderImpl;
import hunt.sql.builder.impl.SQLUpdateBuilderImpl;
import hunt.sql.builder.SQLSelectBuilder;
import hunt.sql.builder.SQLDeleteBuilder;
import hunt.sql.builder.SQLUpdateBuilder;
import hunt.sql.builder.SQLBuilder;

public class SQLBuilderFactory {

    public static SQLBuilder createSQLBuilder(T)(string dbType) {
        return new T(dbType);
    }

    public static SQLBuilder createSQLBuilder(T)(string sql, string dbType) {
        return new T(sql, dbType);
    }

    public static SQLBuilder createSelectSQLBuilder(string dbType) {
        return new SQLSelectBuilderImpl(dbType);
    }
    
    public static SQLBuilder createSelectSQLBuilder(string sql, string dbType) {
        return new SQLSelectBuilderImpl(sql, dbType);
    }

    public static SQLBuilder createDeleteBuilder(string dbType) {
        return new SQLDeleteBuilderImpl(dbType);
    }
    
    public static SQLBuilder createDeleteBuilder(string sql, string dbType) {
        return new SQLDeleteBuilderImpl(sql, dbType);
    }

    public static SQLBuilder createUpdateBuilder(string dbType) {
        return new SQLUpdateBuilderImpl(dbType);
    }
    
    public static SQLBuilder createUpdateBuilder(string sql, string dbType) {
        return new SQLUpdateBuilderImpl(sql, dbType);
    }
}
