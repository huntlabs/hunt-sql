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
module hunt.sql.dialect.mysql.visitor.transform.FromSubqueryResolver;

import hunt.sql.SQLUtils;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLObject;
import hunt.sql.ast.SQLStatement;
import hunt.sql.ast.expr.SQLIdentifierExpr;
import hunt.sql.ast.statement;
// import hunt.sql.dialect.oracle.ast.stmt.OracleSelectSubqueryTableSource;
// import hunt.sql.dialect.oracle.ast.stmt.OracleSelectTableReference;
// import hunt.sql.dialect.oracle.visitor.OracleASTVisitorAdapter;


import hunt.container;


/**
 */
// public class FromSubqueryResolver : OracleASTVisitorAdapter {
//     private  List!(SQLStatement) targetList;
//     private  string viewName;
//     private  Map!(string, string) mappings;

//     private int viewNameSeed = 1;

//     this()
//     {
//         mappings = new LinkedHashMap!(string, string)();
//     }

//     public this(List!(SQLStatement) targetList, string viewName) {
//         this.targetList = targetList;
//         this.viewName = viewName;
//     }

//     // public bool visit(OracleSelectSubqueryTableSource x) {
//     //     return visit(cast(SQLSubqueryTableSource) x);
//     // }

//     public bool visit(SQLSubqueryTableSource x) {
//         string subViewName = generateSubViewName();

//         SQLObject parent = x.getParent();
//         if(cast(SQLSelectQueryBlock)(parent) !is null) {
//             SQLSelectQueryBlock queryBlock = cast(SQLSelectQueryBlock) parent;
//             queryBlock.setFrom(subViewName, x.getAlias());
//         } else if(cast(SQLJoinTableSource)(parent) !is null) {
//             SQLJoinTableSource join = cast(SQLJoinTableSource) parent;
//             if (join.getLeft() == x) {
//                 join.setLeft(subViewName, x.getAlias());
//             } else if (join.getRight() == x) {
//                 join.setRight(subViewName, x.getAlias());
//             }
//         }

//         SQLCreateViewStatement stmt = new SQLCreateViewStatement();

//         stmt.setName(generateSubViewName());

//         SQLSelect select = x.getSelect();
//         stmt.setSubQuery(select);

//         targetList.add(0, stmt);

//         stmt.accept(new FromSubqueryResolver(targetList, viewName));

//         return false;
//     }

//     public bool visit(SQLExprTableSource x) {
//         SQLExpr expr = x.getExpr();
//         if (cast(SQLIdentifierExpr)(expr) !is null) {
//             SQLIdentifierExpr identifierExpr = cast(SQLIdentifierExpr) expr;
//             string ident = identifierExpr.getName();
//             string mappingIdent = mappings.get(ident);
//             if (mappingIdent !is null) {
//                 x.setExpr(new SQLIdentifierExpr(mappingIdent));
//             }
//         }
//         return false;
//     }

//     public bool visit(OracleSelectTableReference x) {
//         return visit(cast(SQLExprTableSource) x);
//     }

//     private string generateSubViewName() {
//         return this.viewName ~ "_" ~ targetList.size();
//     }

//     public static List!(SQLStatement) resolve(SQLCreateViewStatement stmt) {
//         List!(SQLStatement) targetList = new ArrayList!(SQLStatement)();
//         targetList.add(stmt);

//         string viewName = SQLUtils.normalize(stmt.getName().getSimpleName());

//         FromSubqueryResolver visitor = new FromSubqueryResolver(targetList, viewName);

//         SQLWithSubqueryClause withSubqueryClause = stmt.getSubQuery().getWithSubQuery();
//         if (withSubqueryClause !is null) {
//             stmt.getSubQuery().setWithSubQuery(null);

//             foreach(SQLWithSubqueryClause.Entry entry ; withSubqueryClause.getEntries()) {
//                 string entryName = entry.getAlias();

//                 SQLCreateViewStatement entryStmt = new SQLCreateViewStatement();
//                 entryStmt.setOrReplace(true);
//                 entryStmt.setDbType(stmt.getDbType());

//                 string entryViewName = visitor.generateSubViewName();
//                 entryStmt.setName(entryViewName);
//                 entryStmt.setSubQuery(entry.getSubQuery());

//                 visitor.targetList.add(0, entryStmt);
//                 visitor.mappings.put(entryName, entryViewName);

//                 entryStmt.accept(visitor);
//             }
//         }

//         stmt.accept(visitor);

//         string dbType = stmt.getDbType();
//         for (int i = 0; i < targetList.size() - 1; ++i) {
//             SQLCreateViewStatement targetStmt = cast(SQLCreateViewStatement) targetList.get(i);
//             targetStmt.setOrReplace(true);
//             targetStmt.setDbType(dbType);
//             targetStmt.setAfterSemi(true);
//         }

//         return targetList;
//     }
// }
