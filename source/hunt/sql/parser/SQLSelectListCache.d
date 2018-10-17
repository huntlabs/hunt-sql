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
module hunt.sql.parser.SQLSelectListCache;

import hunt.sql.ast.statement.SQLSelectQueryBlock;
// import entity.support.logging.Log;
// import entity.support.logging.LogFactory;
import hunt.sql.util.FnvHash;
import hunt.sql.parser.Lexer;

import hunt.container;
import hunt.sql.parser.SQLSelectParser;
import hunt.sql.parser.SQLParserUtils;
import hunt.string;
import hunt.sql.parser.Token;
import std.algorithm.searching;
import hunt.logging;

public class SQLSelectListCache {
    // private  static Log                LOG             = LogFactory.getLog(SQLSelectListCache.class);
    private  string                    dbType;
    private  List!(Entry)               entries;

    this()
    {
        entries         = new ArrayList!(Entry)();
    }

    public this(string dbType) {
        this();
        this.dbType = dbType;
    }

    public void add(string select) {
        if (select is null || select.length == 0) {
            return;
        }

        SQLSelectParser selectParser = SQLParserUtils.createSQLStatementParser(select, dbType)
                                                     .createSQLSelectParser();
        SQLSelectQueryBlock queryBlock = SQLParserUtils.createSelectQueryBlock(dbType);
        selectParser.accept(Token.SELECT);

        selectParser.parseSelectList(queryBlock);

        selectParser.accept(Token.FROM);
        selectParser.accept(Token.EOF);

        string printSql = (cast(Object)(queryBlock)).toString();
        long printSqlHash = FnvHash.fnv1a_64_lower(printSql);
        entries.add(
                new Entry(select.substring(6)
                        , queryBlock
                        , printSql
                        , printSqlHash)
        );

        if (entries.size() > 5) {
            logWarning("SelectListCache is too large.");
        }
    }

    public int getSize() {
        return entries.size();
    }

    public void clear() {
        entries.clear();
    }

    public bool match(Lexer lexer, SQLSelectQueryBlock queryBlock) {
        if (lexer.token != Token.SELECT) {
            return false;
        }

        int pos = lexer.pos;
        string text = lexer.text;

        for (int i = 0; i < entries.size(); i++) {
            Entry entry = entries.get(i);
            string block = entry.sql;
            if (text.startsWith(block, pos)) {
                //SQLSelectQueryBlock queryBlockCached = queryBlockCache.get(i);
                // queryBlockCached.cloneSelectListTo(queryBlock);
                queryBlock.setCachedSelectList(entry.printSql, entry.printSqlHash);

                int len = pos + cast(int)(block.length);
                lexer.reset(len, charAt(text, len), Token.FROM);
                return true;
            }
        }
        return false;
    }

    private static class Entry {
        public  string              sql;
        public  SQLSelectQueryBlock queryBlock;
        public  string              printSql;
        public  long                printSqlHash;

        public this(string sql, SQLSelectQueryBlock queryBlock, string printSql, long printSqlHash) {
            this.sql = sql;
            this.queryBlock = queryBlock;
            this.printSql = printSql;
            this.printSqlHash = printSqlHash;
        }
    }
}
