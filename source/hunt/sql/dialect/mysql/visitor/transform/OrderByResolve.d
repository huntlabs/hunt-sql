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
module hunt.sql.dialect.mysql.visitor.transform.OrderByResolve;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLOrderBy;
import hunt.sql.ast.statement.SQLSelect;
import hunt.sql.ast.statement.SQLSelectItem;
import hunt.sql.ast.statement.SQLSelectOrderByItem;
import hunt.sql.ast.statement.SQLSelectQueryBlock;
// import hunt.sql.dialect.oracle.ast.stmt.OracleSelectQueryBlock;
// import hunt.sql.dialect.oracle.visitor.OracleASTVisitorAdapter;
import hunt.sql.util.FnvHash;


import hunt.container;

/**
 * Created by wenshao on 27/07/2017.
 */
// public class OrderByResolve : OracleASTVisitorAdapter {
//      static long DBMS_RANDOM_VALUE = FnvHash.hashCode64("DBMS_RANDOM.value");

//     public bool visit(SQLSelect x) {
//         SQLSelectQueryBlock queryBlock = x.getQueryBlock();
//         if (queryBlock is null) {
//             return super.visit(x);
//         }

//         if (x.getOrderBy() !is null && queryBlock.isForUpdate() && queryBlock.getOrderBy() is null) {
//             queryBlock.setOrderBy(x.getOrderBy());
//             x.setOrderBy(null);
//         }

//         SQLOrderBy orderBy = queryBlock.getOrderBy();
//         if (orderBy is null) {
//             return super.visit(x);
//         }


//         if (!queryBlock.selectItemHasAllColumn(false)) {
//             List!(SQLSelectOrderByItem) notContainsOrderBy = new ArrayList!(SQLSelectOrderByItem)();

//             foreach(SQLSelectOrderByItem orderByItem ; orderBy.getItems()) {
//                 SQLExpr orderByExpr = orderByItem.getExpr();

//                 if (cast(SQLName)(orderByExpr) !is null) {
//                     if ((cast(SQLName) orderByExpr).hashCode64() == DBMS_RANDOM_VALUE) {
//                         continue;
//                     }

//                     long hashCode64 = (cast(SQLName) orderByExpr).nameHashCode64();
//                     SQLSelectItem selectItem = queryBlock.findSelectItem(hashCode64);
//                     if (selectItem is null) {
//                         queryBlock.addSelectItem(orderByExpr.clone());
//                     }
//                 }
//             }

//             if (notContainsOrderBy.size() > 0) {
//                 foreach(SQLSelectOrderByItem orderByItem ; notContainsOrderBy) {
//                     queryBlock.addSelectItem(orderByItem.getExpr());
//                 }

//                 OracleSelectQueryBlock queryBlock1 = new OracleSelectQueryBlock();
//                 queryBlock1.setFrom(queryBlock, "x");
//                 x.setQuery(queryBlock1);
//             }
//         }



//         return super.visit(x);
//     }
// }
