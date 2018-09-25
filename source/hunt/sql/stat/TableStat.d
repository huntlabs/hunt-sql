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
module hunt.sql.stat.TableStat;

import hunt.sql.SQLUtils;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.expr.SQLPropertyExpr;
import hunt.util.serialize;
import hunt.sql.util.FnvHash;
import hunt.sql.util.DBType;
import hunt.util.string;
import hunt.container;
import hunt.sql.util.String;
import std.string;

public class TableStat
{

    int selectCount = 0;
    int updateCount = 0;
    int deleteCount = 0;
    int insertCount = 0;
    int dropCount = 0;
    int mergeCount = 0;
    int createCount = 0;
    int alterCount = 0;
    int createIndexCount = 0;
    int dropIndexCount = 0;
    int referencedCount = 0;

    public int getReferencedCount()
    {
        return referencedCount;
    }

    public void incrementReferencedCount()
    {
        referencedCount++;
    }

    public int getDropIndexCount()
    {
        return dropIndexCount;
    }

    public void incrementDropIndexCount()
    {
        this.dropIndexCount++;
    }

    public int getCreateIndexCount()
    {
        return createIndexCount;
    }

    public void incrementCreateIndexCount()
    {
        createIndexCount++;
    }

    public int getAlterCount()
    {
        return alterCount;
    }

    public void incrementAlterCount()
    {
        this.alterCount++;
    }

    public int getCreateCount()
    {
        return createCount;
    }

    public void incrementCreateCount()
    {
        this.createCount++;
    }

    public int getMergeCount()
    {
        return mergeCount;
    }

    public void incrementMergeCount()
    {
        this.mergeCount++;
    }

    public int getDropCount()
    {
        return dropCount;
    }

    public void incrementDropCount()
    {
        dropCount++;
    }

    public void setDropCount(int dropCount)
    {
        this.dropCount = dropCount;
    }

    public int getSelectCount()
    {
        return selectCount;
    }

    public void incrementSelectCount()
    {
        selectCount++;
    }

    public void setSelectCount(int selectCount)
    {
        this.selectCount = selectCount;
    }

    public int getUpdateCount()
    {
        return updateCount;
    }

    public void incrementUpdateCount()
    {
        updateCount++;
    }

    public void setUpdateCount(int updateCount)
    {
        this.updateCount = updateCount;
    }

    public int getDeleteCount()
    {
        return deleteCount;
    }

    public void incrementDeleteCount()
    {
        this.deleteCount++;
    }

    public void setDeleteCount(int deleteCount)
    {
        this.deleteCount = deleteCount;
    }

    public void incrementInsertCount()
    {
        this.insertCount++;
    }

    public int getInsertCount()
    {
        return insertCount;
    }

    public void setInsertCount(int insertCount)
    {
        this.insertCount = insertCount;
    }

    override public string toString()
    {
        StringBuilder buf = new StringBuilder(4);
        if (mergeCount > 0)
        {
            buf.append("Merge");
        }
        if (insertCount > 0)
        {
            buf.append("Insert");
        }
        if (updateCount > 0)
        {
            buf.append("Update");
        }
        if (selectCount > 0)
        {
            buf.append("Select");
        }
        if (deleteCount > 0)
        {
            buf.append("Delete");
        }
        if (dropCount > 0)
        {
            buf.append("Drop");
        }
        if (createCount > 0)
        {
            buf.append("Create");
        }
        if (alterCount > 0)
        {
            buf.append("Alter");
        }
        if (createIndexCount > 0)
        {
            buf.append("CreateIndex");
        }
        if (dropIndexCount > 0)
        {
            buf.append("DropIndex");
        }

        return buf.toString();
    }

    public static class Name
    {
        private  string name;
        private  long _hashCode64;

        public this(string name)
        {
            this(name, FnvHash.hashCode64(name));
        }

        public this(string name, long _hashCode64)
        {
            this.name = name;
            this._hashCode64 = _hashCode64;
        }

        public string getName()
        {
            return this.name;
        }

        override public size_t toHash() @trusted nothrow
        {
            try{
                long value = hashCode64();
                return cast(size_t)(value ^ (value >>> 32));
            }
            catch(Exception e){}
            return 0;
        }

        public long hashCode64()
        {
            return _hashCode64;
        }

        override public bool opEquals(Object o)
        {
            if (!(cast(Name)(o) !is null))
            {
                return false;
            }

            Name other = cast(Name) o;
            return this._hashCode64 == other._hashCode64;
        }

