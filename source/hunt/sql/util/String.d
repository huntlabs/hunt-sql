module hunt.sql.util.String;
import std.conv;

class String{

    private string _str;

    this()
    {
        _str = string.init;
    }

    this(string str)
    {
        _str = str;
    }

    this(char c)
    {
        this(to!string(c));
    }

    this(byte[] b)
    {
        this(to!string(b));
    }

    @property string str()
    {
        return _str;
    }

    @property size_t length()
    {
        return _str.length;
    }

    byte[] getBytes()
    {
        return to!(byte[])(_str);
    }

    public static string valueOf(Object obj) {
        return (obj is null) ? "null" : obj.toString();
    }

    override string toString()
    {
        return _str;
    }
}

 int compareTo(String v1 , String v2)
 {  
        import std.algorithm.comparison;

        string value = v1.str;
        string another = v2.str;
        int len1 = cast(int)value.length;
        int len2 = cast(int)another.length;
        int lim = min(len1, len2);

        int k = 0;
        while (k < lim) {
            char c1 = value[k];
            char c2 = another[k];
            if (c1 != c2) {
                return c1 - c2;
            }
            k++;
        }
        return len1 - len2;
}