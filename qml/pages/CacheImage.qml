import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    property string imgcache
    property string defaultimage
    property int pWidth: image.paintedWidth

    /*Image {
        id: defaultAvatar
        anchors.fill: parent
        source: defaultimage
        fillMode: Image.PreserveAspectFit
        smooth: true
    }*/

    Rectangle
    {
        id: defaultAvatar
        anchors.fill: parent
        anchors.margins: 1
        color: Qt.darker(Theme.highlightColor, 2.5)
        opacity: image.status!=Image.Ready? 0.75 : 0
        border.color: Theme.highlightColor
        border.width: 1

        Behavior on opacity { NumberAnimation { duration: 500 } }
    }

    Image {
        id: image
        smooth: true
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        source: imgcache

        states: [
            State {
                name: "loaded"; when: image.status==Image.Ready
                PropertyChanges { target: image; opacity: 1; }
            },
            State {
                name: "loading"; when: image.status!=Image.Ready
                PropertyChanges { target: image; opacity: 0; }
            }
        ]

        Connections {
            target: utils

            onImageSavedToCache: {
                if (imgcache===durl) imgcache = dpath
            }
        }

        Behavior on opacity { NumberAnimation { duration: 500 } }

    }
}
