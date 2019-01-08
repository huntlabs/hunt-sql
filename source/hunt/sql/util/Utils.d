module hunt.sql.util.Utils;

import std.conv;
import std.algorithm.searching; 
import hunt.container;
import std.file;
import std.stdio;
import std.string;

int search(T)(T[] ts, T t)
{
    if(!ts.canFind(t))
        return -1;
    foreach(size_t idx, T tm ; ts)
    {
        if(tm == t)
            return cast(int)idx;
    }
    return -1;
}

class Utils
{
    public static string hex_t(long hash) {
        byte[] bytes = new byte[8];

        bytes[7] = cast(byte) (hash       );
        bytes[6] = cast(byte) (hash >>>  8);
        bytes[5] = cast(byte) (hash >>> 16);
        bytes[4] = cast(byte) (hash >>> 24);
        bytes[3] = cast(byte) (hash >>> 32);
        bytes[2] = cast(byte) (hash >>> 40);
        bytes[1] = cast(byte) (hash >>> 48);
        bytes[0] = cast(byte) (hash >>> 56);

        char[] chars = new char[18];
        chars[0] = 'T';
        chars[1] = '_';
        for (int i = 0; i < 8; ++i) {
            byte b = bytes[i];

            int a = b & 0xFF;
            int b0 = a >> 4;
            int b1 = a & 0xf;

            chars[i * 2 + 2] = cast(char) (b0 + (b0 < 10 ? 48 : 55));
            chars[i * 2 + 3] = cast(char) (b1 + (b1 < 10 ? 48 : 55));
        }

        return to!string(chars);
    }

    public static void putLong(byte[] b, int off, long val) {
        b[off + 7] = cast(byte) (val >>> 0);
        b[off + 6] = cast(byte) (val >>> 8);
        b[off + 5] = cast(byte) (val >>> 16);
        b[off + 4] = cast(byte) (val >>> 24);
        b[off + 3] = cast(byte) (val >>> 32);
        b[off + 2] = cast(byte) (val >>> 40);
        b[off + 1] = cast(byte) (val >>> 48);
        b[off + 0] = cast(byte) (val >>> 56);
    }

    public static bool equals(Object a, Object b) {
        return (a == b) || (a !is null && a.opEquals(b));
    }


    public static bool matches(string pattern,string input)
    {
        import std.regex;
        auto res = matchFirst(input , regex(pattern));
        if (!res.empty)
        {
            if(res.front.length == input.length)
                return true;
        }

        return false;
    }

    public static void loadFromFile(string path, Set!string set) {
        try {
            
            auto reader = File(path,"rb");
            foreach (line ; reader.byLine() ) {

                auto keywords = toLower(strip(cast(string)line));

                if (keywords.length == 0) {
                    continue;
                }
                set.add(keywords);
            }
        } catch (Exception ex) {
            // skip
        } finally {
        }
    }

}

