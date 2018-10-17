module hunt.sql.util.FnvHash;

import hunt.string;

public  class FnvHash {
    public  enum  long BASIC = 0xcbf29ce484222325L;
    public  enum  long PRIME = 0x100000001b3L;

    public static  long fnv1a_64(string input) {
        if (input is null) {
            return 0;
        }

         long hash = BASIC;
        for (int i = 0; i < input.length; ++i) {
            char c = charAt(input, i);
            hash ^= c;
            hash *= PRIME;
        }

        return hash;
    }

    public static  long fnv1a_64(string input, int offset, int end) {
        if (input is null) {
            return 0;
        }

        if (input.length < end) {
            end = cast(int)input.length;
        }

         long hash = BASIC;
        for (int i = offset; i < end; ++i) {
            char c = charAt(input, i);
            hash ^= c;
            hash *= PRIME;
        }

        return hash;
    }

    public static  long fnv1a_64(byte[] input, int offset, int end) {
        if (input is null) {
            return 0;
        }

        if (input.length < end) {
            end = cast(int)input.length;
        }

         long hash = BASIC;
        for (int i = offset; i < end; ++i) {
            byte c = input[i];
            hash ^= c;
            hash *= PRIME;
        }

        return hash;
    }

    public static  long fnv1a_64(char[] chars) {
        if (chars is null) {
            return 0;
        }
         long hash = BASIC;
        for (int i = 0; i < chars.length; ++i) {
            char c = chars[i];
            hash ^= c;
            hash *= PRIME;
        }

        return hash;
    }

    /**
     * lower and normalized and fnv_1a_64
     * @param name
     * @return
     */
    public static  long hashCode64(string name) @trusted nothrow{
        if (name is null) {
            return 0;
        }

        bool quote = false;

        int len = cast(int)name.length;
        if (len > 2) {
            char c0 = charAt(name, 0);
            char c1 = charAt(name, len - 1);
            if ((c0 == '`' && c1 == '`')
                    || (c0 == '"' && c1 == '"')
                    || (c0 == '\'' && c1 == '\'')
                    || (c0 == '[' && c1 == ']')) {
                quote = true;
            }
        }
        if (quote) {
            return FnvHash.hashCode64(name, 1, len - 1);
        } else {
            return FnvHash.hashCode64(name, 0, len);
        }
    }

    public static  long fnv1a_64_lower(string key) {
         long hashCode = BASIC;
        for (int i = 0; i < key.length; ++i) {
            char ch = charAt(key, i);

            if (ch >= 'A' && ch <= 'Z') {
                ch = cast(char) (ch + 32);
            }

            hashCode ^= ch;
            hashCode *= PRIME;
        }

        return hashCode;
    }

    public static  long fnv1a_64_lower(StringBuilder key) {
         long hashCode = BASIC;
        for (int i = 0; i < key.length; ++i) {
            char ch = key._buffer.data[i];

            if (ch >= 'A' && ch <= 'Z') {
                ch = cast(char) (ch + 32);
            }

            hashCode ^= ch;
            hashCode *= PRIME;
        }

        return hashCode;
    }

    public static  long fnv1a_64_lower( long basic, StringBuilder key) {
         long hashCode = basic;
        for (int i = 0; i < key.length; ++i) {
            char ch = key._buffer.data[i];

            if (ch >= 'A' && ch <= 'Z') {
                ch = cast(char) (ch + 32);
            }

            hashCode ^= ch;
            hashCode *= PRIME;
        }

        return hashCode;
    }

    public static  long hashCode64(string key, int offset, int end) @trusted nothrow {
        long hashCode = BASIC;
        for (int i = offset; i < end; ++i) {
            char ch = charAt(key, i);

            if (ch >= 'A' && ch <= 'Z') {
                ch = cast(char) (ch + 32);
            }

            hashCode ^= ch;
            hashCode *= PRIME;
        }

        return hashCode;
    }

    public static long hashCode64(long basic, string name)@trusted nothrow {
        if (name is null) {
            return basic;
        }

        bool quote = false;

        int len = cast(int)name.length;
        if (len > 2) {
            char c0 = charAt(name, 0);
            char c1 = charAt(name, len - 1);
            if ((c0 == '`' && c1 == '`')
                    || (c0 == '"' && c1 == '"')
                    || (c0 == '\'' && c1 == '\'')
                    || (c0 == '[' && c1 == ']')) {
                quote = true;
            }
        }
        if (quote) {
            return FnvHash.hashCode64(basic, name, 1, len - 1);
        } else {
            return FnvHash.hashCode64(basic, name, 0, len);
        }
    }

