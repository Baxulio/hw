#include "servicemodel.h"

ServiceModel::ServiceModel(QObject *parent) :
    QSqlQueryModel (parent)
{
}

void ServiceModel::setIdn(int idn)
{
    m_idn=idn;
    setQuery("SELECT s.type FROM mapper m JOIN subject_types s ON m.type = s.Id WHERE m.subject="+QString::number(idn));
}

//void ServiceModel::setMod(ServiceModel::models model)
//{
////    if(modName()==model)return;

//    mod=model;

//    switch (model) {
//    case SubjectTypes:
//        setQuery("SELECT s.type FROM mapper m JOIN subject_types s ON m.type = s.Id WHERE m.subject="+QString::number(idn()));
//        break;
//    case Solutions: break;
//    }
//}
