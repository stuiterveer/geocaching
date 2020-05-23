import io.thp.pyotherside 1.5
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import Ubuntu.Components 1.3
import Ubuntu.Content 1.3

Page {
    id: sharePage
    width: parent.width
    height: parent.height

    property var lat
    property var lon

    header: PageHeader {
        title: i18n.tr("Share ") + cacheid + i18n.tr(" with a contact")
    }

    ColumnLayout {
        spacing: units.gu(1)
        width: parent.width
        anchors.top: header.bottom

        Label {
            text: i18n.tr("Select url to put it in the clipboard")
        }

        Button {
            color: "#3EB34F"
            width: parent.width
            Layout.fillWidth: true
            text: "https://www.geocaching.com/geocache/" + cacheid
            onClicked: {
                var mimeData = Clipboard.newData()
                Clipboard.push("https://www.geocaching.com/geocache/" + cacheid)
                toast.show(i18n.tr("Link copied to clipboard!"), 5000)
            }
        }

        Button {
            color: "#3EB34F"
            width: parent.width
            Layout.fillWidth: true
            text: 'http://map.unav.me?' + parseFloat(sharePage.lat).toFixed(5) + ',' + parseFloat(sharePage.lon).toFixed(5)
            onClicked: {
                var mimeData = Clipboard.newData()
                Clipboard.push('http://map.unav.me?' + parseFloat(sharePage.lat).toFixed(5) + ',' + parseFloat(sharePage.lon).toFixed(5))
                toast.show(i18n.tr("Link copied to clipboard!"), 5000)
            }
        }

        Button {
            color: "#3EB34F"
            width: parent.width
            Layout.fillWidth: true
            text: i18n.tr("geo:") + parseFloat(sharePage.lat).toFixed(5) + ',' + parseFloat(sharePage.lon).toFixed(5)
            onClicked: {
                var mimeData = Clipboard.newData()
                Clipboard.push("geo:" + parseFloat(sharePage.lat).toFixed(5) + ',' + parseFloat(sharePage.lon).toFixed(5))
                toast.show(i18n.tr("Link copied to clipboard!"), 5000)
            }
        }

        Button {
            color: "#3EB34F"
            width: parent.width
            Layout.fillWidth: true
            text: parseFloat(sharePage.lat).toFixed(5) + ',' + parseFloat(sharePage.lon).toFixed(5)
            onClicked: {
                var mimeData = Clipboard.newData()
                Clipboard.push(parseFloat(sharePage.lat).toFixed(5) + ',' + parseFloat(sharePage.lon).toFixed(5))
                toast.show(i18n.tr("Link copied to clipboard!"), 5000)
            }
        }
    }

    Component.onCompleted: {
        pytest.call("util.getJsonRow", [cacheid], function(results) {
            var JsonObject = JSON.parse(results)
            if(JsonObject["cacheid"] != cacheid) {
                loadMap()
                return
            }

            sharePage.lat = JsonObject['lat']
            sharePage.lon = JsonObject['lon']
        })
    }

    Python {
        id: pytest
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../py/'))
            importModule("util", function() {})
        }
    }
}