    public static long hashCode64(long basic, string key, int offset, int end)@trusted nothrow {
        long hashCode = basic;
        for (int i = offset; i < end; ++i) {
            char ch = charAt(key, i);

            if (ch >= 'A' && ch <= 'Z') {
                ch = cast(char) (ch + 32);
            }

            hashCode ^= ch;
            hashCode *= PRIME;
        }

        return hashCode;
    }

    public static long fnv_32_lower(string key) {
        long hashCode = 0x811c9dc5;
        for (int i = 0; i < key.length; ++i) {
            char ch = charAt(key, i);
            if (ch == '_' || ch == '-') {
                continue;
            }

            if (ch >= 'A' && ch <= 'Z') {
                ch = cast(char) (ch + 32);
            }

            hashCode ^= ch;
            hashCode *= 0x01000193;
        }

        return hashCode;
    }

    public static long[] fnv1a_64_lower(string[] strings, bool sorted) {
        long[] hashCodes = new long[strings.length];
        for (int i = 0; i < strings.length; i++) {
            hashCodes[i] = fnv1a_64_lower(strings[i]);
        }
        if (sorted) {
            import std.algorithm.sorting;
            sort!("a < b")(hashCodes);
        }
        return hashCodes;
    }

    /**
     * normalized and lower and fnv1a_64_hash
     * @param owner
     * @param name
     * @return
     */
    public static  long hashCode64(string owner, string name)@trusted nothrow {
         long hashCode = BASIC;

        if (owner !is null) {
            string item = owner;

            bool quote = false;

            int len = cast(int)item.length;
            if (len > 2) {
                char c0 = charAt(item, 0);
                char c1 = charAt(item, len - 1);
                if ((c0 == '`' && c1 == '`')
                        || (c0 == '"' && c1 == '"')
                        || (c0 == '\'' && c1 == '\'')
                        || (c0 == '[' && c1 == ']')) {
                    quote = true;
                }
            }

            int start = quote ? 1 : 0;
            int end   = quote ? len - 1 : len;
            for (int j = start; j < end; ++j) {
                char ch = charAt(item, j);

                if (ch >= 'A' && ch <= 'Z') {
                    ch = cast(char) (ch + 32);
                }

                hashCode ^= ch;
                hashCode *= PRIME;
            }

            hashCode ^= '.';
            hashCode *= PRIME;
        }


        if (name !is null) {
            string item = name;

            bool quote = false;

            int len = cast(int)item.length;
            if (len > 2) {
                char c0 = charAt(item, 0);
                char c1 = charAt(item, len - 1);
                if ((c0 == '`' && c1 == '`')
                        || (c0 == '"' && c1 == '"')
                        || (c0 == '\'' && c1 == '\'')
                        || (c0 == '[' && c1 == ']')) {
                    quote = true;
                }
            }

            int start = quote ? 1 : 0;
            int end   = quote ? len - 1 : len;
            for (int j = start; j < end; ++j) {
                char ch = charAt(item, j);

                if (ch >= 'A' && ch <= 'Z') {
                    ch = cast(char) (ch + 32);
                }

                hashCode ^= ch;
                hashCode *= PRIME;
            }
        }

        return hashCode;
    }

