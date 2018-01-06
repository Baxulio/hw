#include <QSqlRecord>
#include "sqltaskmodel.h"
#include <QSqlQuery>

#include <QElapsedTimer>
#include <QDebug>
#include <QSqlError>

static const char *tasksTableName = "tasks";

SqlTaskModel::SqlTaskModel(QObject *parent) :
    QSqlRelationalTableModel(parent)
{
    // setTable(tasksTableName);
    //
    
    //    setRelation(fieldIndex("subject"),QSqlRelation("mapper","id","type"));
    
    //    setEditStrategy(QSqlRelationalTableModel::OnManualSubmit);
    //    setJoinMode(QSqlRelationalTableModel::InnerJoin);
    
    //        const QString filterString = QString::fromLatin1(
    //            "mapper.subject=%1").arg(1);
    
    //        setFilter(filterString);
    
    //setQuery(QSqlQuery("select * from tasks"));
    
    //setSort(0, Qt::DescendingOrder);
    
    
    //select();
    
    //    const QString filterString = QString::fromLatin1("SELECT t.Id,t.task_number,t.task,s.type, t.solutions,t.description,t.added_data FROM tasks t JOIN mapper m ON t.subject=m.id AND m.subject=%1 JOIN subject_types s ON m.`type`=s.Id ORDER BY m.`type` ASC").arg(3);
    
    //    setQuery(QSqlQuery(filterString));
    //    select();
}

int SqlTaskModel::subject() const
{
    return m_subject;
}

void SqlTaskModel::setSubject(const int &subject)
{
    if (subject == m_subject)
        return;
    
    m_subject = subject;
    
    const QString filterString = QString::fromLatin1("SELECT t.Id,t.task_number,t.task,s.type, t.solutions,t.description,t.added_data FROM tasks t JOIN mapper m ON t.subject=m.id AND m.subject=%1 JOIN subject_types s ON m.`type`=s.Id ORDER BY m.`type` ASC").arg(m_subject);
    
    
    setQuery(QSqlQuery(filterString));
    QElapsedTimer timer;
    timer.start();
    select();
    qDebug() << "The operation took" << timer.elapsed() << "milliseconds";
    emit subjectChanged();
}

QVariant SqlTaskModel::data(const QModelIndex &index, int role) const
{
    if (role < Qt::UserRole)
        return QSqlTableModel::data(index, role);
    
    const QSqlRecord sqlRecord = record(index.row());
    return sqlRecord.value(role - Qt::UserRole);
}

QHash<int, QByteArray> SqlTaskModel::roleNames() const
{
    QHash<int, QByteArray> names;
    names[Qt::UserRole] = "id";
    names[Qt::UserRole + 1] = "task_number";
    names[Qt::UserRole + 2] = "task";
    names[Qt::UserRole + 3] = "type";
    names[Qt::UserRole + 4] = "solutions";
    names[Qt::UserRole + 5] = "description";
    names[Qt::UserRole + 6] = "added_data";
    
    return names;
}

bool SqlTaskModel::addTask(const QString &task, const QString &description, const int &taskNumber, const QString &type_name)
{
    QSqlQuery query(QString::fromLatin1("SELECT Id FROM myhw.subject_types s WHERE s.type='%1'").arg(type_name));
    int type_id;
    if(!query.next())
        return false;

    type_id=query.value(0).toInt();

    query.prepare("INSERT INTO myhw.tasks (task_number, task, subject, description, added_data) VALUES (?, ?,(SELECT id FROM myhw.mapper m WHERE m.subject=? AND m.type=?), ?, SYSDATE());");

    query.bindValue(0,taskNumber);
    query.bindValue(1,task);
    query.bindValue(3,type_id);
    query.bindValue(2,subject());
    query.bindValue(4,description);

    if(!query.exec())
    {
        qDebug()<<"can't addTask : "<<query.lastError().text();
        return false;
    }
    return true;
}

bool SqlTaskModel::addSolution(const QUrl &url)
{
    QSqlDatabase::database().transaction();

    const int taskId =url.idnWhitelist().first().toInt();

    QSqlQuery query;
    query.exec(QString::fromLatin1("SELECT solutions FROM myhw.tasks WHERE id = %1").arg(taskId));

    if (!query.next()) {
        qDebug()<<query.lastError();
        query.finish();
        return QSqlDatabase::database().rollback();
    }

    int solutionId = query.value(0).toInt();

    if(!solutionId)
    {
        query.exec(QString::fromLatin1("SELECT MAX(id)+1 FROM myhw.solutions"));
        if (!query.next()) {
            qDebug()<<query.lastError();
            query.finish();
            return QSqlDatabase::database().rollback();
        }
        solutionId=query.value(0).toInt();
    }

    query.prepare("INSERT INTO myhw.solutions (id, `file`) VALUES (?,?); UPDATE myhw.tasks SET solutions=? WHERE  Id=?;");
    query.bindValue(0,solutionId);
    query.bindValue(1,url.toString(QUrl::RemovePassword));
    query.bindValue(2,solutionId);
    query.bindValue(3, taskId);

    if(!query.exec())
    {
        qDebug()<<query.lastError();
        query.finish();
        return QSqlDatabase::database().rollback();
    }
    if(query.isActive())query.clear();
    return QSqlDatabase::database().commit();
}
