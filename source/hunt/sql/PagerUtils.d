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
module hunt.sql.PagerUtils;

import hunt.container;

import std.exception;
import hunt.sql.ast;
import hunt.sql.ast.expr;
import hunt.sql.ast.statement;
// import hunt.sql.dialect.db2.ast.stmt.DB2SelectQueryBlock;
import hunt.sql.dialect.mysql.ast.statement.MySqlSelectQueryBlock;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitorAdapter;
// import hunt.sql.dialect.odps.ast.OdpsSelectQueryBlock;
// import hunt.sql.dialect.oracle.ast.stmt.OracleSelectQueryBlock;
// import hunt.sql.dialect.oracle.visitor.OracleASTVisitorAdapter;
import hunt.sql.dialect.postgresql.ast.stmt.PGSelectQueryBlock;
// import hunt.sql.dialect.sqlserver.ast.SQLServerSelectQueryBlock;
// import hunt.sql.dialect.sqlserver.ast.SQLServerTop;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.util.DBType;
import hunt.sql.util.DBType;
import hunt.sql.SQLUtils;
import hunt.math;
import hunt.sql.visitor.SQLASTVisitorAdapter;

public class PagerUtils {

    public static string count(string sql, string dbType) {
        List!(SQLStatement) stmtList = SQLUtils.parseStatements(sql, dbType);

        if (stmtList.size() != 1) {
            throw new Exception("sql not support count : " ~ sql);
        }

        SQLStatement stmt = stmtList.get(0);

        if (!(cast(SQLSelectStatement)(stmt) !is null)) {
            throw new Exception("sql not support count : " ~ sql);
        }

        SQLSelectStatement selectStmt = cast(SQLSelectStatement) stmt;
        return count(selectStmt.getSelect(), dbType);
    }

    public static string limit(string sql, string dbType, int offset, int count) {
        List!(SQLStatement) stmtList = SQLUtils.parseStatements(sql, dbType);

        if (stmtList.size() != 1) {
            throw new Exception("sql not support count : " ~ sql);
        }

        SQLStatement stmt = stmtList.get(0);

        if (!(cast(SQLSelectStatement)(stmt) !is null)) {
            throw new Exception("sql not support count : " ~ sql);
        }

        SQLSelectStatement selectStmt = cast(SQLSelectStatement) stmt;

        return limit(selectStmt.getSelect(), dbType, offset, count);
    }

    public static string limit(SQLSelect select, string dbType, int offset, int count) {
        limit(select, dbType, offset, count, false);

        return SQLUtils.toSQLString(select, dbType);
    }

    public static bool limit(SQLSelect select, string dbType, int offset, int count, bool check) {
        SQLSelectQuery query = select.getQuery();

        // if (DBType.ORACLE.opEquals(dbType)) {
        //     return limitOracle(select, dbType, offset, count, check);
        // }

        // if (DBType.DB2.opEquals(dbType)) {
        //     return limitDB2(select, dbType, offset, count, check);
        // }

        // if (DBType.SQL_SERVER.opEquals(dbType) || DBType.JTDS.opEquals(dbType)) {
        //     return limitSQLServer(select, dbType, offset, count, check);
        // }

        return limitQueryBlock(select, dbType, offset, count, check);
    }

    private static bool limitQueryBlock(SQLSelect select, string dbType, int offset, int count, bool check) {
        SQLSelectQuery query = select.getQuery();
        if (cast(SQLUnionQuery)(query) !is null) {
            SQLUnionQuery union_p = cast(SQLUnionQuery) query;
            return limitUnion(union_p, dbType, offset, count, check);
        }

        SQLSelectQueryBlock queryBlock = cast(SQLSelectQueryBlock) query;
        if (DBType.MYSQL.opEquals(dbType) || //
            DBType.MARIADB.opEquals(dbType) /*|| //
             DBType.H2.opEquals(dbType) */) {
            return limitMySqlQueryBlock(queryBlock, dbType, offset, count, check);
        }

        if (DBType.POSTGRESQL.opEquals(dbType)) {
            return limitPostgreSQLQueryBlock(cast(PGSelectQueryBlock) queryBlock, dbType, offset, count, check);
        }
        throw new Exception("limitQueryBlock");
    }