    public static interface Constants {
        enum long HIGH_PRIORITY = fnv1a_64_lower("HIGH_PRIORITY");
        enum long DISTINCTROW = fnv1a_64_lower("DISTINCTROW");
        enum long STRAIGHT_JOIN = fnv1a_64_lower("STRAIGHT_JOIN");
        enum long SQL_SMALL_RESULT = fnv1a_64_lower("SQL_SMALL_RESULT");
        enum long SQL_BIG_RESULT = fnv1a_64_lower("SQL_BIG_RESULT");
        enum long SQL_BUFFER_RESULT = fnv1a_64_lower("SQL_BUFFER_RESULT");
        enum long CACHE = fnv1a_64_lower("CACHE");
        enum long SQL_CACHE = fnv1a_64_lower("SQL_CACHE");
        enum long SQL_NO_CACHE = fnv1a_64_lower("SQL_NO_CACHE");
        enum long SQL_CALC_FOUND_ROWS = fnv1a_64_lower("SQL_CALC_FOUND_ROWS");
        enum long OUTFILE = fnv1a_64_lower("OUTFILE");
        enum long SETS = fnv1a_64_lower("SETS");
        enum long REGEXP = fnv1a_64_lower("REGEXP");
        enum long RLIKE = fnv1a_64_lower("RLIKE");
        enum long USING = fnv1a_64_lower("USING");
        enum long IGNORE = fnv1a_64_lower("IGNORE");
        enum long FORCE = fnv1a_64_lower("FORCE");
        enum long CROSS = fnv1a_64_lower("CROSS");
        enum long NATURAL = fnv1a_64_lower("NATURAL");
        enum long APPLY = fnv1a_64_lower("APPLY");
        enum long CONNECT = fnv1a_64_lower("CONNECT");
        enum long START = fnv1a_64_lower("START");
        enum long BTREE = fnv1a_64_lower("BTREE");
        enum long HASH = fnv1a_64_lower("HASH");
        enum long NO_WAIT = fnv1a_64_lower("NO_WAIT");
        enum long WAIT = fnv1a_64_lower("WAIT");
        enum long NOWAIT = fnv1a_64_lower("NOWAIT");
        enum long ERRORS = fnv1a_64_lower("ERRORS");
        enum long VALUE = fnv1a_64_lower("VALUE");
        enum long NEXT = fnv1a_64_lower("NEXT");
        enum long NEXTVAL = fnv1a_64_lower("NEXTVAL");
        enum long CURRVAL = fnv1a_64_lower("CURRVAL");
        enum long PREVVAL = fnv1a_64_lower("PREVVAL");
        enum long PREVIOUS = fnv1a_64_lower("PREVIOUS");
        enum long LOW_PRIORITY = fnv1a_64_lower("LOW_PRIORITY");
        enum long COMMIT_ON_SUCCESS = fnv1a_64_lower("COMMIT_ON_SUCCESS");
        enum long ROLLBACK_ON_FAIL = fnv1a_64_lower("ROLLBACK_ON_FAIL");
        enum long QUEUE_ON_PK = fnv1a_64_lower("QUEUE_ON_PK");
        enum long TARGET_AFFECT_ROW = fnv1a_64_lower("TARGET_AFFECT_ROW");
        enum long COLLATE = fnv1a_64_lower("COLLATE");
        enum long BOOLEAN = fnv1a_64_lower("bool");
        enum long SMALLINT = fnv1a_64_lower("SMALLINT");
        enum long CHARSET = fnv1a_64_lower("CHARSET");
        enum long SEMI = fnv1a_64_lower("SEMI");
        enum long ANTI = fnv1a_64_lower("ANTI");
        enum long PRIOR = fnv1a_64_lower("PRIOR");
        enum long NOCYCLE = fnv1a_64_lower("NOCYCLE");
        enum long CONNECT_BY_ROOT = fnv1a_64_lower("CONNECT_BY_ROOT");

        enum long DATE = fnv1a_64_lower("DATE");
        enum long DATETIME = fnv1a_64_lower("DATETIME");
        enum long TIME = fnv1a_64_lower("TIME");
        enum long TIMESTAMP = fnv1a_64_lower("TIMESTAMP");
        enum long CLOB = fnv1a_64_lower("CLOB");
        enum long NCLOB = fnv1a_64_lower("NCLOB");
        enum long BLOB = fnv1a_64_lower("BLOB");
        enum long XMLTYPE = fnv1a_64_lower("XMLTYPE");
        enum long BFILE = fnv1a_64_lower("BFILE");
        enum long UROWID = fnv1a_64_lower("UROWID");
        enum long ROWID = fnv1a_64_lower("ROWID");
        enum long INTEGER = fnv1a_64_lower("INTEGER");
        enum long INT = fnv1a_64_lower("INT");
        enum long BINARY_FLOAT = fnv1a_64_lower("BINARY_FLOAT");
        enum long BINARY_DOUBLE = fnv1a_64_lower("BINARY_DOUBLE");
        enum long FLOAT = fnv1a_64_lower("FLOAT");
        enum long REAL = fnv1a_64_lower("REAL");
        enum long NUMBER = fnv1a_64_lower("NUMBER");
        enum long DEC = fnv1a_64_lower("DEC");
        enum long DECIMAL = fnv1a_64_lower("DECIMAL");

