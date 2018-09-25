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
module hunt.sql.dialect.mysql.ast.clause.MySqlDeclareConditionStatement;


import hunt.sql.dialect.mysql.ast.statement.MySqlStatementImpl;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;
import hunt.sql.dialect.mysql.ast.clause.ConditionValue;


public class MySqlDeclareConditionStatement : MySqlStatementImpl{
	
	alias accept0 = MySqlStatementImpl.accept0;
	/*
	DECLARE condition_name CONDITION FOR condition_value

	condition_value:
	    SQLSTATE [VALUE] sqlstate_value
	  | mysql_error_code
	*/
	
	//condition_name
	private string conditionName; 
	//sp statement
	private ConditionValue conditionValue;
	
	public string getConditionName() {
		return conditionName;
	}

	public void setConditionName(string conditionName) {
		this.conditionName = conditionName;
	}

	public ConditionValue getConditionValue() {
		return conditionValue;
	}

	public void setConditionValue(ConditionValue conditionValue) {
		this.conditionValue = conditionValue;
	}

	override
	public void accept0(MySqlASTVisitor visitor) {
		// TODO Auto-generated method stub
		visitor.visit(this);
	    visitor.endVisit(this);
		
	}

}

