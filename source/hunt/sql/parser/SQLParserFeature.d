module hunt.sql.parser.SQLParserFeature;

import std.string;

struct SQLParserFeature {
    enum SQLParserFeature KeepInsertValueClauseOriginalString = SQLParserFeature(0);
    enum SQLParserFeature KeepSelectListOriginalString = SQLParserFeature(1); // for improved sql parameterized performance
    enum SQLParserFeature UseInsertColumnsCache = SQLParserFeature(2);
    enum SQLParserFeature EnableSQLBinaryOpExprGroup = SQLParserFeature(3);
    enum SQLParserFeature OptimizedForParameterized = SQLParserFeature(4);
    enum SQLParserFeature OptimizedForForParameterizedSkipValue = SQLParserFeature(5);
    enum SQLParserFeature KeepComments = SQLParserFeature(6);
    enum SQLParserFeature SkipComments = SQLParserFeature(7);
    enum SQLParserFeature StrictForWall = SQLParserFeature(8);

    enum SQLParserFeature PipesAsConcat = 9; // for mysql

    this(int ord){
        mask = (1 << ord);
    }

    public  int mask;


    public static bool isEnabled(int features, SQLParserFeature feature) {
        return (features & feature.mask) != 0;
    }

    public static int config(int features, SQLParserFeature feature, bool state) {
        if (state) {
            features |= feature.mask;
        } else {
            features &= ~feature.mask;
        }

        return features;
    }

    public static int of(SQLParserFeature[] features...) {
        if (features is null) {
            return 0;
        }

        int value = 0;

        foreach(SQLParserFeature feature; features) {
            value |= feature.mask;
        }

        return value;
    }

    bool opEquals(const SQLParserFeature h) nothrow {
        return mask == h.mask ;
    } 

    bool opEquals(ref const SQLParserFeature h) nothrow {
        return mask == h.mask ;
    } 
}

unittest{
    SQLParserFeature p = SQLParserFeature.KeepComments;
    assert(p == SQLParserFeature.KeepComments);
}