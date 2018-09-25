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
module hunt.sql.dialect.mysql.ast.clause.MySqlCursorDeclareStatement;

import hunt.sql.ast.SQLName;
import hunt.sql.ast.expr.SQLIdentifierExpr;
import hunt.sql.ast.statement.SQLSelect;
import hunt.sql.ast.statement.SQLSelectStatement;
import hunt.sql.dialect.mysql.ast.statement.MySqlStatementImpl;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;

public class MySqlCursorDeclareStatement : MySqlStatementImpl{
	
	alias accept0 = MySqlStatementImpl.accept0;
	//cursor name
	private SQLName cursorName;
	//select statement
	private SQLSelect select;
	
	public SQLName getCursorName() {
		return cursorName;
	}
	
	public void setCursorName(SQLName cursorName) {
		if (cursorName !is null) {
			cursorName.setParent(this);
		}
		this.cursorName = cursorName;
	}

	public void setCursorName(string cursorName) {
		this.setCursorName(new SQLIdentifierExpr(cursorName));
	}

	public SQLSelect getSelect() {
		return select;
	}

	public void setSelect(SQLSelect select) {
		if (select !is null) {
			select.setParent(this);
		}
		this.select = select;
	}

	override
	public void accept0(MySqlASTVisitor visitor) {
		 if (visitor.visit(this)) {
	         acceptChild(visitor, select);
	        }
	     visitor.endVisit(this);
		
	}

}
