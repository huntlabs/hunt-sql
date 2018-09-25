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
module hunt.sql.dialect.mysql.ast.clause.MySqlStatementType;

import hunt.sql.ast.SQLStatement;
import hunt.sql.ast.statement;
import hunt.sql.dialect.mysql.ast.statement.MySqlDeleteStatement;
import hunt.sql.dialect.mysql.ast.statement.MySqlInsertStatement;
import hunt.sql.dialect.mysql.ast.statement.MySqlUpdateStatement;


public struct MySqlStatementType {
	//select statement
	enum  MySqlStatementType SELECT = MySqlStatementType("SQLSelectStatement");
	//update statement
	enum  MySqlStatementType UPDATE = MySqlStatementType("MySqlUpdateStatement");
	//insert statement
	enum  MySqlStatementType INSERT = MySqlStatementType("MySqlInsertStatement");
	//delete statement
	enum  MySqlStatementType DELETE = MySqlStatementType("MySqlDeleteStatement");
	//while statement
	enum  MySqlStatementType WHILE = MySqlStatementType("SQLWhileStatement");
	//begin-end
	enum  MySqlStatementType IF = MySqlStatementType("SQLIfStatement");
	//begin-end
	enum  MySqlStatementType LOOP = MySqlStatementType("SQLLoopStatement");
	//begin-end
	enum  MySqlStatementType BLOCK = MySqlStatementType("SQLBlockStatement");
	//declare statement
	enum  MySqlStatementType DECLARE = MySqlStatementType("MySqlDeclareStatement");
	//select into
	enum  MySqlStatementType SELECTINTO = MySqlStatementType("MySqlSelectIntoStatement");
	//case
	enum  MySqlStatementType CASE = MySqlStatementType("MySqlCaseStatement");
	
	enum MySqlStatementType UNDEFINED = MySqlStatementType("");
	
	static MySqlStatementType[] _types;

	// static this()
	// {
	// 	_types = [SELECT,UPDATE,INSERT,DELETE,WHILE,IF,LOOP,BLOCK,DECLARE,SELECTINTO,CASE,UNDEFINED];
	// }
	
	static MySqlStatementType[] values()
	{
		return _types;
	}

	public  string name;

	// this(){
    //     this("");
    // }

	this(string name){
        this.name = name;
    }
	public static MySqlStatementType getType(SQLStatement stmt)
	{
		 foreach (MySqlStatementType type ; MySqlStatementType.values()) {
             if (type.name == typeof(stmt).stringof) {
                 return type;
             }
         }
		 return UNDEFINED;
	}

	bool opEquals(const MySqlStatementType h) nothrow {
        return name == h.name ;
    } 

    bool opEquals(ref const MySqlStatementType h) nothrow {
        return name == h.name ;
    } 
}
