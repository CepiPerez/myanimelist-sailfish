import QtQuick 2.0
import Sailfish.Silica 1.0
import MyAnimeList 1.0
import "pages"

ApplicationWindow
{
    id: appWindow

    initialPage: loginPage
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    API { id: api }
    Utils { id: utils }
    MainPage { id: mainPage }
    Login { id: loginPage }

    signal animeRemoved(string removedid)
    signal mangaRemoved(string removedid)

    property string myAnimeLibrary
    property string myMangaLibrary

    ListModel { id: animeModel }
    ListModel { id: mangaModel }

    Connections {
        target: api

        onAddToListDone: {
            //myAnimeLibrary = animedata
            //myMangaLibrary = mangadata
            console.log("anime: " + myAnimeLibrary)
            console.log("manga: " + myMangaLibrary)
            utils.checkImages()
        }
    }

    function getAnimeStatus(text) {
        if (text==="1") return qsTr("Watching")
        else if (text==="2") return qsTr("Completed")
        else if (text==="3") return qsTr("On hold")
        else if (text==="4") return qsTr("Dropped")
        else if (text==="6") return qsTr("Plan to watch")
        else return text
    }

    function removeAnimeItem(anime) {
        for (var i=0; i<animeModel.count; ++i) {
            var old = animeModel.get(i)
            if (old.id===anime.id) {
                animeModel.remove(i)
                break
            }
        }
    }

    function addAnimeItem(anime) {
        animeModel.insert(0, anime)
    }


    function getMangaStatus(text) {
        if (text==="1") return qsTr("Reading")
        else if (text==="2") return qsTr("Completed")
        else if (text==="3") return qsTr("On hold")
        else if (text==="4") return qsTr("Dropped")
        else if (text==="6") return qsTr("Plan to read")
        else return text
    }

    function removeMangaItem(manga) {
        for (var i=0; i<mangaModel.count; ++i) {
            var old = mangaModel.get(i)
            if (old.id===manga.id) {
                mangaModel.remove(i)
                break
            }
        }
    }

    function addMangaItem(manga) {
        mangaModel.insert(0, manga)
    }
}