    private static bool limitPostgreSQLQueryBlock(PGSelectQueryBlock queryBlock, string dbType, int offset, int count, bool check) {
        SQLLimit limit = queryBlock.getLimit();
        if (limit !is null) {
            if (offset > 0) {
                limit.setOffset(new SQLIntegerExpr(offset));
            }

            if (check && cast(SQLNumericLiteralExpr)limit.getRowCount() !is null) {
                int rowCount = (cast(SQLNumericLiteralExpr) limit.getRowCount()).getNumber().intValue();
                if (rowCount <= count && offset <= 0) {
                    return false;
                }
            }

            limit.setRowCount(new SQLIntegerExpr(count));
        }

        limit = new SQLLimit();
        if (offset > 0) {
            limit.setOffset(new SQLIntegerExpr(offset));
        }
        limit.setRowCount(new SQLIntegerExpr(count));
        queryBlock.setLimit(limit);
        return true;
    }

    // private static bool limitDB2(SQLSelect select, string dbType, int offset, int count, bool check) {
    //     SQLSelectQuery query = select.getQuery();

    //     SQLBinaryOpExpr gt = new SQLBinaryOpExpr(new SQLIdentifierExpr("ROWNUM"), //
    //                                              SQLBinaryOperator.GreaterThan, //
    //                                              new SQLNumberExpr(offset), //
    //                                              DBType.DB2);
    //     SQLBinaryOpExpr lteq = new SQLBinaryOpExpr(new SQLIdentifierExpr("ROWNUM"), //
    //                                                SQLBinaryOperator.LessThanOrEqual, //
    //                                                new SQLNumberExpr(count + offset), //
    //                                                DBType.DB2);
    //     SQLBinaryOpExpr pageCondition = new SQLBinaryOpExpr(gt, SQLBinaryOperator.BooleanAnd, lteq, DBType.DB2);

    //     if (cast(SQLSelectQueryBlock)(query) !is null) {
    //         DB2SelectQueryBlock queryBlock = cast(DB2SelectQueryBlock) query;
    //         if (offset <= 0) {
    //             SQLExpr first = queryBlock.getFirst();
    //             if (check && first !is null && cast(SQLNumericLiteralExpr)(first) !is null) {
    //                 int rowCount = (cast(SQLNumericLiteralExpr) first).getNumber().intValue();
    //                 if (rowCount < count) {
    //                     return false;
    //                 }
    //             }
    //             queryBlock.setFirst(new SQLIntegerExpr(count));
    //             return true;
    //         }

    //         SQLAggregateExpr aggregateExpr = new SQLAggregateExpr("ROW_NUMBER");
    //         SQLOrderBy orderBy = select.getOrderBy();
            
    //         if (orderBy is null && cast(SQLSelectQueryBlock)select.getQuery() !is null) {
    //             SQLSelectQueryBlock selectQueryBlcok = cast(SQLSelectQueryBlock) select.getQuery();
    //             orderBy = selectQueryBlcok.getOrderBy();
    //             selectQueryBlcok.setOrderBy(null);
    //         } else {
    //             select.setOrderBy(null);                
    //         }
            
    //         aggregateExpr.setOver(new SQLOver(orderBy));

    //         queryBlock.getSelectList().add(new SQLSelectItem(aggregateExpr, "ROWNUM"));

    //         DB2SelectQueryBlock countQueryBlock = new DB2SelectQueryBlock();
    //         countQueryBlock.getSelectList().add(new SQLSelectItem(new SQLAllColumnExpr()));

    //         countQueryBlock.setFrom(new SQLSubqueryTableSource(select.clone(), "XX"));

    //         countQueryBlock.setWhere(pageCondition);

    //         select.setQuery(countQueryBlock);

    //         return true;
    //     }

