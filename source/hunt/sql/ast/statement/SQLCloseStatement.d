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
module hunt.sql.ast.statement.SQLCloseStatement;

import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLObject;
import hunt.sql.ast.SQLStatementImpl;
import hunt.sql.ast.expr.SQLIdentifierExpr;
import hunt.sql.visitor.SQLASTVisitor;

import hunt.container;

/**
 * 
 * MySql cursor close statement
 */
public class SQLCloseStatement : SQLStatementImpl{
	
	//cursor name
	private SQLName cursorName;
	
	public SQLName getCursorName() {
		return cursorName;
	}

	public void setCursorName(string cursorName) {
		setCursorName(new SQLIdentifierExpr(cursorName));
	}
	
	public void setCursorName(SQLName cursorName) {
		if (cursorName !is null) {
			cursorName.setParent(this);
		}
		this.cursorName = cursorName;
	}

	
	override  protected void accept0(SQLASTVisitor visitor) {
		if (visitor.visit(this)) {
			acceptChild(visitor, cursorName);
		}
	    visitor.endVisit(this);
		
	}

	override
	public List!SQLObject getChildren() {
		// return Collections.emptyList!(SQLObject)();
        List!SQLObject ls = new ArrayList!SQLObject();
		return ls;
	}
}
