#include "API.h"
#include <QString>
#include <QFileInfo>
#include <QDir>
#include <QNetworkConfigurationManager>
#include <QAuthenticator>
#include <QSettings>
#include <QDateTime>
//#include <meegotouch/MLocale>
#include <QtXml/QDomDocument>
#include <QtXml/QDomElement>


API::API(QQuickItem *parent) : QQuickItem(parent)
{
    data1 = new QNetworkAccessManager(this);

    connect(data1, SIGNAL(finished(QNetworkReply*)), this, SLOT(downloaded(QNetworkReply*)));
    connect(data1, SIGNAL(authenticationRequired(QNetworkReply*,QAuthenticator*)),
                    SLOT(onAuthenticationRequired(QNetworkReply*,QAuthenticator*)));

    QSettings sets("cepiperez", "myanimelist");
    user = sets.value("user", "").toString();
    pass = sets.value("pass", "").toString();
    token = sets.value("token", "").toString();

}

QString API::accountUsername()
{
    QSettings sets("cepiperez", "myanimelist");
    return sets.value("user","").toString();
}

QString API::accountPassword()
{
    QSettings sets("cepiperez", "myanimelist");
    return sets.value("pass","").toString();
}

void API::onAuthenticationRequired(QNetworkReply *reply, QAuthenticator *auth)
{
    auth->setUser(user);
    auth->setPassword(pass);
}

void API::login(QString username, QString password)
{
    user = username;
    pass = password;
    action = "login";
    QString url = "http://myanimelist.net/api/account/verify_credentials.xml";
    reply1 = data1->get(QNetworkRequest(QUrl(url)));
}

void API::getUser(QString username)
{
    action = "get_user";
    QString url = "https://hummingbird.me/api/v1/users/"+username;
    reply1 = data1->get(QNetworkRequest(QUrl(url)));
}

void API::getList(QString username, QString specific)
{
    //specific: anime or manga
    action = "get_list";
    QString url = "http://myanimelist.net/malappinfo.php?u="+username+"&status=all&type="+specific;
    QStringList parameters;
    parameters.append("u=" + username);
    parameters.append("status=all");
    parameters.append("type=" + specific);

    QNetworkRequest request;
    request.setUrl(url);
    request.setRawHeader("Content-Type", "application/x-www-form-urlencoded");
    //request.setRawHeader("WWW-Authenticate", "Basic realm=\"myanimelist.net\"");
    request.setRawHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36");
    reply1 = data1->get(request);
}

void API::getItemDetails(QString type, QString id)
{
    action = "get_details";
    QString url = "http://myanimelist.net/" + type + "/" + id;
    QStringList parameters;
    reply1 = data1->post(QNetworkRequest(QUrl(url)), parameters.join("&").toUtf8());
}

void API::getAddItem(QString list, QString id, QString status)
{
    qDebug() << "Adding anime id: " << id;
    action = "add_anime";
    QString url = "http://myanimelist.net/api/" + list + "list/add/" + id + ".xml";
    QString parameters = "data=<entry><status>" + status + "</status></entry>";
    qDebug() << parameters;
    reply1 = data1->post(QNetworkRequest(QUrl(url)), parameters.toUtf8());
}

void API::getUpdateItem(QString list, QString id, QString status)
{
    qDebug() << "Updating anime id: " << id;
    action = "update_anime";
    QString url = "http://myanimelist.net/api/" + list + "list/update/" + id + ".xml";
    QString parameters = "data=<entry><status>" + status + "</status></entry>";
    qDebug() << parameters;
    reply1 = data1->post(QNetworkRequest(QUrl(url)), parameters.toUtf8());
}

void API::getDeleteItem(QString list, QString id)
{
    qDebug() << "Removing anime id: " << id;
    action = "delete_anime";
    QString url = "http://myanimelist.net/api/" + list + "list/delete/" + id + ".xml";
    QString parameters;
    qDebug() << parameters;
    reply1 = data1->post(QNetworkRequest(QUrl(url)), parameters.toUtf8());
}