    //     DB2SelectQueryBlock countQueryBlock = new DB2SelectQueryBlock();
    //     countQueryBlock.getSelectList().add(new SQLSelectItem(new SQLPropertyExpr(new SQLIdentifierExpr("XX"), "*")));
    //     SQLAggregateExpr aggregateExpr = new SQLAggregateExpr("ROW_NUMBER");
    //     SQLOrderBy orderBy = select.getOrderBy();
    //     aggregateExpr.setOver(new SQLOver(orderBy));
    //     select.setOrderBy(null);
    //     countQueryBlock.getSelectList().add(new SQLSelectItem(aggregateExpr, "ROWNUM"));

    //     countQueryBlock.setFrom(new SQLSubqueryTableSource(select.clone(), "XX"));

    //     if (offset <= 0) {
    //         select.setQuery(countQueryBlock);
    //         return true;
    //     }

    //     DB2SelectQueryBlock offsetQueryBlock = new DB2SelectQueryBlock();
    //     offsetQueryBlock.getSelectList().add(new SQLSelectItem(new SQLAllColumnExpr()));
    //     offsetQueryBlock.setFrom(new SQLSubqueryTableSource(new SQLSelect(countQueryBlock), "XXX"));
    //     offsetQueryBlock.setWhere(pageCondition);

    //     select.setQuery(offsetQueryBlock);

    //     return true;
    // }

    // private static bool limitSQLServer(SQLSelect select, string dbType, int offset, int count, bool check) {
    //     SQLSelectQuery query = select.getQuery();

    //     SQLBinaryOpExpr gt = new SQLBinaryOpExpr(new SQLIdentifierExpr("ROWNUM"), //
    //                                              SQLBinaryOperator.GreaterThan, //
    //                                              new SQLNumberExpr(offset), //
    //                                              DBType.SQL_SERVER);
    //     SQLBinaryOpExpr lteq = new SQLBinaryOpExpr(new SQLIdentifierExpr("ROWNUM"), //
    //                                                SQLBinaryOperator.LessThanOrEqual, //
    //                                                new SQLNumberExpr(count + offset), //
    //                                                DBType.SQL_SERVER);
    //     SQLBinaryOpExpr pageCondition = new SQLBinaryOpExpr(gt, SQLBinaryOperator.BooleanAnd, lteq,
    //                                                         DBType.SQL_SERVER);

    //     if (cast(SQLSelectQueryBlock)(query) !is null) {
    //         SQLServerSelectQueryBlock queryBlock = cast(SQLServerSelectQueryBlock) query;
    //         if (offset <= 0) {
    //             SQLServerTop top = queryBlock.getTop();
    //             if (check && top !is null && !top.isPercent() && cast(SQLNumericLiteralExpr)top.getExpr() !is null) {
    //                 int rowCount = (cast(SQLNumericLiteralExpr) top.getExpr()).getNumber().intValue();
    //                 if (rowCount <= count) {
    //                     return false;
    //                 }
    //             }
    //             queryBlock.setTop(new SQLServerTop(new SQLNumberExpr(count)));
    //             return true;
    //         }

    //         SQLAggregateExpr aggregateExpr = new SQLAggregateExpr("ROW_NUMBER");
    //         SQLOrderBy orderBy = select.getOrderBy();
    //         aggregateExpr.setOver(new SQLOver(orderBy));
    //         select.setOrderBy(null);

    //         queryBlock.getSelectList().add(new SQLSelectItem(aggregateExpr, "ROWNUM"));

    //         SQLServerSelectQueryBlock countQueryBlock = new SQLServerSelectQueryBlock();
    //         countQueryBlock.getSelectList().add(new SQLSelectItem(new SQLAllColumnExpr()));

    //         countQueryBlock.setFrom(new SQLSubqueryTableSource(select.clone(), "XX"));

    //         countQueryBlock.setWhere(pageCondition);

    //         select.setQuery(countQueryBlock);

    //         return true;
    //     }

