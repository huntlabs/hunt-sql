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
module hunt.sql.dialect.mysql.ast.statement.MySqlShowEngineStatement;

import hunt.sql.ast.SQLExpr;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;
import hunt.sql.dialect.mysql.ast.statement.MySqlStatementImpl;
import hunt.sql.dialect.mysql.ast.statement.MySqlShowStatement;

public class MySqlShowEngineStatement : MySqlStatementImpl , MySqlShowStatement {
    alias accept0 = MySqlStatementImpl.accept0;
    private SQLExpr name;
    private Option  option;

    override public void accept0(MySqlASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, name);
        }
        visitor.endVisit(this);
    }

    public SQLExpr getName() {
        return name;
    }

    public void setName(SQLExpr name) {
        this.name = name;
    }

    public Option getOption() {
        return option;
    }

    public void setOption(Option option) {
        this.option = option;
    }

    public static struct Option {
        enum Option STATUS = Option("STATUS");
        enum Option MUTEX = Option("MUTEX");

        private string _name;

        this(string name)
        {
            _name = name;
        }

        @property string name()
        {
            return _name;
        }

        bool opEquals(const Option h) nothrow {
        return _name == h._name ;
        } 

        bool opEquals(ref const Option h) nothrow {
            return _name == h._name ;
        }
    }
}
