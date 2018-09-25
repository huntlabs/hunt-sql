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
module hunt.sql.dialect.mysql.ast.clause.MySqlSelectIntoStatement;


import hunt.container;
import hunt.sql.ast.SQLObject;

import hunt.sql.ast.statement.SQLSelect;
import hunt.sql.dialect.mysql.ast.statement.MySqlStatementImpl;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;
import hunt.sql.ast.SQLExpr;

public class MySqlSelectIntoStatement : MySqlStatementImpl{

	alias accept0 = MySqlStatementImpl.accept0;

	//select statement
	private SQLSelect select;
	//var list
	private List!(SQLExpr) varList;

	this(){
		varList=new ArrayList!(SQLExpr)();
	}
	
	public SQLSelect getSelect() {
		return select;
	}

	public void setSelect(SQLSelect select) {
		this.select = select;
	}

	public List!(SQLExpr) getVarList() {
		return varList;
	}

	public void setVarList(List!(SQLExpr) varList) {
		this.varList = varList;
	}

	
	
	override
	public void accept0(MySqlASTVisitor visitor) {
		if (visitor.visit(this)) {
            acceptChild(visitor, select);
            acceptChild!SQLExpr(visitor, varList);
        }
        visitor.endVisit(this);
	}

}