    //     SQLServerSelectQueryBlock countQueryBlock = new SQLServerSelectQueryBlock();
    //     countQueryBlock.getSelectList().add(new SQLSelectItem(new SQLPropertyExpr(new SQLIdentifierExpr("XX"), "*")));

    //     countQueryBlock.setFrom(new SQLSubqueryTableSource(select.clone(), "XX"));

    //     if (offset <= 0) {
    //         countQueryBlock.setTop(new SQLServerTop(new SQLNumberExpr(count)));

    //         select.setQuery(countQueryBlock);
    //         return true;
    //     }

    //     SQLAggregateExpr aggregateExpr = new SQLAggregateExpr("ROW_NUMBER");
    //     SQLOrderBy orderBy = select.getOrderBy();
    //     aggregateExpr.setOver(new SQLOver(orderBy));
    //     select.setOrderBy(null);
    //     countQueryBlock.getSelectList().add(new SQLSelectItem(aggregateExpr, "ROWNUM"));

    //     SQLServerSelectQueryBlock offsetQueryBlock = new SQLServerSelectQueryBlock();
    //     offsetQueryBlock.getSelectList().add(new SQLSelectItem(new SQLAllColumnExpr()));
    //     offsetQueryBlock.setFrom(new SQLSubqueryTableSource(new SQLSelect(countQueryBlock), "XXX"));
    //     offsetQueryBlock.setWhere(pageCondition);

    //     select.setQuery(offsetQueryBlock);

    //     return true;
    // }

    // private static bool limitOracle(SQLSelect select, string dbType, int offset, int count, bool check) {
    //     SQLSelectQuery query = select.getQuery();

    //     if (cast(SQLSelectQueryBlock)(query) !is null) {
    //         OracleSelectQueryBlock queryBlock = cast(OracleSelectQueryBlock) query;
    //         SQLOrderBy orderBy = select.getOrderBy();
    //         if (orderBy is null && queryBlock.getOrderBy() !is null) {
    //             orderBy = queryBlock.getOrderBy();
    //         }

    //         if (queryBlock.getGroupBy() is null
    //                 && orderBy is null && offset <= 0) {

    //             SQLExpr where = queryBlock.getWhere();
    //             if (check && cast(SQLBinaryOpExpr)(where) !is null) {
    //                 SQLBinaryOpExpr binaryOpWhere = cast(SQLBinaryOpExpr) where;
    //                 if (binaryOpWhere.getOperator() == SQLBinaryOperator.LessThanOrEqual) {
    //                     SQLExpr left = binaryOpWhere.getLeft();
    //                     SQLExpr right = binaryOpWhere.getRight();
    //                     if (cast(SQLIdentifierExpr)(left) !is null
    //                             && (cast(SQLIdentifierExpr) left).getName().equalsIgnoreCase("ROWNUM")
    //                             && cast(SQLNumericLiteralExpr)(right) !is null) {
    //                         int rowCount = (cast(SQLNumericLiteralExpr) right).getNumber().intValue();
    //                         if (rowCount <= count) {
    //                             return false;
    //                         }
    //                     }
    //                 }
    //             }

    //             SQLExpr condition = new SQLBinaryOpExpr(new SQLIdentifierExpr("ROWNUM"), //
    //                                                     SQLBinaryOperator.LessThanOrEqual, //
    //                                                     new SQLNumberExpr(count), //
    //                                                     DBType.ORACLE);
    //             if (queryBlock.getWhere() is null) {
    //                 queryBlock.setWhere(condition);
    //             } else {
    //                 queryBlock.setWhere(new SQLBinaryOpExpr(queryBlock.getWhere(), //
    //                                                         SQLBinaryOperator.BooleanAnd, //
    //                                                         condition, //
    //                                                         DBType.ORACLE));
    //             }

    //             return true;
    //         }
    //     }

    //     OracleSelectQueryBlock countQueryBlock = new OracleSelectQueryBlock();
    //     countQueryBlock.getSelectList().add(new SQLSelectItem(new SQLPropertyExpr(new SQLIdentifierExpr("XX"), "*")));
    //     countQueryBlock.getSelectList().add(new SQLSelectItem(new SQLIdentifierExpr("ROWNUM"), "RN"));

