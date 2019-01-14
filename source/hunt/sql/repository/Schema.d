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
module hunt.sql.repository.Schema;

import hunt.sql.SQLUtils;
import hunt.sql.ast.SQLDataType;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLStatement;
import hunt.sql.ast.expr.SQLAggregateExpr;
import hunt.sql.ast.expr.SQLAllColumnExpr;
import hunt.sql.ast.expr.SQLIdentifierExpr;
import hunt.sql.ast.expr.SQLPropertyExpr;
import hunt.sql.ast.statement;
import hunt.sql.dialect.mysql.ast.statement.MySqlCreateTableStatement;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitorAdapter;
// import hunt.sql.dialect.oracle.ast.stmt.OracleCreateTableStatement;
// import hunt.sql.dialect.oracle.visitor.OracleASTVisitorAdapter;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.util.FnvHash;
import hunt.sql.util.DBType;
import hunt.sql.repository.SchemaObjectType;

import hunt.collection;
import hunt.Long;
import hunt.String;
import hunt.sql.repository.SchemaObject;
import std.uni;
import hunt.sql.repository.SchemaRepository;
import hunt.text;
/**
 * Created by wenshao on 21/07/2017.
 */
public class Schema {
    private string name;

    public  Map!(Long, SchemaObject) objects;

    public  Map!(Long, SchemaObject) _functions;

    private SchemaRepository repository;

    this()
    {
        objects = new HashMap!(Long, SchemaObject)();
        _functions  = new HashMap!(Long, SchemaObject)();
    }

    public this(SchemaRepository repository) {
        this(repository, null);
    }

    public this(SchemaRepository repository, string name) {
        this();
        this.repository = repository;
        this.name = name;
    }

    public string getName() {
        return name;
    }

    public void setName(string name) {
        this.name = name;
    }


    public SchemaObject findTable(string tableName) {
        long hashCode64 = FnvHash.hashCode64(tableName);
        return findTable(hashCode64);
    }

    public SchemaObject findTable(long nameHashCode64) {
        SchemaObject object = objects.get(new Long(nameHashCode64));

        if (object !is null && object.getType() == SchemaObjectType.Table) {
            return object;
        }

        return null;
    }

    public SchemaObject findTableOrView(string tableName) {
        long hashCode64 = FnvHash.hashCode64(tableName);
        return findTableOrView(hashCode64);
    }

    public SchemaObject findTableOrView(long hashCode64) {
        SchemaObject object = objects.get(new Long(hashCode64));

        if (object is null) {
            return null;
        }

        SchemaObjectType type = object.getType();
        if (type == SchemaObjectType.Table || type == SchemaObjectType.View) {
            return object;
        }

        return null;
    }

    public SchemaObject findFunction(string _functionName) {
        _functionName = SQLUtils.normalize(_functionName);
        string lowerName = toLower(_functionName);
        return _functions.get(new Long(lowerName));
    }

    public bool isSequence(string name) {
        long nameHashCode64 = FnvHash.hashCode64(name);
        SchemaObject object = objects.get(new Long(nameHashCode64));
        return object !is null
                && object.getType() == SchemaObjectType.Sequence;
    }


    public SchemaObject findTable(SQLTableSource tableSource, string _alias) {
        if (cast(SQLExprTableSource)(tableSource) !is null) {
            if (equalsIgnoreCase(_alias, tableSource.computeAlias())) {
                SQLExprTableSource exprTableSource = cast(SQLExprTableSource) tableSource;

                SchemaObject tableObject = exprTableSource.getSchemaObject();
                if (tableObject !is  null) {
                    return tableObject;
                }

                SQLExpr expr = exprTableSource.getExpr();
                if (cast(SQLIdentifierExpr)(expr) !is null) {
                    long tableNameHashCode64 = (cast(SQLIdentifierExpr) expr).nameHashCode64();

                    tableObject = findTable(tableNameHashCode64);
                    if (tableObject !is null) {
                        exprTableSource.setSchemaObject(tableObject);
                    }
                    return tableObject;
                }

                if (cast(SQLPropertyExpr)(expr) !is null) {
                    long tableNameHashCode64 = (cast(SQLPropertyExpr) expr).nameHashCode64();

                    tableObject = findTable(tableNameHashCode64);
                    if (tableObject !is null) {
                        exprTableSource.setSchemaObject(tableObject);
                    }
                    return tableObject;
                }
            }
            return null;
        }

        if (cast(SQLJoinTableSource)(tableSource) !is null) {
            SQLJoinTableSource join = cast(SQLJoinTableSource) tableSource;
            SQLTableSource left = join.getLeft();

            SchemaObject tableObject = findTable(left, _alias);
            if (tableObject !is null) {
                return tableObject;
            }

            SQLTableSource right = join.getRight();
            tableObject = findTable(right, _alias);
            return tableObject;
        }

        return null;
    }

