import QtQuick 2.0
import Sailfish.Silica 1.0
import MyAnimeList 1.0

Item {

    property bool working: true
    property string pageTitle: qsTr("Anime")

    height: mainView.height
    width: mainView.width

    Connections {
        target: api

        onAddToAnimeList: {
            myAnimeLibrary = utils.manageList("add", myAnimeLibrary, ritem.id)
            animeModel.append(ritem)
            utils.getCacheImage(ritem.cover, true)
        }
        onReadError: {
            working = false
        }
        onAddToListDone: {
            working = false
        }
    }

    /*PageHeader {
        id: header
        title: qsTr("Anime")
        anchors.top: parent.top
        //anchors.topMargin: currentTheme==="sailfish"? toolBar.height : 0
    }*/

    BusyIndicator {
        id: indicator
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
        visible: working
        running: visible
    }

    /*ImageButton {
        anchors.right: parent.right
        anchors.top: header.top
        height: header.height
        width: 64
        imgsize: 32
        imgsource: currentTheme==="blanco" ? "file:///usr/share/themes/blanco/meegotouch/icons/icon-m-toolbar-refresh-white.png" :
                   "file:///usr/share/themes/sailfish/meegotouch/icons/toolbar/icon-m-toolbar-refresh.png"
        visible: !working
        onClicked: {
            working = true
            animeModel.clear()
            api.getList(api.accountUsername(), "anime")
        }
    }*/

    SilicaListView {
        anchors.fill: parent
        clip: true
        model: animeModel

        delegate: ListItem {
            property string itemtype: "anime"
            contentHeight: Theme.itemSizeExtraLarge
            width: parent.width

            CacheImage {
                id: image
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingLarge
                anchors.verticalCenter: parent.verticalCenter
                width: height*0.7
                height: Theme.itemSizeExtraLarge -Theme.paddingMedium
                imgcache: utils.getCacheImage(model.cover)
                //defaultimage: "file:///usr/share/myanimelist/images/default_anime.png"
            }

            Column {
                anchors.left: image.right
                anchors.leftMargin: Theme.paddingMedium
                anchors.verticalCenter: image.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium
                spacing: Theme.paddingSmall

                Label
                {
                    id: titleText
                    width: parent.width
                    truncationMode: TruncationMode.Fade
                    color: Theme.highlightColor
                    text: model.title
                }

                Label
                {
                    width: parent.width
                    font.pixelSize: titleText.font.pixelSize*0.9
                    truncationMode: TruncationMode.Fade
                    color: Theme.primaryColor
                    text: (itemtype==="anime"? qsTr("Episodes: ") : qsTr("Volumes: ")) + model.counter
                }

                Label
                {
                    width: parent.width
                    font.pixelSize: titleText.font.pixelSize*0.8
                    truncationMode: TruncationMode.Fade
                    color: Theme.secondaryColor
                    text: qsTr("Status: ") + (itemtype==="anime"? getAnimeStatus(model.mystatus) : getMangaStatus(model.mystatus))
                }

            }

            onClicked: {
                pageStack.push("AnimePage.qml", { anime: model })
            }


        }

    }

}
