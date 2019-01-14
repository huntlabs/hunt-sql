module hunt.sql.ast.SQLOver;

import hunt.sql.ast.SQLDataType;
import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLOrderBy;
import hunt.sql.ast.SQLObject;

import hunt.sql.visitor.SQLASTVisitor;
import hunt.collection;

public class SQLOver : SQLObjectImpl {

    protected List!SQLExpr partitionBy;
    protected SQLOrderBy          orderBy;

    // for db2
    protected SQLName             of;

    protected SQLExpr             windowing;
    protected WindowingType       windowingType = WindowingType.ROWS;

    protected bool             windowingPreceding;
    protected bool             windowingFollowing;

    protected SQLExpr             windowingBetweenBegin;
    protected bool             windowingBetweenBeginPreceding;
    protected bool             windowingBetweenBeginFollowing;

    protected SQLExpr             windowingBetweenEnd;
    protected bool             windowingBetweenEndPreceding;
    protected bool             windowingBetweenEndFollowing;

    public this(){
        partitionBy = new ArrayList!SQLExpr();
    }

    public this(SQLOrderBy orderBy){
        this();
        this.setOrderBy(orderBy);
    }

    protected override void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild!SQLExpr(visitor, this.partitionBy);
            acceptChild(visitor, this.orderBy);
            acceptChild(visitor, this.of);
        }
        visitor.endVisit(this);
    }

    public SQLOrderBy getOrderBy() {
        return orderBy;
    }

    public void setOrderBy(SQLOrderBy orderBy) {
        if (orderBy !is null) {
            orderBy.setParent(this);
        }
        this.orderBy = orderBy;
    }

    public SQLName getOf() {
        return of;
    }

    public void setOf(SQLName of) {
        if (of !is null) {
            of.setParent(this);
        }
        this.of = of;
    }

    public List!SQLExpr getPartitionBy() {
        return partitionBy;
    }

    public SQLExpr getWindowing() {
        return windowing;
    }

    public void setWindowing(SQLExpr windowing) {
        this.windowing = windowing;
    }

    public WindowingType getWindowingType() {
        return windowingType;
    }

    public void setWindowingType(WindowingType windowingType) {
        this.windowingType = windowingType;
    }

    public bool isWindowingPreceding() {
        return windowingPreceding;
    }

    public void setWindowingPreceding(bool windowingPreceding) {
        this.windowingPreceding = windowingPreceding;
    }

    public bool isWindowingFollowing() {
        return windowingFollowing;
    }

    public void setWindowingFollowing(bool windowingFollowing) {
        this.windowingFollowing = windowingFollowing;
    }

    public SQLExpr getWindowingBetweenBegin() {
        return windowingBetweenBegin;
    }

    public void setWindowingBetweenBegin(SQLExpr windowingBetweenBegin) {
        this.windowingBetweenBegin = windowingBetweenBegin;
    }

    public bool isWindowingBetweenBeginPreceding() {
        return windowingBetweenBeginPreceding;
    }

    public void setWindowingBetweenBeginPreceding(bool windowingBetweenBeginPreceding) {
        this.windowingBetweenBeginPreceding = windowingBetweenBeginPreceding;
    }

    public bool isWindowingBetweenBeginFollowing() {
        return windowingBetweenBeginFollowing;
    }

    public void setWindowingBetweenBeginFollowing(bool windowingBetweenBeginFollowing) {
        this.windowingBetweenBeginFollowing = windowingBetweenBeginFollowing;
    }

    public SQLExpr getWindowingBetweenEnd() {
        return windowingBetweenEnd;
    }

    public void setWindowingBetweenEnd(SQLExpr windowingBetweenEnd) {
        this.windowingBetweenEnd = windowingBetweenEnd;
    }

    public bool isWindowingBetweenEndPreceding() {
        return windowingBetweenEndPreceding;
    }

    public void setWindowingBetweenEndPreceding(bool windowingBetweenEndPreceding) {
        this.windowingBetweenEndPreceding = windowingBetweenEndPreceding;
    }

    public bool isWindowingBetweenEndFollowing() {
        return windowingBetweenEndFollowing;
    }

    public void setWindowingBetweenEndFollowing(bool windowingBetweenEndFollowing) {
        this.windowingBetweenEndFollowing = windowingBetweenEndFollowing;
    }

    override public bool opEquals(Object o) {
        if (this == o) return true;
        if (o is null || typeid(o) == typeid(SQLOver)) return false;

        SQLOver sqlOver = cast(SQLOver) o;

        if (windowingPreceding != sqlOver.windowingPreceding) return false;
        if (windowingFollowing != sqlOver.windowingFollowing) return false;
        if (windowingBetweenBeginPreceding != sqlOver.windowingBetweenBeginPreceding) return false;
        if (windowingBetweenBeginFollowing != sqlOver.windowingBetweenBeginFollowing) return false;
        if (windowingBetweenEndPreceding != sqlOver.windowingBetweenEndPreceding) return false;
        if (windowingBetweenEndFollowing != sqlOver.windowingBetweenEndFollowing) return false;
        if (partitionBy !is null ? !(cast(Object)partitionBy).opEquals(cast(Object)sqlOver.partitionBy) : sqlOver.partitionBy !is null) return false;
        if (orderBy !is null ? !(cast(Object)(orderBy)).opEquals(cast(Object)sqlOver.orderBy) : sqlOver.orderBy !is null) return false;
        if (of !is null ? !(cast(Object)of).opEquals(cast(Object)(sqlOver.of)) : sqlOver.of !is null) return false;
        if (windowing !is null ? !(cast(Object)windowing).opEquals(cast(Object)(sqlOver.windowing)) : sqlOver.windowing !is null) return false;
        if (windowingType != sqlOver.windowingType) return false;
        if (windowingBetweenBegin !is null ? !(cast(Object)windowingBetweenBegin).opEquals(cast(Object)(sqlOver.windowingBetweenBegin)) : sqlOver.windowingBetweenBegin !is null)
            return false;
        return windowingBetweenEnd !is null ? (cast(Object)windowingBetweenEnd).opEquals(cast(Object)(sqlOver.windowingBetweenEnd)) : sqlOver.windowingBetweenEnd is null;

    }

    override public size_t toHash() @trusted nothrow {
        size_t result = partitionBy !is null ? (cast(Object)partitionBy).toHash() : 0;
        result = 31 * result + (orderBy !is null ? (cast(Object)orderBy).toHash() : 0);
        result = 31 * result + (of !is null ? (cast(Object)of).toHash() : 0);
        result = 31 * result + (windowing !is null ? (cast(Object)windowing).toHash() : 0);
        result = 31 * result + windowingType/*(windowingType !is null ? windowingType : 0)*/;
        result = 31 * result + (windowingPreceding ? 1 : 0);
        result = 31 * result + (windowingFollowing ? 1 : 0);
        result = 31 * result + (windowingBetweenBegin !is null ? (cast(Object)windowingBetweenBegin).toHash() : 0);
        result = 31 * result + (windowingBetweenBeginPreceding ? 1 : 0);
        result = 31 * result + (windowingBetweenBeginFollowing ? 1 : 0);
        result = 31 * result + (windowingBetweenEnd !is null ? (cast(Object)windowingBetweenEnd).toHash() : 0);
        result = 31 * result + (windowingBetweenEndPreceding ? 1 : 0);
        result = 31 * result + (windowingBetweenEndFollowing ? 1 : 0);
        return result;
    }

    public void cloneTo(SQLOver x) {
        foreach (SQLExpr item ; partitionBy) {
            SQLExpr item1 = item.clone();
            item1.setParent(x);
            x.partitionBy.add(item);
        }

        if (orderBy !is null) {
            x.setOrderBy(orderBy.clone());
        }

        if (of !is null) {
            x.setOf(of.clone());
        }

        if (windowing !is null) {
            x.setWindowing(windowing.clone());
        }
        x.windowingType = windowingType;
        x.windowingPreceding = windowingPreceding;
        x.windowingFollowing = windowingFollowing;

        if (windowingBetweenBegin !is null) {
            x.setWindowingBetweenBegin(windowingBetweenBegin.clone());
        }
        x.windowingBetweenBeginPreceding = windowingBetweenBeginPreceding;
        x.windowingBetweenBeginFollowing = windowingBetweenBeginFollowing;

        if (windowingBetweenEnd !is null) {
            x.setWindowingBetweenEnd(windowingBetweenEnd.clone());
        }
        x.windowingBetweenEndPreceding = windowingBetweenEndPreceding;
        x.windowingBetweenEndFollowing = windowingBetweenEndFollowing;
    }

    public override SQLOver clone() {
        SQLOver x = new SQLOver();
        cloneTo(x);
        return x;
    }

    public static enum WindowingType : int {
        ROWS = 0, RANGE =1
    }
}
