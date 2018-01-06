#include "sqlsubjectmodel.h"
#include "QSqlRecord"

#include <QDebug>
#include <QSqlError>
#include <QSqlQuery>

static const char *subjectsTableName = "subjects";

//SqlSubjectModel::SqlSubjectModel(QObject *parent) :
//    QSqlRelationalTableModel (parent)
//{
//    QSqlQuery query;
//    if (!query.exec("SELECT subject FROM subjects"))
//        qFatal("Contacts SELECT query failed: %s", qPrintable(query.lastError().text()));

//    setQuery(query);
//    if (lastError().isValid())
//        qFatal("Cannot set query on SqlContactModel: %s", qPrintable(lastError().text()));
//}

SqlSubjectModel::SqlSubjectModel(QObject *parent) :
    QSqlRelationalTableModel(parent)
{
    setTable(subjectsTableName);
    setSort(1, Qt::AscendingOrder);
    select();
}

QVariant SqlSubjectModel::data(const QModelIndex &index, int role) const
{
    if (role < Qt::UserRole)
        return QSqlTableModel::data(index, role);

    const QSqlRecord sqlRecord = record(index.row());
    return sqlRecord.value(role - Qt::UserRole);
}

QHash<int, QByteArray> SqlSubjectModel::roleNames() const
{
    QHash<int, QByteArray> names;
    names[Qt::UserRole] = "id";
    names[Qt::UserRole + 1] = "subject";

    return names;
}

void SqlSubjectModel::selectModel()
{
    select();
}
