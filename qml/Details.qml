import io.thp.pyotherside 1.5
import QtLocation 5.9
import QtPositioning 5.9
import QtQuick 2.6
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2

Page {
    id: detailsPage
    
    width: parent.width
    height: parent.height

    property var coord1
    property var rot13hint: ""
    property var hintshowing: false

    header: ToolBar {
        id: toolBar
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
            ToolButton {
                width: units.gu(5)
                height: units.gu(5)
                contentItem: Image {
                    fillMode: Image.PreserveAspectFit
                    source: "../assets/details_menu.png"
                    sourceSize.width: units.gu(4.5)
                    sourceSize.height: units.gu(4.5)
                }
                onClicked: {
                    menuPopup.open()
                }
            }
        }
    }

    Popup {
        id: menuPopup
        padding: 10
        width: units.gu(31)
        // height: units.gu(30.85)
        height: units.gu(25.8)
        x: parent.width - width
        // y: toolBar.bottom
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        Rectangle {
            id: firstMenu
            border.color: "#000000"
            border.width: 1
            anchors.top: parent.top
            width: parent.width
            height: units.gu(5)

            Label {
                width: parent.width
                anchors.centerIn: parent
                height: units.gu(4.9)
                font.pixelSize: units.gu(4)
                text: "Compass"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    menuPopup.close()
                    mainView.loadCompass()
                }
            }
        }

        Rectangle {
            id: secondMenu
            border.color: "#000000"
            border.width: 1
            anchors.top: firstMenu.bottom
            width: parent.width
            height: units.gu(5)

            Label {
                anchors.centerIn: parent
                width: parent.width
                height: units.gu(4.9)
                font.pixelSize: units.gu(4)
                text: "Navigation"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    menuPopup.close()
                    Qt.openUrlExternally("geo:" + detailsPage.coord1.latitude + "," + detailsPage.coord1.longitude + "?z=18")
                }
            }
        }

        Rectangle {
            id: thirdMenu
            border.color: "#000000"
            border.width: 1
            anchors.top: secondMenu.bottom
            width: parent.width
            height: units.gu(5)

            Label {
                anchors.centerIn: parent
                width: parent.width
                height: units.gu(4.9)
                font.pixelSize: units.gu(4)
                text: "Log Visit"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    menuPopup.close()
                    mainView.loadLogVisit()
                }
            }
        }

        Rectangle {
            id: fourthMenu
            border.color: "#000000"
            border.width: 1
            anchors.top: thirdMenu.bottom
            width: parent.width
            height: units.gu(5)

            Label {
                anchors.centerIn: parent
                width: parent.width
                height: units.gu(4.9)
                font.pixelSize: units.gu(4)
                text: "Open in Browser"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    menuPopup.close()
                    Qt.openUrlExternally("https://www.geocaching.com/geocache/" + mainView.cacheid)
                }
            }
        }

        Rectangle {
            id: fifthMenu
            border.color: "#000000"
            border.width: 1
            anchors.top: fourthMenu.bottom
            width: parent.width
            height: units.gu(5)

            Label {
                anchors.centerIn: parent
                width: parent.width
                height: units.gu(4.9)
                font.pixelSize: units.gu(4)
                text: "Share Cache"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    menuPopup.close()
                    mainView.loadShare()
                }
            }
        }

        // Rectangle {
        //     id: sixthMenu
        //     border.color: "#000000"
        //     border.width: 1
        //     anchors.top: fifthMenu.bottom
        //     width: parent.width
        //     height: units.gu(5)

        //     Label {
        //         anchors.centerIn: parent
        //         width: parent.width
        //         height: units.gu(4.9)
        //         font.pixelSize: units.gu(4)
        //         text: "Nearby Caches"
        //     }

        //     MouseArea {
        //         anchors.fill: parent
        //         onClicked: {
        //             menuPopup.close()
        //             stack.pop()
        //         }
        //     }
        // }
    }

    SwipeView {
        id: swipeView
        anchors.fill: parent
        currentIndex: tabBar.currentIndex

        Item {
            id: firstPage
            width: swipeView.width
            height: swipeView.height

            Rectangle {
                anchors.fill: parent

                GridLayout {
                    id: gridLayout
                    width: parent.width
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
                    color: "#666666"
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
                    color: "#666666"
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
            }
        }

        Item {
            id: secondPage
            width: swipeView.width
            height: swipeView.height
            Flickable {
                id: view
                anchors.fill: parent
                width: parent.width
                contentWidth: swipeView.width
                contentHeight: shortDesc.height + longDesc.height + sepRect3.height + hintlabel.height + hintText.height + units.gu(5)
                maximumFlickVelocity: 25000

                Rectangle {
                    id: frame
                    width: parent.width
                    anchors.fill: parent

                    Label {
                        id: shortDesc
                        width: parent.width
                        textFormat: Text.StyledText
                        wrapMode: Label.WordWrap
                        font.pixelSize: units.gu(2.5)
                    }

                    Label {
                        id: longDesc
                        anchors.top: shortDesc.bottom
                        width: parent.width
                        wrapMode: Label.WordWrap
                        textFormat: Text.RichText
                        font.pixelSize: units.gu(2.5)
                    }

                    Rectangle {
                        id: sepRect3
                        width: parent.width
                        height: units.gu(1)
                        color: "#666666"
                        anchors.top: longDesc.bottom
                        anchors.margins: units.gu(1)
                    }

                    Label {
                        id: hintlabel
                        width: parent.width
                        anchors.top: sepRect3.bottom
                        text: "Hint:"
                        font.pixelSize: units.gu(3)
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                console.log("hintText clicked")
                                hintText.text = rot13()
                            }
                        }
                    }

                    Label {
                        id: hintText
                        width: parent.width
                        anchors.top: hintlabel.bottom
                        wrapMode: Label.WordWrap
                        textFormat: Text.StyledText

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                console.log("hintText clicked")
                                hintText.text = rot13()
                            }
                        }
                    }
                }
            }

            ScrollBar {
                id: verticalScrollBar
                width: 12
                height: view.height-12
                anchors.right: view.right
                opacity: 0
                orientation: Qt.Vertical
                position: view.visibleArea.yPosition
            }
        }

        Item {
            id: thirdPage
            width: swipeView.width
            height: swipeView.height

            Rectangle {
                z: detailsPage.z + 1
                color: "#FFFFFF"
                anchors.fill: parent
                width: parent.width

                ListView {
                    anchors.fill: parent
                    width: parent.width
                    model: logModel
                    delegate: logDelegate
                }
            }

        }
    }

    footer: TabBar {
        id: tabBar
        height: units.gu(2.4)
        currentIndex: swipeView.currentIndex

        TabButton {
            text: "Details"
        }
        TabButton {
            text: "Description"
        }
        TabButton {
            text: "Logbook"
        }
    }

    ListModel {
        id: logModel
    }

    Component {
        id: logDelegate

        GridLayout {
            columns: 3

            Text {
                Layout.columnSpan: 3
                text: username
                font.pixelSize: units.gu(2.5)
                font.bold: true
            }

            Text {
                id: metaCol
                text: metacol
                font.pixelSize: units.gu(2)
                width: units.gu(15)
                Layout.alignment: Qt.AlignTop | Qt.AlignRight
                horizontalAlignment: Text.AlignRight
            }

            Rectangle {
                Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
                height: metaCol.height
                width: units.gu(1) / 2
                color: fnfcolor
            }

            Text {
                text: logtext
                font.pixelSize: units.gu(2)
                Layout.maximumWidth: units.gu(33)
                wrapMode: Text.WordWrap
                textFormat: Text.RichText
            }

            Rectangle {
                Layout.columnSpan: 3
                height: units.gu(1)
                color: fnfcolor
            }
        }
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
        updateLogBooks()
    }
    
    function updateLogBooks() {
        pytest.call("util.getJsonLogs", [mainView.cacheid], function(results) {
            var JsonArray = JSON.parse(results)
            for(var i in JsonArray) {
                var JsonObject = JsonArray[i]
                var fnfcolor = "#f0e442"

                switch(JsonObject['logtype']) {
                    case "Found it":
                        fnfcolor = "#3eb34f"
                        break
                    case "Didn't find it":
                        fnfcolor = "#ed3146"
                        break
                    case "Temporarily Disable Listing":
                        JsonObject['logtype'] = "Disabled"
                        break
                    case "Owner Maintenance":
                        JsonObject['logtype'] = "Maintainance"
                        break
                    case "Enable Listing":
                        JsonObject['logtype'] = "Enabled"
                        break
                    case "Publish Listing":
                        JsonObject['logtype'] = "Published"
                        break
                }

                var images = JsonObject['images']
                for(var i in images) {
                    var img = images[i]

                    if(img['name'] != '')
                        JsonObject['logtext'] += "<br>\n<br>\n<img src='" + img['filename'] + "'/><br>\nPhoto: " + img['name']
                    else if(img['Descr' != ''])
                        JsonObject['logtext'] += "<br>\n<br>\n<img src='" + img['filename'] + "'/><br>\nPhoto: " + img['descr']
                    else
                        JsonObject['logtext'] += "<br>\n<br>\n<img src='" + img['filename'] + "'/>"
                }

                logModel.append({"username": JsonObject['username'],
                                    "metacol": JsonObject['visited'] + "\n" + JsonObject['logtype'] + "\n" + JsonObject['findcount'] + " caches",
                                    "logtext": JsonObject['logtext'], "fnfcolor": fnfcolor})
            }
        })
    }

    function r(a,b) {
        return++b?String.fromCharCode((a<"["?91:123)>(a=a.charCodeAt()+13)?a:a-26):a.replace(/[a-zA-Z]/g,r)
    }

    function rot13() {
        if(detailsPage.hintshowing) {
            detailsPage.hintshowing = false
            return detailsPage.rot13hint.replace("\n", "<br>\n")
        }

        detailsPage.hintshowing = true
        return r(detailsPage.rot13hint).replace("\n", "<br>\n")
    }

    function updateScreen() {
        pytest.call("util.getJsonRow", [mainView.cacheid], function(results) {
            var JsonObject = JSON.parse(results)
            if(JsonObject["cacheid"] != mainView.cacheid) {
                print(mainView.cacheid)
                print(JsonObject["cacheid"])
                mainView.loadMap()
                return
            }

            headerTitle.text = JsonObject["cachename"]
            detailsPage.coord1 = QtPositioning.coordinate(JsonObject["lat"], JsonObject["lon"])
            try {
                var distance = Math.round(mainView.lastCoords.distanceTo(detailsPage.coord1)) + "m"
                var azimuth = mainView.lastCoords.azimuthTo(detailsPage.coord1)
                console.log(mainView.cacheid + ": " + distance + ", azimuth: " + azimuth)
                distanceText.text = distance + " @ " + Math.round(azimuth) + "°"
            } catch (error) {
                console.log(error)
            }
            headingText.text = JsonObject['cachename']
            locText.text = mainView.from_decimal(JsonObject['lat'], 'lat') + " - " + mainView.from_decimal(JsonObject['lon'], 'lon')
            typeText.text = JsonObject['cachetype']
            sizeText.text = JsonObject['cachesize']
            cacheidText.text = mainView.cacheid
            diffText.text = JsonObject['diff'] + " / 5.0"
            terrText.text = JsonObject['terr'] + " / 5.0"
            ownerText.text = JsonObject['cacheowner']
            hintText.text = JsonObject['hint'].replace("\n", "<br>\n")
            detailsPage.rot13hint = JsonObject['hint']
            detailsPage.hintshowing = false

            var a = new Date(JsonObject['hidden'] * 1000);
            var months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
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

            shortDesc.text = JsonObject["short"]
            longDesc.text = JsonObject["body"]
            storedText.text = "Stored in device: " + showAge(JsonObject["dltime"])

            pytest.call("util.getJsonAttributes", [mainView.cacheid], function(results) {
                var JsonArray = JSON.parse(results)
                var tmp = []
                for(var i in JsonArray) {
                    var line = convertIcon(JsonArray[i])
                    tmp[i] = line
                }

                listview.model = tmp

                busyIndicator.running = false
            })
        })
    }

    function convertIcon(line) {
        var filename = "../assets/attribute_" + line.toLowerCase() + ".png"
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

    BusyIndicator {
        id: busyIndicator
        z: detailsPage.z + 6
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