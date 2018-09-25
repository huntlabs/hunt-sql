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
module hunt.sql.ast.statement.SQLCreateMaterializedViewStatement;

import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLObject;
import hunt.sql.ast.SQLPartitionBy;
import hunt.sql.ast.SQLStatementImpl;
// import hunt.sql.dialect.oracle.ast.OracleSegmentAttributes;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLSelect;
import hunt.sql.ast.statement.SQLCreateStatement;

import hunt.container;
import hunt.math;
/**
 * Created by wenshao on 30/06/2017.
 */
public class SQLCreateMaterializedViewStatement : SQLStatementImpl ,/* OracleSegmentAttributes, */SQLCreateStatement {
    private SQLName name;
    private List!SQLName columns;

    private bool refreshFast;
    private bool refreshComlete;
    private bool refreshForce;
    private bool refreshOnCommit;
    private bool refreshOnDemand;

    private bool buildImmediate;
    private bool buildDeferred;

    private SQLSelect query;

    // oracle
    private Integer pctfree;
    private Integer pctused;
    private Integer initrans;

    private Integer maxtrans;
    private Integer pctincrease;
    private Integer freeLists;
    private bool compress;
    private Integer compressLevel;
    private bool compressForOltp;
    private Integer pctthreshold;

    private bool logging;
    private Boolean cache;

    protected SQLName tablespace;
    protected SQLObject storage;

    private bool parallel;
    private Integer parallelValue;

    private Boolean enableQueryRewrite;

    private SQLPartitionBy partitionBy;

    private bool withRowId;

    this()
    {
        columns = new ArrayList!SQLName();
    }

    public SQLName getName() {
        return name;
    }

    public void setName(SQLName name) {
        if (name !is null) {
            name.setParent(this);
        }
        this.name = name;
    }

    public List!SQLName getColumns() {
        return columns;
    }

    public SQLSelect getQuery() {
        return query;
    }

    public void setQuery(SQLSelect query) {
        if (query !is null) {
            query.setParent(this);
        }
        this.query = query;
    }

    public bool isBuildImmediate() {
        return buildImmediate;
    }

    public void setBuildImmediate(bool buildImmediate) {
        this.buildImmediate = buildImmediate;
    }

    public bool isBuildDeferred() {
        return buildDeferred;
    }

    public void setBuildDeferred(bool buildDeferred) {
        this.buildDeferred = buildDeferred;
    }

    public bool isRefresh() {
        return this.refreshFast || refreshComlete || refreshForce || refreshOnDemand || refreshOnCommit;
    }

    public bool isRefreshFast() {
        return refreshFast;
    }

    public void setRefreshFast(bool refreshFast) {
        this.refreshFast = refreshFast;
    }

    public bool isRefreshComlete() {
        return refreshComlete;
    }

    public void setRefreshComlete(bool refreshComlete) {
        this.refreshComlete = refreshComlete;
    }

    public bool isRefreshForce() {
        return refreshForce;
    }

    public void setRefreshForce(bool refreshForce) {
        this.refreshForce = refreshForce;
    }

    public bool isRefreshOnCommit() {
        return refreshOnCommit;
    }

    public void setRefreshOnCommit(bool refreshOnCommit) {
        this.refreshOnCommit = refreshOnCommit;
    }

    public bool isRefreshOnDemand() {
        return refreshOnDemand;
    }

    public void setRefreshOnDemand(bool refreshOnDemand) {
        this.refreshOnDemand = refreshOnDemand;
    }

    public Integer getPctfree() {
        return pctfree;
    }

    public void setPctfree(Integer pctfree) {
        this.pctfree = pctfree;
    }

    public Integer getPctused() {
        return pctused;
    }

    public void setPctused(Integer pctused) {
        this.pctused = pctused;
    }

    public Integer getInitrans() {
        return initrans;
    }

    public void setInitrans(Integer initrans) {
        this.initrans = initrans;
    }

    public Integer getMaxtrans() {
        return maxtrans;
    }

    public void setMaxtrans(Integer maxtrans) {
        this.maxtrans = maxtrans;
    }

    public Integer getPctincrease() {
        return pctincrease;
    }

    public void setPctincrease(Integer pctincrease) {
        this.pctincrease = pctincrease;
    }

    public Integer getFreeLists() {
        return freeLists;
    }

    public void setFreeLists(Integer freeLists) {
        this.freeLists = freeLists;
    }

    public bool getCompress() {
        return compress;
    }

    public void setCompress(bool compress) {
        this.compress = compress;
    }

    public Integer getCompressLevel() {
        return compressLevel;
    }

    public void setCompressLevel(Integer compressLevel) {
        this.compressLevel = compressLevel;
    }

    public bool isCompressForOltp() {
        return compressForOltp;
    }

    public void setCompressForOltp(bool compressForOltp) {
        this.compressForOltp = compressForOltp;
    }

    public Integer getPctthreshold() {
        return pctthreshold;
    }

    public void setPctthreshold(Integer pctthreshold) {
        this.pctthreshold = pctthreshold;
    }

    public bool getLogging() {
        return logging;
    }

    public void setLogging(bool logging) {
        this.logging = logging;
    }

    public SQLName getTablespace() {
        return tablespace;
    }

    public void setTablespace(SQLName tablespace) {
        if (tablespace !is null) {
            tablespace.setParent(this);
        }
        this.tablespace = tablespace;
    }

    public SQLObject getStorage() {
        return storage;
    }

    public void setStorage(SQLObject storage) {
        if (storage !is null) {
            storage.setParent(this);
        }
        this.storage = storage;
    }

    public Boolean getParallel() {
        return new Boolean(parallel);
    }

    public void setParallel(bool parallel) {
        this.parallel = parallel;
    }

    public Integer getParallelValue() {
        return parallelValue;
    }

    public void setParallelValue(Integer parallelValue) {
        this.parallelValue = parallelValue;
    }

    public Boolean getEnableQueryRewrite() {
        return enableQueryRewrite;
    }

    public void setEnableQueryRewrite(bool enableQueryRewrite) {
        this.enableQueryRewrite = new Boolean(enableQueryRewrite);
    }

    public Boolean getCache() {
        return cache;
    }

    public void setCache(bool cache) {
        this.cache = new Boolean(cache);
    }

    public SQLPartitionBy getPartitionBy() {
        return partitionBy;
    }

    public void setPartitionBy(SQLPartitionBy x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.partitionBy = x;
    }

    public bool isWithRowId() {
        return withRowId;
    }

    public void setWithRowId(bool withRowId) {
        this.withRowId = withRowId;
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, name);
            acceptChild!SQLName(visitor, columns);
            acceptChild(visitor, partitionBy);
            acceptChild(visitor, query);
        }
        visitor.endVisit(this);
    }
}
