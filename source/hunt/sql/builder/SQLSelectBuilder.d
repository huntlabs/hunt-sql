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
module hunt.sql.builder.SQLSelectBuilder;

import hunt.sql.ast.statement.SQLSelectStatement;

public interface SQLSelectBuilder {

    SQLSelectStatement getSQLSelectStatement();

    SQLSelectBuilder select(string[] column...);

    SQLSelectBuilder selectWithAlias(string column, string _alias);

    SQLSelectBuilder from(string table);

    SQLSelectBuilder from(string table, string _alias);

    SQLSelectBuilder orderBy(string[] columns...);

    SQLSelectBuilder groupBy(string expr);

    SQLSelectBuilder having(string expr);

    SQLSelectBuilder into(string expr);

    SQLSelectBuilder limit(int rowCount);

    SQLSelectBuilder limit(int rowCount, int offset);

    SQLSelectBuilder where(string sql);

    SQLSelectBuilder whereAnd(string sql);

    SQLSelectBuilder whereOr(string sql);

    string toString();
}
