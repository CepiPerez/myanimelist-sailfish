import QtQuick 2.0
import Sailfish.Silica 1.0
import MyAnimeList 1.0

Page {
    id: page
    anchors.fill: parent

    SilicaFlickable {
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: mainView.currentIndex==0? qsTr("Search anime") : qsTr("Search manga")
                onClicked: pageStack.push("SearchPage.qml",
                            {searchtype: mainView.currentIndex==0? "anime" : "manga"})
            }
        }

        IconButton {
            icon.source: "file:///usr/share/myanimelist/images/icon.png"
            height: Theme.itemSizeMedium
            width: height
            icon.height: height/2
            icon.width: icon.height
            anchors { left: parent.left; top: parent.top }
        }

        TabHeader {
            id: header
            height: Theme.itemSizeMedium
            width: parent.width - Theme.itemSizeMedium*2
            labelSize: Theme.fontSizeLarge
            anchors.horizontalCenter: parent.horizontalCenter
            //anchors.top: parent.top
            listView: mainView
            checkSecure: true
            useText: true
            iconArray: ["",""]
        }

        IconButton {
            icon.source: "image://theme/icon-m-refresh"
            height: Theme.itemSizeMedium
            width: height
            icon.height: height/2
            icon.width: icon.height
            anchors { right: parent.right; top: parent.top }
            enabled: !animeListPage.working && !mangaListPage.working
            onClicked: {
                if (mainView.currentIndex==0) {
                    animeListPage.working = true
                    animeModel.clear()
                    api.getList(api.accountUsername(), "anime")
                } else {
                    mangaListPage.working = true
                    mangaModel.clear()
                    api.getList(api.accountUsername(), "manga")
                }
            }
        }


        SlideshowView {
            id: mainView

            anchors.fill: parent
            anchors.topMargin: header.height
            itemWidth: width
            itemHeight: height
            clip: true

            model: VisualItemModel {

                AnimeListPage {
                    id: animeListPage
                }

                MangaListPage {
                    id: mangaListPage
                }

            }

        }

    }
}