void API::searchItems(QString type, QString text)
{
    //qDebug() << "Searching: " << text;
    action = "search_items";
    QString url = "http://myanimelist.net/api/" + type + "/search.xml?q=" + text;
    qDebug() << url;
    reply1 = data1->get(QNetworkRequest(QUrl(url)));
}

void API::downloaded(QNetworkReply *respuesta)
{
    QString datos1 = respuesta->readAll();
    //if (action!="get_details")
        qDebug() << datos1;

    if (respuesta->error() != QNetworkReply::NoError)
    {
        qDebug() << "error: " << respuesta->error();
        if (action=="login") emit loginResult("error");
        else emit readError();

    }
    else if (action=="login")
    {
        token = "";
        QSettings sets("cepiperez", "myanimelist");
        sets.setValue("user", user);
        sets.setValue("pass", pass);
        sets.setValue("token", token);
        sets.sync();
        emit loginResult("ok");
    }
    else if (action=="get_user")
    {
        /*bool ok;
        QVariantMap result = QtJson::Json::parse(datos1, ok).toMap();
        if (ok) {
            QString avatar = result.value("avatar", "").toString();
            QString cover = result.value("cover_image", "").toString();
            QString name = result.value("name", "").toString();
            qDebug() << name << cover << avatar;
            emit userDataLoaded(name, cover, avatar);
        } else {
            return userDataLoaded("", "", "");
        }*/
    }
    else if (action=="get_list")
    {
        QString datatype;
        QDomElement docElem;
        QDomDocument xmldoc;
        xmldoc.setContent(datos1);
        docElem = xmldoc.documentElement();
        QDomNode child = docElem.firstChild();
        while (!child.isNull())
        {
            if (child.toElement().tagName()=="anime" || child.toElement().tagName()=="manga")
            {
                datatype = child.toElement().tagName();
                QVariantMap item;
                for (int i=0; i<child.childNodes().count(); ++i)
                {
                    QDomNode n = child.childNodes().at(i);
                    if (n.toElement().tagName()=="series_animedb_id" || n.toElement().tagName()=="series_mangadb_id")
                        item.insert("id", n.toElement().text());
                    else if (n.toElement().tagName().endsWith("series_title"))
                        item.insert("title", n.toElement().text());
                    else if (n.toElement().tagName().endsWith("series_episodes") || n.toElement().tagName()=="series_volumes")
                        item.insert("counter", n.toElement().text());
                    else if (n.toElement().tagName().endsWith("series_type"))
                        item.insert("type", n.toElement().text());
                    else if (n.toElement().tagName().endsWith("my_status"))
                        item.insert("mystatus", n.toElement().text());
                    else if (n.toElement().tagName().endsWith("series_status"))
                        item.insert("status", n.toElement().text());
                    else if (n.toElement().tagName().endsWith("series_start"))
                        item.insert("started", n.toElement().text());
                    else if (n.toElement().tagName().endsWith("series_end"))
                        item.insert("finished", n.toElement().text());
                    else if (n.toElement().tagName().endsWith("series_image"))
                        item.insert("cover", n.toElement().text());

                }
                item.insert("itemtype", datatype);
                item.insert("synopsis", "");
                item.insert("score", "");
                item.insert("url", "http://myanimelist.net/" + datatype + "/" + item.value("id","").toString());
                //qDebug() << "Appending:" << anime;
                if (datatype=="anime") {
                    emit addToAnimeList(item);
                } else {
                    emit addToMangaList(item);
                }
            }

            child = child.nextSibling();
        }

        emit addToListDone();
    }
    else if (action=="get_details")
    {
        QVariantMap itemdata;

        QString temp;

        //Synopsis
        temp = datos1;
        int i = temp.indexOf("Synopsis</h2>");
        temp.remove(0, i);
        temp.remove("Synopsis</h2>");
        i = temp.indexOf("<");
        temp = temp.left(i);
        itemdata.insert("synopsis", temp.trimmed());

        //Type
        temp = datos1;
        i = temp.indexOf("Type:</span>");
        temp.remove(0, i);
        temp.remove("Type:</span>");
        i = temp.indexOf("<");
        temp = temp.left(i);
        itemdata.insert("type", temp.trimmed());

        //Rating
        temp = datos1;
        i = temp.indexOf("Rating:</span>");
        temp.remove(0, i);
        temp.remove("Rating:</span>");
        i = temp.indexOf("<");
        temp = temp.left(i);
        itemdata.insert("rating", temp.trimmed());

        //Episodes or Chapters
        if (datos1.contains("Episodes:</span>")) {
            temp = datos1;
            i = temp.indexOf("Episodes:</span>");
            temp.remove(0, i);
            temp.remove("Episodes:</span>");
            i = temp.indexOf("<");
            temp = temp.left(i);
            itemdata.insert("counter", temp.trimmed());
        } else {
            temp = datos1;
            i = temp.indexOf("Volumes:</span>");
            temp.remove(0, i);
            temp.remove("Volumes:</span>");
            i = temp.indexOf("<");
            temp = temp.left(i);
            itemdata.insert("counter", temp.trimmed());
        }

        //Status
        temp = datos1;
        i = temp.indexOf("Status:</span>");
        temp.remove(0, i);
        temp.remove("Status:</span>");
        i = temp.indexOf("<");
        temp = temp.left(i);
        itemdata.insert("status", temp.trimmed());

        //Score
        temp = datos1;
        i = temp.indexOf(">Score:</span>");
        temp.remove(0, i);
        temp.remove(">Score:</span>");
        i = temp.indexOf("<");
        temp = temp.left(i);
        itemdata.insert("score", temp.trimmed());

        emit detailsDownloaded(itemdata);

    }
    else if (action=="search_items")
    {
        QString stype;
        QDomElement docElem;
        QDomDocument xmldoc;
        xmldoc.setContent(datos1);
        docElem = xmldoc.documentElement();
        QDomNode child = docElem.firstChild();
        while (!child.isNull())
        {
            if (child.toElement().tagName()=="entry")
            {
                QVariantMap item;
                for (int i=0; i<child.childNodes().count(); ++i)
                {
                    QDomNode n = child.childNodes().at(i);
                    if (n.toElement().tagName()=="id")
                        item.insert("id", n.toElement().text());
                    if (n.toElement().tagName()=="type")
                        item.insert("type", n.toElement().text());
                    else if (n.toElement().tagName()=="title")
                        item.insert("title", n.toElement().text());
                    else if (n.toElement().tagName()=="episodes") {
                        item.insert("counter", n.toElement().text());
                        item.insert("itemtype", "anime");
                        item.insert("url", "http://myanimelist.net/anime/" + item.value("id","").toString());
                    }
                    else if (n.toElement().tagName()=="chapters") {
                        item.insert("counter", n.toElement().text());
                        item.insert("itemtype", "manga");
                        item.insert("url", "http://myanimelist.net/manga/" + item.value("id","").toString());
                    }
                    else if (n.toElement().tagName()=="status")
                        item.insert("status", n.toElement().text());
                    else if (n.toElement().tagName()=="start_date")
                        item.insert("started", n.toElement().text());
                    else if (n.toElement().tagName()=="end_date")
                        item.insert("finished", n.toElement().text());
                    else if (n.toElement().tagName()=="image")
                        item.insert("cover", n.toElement().text());
                    else if (n.toElement().tagName()=="synopsis")
                        item.insert("synopsis", n.toElement().text());
                    else if (n.toElement().tagName()=="score")
                        item.insert("score", n.toElement().text());

                }
                emit addToSearchList(item);
            }
            child = child.nextSibling();
        }

        emit addToSearchListDone();
    }
    else if (action=="add_anime")
    {
        if (datos1.contains("<h1>Created</h1>")) emit itemAdded();
        else if (datos1.toInt()>0) emit itemAdded();
        else emit readError();
    }
    else if (action=="add_anime")
    {
        if (datos1=="Updated") emit itemAdded();
        else emit readError();
    }
    else if (action=="delete_anime")
    {
        if (datos1=="Deleted") emit itemDeleted();
        else emit readError();
    }


}