    //     countQueryBlock.setFrom(new SQLSubqueryTableSource(select.clone(), "XX"));
    //     countQueryBlock.setWhere(new SQLBinaryOpExpr(new SQLIdentifierExpr("ROWNUM"), //
    //                                                  SQLBinaryOperator.LessThanOrEqual, //
    //                                                  new SQLNumberExpr(count + offset), //
    //                                                  DBType.ORACLE));

    //     select.setOrderBy(null);
    //     if (offset <= 0) {
    //         select.setQuery(countQueryBlock);
    //         return true;
    //     }

    //     OracleSelectQueryBlock offsetQueryBlock = new OracleSelectQueryBlock();
    //     offsetQueryBlock.getSelectList().add(new SQLSelectItem(new SQLAllColumnExpr()));
    //     offsetQueryBlock.setFrom(new SQLSubqueryTableSource(new SQLSelect(countQueryBlock), "XXX"));
    //     offsetQueryBlock.setWhere(new SQLBinaryOpExpr(new SQLIdentifierExpr("RN"), //
    //                                                   SQLBinaryOperator.GreaterThan, //
    //                                                   new SQLNumberExpr(offset), //
    //                                                   DBType.ORACLE));

    //     select.setQuery(offsetQueryBlock);
    //     return true;
    // }

    private static bool limitMySqlQueryBlock(SQLSelectQueryBlock queryBlock, string dbType, int offset, int count, bool check) {
        SQLLimit limit = queryBlock.getLimit();
        if (limit !is null) {
            if (offset > 0) {
                limit.setOffset(new SQLIntegerExpr(offset));
            }

            if (check && cast(SQLNumericLiteralExpr)limit.getRowCount() !is null) {
                int rowCount = (cast(SQLNumericLiteralExpr) limit.getRowCount()).getNumber().intValue();
                if (rowCount <= count && offset <= 0) {
                    return false;
                }
            } else if (check && cast(SQLVariantRefExpr)limit.getRowCount() !is null) {
                return false;
            }

            limit.setRowCount(new SQLIntegerExpr(count));
        }

        if (limit is null) {
            limit = new SQLLimit();
            if (offset > 0) {
                limit.setOffset(new SQLIntegerExpr(offset));
            }
            limit.setRowCount(new SQLIntegerExpr(count));
            queryBlock.setLimit(limit);
        }

        return true;
    }

    private static bool limitUnion(SQLUnionQuery queryBlock, string dbType, int offset, int count, bool check) {
        SQLLimit limit = queryBlock.getLimit();
        if (limit !is null) {
            if (offset > 0) {
                limit.setOffset(new SQLIntegerExpr(offset));
            }

            if (check && cast(SQLNumericLiteralExpr)limit.getRowCount() !is null) {
                int rowCount = (cast(SQLNumericLiteralExpr) limit.getRowCount()).getNumber().intValue();
                if (rowCount <= count && offset <= 0) {
                    return false;
                }
            } else if (check && cast(SQLVariantRefExpr)limit.getRowCount() !is null) {
                return false;
            }

            limit.setRowCount(new SQLIntegerExpr(count));
        }

        if (limit is null) {
            limit = new SQLLimit();
            if (offset > 0) {
                limit.setOffset(new SQLIntegerExpr(offset));
            }
            limit.setRowCount(new SQLIntegerExpr(count));
            queryBlock.setLimit(limit);
        }

        return true;
    }

