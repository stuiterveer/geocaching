import io.thp.pyotherside 1.5
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import Ubuntu.Components 1.3
import Ubuntu.Content 1.3

Page {
    id: searchPage
    width: parent.width
    height: parent.height

    header: PageHeader {
        title: i18n.tr("Search for a cache...")
    }

    onVisibleChanged: {
        if(visible) {
            geocode.forceActiveFocus()
            geocode.cursorPosition = geocode.text.length
        }
    }

    ColumnLayout {
        width: parent.width
        anchors.top: header.bottom

        Label {
            text: i18n.tr("Search for a cache by it's GC code")
        }

        TextField {
            id: geocode
            Layout.fillWidth: true
            text: "GC"
            font.capitalization: Font.AllUppercase
        }

        Button {
            id: proccessButton
            Layout.fillWidth: true
            text: i18n.tr("Search")
            color: "#3EB34F"

            onClicked: {
                busyIndicator.running = true
                proccessButton.enabled = false
                var gc = geocode.text
                gc = gc.toUpperCase();
                cacheid = gc
                pytest.call("util.dl_cache", [geocode.text], function(results) {
                    proccessButton.enabled = true
                    busyIndicator.running = false
                    if(results != true) {
                        toast.show(results, 5000)
                        return
                    } else {
                        requestMapUpdate = true
                        loadDetails()
                        return
                    }
                })
            }
        }
    }

    BusyIndicator {
        id: busyIndicator
        z: searchPage.z + 6
        width: units.gu(20)
        height: units.gu(20)
        anchors.centerIn: parent
        running: false
    }

    Python {
        id: pytest
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../py/'))
            importModule("util", function() {})
        }
    }
}