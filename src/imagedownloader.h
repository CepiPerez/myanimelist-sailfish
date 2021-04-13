#ifndef IMAGEDOWNLOADER_H
#define IMAGEDOWNLOADER_H

#include <QStringList>
#include <QThread>
#include <QImage>

#include <QNetworkAccessManager>
#include <QNetworkReply>

class QNetworkRequest;
class QNetworkReply;

class ImageDownloader : public QThread
{
   Q_OBJECT

public:
   ImageDownloader();
   virtual ~ImageDownloader();

   QStringList images;
   QImage result;

   bool working;

public slots:
   void clear();
   void addImage(QString filename);
   void download(QString filename);
   void done();

   void handleNetworkReply(QNetworkReply *networkReply);


signals:
    void imageLoaded(QString filename);

private:
    QNetworkAccessManager* datos;
    QNetworkReply *reply;
};

#endif // IMAGEDOWNLOADER_H
