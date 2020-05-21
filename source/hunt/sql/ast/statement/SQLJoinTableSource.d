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
module hunt.sql.ast.statement.SQLJoinTableSource;


import hunt.collection;

import hunt.sql.SQLUtils;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLReplaceable;
import hunt.sql.ast.expr.SQLBinaryOpExpr;
import hunt.sql.ast.expr.SQLIdentifierExpr;
import hunt.sql.ast.expr.SQLPropertyExpr;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.util.FnvHash;
import hunt.sql.ast.statement.SQLExprTableSource;
import hunt.sql.ast.statement.SQLTableSourceImpl;
import hunt.sql.ast.statement.SQLTableSource;
import hunt.sql.ast.statement.SQLColumnDefinition;
import hunt.util.StringBuilder;
import std.uni;
import hunt.sql.ast.SQLObject;

public class SQLJoinTableSource : SQLTableSourceImpl , SQLReplaceable {

    protected SQLTableSource      left;
    protected JoinType            joinType;
    protected SQLTableSource      right;
    protected SQLExpr             condition;
    protected  List!SQLExpr _using;


    protected bool             natural = false;

    public this(string alias_p){
        _using = new ArrayList!SQLExpr();
        super(alias_p);
    }

    public this(){
        _using = new ArrayList!SQLExpr();
    }

    public this(SQLTableSource left, JoinType joinType, SQLTableSource right, SQLExpr condition){
        this();
        this.setLeft(left);
        this.setJoinType(joinType);
        this.setRight(right);
        this.setCondition(condition);
    }

