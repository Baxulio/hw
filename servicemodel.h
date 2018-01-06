#ifndef SERVICEMODEL_H
#define SERVICEMODEL_H

#include <QSqlQueryModel>

class ServiceModel : public QSqlQueryModel
{
    Q_OBJECT

    Q_PROPERTY(int idn READ idn WRITE setIdn NOTIFY idNChanged)

//    Q_PROPERTY(models mod READ modName WRITE setMod)

public:
//    enum models{
//        SubjectTypes=1,
//        Solutions
//    };
//    Q_ENUM(models)

    ServiceModel(QObject *parent = 0);

    int idn(){return m_idn;}
    void setIdn(int idn);

//    models modName(){return mod;}
//    void setMod(models model);

signals:
    void idNChanged();

private:
    int m_idn;
//    models mod;
};

#endif // SERVICEMODEL_H
