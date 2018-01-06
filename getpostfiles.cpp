#include "getpostfiles.h"
#include <QStandardPaths>
#include <QDir>
GetPostFiles::GetPostFiles(QObject *parent) : QObject(parent)
{
    connect(&manager, SIGNAL(finished(QNetworkReply*)),SLOT(downloadFinished(QNetworkReply*)));
}

void GetPostFiles::getFile(const QString &url)
{
    QUrl uri = QUrl::fromEncoded(url.toLocal8Bit());
    uri.setPassword("12345");
    qDebug()<<uri;
    QNetworkRequest request(uri);
    QNetworkReply *reply = manager.get(request);

#ifndef QT_NO_SSL
    connect(reply, SIGNAL(sslErrors(QList<QSslError>)), SLOT(sslErrors(QList<QSslError>)));
#endif

    currentDownloads.append(reply);
}

void GetPostFiles::putFile(const QUrl &url)
{

    const QString fileLocation=url.toDisplayString(QUrl::PreferLocalFile);

    QFile *data=new QFile(fileLocation);

    if (!data->open(QIODevice::ReadOnly)) {
        qDebug() << "Oops";

        data->deleteLater();
        return;
    }
    QUrl uri("ftp://root@localhost/files/"+url.fileName());
    uri.setPassword("12345");

    QNetworkReply *reply = manager.put(QNetworkRequest(uri),data);
    //connect(reply, SIGNAL(finished()), SLOT(uploadDone()));
    //connect(reply, SIGNAL(uploadProgress(qint64, qint64)), SLOT(progress(qint64, qint64)));
#ifndef QT_NO_SSL
    connect(reply, SIGNAL(sslErrors(QList<QSslError>)), SLOT(sslErrors(QList<QSslError>)));
#endif

    currentDownloads.append(reply);
    //data->deleteLater();
}

QString GetPostFiles::saveFileName(const QUrl &url)
{
    QString basename = url.fileName();

    if (basename.isEmpty())
        basename = "download";

    if (isFileExist(basename)) {
        // already exists, don't overwrite
        int i = 0, index=basename.lastIndexOf(".");
        QString format = basename.right(basename.length()-index);
        basename.chop(index);
        basename+="_";
        while (QFile::exists(parentDir(basename + QString::number(i))))
            ++i;

        basename += QString::number(i)+format;
    }

    return parentDir(basename);
}

bool GetPostFiles::saveToDisk(const QString &filename, QIODevice *data)
{
    QFile file(filename);
    const QString path=QStandardPaths::writableLocation(QStandardPaths::DownloadLocation)+"/hw";

    QDir dir(path);
    if (!dir.exists()) {
        dir.mkpath(path);
    }
    if (!file.open(QIODevice::WriteOnly)) {
        fprintf(stderr, "Could not open %s for writing: %s\n",
                qPrintable(filename),
                qPrintable(file.errorString()));
        return false;
    }

    file.write(data->readAll());
    file.close();

    return true;
}

bool GetPostFiles::isFileExist(const QString &filename)
{
    return QFile::exists(parentDir(filename));
}

const QString GetPostFiles::parentDir(const QString &filename)
{
    return QStandardPaths::writableLocation(QStandardPaths::DownloadLocation)+"/hw/"+filename;
}

void GetPostFiles::executePutting(const QList<QUrl> &urls, const int &subjectId, const int &hasId)
{
    if (urls.isEmpty()) {
        printf("no urls");
        return;
    }
    foreach (QUrl url, urls) {
        qDebug()<<url<<""<<subjectId<<hasId;
        url.setIdnWhitelist(QStringList()<<QString::number(subjectId)<<QString::number(hasId));
        putFile(url);
    }
}

void GetPostFiles::downloadFinished(QNetworkReply *reply)
{
    QUrl url=reply->url();

    qDebug()<<"download finished: "<<url;

    if(reply->error()==QNetworkReply::ContentConflictError)
    {

    }
    else if (reply->error()) {
        fprintf(stderr, "Download of %s failed: %s\n",
                url.toEncoded().constData(),
                qPrintable(reply->errorString()));
    }
    else if(reply->operation()==QNetworkAccessManager::GetOperation){
        QString filename = saveFileName(url);
        qDebug()<<"created file name: "<<filename << "\n"<< QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
        if (saveToDisk(filename, reply))
            printf("Download of %s succeeded (saved to %s)\n", url.toEncoded().constData(), qPrintable(filename));
    }
    else if(reply->operation()==QNetworkAccessManager::PutOperation)
    {
        emit replyReady(url);
    }

    currentDownloads.removeAll(reply);
    reply->deleteLater();
}

void GetPostFiles::sslErrors(const QList<QSslError> &errors)
{
#ifndef QT_NO_SSL
    foreach (const QSslError &error, errors)
        fprintf(stderr, "SSL error: %s\n", qPrintable(error.errorString()));
#else
    Q_UNUSED(sslErrors);
#endif
}
