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
module hunt.sql.visitor.ExportTableAliasVisitor;

import hunt.sql.visitor.SQLASTVisitorAdapter;
import hunt.sql.ast.statement.SQLTableSource;
import hunt.sql.ast.statement.SQLExprTableSource;
import hunt.util.string;
import hunt.container;

 public  class ExportTableAliasVisitor : SQLASTVisitorAdapter {
        alias visit = SQLASTVisitorAdapter.visit;

        private Map!(string, SQLTableSource) aliasMap;

        this()
        {
            aliasMap = new HashMap!(string, SQLTableSource)();
        }

        override public bool visit(SQLExprTableSource x) {
            string _alias = x.getAlias();
            aliasMap.put(_alias, x);
            return true;
        }

        public Map!(string, SQLTableSource) getAliasMap() {
            return aliasMap;
        }
    }