    public this(SQLTableSource left, JoinType joinType, SQLTableSource right){
        this();
        this.setLeft(left);
        this.setJoinType(joinType);
        this.setRight(right);
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, this.left);
            acceptChild(visitor, this.right);
            acceptChild(visitor, this.condition);
            acceptChild!SQLExpr(visitor, this._using);
        }

        visitor.endVisit(this);
    }

    public JoinType getJoinType() {
        return this.joinType;
    }

    public void setJoinType(JoinType joinType) {
        this.joinType = joinType;
    }

    public SQLTableSource getLeft() {
        return this.left;
    }

    public void setLeft(SQLTableSource left) {
        if (left !is null) {
            left.setParent(this);
        }
        this.left = left;
    }

    public void setLeft(string tableName, string alias_p) {
        SQLExprTableSource tableSource;
        if (tableName is null || tableName.length == 0) {
            tableSource = null;
        } else {
            tableSource = new SQLExprTableSource(new SQLIdentifierExpr(tableName), alias_p);
        }
        this.setLeft(tableSource);
    }

    public void setRight(string tableName, string alias_p) {
        SQLExprTableSource tableSource;
        if (tableName is null || tableName.length == 0) {
            tableSource = null;
        } else {
            tableSource = new SQLExprTableSource(new SQLIdentifierExpr(tableName), alias_p);
        }
        this.setRight(tableSource);
    }

    public SQLTableSource getRight() {
        return this.right;
    }

    public void setRight(SQLTableSource right) {
        if (right !is null) {
            right.setParent(this);
        }
        this.right = right;
    }

    public SQLExpr getCondition() {
        return this.condition;
    }

    public void setCondition(SQLExpr condition) {
        if (condition !is null) {
            condition.setParent(this);
        }
        this.condition = condition;
    }

    public void addConditionn(SQLExpr condition) {
        this.condition = SQLBinaryOpExpr.and(this.condition, condition);
    }

    public void addConditionnIfAbsent(SQLExpr condition) {
        if (this.containsCondition(condition)) {
            return;
        }
        this.condition = SQLBinaryOpExpr.and(this.condition, condition);
    }

    public bool containsCondition(SQLExpr condition) {
        if (this.condition is null) {
            return false;
        }

        if ((cast(Object)(this.condition)).opEquals(cast(Object)(condition))) {
            return false;
        }

        if (cast(SQLBinaryOpExpr)(this.condition) !is null ) {
            return (cast(SQLBinaryOpExpr) this.condition).contains(condition);
        }

        return false;
    }

    public List!SQLExpr getUsing() {
        return this._using;
    }

    public bool isNatural() {
        return natural;
    }

    public void setNatural(bool natural) {
        this.natural = natural;
    }

    override public void output(StringBuilder buf) {
        this.left.output(buf);
        buf.append(' ');
        buf.append(JoinType.toString(this.joinType));
        buf.append(' ');
        this.right.output(buf);

        if (this.condition !is null) {
            buf.append(" ON ");
            this.condition.output(buf);
        }
    }

    override
    public bool opEquals(Object o) {
        if (this == o) return true;
        if (o is null || typeid(this) != typeid(o)) return false;

        SQLJoinTableSource that = cast(SQLJoinTableSource) o;

        if (natural != that.natural) return false;
        if (left !is null ? !(cast(Object)(left)).opEquals(cast(Object)(that.left)) : that.left !is null) return false;
        if (joinType != that.joinType) return false;
        if (right !is null ? !(cast(Object)(right)).opEquals(cast(Object)(that.right)) : that.right !is null) return false;
        if (condition !is null ? !(cast(Object)(condition)).opEquals(cast(Object)(that.condition)) : that.condition !is null) return false;
        return _using !is null ? (cast(Object)(_using)).opEquals(cast(Object)(that._using)) : that._using is null;
    }

    override
    public bool replace(SQLExpr expr, SQLExpr target) {
        if (condition == expr) {
            setCondition(target);
            return true;
        }

        return false;
    }

    public static struct  JoinType {
        enum JoinType COMMA = JoinType(","); //
        enum JoinType JOIN = JoinType("JOIN"); //
        enum JoinType INNER_JOIN = JoinType("INNER JOIN"); //
        enum JoinType CROSS_JOIN = JoinType("CROSS JOIN"); //
        enum JoinType NATURAL_JOIN = JoinType("NATURAL JOIN"); //
        enum JoinType NATURAL_INNER_JOIN = JoinType("NATURAL INNER JOIN"); //
        enum JoinType LEFT_OUTER_JOIN = JoinType("LEFT JOIN"); //
        enum JoinType LEFT_SEMI_JOIN = JoinType("LEFT SEMI JOIN"); //
        enum JoinType LEFT_ANTI_JOIN = JoinType("LEFT ANTI JOIN"); //
        enum JoinType RIGHT_OUTER_JOIN = JoinType("RIGHT JOIN"); //
        enum JoinType FULL_OUTER_JOIN = JoinType("FULL JOIN");//
        enum JoinType STRAIGHT_JOIN = JoinType("STRAIGHT_JOIN"); //
        enum JoinType OUTER_APPLY = JoinType("OUTER APPLY");//
        enum JoinType CROSS_APPLY = JoinType("CROSS APPLY");

        public  string name;
        public  string name_lcase;

        this(string name){
            this.name = name;
            this.name_lcase = toLower(name);
        }

        public static string toString(JoinType joinType) {
            return joinType.name;
        }

        bool opEquals(const JoinType h) nothrow {
            return name == h.name ;
        } 

        bool opEquals(ref const JoinType h) nothrow {
            return name == h.name ;
        }
    }


    public void cloneTo(SQLJoinTableSource x) {
        x._alias = _alias;

        if (left !is null) {
            x.setLeft(left.clone());
        }

        x.joinType = joinType;

        if (right !is null) {
            x.setRight(right.clone());
        }

        if(condition !is null){
            x.setCondition(condition);
        }

        foreach (SQLExpr item ; _using) {
            SQLExpr item2 = item.clone();
            item2.setParent(x);
            x._using.add(item2);
        }

        x.natural = natural;
    }

    override public SQLJoinTableSource clone() {
        SQLJoinTableSource x = new SQLJoinTableSource();
        cloneTo(x);
        return x;
    }

    public void reverse() {
        SQLTableSource temp = left;
        left = right;
        right = temp;

        if (cast(SQLJoinTableSource)(left) !is null ) {
            (cast(SQLJoinTableSource) left).reverse();
        }

        if (cast(SQLJoinTableSource)(right) !is null ) {
            (cast(SQLJoinTableSource) right).reverse();
        }
    }

    /**
     * a inner_join (b inner_join c) -&lt; a inner_join b innre_join c
     */
    public void rearrangement() {
        if (joinType != JoinType.COMMA && joinType != JoinType.INNER_JOIN) {
            return;
        }
        if (cast(SQLJoinTableSource)(right) !is null ) {
            SQLJoinTableSource rightJoin = cast(SQLJoinTableSource) right;

            if (rightJoin.joinType != JoinType.COMMA && rightJoin.joinType != JoinType.INNER_JOIN) {
                return;
            }

            SQLTableSource a = left;
            SQLTableSource b = rightJoin.getLeft();
            SQLTableSource c = rightJoin.getRight();
            SQLExpr on_ab = condition;
            SQLExpr on_bc = rightJoin.condition;

            setLeft(rightJoin);
            rightJoin.setLeft(a);
            rightJoin.setRight(b);


            bool on_ab_match = false;
            if (cast(SQLBinaryOpExpr)(on_ab) !is null ) {
                SQLBinaryOpExpr on_ab_binaryOpExpr = cast(SQLBinaryOpExpr) on_ab;
                if ( cast(SQLPropertyExpr)(on_ab_binaryOpExpr.getLeft()) !is null
                        && (cast(SQLPropertyExpr)on_ab_binaryOpExpr.getRight()) !is null ) {
                    string leftOwnerName = (cast(SQLPropertyExpr) on_ab_binaryOpExpr.getLeft()).getOwnernName();
                    string rightOwnerName = (cast(SQLPropertyExpr) on_ab_binaryOpExpr.getRight()).getOwnernName();

                    if (rightJoin.containsAlias(leftOwnerName) && rightJoin.containsAlias(rightOwnerName)) {
                        on_ab_match = true;
                    }
                }
            }

            if (on_ab_match) {
                rightJoin.setCondition(on_ab);
            } else {
                rightJoin.setCondition(null);
                on_bc = SQLBinaryOpExpr.and(on_bc, on_ab);
            }

            setRight(c);
            setCondition(on_bc);
        }
    }

    public bool contains(SQLTableSource tableSource, SQLExpr condition) {
        if ((cast(Object)(right)).opEquals(cast(Object)(tableSource))) {
            if (this.condition == condition) {
                return true;
            }

            return this.condition !is null && (cast(Object)(this.condition)).opEquals(cast(Object)(condition));
        }

        if (cast(SQLJoinTableSource)(left) !is null ) {
            SQLJoinTableSource joinLeft = cast(SQLJoinTableSource) left;

            if (cast(SQLJoinTableSource)(tableSource) !is null ) {
                SQLJoinTableSource join = cast(SQLJoinTableSource) tableSource;

                if ((cast(Object)(join.right)).opEquals(cast(Object)(right)) && (cast(Object)(this.condition)).opEquals(cast(Object)(condition)) && (cast(Object)(joinLeft.right)).opEquals(cast(Object)(join.left))) {
                    return true;
                }
            }

            return joinLeft.contains(tableSource, condition);
        }

        return false;
    }

    public bool contains(SQLTableSource tableSource, SQLExpr condition, JoinType joinType) {
        if ((cast(Object)(right)).opEquals(cast(Object)(tableSource))) {
            if (this.condition == condition) {
                return true;
            }

            return this.condition !is null && (cast(Object)(this.condition)).opEquals(cast(Object)(condition)) && this.joinType == joinType;
        }

        if (cast(SQLJoinTableSource)(left) !is null ) {
            SQLJoinTableSource joinLeft = cast(SQLJoinTableSource) left;

            if (cast(SQLJoinTableSource)(tableSource) !is null ) {
                SQLJoinTableSource join = cast(SQLJoinTableSource) tableSource;

                if ((cast(Object)(join.right)).opEquals(cast(Object)(right))
                        && this.condition !is null && (cast(Object)(this.condition)).opEquals(cast(Object)(join.condition))
                        && (cast(Object)(joinLeft.right)).opEquals(cast(Object)(join.left))
                        && this.joinType == join.joinType
                        && joinLeft.condition !is null && (cast(Object)(joinLeft.condition)).opEquals(cast(Object)(condition))
                        && joinLeft.joinType == joinType) {
                    return true;
                }
            }

            return joinLeft.contains(tableSource, condition, joinType);
        }

        return false;
    }

    public SQLJoinTableSource findJoin(SQLTableSource tableSource, JoinType joinType) {
        if ((cast(Object)(right)).opEquals(cast(Object)(tableSource))) {
            if (this.joinType == joinType) {
                return this;
            }
            return null;
        }

        if (cast(SQLJoinTableSource)(left) !is null ) {
            return (cast(SQLJoinTableSource) left).findJoin(tableSource, joinType);
        }

        return null;
    }

    override public bool containsAlias(string alias_p) {
        if (SQLUtils.nameEquals(this._alias, alias_p)) {
            return true;
        }

        if (left !is null && left.containsAlias(alias_p)) {
            return true;
        }

        if (right !is null && right.containsAlias(alias_p)) {
            return true;
        }

        return false;
    }

    override public SQLColumnDefinition findColumn(string columnName) {
        long hash = FnvHash.hashCode64(columnName);
        return findColumn(hash);
    }

    override public SQLColumnDefinition findColumn(long columnNameHash) {
        if (left !is null) {
            SQLColumnDefinition column = left.findColumn(columnNameHash);
            if (column !is null) {
                return column;
            }
        }

        if (right !is null) {
            return right.findColumn(columnNameHash);
        }

        return null;
    }

    override
    public SQLTableSource findTableSourceWithColumn(string columnName) {
        long hash = FnvHash.hashCode64(columnName);
        return findTableSourceWithColumn(hash);
    }

    override public SQLTableSource findTableSourceWithColumn(long columnNameHash) {
        if (left !is null) {
            SQLTableSource tableSource = left.findTableSourceWithColumn(columnNameHash);
            if (tableSource !is null) {
                return tableSource;
            }
        }

        if (right !is null) {
            return right.findTableSourceWithColumn(columnNameHash);
        }

        return null;
    }

    public bool match(string alias_a, string alias_b) {
        if (left is null || right is null) {
            return false;
        }

        if (left.containsAlias(alias_a)
                && right.containsAlias(alias_b)) {
            return true;
        }

        return right.containsAlias(alias_a)
                && left.containsAlias(alias_b);
    }

    public bool conditionContainsTable(string alias_p) {
        if (condition is null) {
            return false;
        }

        if (cast(SQLBinaryOpExpr)(condition) !is null ) {
            return (cast(SQLBinaryOpExpr) condition).conditionContainsTable(alias_p);
        }

        return false;
    }

    public SQLJoinTableSource join(SQLTableSource right, JoinType joinType, SQLExpr condition) {
        SQLJoinTableSource joined = new SQLJoinTableSource(this, joinType, right, condition);
        return joined;
    }

    override public SQLTableSource findTableSource(long alias_hash) {
        if (alias_hash == 0) {
            return null;
        }

        if (aliasHashCode64() == alias_hash) {
            return this;
        }

        SQLTableSource result = left.findTableSource(alias_hash);
        if (result !is null) {
            return result;
        }

        return right.findTableSource(alias_hash);
    }

    public SQLTableSource other(SQLTableSource x) {
        if (left == x) {
            return right;
        }

        if (right == x) {
            return left;
        }

        return null;
    }
}