        override public string toString()
        {
            return SQLUtils.normalize(this.name);
        }
    }

    public static class Relationship
    {
        private Column left;
        private Column right;
        private string operator;

        public this(Column left, Column right, string operator)
        {
            this.left = left;
            this.right = right;
            this.operator = operator;
        }

        public Column getLeft()
        {
            return left;
        }

        public Column getRight()
        {
            return right;
        }

        public string getOperator()
        {
            return operator;
        }

        override public size_t toHash() @trusted nothrow
        {
             int prime = 31;
            size_t result = 1;
            result = prime * result + ((left is null) ? 0 : (cast(Object)left).toHash());
            result = prime * result + ((operator is null) ? 0 : hashOf(operator));
            result = prime * result + ((right is null) ? 0 : (cast(Object)right).toHash());
            return result;
        }

        override public bool opEquals(Object obj)
        {
            if (this == obj)
            {
                return true;
            }
            if (obj is null)
            {
                return false;
            }
            if (typeid(this) != typeid(obj))
            {
                return false;
            }
            Relationship other = cast(Relationship) obj;
            if (left is null)
            {
                if (other.left !is null)
                {
                    return false;
                }
            }
            else if (!(cast(Object)(left)).opEquals(cast(Object)(other.left)))
            {
                return false;
            }
            if (operator is null)
            {
                if (other.operator !is null)
                {
                    return false;
                }
            }
            else if (!(operator == other.operator))
            {
                return false;
            }
            if (right is null)
            {
                if (other.right !is null)
                {
                    return false;
                }
            }
            else if (!(cast(Object)(right)).opEquals(cast(Object)(other.right)))
            {
                return false;
            }
            return true;
        }

        override public string toString()
        {
            return left.toString ~ " " ~ operator ~ " " ~ right.toString;
        }

    }

    public static class Condition
    {

        private  Column column;
        private  string operator;
        private  List!(Object) values;

        this()
        {
            values = new ArrayList!(Object)();
        }

        public this(Column column, string operator)
        {
            this();
            this.column = column;
            this.operator = operator;
        }

        public Column getColumn()
        {
            return column;
        }

        public string getOperator()
        {
            return operator;
        }

        public List!(Object) getValues()
        {
            return values;
        }

        public void addValue(Object value)
        {
            this.values.add(value);
        }

        override public size_t toHash() @trusted nothrow
        {
             int prime = 31;
            size_t result = 1;
            result = prime * result + ((column is null) ? 0 : (cast(Object)column).toHash());
            result = prime * result + ((operator is null) ? 0 : hashOf(operator));
            return result;
        }

        override public bool opEquals(Object obj)
        {
            if (this == obj)
            {
                return true;
            }
            if (obj is null)
            {
                return false;
            }
            if (typeid(this) != typeid(obj))
            {
                return false;
            }
            Condition other = cast(Condition) obj;
            if (column is null)
            {
                if (other.column !is null)
                {
                    return false;
                }
            }
            else if (!(cast(Object)(column)).opEquals(cast(Object)(other.column)))
            {
                return false;
            }
            if (operator is null)
            {
                if (other.operator !is null)
                {
                    return false;
                }
            }
            else if (!(operator == other.operator))
            {
                return false;
            }
            return true;
        }

        override public string toString()
        {
            StringBuilder buf = new StringBuilder();
            buf.append((cast(Object)(this.column)).toString());
            buf.append(' ');
            buf.append(this.operator);

            if (values.size() == 1)
            {
                buf.append(' ');
                buf.append(String.valueOf(this.values.get(0)));
            }
            else if (values.size() > 0)
            {
                buf.append(" (");
                for (int i = 0; i < values.size(); ++i)
                {
                    if (i != 0)
                    {
                        buf.append(", ");
                    }
                    Object val = values.get(i);
                    if (cast(String)(val) !is null)
                    {
                        string jsonStr = toJSON(val).toString;
                        buf.append(jsonStr);
                    }
                    else
                    {
                        buf.append(String.valueOf(val));
                    }
                }
                buf.append(")");
            }

            return buf.toString();
        }
    }

    public static class Column
    {

        private  string table;
        private  string name;
        protected  long _hashCode64;

        private bool where;
        private bool select;
        private bool groupBy;
        private bool having;
        private bool join;

        private bool primaryKey; // for ddl
        private bool unique; //

