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
module hunt.sql.dialect.mysql.ast.clause.MySqlIterateStatement;

import hunt.sql.dialect.mysql.ast.statement.MySqlStatementImpl;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;


public class MySqlIterateStatement : MySqlStatementImpl {
	
	alias accept0 = MySqlStatementImpl.accept0;
	
	private string labelName;
	
	override
    public void accept0(MySqlASTVisitor visitor) {
		visitor.visit(this);
        visitor.endVisit(this);
    }

	public string getLabelName() {
		return labelName;
	}

	public void setLabelName(string labelName) {
		this.labelName = labelName;
	}
    
}
