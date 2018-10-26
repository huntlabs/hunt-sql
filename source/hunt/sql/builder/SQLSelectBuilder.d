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
import hunt.sql.builder.SQLBuilder;


abstract class SQLSelectBuilder : SQLBuilder {

    SQLBuilder select(string[] column...)
    {
        return this;
    }

    SQLBuilder selectWithAlias(string column, string _alias)
    {
        return this;
    }

    SQLBuilder from(string table)
    {
        return this;
    }

    SQLBuilder from(string table, string _alias)
    {
        return this;
    }

    SQLBuilder orderBy(string[] columns...)
    {
        return this;
    }

    SQLBuilder groupBy(string expr)
    {
        return this;
    }

    SQLBuilder having(string expr)
    {
        return this;
    }

    SQLBuilder into(string expr)
    {
        return this;
    }

    SQLBuilder limit(int rowCount)
    {
        return this;
    }

    SQLBuilder offset(int offset)
    {
        return this;
    }

    SQLBuilder limit(int rowCount, int offset)
    {
        return this;
    }

    SQLBuilder where(string sql)
    {
        return this;
    }

    SQLBuilder whereAnd(string sql)
    {
        return this;
    }

    SQLBuilder whereOr(string sql)
    {
        return this;
    }

    SQLBuilder join(string table , string _alias = null, string cond = null)
    {
        return this;
    }

    SQLBuilder innerJoin(string table , string _alias = null, string cond = null)
    {
        return this;
    }

    SQLBuilder leftJoin(string table , string _alias = null, string cond = null)
    {
        return this;
    }

    SQLBuilder rightJoin(string table , string _alias = null, string cond = null)
    {
        return this;
    }

    override string toString()
    {
        return "SQLSelectBuilder";
    }
}
