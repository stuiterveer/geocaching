import io.thp.pyotherside 1.5
import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import Ubuntu.Components 1.3

Page {
    id: authPage
    width: parent.width
    height: parent.height

    header: PageHeader {
        title: "Geocaching.com Login"
    }

    ColumnLayout {
        spacing: units.gu(1)
        width: parent.width
        anchors.centerIn: parent

        TextField {
            id: login
            Layout.fillWidth: true
            placeholderText: "Username"
        }

        onVisibleChanged: {
            if(visible) {
                login.forceActiveFocus()
                login.cursorPosition = login.text.length
            }
        }

        TextField {
            id: password
            Layout.fillWidth: true
            placeholderText: "Password"
            echoMode: TextInput.PasswordEchoOnEdit
        }

        Component.onCompleted: {
            login.text = mainView.username
            password.text = mainView.password
        }

        Button {
            id: proccessButton
            Layout.fillWidth: true
            text: "Login"
            color: "#3EB34F"
            onClicked: {
                busyIndicator.running = true
                proccessButton.enabled = false
                data.text = "Please wait, attempting to log in."
                pytest.call("util.gclogin", [login.text, password.text], function(results) {
                    proccessButton.enabled = true
                    busyIndicator.running = false
                    if(results[0] == 1)
                    {
                        data.text = "Login accepted"
                        mainView.loadMap()
                    } else {
                        data.text = "Login details are incorrect, try again."
                    }
                })
            }
        }

        TextArea {
            id: data
            text: "Not logged in."
            readOnly: true
            Layout.fillWidth: true
        }
    }

    BusyIndicator {
        id: busyIndicator
        z: authPage.z + 6
        width: units.gu(20)
        height: units.gu(20)
        anchors.centerIn: parent
        running: false
    }

    Python {
        id: pytest
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../py/'))
            importModule("util", function() {});
        }
    }
}