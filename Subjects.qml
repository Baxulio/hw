import QtQuick 2.6
import QtQuick.Controls 2.1

SwipeDelegate {
    id: control
    text: "ytrtyuiop[oiuytfyguhijokp"
    bottomPadding: 0
    rightPadding: 0
    leftPadding: 0
    topPadding: 0
    spacing: -2
    checked: true

    Component {
        id: component

        Rectangle {
            color: SwipeDelegate.pressed ? "#333" : "#444"
            width: parent.width
            height: parent.height
            clip: true

            Label {
                text: qsTr("Press me!")
                color: "#21be2b"
                anchors.centerIn: parent
            }
        }
    }

    swipe.left: component
    swipe.right: component

    contentItem: Text {
        text: control.text
        transformOrigin: Item.Center
        scale: 1
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        font.pointSize: 37
        font: control.font
        color: control.enabled ? (control.down ? "#17a81a" : "#21be2b") : "#bdbebf"
        elide: Text.ElideRight
        visible: control.text
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter

        Behavior on x {
            enabled: !control.down
            NumberAnimation {
                easing.type: Easing.InOutCubic
                duration: 400
            }
        }
    }
}
