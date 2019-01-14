module hunt.sql.ast.SQLPartition;

import hunt.sql.ast.SQLDataType;
import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLSubPartition;
import hunt.sql.ast.SQLPartitionValue;
import hunt.sql.ast.SQLObject;
import hunt.sql.visitor.SQLASTVisitor;


import hunt.collection;
import hunt.Integer;

public interface OracleSegmentAttributes : SQLObject {

    SQLName getTablespace();
    void setTablespace(SQLName name);

    bool getCompress();

    void setCompress(bool compress);

    Integer getCompressLevel();

    void setCompressLevel(Integer compressLevel);

    Integer getInitrans();
    void setInitrans(Integer initrans);

    Integer getMaxtrans();
    void setMaxtrans(Integer maxtrans);

    Integer getPctincrease();
    void setPctincrease(Integer pctincrease);

    Integer getPctused();
    void setPctused(Integer pctused);

    Integer getPctfree();
    void setPctfree(Integer ptcfree);

    bool getLogging();
    void setLogging(bool logging);

    SQLObject getStorage();
    void setStorage(SQLObject storage);

    bool isCompressForOltp();

    void setCompressForOltp(bool compressForOltp);
}

public abstract class OracleSegmentAttributesImpl : SQLObjectImpl , OracleSegmentAttributes {
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

    protected SQLName tablespace;
    protected SQLObject storage;

    public SQLName getTablespace() {
        return tablespace;
    }

