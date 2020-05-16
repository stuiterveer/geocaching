import io.thp.pyotherside 1.5
import QtLocation 5.9
import QtPositioning 5.9
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import Ubuntu.Components 1.3

Page {
    id: mapPage

    property var gpsLock: false

    header: PageHeader {
        id: listHeader
        title: "Waiting for GPS fix..."

        trailingActionBar {
            actions: [
                Action {
                    iconSource: "../assets/search.svg"
                    text: "Show Search"

                    onTriggered: {
                        loadSearch()
                        updateMap(map.center.latitude, map.center.longitude)
                    }
                },
                Action {
                    iconSource: "../assets/download.svg"
                    text: "Download Caches"

                    onTriggered: {
                        busyIndicator.running = true
                        // var nw = map.toCoordinate(Qt.point(0, 0));
                        // var se = map.toCoordinate(Qt.point(map.width, map.height));
                        // pytest.call("util.get_cache_list2", [nw.latitude, nw.longitude, se.latitude, se.longitude, map.center.latitude, map.center.longitude], function(results) {
                        pytest.call("util.get_cache_list", [map.center.latitude, map.center.longitude], function(results) {
                            updateMap(map.center.latitude, map.center.longitude)
                            busyIndicator.running = false
                        })
                    }
                },
                Action {
                    id: gps
                    iconSource: "../assets/gps_target.svg"
                    text: "GPS Lock"

                    onTriggered: gpsToggle()
                }
            ]
        }
    }

    Plugin {
        id: osmMapPlugin
        name: "osm"
        PluginParameter {
            name: "useragent"
            value: "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.86 Safari/537.36"
        }
        // PluginParameter {
        //     name: "osm.mapping.providersrepository.disabled"
        //     value: true
        // }
        // PluginParameter { name: "osm.mapping.custom.host"; value: "https://map.fosm.org/" }
        // PluginParameter { name: "osm.mapping.copyright"; value: "&copy; by <a href='https://fosm.org'>FOSM.org and contributors</a>" }
    }

    ListModel {
        id: locationModel
    }

    Map {
        id: map

        property int lastX: -1
        property int lastY: -1
        property int pressX: -1
        property int pressY: -1
        property int jitterThreshold: 30

        plugin: osmMapPlugin
        // activeMapType: supportedMapTypes[supportedMapTypes.length - 1]

        width: parent.width
        height: parent.height

        center {
            // Sydney
            latitude: -33.8665593
            longitude: 151.2086631
        }
        zoomLevel: 9

        Component.onDestruction: {
            pytest.call("files.save_config", [map.center.latitude, map.center.longitude, map.zoomLevel, gpsLock], function(results) {})
        }

        MapQuickItem {
            id: map_marker
            sourceItem: nav_icon
            coordinate: positionSource.position.coordinate
            opacity:1.0
            anchorPoint: Qt.point(sourceItem.width / 2, sourceItem.height / 2)
        }

        Image {
            id: nav_icon
            width: units.gu(10)
            height: units.gu(10)
            source: "../assets/my_location_chevron.png"

            transform: Rotation {
                id: mm_rotation
                angle: 0
                origin.x: map_marker.width / 2
                origin.y: map_marker.height / 2
                Behavior on angle {
                    SpringAnimation {
                        spring: 2
                        damping: 0.2
                        modulus: 360
                    }
                }
            }
        }

        MapItemView {
            model: locationModel
            delegate: MapQuickItem {
                id: marker
                coordinate: QtPositioning.coordinate(lat, lon)

                anchorPoint.x: image.width * 0.5
                anchorPoint.y: image.height

                sourceItem: Column {
                    Image { id: image; source: getMapMarker(cachetype); width: units.gu(5); height: units.gu(5) }
                    Text { text: title; font.bold: true }
                }

                MouseArea {
                    id: idMyMouseArea;
                    acceptedButtons: Qt.LeftButton
                    parent: marker
                    anchors.fill: parent

                    onPressed: {
                        console.log("marker " + title + " was clicked, lat: " + coordinate.latitude + ", lon: " + coordinate.longitude)
                        cacheid = title
                        map.center = coordinate
                        markerPopup.open()
                    }
                }

                Popup {
                    id: markerPopup
                    padding: 10
                    width: units.gu(37)
                    height: units.gu(28)
                    x: Math.round((parent.width - width) / 2)
                    y: Math.round((parent.height - height) / 2)
                    modal: true
                    focus: true
                    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

                    GridLayout {
                        width: parent.width
                        id: gridLayout
                        columns: 2

                        Label {
                            width: units.gu(5)
                            horizontalAlignment: Text.AlignRight
                            text: "Cache Name: "
                        }

                        Rectangle {
                            clip: true
                            width: units.gu(22)
                            height: headingText.height

                            Label {
                                id: headingText
                                width: parent.width
                                text: heading
                                font.bold: true
                            }
                        }

                        Label {
                            horizontalAlignment: Label.AlignRight
                            text: "Cache Location: "
                        }

                        Text {
                            width: parent.width
                            id: locText
                            text: from_decimal(lat, "lat") + " - " + from_decimal(lon, "lon")
                        }

                        Label {
                            horizontalAlignment: Text.AlignRight
                            text: "Cache Type: "
                        }

                        Text {
                            width: parent.width
                            id: typeText
                            text: type
                        }

                        Label {
                            horizontalAlignment: Text.AlignRight
                            text: "Cache ID: "
                        }

                        Text {
                            width: parent.width
                            id: cacheidText
                            text: title
                        }

                        Label {
                            horizontalAlignment: Text.AlignRight
                            text: "Distance: "
                        }

                        Text {
                            width: parent.width
                            id: distanceText
                            text: dist
                        }

                        Label {
                            horizontalAlignment: Text.AlignRight
                            text: "Difficulty: "
                        }

                        Text {
                            width: parent.width
                            id: diffText
                            text: diff + "/5"
                        }

                        Label {
                            horizontalAlignment: Text.AlignRight
                            text: "Terrain: "
                        }

                        Text {
                            width: parent.width
                            id: terrText
                            text: terr + "/5"
                        }
                    }

                    Button {
                        id: moreDetails
                        anchors.top: gridLayout.bottom
                        text: "More Details"
                        width: parent.width
                        color: "#3eb34f"
                        onClicked: {
                            markerPopup.close()
                            cacheid = title
                            loadDetails()
                        }
                    }

                    Rectangle {
                        id: sepRect
                        width: parent.width
                        height: units.gu(1) / 4
                        color: "#666666"
                        anchors.top: moreDetails.bottom
                        anchors.margins: units.gu(1) / 3
                    }

                    Label {
                        anchors.top: sepRect.bottom
                        anchors.left: parent.left
                        width: parent.width / 2
                        text: "Stored in device: " + showAge(dlage)
                    }

                    Image {
                        id: deleteIcon
                        source: "../assets/delete.png"
                        anchors.top: sepRect.bottom
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
                        anchors.top: sepRect.bottom
                        anchors.right: deleteIcon.left
                        width: units.gu(3.5)
                        height: units.gu(3.5)
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                markerPopup.close()
                                busyIndicator.running = true
                                pytest.call("util.refresh_cache", [title], function(results) {
                                    markerPopup.close()
                                    updateMap(map.center.latitude, map.center.longitude)
                                    busyIndicator.running = false
                                })
                            }
                        }
                    }
                }
            }
        }

        MouseArea {
            id: idModuleMouseDebug;
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            parent: map
            anchors.fill: parent

            property variant lastCoordinate

            onPressed: {
                map.lastX = mouse.x
                map.lastY = mouse.y
                map.pressX = mouse.x
                map.pressY = mouse.y
                lastCoordinate = map.toCoordinate(Qt.point(mouse.x, mouse.y))
            }

            onPositionChanged: {
                if (mouse.button == Qt.LeftButton) {
                    map.lastX = mouse.x
                    map.lastY = mouse.y

                    // var coordinate = map.toCoordinate(Qt.point(map.lastX,map.lastY))
                    // updateMap(coordinate.latitude, coordinate.longitude)
                }
            }

            onDoubleClicked: {
                var mouseGeoPos = map.toCoordinate(Qt.point(mouse.x, mouse.y));
                var preZoomPoint = map.fromCoordinate(mouseGeoPos, false);
                if(mouse.button === Qt.LeftButton) {
                    if(map.zoomLevel < 18)
                        map.zoomLevel = Math.floor(map.zoomLevel + 1)
                } else if (mouse.button === Qt.RightButton) {
                    if(map.zoomLevel > 0)
                        map.zoomLevel = Math.floor(map.zoomLevel - 1)
                }
                var postZoomPoint = map.fromCoordinate(mouseGeoPos, false);
                var dx = postZoomPoint.x - preZoomPoint.x;
                var dy = postZoomPoint.y - preZoomPoint.y;

                var mapCenterPoint = Qt.point(map.width / 2.0 + dx, map.height / 2.0 + dy);
                map.center = map.toCoordinate(mapCenterPoint);

                map.lastX = -1;
                map.lastY = -1;

                pytest.call("files.save_config", [map.center.latitude, map.center.longitude, map.zoomLevel, gpsLock], function(results) {})
            }
        }
    }

    ListModel {
        id: listModel
    }

    BusyIndicator {
        id: busyIndicator
        z: map.z + 6
        width: units.gu(20)
        height: units.gu(20)
        anchors.centerIn: parent
        running: true
    }

    function updateMap(lat, lon)
    {
        console.log("UpdateMap(" + lat + ", " + lon + ")")
        pytest.call("util.get_markers", [], function(results) {
            locationModel.clear()
            var JsonArray = JSON.parse(results)

            for(var i in JsonArray) {
                var JsonObject = JsonArray[i]

                var coord1 = QtPositioning.coordinate(JsonObject["lat"], JsonObject["lon"])
                var distance = 0
                try {
                    distance = Math.round(lastCoords.distanceTo(coord1)) + "m"
                } catch (error) {
                    distance = Math.round(map.center.distanceTo(coord1)) + "m"
                }

                var cacheTitle = JsonObject["cacheid"]
                locationModel.append({lat: JsonObject["lat"], lon: JsonObject["lon"], title: cacheTitle, heading: JsonObject["cachename"],
                                      type: JsonObject["cachetype"] + " (" + JsonObject["cachesize"] + ")", dist: distance,
                                      diff: JsonObject["diff"], terr: JsonObject["terr"], dlage: JsonObject["dltime"],
                                      cachetype: JsonObject["cachetype"]})
            }
        })
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

    function getMapMarker(cachetype) {
        if(cachetype.toLowerCase() == "cache in trash out event")
            var lc = "../assets/marker_type_cito.png"
        else
            var lc = "../assets/marker_type_" + cachetype.toLowerCase().split("-")[0].split(" ")[0] + ".png"
        return lc
    }

    function gpsToggle() {
        if(gpsLock) {
            gpsLock = false
            positionSource.stop()
            gps.iconSource = "../assets/gps_empty.svg"
        } else {
            gpsLock = true
            positionSource.start()
            gps.iconSource = "../assets/gps_target.svg"
        }

        pytest.call("files.save_config", [map.center.latitude, map.center.longitude, map.zoomLevel, gpsLock], function(results) {})
    }

    Timer {
        id: updateMapTimer
        running: true
        repeat: true
        interval: 5000

        onTriggered: {
            if(requestMapUpdate) {
                requestMapUpdate = false
                console.log("Update map")
                updateMap(map.center.latitude, map.center.longitude)
            }
        }
    }

    Timer {
        id: mapTimer
        running: true
        repeat: true
        interval: 1000

        onTriggered: {
            if(isNaN(positionSource.position.coordinate.longitude) || isNaN(positionSource.position.coordinate.latitude))
                return

            if(positionSource.position.coordinate.latitude == 0 && positionSource.position.coordinate.longitude == 0)
                return

            if(positionSource.position.coordinate == map.center)
                return

            header.title = from_decimal(positionSource.position.coordinate.latitude, "lat") + " - " + 
                           from_decimal(positionSource.position.coordinate.longitude, "lon") + ", " + map.zoomLevel

            map_marker.coordinate = positionSource.position.coordinate
            mm_rotation.angle = Math.round(direction)

            if(gpsLock)
            {
                busyIndicator.running = true
                map.center = positionSource.position.coordinate
                updateMap(map.center.latitude, map.center.longitude)
                busyIndicator.running = false
            }
        }
    }

    Python {
        id: pytest
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../py/'))
            importModule("util", function() {});
            importModule("files", function() {});
            call("files.get_config", [], function(results) {
                if(results[2] != "") {
                    map.center = QtPositioning.coordinate(results[0], results[1])
                    map.zoomLevel = results[2]
                    updateMap(map.center.latitude, map.center.longitude)
                    if(results[3] != "") {
                        if(results[3] == 0) {
                            gpsLock = false
                            positionSource.stop()
                            gps.iconSource = "../assets/gps_empty.svg"
                        } else {
                            gpsLock = true
                            positionSource.start()
                            gps.iconSource = "../assets/gps_target.svg"
                        }
                    }
                }
                busyIndicator.running = false
            })
        }
    }
}