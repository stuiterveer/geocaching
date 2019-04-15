import io.thp.pyotherside 1.5
import QtLocation 5.9
import QtPositioning 5.9
import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import Ubuntu.Components 1.3

Page {
    id: compassPage

    header: PageHeader {
        id: compassHeader
        title: "Cache: " + mainView.cacheid
    }

    property var coord1

    Text {
        width: parent.width
        anchors.top: compassHeader.bottom
        horizontalAlignment: Text.AlignHCenter
        id: locText
        text: "Loc Test"
        font.pixelSize: units.gu(3)
    }

    Text {
        width: parent.width
        anchors.top: locText.bottom
        horizontalAlignment: Text.AlignHCenter
        id: dtsText
        text: "DTS Test"
        font.pixelSize: units.gu(3)
    }

    Rectangle {
        id: sepRect
        width: parent.width
        height: units.gu(1) / 4
        color: "#666666"
        anchors.top: dtsText.bottom
        anchors.margins: units.gu(1) / 3
    }

    Text {
        horizontalAlignment: Text.AlignLeft
        anchors.top: sepRect.bottom
        anchors.left: parent.left
        id: degreeText
        text: "degree Test"
        font.pixelSize: units.gu(5)
    }

    Text {
        horizontalAlignment: Text.AlignRight
        anchors.top: sepRect.bottom
        anchors.right: parent.right
        id: distanceText
        text: "dist Test"
        font.pixelSize: units.gu(5)
    }

    CompassUi {
        id: compassui
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: units.gu(40)
        height: units.gu(40)
    }

    Text {
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        anchors.bottom: parent.bottom
        id: curlocText
        text: "curloc Test"
        font.pixelSize: units.gu(3)
    }

    Timer {
        id: compassTimer
        running: true
        repeat: true
        interval: 1000

        onTriggered: {
            if(!isNaN(lastCoords.latitude) && lastCoords.latitude != 0 && lastCoords.longitude != 0) {
                var distance = Math.round(lastCoords.distanceTo(compassPage.coord1)) + "m"
                var azimuth = Math.round(lastCoords.azimuthTo(compassPage.coord1))

                compassui.setDirection(azimuth)
                distanceText.text = distance
                degreeText.text = Math.round(azimuth) + "°"

                compassui.setBearing(Math.floor(direction))
                curlocText.text = from_decimal(lastCoords.latitude, "lat") + " - " + from_decimal(lastCoords.longitude, "lon")
            }
        }
    }

    Component.onCompleted: {
        updateScreen()
    }

    function updateScreen() {
        pytest.call("util.get_json_row", [mainView.cacheid], function(results) {
            var JsonObject = JSON.parse(results)
            if(JsonObject["cacheid"] != mainView.cacheid) {
                stack.pop()
                return
            }

            compassHeader.title = JsonObject["cachename"]
            compassPage.coord1 = QtPositioning.coordinate(JsonObject["lat"], JsonObject["lon"])
            var distance = Math.round(lastCoords.distanceTo(compassPage.coord1)) + "m"
            var azimuth = mainView.lastCoords.azimuthTo(compassPage.coord1)
            console.log(mainView.cacheid + ": " + distance + ", azimuth: " + azimuth)

            locText.text = mainView.from_decimal(JsonObject['lat'], "lat") + " - " + mainView.from_decimal(JsonObject['lon'], "lon")
            distanceText.text = distance
            degreeText.text = Math.round(azimuth) + "°"
            dtsText.text = "D " + JsonObject['diff'] + " - T " + JsonObject['terr'] + " - " + JsonObject['cachesize']
            compassui.setBearing(Math.round(azimuth))
            compassui.setDirection(Math.round(direction))
            curlocText.text =  mainView.from_decimal(lastCoords.latitude, "lat") + " - " + from_decimal(lastCoords.longitude, "lon")
            console.log(mainView.cacheid + ": " + distance + ", azimuth: " + azimuth)
        })
    }

    Python {
        id: pytest
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../py/'))
            importModule("util", function() {});
        }
    }
}