        enum long CURRENT = fnv1a_64_lower("CURRENT");
        enum long COUNT = fnv1a_64_lower("COUNT");
        enum long ROW_NUMBER = fnv1a_64_lower("ROW_NUMBER");
        enum long WM_CONCAT = fnv1a_64_lower("WM_CONCAT");
        enum long AVG = fnv1a_64_lower("AVG");
        enum long MAX = fnv1a_64_lower("MAX");
        enum long MIN = fnv1a_64_lower("MIN");
        enum long STDDEV = fnv1a_64_lower("STDDEV");
        enum long SUM = fnv1a_64_lower("SUM");
        enum long GROUP_CONCAT = fnv1a_64_lower("GROUP_CONCAT");
        enum long DEDUPLICATION = fnv1a_64_lower("DEDUPLICATION");
        enum long CONVERT = fnv1a_64_lower("CONVERT");
        enum long CHAR = fnv1a_64_lower("CHAR");
        enum long VARCHAR = fnv1a_64_lower("VARCHAR");
        enum long VARCHAR2 = fnv1a_64_lower("VARCHAR2");
        enum long NCHAR = fnv1a_64_lower("NCHAR");
        enum long NVARCHAR = fnv1a_64_lower("NVARCHAR");
        enum long NVARCHAR2 = fnv1a_64_lower("NVARCHAR2");
        enum long NCHAR_VARYING = fnv1a_64_lower("nchar varying");
        enum long TINYTEXT = fnv1a_64_lower("TINYTEXT");
        enum long TEXT = fnv1a_64_lower("TEXT");
        enum long MEDIUMTEXT = fnv1a_64_lower("MEDIUMTEXT");
        enum long LONGTEXT = fnv1a_64_lower("LONGTEXT");
        enum long TRIM = fnv1a_64_lower("TRIM");
        enum long LEADING = fnv1a_64_lower("LEADING");
        enum long BOTH = fnv1a_64_lower("BOTH");
        enum long TRAILING = fnv1a_64_lower("TRAILING");
        enum long MOD = fnv1a_64_lower("MOD");
        enum long MATCH = fnv1a_64_lower("MATCH");
        enum long EXTRACT = fnv1a_64_lower("EXTRACT");
        enum long POSITION = fnv1a_64_lower("POSITION");
        enum long DUAL = fnv1a_64_lower("DUAL");
        enum long LEVEL = fnv1a_64_lower("LEVEL");
        enum long CONNECT_BY_ISCYCLE = fnv1a_64_lower("CONNECT_BY_ISCYCLE");
        enum long CURRENT_TIMESTAMP = fnv1a_64_lower("CURRENT_TIMESTAMP");
        enum long CURRENT_USER = fnv1a_64_lower("CURRENT_USER");
        enum long FALSE = fnv1a_64_lower("FALSE");
        enum long TRUE = fnv1a_64_lower("TRUE");
        enum long SET = fnv1a_64_lower("SET");
        enum long LESS = fnv1a_64_lower("LESS");
        enum long MAXVALUE = fnv1a_64_lower("MAXVALUE");
        enum long OFFSET = fnv1a_64_lower("OFFSET");
        enum long RAW = fnv1a_64_lower("RAW");
        enum long LONG_RAW = fnv1a_64_lower("LONG RAW");
        enum long LONG = fnv1a_64_lower("LONG");
        enum long ROWNUM = fnv1a_64_lower("ROWNUM");
        enum long SYSDATE = fnv1a_64_lower("SYSDATE");
        enum long SQLCODE = fnv1a_64_lower("SQLCODE");
        enum long PRECISION = fnv1a_64_lower("PRECISION");
        enum long DOUBLE = fnv1a_64_lower("DOUBLE");
        enum long DOUBLE_PRECISION = fnv1a_64_lower("DOUBLE PRECISION");
        enum long WITHOUT = fnv1a_64_lower("WITHOUT");

        enum long DEFINER = fnv1a_64_lower("DEFINER");
        enum long EVENT = fnv1a_64_lower("EVENT");
        enum long DETERMINISTIC = fnv1a_64_lower("DETERMINISTIC");
        enum long CONTAINS = fnv1a_64_lower("CONTAINS");
        enum long SQL = fnv1a_64_lower("SQL");
        enum long CALL = fnv1a_64_lower("CALL");
        enum long CHARACTER = fnv1a_64_lower("CHARACTER");

