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
module hunt.sql.dialect.postgresql.visitor.PGASTVisitor;

import hunt.sql.dialect.postgresql.ast.expr;
import hunt.sql.dialect.postgresql.ast.stmt;
import hunt.sql.visitor.SQLASTVisitor;

public interface PGASTVisitor : SQLASTVisitor {

    void endVisit(PGSelectQueryBlock x);

    bool visit(PGSelectQueryBlock x);

    void endVisit(PGSelectQueryBlock.WindowClause x);

    bool visit(PGSelectQueryBlock.WindowClause x);

    void endVisit(PGSelectQueryBlock.FetchClause x);

    bool visit(PGSelectQueryBlock.FetchClause x);

    void endVisit(PGSelectQueryBlock.ForClause x);

    bool visit(PGSelectQueryBlock.ForClause x);

    void endVisit(PGDeleteStatement x);

    bool visit(PGDeleteStatement x);

    void endVisit(PGInsertStatement x);

    bool visit(PGInsertStatement x);

    void endVisit(PGSelectStatement x);

    bool visit(PGSelectStatement x);

    void endVisit(PGUpdateStatement x);

    bool visit(PGUpdateStatement x);

    void endVisit(PGFunctionTableSource x);

    bool visit(PGFunctionTableSource x);
    
    void endVisit(PGTypeCastExpr x);
    
    bool visit(PGTypeCastExpr x);
    
    void endVisit(PGValuesQuery x);
    
    bool visit(PGValuesQuery x);
    
    void endVisit(PGExtractExpr x);
    
    bool visit(PGExtractExpr x);
    
    void endVisit(PGBoxExpr x);
    
    bool visit(PGBoxExpr x);
    
    void endVisit(PGPointExpr x);
    
    bool visit(PGPointExpr x);
    
    void endVisit(PGMacAddrExpr x);
    
    bool visit(PGMacAddrExpr x);
    
    void endVisit(PGInetExpr x);
    
    bool visit(PGInetExpr x);
    
    void endVisit(PGCidrExpr x);
    
    bool visit(PGCidrExpr x);
    
    void endVisit(PGPolygonExpr x);
    
    bool visit(PGPolygonExpr x);
    
    void endVisit(PGCircleExpr x);
    
    bool visit(PGCircleExpr x);
    
    void endVisit(PGLineSegmentsExpr x);
    
    bool visit(PGLineSegmentsExpr x);

    void endVisit(PGShowStatement x);
    
    bool visit(PGShowStatement x);

    void endVisit(PGStartTransactionStatement x);
    bool visit(PGStartTransactionStatement x);

    void endVisit(PGConnectToStatement x);
    bool visit(PGConnectToStatement x);

}
