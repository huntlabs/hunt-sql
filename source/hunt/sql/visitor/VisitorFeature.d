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
module hunt.sql.visitor.VisitorFeature;

public struct  VisitorFeature {
    enum VisitorFeature OutputUCase =  VisitorFeature(0);
    enum VisitorFeature OutputPrettyFormat =  VisitorFeature(1);
    enum VisitorFeature OutputParameterized =  VisitorFeature(2);
    enum VisitorFeature OutputDesensitize =  VisitorFeature(3);
    enum VisitorFeature OutputUseInsertValueClauseOriginalString =  VisitorFeature(4);
    enum VisitorFeature OutputSkipSelectListCacheString =  VisitorFeature(5);
    enum VisitorFeature OutputSkipInsertColumnsString =  VisitorFeature(6);
    enum VisitorFeature OutputParameterizedQuesUnMergeInList =  VisitorFeature(7);
    enum VisitorFeature OutputParameterizedQuesUnMergeOr =  VisitorFeature(8);
    enum VisitorFeature OutputKeepParenthesisWhenNotExpr =   VisitorFeature(9);


    /**
     * @deprecated
     */

    private this(int ord){
        mask = (1 << ord);
    }

    public  int mask;


    public static bool isEnabled(int features, VisitorFeature feature) {
        return (features & feature.mask) != 0;
    }

    public static int config(int features, VisitorFeature feature, bool state) {
        if (state) {
            features |= feature.mask;
        } else {
            features &= ~feature.mask;
        }

        return features;
    }

    public static int of(VisitorFeature[] features...) {
        if (features is null) {
            return 0;
        }

        int value = 0;

        foreach (VisitorFeature feature; features) {
            value |= feature.mask;
        }

        return value;
    }

    bool opEquals(const VisitorFeature h) nothrow {
        return mask == h.mask ;
    } 

    bool opEquals(ref const VisitorFeature h) nothrow {
        return mask == h.mask ;
    } 
}
