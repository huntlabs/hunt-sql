
module hunt.sql.parser.SymbolTable;

import std.concurrency:initOnce;

/**
 */
public class SymbolTable {
    // private  enum UTF8 = "UTF-8";
    // private static  bool JVM_16;
    // static this()
    // {
    //     global = new SymbolTable(32768);
    // }

    static SymbolTable global() {
        __gshared SymbolTable inst;
        return initOnce!inst(new SymbolTable(32768));
    }

    private  Entry[] entries;
    private  int      indexMask;

    public this(int tableSize){
        this.indexMask = tableSize - 1;
        this.entries = new Entry[tableSize];
    }

    public string addSymbol(string buffer, int offset, int len, long hash) {
         int bucket = (cast(int) hash) & indexMask;

        Entry entry = entries[bucket];
        if (entry !is null) {
            if (hash == entry.hash) {
                return entry.value;
            }

            string str = buffer[offset .. offset + len];

            return str;
        }

        string str = buffer[offset .. offset + len];
        entry = new Entry(hash, len, str);
        entries[bucket] = entry;
        return str;
    }

    public string addSymbol(byte[] buffer, int offset, int len, long hash) {
         int bucket = (cast(int) hash) & indexMask;

        Entry entry = entries[bucket];
        if (entry !is null) {
            if (hash == entry.hash) {
                return entry.value;
            }

            string str = subString(buffer, offset, len);

            return str;
        }

        string str = subString(buffer, offset, len);
        entry = new Entry(hash, len, str);
        entries[bucket] = entry;
        return str;
    }

    public string addSymbol(string symbol, long hash) {
         int bucket = (cast(int) hash) & indexMask;

        Entry entry = entries[bucket];
        if (entry !is null) {
            if (hash == entry.hash) {
                return entry.value;
            }

            return symbol;
        }

        entry = new Entry(hash, cast(int)symbol.length, symbol);
        entries[bucket] = entry;
        return symbol;
    }

    public string findSymbol(long hash) {
         int bucket = (cast(int) hash) & indexMask;
        Entry entry = entries[bucket];
        if (entry !is null && entry.hash == hash) {
            return entry.value;
        }
        return null;
    }

    private static string subString(string src, int offset, int len) {
        //char[] chars = new char[len];
        // src.getChars(offset, offset + len, chars, 0);
        return src[offset..offset+len];
    }

    private static string subString(byte[] bytes, int from, int len) {
        // byte[] strBytes = new byte[len];
        byte[] strBytes = bytes[from..from+len].dup;
        return cast(string)strBytes;
        // System.arraycopy(bytes, from, strBytes, 0, len);
        // return new string(strBytes, UTF8);
    }

    private static class Entry {
        public  long hash;
        public  int len;
        public  string value;

        public this(long hash, int len, string value) {
            this.hash = hash;
            this.len = len;
            this.value = value;
        }
    }
}