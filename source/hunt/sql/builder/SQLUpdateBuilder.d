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
module hunt.sql.builder.SQLUpdateBuilder;

public interface SQLUpdateBuilder {

    SQLUpdateBuilder from(string table);

    SQLUpdateBuilder from(string table, string _alias);

    SQLUpdateBuilder limit(int rowCount);

    SQLUpdateBuilder limit(int rowCount, int offset);

    SQLUpdateBuilder where(string sql);

    SQLUpdateBuilder whereAnd(string sql);

    SQLUpdateBuilder whereOr(string sql);

    SQLUpdateBuilder set(string[] items...);
}
