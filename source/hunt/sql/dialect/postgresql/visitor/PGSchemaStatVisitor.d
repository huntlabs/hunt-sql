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
module hunt.sql.dialect.postgresql.visitor.PGSchemaStatVisitor;



import hunt.sql.ast.SQLName;
import hunt.sql.ast.statement.SQLSelectQueryBlock;
import hunt.sql.ast.statement.SQLSelectStatement;
import hunt.sql.ast.statement.SQLTableSource;
import hunt.sql.dialect.postgresql.ast.expr.PGBoxExpr;
import hunt.sql.dialect.postgresql.ast.expr.PGCidrExpr;
import hunt.sql.dialect.postgresql.ast.expr.PGCircleExpr;
import hunt.sql.dialect.postgresql.ast.expr.PGExtractExpr;
import hunt.sql.dialect.postgresql.ast.expr.PGInetExpr;
import hunt.sql.dialect.postgresql.ast.expr.PGLineSegmentsExpr;
import hunt.sql.dialect.postgresql.ast.expr.PGMacAddrExpr;
import hunt.sql.dialect.postgresql.ast.expr.PGPointExpr;
import hunt.sql.dialect.postgresql.ast.expr.PGPolygonExpr;
import hunt.sql.dialect.postgresql.ast.expr.PGTypeCastExpr;
import hunt.sql.dialect.postgresql.ast.stmt;
import hunt.sql.dialect.postgresql.ast.stmt.PGSelectQueryBlock;
// import hunt.sql.dialect.postgresql.ast.stmt.PGSelectQueryBlock.FetchClause;
// import hunt.sql.dialect.postgresql.ast.stmt.PGSelectQueryBlock.ForClause;
// import hunt.sql.dialect.postgresql.ast.stmt.PGSelectQueryBlock.WindowClause;
import hunt.sql.visitor.SchemaStatVisitor;
import hunt.sql.stat.TableStat;
// import hunt.sql.stat.TableStat.Mode;
import hunt.sql.util.DBType;
import hunt.sql.util.PGUtils;
import hunt.sql.dialect.postgresql.visitor.PGASTVisitor;
import hunt.collection;
import hunt.sql.ast.SQLObject;

public class PGSchemaStatVisitor : SchemaStatVisitor , PGASTVisitor {

    alias visit = SchemaStatVisitor.visit;
    alias endVisit = SchemaStatVisitor.endVisit;
    

    public this() {
        super(DBType.POSTGRESQL.name);
    }

    override
    public string getDbType() {
        return DBType.POSTGRESQL.name;
    }

    override
    public void endVisit(PGSelectQueryBlock.WindowClause x) {

    }

    override
    public bool visit(PGSelectQueryBlock.WindowClause x) {
        return true;
    }

    override
    public void endVisit(PGSelectQueryBlock.FetchClause x) {

    }

    override
    public bool visit(PGSelectQueryBlock.FetchClause x) {
        return true;
    }

    override
    public void endVisit(PGSelectQueryBlock.ForClause x) {

    }

    override
    public bool visit(PGSelectQueryBlock.ForClause x) {

        return true;
    }

    override
    public void endVisit(PGDeleteStatement x) {

    }

    override
    public bool visit(PGDeleteStatement x) {
        if (repository !is null
                && x.getParent() is null) {
            repository.resolve(x);
        }

        if (x.getWith() !is null) {
            x.getWith().accept(this);
        }

        SQLTableSource using = x.getUsing();
        if (using !is null) {
            using.accept(this);
        }

        x.putAttribute("_original_use_mode", cast(Object)(getMode()));
        setMode(x, TableStat.Mode.Delete);

        TableStat stat = getTableStat(x.getTableName());
        stat.incrementDeleteCount();

        accept(x.getWhere());

        return false;
    }

    override
    public void endVisit(PGInsertStatement x) {

    }

