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
module hunt.sql.ast.expr.SQLBinaryOpExpr;


import hunt.sql.SQLUtils;
import hunt.sql.ast;
import hunt.sql.visitor.ParameterizedOutputVisitorUtils;
import hunt.sql.visitor.ParameterizedVisitor;
import hunt.sql.visitor.SQLASTOutputVisitor;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.util.Utils;
import hunt.sql.ast.expr.SQLBinaryOperator;
import hunt.collection;
import hunt.sql.ast.expr.SQLExprUtils;
import hunt.sql.ast.expr.SQLNullExpr;
import hunt.sql.ast.expr.SQLBooleanExpr;
import hunt.sql.ast.expr.SQLCharExpr;
import hunt.sql.ast.expr.SQLPropertyExpr;
import hunt.sql.ast.expr.SQLIdentifierExpr;
import hunt.sql.ast.expr.SQLLiteralExpr;
import hunt.sql.ast.expr.SQLVariantRefExpr;

public class SQLBinaryOpExpr : SQLExprImpl , SQLReplaceable//, Serializable 
{

    private static  long   serialVersionUID = 1L;
    public SQLExpr           left;
    public SQLExpr           right;
    public SQLBinaryOperator operator;
    protected string            dbType;

    private bool             bracket  = false;

    // only for parameterized output
    protected  List!SQLObject mergedList;

    public this(){

    }

    public this(string dbType){
        this.dbType = dbType;
    }

    public this(SQLExpr left, SQLBinaryOperator operator, SQLExpr right){
        this(left, operator, right, null);
    }
    
    public this(SQLExpr left, SQLBinaryOperator operator, SQLExpr right, string dbType){
        if (left !is null) {
            left.setParent(this);
        }
        this.left = left;

        setRight(right);
        this.operator = operator;

        if (dbType is null) {
            auto obj = cast(SQLBinaryOpExpr) left;
            if (obj !is null) {
                dbType = obj.dbType;
            }
        }

        if (dbType is null) {
            auto obj = cast(SQLBinaryOpExpr) right;
            if (obj !is null) {
                dbType = obj.dbType;
            }
        }

        this.dbType = dbType;
    }

    public this(SQLExpr left, SQLExpr right, SQLBinaryOperator operator){

        setLeft(left);
        setRight(right);
        this.operator = operator;
    }

    public string getDbType() {
        return dbType;
    }

    public void setDbType(string dbType) {
        this.dbType = dbType;
    }

    public SQLExpr getLeft() {
        return this.left;
    }

    public void setLeft(SQLExpr left) {
        if (left !is null) {
            left.setParent(this);
        }
        this.left = left;
    }

    public SQLExpr getRight() {
        return this.right;
    }

    public void setRight(SQLExpr right) {
        if (right !is null) {
            right.setParent(this);
        }
        this.right = right;
    }

    public SQLBinaryOperator getOperator() {
        return this.operator;
    }

    public void setOperator(SQLBinaryOperator operator) {
        this.operator = operator;
    }

    public bool isBracket() {
        return bracket;
    }

