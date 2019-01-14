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
module hunt.sql.dialect.mysql.ast.clause.MySqlRepeatStatement;


import hunt.collection;
import hunt.sql.ast.SQLObject;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLStatement;
import hunt.sql.dialect.mysql.ast.statement.MySqlStatementImpl;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;


public class MySqlRepeatStatement : MySqlStatementImpl {
	
	alias accept0 = MySqlStatementImpl.accept0;
	
	private string labelName;

	private List!(SQLStatement) statements;
	
	private SQLExpr            condition;

	this()
	{
		statements = new ArrayList!(SQLStatement)();
	}
	
	override
    public void accept0(MySqlASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild!SQLStatement(visitor, statements);
            acceptChild(visitor, condition);
        }
        visitor.endVisit(this);
    }

    public List!(SQLStatement) getStatements() {
        return statements;
    }

    public void setStatements(List!(SQLStatement) statements) {
        this.statements = statements;
    }

	public string getLabelName() {
		return labelName;
	}

	public void setLabelName(string labelName) {
		this.labelName = labelName;
	}
    
	public SQLExpr getCondition() {
		return condition;
	}

	public void setCondition(SQLExpr condition) {
		this.condition = condition;
	}
}
