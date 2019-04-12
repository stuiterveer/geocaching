import io.thp.pyotherside 1.5
import QtPositioning 5.9
import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import Ubuntu.Components 1.3

MainView {
    id: mainView
    objectName: "mainView"
    applicationName: "geocaching.evilbunny"

    width: units.gu(50)
    height: units.gu(80)

    property string username
    property string password
    property string cacheid
    property var lastCoords
    property var direction
    property bool updateMap: false

    ListModel {
        id: listModel
    }

    Component.onCompleted: {
        pytest.call("util.getAuth", [], function(results) {
            mainView.username = results[0]
            mainView.password = results[1]

            mainView.lastCoords = QtPositioning.coordinate(-33.8665593, 151.2086631)
            loadAuth()
        })        
    }

    function loadMap()
    {
        stack.push(Qt.resolvedUrl("MapScreen.qml"))
    }

    function loadAuth()
    {
        stack.push(Qt.resolvedUrl("AuthScreen.qml"))
    }

    function loadDetails()
    {
        stack.push(Qt.resolvedUrl("Details.qml"))
    }

    function loadCompass()
    {
        stack.push(Qt.resolvedUrl("Compass.qml"))
    }
    
    function loadLogVisit()
    {
        stack.push(Qt.resolvedUrl("LogVisit.qml"))
    }

    function loadShare()
    {
        stack.push(Qt.resolvedUrl("Share.qml"))
    }

    function loadSearch()
    {
        stack.push(Qt.resolvedUrl("Search.qml"))
    }

    ToastManager {
        id: toast
    }

    PageStack {
        id: stack
    }

    Python {
        id: pytest
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../py/'))
            importModule("util", function() {});
        }
    }

    function from_decimal(deg, ll) {
        var sign = ""
        
        if(deg >= 0)
            var degrees = Math.floor(deg)
        else
            var degrees = Math.ceil(deg)

        var minutes = round((deg - degrees) * 60, 3)

        if(ll == "lat")
        {
            if(degrees < 0)
                sign = "S"
            else
                sign = "N"
        } else {
            if(degrees < 0)
                sign = "W"
            else
                sign = "E"
        }

        return sign + " " + Math.abs(degrees) + "° " + Math.abs(minutes) + "'"
    }

    function to_decimal(deg, min) {
        return round(deg + min / 60, 5)
    }

    function round(num, places) {
        return Math.round(num * Math.pow(10, places)) / Math.pow(10, places)
    }
}
