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
module hunt.sql.util.PGUtils;

import hunt.sql.util.FnvHash;
import hunt.sql.util.Utils;
import hunt.container;
import std.uni;
import std.string;

public class PGUtils {

    // public static XAConnection createXAConnection(Connection physicalConn) throws SQLException {
    //     return new PGXAConnection((BaseConnection) physicalConn);
    // }

    // public static List!(string) showTables(Connection conn) throws SQLException {
    //     List!(string) tables = new ArrayList!(string)();

    //     Statement stmt = null;
    //     ResultSet rs = null;
    //     try {
    //         stmt = conn.createStatement();
    //         rs = stmt.executeQuery("SELECT tablename FROM pg_catalog.pg_tables where schemaname not in ('pg_catalog', 'information_schema', 'sys')");
    //         while (rs.next()) {
    //             string tableName = rs.getString(1);
    //             tables.add(tableName);
    //         }
    //     } finally {
    //         DBType.close(rs);
    //         DBType.close(stmt);
    //     }

    //     return tables;
    // }

    private static Set!(string) keywords;
    public static bool isKeyword(string name) {
        if (name is null) {
            return false;
        }

        string name_lower = toLower(name);

        Set!(string) words = keywords;

        if (words is null) {
            words = new HashSet!(string)();
            Utils.loadFromFile("entity/sql/META-INF/postgresql/keywords", words);
            keywords = words;
        }

        return words.contains(name_lower);
    }

    private  static long[] pseudoColumnHashCodes;
    static this(){
        long[] array = [
                FnvHash.Constants.CURRENT_TIMESTAMP
        ];
        // Arrays.sort(array);
        pseudoColumnHashCodes = array;
    }

    public static bool isPseudoColumn(long hash) {
        return search(pseudoColumnHashCodes, hash) >= 0;
    }
}