//  public  struct  JoinType {
//         enum JoinType COMMA = JoinType(","); //
//         enum JoinType JOIN = JoinType("JOIN"); //
//         enum JoinType INNER_JOIN = JoinType("INNER JOIN"); //
//         enum JoinType CROSS_JOIN = JoinType("CROSS JOIN"); //
//         enum JoinType NATURAL_JOIN = JoinType("NATURAL JOIN"); //
//         enum JoinType NATURAL_INNER_JOIN = JoinType("NATURAL INNER JOIN"); //
//         enum JoinType LEFT_OUTER_JOIN = JoinType("LEFT JOIN"); //
//         enum JoinType LEFT_SEMI_JOIN = JoinType("LEFT SEMI JOIN"); //
//         enum JoinType LEFT_ANTI_JOIN = JoinType("LEFT ANTI JOIN"); //
//         enum JoinType RIGHT_OUTER_JOIN = JoinType("RIGHT JOIN"); //
//         enum JoinType FULL_OUTER_JOIN = JoinType("FULL JOIN");//
//         enum JoinType STRAIGHT_JOIN = JoinType("STRAIGHT_JOIN"); //
//         enum JoinType OUTER_APPLY = JoinType("OUTER APPLY");//
//         enum JoinType CROSS_APPLY = JoinType("CROSS APPLY");

//         public  string name;
//         public  string name_lcase;

//         this(string name){
//             this.name = name;
//             this.name_lcase = toLower(name);
//         }

//         public static string toString(JoinType joinType) {
//             return joinType.name;
//         }

//         bool opEquals(const JoinType h) nothrow {
//             return name == h.name ;
//         } 

//         bool opEquals(ref const JoinType h) nothrow {
//             return name == h.name ;
//         }
//     }