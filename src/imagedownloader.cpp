#include "imagedownloader.h"

#include <QCryptographicHash>
#include <QUrl>
#include <QString>
#include <QFileInfo>
#include <QDir>
#include <QImage>
#include <QSettings>
#include <QDebug>

#include <QNetworkReply>


ImageDownloader::ImageDownloader()
{
    datos = new QNetworkAccessManager(this);
    connect(datos, SIGNAL(finished(QNetworkReply*)), this, SLOT(handleNetworkReply(QNetworkReply*)));
    working = false;
}

ImageDownloader::~ImageDownloader()
{

}

void ImageDownloader::clear()
{
    if (images.count()==0)
        return;

    images.clear();
    if (reply && reply->isRunning()) {
        reply->abort();
    }
    working = false;
}

void ImageDownloader::addImage(QString filename)
{
    images.append(filename);
    images.removeDuplicates();
}

void ImageDownloader::done()
{
    if (images.count()>0) {
        working = true;
        download(images.at(0));
    } else {
        working = false;
    }
}

void ImageDownloader::download(QString filename)
{
    QUrl url = filename.split("?").at(0);
    qDebug() << "Downloading image: " << url;
    reply = datos->get(QNetworkRequest(QUrl(url)));
}

void ImageDownloader::handleNetworkReply(QNetworkReply *networkReply)
{
    if(!QFileInfo("/home/nemo/.cache/myanimelist").exists()) {
        QDir dir;
        dir.mkdir("/home/nemo/.cache/myanimelist");
    }

    QImage img = QImage::fromData(networkReply->readAll());

    QCryptographicHash md(QCryptographicHash::Md5);
    QString file = images.at(0);
    md.addData(file.toUtf8());
    QString tf = "/home/nemo/.cache/myanimelist/"+ QString(md.result().toHex().constData()) + ".jpg";

    img.save(tf, "JPEG");

    emit imageLoaded(images.at(0));

    images.removeAt(0);
    done();

}
