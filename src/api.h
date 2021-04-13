#ifndef API_H
#define API_H

#include <QQuickItem>

//#include <QHttp>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QDebug>


class API : public QQuickItem
{
    Q_OBJECT

public:
    API(QQuickItem *parent = 0);

    Q_INVOKABLE QString accountUsername();
    Q_INVOKABLE QString accountPassword();

public slots:
    void login(QString username, QString password);
    void getList(QString username, QString specific);
    void getUser(QString username);
    void getAddItem(QString list, QString id, QString status);
    void getUpdateItem(QString list, QString id, QString status);
    void getDeleteItem(QString list, QString id);
    void getItemDetails(QString type, QString id);
    void searchItems(QString type, QString text);

signals:
    void readError();
    void loginResult(QString result);
    void userDataLoaded(QString rusername, QString rcover, QString ravatar);
    void addToAnimeList(QVariantMap ritem);
    void addToMangaList(QVariantMap ritem);
    void addToListDone();
    void detailsDownloaded(QVariantMap itemdata);
    void addToSearchList(QVariantMap ranime);
    void addToSearchListDone();
    void itemAdded();
    void itemDeleted();

private slots:
    void onAuthenticationRequired(QNetworkReply *reply, QAuthenticator *auth);
    void downloaded(QNetworkReply *respuesta);

private:
    QNetworkAccessManager* data1;
    QNetworkReply *reply1;
    QString user, pass, token, action;

};

#endif // API_H
