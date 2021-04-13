import QtQuick 2.0
import Sailfish.Silica 1.0
import MyAnimeList 1.0

Page {
    id: mainPage

    property variant anime
    property bool working: false
    property string newstatus
    property bool inLybrary: false

    Connections {
        target: api

        onReadError: {
            working = false
        }
        onItemAdded: {
            myAnimeLibrary = utils.manageList("add", myAnimeLibrary, anime.id)
            var newanime = newstatus + "<HSEP>" + anime.id + "<HSEP>" + anime.title + "<HSEP>"
                           + anime.url + "<HSEP>" + anime.synopsis + "<HSEP>" + anime.cover + "<HSEP>"
                           + anime.counter + "<HSEP>" + anime.started + "<HSEP>" + anime.finished + "<HSEP>"
                           + anime.score + "<HSEP>" +  anime.type + "<HSEP>" + anime.itemtype
                           + "<HSEP>" +  anime.status

            anime = utils.updateItem(newanime)
            removeAnimeItem(anime)
            addAnimeItem(anime)
        }
        onItemDeleted: {
            myAnimeLibrary = utils.manageList("remove", myAnimeLibrary, anime.id)
            removeAnimeItem(anime)
            working = false
            pageStack.pop()
        }
        onDetailsDownloaded: {
            working = false
            synopsis.text = itemdata.synopsis
            score.text = qsTr("Score: ") + itemdata.score
            data.text = itemdata.type + "\n"
                        + qsTr("%1 episodes").arg(itemdata.counter) + "\n"
                        + itemdata.status
        }
    }

    onStatusChanged: {
        if (status === PageStatus.Activating) {
            if (anime.synopsis==="") {
                console.log("Getting item details")
                working = true
                api.getItemDetails("anime", anime.id)
            } else {
                working = false
            }

            inLybrary = utils.itemInLibrary(myAnimeLibrary, anime.id)
        }
    }

    function processAction(action) {
        if (!inLybrary) {
            newstatus = action
            api.getAddItem("anime", anime.id, action)
        } else {
            if (action==="remove") {
                api.getDeleteItem("anime", anime.id)
            } else {
                newstatus = action
                api.getUpdateItem("anime", anime.id, action)
            }
        }
    }


    SilicaFlickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: column1.height + Theme.paddingLarge
        clip: true

        opacity: statusSelection.open? 0.3 : 1
        enabled: !statusSelection.open

        Behavior on opacity { FadeAnimation {} }

        PullDownMenu {
            visible: inLybrary

            MenuItem {
                text: qsTr("Remove from library")
                visible: inLybrary
                onClicked: processAction("remove")
            }
        }



        Column {
            id: column1
            anchors.top: parent.top
            anchors.left: parent.left
            width: parent.width
            anchors.leftMargin: 0
            spacing: Theme.paddingLarge

            PageHeader {
                id: header
                title: anime.title
            }

            Image {
                height: 480
                width: 480
                anchors.horizontalCenter: parent.horizontalCenter
                fillMode: Image.PreserveAspectFit
                smooth: true
                source: utils.getCacheImage(anime.cover)
            }

            BusyIndicator {
                id: indicator
                anchors.horizontalCenter: parent.horizontalCenter
                size: BusyIndicatorSize.Medium
                visible: working
                running: visible
            }

            Label {
                id: data
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingLarge
                width: parent.width -Theme.paddingLarge*2
                horizontalAlignment: Text.AlignHCenter
                //font.pixelSize: 18
                color: Theme.primaryColor
                visible: !working
                text: anime.type + "\n"
                      + qsTr("%1 episodes").arg(anime.counter) + "\n"
                      + anime.status
            }

            Label {
                id: synopsis
                text: anime.synopsis
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingLarge
                width: parent.width -Theme.paddingLarge*2
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                color: Theme.secondaryColor
                visible: !working
            }

            Label {
                id: score
                text: qsTr("Score: ") + anime.score
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingLarge
                width: parent.width -Theme.paddingLarge*2
                horizontalAlignment: Text.AlignHCenter
                visible: !working
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: inLybrary? getAnimeStatus(anime.mystatus) : qsTr("Add to Library")
                visible: !working
                onClicked: {
                    statusSelection.open = true
                }
            }
        }
    }

    ListModel {
        id: optionsModel
        ListElement{name: QT_TR_NOOP("Watching"); action:"1" }
        ListElement{name: QT_TR_NOOP("Completed"); action:"2" }
        ListElement{name: QT_TR_NOOP("On hold"); action:"3" }
        ListElement{name: QT_TR_NOOP("Dropped"); action:"4" }
        ListElement{name: QT_TR_NOOP("Plan to watch"); action:"6" }
        ListElement{name: QT_TR_NOOP("Remove from library"); action:"remove" }
    }

    MouseArea {
        anchors.fill: parent
        enabled: statusSelection.open
        onClicked: statusSelection.open = false
    }

    DockedPanel {
        id: statusSelection

        width: mainPage.isPortrait? mainPage.width : mainPage.height //-Theme.itemSizeSmall
        height: mainPage.isPortrait? panelFlick.contentHeight : mainPage.height
        dock: mainPage.isPortrait? Dock.Bottom : Dock.Right
        open: false
        opacity: open? 1 : 0

        Behavior on opacity { FadeAnimation {} }

        Behavior on y {
            NumberAnimation {
                id: verticalMoving
                duration: 250; easing.type: Easing.InOutQuad
            }
        }

        Rectangle {
            anchors.fill: parent
            color: Qt.darker(Theme.highlightColor, 2.5)
            opacity: 0.7
        }

        SilicaFlickable {
            id: panelFlick
            anchors.fill: parent
            contentHeight: column.height + Theme.paddingMedium
            clip: true

            Column {
                id: column
                width: parent.width

                Label {
                    id: panelTitle
                    text: qsTr("Change status")
                    font.pixelSize: Theme.fontSizeLarge
                    color: Theme.highlightColor
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    height: Theme.itemSizeLarge
                }

                SilicaListView {
                    width: parent.width
                    height: optionsModel.count *Theme.itemSizeExtraSmall
                    model: optionsModel
                    visible: model.action!=="remove" || inLybrary
                    interactive: false

                    delegate: ListItem {
                        contentHeight: Theme.itemSizeExtraSmall
                        width: parent.width
                        Label {
                            text: model.name
                            width: parent.width
                            anchors.verticalCenter: parent.verticalCenter
                            horizontalAlignment: Text.AlignHCenter
                        }
                        onClicked: {
                            statusSelection.open = false
                            processAction(model.action)
                        }
                    }
                }
            }

        }



    }


}
