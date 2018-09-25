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
module hunt.sql.dialect.mysql.ast.clause.MySqlHandlerType;


public struct MySqlHandlerType {
	//DECLARE处理程序handler_type

	enum MySqlHandlerType CONTINUE = MySqlHandlerType("CONTINUE");
	enum MySqlHandlerType EXIT = MySqlHandlerType("EXIT");
	enum MySqlHandlerType UNDO = MySqlHandlerType("UNDO");

	private string _name;

    @property string name()
    {
        return _name;
    }

    this(string name)
    {
        _name = name;
    }

    bool opEquals(const MySqlHandlerType h) nothrow {
        return _name == h._name ;
    } 

    bool opEquals(ref const MySqlHandlerType h) nothrow {
        return _name == h._name ;
    }
}