    public void setTablespace(SQLName tablespace) {
        if (tablespace !is null) {
            tablespace.setParent(this);
        }
        this.tablespace = tablespace;
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

    public Integer getPctthreshold() {
        return pctthreshold;
    }

    public void setPctthreshold(Integer pctthreshold) {
        this.pctthreshold = pctthreshold;
    }

    public Integer getPctfree() {
        return pctfree;
    }

    public void setPctfree(Integer ptcfree) {
        this.pctfree = ptcfree;
    }

    public Integer getPctused() {
        return pctused;
    }

    public void setPctused(Integer ptcused) {
        this.pctused = ptcused;
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

    public bool getLogging() {
        return logging;
    }

    public void setLogging(bool logging) {
        this.logging = logging;
    }

    public SQLObject getStorage() {
        return storage;
    }

    public void setStorage(SQLObject storage) {
        this.storage = storage;
    }

    public bool isCompressForOltp() {
        return compressForOltp;
    }

    public void setCompressForOltp(bool compressForOltp) {
        this.compressForOltp = compressForOltp;
    }

    public void cloneTo(OracleSegmentAttributesImpl x) {
        x.pctfree = pctfree;
        x.pctused = pctused;
        x.initrans = initrans;

        x.maxtrans = maxtrans;
        x.pctincrease = pctincrease;
        x.freeLists = freeLists;
        x.compress = compress;
        x.compressLevel = compressLevel;
        x.compressForOltp = compressForOltp;
        x.pctthreshold = pctthreshold;

        x.logging = logging;

        if (tablespace !is null) {
            x.setTablespace(tablespace.clone());
        }

        if (storage !is null) {
            x.setStorage(storage.clone());
        }
    }
}

public class SQLPartition : OracleSegmentAttributesImpl // @gxc
{

    protected SQLName               name;

    protected SQLExpr               subPartitionsCount;

    protected List!SQLSubPartition subPartitions;

    protected SQLPartitionValue     values;
    
    // for mysql
    protected SQLExpr           dataDirectory;
    protected SQLExpr           indexDirectory;
    protected SQLExpr           maxRows;
    protected SQLExpr           minRows;
    protected SQLExpr           engine;
    protected SQLExpr           comment;

    // for oracle
    protected bool segmentCreationImmediate;
    protected bool segmentCreationDeferred;

    private SQLObject lobStorage;

    this()
    {
        subPartitions = new ArrayList!SQLSubPartition();
    }

// override public SQLName getTablespace() {
//     return super.getTablespace();
// }

    public SQLName getName() {
        return name;
    }

    public void setName(SQLName name) {
        if (name !is null) {
            name.setParent(this);
        }
        this.name = name;
    }

    public SQLExpr getSubPartitionsCount() {
        return subPartitionsCount;
    }

    public void setSubPartitionsCount(SQLExpr subPartitionsCount) {
        if (subPartitionsCount !is null) {
            subPartitionsCount.setParent(this);
        }
        this.subPartitionsCount = subPartitionsCount;
    }

    public SQLPartitionValue getValues() {
        return values;
    }

    public void setValues(SQLPartitionValue values) {
        if (values !is null) {
            values.setParent(this);
        }
        this.values = values;
    }

    public List!SQLSubPartition getSubPartitions() {
        return subPartitions;
    }
    
    public void addSubPartition(SQLSubPartition partition) {
        if (partition !is null) {
            partition.setParent(this);
        }
        this.subPartitions.add(partition);
    }

    public SQLExpr getIndexDirectory() {
        return indexDirectory;
    }

    public void setIndexDirectory(SQLExpr indexDirectory) {
        if (indexDirectory !is null) {
            indexDirectory.setParent(this);
        }
        this.indexDirectory = indexDirectory;
    }

    public SQLExpr getDataDirectory() {
        return dataDirectory;
    }

    public void setDataDirectory(SQLExpr dataDirectory) {
        if (dataDirectory !is null) {
            dataDirectory.setParent(this);
        }
        this.dataDirectory = dataDirectory;
    }

    public SQLExpr getMaxRows() {
        return maxRows;
    }

    public void setMaxRows(SQLExpr maxRows) {
        if (maxRows !is null) {
            maxRows.setParent(this);
        }
        this.maxRows = maxRows;
    }

    public SQLExpr getMinRows() {
        return minRows;
    }

    public void setMinRows(SQLExpr minRows) {
        if (minRows !is null) {
            minRows.setParent(this);
        }
        this.minRows = minRows;
    }

    public SQLExpr getEngine() {
        return engine;
    }

    public void setEngine(SQLExpr engine) {
        if (engine !is null) {
            engine.setParent(this);
        }
        this.engine = engine;
    }

    public SQLExpr getComment() {
        return comment;
    }

    public void setComment(SQLExpr comment) {
        if (comment !is null) {
            comment.setParent(this);
        }
        this.comment = comment;
    }
    
    override   protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, name);
            acceptChild(visitor, values);
            acceptChild(visitor, dataDirectory);
            acceptChild(visitor, indexDirectory);
            acceptChild(visitor, tablespace);
            acceptChild(visitor, maxRows);
            acceptChild(visitor, minRows);
            acceptChild(visitor, engine);
            acceptChild(visitor, comment);

            acceptChild(visitor, storage);
        }
        visitor.endVisit(this);
    }

    public SQLObject getLobStorage() {
        return lobStorage;
    }

    public void setLobStorage(SQLObject lobStorage) {
        if (lobStorage !is null) {
            lobStorage.setParent(this);
        }
        this.lobStorage = lobStorage;
    }

    public bool isSegmentCreationImmediate() {
        return segmentCreationImmediate;
    }

    public void setSegmentCreationImmediate(bool segmentCreationImmediate) {
        this.segmentCreationImmediate = segmentCreationImmediate;
    }

    public bool isSegmentCreationDeferred() {
        return segmentCreationDeferred;
    }

    public void setSegmentCreationDeferred(bool segmentCreationDeferred) {
        this.segmentCreationDeferred = segmentCreationDeferred;
    }

    override public SQLPartition clone() {
        SQLPartition x = new SQLPartition();

        if (name !is null) {
            x.setName(name.clone());
        }

        if (subPartitionsCount !is null) {
            x.setSubPartitionsCount(subPartitionsCount.clone());
        }

        foreach (SQLSubPartition p ; subPartitions) {
            SQLSubPartition p2 = p.clone();
            p2.setParent(x);
            x.subPartitions.add(p2);
        }

        if (values !is null) {
            x.setValues(values.clone());
        }

        if (dataDirectory !is null) {
            x.setDataDirectory(dataDirectory.clone());
        }
        if (indexDirectory !is null) {
            x.setDataDirectory(indexDirectory.clone());
        }
        if (maxRows !is null) {
            x.setDataDirectory(maxRows.clone());
        }
        if (minRows !is null) {
            x.setDataDirectory(minRows.clone());
        }
        if (engine !is null) {
            x.setDataDirectory(engine.clone());
        }
        if (comment !is null) {
            x.setDataDirectory(comment.clone());
        }
        x.segmentCreationImmediate = segmentCreationImmediate;
        x.segmentCreationDeferred = segmentCreationDeferred;

        if (lobStorage !is null) {
            x.setLobStorage(lobStorage.clone());
        }

        return x;
    }
}
