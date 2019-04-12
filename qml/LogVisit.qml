import io.thp.pyotherside 1.5
import QtLocation 5.9
import QtPositioning 5.9
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import Ubuntu.Components 1.3

Page {
    id: logVisitPage
    width: parent.width
    height: parent.height

    header: PageHeader {
        title: "Log your vitsit to " + mainView.cacheid
    }

    ComboBox {
        id: control
        anchors.top: header.bottom
        anchors.left: parent.left
        width: parent.width / 2
        height: units.gu(5)
        model: logModel
        font.pixelSize: units.gu(3.5)

        delegate: ItemDelegate {
            width: control.width
            contentItem: Text {
                text: type_text
                textFormat: Text.StyledText
                font.pixelSize: units.gu(3.5)
                verticalAlignment: Text.AlignVCenter
            }
        }

        indicator: Canvas {
            id: canvas
            x: control.width - width - control.rightPadding
            y: control.topPadding + (control.availableHeight - height) / 2
            width: 12
            height: 8
            contextType: "2d"

            Connections {
                target: control
                onPressedChanged: canvas.requestPaint()
            }

            onPaint: {
                context.reset();
                context.moveTo(0, 0);
                context.lineTo(width, 0);
                context.lineTo(width / 2, height);
                context.closePath();
                context.fill();
            }
        }

        contentItem: Text {
            leftPadding: 0
            rightPadding: control.indicator.width + control.spacing

            text: control.displayText
            font.pixelSize: units.gu(3.5)
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        background: Rectangle {
            implicitWidth: 120
            implicitHeight: 40
            border.width: control.visualFocus ? 2 : 1
            radius: 2
        }

        popup: Popup {
            y: control.height - 1
            width: control.width
            implicitHeight: contentItem.implicitHeight
            padding: 1

            contentItem: ListView {
                clip: true
                implicitHeight: contentHeight
                model: control.popup.visible ? control.delegateModel : null
                currentIndex: control.highlightedIndex

                ScrollIndicator.vertical: ScrollIndicator { }
            }

            background: Rectangle {
                radius: 2
            }
        }

        onCurrentIndexChanged: {
            displayText = textAt(currentIndex)
            console.log("Index " + currentIndex + ", changed to => " + textAt(currentIndex))
        }

        Component.onCompleted: {
            pytest.call("util.getLogTypes", [mainView.cacheid], function(results) {
                var JsonArray = JSON.parse(results)
                logModel.clear()
                var jobj = null
                for(var i in JsonArray) {
                    var JsonObject = JsonArray[i]
                    if(jobj == null)
                        jobj = JsonArray[i]
                    logModel.append({"type_text": JsonObject['type_text']})
                }

                displayText = jobj['type_text']
                busyIndicator.running = false
                proccessButton.enabled = true
            })
        }
    }

    ComboBox {
        id: control2
        anchors.top: header.bottom
        anchors.right: parent.right
        width: parent.width / 2
        height: units.gu(5)
        model: ["Today", "Yesterday"]
        font.pixelSize: units.gu(3.5)

        delegate: ItemDelegate {
            width: control2.width
            contentItem: Text {
                text: modelData
                font.pixelSize: units.gu(3.5)
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }
            highlighted: control2.highlightedIndex === index
        }

        indicator: Canvas {
            id: canvas2
            x: control2.width - width - control2.rightPadding
            y: control2.topPadding + (control2.availableHeight - height) / 2
            width: 12
            height: 8
            contextType: "2d"

            Connections {
                target: control2
                onPressedChanged: canvas2.requestPaint()
            }

            onPaint: {
                context.reset();
                context.moveTo(0, 0);
                context.lineTo(width, 0);
                context.lineTo(width / 2, height);
                context.closePath();
                context.fill();
            }
        }

        contentItem: Text {
            leftPadding: 0
            rightPadding: control2.indicator.width + control2.spacing

            text: control2.displayText
            font.pixelSize: units.gu(3.5)
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        background: Rectangle {
            implicitWidth: 120
            implicitHeight: 40
            border.width: control2.visualFocus ? 2 : 1
            radius: 2
        }

        popup: Popup {
            y: control2.height - 1
            width: control2.width
            implicitHeight: contentItem.implicitHeight
            padding: 1

            contentItem: ListView {
                clip: true
                implicitHeight: contentHeight
                model: control2.popup.visible ? control2.delegateModel : null
                currentIndex: control2.highlightedIndex

                ScrollIndicator.vertical: ScrollIndicator { }
            }

            background: Rectangle {
                // border.color: "#21be2b"
                radius: 2
            }
        }
    }

    TextArea {
        id: logText
        anchors.top: control.bottom
        width: parent.width
        font.pixelSize: units.gu(3.5)
        height: units.gu(20)
        placeholderText: "Log Text"
        textFormat: TextArea.PlainText
    }

    Button {
        id: proccessButton
        anchors.top: logText.bottom
        font.pixelSize: units.gu(3.5)
        height: units.gu(5)
        width: parent.width
        Layout.fillWidth: true
        text: "Submit Log"
        color: "#3EB34F"
        enabled: false
        onClicked: {
            if(logText.text == "") {
                toast.show("Log Text can't be blank.", 5000)
                return
            }

            if(control.currentText == "") {
                toast.show("Log Type can't be blank.", 5000)
                return
            }

            busyIndicator.running = true
            proccessButton.enabled = false

            pytest.call("util.logvisit", [mainView.cacheid, control.currentText, control2.currentText, logText.text], function(results) {
                proccessButton.enabled = true
                busyIndicator.running = false
                if(results == true) {
                    toast.show("Log was submitted successfully.")
                    stack.pop()
                    return
                }

                toast.show(results, 5000)
            })
        }
    }

    ListModel {
        id: logModel
    }

    BusyIndicator {
        id: busyIndicator
        z: logVisitPage.z + 6
        width: units.gu(20)
        height: units.gu(20)
        anchors.centerIn: parent
        running: true
    }

    Python {
        id: pytest
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../py/'))
            importModule("util", function() {});
        }
    }
}