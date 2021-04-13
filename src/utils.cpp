#include "utils.h"
#include <QString>
#include <QSettings>
//#include <MGConfItem>
#include <QCryptographicHash>
#include <QFileInfo>
#include <QPainter>
//#include <QStyleOptionGraphicsItem>
#include <QDir>

QSettings settings("cepiperez", "flowplayer");

Utils::Utils(QQuickItem *parent)
    : QQuickItem(parent)
{
    imgDownloader = new ImageDownloader();

    connect(imgDownloader, SIGNAL(imageLoaded(QString)), this, SLOT(imageDownloaded(QString)));

}

void Utils::setSettings(QString set, QString val)
{
    settings.setValue(set, val);
    settings.sync();
}

QString Utils::readSettings(QString set, QString val)
{
    return settings.value(set, val).toString();
}


/*QString Utils::getTheme()
{
    MGConfItem *m_gconfItem = new MGConfItem("/meegotouch/theme/name");
    QString currentTheme = m_gconfItem->value().toString();
    if (currentTheme.isEmpty()) {
        currentTheme = "blanco";
    }
    return currentTheme;
}*/

/*QString Utils::getBlancoColor(int index)
{
    QSettings settings("/usr/share/themes/blanco/meegotouch/constants.ini", QSettings::IniFormat );
    QString con = "COLOR_ACCENT" + QString::number(index);
    QString result = settings.value("Palette/"+con,"#4591FF").toString();
    //qDebug() << "SEL COLOR: " << result;
    return result;
}*/

/*QString Utils::getSailfishColor()
{
    QSettings tsettings2("/usr/share/themes/sailfish/meegotouch/constants.ini", QSettings::IniFormat );
    return tsettings2.value("Special Colors for Ambiance support/COLOR_SPECIAL2","#FFFFFF").toString();
}*/

/*QString Utils::getSailfishBackColor()
{
    QSettings tsettings2("/usr/share/themes/sailfish/meegotouch/constants.ini", QSettings::IniFormat );
    return tsettings2.value("Special Colors for Ambiance support/COLOR_SPECIAL4","#FFFFFF").toString();
}*/

/*void Utils::saveImage(QObject *imageObj, QString url)
{
    qDebug() << "Saving cache image for " << url;

    if(!QFileInfo("/home/nemo/.cache/myanimelist").exists()) {
        QDir dir;
        dir.mkdir("/home/nemo/.cache/myanimelist");
    }

    QGraphicsObject *item = qobject_cast<QGraphicsObject*>(imageObj);
    if (!item) {
        qDebug() << "Item is NULL";
        return;
    }

    QImage img(item->boundingRect().size().toSize(), QImage::Format_RGB32);
    img.fill(QColor(255, 255, 255).rgb());
    QPainter painter(&img);
    QStyleOptionGraphicsItem styleOption;
    item->paint(&painter, &styleOption);

    QCryptographicHash md(QCryptographicHash::Md5);
    md.addData(url.toUtf8());
    QString tf = "/home/nemo/.cache/myanimelist/"+ QString(md.result().toHex().constData()) + ".jpg";
    img.save(tf, "JPEG");
}*/

QString Utils::getCacheImage(QString url, bool download)
{
    qDebug() << "Getting image for " << url;
    QCryptographicHash md(QCryptographicHash::Md5);
    md.addData(url.toUtf8());
    QString tf = "/home/nemo/.cache/myanimelist/"+ QString(md.result().toHex().constData()) + ".jpg";

    if (!QFileInfo(tf).exists()) {
        if (download) {
            qDebug() << "Adding " << url;
            imgDownloader->addImage(url);
        }
        return "loading-" + url; //prevent to load from qml side
    } else {
        return "file://" + tf;
    }
}

void Utils::checkImages()
{
    qDebug() << "Checking image downloader: " << imgDownloader->images.count() << imgDownloader->working;
    if (!imgDownloader->working && imgDownloader->images.count()>0)
        imgDownloader->done();
}

void Utils::stopCachingImages()
{
    imgDownloader->clear();
}

void Utils::imageDownloaded(QString url)
{
    QCryptographicHash md(QCryptographicHash::Md5);
    md.addData(url.toUtf8());
    QString tf = "file:///home/nemo/.cache/myanimelist/"+ QString(md.result().toHex().constData()) + ".jpg";
    emit imageSavedToCache("loading-"+url, tf);
}

QVariantMap Utils::updateItem(QString map)
{
    qDebug() << map;

    QStringList list = map.split("<HSEP>");
    QVariantMap newmap;
    newmap.insert("mystatus", list.at(0));
    newmap.insert("id", list.at(1));
    newmap.insert("title", list.at(2));
    newmap.insert("url", list.at(3));
    newmap.insert("synopsis", list.at(4));
    newmap.insert("cover", list.at(5));
    newmap.insert("counter", list.at(6));
    newmap.insert("started", list.at(7));
    newmap.insert("finished", list.at(8));
    newmap.insert("score", list.at(9));
    newmap.insert("type", list.at(10));
    newmap.insert("itemtype", list.at(11));
    newmap.insert("status", list.at(11));

    return newmap;
}

QString Utils::manageList(QString action, QString list, QString items)
{
    QStringList mlist = list.split(",");
    QStringList mitems = items.split(",");

    for (int i=0; i<mitems.count(); ++i) {
        if (action=="add") mlist.append(mitems.at(i));
        else if (action=="remove") mlist.removeAll(mitems.at(i));
    }
    mlist.removeDuplicates();
    mlist.removeAll("");

    return mlist.join(",");
}

bool Utils::itemInLibrary(QString library, QString id)
{
    QStringList l = library.split(",");
    qDebug() << "Checking " << id << " in library " << library;
    return l.contains(id);
}