        enum long VALIDATE = fnv1a_64_lower("VALIDATE");
        enum long NOVALIDATE = fnv1a_64_lower("NOVALIDATE");
        enum long SIMILAR = fnv1a_64_lower("SIMILAR");
        enum long CASCADE = fnv1a_64_lower("CASCADE");
        enum long RELY = fnv1a_64_lower("RELY");
        enum long NORELY = fnv1a_64_lower("NORELY");
        enum long ROW = fnv1a_64_lower("ROW");
        enum long ROWS = fnv1a_64_lower("ROWS");
        enum long RANGE = fnv1a_64_lower("RANGE");
        enum long PRECEDING = fnv1a_64_lower("PRECEDING");
        enum long FOLLOWING = fnv1a_64_lower("FOLLOWING");
        enum long UNBOUNDED = fnv1a_64_lower("UNBOUNDED");
        enum long SIBLINGS = fnv1a_64_lower("SIBLINGS");
        enum long RESPECT = fnv1a_64_lower("RESPECT");
        enum long NULLS = fnv1a_64_lower("NULLS");
        enum long FIRST = fnv1a_64_lower("FIRST");
        enum long LAST = fnv1a_64_lower("LAST");
        enum long AUTO_INCREMENT = fnv1a_64_lower("AUTO_INCREMENT");
        enum long STORAGE = fnv1a_64_lower("STORAGE");
        enum long STORED = fnv1a_64_lower("STORED");
        enum long VIRTUAL = fnv1a_64_lower("VIRTUAL");
        enum long UNSIGNED = fnv1a_64_lower("UNSIGNED");
        enum long ZEROFILL = fnv1a_64_lower("ZEROFILL");
        enum long GLOBAL = fnv1a_64_lower("GLOBAL");
        enum long SESSION = fnv1a_64_lower("SESSION");
        enum long NAMES = fnv1a_64_lower("NAMES");
        enum long PARTIAL = fnv1a_64_lower("PARTIAL");
        enum long SIMPLE = fnv1a_64_lower("SIMPLE");
        enum long RESTRICT = fnv1a_64_lower("RESTRICT");
        enum long ON = fnv1a_64_lower("ON");
        enum long ACTION = fnv1a_64_lower("ACTION");
        enum long SEPARATOR = fnv1a_64_lower("SEPARATOR");
        enum long DATA = fnv1a_64_lower("DATA");
        enum long MAX_ROWS = fnv1a_64_lower("MAX_ROWS");
        enum long MIN_ROWS = fnv1a_64_lower("MIN_ROWS");
        enum long ENGINE = fnv1a_64_lower("ENGINE");
        enum long SKIP = fnv1a_64_lower("SKIP");
        enum long RECURSIVE = fnv1a_64_lower("RECURSIVE");
        enum long ROLLUP = fnv1a_64_lower("ROLLUP");
        enum long CUBE = fnv1a_64_lower("CUBE");

        enum long YEAR = fnv1a_64_lower("YEAR");
        enum long MONTH = fnv1a_64_lower("MONTH");
        enum long DAY = fnv1a_64_lower("DAY");
        enum long HOUR = fnv1a_64_lower("HOUR");
        enum long MINUTE = fnv1a_64_lower("MINUTE");
        enum long SECOND = fnv1a_64_lower("SECOND");

        enum long SECONDS = fnv1a_64_lower("SECONDS");
        enum long MINUTES = fnv1a_64_lower("MINUTES");
        enum long HOURS = fnv1a_64_lower("HOURS");
        enum long DAYS = fnv1a_64_lower("DAYS");
        enum long MONTHS = fnv1a_64_lower("MONTHS");
        enum long YEARS = fnv1a_64_lower("YEARS");

        enum long BEFORE = fnv1a_64_lower("BEFORE");
        enum long AFTER = fnv1a_64_lower("AFTER");
        enum long INSTEAD = fnv1a_64_lower("INSTEAD");