    private static string count(SQLSelect select, string dbType) {
        if (select.getOrderBy() !is null) {
            select.setOrderBy(null);
        }

        SQLSelectQuery query = select.getQuery();
        clearOrderBy(query);

        if (cast(SQLSelectQueryBlock)(query) !is null) {
            SQLSelectItem countItem = createCountItem(dbType);

            SQLSelectQueryBlock queryBlock = cast(SQLSelectQueryBlock) query;
            List!(SQLSelectItem) selectList = queryBlock.getSelectList();

            if (queryBlock.getGroupBy() !is null
                    && queryBlock.getGroupBy().getItems().size() > 0) {
                return createCountUseSubQuery(select, dbType);
            }
            
            int option = queryBlock.getDistionOption();
            if (option == SQLSetQuantifier.DISTINCT
                    && selectList.size() >= 1) {
                SQLAggregateExpr countExpr = new SQLAggregateExpr("COUNT", SQLAggregateOption.DISTINCT);
                for (int i = 0; i < selectList.size(); ++i) {
                    countExpr.addArgument(selectList.get(i).getExpr());
                }
                selectList.clear();
                queryBlock.setDistionOption(0);
                queryBlock.addSelectItem(countExpr);
            } else {
                selectList.clear();
                selectList.add(countItem);
            }
            return SQLUtils.toSQLString(select, dbType);
        } else if (cast(SQLUnionQuery)(query) !is null) {
            return createCountUseSubQuery(select, dbType);
        }

        throw new Exception("IllegalState");
    }

    private static string createCountUseSubQuery(SQLSelect select, string dbType) {
        SQLSelectQueryBlock countSelectQuery = createQueryBlock(dbType);

        SQLSelectItem countItem = createCountItem(dbType);
        countSelectQuery.getSelectList().add(countItem);

        SQLSubqueryTableSource fromSubquery = new SQLSubqueryTableSource(select);
        fromSubquery.setAlias("ALIAS_COUNT");
        countSelectQuery.setFrom(fromSubquery);

        SQLSelect countSelect = new SQLSelect(countSelectQuery);
        SQLSelectStatement countStmt = new SQLSelectStatement(countSelect, dbType);

        return SQLUtils.toSQLString(countStmt, dbType);
    }

    private static SQLSelectQueryBlock createQueryBlock(string dbType) {
        if (DBType.MYSQL.opEquals(dbType)
                || DBType.MARIADB.opEquals(dbType)
                /* || DBType.ALIYUN_ADS.opEquals(dbType) */) {
            return new MySqlSelectQueryBlock();
        }

        if (DBType.MARIADB.opEquals(dbType)) {
            return new MySqlSelectQueryBlock();
        }

        // if (DBType.H2.opEquals(dbType)) {
        //     return new MySqlSelectQueryBlock();
        // }

        // if (DBType.ORACLE.opEquals(dbType)) {
        //     return new OracleSelectQueryBlock();
        // }

        if (DBType.POSTGRESQL.opEquals(dbType)) {
            return new PGSelectQueryBlock();
        }

        // if (DBType.SQL_SERVER.opEquals(dbType) || DBType.JTDS.opEquals(dbType)) {
        //     return new SQLServerSelectQueryBlock();
        // }

        // if (DBType.DB2.opEquals(dbType)) {
        //     return new DB2SelectQueryBlock();
        // }

        return new SQLSelectQueryBlock();
    }

    private static SQLSelectItem createCountItem(string dbType) {
        SQLAggregateExpr countExpr = new SQLAggregateExpr("COUNT");

        countExpr.addArgument(new SQLAllColumnExpr());

        SQLSelectItem countItem = new SQLSelectItem(countExpr);
        return countItem;
    }

    private static void clearOrderBy(SQLSelectQuery query) {
        if (cast(SQLSelectQueryBlock)(query) !is null) {
            SQLSelectQueryBlock queryBlock = cast(SQLSelectQueryBlock) query;
            if (queryBlock.getOrderBy() !is null) {
                queryBlock.setOrderBy(null);
            }
            return;
        }

        if (cast(SQLUnionQuery)(query) !is null) {
            SQLUnionQuery union_p = cast(SQLUnionQuery) query;
            if (union_p.getOrderBy() !is null) {
                union_p.setOrderBy(null);
            }
            clearOrderBy(union_p.getLeft());
            clearOrderBy(union_p.getRight());
        }
    }
    
