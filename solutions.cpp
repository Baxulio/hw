#include "solutions.h"

solutions::solutions(QObject *parent) : QSqlQueryModel(parent)
{

}

void solutions::setIdn(int idn)
{
    m_idn=idn;
    setQuery("SELECT s.file FROM solutions s WHERE s.id="+QString::number(idn));
}
