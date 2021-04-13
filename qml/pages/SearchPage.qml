import QtQuick 2.0
import Sailfish.Silica 1.0
import MyAnimeList 1.0

Page {

    property bool working: false
    property string searchtype

    Connections {
        target: api

        onAddToSearchList: {
            searchModel.append(ranime)
            utils.getCacheImage(ranime.cover, true)
        }
        onAddToSearchListDone: {
            working = false
            utils.checkImages()
        }
        onReadError: {
            working = false
        }
    }


    PageHeader {
        id: header
        title: qsTr("Search")
        anchors.top: parent.top
    }

    ListModel { id: searchModel }

    BusyIndicator {
        id: indicator
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
        visible: working
        running: visible
    }


    TextField {
        id: searchField
        anchors.top: header.bottom
        anchors.topMargin: Theme.paddingMedium
        anchors.left: parent.left
        anchors.leftMargin: Theme.paddingMedium
        width: parent.width -Theme.paddingMedium*3 -sbutton.width
        placeholderText: qsTr("Enter text to search")
        labelVisible: false
    }

    IconButton {
        id: sbutton
        smooth: true
        anchors.verticalCenter: searchField.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingMedium
        height: Theme.itemSizeExtraSmall
        width: height
        opacity: !working? 1 : 0.5
        icon.source: "image://theme/icon-m-search"
        onClicked: {
            working = true
            searchModel.clear()
            api.searchItems(searchtype, searchField.text)
        }
    }

    SilicaListView {
        anchors.top: searchField.bottom
        anchors.topMargin: Theme.paddingLarge
        anchors.left: parent.left
        width: parent.width
        anchors.bottom: parent.bottom
        clip: true
        model: searchModel

        delegate: ListItem {
            property string itemtype: model.itemtype
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
                    text: qsTr("Status: ") + model.status
                }

            }

            onClicked: {
                if (model.itemtype==="anime")
                    pageStack.push("AnimePage.qml", {anime:model})
                else
                    pageStack.push("MangaPage.qml", {manga:model})
            }



            /*Connections {
                target: appWindow

                onAnimeRemoved: {
                    if (model.id===removedid) {
                        animeModel.remove(model.index)
                    }
                }
            }*/
        }

    }


}