    /**
     * 
     * @param sql
     * @param dbType
     * @return if not exists limit, return -1;
     */
    public static int getLimit(string sql, string dbType) {
        List!(SQLStatement) stmtList = SQLUtils.parseStatements(sql, dbType);

        if (stmtList.size() != 1) {
            return -1;
        }

        SQLStatement stmt = stmtList.get(0);

        if (cast(SQLSelectStatement)(stmt) !is null) {
            SQLSelectStatement selectStmt = cast(SQLSelectStatement) stmt;
            SQLSelectQuery query = selectStmt.getSelect().getQuery();
            if (cast(SQLSelectQueryBlock)(query) !is null) {
                if (cast(MySqlSelectQueryBlock)(query) !is null) {
                    SQLLimit limit = (cast(MySqlSelectQueryBlock) query).getLimit();

                    if (limit is null) {
                        return -1;
                    }

                    SQLExpr rowCountExpr = limit.getRowCount();

                    if (cast(SQLNumericLiteralExpr)(rowCountExpr) !is null) {
                        int rowCount = (cast(SQLNumericLiteralExpr) rowCountExpr).getNumber().intValue();
                        return rowCount;
                    }

                    return Integer.MAX_VALUE;
                }

                // if (cast(OdpsSelectQueryBlock)(query) !is null) {
                //     SQLLimit limit = (cast(OdpsSelectQueryBlock) query).getLimit();
                //     SQLExpr rowCountExpr = limit !is null ? limit.getRowCount() : null;

                //     if (cast(SQLNumericLiteralExpr)(rowCountExpr) !is null) {
                //         int rowCount = (cast(SQLNumericLiteralExpr) rowCountExpr).getNumber().intValue();
                //         return rowCount;
                //     }

                //     return Integer.MAX_VALUE;
                // }

                return -1;
            }
        }
        
        return -1;
    }

    public static bool hasUnorderedLimit(string sql, string dbType) {
        List!(SQLStatement) stmtList = SQLUtils.parseStatements(sql, dbType);

        if (DBType.MYSQL.opEquals(dbType)) {

            MySqlUnorderedLimitDetectVisitor visitor = new MySqlUnorderedLimitDetectVisitor();

            foreach(SQLStatement stmt ; stmtList) {
                stmt.accept(visitor);
            }

            return visitor.unorderedLimitCount > 0;
        }

        // if (DBType.ORACLE.opEquals(dbType)) {

        //     OracleUnorderedLimitDetectVisitor visitor = new OracleUnorderedLimitDetectVisitor();

        //     foreach(SQLStatement stmt ; stmtList) {
        //         stmt.accept(visitor);
        //     }

        //     return visitor.unorderedLimitCount > 0;
        // }

        throw new Exception("not supported. dbType : " ~ dbType);
    }

    private static class MySqlUnorderedLimitDetectVisitor : MySqlASTVisitorAdapter {
        public int unorderedLimitCount;
        // alias endVisit = SQLASTVisitorAdapter.endVisit;
        // alias visit = SQLASTVisitorAdapter.visit;

        alias endVisit = MySqlASTVisitorAdapter.endVisit;
        alias visit = MySqlASTVisitorAdapter.visit;

        override
        public bool visit(MySqlSelectQueryBlock x) {
            SQLOrderBy orderBy = x.getOrderBy();
            SQLLimit limit = x.getLimit();

            if (limit !is null && (orderBy is null || orderBy.getItems().size() == 0)) {
                bool subQueryHasOrderBy = false;
                SQLTableSource from = x.getFrom();
                if (cast(SQLSubqueryTableSource)(from) !is null) {
                    SQLSubqueryTableSource subqueryTabSrc = cast(SQLSubqueryTableSource) from;
                    SQLSelect select = subqueryTabSrc.getSelect();
                    if (cast(SQLSelectQueryBlock)select.getQuery() !is null) {
                        SQLSelectQueryBlock subquery = cast(SQLSelectQueryBlock) select.getQuery();
                        if (subquery.getOrderBy() !is null && subquery.getOrderBy().getItems().size() > 0) {
                            subQueryHasOrderBy = true;
                        }
                    }
                }

                if (!subQueryHasOrderBy) {
                    unorderedLimitCount++;
                }
            }
            return true;
        }
    }

