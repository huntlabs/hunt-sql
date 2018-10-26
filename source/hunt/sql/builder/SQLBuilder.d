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

module hunt.sql.builder.SQLBuilder;


public interface SQLBuilder {


    SQLBuilder select(string[] column...);

    SQLBuilder selectWithAlias(string column, string _alias);

    SQLBuilder from(string table);

    SQLBuilder from(string table, string _alias);

    SQLBuilder orderBy(string[] columns...);

    SQLBuilder groupBy(string expr);

    SQLBuilder having(string expr);

    SQLBuilder into(string expr);

    SQLBuilder limit(int rowCount);

    SQLBuilder offset(int offset);

    SQLBuilder limit(int rowCount, int offset);

    SQLBuilder where(string sql);

    SQLBuilder whereAnd(string sql);

    SQLBuilder whereOr(string sql);

    SQLBuilder join(string table , string _alias = null, string cond = null);

    SQLBuilder innerJoin(string table , string _alias = null, string cond = null);

    SQLBuilder leftJoin(string table , string _alias = null, string cond = null);

    SQLBuilder rightJoin(string table , string _alias = null, string cond = null);

    string toString();
}
