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
module hunt.sql.visitor.ParameterizedVisitor;
import hunt.sql.visitor.PrintableVisitor;
import hunt.sql.visitor.VisitorFeature;

import hunt.collection;

public interface ParameterizedVisitor : PrintableVisitor {

    int getReplaceCount();

    void incrementReplaceCunt();

    string getDbType();

    void setOutputParameters(List!(Object) parameters);

    void config(VisitorFeature feature, bool state);
}
