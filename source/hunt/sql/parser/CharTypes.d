module hunt.sql.parser.CharTypes;

//import hunt.sql.parser.LayoutCharacters.EOI;
import std.conv;
import hunt.sql.parser.LayoutCharacters;

public class CharTypes {

    private  static bool[] hexFlags = new bool[256];
    

    public static bool isHex(char c) {
        return c < 256 && hexFlags[c];
    }

    public static bool isDigit(char c) {
        return c >= '0' && c <= '9';
    }

    private  static bool[] firstIdentifierFlags = new bool[256];


    public static bool isFirstIdentifierChar(char c) {
        if (c <= firstIdentifierFlags.length) {
            return firstIdentifierFlags[c];
        }
        return c != '　' && c != '，';
    }

    private  static string[] stringCache = new string[256];
    private  static bool[] identifierFlags = new bool[256];


    public static bool isIdentifierChar(char c) {
        if (c <= identifierFlags.length) {
            return identifierFlags[c];
        }
        return c != '　' && c != '，' && c != '）';
    }

    public static string valueOf(char ch) {
        if (ch < stringCache.length) {
            return stringCache[ch];
        }
        return null;
    }

    private  static bool[] whitespaceFlags = new bool[256];

    /**
     * @return false if {@link LayoutCharacters#EOI}
     */
    public static bool isWhitespace(char c) {
        return (c <= whitespaceFlags.length && whitespaceFlags[c]) //
               || c == '　'; // Chinese space
    }

}

static this()
{
   import std.stdio;
        for (dchar c = 0; c < CharTypes.hexFlags.length; ++c) {
            if (c >= 'A' && c <= 'F') {
                CharTypes.hexFlags[c] = true;
            } else if (c >= 'a' && c <= 'f') {
                CharTypes.hexFlags[c] = true;
            } else if (c >= '0' && c <= '9') {
                CharTypes.hexFlags[c] = true;
            }
        }

        for (dchar c = 0; c < CharTypes.firstIdentifierFlags.length; ++c) {
            if (c >= 'A' && c <= 'Z') {
                CharTypes.firstIdentifierFlags[c] = true;
            } else if (c >= 'a' && c <= 'z') {
                CharTypes.firstIdentifierFlags[c] = true;
            }
        }
        CharTypes.firstIdentifierFlags['`'] = true;
        CharTypes.firstIdentifierFlags['_'] = true;
        CharTypes.firstIdentifierFlags['$'] = true;
    
        for (dchar c = 0; c < CharTypes.identifierFlags.length; ++c) {
            if (c >= 'A' && c <= 'Z') {
                CharTypes.identifierFlags[c] = true;
            } else if (c >= 'a' && c <= 'z') {
                CharTypes.identifierFlags[c] = true;
            } else if (c >= '0' && c <= '9') {
                CharTypes.identifierFlags[c] = true;
            }
        }
        // identifierFlags['`'] = true;
        CharTypes.identifierFlags['_'] = true;
        CharTypes.identifierFlags['$'] = true;
        CharTypes.identifierFlags['#'] = true;

        for (int i = 0; i < CharTypes.identifierFlags.length; i++) {
            if (CharTypes.identifierFlags[i]) {
                char ch = cast(char) i;
                CharTypes.stringCache[i] = to!string(ch);
            }
        }

        for (int i = 0; i <= 32; ++i) {
            CharTypes.whitespaceFlags[i] = true;
        }
        
        CharTypes.whitespaceFlags[LayoutCharacters.EOI] = false;
        for (int i = 0x7F; i <= 0xA0; ++i) {
            CharTypes.whitespaceFlags[i] = true;
        }
   
        CharTypes.whitespaceFlags[160] = true; // 特别处理

}