    // private static class OracleUnorderedLimitDetectVisitor : OracleASTVisitorAdapter {
    //     public int unorderedLimitCount;

    //     public bool visit(SQLBinaryOpExpr x) {
    //         SQLExpr left = x.getLeft();
    //         SQLExpr right = x.getRight();

    //         bool rownum = false;
    //         if (cast(SQLIdentifierExpr)(left) !is null
    //                 && (cast(SQLIdentifierExpr) left).getName().equalsIgnoreCase("ROWNUM")
    //                 && cast(SQLLiteralExpr)(right) !is null) {
    //             rownum = true;
    //         } else if (cast(SQLIdentifierExpr)(right) !is null
    //                 && (cast(SQLIdentifierExpr) right).getName().equalsIgnoreCase("ROWNUM")
    //                 && cast(SQLLiteralExpr)(left) !is null) {
    //             rownum = true;
    //         }

    //         OracleSelectQueryBlock selectQuery = null;
    //         if (rownum) {
    //             for (SQLObject parent = x.getParent(); parent !is null; parent = parent.getParent()) {
    //                 if (cast(SQLSelectQuery)(parent) !is null) {
    //                     if (cast(OracleSelectQueryBlock)(parent) !is null) {
    //                         OracleSelectQueryBlock queryBlock = cast(OracleSelectQueryBlock) parent;
    //                         SQLTableSource from = queryBlock.getFrom();
    //                         if (cast(SQLExprTableSource)(from) !is null) {
    //                             selectQuery = queryBlock;
    //                         } else if (cast(SQLSubqueryTableSource)(from) !is null) {
    //                             SQLSelect subSelect = (cast(SQLSubqueryTableSource) from).getSelect();
    //                             if (cast(OracleSelectQueryBlock)subSelect.getQuery() !is null) {
    //                                 selectQuery = cast(OracleSelectQueryBlock) subSelect.getQuery();
    //                             }
    //                         }
    //                     }
    //                     break;
    //                 }
    //             }
    //         }


    //         if (selectQuery !is null) {
    //             SQLOrderBy orderBy = selectQuery.getOrderBy();

    //             SQLObject parent = selectQuery.getParent();
    //             if (orderBy is null && cast(SQLSelect)(parent) !is null) {
    //                 SQLSelect select = cast(SQLSelect) parent;
    //                 orderBy = select.getOrderBy();
    //             }

    //             if (orderBy is null || orderBy.getItems().size() == 0) {
    //                 unorderedLimitCount++;
    //             }
    //         }

    //         return true;
    //     }

    //     override
    //     public bool visit(OracleSelectQueryBlock queryBlock) {
    //         bool isExprTableSrc =  cast(SQLExprTableSource)queryBlock.getFrom() !is null;

    //         if (!isExprTableSrc) {
    //             return true;
    //         }

    //         bool rownum = false;
    //         foreach(SQLSelectItem item ; queryBlock.getSelectList()) {
    //             SQLExpr itemExpr = item.getExpr();
    //             if (cast(SQLIdentifierExpr)(itemExpr) !is null) {
    //                 if ((cast(SQLIdentifierExpr) itemExpr).getName().equalsIgnoreCase("ROWNUM")) {
    //                     rownum = true;
    //                     break;
    //                 }
    //             }
    //         }

    //         if (!rownum) {
    //             return true;
    //         }

    //         SQLObject parent = queryBlock.getParent();
    //         if (!(cast(SQLSelect)(parent) !is null)) {
    //             return true;
    //         }

    //         SQLSelect select = cast(SQLSelect) parent;

    //         if (select.getOrderBy() is null || select.getOrderBy().getItems().size() == 0) {
    //             unorderedLimitCount++;
    //         }

    //         return false;
    //     }
    // }
}
