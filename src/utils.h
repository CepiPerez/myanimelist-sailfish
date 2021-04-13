#ifndef UTILS_H
#define UTILS_H

#include <QQuickItem>
#include <QDebug>

#include "imagedownloader.h"

class Utils : public QQuickItem
{
    Q_OBJECT

public:
    Utils(QQuickItem *parent = 0);

    Q_INVOKABLE QString readSettings(QString set, QString val);

    //Q_INVOKABLE QString getTheme();
    //Q_INVOKABLE QString getBlancoColor(int color);
    //Q_INVOKABLE QString getSailfishColor();
    //Q_INVOKABLE QString getSailfishBackColor();
    Q_INVOKABLE QString getCacheImage(QString url, bool download=false);
    Q_INVOKABLE QVariantMap updateItem(QString map);
    Q_INVOKABLE QString manageList(QString action, QString list, QString items);
    Q_INVOKABLE bool itemInLibrary(QString library, QString id);


public slots:
    void setSettings(QString set, QString val);
    //void saveImage(QObject *imageObj, QString url);
    void imageDownloaded(QString url);
    void checkImages();
    void stopCachingImages();

signals:
    void imageSavedToCache(QString durl, QString dpath);

private:
    ImageDownloader *imgDownloader;

};

#endif // UTILS_H


