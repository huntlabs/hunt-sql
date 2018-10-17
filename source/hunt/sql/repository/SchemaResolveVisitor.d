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
module hunt.sql.repository.SchemaResolveVisitor;

import hunt.sql.ast.SQLDeclareItem;
import hunt.sql.ast.SQLObject;
import hunt.sql.ast.statement.SQLTableSource;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.repository.SchemaRepository;

import hunt.container;
import hunt.lang;
/**
 * Created by wenshao on 03/08/2017.
 */
public interface SchemaResolveVisitor : SQLASTVisitor {

    bool isEnabled(Option option);

    public static struct Option {
        enum Option ResolveAllColumn = Option(0);
        enum Option ResolveIdentifierAlias = Option(1);
        private this(int ord) {
            mask = (1 << ord);
        }

        public  int mask;

        public static int of(Option[] options...) {
            if (options is null) {
                return 0;
            }

            int value = 0;

            foreach(Option option ; options) {
                value |= option.mask;
            }

            return value;
        }

        bool opEquals(const Option h) nothrow {
        return mask == h.mask ;
        } 

        bool opEquals(ref const Option h) nothrow {
            return mask == h.mask ;
        } 
    }

    SchemaRepository getRepository();

    Context getContext();
    Context createContext(SQLObject object);
    void popContext();

    static class Context {
        public  Context parent;
        public  SQLObject object;

        private SQLTableSource tableSource;

        private SQLTableSource from;

        private Map!(Long, SQLTableSource) tableSourceMap;

        protected Map!(Long, SQLDeclareItem) declares;

        public this(SQLObject object, Context parent) {
            this.object = object;
            this.parent = parent;
        }

        public SQLTableSource getFrom() {
            return from;
        }

        public void setFrom(SQLTableSource from) {
            this.from = from;
        }

        public SQLTableSource getTableSource() {
            return tableSource;
        }

        public void setTableSource(SQLTableSource tableSource) {
            this.tableSource = tableSource;
        }

        public void addTableSource(long alias_hash, SQLTableSource tableSource) {
            tableSourceMap.put(new Long(alias_hash), tableSource);
        }

        public void declare(SQLDeclareItem x) {
            if (declares is null) {
                declares = new HashMap!(Long, SQLDeclareItem)();
            }
            declares.put(new Long(x.getName().nameHashCode64()), x);
        }

        public  SQLDeclareItem findDeclare(long nameHash) {
            if (declares is null) {
                return null;
            }
            return declares.get(new Long(nameHash));
        }
    }
}
