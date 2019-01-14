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
module hunt.sql.dialect.mysql.ast.expr.MySqlMatchAgainstExpr;



import hunt.collection;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLExprImpl;
import hunt.sql.ast.SQLObject;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.dialect.mysql.ast.expr.MySqlExpr;
import std.uni;

public class MySqlMatchAgainstExpr : SQLExprImpl , MySqlExpr {

    private List!(SQLExpr)  columns;

    private SQLExpr        against;

    private SearchModifier searchModifier;

    this(){
        columns = new ArrayList!(SQLExpr)();
    }

    override public MySqlMatchAgainstExpr clone() {
        MySqlMatchAgainstExpr x = new MySqlMatchAgainstExpr();
        foreach (SQLExpr column ; columns) {
            SQLExpr column2 = column.clone();
            column2.setParent(x);
            x.columns.add(column2);
        }
        if (against !is null) {
            x.setAgainst(against.clone());
        }
        x.searchModifier = searchModifier;
        return x;
    }

    public List!(SQLExpr) getColumns() {
        return columns;
    }

    public void setColumns(List!(SQLExpr) columns) {
        this.columns = columns;
    }

    public SQLExpr getAgainst() {
        return against;
    }

    public void setAgainst(SQLExpr against) {
        if (against !is null) {
            against.setParent(this);
        }
        this.against = against;
    }

    public SearchModifier getSearchModifier() {
        return searchModifier;
    }

    public void setSearchModifier(SearchModifier searchModifier) {
        this.searchModifier = searchModifier;
    }

    public static struct SearchModifier {
        enum SearchModifier IN_BOOLEAN_MODE =  SearchModifier("IN BOOLEAN MODE"); // 
        enum SearchModifier IN_NATURAL_LANGUAGE_MODE =  SearchModifier("IN NATURAL LANGUAGE MODE"); //
        enum SearchModifier IN_NATURAL_LANGUAGE_MODE_WITH_QUERY_EXPANSION =  SearchModifier("IN NATURAL LANGUAGE MODE WITH QUERY EXPANSION");
        enum SearchModifier WITH_QUERY_EXPANSION =   SearchModifier("WITH QUERY EXPANSION");

        public  string name;
        public  string name_lcase;

        

        this(string name){
            this.name = name;
            this.name_lcase = toLower(name);
        }

        bool opEquals(const SearchModifier h) nothrow {
        return name == h.name ;
        } 

        bool opEquals(ref const SearchModifier h) nothrow {
            return name == h.name ;
        } 
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        MySqlASTVisitor mysqlVisitor = cast(MySqlASTVisitor) visitor;
        if (mysqlVisitor.visit(this)) {
            acceptChild!SQLExpr(visitor, this.columns);
            acceptChild(visitor, this.against);
        }
        mysqlVisitor.endVisit(this);
    }

    override
    public List!SQLObject getChildren() {
        List!(SQLObject) children = new ArrayList!(SQLObject)();
        children.addAll(cast(List!SQLObject)(this.columns));
        children.add(this.against);
        return children;
    }

    override
    public size_t toHash() @trusted nothrow {
         int prime = 31;
        size_t result = 1;
        result = prime * result + ((against is null) ? 0 : (cast(Object)against).toHash());
        result = prime * result + ((columns is null) ? 0 : (cast(Object)columns).toHash());
        result = prime * result + hashOf(searchModifier);
        return result;
    }

    override
    public bool opEquals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj is null) {
            return false;
        }
        // if ( typeid(this) != typeid(obj)) {
        //     return false;
        // }
        MySqlMatchAgainstExpr other = cast(MySqlMatchAgainstExpr) obj;
        if(other is null)
            return false;
        if (against is null) {
            if (other.against !is null) {
                return false;
            }
        } else if (!(cast(Object)(against)).opEquals(cast(Object)(other.against))) {
            return false;
        }
        if (columns is null) {
            if (other.columns !is null) {
                return false;
            }
        } else if (!(cast(Object)(columns)).opEquals(cast(Object)(other.columns))) {
            return false;
        }
        if (searchModifier != other.searchModifier) {
            return false;
        }
        return true;
    }

}
