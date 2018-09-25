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
module hunt.sql.dialect.mysql.visitor.transform.NameResolveVisitor;

import hunt.sql.SQLUtils;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLObject;
import hunt.sql.ast.SQLStatement;
import hunt.sql.ast.expr;
import hunt.sql.ast.statement;
// import hunt.sql.dialect.oracle.visitor.OracleASTVisitorAdapter;
import hunt.sql.util.FnvHash;

/**
 * Created by wenshao on 26/07/2017.
 */
// public class NameResolveVisitor : OracleASTVisitorAdapter {
//     public bool visit(SQLIdentifierExpr x) {
//         SQLObject parent = x.getParent();

//         if (cast(SQLBinaryOpExpr)(parent) !is null
//                 && x.getResolvedColumn() is null) {
//             SQLBinaryOpExpr binaryOpExpr = cast(SQLBinaryOpExpr) parent;
//             bool isJoinCondition = cast(SQLName)binaryOpExpr.getLeft() !is null
//                     && cast(SQLName)binaryOpExpr.getRight() !is null;
//             if (isJoinCondition) {
//                 return false;
//             }
//         }

//         string name = x.getName();

//         if ("ROWNUM".equalsIgnoreCase(name)) {
//             return false;
//         }

//         long hash = x.nameHashCode64();
//         SQLTableSource tableSource = null;

//         if (hash == FnvHash.Constants.LEVEL
//                 || hash == FnvHash.Constants.CONNECT_BY_ISCYCLE
//                 || hash == FnvHash.Constants.SYSTIMESTAMP) {
//             return false;
//         }

//         if (cast(SQLPropertyExpr)(parent) !is null) {
//             return false;
//         }

//         for (; parent !is null; parent = parent.getParent()) {
//             if (cast(SQLTableSource)(parent) !is null) {
//                 return false;
//             }

//             if (cast(SQLSelectQueryBlock)(parent) !is null) {
//                 SQLSelectQueryBlock queryBlock = cast(SQLSelectQueryBlock) parent;

//                 if (queryBlock.getInto() !is null) {
//                     return false;
//                 }

//                 if (cast(SQLSelect)queryBlock.getParent() !is null) {
//                     SQLObject pp = queryBlock.getParent().getParent();
//                     if ( cast(SQLInSubQueryExpr)pp !is null || cast(SQLExistsExpr)(pp) !is null) {
//                         return false;
//                     }
//                 }

//                 SQLTableSource from = queryBlock.getFrom();
//                 if (cast(SQLExprTableSource)(from) !is null || cast(SQLSubqueryTableSource)(from) !is null) {
//                     string alias_p = from.getAlias();
//                     if (alias_p !is null) {
//                         SQLUtils.replaceInParent(x, new SQLPropertyExpr(alias_p, name));
//                     }
//                 }
//                 return false;
//             }
//         }
//         return true;
//     }

//     public bool visit(SQLPropertyExpr x) {
//         string ownerName = x.getOwnernName();
//         if (ownerName is null) {
//             return super.visit(x);
//         }

//         for (SQLObject parent = x.getParent(); parent !is null; parent = parent.getParent()) {
//             if (cast(SQLSelectQueryBlock)(parent) !is null) {
//                 SQLSelectQueryBlock queryBlock = cast(SQLSelectQueryBlock) parent;
//                 SQLTableSource tableSource = queryBlock.findTableSource(ownerName);
//                 if (tableSource is null) {
//                     continue;
//                 }

//                 string alias_p = tableSource.computeAlias();
//                 if (tableSource !is null
//                         && equalsIgnoreCase(ownerName, alias_p)
//                         && !ownerName.opEquals(alias_p)) {
//                     x.setOwner(alias_p);
//                 }

//                 break;
//             }
//         }

//         return super.visit(x);
//     }
// }
