#include <QtQuick>
#include <sailfishapp.h>
#include <QObject>

#include "api.h"
#include "utils.h"

int main(int argc, char *argv[])
{
    QGuiApplication *app = SailfishApp::application(argc, argv);
    app->setOrganizationName("myanimelist");
    app->setApplicationName("myanimelist");

    QScopedPointer<QQuickView> window(SailfishApp::createView());
    window->setTitle("MyAnimeList");

    //window->rootContext()->setContextProperty("view", window.data());
    //window->rootContext()->setContextProperty("app", app.data());
    window->engine()->addImportPath("/usr/share/myanimelist/qml");

    qmlRegisterType<API>("MyAnimeList", 1, 0, "API");
    qmlRegisterType<Utils>("MyAnimeList", 1, 0, "Utils");

    window->setSource(SailfishApp::pathTo("qml/myanimelist.qml"));

    window->showFullScreen();
    return app->exec();

}

