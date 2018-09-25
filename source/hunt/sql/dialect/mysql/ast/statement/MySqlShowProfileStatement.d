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
module hunt.sql.dialect.mysql.ast.statement.MySqlShowProfileStatement;


import hunt.container;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLLimit;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;
import hunt.sql.dialect.mysql.ast.statement.MySqlStatementImpl;
import hunt.sql.dialect.mysql.ast.statement.MySqlShowStatement;

public class MySqlShowProfileStatement : MySqlStatementImpl , MySqlShowStatement {
    alias accept0 = MySqlStatementImpl.accept0;
    public static class Type {
        public static  Type ALL ;
        public static  Type BLOCK_IO;
        public static  Type CONTEXT_SWITCHES ;
        public static  Type CPU ;
        public static  Type IPC ;
        public static  Type MEMORY ;
        public static  Type PAGE_FAULTS ;
        public static  Type SOURCE ;
        public static  Type SWAPS ;

        // static this()
        // {
        //     ALL = new Type("ALL");
        //     BLOCK_IO = new Type("BLOCK IO");
        //     CONTEXT_SWITCHES = new Type("CONTEXT SWITCHES");
        //     CPU = new Type("CPU");
        //     IPC = new Type("IPC");
        //     MEMORY = new Type("MEMORY");
        //     PAGE_FAULTS = new Type("PAGE FAULTS");
        //     SOURCE = new Type("SOURCE");
        //     SWAPS = new Type("SWAPS");
        // }

        public  string name;

        this(string name){
            this.name = name;
        }

        bool opEquals(const Type h) nothrow {
            return name == h.name ;
        } 

        bool opEquals(ref const Type h) nothrow {
            return name == h.name ;
        }
    }

    private List!(Type) types;

    private SQLExpr    forQuery;

    private SQLLimit limit;

    this(){
        types = new ArrayList!(Type)();
    }

    override public void accept0(MySqlASTVisitor visitor) {
        visitor.visit(this);
        visitor.endVisit(this);
    }

    public List!(Type) getTypes() {
        return types;
    }

    public SQLExpr getForQuery() {
        return forQuery;
    }

    public void setForQuery(SQLExpr forQuery) {
        this.forQuery = forQuery;
    }

    public SQLLimit getLimit() {
        return limit;
    }

    public void setLimit(SQLLimit limit) {
        this.limit = limit;
    }

    

}
