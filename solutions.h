#ifndef SOLUTIONS_H
#define SOLUTIONS_H

#include <QSqlQueryModel>

class solutions : public QSqlQueryModel
{
    Q_OBJECT

    Q_PROPERTY(int idn READ idn WRITE setIdn)
public:
    solutions(QObject *parent = 0);

    int idn(){return m_idn;}
    void setIdn(int idn);

private:
    int m_idn;
};

#endif // SOLUTIONS_H
