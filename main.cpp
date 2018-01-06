#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <QSettings>
#include <QQuickStyle>
#include <QQmlContext>
#include <QSqlDatabase>
#include <QSqlError>

#include <sqlsubjectmodel.h>
#include <sqltaskmodel.h>
#include <servicemodel.h>
#include <solutions.h>
#include <getpostfiles.h>

static bool connectToDatabase()
{
    QSqlDatabase database;
    database = QSqlDatabase::addDatabase("QMYSQL");

    database.setDatabaseName("myhw");
    database.setHostName("localhost");
    database.setPassword("");
    database.setPort(3306);
    database.setUserName("root");

    if (!database.open())
    {
        //qFatal("Cannot add database: %s", qPrintable(database.lastError().text()));
        return 0;
    }
    return 1;
}

int main(int argc, char *argv[])
{
    QCoreApplication::setApplicationName("My H/W");
    QCoreApplication::setOrganizationName("Bahman");
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    if(!connectToDatabase())
    {
        return -1;
    }

    QSettings settings;
    QString style = QQuickStyle::name();
    if (!style.isEmpty())
        settings.setValue("style", style);
    else
        QQuickStyle::setStyle(settings.value("style").toString());

    qmlRegisterType<SqlSubjectModel>("hw.sqlsubjectmodel",1,0,"SqlSubjectModel");
    qmlRegisterType<SqlTaskModel>("hw.sqltaskmodel",1,0,"SqlTaskModel");
    qmlRegisterType<ServiceModel>("hw.servicemodel",1,0,"ServiceModel");
    qmlRegisterType<solutions>("hw.solutionsmodel",1,0,"SolutionsModel");

    GetPostFiles ftp;
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("ftp",&ftp);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
