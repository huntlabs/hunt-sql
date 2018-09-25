module hunt.sql.util.DBType;


struct DBType {

     enum DBType JTDS                       = DBType("jtds");

     enum DBType MOCK                       = DBType("mock");

     enum DBType HSQL                       = DBType("hsql");

     enum DBType DB2                        = DBType("db2");

     enum DBType DB2_DRIVER                 = DBType("com.ibm.db2.jcc.DB2Driver");

     enum DBType POSTGRESQL                 = DBType("postgresql");
     enum DBType POSTGRESQL_DRIVER          = DBType("org.postgresql.Driver");

     enum DBType SYBASE                     = DBType("sybase");

     enum DBType SQL_SERVER                 = DBType("sqlserver");
     enum DBType SQL_SERVER_DRIVER          = DBType("com.microsoft.jdbc.sqlserver.SQLServerDriver");
     enum DBType SQL_SERVER_DRIVER_SQLJDBC4 = DBType("com.microsoft.sqlserver.jdbc.SQLServerDriver");
     enum DBType SQL_SERVER_DRIVER_JTDS     = DBType("net.sourceforge.jtds.jdbc.Driver");

     enum DBType ORACLE                     = DBType("oracle");
     enum DBType ORACLE_DRIVER              = DBType("oracle.jdbc.OracleDriver");
     enum DBType ORACLE_DRIVER2             = DBType("oracle.jdbc.driver.OracleDriver");



     enum DBType MYSQL                      = DBType("mysql");
     enum DBType MYSQL_DRIVER               = DBType("com.mysql.jdbc.Driver");
     enum DBType MYSQL_DRIVER_6             = DBType("com.mysql.cj.jdbc.Driver");
     enum DBType MYSQL_DRIVER_REPLICATE     = DBType("com.mysql.jdbc.");

     enum DBType MARIADB                    = DBType("mariadb");
     enum DBType MARIADB_DRIVER             = DBType("org.mariadb.jdbc.Driver");

     enum DBType DERBY                      = DBType("derby");

     enum DBType HBASE                      = DBType("hbase");

     enum DBType HIVE                       = DBType("hive");
     enum DBType HIVE_DRIVER                = DBType("org.apache.hive.jdbc.HiveDriver");

     enum DBType H2                         = DBType("h2");
     enum DBType H2_DRIVER                  = DBType("org.h2.Driver");

     enum DBType DM                         = DBType("dm");
     enum DBType DM_DRIVER                  = DBType("dm.jdbc.driver.DmDriver");

     enum DBType KINGBASE                   = DBType("kingbase");
     enum DBType KINGBASE_DRIVER            = DBType("com.kingbase.Driver");

     enum DBType GBASE                      = DBType("gbase");
     enum DBType GBASE_DRIVER               = DBType("com.gbase.jdbc.Driver");

     enum DBType XUGU                       = DBType("xugu");
     enum DBType XUGU_DRIVER                = DBType("com.xugu.cloudjdbc.Driver");

     enum DBType OCEANBASE                  = DBType("oceanbase");
     enum DBType OCEANBASE_DRIVER           = DBType("com.mysql.jdbc.Driver");
     enum DBType INFORMIX                   = DBType("informix");
    
 
     enum DBType ODPS     = DBType("odps");


     enum DBType PHOENIX                    = DBType("phoenix");
     enum DBType PHOENIX_DRIVER             = DBType("org.apache.phoenix.jdbc.PhoenixDriver");
     enum DBType ENTERPRISEDB               = DBType("edb");
     enum DBType ENTERPRISEDB_DRIVER        = DBType("com.edb.Driver");

     enum DBType KYLIN                      = DBType("kylin");
     enum DBType KYLIN_DRIVER               = DBType("org.apache.kylin.jdbc.Driver");


     enum DBType SQLITE                     = DBType("sqlite");
     enum DBType SQLITE_DRIVER              = DBType("org.sqlite.JDBC");

     enum DBType ALIYUN_ADS                 = DBType("aliyun_ads");
     enum DBType ALIYUN_DRDS                = DBType("aliyun_drds");

     enum DBType PRESTO                     = DBType("presto");

     enum DBType ELASTIC_SEARCH             = DBType("elastic_search");
    

     enum DBType CLICKHOUSE                 = DBType("clickhouse");
     enum DBType CLICKHOUSE_DRIVER          = DBType("ru.yandex.clickhouse.ClickHouseDriver");

     private string _name;

     this(string name)
     {
         this._name = name;
     }

     string name()
     {
         return _name;
     }

     bool opEquals(const DBType h) nothrow {
        return _name == h._name ;
    } 

    bool opEquals(string name) nothrow {
        return _name == name ;
    }

    bool opEquals(ref const DBType h) nothrow {
        return _name == h._name ;
    } 
}
