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
module hunt.sql.ast.statement.SQLUnionOperator;
import std.uni;

public struct SQLUnionOperator {
    enum SQLUnionOperator UNION = SQLUnionOperator("UNION");
    enum SQLUnionOperator UNION_ALL = SQLUnionOperator("UNION ALL");
    enum SQLUnionOperator MINUS = SQLUnionOperator("MINUS"); 
    enum SQLUnionOperator EXCEPT = SQLUnionOperator("EXCEPT");
    enum SQLUnionOperator INTERSECT = SQLUnionOperator("INTERSECT");
    enum SQLUnionOperator DISTINCT = SQLUnionOperator("UNION DISTINCT");

    public  string name;
    public  string name_lcase;

    private this(string name){
        this.name = name;
        this.name_lcase = toLower(name);
    }

     bool opEquals(const SQLUnionOperator h) nothrow {
        return name == h.name ;
    } 

    bool opEquals(ref const SQLUnionOperator h) nothrow {
        return name == h.name ;
    }

    public string toString() {
        return name;
    }
}
