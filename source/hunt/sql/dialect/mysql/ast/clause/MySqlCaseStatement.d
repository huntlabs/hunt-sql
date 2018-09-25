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
module hunt.sql.dialect.mysql.ast.clause.MySqlCaseStatement;


import hunt.container;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLObject;
import hunt.sql.ast.SQLStatement;
import hunt.sql.ast.statement.SQLIfStatement;
import hunt.sql.dialect.mysql.ast.MySqlObjectImpl;
import hunt.sql.dialect.mysql.ast.statement.MySqlStatementImpl;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;

public class MySqlCaseStatement : MySqlStatementImpl{

	alias accept0 = MySqlStatementImpl.accept0;
	//case expr
	private SQLExpr            		  condition;
	//when statement list
	private List!MySqlWhenStatement whenList;
	//else statement
	private SQLIfStatement.Else        elseItem;
	
	this()
	{
		whenList = new ArrayList!(MySqlCaseStatement.MySqlWhenStatement)();
	}

	public SQLExpr getCondition() {
		return condition;
	}

	public void setCondition(SQLExpr condition) {
		this.condition = condition;
	}

	public List!(MySqlWhenStatement) getWhenList() {
		return whenList;
	}

	public void setWhenList(List!(MySqlWhenStatement) whenList) {
		this.whenList = whenList;
	}
	
	public void addWhenStatement(MySqlWhenStatement stmt)
	{
		this.whenList.add(stmt);
	}

	public SQLIfStatement.Else getElseItem() {
		return elseItem;
	}

	public void setElseItem(SQLIfStatement.Else elseItem) {
		this.elseItem = elseItem;
	}

	override
	public void accept0(MySqlASTVisitor visitor) {
		// TODO Auto-generated method stub
		if (visitor.visit(this)) {
            acceptChild(visitor, condition);
            acceptChild!MySqlWhenStatement(visitor, whenList);
            acceptChild(visitor, elseItem);
        }
        visitor.endVisit(this);
	}

	override
	public List!(SQLObject) getChildren() {
		List!(SQLObject) children = new ArrayList!(SQLObject)();
		children.addAll(cast(List!SQLObject)(children));
		children.addAll(cast(List!SQLObject)(whenList));
		children.addAll(cast(List!SQLObject)(whenList));
		if (elseItem !is null) {
			children.add(elseItem);
		}
		return children;
	}


	public static class MySqlWhenStatement : MySqlObjectImpl {

		alias accept0 = MySqlObjectImpl.accept0;

        private SQLExpr            condition;
        private List!(SQLStatement) statements;

		this()
		{
			statements = new ArrayList!(SQLStatement)();
		}

        override
        public void accept0(MySqlASTVisitor visitor) {
            if (visitor.visit(this)) {
                acceptChild(visitor, condition);
                acceptChild!SQLStatement(visitor, statements);
            }
            visitor.endVisit(this);
        }

        public SQLExpr getCondition() {
            return condition;
        }

        public void setCondition(SQLExpr condition) {
            this.condition = condition;
        }

        public List!(SQLStatement) getStatements() {
            return statements;
        }

        public void setStatements(List!(SQLStatement) statements) {
            this.statements = statements;
        }

    }

}