    public SQLColumnDefinition findColumn(SQLTableSource tableSource, SQLSelectItem selectItem) {
        if (selectItem is null) {
            return null;
        }

        return findColumn(tableSource, selectItem.getExpr());
    }

    public SQLColumnDefinition findColumn(SQLTableSource tableSource, SQLExpr expr) {
        SchemaObject object = findTable(tableSource, expr);
        if (object !is null) {
            if (cast(SQLAggregateExpr)(expr) !is null) {
                SQLAggregateExpr aggregateExpr = cast(SQLAggregateExpr) expr;
                string _function = aggregateExpr.getMethodName();
                if ("min".equalsIgnoreCase(_function)
                        || "max".equalsIgnoreCase(_function)) {
                    SQLExpr arg = aggregateExpr.getArguments().get(0);
                    expr = arg;
                }
            }

            if (cast(SQLName)(expr) !is null) {
                return object.findColumn((cast(SQLName) expr).getSimpleName());
            }
        }

        return null;
    }

    public SchemaObject findTable(SQLTableSource tableSource, SQLSelectItem selectItem) {
        if (selectItem is null) {
            return null;
        }

        return findTable(tableSource, selectItem.getExpr());
    }

    public SchemaObject findTable(SQLTableSource tableSource, SQLExpr expr) {
        if (cast(SQLAggregateExpr)(expr) !is null) {
            SQLAggregateExpr aggregateExpr = cast(SQLAggregateExpr) expr;
            string _function = aggregateExpr.getMethodName();
            if ("min".equalsIgnoreCase(_function)
                    || "max".equalsIgnoreCase(_function)) {
                SQLExpr arg = aggregateExpr.getArguments().get(0);
                return findTable(tableSource, arg);
            }
        }

        if (cast(SQLPropertyExpr)(expr) !is null) {
            string ownerName = (cast(SQLPropertyExpr) expr).getOwnernName();
            return findTable(tableSource, ownerName);
        }

        if (cast(SQLAllColumnExpr)(expr) !is null || cast(SQLIdentifierExpr)(expr) !is null) {
            if (cast(SQLExprTableSource)(tableSource) !is null) {
                return findTable(tableSource, tableSource.computeAlias());
            }

            if (cast(SQLJoinTableSource)(tableSource) !is null) {
                SQLJoinTableSource join = cast(SQLJoinTableSource) tableSource;

                SchemaObject table = findTable(join.getLeft(), expr);
                if (table is null) {
                    table = findTable(join.getRight(), expr);
                }
                return table;
            }
            return null;
        }

        return null;
    }

    public Map!(string, SchemaObject) getTables(SQLTableSource x) {
        Map!(string, SchemaObject) tables = new LinkedHashMap!(string, SchemaObject)();
        computeTables(x, tables);
        return tables;
    }

    protected void computeTables(SQLTableSource x, Map!(string, SchemaObject) tables) {
        if (x is null) {
            return;
        }

        if (cast(SQLExprTableSource)(x) !is null) {
            SQLExprTableSource exprTableSource = cast(SQLExprTableSource) x;

            SQLExpr expr = exprTableSource.getExpr();
            if (cast(SQLIdentifierExpr)(expr) !is null) {
                long tableNameHashCode64 = (cast(SQLIdentifierExpr) expr).nameHashCode64();
                string tableName = (cast(SQLIdentifierExpr) expr).getName();

                SchemaObject table = exprTableSource.getSchemaObject();
                if (table is null) {
                    table = findTable(tableNameHashCode64);

                    if (table !is null) {
                        exprTableSource.setSchemaObject(table);
                    }
                }

                if (table !is null) {
                    tables.put(tableName, table);

                    string _alias = x.getAlias();
                    if (_alias !is null && !equalsIgnoreCase(_alias, tableName)) {
                        tables.put(_alias, table);
                    }
                }
            }

            return;
        }

        if (cast(SQLJoinTableSource)(x) !is null) {
            SQLJoinTableSource join = cast(SQLJoinTableSource) x;
            computeTables(join.getLeft(), tables);
            computeTables(join.getRight(), tables);
        }
    }

    public int getTableCount() {
        int count = 0;
        foreach(SchemaObject object ; this.objects.values()) {
            if (object.getType() == SchemaObjectType.Table) {
                count++;
            }
        }
        return count;
    }

    public SchemaObject[] getObjects() {
        return (this.objects.values());
    }

    public int getViewCount() {
        int count = 0;
        foreach(SchemaObject object ; this.objects.values()) {
            if (object.getType() == SchemaObjectType.View) {
                count++;
            }
        }
        return count;
    }

    public List!(string) showTables() {
        List!(string) tables = new ArrayList!(string)(objects.size());
        foreach(SchemaObject object ; objects.values()) {
            if (object.getType() == SchemaObjectType.Table) {
                tables.add(object.getName());
            }
        }
        //Collections.sort(tables); //@gxc
        return tables;
    }
}
