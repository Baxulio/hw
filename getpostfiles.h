#ifndef GETPOSTFILES_H
#define GETPOSTFILES_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QFile>
#include <QFileInfo>
class GetPostFiles : public QObject
{
    Q_OBJECT

public:
    explicit GetPostFiles(QObject *parent = 0);

    Q_INVOKABLE void getFile(const QString &url);
    Q_INVOKABLE void putFile(const QUrl &url);

    QString saveFileName(const QUrl &url);
    bool saveToDisk(const QString &filename, QIODevice *data);

    Q_INVOKABLE bool isFileExist(const QString &filename);
    Q_INVOKABLE const QString parentDir(const QString &filename);

signals:
//    void progress(qint64 recieved, qint64 total);
    void replyReady(const QUrl &url);

public slots:
    void executePutting(const QList<QUrl> &urls, const int &subjectId, const int &hasId);
    void downloadFinished(QNetworkReply *reply);
    void sslErrors(const QList<QSslError> &errors);

private:
    QNetworkAccessManager manager;          // менеджер сетевого доступа
    QList<QNetworkReply *> currentDownloads;
    QFile *data;
};
#endif // GETPOSTFILES_H
