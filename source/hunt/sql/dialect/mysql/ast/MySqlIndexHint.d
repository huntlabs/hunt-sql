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
module hunt.sql.dialect.mysql.ast.MySqlIndexHint;
import hunt.sql.dialect.mysql.ast.MySqlHint;
import std.uni;

public interface MySqlIndexHint : MySqlHint {
    public static struct Option {
        enum Option JOIN = Option("JOIN");
        enum Option ORDER_BY = Option("ORDER BY");
        enum Option GROUP_BY = Option("GROUP BY");
        
        public  string name;
        public  string name_lcase;
        
        this(string name) {
            this.name = name;
            this.name_lcase = toLower(name);
        }

        bool opEquals(const Option h) nothrow {
            return name == h.name ;
        } 

        bool opEquals(ref const Option h) nothrow {
            return name == h.name ;
        }
    }
}
