TARGET = myanimelist

CONFIG += sailfishapp

QT += multimedia xml

SOURCES += src/myanimelist.cpp \
    src/api.cpp \
    src/imagedownloader.cpp \
    src/utils.cpp

OTHER_FILES += qml/myanimelist.qml \
    qml/cover/CoverPage.qml \
    qml/pages/SecondPage.qml \
    rpm/myanimelist.changes.in \
    rpm/myanimelist.spec \
    rpm/myanimelist.yaml \
    translations/*.ts \
    myanimelist.desktop \
    qml/pages/TabHeader.qml \
    qml/pages/AnimeListPage.qml \
    qml/pages/AnimePage.qml \
    qml/pages/Login.qml \
    qml/pages/MangaListPage.qml \
    qml/pages/MangaPage.qml \
    qml/pages/CacheImage.qml \
    qml/pages/MainPage.qml \
    qml/pages/SearchPage.qml

# to disable building translations every time, comment out the
# following CONFIG line
#CONFIG += sailfishapp_i18n
#TRANSLATIONS += translations/myanimelist-de.ts

HEADERS += \
    src/api.h \
    src/imagedownloader.h \
    src/utils.h

images.files = images
images.path = /usr/share/$${TARGET}

qmls.files = qml
qmls.path = /usr/share/$${TARGET}

desktops.files = $${TARGET}.desktop
desktops.path = /usr/share/applications

icons.files = $${TARGET}.png
icons.path = /usr/share/icons/hicolor/86x86/apps

INSTALLS = qmls desktops icons images

