#ifndef SQLSUBJECTMODEL_H
#define SQLSUBJECTMODEL_H

#include <QSqlRelationalTableModel>

class SqlSubjectModel : public QSqlRelationalTableModel
{
    Q_OBJECT
public:
    SqlSubjectModel(QObject *parent = 0);

    QVariant data(const QModelIndex &index, int role) const Q_DECL_OVERRIDE;
    QHash<int, QByteArray> roleNames() const Q_DECL_OVERRIDE;

    //Q_INVOKABLE void sendMessage(const QString &recipient, const QString &message);
    Q_INVOKABLE void selectModel();

private:
    QString m_recipient;
};

#endif // SQLSUBJECTMODEL_H