    override
    public bool visit(PGInsertStatement x) {
        if (repository !is null
                && x.getParent() is null) {
            repository.resolve(x);
        }

        if (x.getWith() !is null) {
            x.getWith().accept(this);
        }

        x.putAttribute("_original_use_mode", cast(Object)(getMode()));
        setMode(x, TableStat.Mode.Insert);


        SQLName tableName = x.getTableName();
        {
            TableStat stat = getTableStat(tableName);
            stat.incrementInsertCount();
        }

        accept(cast(List!SQLObject)(x.getColumns()));
        accept(x.getQuery());

        return false;
    }

    override
    public void endVisit(PGSelectStatement x) {

    }

    override
    public bool visit(PGSelectStatement x) {
        return visit(cast(SQLSelectStatement) x);
    }

    override
    public void endVisit(PGUpdateStatement x) {

    }

    override public bool isPseudoColumn(long hash) {
        return PGUtils.isPseudoColumn(hash);
    }

    override
    public bool visit(PGUpdateStatement x) {
        if (repository !is null
                && x.getParent() is null) {
            repository.resolve(x);
        }

        if (x.getWith() !is null) {
            x.getWith().accept(this);
        }

        TableStat stat = getTableStat(x.getTableName());
        stat.incrementUpdateCount();

        accept(x.getFrom());

        accept(cast(List!SQLObject)(x.getItems()));
        accept(x.getWhere());

        return false;
    }

    override
    public void endVisit(PGSelectQueryBlock x) {
        super.endVisit(cast(SQLSelectQueryBlock) x);
    }

    override
    public bool visit(PGSelectQueryBlock x) {
        return this.visit(cast(SQLSelectQueryBlock) x);
    }

    override
    public void endVisit(PGFunctionTableSource x) {

    }

    override
    public bool visit(PGFunctionTableSource x) {
        return true;
    }
    
    override
    public bool visit(PGTypeCastExpr x) {
        x.getExpr().accept(this);
        return false;
    }
    
    override
    public void endVisit(PGTypeCastExpr x) {
        
    }

    override
    public void endVisit(PGValuesQuery x) {
        
    }

    override
    public bool visit(PGValuesQuery x) {
        return true;
    }
    
    override
    public void endVisit(PGExtractExpr x) {
        
    }
    
    override
    public bool visit(PGExtractExpr x) {
        return true;
    }
    
    override
    public void endVisit(PGBoxExpr x) {
        
    }
    
    override
    public bool visit(PGBoxExpr x) {
        return true;
    }
    
    override
    public void endVisit(PGPointExpr x) {
        
    }
    
    override
    public bool visit(PGMacAddrExpr x) {
        return true;
    }
    
    override
    public void endVisit(PGMacAddrExpr x) {
        
    }
    
    override
    public bool visit(PGInetExpr x) {
        return true;
    }
    
    override
    public void endVisit(PGInetExpr x) {
        
    }
    
    override
    public bool visit(PGCidrExpr x) {
        return true;
    }
    
    override
    public void endVisit(PGCidrExpr x) {
        
    }
    
    override
    public bool visit(PGPolygonExpr x) {
        return true;
    }
    
    override
    public void endVisit(PGPolygonExpr x) {
        
    }
    
    override
    public bool visit(PGCircleExpr x) {
        return true;
    }
    
    override
    public void endVisit(PGCircleExpr x) {
        
    }
    
    override
    public bool visit(PGLineSegmentsExpr x) {
        return true;
    }

    override
    public void endVisit(PGLineSegmentsExpr x) {
        
    }
    
    override
    public bool visit(PGPointExpr x) {
        return true;
    }
    
    override
    public void endVisit(PGShowStatement x) {
        
    }
    
    override
    public bool visit(PGShowStatement x) {
        return false;
    }

    override
    public void endVisit(PGStartTransactionStatement x) {
        
    }

    override
    public bool visit(PGStartTransactionStatement x) {
        return false;
    }

    override
    public void endVisit(PGConnectToStatement x) {

    }

    override
    public bool visit(PGConnectToStatement x) {
        return false;
    }

}
