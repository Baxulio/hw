#ifndef SQLTASKMODEL_H
#define SQLTASKMODEL_H

#include <QSqlRelationalTableModel>
#include <QUrl>
class SqlTaskModel : public QSqlRelationalTableModel
{
    Q_OBJECT
    Q_PROPERTY(int subject READ subject WRITE setSubject NOTIFY subjectChanged)

public:
    SqlTaskModel(QObject *parent = 0);

    int subject() const;
    void setSubject(const int &subject);

    QVariant data(const QModelIndex &index, int role) const Q_DECL_OVERRIDE;
    QHash<int, QByteArray> roleNames() const Q_DECL_OVERRIDE;

    Q_INVOKABLE bool addTask(const QString &task, const QString &description, const int &taskNumber, const QString &type_name);
    Q_INVOKABLE bool addSolution(const QUrl &url);
signals:
    void subjectChanged();

private:
    int m_subject;
};

#endif // SQLTASKMODEL_H
