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
module hunt.sql.parser.InsertColumnsCache;

import hunt.sql.ast.SQLExpr;
import hunt.sql.util.FnvHash;
import hunt.Long;
import hunt.collection;


public class InsertColumnsCache {
    public static InsertColumnsCache global;

    // static this(){
    //     global = new InsertColumnsCache(8192);
    // }

    public HashMap!(Long, Entry) cache;

    private  Entry[]   buckets;
    private  int       indexMask;

    public this(int tableSize){
        this.indexMask = tableSize - 1;
        this.buckets = new Entry[tableSize];
        cache = new HashMap!(Long, Entry)();
    }

    public  Entry get(long hashCode64) {
         int bucket = (cast(int) hashCode64) & indexMask;
        for (Entry entry = buckets[bucket]; entry !is null; entry = entry.next) {
            if (hashCode64 == entry.hashCode64) {
                return entry;
            }
        }

        return null;
    }

    public bool put(long hashCode64, string columnsString, string columnsFormattedString, List!(SQLExpr) columns) {
         int bucket = (cast(int) hashCode64) & indexMask;

        for (Entry entry = buckets[bucket]; entry !is null; entry = entry.next) {
            if (hashCode64 == entry.hashCode64) {
                return true;
            }
        }

        Entry entry = new Entry(hashCode64, columnsString, columnsFormattedString, columns, buckets[bucket]);
        buckets[bucket] = entry;  // 并发是处理时会可能导致缓存丢失，但不影响正确性

        return false;
    }

    public  static class Entry {
        public  long hashCode64;
        public  string columnsString;
        public  string columnsFormattedString;
        public  long columnsFormattedStringHash;
        public  List!(SQLExpr) columns;
        public  Entry next;

        public this(long hashCode64, string columnsString, string columnsFormattedString, List!(SQLExpr) columns, Entry next) {
            this.hashCode64 = hashCode64;
            this.columnsString = columnsString;
            this.columnsFormattedString = columnsFormattedString;
            this.columnsFormattedStringHash = FnvHash.fnv1a_64_lower(columnsFormattedString);
            this.columns = columns;
            this.next = next;
        }
    }
}
