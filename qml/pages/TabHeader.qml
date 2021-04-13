import QtQuick 2.1
import Sailfish.Silica 1.0
import MyAnimeList 1.0

Item {
    id: tabHeader

    // listView must be Silica SlideshowView and have:
    // VisualItemModel as model
    // function - moveToColumn(index)
    // Each children of VisualItemModel must have:
    // properties - busy (bool) and unreadCount (int)
    // method - positionAtTop()
    property SlideshowView listView: null
    property variant iconArray: []
    property int visibleHeight: flickable.contentY + height
    property bool checkSecure: false
    property bool useText: false
    property real labelSize: Theme.fontSizeLarge
    //signal tabClicked(int number)

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        contentHeight: parent.height

        /*Image {
            id: background
            anchors.fill: parent
            source: "image://theme/graphic-header"
        }*/

        Row {
            anchors.fill: parent

            Repeater {
                id: sectionRepeater
                model: iconArray
                delegate: BackgroundItem {

                    width: tabHeader.width / sectionRepeater.count
                    height: tabHeader.height

                    Image {
                        id: icon
                        height: Theme.itemSizeLarge/2
                        width: height
                        smooth: true
                        anchors.centerIn: parent
                        source: modelData
                        visible: !useText
                    }

                    Label {
                        id: labelText
                        anchors.centerIn: parent
                        color: Theme.highlightColor
                        font.pixelSize: labelSize
                        text: listView.model.children[index].pageTitle
                        visible: useText
                    }

                    onClicked: {
                        if (listView.currentIndex!==index) {
                            if (listView.count>2)
                                listView.currentIndex = index
                            else if (listView.currentIndex<index)
                                listView.incrementCurrentIndex()
                            else
                                listView.decrementCurrentIndex()

                        }
                    }
                }
            }
        }

        Rectangle {
            id: currentSectionIndicator
            anchors.bottom: parent.bottom
            color: Theme.highlightColor
            height: Theme.paddingSmall
            width: tabHeader.width / sectionRepeater.count
            x: listView.currentIndex * width

            Behavior on x {
                NumberAnimation {
                    duration: 200
                }
            }
        }

    }
}
