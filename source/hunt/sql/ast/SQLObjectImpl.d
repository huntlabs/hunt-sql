module hunt.sql.ast.SQLObjectImpl;

import hunt.sql.ast.SQLObject;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.SQLDataType;
import hunt.sql.ast.SQLExpr;
import hunt.collection;
import hunt.util.StringBuilder;



abstract class SQLObjectImpl : SQLObject {

    protected SQLObject           parent;
    protected Map!(string, Object) attributes;

    public this(){
    }

    override public  void accept(SQLASTVisitor visitor) {
        if (visitor is null) {
            throw new Exception("IllegalArgument");
        }

        visitor.preVisit(this);

        accept0(visitor);

        visitor.postVisit(this);
    }

    protected abstract void accept0(SQLASTVisitor visitor);

    protected  void acceptChild(T = SQLObject)(SQLASTVisitor visitor, List!(T) children) {
        if (children is null) {
            return;
        }
        
        foreach(T child ; children) {
            acceptChild(visitor, child);
        }
    }

    protected  void acceptChild(SQLASTVisitor visitor, SQLObject child) {
        if (child is null) {
            return;
        }

        child.accept(visitor);
    }

    override public void output(StringBuilder buf) {
        buf.append(super.toString());
    }

    public override string toString() {
        StringBuilder buf = new StringBuilder();
        output(buf);
        return buf.toString();
    }

    public SQLObject getParent() {
        return parent;
    }

    public void setParent(SQLObject parent) {
        this.parent = parent;
    }

    public Map!(string, Object) getAttributes() {
        if (attributes is null) {
            attributes = new HashMap!(string, Object)(1);
        }

        return attributes;
    }

    public Object getAttribute(string name) {
        if (attributes is null) {
            return null;
        }

        return attributes.get(name);
    }

    public void putAttribute(string name, Object value) {
        if (attributes is null) {
            attributes = new HashMap!(string, Object)(1);
        }

        attributes.put(name, value);
    }

    public Map!(string, Object) getAttributesDirect() {
        return attributes;
    }
    
    // @SuppressWarnings("unchecked")
    public void addBeforeComment(string comment) {
        if (comment is null) {
            return;
        }
        
        if (attributes is null) {
            attributes = new HashMap!(string, Object)(1);
        }
        
        List!string comments = cast(List!string) attributes.get("format.before_comment");
        if (comments is null) {
            comments = new ArrayList!string(2);
            attributes.put("format.before_comment", cast(Object)comments);
        }
        
        comments.add(comment);
    }
    
    // @SuppressWarnings("unchecked")
    public void addBeforeComment(List!string comments) {
        if (attributes is null) {
            attributes = new HashMap!(string, Object)(1);
        }
        
        List!string attrComments = cast(List!string) attributes.get("format.before_comment");
        if (attrComments is null) {
            attributes.put("format.before_comment", cast(Object)comments);
        } else {
            attrComments.addAll(comments);
        }
    }
    
    // @SuppressWarnings("unchecked")
    public List!string getBeforeCommentsDirect() {
        if (attributes is null) {
            return null;
        }
        
        return cast(List!string) attributes.get("format.before_comment");
    }
    
    // @SuppressWarnings("unchecked")
    public void addAfterComment(string comment) {
        if (attributes is null) {
            attributes = new HashMap!(string, Object)(1);
        }
        
        List!string comments = cast(List!string) attributes.get("format.after_comment");
        if (comments is null) {
            comments = new ArrayList!string(2);
            attributes.put("format.after_comment", cast(Object)comments);
        }
        
        comments.add(comment);
    }
    
    // @SuppressWarnings("unchecked")
    public void addAfterComment(List!string comments) {
        if (comments is null) {
            return;
        }

        if (attributes is null) {
            attributes = new HashMap!(string, Object)(1);
        }
        
        List!string attrComments = cast(List!string) attributes.get("format.after_comment");
        if (attrComments is null) {
            attributes.put("format.after_comment", cast(Object)comments);
        } else {
            attrComments.addAll(comments);
        }
    }
    
    // @SuppressWarnings("unchecked")
    public List!string getAfterCommentsDirect() {
        if (attributes is null) {
            return null;
        }
        
        return cast(List!string) attributes.get("format.after_comment");
    }
    
    public bool hasBeforeComment() {
        if (attributes is null) {
            return false;
        }

        List!string comments = cast(List!string) attributes.get("format.before_comment");

        if (comments is null) {
            return false;
        }
        
        return !comments.isEmpty();
    }
    
    public bool hasAfterComment() {
        if (attributes is null) {
            return false;
        }

        List!string comments = cast(List!string) attributes.get("format.after_comment");
        if (comments is null) {
            return false;
        }
        
        return !comments.isEmpty();
    }

    public SQLObject clone() {
        throw new Exception("UnsupportedOperation");
    }

    public SQLDataType computeDataType() {
        return null;
    }
}


class ValuesClause : SQLObjectImpl {

        private      List!SQLExpr values;
        private  string        originalString;
        private  int           replaceCount;

        public this(){
            this(new ArrayList!SQLExpr());
        }

        override public ValuesClause clone() {
            ValuesClause x = new ValuesClause(new ArrayList!SQLExpr(this.values.size()));
            foreach (SQLExpr v ; values) {
                x.addValue(v);
            }
            return x;
        }

        public this(List!SQLExpr values){
            this.values = values;
            for (int i = 0; i < values.size(); ++i) {
                values.get(i).setParent(this);
            }
        }

        public void addValue(SQLExpr value) {
            value.setParent(this);
            values.add(value);
        }

        public List!SQLExpr getValues() {
            return values;
        }

        override public void output(StringBuilder buf) {
            buf.append(" VALUES (");
            for (int i = 0, size = values.size(); i < size; ++i) {
                if (i != 0) {
                    buf.append(", ");
                }
                values.get(i).output(buf);
            }
            buf.append(")");
        }

        
        override  protected void accept0(SQLASTVisitor visitor) {
            if (visitor.visit(this)) {
                this.acceptChild!SQLExpr(visitor, values);
            }

            visitor.endVisit(this);
        }

        public string getOriginalString() {
            return originalString;
        }

        public void setOriginalString(string originalString) {
            this.originalString = originalString;
        }

        public int getReplaceCount() {
            return replaceCount;
        }

        public void incrementReplaceCount() {
            this.replaceCount++;
        }
    }