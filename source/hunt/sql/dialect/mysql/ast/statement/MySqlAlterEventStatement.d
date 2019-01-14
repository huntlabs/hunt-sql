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
module hunt.sql.dialect.mysql.ast.statement.MySqlAlterEventStatement;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLStatement;
import hunt.sql.ast.statement.SQLAlterStatement;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;
import hunt.sql.util.DBType;
import hunt.sql.dialect.mysql.ast.statement.MySqlStatementImpl;
import hunt.sql.dialect.mysql.ast.statement.MySqlEventSchedule;
import hunt.Boolean;

public class MySqlAlterEventStatement : MySqlStatementImpl , SQLAlterStatement {
    alias accept0 = MySqlStatementImpl.accept0;
    
    private SQLName            definer;
    private SQLName            name;

    private MySqlEventSchedule schedule;
    private bool            onCompletionPreserve;
    private SQLName            renameTo;
    private Boolean            enable;
    private bool            disableOnSlave;
    private SQLExpr            comment;
    private SQLStatement       eventBody;

    public this() {
        setDbType(DBType.MYSQL.name);
    }

    override public void accept0(MySqlASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, definer);
            acceptChild(visitor, name);
            acceptChild(visitor, schedule);
            acceptChild(visitor, renameTo);
            acceptChild(visitor, comment);
            acceptChild(visitor, eventBody);
        }
        visitor.endVisit(this);
    }

    public SQLName getDefiner() {
        return definer;
    }

    public void setDefiner(SQLName definer) {
        if (definer !is null) {
            definer.setParent(this);
        }
        this.definer = definer;
    }

    public SQLName getName() {
        return name;
    }

    public void setName(SQLName name) {
        if (name !is null) {
            name.setParent(this);
        }
        this.name = name;
    }

    public MySqlEventSchedule getSchedule() {
        return schedule;
    }

    public void setSchedule(MySqlEventSchedule schedule) {
        if (schedule !is null) {
            schedule.setParent(this);
        }
        this.schedule = schedule;
    }

    public bool isOnCompletionPreserve() {
        return onCompletionPreserve;
    }

    public void setOnCompletionPreserve(bool onCompletionPreserve) {
        this.onCompletionPreserve = onCompletionPreserve;
    }

    public SQLName getRenameTo() {
        return renameTo;
    }

    public void setRenameTo(SQLName renameTo) {
        if (renameTo !is null) {
            renameTo.setParent(this);
        }
        this.renameTo = renameTo;
    }

    public Boolean getEnable() {
        return enable;
    }

    public void setEnable(Boolean enable) {
        this.enable = enable;
    }

    public bool isDisableOnSlave() {
        return disableOnSlave;
    }

    public void setDisableOnSlave(bool disableOnSlave) {
        this.disableOnSlave = disableOnSlave;
    }

    public SQLExpr getComment() {
        return comment;
    }

    public void setComment(SQLExpr comment) {
        if (comment !is null) {
            comment.setParent(this);
        }
        this.comment = comment;
    }

    public SQLStatement getEventBody() {
        return eventBody;
    }

    public void setEventBody(SQLStatement eventBody) {
        if (eventBody !is null) {
            eventBody.setParent(this);
        }
        this.eventBody = eventBody;
    }
}
