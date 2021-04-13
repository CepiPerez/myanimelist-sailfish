import QtQuick 2.0
import Sailfish.Silica 1.0
import MyAnimeList 1.0

Page {
    property bool working: false


    Connections {
        target: api

        onLoginResult: {
            working = false
            if (result==="ok") {
                pageStack.replace(mainPage)
                api.getList(api.accountUsername(), "anime")
                api.getList(api.accountUsername(), "manga")
            }
        }
    }

    Component.onCompleted: {
        if (api.accountUsername()!=="") {
            working = true
            userField.text = api.accountUsername()
            passField.text = api.accountPassword()
            api.login(api.accountUsername(), api.accountPassword())
        }
    }


    PageHeader {
        id: header
        title: qsTr("MyAnimeList")
    }

    BusyIndicator {
        id: indicator
        anchors.left: parent.left
        anchors.leftMargin: Theme.paddingLarge
        anchors.verticalCenter: header.verticalCenter
        size: BusyIndicatorSize.Small
        visible: working
        running: visible
    }


    Column {
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.paddingLarge

        /*Label {
            color: "white"
            text: qsTr("Username")
        }*/

        TextField {
            id: userField
            width: parent.width
            placeholderText: qsTr("Username")
            label: qsTr("Username")
            enabled: !working
        }

        /*Label {
            color: "white"
            text: qsTr("Password")
        }*/

        TextField {
            id: passField
            width: parent.width
            echoMode: TextInput.Password
            placeholderText: qsTr("Password")
            label: qsTr("Password")
            enabled: !working
        }

        Item { width: parent.width; height: 10 }

        Button {
            id: logBtn
            //width: 300
            text: qsTr("Login")
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingMedium
            enabled: !working
            onClicked: {
                if (userField.text.trim()==="" || passField.text.trim()==="")
                    return;

                working = true
                api.login(userField.text, passField.text)
            }
        }

    }



}
