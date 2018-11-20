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
module hunt.sql.util.MySqlUtils;

import hunt.sql.util.FnvHash;
import hunt.sql.util.Utils;
import hunt.container;
import std.uni;
import std.string;

public class MySqlUtils {

    private static Set!(string) keywords;
    public static bool isKeyword(string name) {
        if (name is null) {
            return false;
        }

        string name_lower = toLower(name);

        Set!(string) words = keywords;

        if (words is null) {
            words = new HashSet!(string)();
            Utils.loadFromFile("entity/sql/resource/mysql/keywords", words);
            keywords = words;
        }

        return words.contains(name_lower);
    }
}
