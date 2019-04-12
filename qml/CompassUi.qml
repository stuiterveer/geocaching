import QtQuick 2.5

Item {
    id: compassui

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter

    function setBearing(headingIn)
    {
        backRotation.angle = Math.round(headingIn)
    }

    function setDirection(headingIn)
    {
        roseRotation.angle = Math.round(headingIn)
    }

    Item {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        Image {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            height: units.gu(40)
            width: units.gu(40)
            fillMode: Image.PreserveAspectFit
            source: "../assets/compass_underlay.png"
        }

        Image {
            id: bgrose;
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            height: units.gu(40)
            width: units.gu(40)
            fillMode: Image.PreserveAspectFit
            source: "../assets/compass_rose.png"

            transform: Rotation {
                id: roseRotation
                angle: 0
                origin.x: background.width / 2
                origin.y: background.height / 2
                Behavior on angle {
                    SpringAnimation {
                        spring: 2
                        damping: 0.2
                        modulus: 360
                    }
                }
            }
        }

        Image {
            id: background;
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            height: units.gu(40)
            width: units.gu(40)
            fillMode: Image.PreserveAspectFit
            source: "../assets/compass_arrow.png"

            transform: Rotation {
                id: backRotation
                angle: 0
                origin.x: background.width / 2
                origin.y: background.height / 2
                Behavior on angle {
                    SpringAnimation {
                        spring: 2
                        damping: 0.2
                        modulus: 360
                    }
                }
            }
        }
    }
}