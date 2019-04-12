import io.thp.pyotherside 1.5
import QtLocation 5.9
import QtPositioning 5.9
import QtQuick 2.6
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import QtSensors 5.9
import Ubuntu.Components 1.3

Page {
    id: detailsPage

    header: ToolBar {
        width: parent.width
        height: units.gu(7)
        RowLayout {
            anchors.fill: parent
            ToolButton {
                width: units.gu(5)
                height: units.gu(5)
                font.pixelSize: units.gu(5)
                text: qsTr(" ‹ ")
                onClicked: stack.pop()
            }
            Label {
                id: headerTitle
                elide: Label.ElideRight
                horizontalAlignment: Qt.AlignLeft
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
                font.pixelSize: units.gu(3)
            }
            ToolButton {
                width: units.gu(5)
                height: units.gu(5)
                contentItem: Image {
                    fillMode: Image.PreserveAspectFit
                    source: "../assets/compass.png"
                    sourceSize.width: units.gu(4.5)
                    sourceSize.height: units.gu(4.5)
                }
                onClicked: mainView.loadCompass()
            }
        }
    }

    property var coord1

    GridLayout {
        anchors.top: header.bottom
        width: parent.width
        id: gridLayout
        columns: 2

        Label {
            width: units.gu(3)
            horizontalAlignment: Text.AlignRight
            text: "Cache Name: "
        }

        Text {
            id: headingText
            width: units.gu(5)
            wrapMode: Text.Wrap
            elide: Text.ElideRight
            font.bold: true
        }

        Label {
            horizontalAlignment: Text.AlignRight
            text: "Cache Type: "
        }

        Text {
            width: parent.width
            id: typeText
        }

        Label {
            horizontalAlignment: Text.AlignRight
            text: "Cache Size: "
        }

        Text {
            width: parent.width
            id: sizeText
        }

        Label {
            horizontalAlignment: Text.AlignRight
            text: "Cache ID: "
        }

        Text {
            width: parent.width
            id: cacheidText
        }

        Label {
            horizontalAlignment: Text.AlignRight
            text: "Distance: "
        }

        Text {
            width: parent.width
            id: distanceText
        }

        Label {
            horizontalAlignment: Text.AlignRight
            text: "Difficulty: "
        }

        Text {
            width: parent.width
            id: diffText
        }

        Label {
            horizontalAlignment: Text.AlignRight
            text: "Terrain: "
        }

        Text {
            width: parent.width
            id: terrText
        }

        Label {
            horizontalAlignment: Text.AlignRight
            text: "Owner: "
        }

        Text {
            width: parent.width
            id: ownerText
        }

        Label {
            horizontalAlignment: Text.AlignRight
            text: "Hidden: "
        }

        Text {
            width: parent.width
            id: hiddenText
        }

        Label {
            horizontalAlignment: Text.AlignRight
            text: "Last Found: "
        }

        Text {
            width: parent.width
            id: lastFoundText
        }

        Label {
            horizontalAlignment: Text.AlignRight
            text: "Cache Location: "
        }

        Text {
            width: parent.width
            id: locText
        }
    }

    Rectangle {
        id: sepRect
        width: parent.width
        height: units.gu(1) / 5
        color: UbuntuColors.graphite
        anchors.top: gridLayout.bottom
        anchors.margins: units.gu(1)
    }

    ListView {
        id: listview
        height: units.gu(5)
        width: parent.width
        anchors.top: sepRect.bottom
        orientation: ListView.Horizontal
        flickableDirection: Flickable.HorizontalFlick
        boundsBehavior: Flickable.StopAtBounds
        delegate: Image {
            width: units.gu(5)
            height: units.gu(5)
            source: modelData
        }
    }

    Rectangle {
        id: sepRect2
        width: parent.width
        height: units.gu(1) / 5
        color: UbuntuColors.graphite
        anchors.top: listview.bottom
        anchors.margins: units.gu(1)
    }

    Label {
        id: storedText
        anchors.top: sepRect2.bottom
        anchors.left: parent.left
        width: parent.width / 2
        
    }

    Image {
        id: deleteIcon
        source: "../assets/delete.png"
        anchors.top: sepRect2.bottom
        anchors.right: parent.right
        width: units.gu(3.5)
        height: units.gu(3.5)

        MouseArea {
            anchors.fill: parent
            onClicked: {
                console.log("delete clicked")
            }
        }
    }

    Image {
        source: "../assets/refresh.png"
        anchors.top: sepRect2.bottom
        anchors.right: deleteIcon.left
        width: units.gu(3.5)
        height: units.gu(3.5)
        MouseArea {
            anchors.fill: parent
            onClicked: {
                busyIndicator.running = true
                pytest.call("util.refreshCache", [mainView.cacheid], function(results) {
                    updateScreen()
                    busyIndicator.running = false
                })
            }
        }
    }

    BusyIndicator {
        id: busyIndicator
        z: detailsPage.z + 6
        width: units.gu(20)
        height: units.gu(20)
        anchors.centerIn: parent
        running: false
    }

    PositionSource {
        id: positionSource
        active: true
        updateInterval: 1000
        // preferredPositioningMethods: PositionSource.SatellitePositioningMethods

        onPositionChanged: {
            if(isNaN(position.coordinate.longitude) || isNaN(position.coordinate.latitude)) {
                headerTitle.text = "Waiting for a GPS fix..."
                return
            }

            mainView.direction = mainView.lastCoords.azimuthTo(position.coordinate)
            mainView.lastCoords = position.coordinate
            headerTitle.text = "coords: " + mainView.from_decimal(position.coordinate.latitude, "lat") + " - " + 
                               mainView.from_decimal(position.coordinate.longitude, "lon")

            var distance = Math.round(position.coordinate.distanceTo(detailsPage.coord1)) + "m"
            var azimuth = Math.round(position.coordinate.azimuthTo(detailsPage.coord1))

            console.log(mainView.cacheid + ": " + distance + ", azimuth: " + position.coordinate.azimuthTo(detailsPage.coord1))
            distanceText.text = distance + " @ " + Math.round(azimuth) + "°"
        }

        onSourceErrorChanged: {
            if (sourceError == PositionSource.NoError)
                return

            console.log("Source error: " + sourceError)
        }
    }

    Component.onCompleted: {
        updateScreen()
    }

    function updateScreen() {
        pytest.call("util.getJsonRow", [mainView.cacheid], function(results) {
            var JsonObject = JSON.parse(results)
            if(JsonObject["cacheid"] != mainView.cacheid) {
                mainView.loadMap()
                return
            }

            headerTitle.text = JsonObject["cachename"]
            detailsPage.coord1 = QtPositioning.coordinate(JsonObject["lat"], JsonObject["lon"])
            var distance = Math.round(mainView.lastCoords.distanceTo(detailsPage.coord1)) + "m"
            var azimuth = mainView.lastCoords.azimuthTo(detailsPage.coord1)
            console.log(mainView.cacheid + ": " + distance + ", azimuth: " + azimuth)

            headingText.text = JsonObject['cachename']
            locText.text = mainView.from_decimal(JsonObject['lat']) + " - " + mainView.from_decimal(JsonObject['lon'])
            typeText.text = JsonObject['cachetype']
            sizeText.text = JsonObject['cachesize']
            cacheidText.text = mainView.cacheid
            distanceText.text = distance + " @ " + Math.round(azimuth) + "°"
            diffText.text = JsonObject['diff'] + " / 5.0"
            terrText.text = JsonObject['terr'] + " / 5.0"
            ownerText.text = JsonObject['cacheowner']

            var a = new Date(JsonObject['hidden'] * 1000);
            var months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
            var year = a.getFullYear();
            var month = months[a.getMonth()];
            var date = a.getDate();
            hiddenText.text = date + " " + month + " " + year

            if(JsonObject['lastfound'] > 0) {
                var a = new Date(JsonObject['lastfound'] * 1000);
                var year = a.getFullYear();
                var month = months[a.getMonth()];
                var date = a.getDate();
                lastFoundText.text = date + " " + month + " " + year
            }

            storedText.text = "Stored in device: " + showAge(JsonObject["dltime"])

            pytest.call("util.getJsonAttributes", [mainView.cacheid], function(results) {
                var JsonArray = JSON.parse(results)
                var tmp = []
                for(var i in JsonArray) {
                    var line = convertIcon(JsonArray[i])
                    tmp[i] = line
                }

                listview.model = tmp
            })
        })
    }

    function convertIcon(line) {
        var filename = "../assets/attribute_" + line + ".png"
        return filename
    }

    function showAge(dlage)
    {
        var age = 0

        if(dlage < 3600)
            age = Math.round(dlage / 60) + " minutes ago"
        else if(dlage < 86400)
            age = Math.round(dlage / 3600) + " hours ago"
        else
            age = Math.round(dlage / 86400) + " days ago"

        return age
    }

    Python {
        id: pytest
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../py/'))
            importModule("util", function() {});
        }
    }
}