        enum long DEFERRABLE = fnv1a_64_lower("DEFERRABLE");
        enum long AS = fnv1a_64_lower("AS");
        enum long DELAYED = fnv1a_64_lower("DELAYED");
        enum long GO = fnv1a_64_lower("GO");
        enum long WAITFOR = fnv1a_64_lower("WAITFOR");
        enum long EXEC = fnv1a_64_lower("EXEC");
        enum long EXECUTE = fnv1a_64_lower("EXECUTE");

        enum long SOURCE = fnv1a_64_lower("SOURCE");

        enum long STAR = fnv1a_64_lower("*");

        enum long TO_CHAR = fnv1a_64_lower("TO_CHAR");
        enum long SYS_GUID = fnv1a_64_lower("SYS_GUID");

        enum long STATISTICS = fnv1a_64_lower("STATISTICS");
        enum long TRANSACTION = fnv1a_64_lower("TRANSACTION");
        enum long OFF = fnv1a_64_lower("OFF");
        enum long IDENTITY_INSERT = fnv1a_64_lower("IDENTITY_INSERT");
        enum long PASSWORD = fnv1a_64_lower("PASSWORD");
        enum long SOCKET = fnv1a_64_lower("SOCKET");
        enum long OWNER = fnv1a_64_lower("OWNER");
        enum long PORT = fnv1a_64_lower("PORT");
        enum long PUBLIC = fnv1a_64_lower("PUBLIC");
        enum long SYNONYM = fnv1a_64_lower("SYNONYM");
        enum long MATERIALIZED = fnv1a_64_lower("MATERIALIZED");
        enum long BITMAP = fnv1a_64_lower("BITMAP");
        enum long PACKAGE = fnv1a_64_lower("PACKAGE");
        enum long TRUNC = fnv1a_64_lower("TRUNC");
        enum long SYSTIMESTAMP = fnv1a_64_lower("SYSTIMESTAMP");
        enum long TYPE = fnv1a_64_lower("TYPE");
        enum long RECORD = fnv1a_64_lower("RECORD");
        enum long MAP = fnv1a_64_lower("MAP");
        enum long ONLY = fnv1a_64_lower("ONLY");
        enum long MEMBER = fnv1a_64_lower("MEMBER");
        enum long STATIC = fnv1a_64_lower("STATIC");
        enum long FINAL = fnv1a_64_lower("FINAL");
        enum long INSTANTIABLE = fnv1a_64_lower("INSTANTIABLE");
        enum long UNSUPPORTED = fnv1a_64_lower("UNSUPPORTED");
        enum long VARRAY = fnv1a_64_lower("VARRAY");
        enum long WRAPPED = fnv1a_64_lower("WRAPPED");
        enum long AUTHID = fnv1a_64_lower("AUTHID");
        enum long UNDER = fnv1a_64_lower("UNDER");
        enum long USERENV = fnv1a_64_lower("USERENV");
        enum long NUMTODSINTERVAL = fnv1a_64_lower("NUMTODSINTERVAL");

        enum long LATERAL = fnv1a_64_lower("LATERAL");
        enum long NONE = fnv1a_64_lower("NONE");
        enum long PARTITIONING = fnv1a_64_lower("PARTITIONING");
        enum long VALIDPROC = fnv1a_64_lower("VALIDPROC");
        enum long COMPRESS = fnv1a_64_lower("COMPRESS");
        enum long YES = fnv1a_64_lower("YES");
        enum long WMSYS = fnv1a_64_lower("WMSYS");

        enum long DEPTH = fnv1a_64_lower("DEPTH");
        enum long BREADTH = fnv1a_64_lower("BREADTH");

