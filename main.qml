import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import QtQuick.Controls.Universal 2.0
import Qt.labs.settings 1.0

import hw.sqlsubjectmodel 1.0

ApplicationWindow {
    id: window
    visible: true
    width: 640
    height: 480
    title: qsTr("Мой Д\З")

    Settings {
        id: settings
        property string style: "Universal"
    }

    header: ToolBar {
        Material.foreground: "white"

        RowLayout {
            spacing: 20
            anchors.fill: parent

            ToolButton {
                contentItem: Image {
                    fillMode: Image.Pad
                    horizontalAlignment: Image.AlignHCenter
                    verticalAlignment: Image.AlignVCenter
                    source: "qrc:/images/drawer.png"
                }
                onClicked: drawer.open()
            }

            Label {
                id: titleLabel
                text: qsTr("Мой Д\З")
                font.pixelSize: 20
                elide: Label.ElideRight
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
            }

            ToolButton {
                contentItem: Image {
                    fillMode: Image.Pad
                    horizontalAlignment: Image.AlignHCenter
                    verticalAlignment: Image.AlignVCenter
                    source: "qrc:/images/menu.png"
                }
                onClicked: optionsMenu.open()

                Menu {
                    id: optionsMenu
                    x: parent.width - width
                    transformOrigin: Menu.TopRight

                    MenuItem {
                        text: "Settings"
                        onTriggered: settingsPopup.open()
                    }
                    MenuItem {
                        text: "Rules"
                        onTriggered: aboutDialog.open()
                    }
                }
            }
        }
    }

    Drawer {
        id: drawer
        width: Math.min(window.width, window.height) / 3 * 2
        height: window.height

        ListView {
            id: listView
            currentIndex: -1
            anchors.fill: parent
            model: SqlSubjectModel {}
            delegate: ItemDelegate {
                width: parent.width
                text: model.subject
                highlighted: ListView.isCurrentItem
                onClicked: {
                    if (listView.currentIndex != index) {
                        listView.currentIndex = index
                        titleLabel.text = model.subject

                    }
                    stackView.replace("qrc:/tasks.qml", { inConversationWith: model.id })
                    drawer.close()
                }
            }

            ScrollIndicator.vertical: ScrollIndicator { }
        }
    }

    StackView {
        id: stackView
        anchors.fill: parent
        //initialItem: Subjects{}
        initialItem: Pane {
            id: pane

            //            Image {
            //                id: logo
            //                width: pane.availableWidth / 2
            //                height: pane.availableHeight / 2
            //                anchors.centerIn: parent
            //                anchors.verticalCenterOffset: -50
            //                fillMode: Image.PreserveAspectFit
            //                source: "qrc:/images/qt-logo.png"
            //            }

            Label {
                text: qsTr("<h1>:)</h1>
                            <h1>Добро пожаловать в Мой Д\З!</h1>
                            <h2><font color='grey'>ЗАМЕЧАНИЕ:<h2>
                            <p><font size='50' color='grey' face='arial'>- Отредактируйте перед сдачей!
                            <p><font color='grey'>- После скачивания всю ответственность несете вы сами!
                            <p><font color='grey'>- Можете попросить у администраторов сделать Д\З [$] !
                            <p><font color='grey'>- Скрытые источники не должны быть обсуждены - просто изменить хорошенько и сдать!")
                anchors.margins: 20
                anchors.fill: parent
                verticalAlignment: Label.AlignVCenter
                wrapMode: Label.Wrap

            }

            //            Image {
            //                id: arrow
            //                source: "qrc:/images/arrow.png"
            //                anchors.left: parent.left
            //                anchors.bottom: parent.bottom
            //            }
        }
    }

    Popup {
        id: settingsPopup
        x: (window.width - width) / 2
        y: window.height / 6
        width: Math.min(window.width, window.height) / 3 * 2
        height: settingsColumn.implicitHeight + topPadding + bottomPadding
        modal: true
        focus: true

        contentItem: ColumnLayout {
            id: settingsColumn
            spacing: 20

            Label {
                text: "Settings"
                font.bold: true
            }

            RowLayout {
                spacing: 10

                Label {
                    text: "Style:"
                }

                ComboBox {
                    id: styleBox
                    property int styleIndex: -1
                    model: ["Default", "Material", "Universal"]
                    Component.onCompleted: {
                        styleIndex = find(settings.style, Qt.MatchFixedString)
                        if (styleIndex !== -1)
                            currentIndex = styleIndex
                    }
                    Layout.fillWidth: true
                }
            }

            Label {
                text: "Restart required"
                color: "#e41e25"
                opacity: styleBox.currentIndex !== styleBox.styleIndex ? 1.0 : 0.0
                horizontalAlignment: Label.AlignHCenter
                verticalAlignment: Label.AlignVCenter
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            RowLayout {
                spacing: 10

                Button {
                    id: okButton
                    text: "Ok"
                    onClicked: {
                        settings.style = styleBox.displayText
                        settingsPopup.close()
                    }

                    Material.foreground: Material.primary
                    Material.background: "transparent"
                    Material.elevation: 0

                    Layout.preferredWidth: 0
                    Layout.fillWidth: true
                }

                Button {
                    id: cancelButton
                    text: "Cancel"
                    onClicked: {
                        styleBox.currentIndex = styleBox.styleIndex
                        settingsPopup.close()
                    }

                    Material.background: "transparent"
                    Material.elevation: 0

                    Layout.preferredWidth: 0
                    Layout.fillWidth: true
                }
            }
        }
    }

    Popup {
        id: aboutDialog
        modal: true
        focus: true
        x: (window.width - width) / 2
        y: window.height / 6
        width: Math.min(window.width, window.height) / 3 * 2
        contentHeight: aboutColumn.height

        Column {
            id: aboutColumn
            spacing: 20

            Label {
                text: "About"
                font.bold: true
            }

            Label {
                width: aboutDialog.availableWidth
                text: "The Qt Quick Controls 2 module delivers the next generation user interface controls based on Qt Quick."
                wrapMode: Label.Wrap
                font.pixelSize: 12
            }

            Label {
                width: aboutDialog.availableWidth
                text: "In comparison to the desktop-oriented Qt Quick Controls 1, Qt Quick Controls 2 "
                      + "are an order of magnitude simpler, lighter and faster, and are primarily targeted "
                      + "towards embedded and mobile platforms."
                wrapMode: Label.Wrap
                font.pixelSize: 12
            }
        }
    }
}

