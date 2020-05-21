module hunt.sql.ast.SQLObject;

import hunt.collection;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.util.StringBuilder;



interface SQLObject {
    void                accept(SQLASTVisitor visitor);
    SQLObject           clone();

    SQLObject           getParent();
    void                setParent(SQLObject parent);

    Map!(string, Object) getAttributes();
    Object              getAttribute(string name);
    void                putAttribute(string name, Object value);
    Map!(string, Object) getAttributesDirect();
    void                output(StringBuilder buf);

    void                addBeforeComment(string comment);
    void                addBeforeComment(List!string comments);
    List!string         getBeforeCommentsDirect();
    void                addAfterComment(string comment);
    void                addAfterComment(List!string comments);
    List!string         getAfterCommentsDirect();
    bool                hasBeforeComment();
    bool                hasAfterComment();
}