        enum long SCHEDULE = fnv1a_64_lower("SCHEDULE");
        enum long COMPLETION = fnv1a_64_lower("COMPLETION");
        enum long RENAME = fnv1a_64_lower("RENAME");
        enum long DUMP = fnv1a_64_lower("DUMP");
        enum long AT = fnv1a_64_lower("AT");
        enum long LANGUAGE = fnv1a_64_lower("LANGUAGE");
        enum long LOGFILE = fnv1a_64_lower("LOGFILE");
        enum long INITIAL_SIZE = fnv1a_64_lower("INITIAL_SIZE");
        enum long MAX_SIZE = fnv1a_64_lower("MAX_SIZE");
        enum long NODEGROUP = fnv1a_64_lower("NODEGROUP");
        enum long EXTENT_SIZE = fnv1a_64_lower("EXTENT_SIZE");
        enum long AUTOEXTEND_SIZE = fnv1a_64_lower("AUTOEXTEND_SIZE");
        enum long FILE_BLOCK_SIZE = fnv1a_64_lower("FILE_BLOCK_SIZE");
        enum long SERVER = fnv1a_64_lower("SERVER");
        enum long HOST = fnv1a_64_lower("HOST");
        enum long ADD = fnv1a_64_lower("ADD");
        enum long ALGORITHM = fnv1a_64_lower("ALGORITHM");
        enum long EVERY = fnv1a_64_lower("EVERY");
        enum long STARTS = fnv1a_64_lower("STARTS");
        enum long ENDS = fnv1a_64_lower("ENDS");
        enum long BINARY = fnv1a_64_lower("BINARY");
        enum long ISOPEN = fnv1a_64_lower("ISOPEN");
        enum long CONFLICT = fnv1a_64_lower("CONFLICT");
        enum long NOTHING = fnv1a_64_lower("NOTHING");
        enum long COMMIT = fnv1a_64_lower("COMMIT");

        enum long RS = fnv1a_64_lower("RS");
        enum long RR = fnv1a_64_lower("RR");
        enum long CS = fnv1a_64_lower("CS");
        enum long UR = fnv1a_64_lower("UR");

        enum long INT4 = fnv1a_64_lower("INT4");
        enum long VARBIT = fnv1a_64_lower("VARBIT");
        enum long CLUSTERED = fnv1a_64_lower("CLUSTERED");
        enum long SORTED = fnv1a_64_lower("SORTED");
        enum long LIFECYCLE = fnv1a_64_lower("LIFECYCLE");
        enum long PARTITIONS = fnv1a_64_lower("PARTITIONS");
        enum long ARRAY = fnv1a_64_lower("ARRAY");
        enum long STRUCT = fnv1a_64_lower("STRUCT");

        enum long ROLLBACK = fnv1a_64_lower("ROLLBACK");
        enum long SAVEPOINT = fnv1a_64_lower("SAVEPOINT");
        enum long RELEASE = fnv1a_64_lower("RELEASE");
        enum long MERGE = fnv1a_64_lower("MERGE");
        enum long INHERITS = fnv1a_64_lower("INHERITS");
        enum long DELIMITED = fnv1a_64_lower("DELIMITED");
        enum long TABLES = fnv1a_64_lower("TABLES");
        enum long PARALLEL = fnv1a_64_lower("PARALLEL");
        enum long BUILD = fnv1a_64_lower("BUILD");
        enum long NOCACHE = fnv1a_64_lower("NOCACHE");
        enum long NOPARALLEL = fnv1a_64_lower("NOPARALLEL");
        enum long EXIST = fnv1a_64_lower("EXIST");

        enum long TBLPROPERTIES = fnv1a_64_lower("TBLPROPERTIES");
        enum long FULLTEXT = fnv1a_64_lower("FULLTEXT");
        enum long SPATIAL = fnv1a_64_lower("SPATIAL");
        enum long NO = fnv1a_64_lower("NO");
        enum long PATH = fnv1a_64_lower("PATH");
        enum long COMPRESSION = fnv1a_64_lower("COMPRESSION");
        enum long KEY_BLOCK_SIZE = fnv1a_64_lower("KEY_BLOCK_SIZE");
        enum long CHECKSUM = fnv1a_64_lower("CHECKSUM");
        enum long ROUTINE = fnv1a_64_lower("ROUTINE");
        enum long DATE_FORMAT = fnv1a_64_lower("DATE_FORMAT");
        enum long DBPARTITION = fnv1a_64_lower("DBPARTITION");
        enum long TBPARTITION = fnv1a_64_lower("TBPARTITION");
        enum long TBPARTITIONS = fnv1a_64_lower("TBPARTITIONS");
        enum long SOUNDS = fnv1a_64_lower("SOUNDS");
        enum long WINDOW = fnv1a_64_lower("WINDOW");
        enum long GENERATED = fnv1a_64_lower("GENERATED");
        enum long ALWAYS = fnv1a_64_lower("ALWAYS");
        enum long INCREMENT = fnv1a_64_lower("INCREMENT");

        enum long OVERWRITE = fnv1a_64_lower("OVERWRITE");
        enum long FILTER = fnv1a_64_lower("FILTER");
    }
}
