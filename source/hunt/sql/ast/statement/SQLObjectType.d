/*
 * Copyright 2015-2018 HuntLabs.cn
 *
 * Licensed under the Apache License; Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing; software
 * distributed under the License is distributed on an "AS IS" BASIS;
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND; either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
module hunt.sql.ast.statement.SQLObjectType;
import std.uni;

public struct SQLObjectType {
   enum SQLObjectType TABLE = SQLObjectType("TABLE"); // 
   enum SQLObjectType FUNCTION = SQLObjectType("FUNCTION"); // 
   enum SQLObjectType PROCEDURE = SQLObjectType("PROCEDURE"); // 
   enum SQLObjectType USER = SQLObjectType("USER"); //
   enum SQLObjectType DATABASE = SQLObjectType("DATABASE"); //
   enum SQLObjectType ROLE = SQLObjectType("ROLE"); // 
   enum SQLObjectType PROJECT = SQLObjectType("PROJECT"); // 
   enum SQLObjectType PACKAGE = SQLObjectType("PACKAGE"); // 
   enum SQLObjectType RESOURCE = SQLObjectType("RESOURCE"); // 
   enum SQLObjectType INSTANCE = SQLObjectType("INSTANCE"); // 
   enum SQLObjectType JOB = SQLObjectType("JOB"); // 
   enum SQLObjectType VOLUME = SQLObjectType("VOLUME"); // 
   enum SQLObjectType OfflineModel = SQLObjectType("OFFLINEMODEL"); // 
   enum SQLObjectType XFLOW = SQLObjectType("XFLOW"); // for odps
    
    public  string name;
    public  string name_lcase;
    
    this(string name) {
        this.name = name;
        this.name_lcase = toLower(name);
    }

     bool opEquals(const SQLObjectType h) nothrow {
        return name == h.name ;
    } 

    bool opEquals(ref const SQLObjectType h) nothrow {
        return name == h.name ;
    }
}