        private Map!(string, Object) attributes;

        private string fullName;

        /**
         * @since 1.0.20
         */
        private string dataType;

        this()
        {
            attributes = new HashMap!(string, Object)();
        }

        public this(string table, string name)
        {
            this();
            this.table = table;
            this.name = name;

            int p = cast(int)(table.indexOf('.'));
            if (p !=  - 1)
            {
                string dbType = null;
                if (table.indexOf('`') !=  - 1)
                {
                    dbType = DBType.MYSQL.name;
                }
                else if (table.indexOf('[') !=  - 1)
                {
                    dbType = DBType.SQL_SERVER.name;
                }
                else if (table.indexOf('@') !=  - 1)
                {
                    dbType = DBType.ORACLE.name;
                }
                SQLExpr owner = SQLUtils.toSQLExpr(table, dbType);
                _hashCode64 = new SQLPropertyExpr(owner, name).hashCode64();
            }
            else
            {
                _hashCode64 = FnvHash.hashCode64(table, name);
            }
        }

        public this(string table, string name, long _hashCode64)
        {
            this();
            this.table = table;
            this.name = name;
            this._hashCode64 = _hashCode64;
        }

        public string getTable()
        {
            return table;
        }

        public string getFullName()
        {
            if (fullName is null)
            {
                if (table is null)
                {
                    fullName = name;
                }
                else
                {
                    fullName = table ~ '.' ~ name;
                }
            }

            return fullName;
        }

        public long hashCode64()
        {
            return _hashCode64;
        }

        public bool isWhere()
        {
            return where;
        }

        public void setWhere(bool where)
        {
            this.where = where;
        }

        public bool isSelect()
        {
            return select;
        }

        public void setSelec(bool select)
        {
            this.select = select;
        }

        public bool isGroupBy()
        {
            return groupBy;
        }

        public void setGroupBy(bool groupBy)
        {
            this.groupBy = groupBy;
        }

        public bool isHaving()
        {
            return having;
        }

        public bool isJoin()
        {
            return join;
        }

        public void setJoin(bool join)
        {
            this.join = join;
        }

        public void setHaving(bool having)
        {
            this.having = having;
        }

        public bool isPrimaryKey()
        {
            return primaryKey;
        }

        public void setPrimaryKey(bool primaryKey)
        {
            this.primaryKey = primaryKey;
        }

        public bool isUnique()
        {
            return unique;
        }

        public void setUnique(bool unique)
        {
            this.unique = unique;
        }

        public string getName()
        {
            return name;
        }

        /**
         * @since 1.0.20
         */
        public string getDataType()
        {
            return dataType;
        }

        /**
         * @since 1.0.20
         */
        public void setDataType(string dataType)
        {
            this.dataType = dataType;
        }

        public Map!(string, Object) getAttributes()
        {
            return attributes;
        }

        public void setAttributes(Map!(string, Object) attributes)
        {
            this.attributes = attributes;
        }

        override public size_t toHash() @trusted nothrow
        {
            try{
                long hash = hashCode64();
                return cast(size_t)(hash ^ (hash >>> 32));
            }catch(Exception e){}
            return 0;
        }

        override public string toString()
        {
            if (table !is null)
            {
                return SQLUtils.normalize(table) ~ "." ~ SQLUtils.normalize(name);
            }

            return SQLUtils.normalize(name);
        }

        override public bool opEquals(Object obj)
        {
            if (!( cast(Column)obj !is null ))
            {
                return false;
            }

            Column column = cast(Column) obj;
            return _hashCode64 == column._hashCode64;
        }
    }

        public static class Mode
        {
            static  const Mode Insert = new Mode(1); //
            static  const Mode Update = new Mode(2); //
            static  const Mode Delete = new Mode(4); //
            static  const Mode Select = new Mode(8); //
            static  const Mode Merge = new Mode(16); //
            static  const Mode Truncate = new Mode(32); 
            static  const Mode Alter = new Mode(64); //
            static  const Mode Drop = new Mode(128); //
            static  const Mode DropIndex = new Mode(256);
            static  const Mode CreateIndex = new Mode(512);
            static  const Mode Replace = new Mode(1024);


            public int mark;

            private this(int mark)
            {
                this.mark = mark;
            }

            bool opEquals(const Mode h) nothrow
            {
                return mark == h.mark;
            }

            bool opEquals(ref const Mode h) nothrow
            {
                return mark == h.mark;
            }
        }
    }