    public void setBracket(bool bracket) {
        this.bracket = bracket;
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, this.left);
            acceptChild(visitor, this.right);
        }

        visitor.endVisit(this);
    }

   override
    public List!SQLObject getChildren() {
        //return Arrays.asList(this.left, this.right);
        List!SQLObject ls = new ArrayList!SQLObject();
        ls.add(this.left);
        ls.add(this.right);
        return ls;
    }

   override
    public size_t toHash() @trusted nothrow {
         int prime = 31;
        size_t result = 1;
        result = prime * result + ((left is null) ? 0 : (cast(Object)left).toHash());
        result = prime * result + hashOf(operator);
        result = prime * result + ((right is null) ? 0 : (cast(Object)right).toHash());
        return result;
    }

   override
    public bool opEquals(Object obj) {
        if (this is obj) {
            return true;
        }
        if (obj is null) {
            return false;
        }
        // if (!(cast(SQLBinaryOpExpr)(obj) !is null)) {
        //     return false;
        // }
        SQLBinaryOpExpr other = cast(SQLBinaryOpExpr) obj;
        if(other is null)
            return false;

        return operator == other.operator
                && SQLExprUtils.opEquals(left, other.left)
                &&  SQLExprUtils.opEquals(right, other.right);
    }

    public bool opEquals(SQLBinaryOpExpr other) {
        return operator == other.operator
                && SQLExprUtils.opEquals(left, other.left)
                &&  SQLExprUtils.opEquals(right, other.right);
    }


    public bool equalsIgoreOrder(SQLBinaryOpExpr other) {
        if (this == other) {
            return true;
        }
        if (other is null) {
            return false;
        }

        if (operator != other.operator) {
            return false;
        }

        return (Utils.equals(cast(Object)(this.left), cast(Object)(other.left))
                    && Utils.equals(cast(Object)(this.right), cast(Object)(other.right)))
                || (Utils.equals(cast(Object)(this.left), cast(Object)(other.right))
                    && Utils.equals(cast(Object)(this.right), cast(Object)(other.left)));
    }

    override public SQLBinaryOpExpr clone() {
        SQLBinaryOpExpr x = new SQLBinaryOpExpr();

        if (left !is null) {
            x.setLeft(left.clone());
        }
        if (right !is null) {
            x.setRight(right.clone());
        }
        x.operator = operator;
        x.dbType = dbType;
        x.bracket = bracket;

        return x;
    }

    override public string toString() {
        return SQLUtils.toSQLString(this, getDbType());
    }

    override public void output(StringBuffer buf) {
        SQLASTOutputVisitor visitor = SQLUtils.createOutputVisitor(buf, dbType);
        this.accept(visitor);
    }

    public static SQLExpr combine(List!SQLExpr items, SQLBinaryOperator op) {
        if (items is null) {
            return null;
        }

        int size = items.size();
        if (size == 0) {
            return null;
        }

        if (size == 1) {
            return items.get(0);
        }

        SQLBinaryOpExpr expr = new SQLBinaryOpExpr(items.get(0), op, items.get(1));

        for (int i = 2; i < size; ++i) {
            SQLExpr item = items.get(i);
            expr = new SQLBinaryOpExpr(expr, op, item);
        }

        return expr;
    }

    public static List!SQLExpr split(SQLBinaryOpExpr x) {
        return split(x, x.getOperator());
    }

    public static List!SQLExpr split(SQLBinaryOpExpr x, SQLBinaryOperator op) {
        if (x.getOperator() != op) {
            List!SQLExpr groupList = new ArrayList!SQLExpr(1);
            groupList.add(x);
            return groupList;
        }

        List!SQLExpr groupList = new ArrayList!SQLExpr();
        split(groupList, x, op);
        return groupList;
    }

    public static void split(List!SQLExpr outList, SQLExpr expr, SQLBinaryOperator op) {
        if (expr is null) {
            return;
        }

        // if (!(cast(SQLBinaryOpExpr)(expr) !is null)) {
        //     outList.add(expr);
        //     return;
        // }

        SQLBinaryOpExpr binaryExpr = cast(SQLBinaryOpExpr) expr;
        if(binaryExpr is null)
        {
            outList.add(expr);
            return;
        }

        if (binaryExpr.getOperator() != op) {
            outList.add(binaryExpr);
            return;
        }

        List!SQLExpr rightList = new ArrayList!SQLExpr();
        rightList.add(binaryExpr.getRight());
        for (SQLExpr left = binaryExpr.getLeft();;) {
            SQLBinaryOpExpr leftBinary = cast(SQLBinaryOpExpr) left;
            if (leftBinary !is null) {
                if (leftBinary.operator == op) {
                    left = (cast(SQLBinaryOpExpr) leftBinary).getLeft();
                    rightList.add(leftBinary.getRight());
                } else {
                    outList.add(leftBinary);
                    break;
                }
            } else {
                outList.add(left);
                break;
            }
        }

        for (int i = rightList.size() - 1; i >= 0; --i) {
            SQLExpr right  = rightList.get(i);

            SQLBinaryOpExpr binaryRight = cast(SQLBinaryOpExpr) right;
            if (binaryRight !is null) {
                if (binaryRight.operator == op) {
                    {
                        SQLExpr rightLeft = binaryRight.getLeft();
                        SQLBinaryOpExpr rightLeftBinary = cast(SQLBinaryOpExpr) rightLeft;
                        if (rightLeftBinary !is null) {
                            if (rightLeftBinary.operator == op) {
                                split(outList, rightLeftBinary, op);
                            } else {
                                outList.add(rightLeftBinary);
                            }
                        } else {
                            outList.add(rightLeft);
                        }
                    }
                    {
                        SQLExpr rightRight = binaryRight.getRight();
                        SQLBinaryOpExpr rightRightBinary = cast(SQLBinaryOpExpr) rightRight;
                        if (rightRightBinary !is null) {
                            if (rightRightBinary.operator == op) {
                                split(outList, rightRightBinary, op);
                            } else {
                                outList.add(rightRightBinary);
                            }
                        } else {
                            outList.add(rightRight);
                        }
                    }
                } else {
                    outList.add(binaryRight);
                }
            } else {
                outList.add(right);
            }
        }
    }

    public static SQLExpr and(SQLExpr a, SQLExpr b) {
        if (a is null) {
            return b;
        }

        if (b is null) {
            return a;
        }
        SQLBinaryOpExpr bb = cast(SQLBinaryOpExpr) b;
        if ( bb !is null) {
            if (bb.operator == SQLBinaryOperator.BooleanAnd) {
                return and(and(a, bb.left), bb.right);
            }
        }

        return new SQLBinaryOpExpr(a, SQLBinaryOperator.BooleanAnd, b);
    }

    public static SQLExpr andIfNotExists(SQLExpr a, SQLExpr b) {
        if (a is null) {
            return b;
        }

        if (b is null) {
            return a;
        }

        List!SQLExpr groupListA = new ArrayList!SQLExpr();
        List!SQLExpr groupListB = new ArrayList!SQLExpr();
        split(groupListA, a, SQLBinaryOperator.BooleanAnd);
        split(groupListB, a, SQLBinaryOperator.BooleanAnd);

        foreach (SQLExpr itemB ; groupListB) {
            bool exist = false;
            foreach (SQLExpr itemA ; groupListA) {
                if ((cast(Object)itemA).opEquals(cast(Object)(itemB))) {
                    exist = true;
                } else if ((cast(SQLBinaryOpExpr) itemA !is null)
                        && (cast(SQLBinaryOpExpr) itemB !is null)) {
                    if ((cast(SQLBinaryOpExpr) itemA).equalsIgoreOrder(cast(SQLBinaryOpExpr) itemB)) {
                        exist = true;
                    }
                }
            }
            if (!exist) {
                groupListA.add(itemB);
            }
        }
        return combine(groupListA, SQLBinaryOperator.BooleanAnd);
    }

    public static SQLBinaryOpExpr isNotNull(SQLExpr expr) {
        return new SQLBinaryOpExpr(expr, SQLBinaryOperator.IsNot, new SQLNullExpr());
    }

    public static SQLBinaryOpExpr isNull(SQLExpr expr) {
        return new SQLBinaryOpExpr(expr, SQLBinaryOperator.Is, new SQLNullExpr());
    }

    public bool replace(SQLExpr expr, SQLExpr taget) {
        SQLObject parent = getParent();

        if (left == expr) {
            if (taget is null) {
                auto obj = cast(SQLReplaceable) parent;
                if (obj !is null) {
                    return obj.replace(this, right);
                } else {
                    return false;
                }
            }
            this.setLeft(taget);
            return true;
        }

        if (right == expr) {
            if (taget is null) {
                auto obj = cast(SQLReplaceable) parent;
                if (obj !is null) {
                    return obj.replace(this, left);
                } else {
                    return false;
                }
            }
            this.setRight(taget);
            return true;
        }

        return false;
    }

    public SQLExpr other(SQLExpr x) {
        if (x == left) {
            return right;
        }

        if (x == right) {
            return left;
        }

        return null;
    }

    public bool contains(SQLExpr item) {
        auto obj = cast(SQLBinaryOpExpr) item;
        if (obj !is null) {
            if (this.equalsIgoreOrder(obj)) {
                return true;
            }

            return (cast(Object)left).opEquals(cast(Object)(item)) || (cast(Object)right).opEquals(cast(Object)(item));
        }

        return false;
    }

    override public SQLDataType computeDataType() {
        if (operator.isRelational()) {
            return SQLBooleanExpr.DEFAULT_DATA_TYPE;
        }

        SQLDataType leftDataType = null, rightDataType = null;
        if (left !is null) {
            leftDataType = left.computeDataType();
        }
        if (right !is null) {
            rightDataType = right.computeDataType();
        }

        if (operator == SQLBinaryOperator.Concat) {
            if (leftDataType !is null) {
                return leftDataType;
            }
            if (rightDataType !is null) {
                return rightDataType;
            }
            return SQLCharExpr.DEFAULT_DATA_TYPE;
        }

        return null;
    }

    public bool conditionContainsTable(string alias_p) {
        if (left is null || right is null) {
            return false;
        }

        if (cast(SQLPropertyExpr) left !is null) {
            if ((cast(SQLPropertyExpr) left).matchOwner(alias_p)) {
                return true;
            }
        } else if (cast(SQLBinaryOpExpr)left !is null ) {
            if ((cast(SQLBinaryOpExpr) left).conditionContainsTable(alias_p)) {
                return true;
            }
        }

        if (cast(SQLPropertyExpr) right !is null) {
            if ((cast(SQLPropertyExpr) right).matchOwner(alias_p)) {
                return true;
            }
        } else if (cast(SQLBinaryOpExpr) right !is null) {
            return (cast(SQLBinaryOpExpr) right).conditionContainsTable(alias_p);
        }

        return false;
    }

    public bool conditionContainsColumn(string column) {
        if (left is null || right is null) {
            return false;
        }

        if (cast(SQLIdentifierExpr) left !is null) {
            if ((cast(SQLIdentifierExpr) left).nameEquals(column)) {
                return true;
            }
        } else if (cast(SQLIdentifierExpr) right !is null) {
            if ((cast(SQLIdentifierExpr) right).nameEquals(column)) {
                return true;
            }
        }

        return false;
    }

    /**
     * only for parameterized output
     * @param v
     * @param x
     * @return
     */
    public static SQLBinaryOpExpr merge(ParameterizedVisitor v, SQLBinaryOpExpr x) {
        SQLObject parent = x.parent;

        for (;;) {
            SQLBinaryOpExpr rightBinary = cast(SQLBinaryOpExpr) x.right;
            if (rightBinary !is null) {
                SQLBinaryOpExpr leftBinaryExpr = cast(SQLBinaryOpExpr) x.left;
                if (leftBinaryExpr !is null) {
                    if (SQLExprUtils.opEquals(leftBinaryExpr.right, rightBinary)) {
                        x = leftBinaryExpr;
                        v.incrementReplaceCunt();
                        continue;
                    }
                }
                SQLExpr mergedRight = merge(v, rightBinary);
                if (mergedRight != x.right) {
                    x = new SQLBinaryOpExpr(x.left, x.operator, mergedRight);
                    v.incrementReplaceCunt();
                }

                x.setParent(parent);
            }

            break;
        }
        auto xobj = cast(SQLBinaryOpExpr) x.left;
        if (xobj !is null) {
            SQLExpr mergedLeft = merge(v, xobj);
            if (mergedLeft != x.left) {
                SQLBinaryOpExpr tmp = new SQLBinaryOpExpr(mergedLeft, x.operator, x.right);
                tmp.setParent(parent);
                x = tmp;
                v.incrementReplaceCunt();
            }
        }

        // ID = ? OR ID = ? => ID = ?
        if (x.operator == SQLBinaryOperator.BooleanOr) {
            SQLBinaryOpExpr leftBinary = cast(SQLBinaryOpExpr) x.left;
            SQLBinaryOpExpr rightBinary = cast(SQLBinaryOpExpr) x.right;
            if ((leftBinary !is null) && (rightBinary !is null)) {
                
                if (mergeEqual(leftBinary, rightBinary)) {
                    v.incrementReplaceCunt();
                    leftBinary.setParent(x.parent);
                    leftBinary.addMergedItem(rightBinary);
                    return leftBinary;
                }

                if (SQLExprUtils.isLiteralExpr(leftBinary.left) //
                        && leftBinary.operator == SQLBinaryOperator.BooleanOr) {
                    if (mergeEqual(leftBinary.right, x.right)) {
                        v.incrementReplaceCunt();
                        leftBinary.addMergedItem(rightBinary);
                        return leftBinary;
                    }
                }
            }
        }

        return x;
    }

    /**
     * only for parameterized output
     * @param item
     * @return
     */
    private void addMergedItem(SQLBinaryOpExpr item) {
        if (mergedList is null) {
            mergedList = new ArrayList!SQLObject();
        }
        mergedList.add(item);
    }

    /**
     * only for parameterized output
     * @return
     */
    public List!SQLObject getMergedList() {
        return mergedList;
    }

    /**
     * only for parameterized output
     * @param a
     * @param b
     * @return
     */
    private static bool mergeEqual(SQLExpr a, SQLExpr b) {


        SQLBinaryOpExpr binaryA = cast(SQLBinaryOpExpr) a;
        SQLBinaryOpExpr binaryB = cast(SQLBinaryOpExpr) b;

        if (binaryA is null) {
            return false;
        }
        if (binaryB is null) {
            return false;
        }

        if (binaryA.getOperator() != SQLBinaryOperator.Equality) {
            return false;
        }

        if (binaryB.getOperator() != SQLBinaryOperator.Equality) {
            return false;
        }

        if (!(cast(SQLLiteralExpr)(binaryA.getRight()) !is null || cast(SQLVariantRefExpr)(binaryA.getRight()) !is null )) {
            return false;
        }

        if (!(cast(SQLLiteralExpr)(binaryB.getRight()) !is null || cast(SQLVariantRefExpr)(binaryB.getRight()) !is null )) {
            return false;
        }

        return (cast(Object)(binaryA.getLeft())).toString() == (cast(Object)(binaryB.getLeft())).toString();
    }
}
