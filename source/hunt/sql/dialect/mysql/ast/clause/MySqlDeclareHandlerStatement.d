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
module hunt.sql.dialect.mysql.ast.clause.MySqlDeclareHandlerStatement;


import hunt.collection;

import hunt.sql.ast.SQLStatement;
import hunt.sql.dialect.mysql.ast.statement.MySqlStatementImpl;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;
import hunt.sql.dialect.mysql.ast.clause.ConditionValue;
import hunt.sql.dialect.mysql.ast.clause.MySqlHandlerType;


public class MySqlDeclareHandlerStatement : MySqlStatementImpl{
	
	alias accept0 = MySqlStatementImpl.accept0;
	//DECLARE handler_type HANDLER FOR condition_value[,...] sp_statement
	
	//handler type
	private MySqlHandlerType handleType; 
	//sp statement
	private SQLStatement spStatement;
	
	private List!(ConditionValue) conditionValues;
	
	
	public this() {
		conditionValues = new ArrayList!(ConditionValue)();
	}

	public List!(ConditionValue) getConditionValues() {
		return conditionValues;
	}

	public void setConditionValues(List!(ConditionValue) conditionValues) {
		this.conditionValues = conditionValues;
	}

	public MySqlHandlerType getHandleType() {
		return handleType;
	}

	public void setHandleType(MySqlHandlerType handleType) {
		this.handleType = handleType;
	}

	public SQLStatement getSpStatement() {
		return spStatement;
	}

	public void setSpStatement(SQLStatement spStatement) {
		this.spStatement = spStatement;
	}

	override
	public void accept0(MySqlASTVisitor visitor) {
		if (visitor.visit(this)) {
			acceptChild(visitor, spStatement);
		}
		visitor.endVisit(this);
	}

}

