import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material  2.0
import QtQuick.Dialogs 1.1

import hw.sqltaskmodel 1.0
import hw.servicemodel 1.0
import hw.solutionsmodel 1.0

Page {
    id: root

    property int inConversationWith
    Connections {
        target: ftp
        onReplyReady :
        {
            if(taskModel.addSolution(url))
            {
                console.log("Success:" + url)
            }
        }
    }


    Component {
        id: sectionHeading
        Rectangle {

            width: listView.width
            height: sectionText.implicitHeight + 10
            color: "transparent"

            Rectangle {
                width: sectionText.implicitWidth + 20
                height: sectionText.implicitHeight + 10
                color: Qt.rgba(0.9,0.9,0.9,0.5)
                anchors.centerIn: parent
                radius: 10
                Text {
                    id: sectionText
                    anchors.centerIn: parent
                    text: qsTr(section)// + " :: Nurnazarov Bahman"
                    font.pixelSize: 10
                    color: "gray"
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 8
            clip: true
            model: SqlTaskModel {
                id: taskModel
                subject: inConversationWith

            }
            delegate: SwipeDelegate {
                id: swipeDelegate
                width: parent.width
                bottomPadding: 0
                rightPadding: 10
                leftPadding: 10
                topPadding: 5

                readonly property bool hasSolution: model.solutions
                contentItem: Row {

                    Rectangle {
                        id: avatar
                        width: 35
                        height: 35
                        color:  "#eeeeee"

                        Label {
                            id: taskNumber
                            anchors.centerIn: parent
                            text: model.task_number
                        }
                        Image {
                            visible: parent.parent.parent.hasSolution
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.margins: 0
                            width: 12
                            height: width
                            source: "qrc:/images/eventindicator.png"
                        }

                    }
                    Column{
                        Rectangle {
                            property bool ready: false//model.task_number%2==0?true:false
                            id: rect
                            width: 	Math.min(taskText.implicitWidth + 45, listView.width - avatar.width-20)
                            height: Math.max(avatar.height,taskText.implicitHeight+20)
                            color:  ready?"green":"#444"

                            Button{
                                text: rect2.visible?"˄":"˅"
                                x: rect.width-width
                                y: rect.height-height
                                visible: descriptionText.text !== ""
                                height: 25
                                width: 25
                                onClicked: rect2.visible=!rect2.visible
                            }

                            TextEdit {
                                id: taskText
                                color: "white"
                                text: model.task
                                font.pixelSize: 12
                                anchors.margins: 10
                                anchors.fill: parent
                                wrapMode: TextEdit.Wrap
                                selectByMouse: true
                            }
                        }
                        Rectangle {
                            id: rect2
                            visible: false
                            width: 	Math.min(descriptionText.implicitWidth + 24, listView.width - avatar.width-20)
                            height: descriptionText.implicitHeight+20
                            color:  "#eeeeee"

                            TextEdit {
                                id: descriptionText
                                text: model.description
                                font.pixelSize: 12
                                color: "grey"
                                anchors.margins: 12
                                anchors.fill: parent
                                wrapMode: TextEdit.Wrap
                                selectByMouse: true
                            }
                        }
                        Label {
                            id: timestampText
                            text: Qt.formatDateTime(model.added_data, "d MMM hh:mm")
                            color: "lightgrey"
                            font.pixelSize: 12
                        }
                        move: Transition {
                            NumberAnimation { properties: "x,y"; duration: 1000 }
                        }
                    }
                }
                onClicked:
                {
                    if (swipe.complete)
                    {
                        if(swipe.position===1)
                        {
                            rect.color="green";

                        }
                        else if(swipe.position===-1)listView.remove(listView.currentIndex)
                    }
                    else if(SwipeDelegate.pressed) console.log("still pressed...");
                }
                onDoubleClicked:{
                    addSolutionPopup.task=model.task_number;
                    addSolutionPopup.taskId=model.id;
                    addSolutionPopup.solutionId=model.solutions;
                    addSolutionPopup.open();
                }

                Component {
                    id: removeComponent

                    Rectangle {
                        color: swipeDelegate.swipe.complete && swipeDelegate.pressed ? "#333" : "#444"
                        width: parent.width
                        height: parent.height
                        clip: true

                        Label {
                            font.pixelSize: swipeDelegate.font.pixelSize
                            text: "Remove"
                            color: "white"
                            anchors.centerIn: parent
                        }
                    }
                }
                Component {
                    id: markComponent

                    Rectangle {
                        color: swipeDelegate.swipe.complete && swipeDelegate.pressed ? "#333" : "#444"
                        width: parent.width
                        height: parent.height
                        clip: true

                        Label {
                            font.pixelSize: swipeDelegate.font.pixelSize
                            text: "Mark as done"
                            color: "white"
                            anchors.centerIn: parent
                        }
                    }
                }
                swipe.left: markComponent
                swipe.right: removeComponent
            }

            ScrollBar.vertical: ScrollBar {}

            section.property: "type"
            section.criteria: ViewSection.FullString
            section.delegate: sectionHeading
            section.labelPositioning: listView.section.labelPositioning |= ViewSection.CurrentLabelAtStart
        }

        Button {
            id: addButton
            Layout.fillWidth: true
            text: qsTr("Add")
            onClicked: {
                addTaskPopup.open()
            }
        }
    }

    Popup {
        id: addTaskPopup
        x: (root.width-width)/2
        y: (root.height-height)/2
        width: root.availableWidth*0.8
        height:  root.availableHeight*0.8
        modal: true
        focus: true

        contentItem: ColumnLayout {
            id: addItemColumn
            spacing: 20

            Label {
                text: "Add task"
                font.bold: true
            }

            TextField {
                id: taskTextField
                text: qsTr("Задание ...")
                Layout.fillWidth: true
                selectByMouse: true
            }

            TextArea {
                id: taskDescriptionArea
                text: qsTr("Комментарий ...")
                Layout.fillWidth: true
                selectByMouse: true
            }

            RowLayout {
                spacing: 10

                Label {
                    text: "Task number:"
                }

                SpinBox {
                    id: taskNumberSpinBox
                    to: 100
                    from: 1
                    value: 1
                }
            }

            RowLayout {
                spacing: 10

                Label {
                    text: "Type:"
                }

                ComboBox {
                    id: typeBox
                    model: ServiceModel {
                        idn: inConversationWith
                    }
                    textRole: "display"
                    Layout.fillWidth: true
                }
            }

            RowLayout {
                spacing: 10

                Button {
                    id: okButton
                    text: "Ok"
                    onClicked: {

                        if(taskModel.addTask(taskTextField.text,taskDescriptionArea.text,taskNumberSpinBox.value,typeBox.currentText))
                        {
                            listView.update();
                            addTaskPopup.close();
                        }
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
                        addTaskPopup.close()
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
        id: addSolutionPopup
        x: (root.width-width)/2
        y: (root.height-height)/2
        width: root.availableWidth*0.8
        height:  root.availableHeight*0.8
        modal: true
        focus: true

        property int task
        property int solutionId
        property int taskId

        contentItem: ColumnLayout {
            spacing: 20

            Label {
                text: addSolutionPopup.task + " task"
                font.bold: true
            }

            ListView {
                id: solutionsListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: 8
                clip: true
                model: SolutionsModel {
                    id:solutionModel
                    idn: addSolutionPopup.solutionId
                }

                delegate: SwipeDelegate {
                    bottomPadding: 0
                    rightPadding: 10
                    leftPadding: 10
                    topPadding: 0
                    id: swipeDelegate2
                    width: parent.width
                    contentItem: Row{
                        spacing: 10
                        Rectangle{
                            width: 40
                            height: 40
                            color: "lightgray"
                            Text {
                                anchors.centerIn: parent
                                text: {
                                    if(ftp.isFileExist(fileName.text))
                                    {
                                        var text=model.display;
                                        text=text.slice(text.lastIndexOf(".")+1);
                                        return text!==""?text:"...";
                                    }
                                    return "˅";
                                }
                            }
                        }
                        Column{
                            Text {
                                anchors.topMargin: 20
                                id: fileName
                                text: {
                                    var text=model.display;
                                    return text.slice(text.lastIndexOf("/")+1);
                                }
                                font.pixelSize: 12

                            }
                            ProgressBar {
                                visible: false
                                id: bar
                                value: 0.5
                                width: parent.parent.width-50
                                height: 20
                            }
                        }


                    }
                    onClicked: {
                       ftp.isFileExist(fileName.text)?Qt.openUrlExternally(ftp.parentDir(fileName.text)):ftp.getFile(model.display)
                    }
                    Component {
                        id: removeComponent

                        Rectangle {
                            color: swipeDelegate2.swipe.complete && swipeDelegate2.pressed ? "#333" : "#444"
                            width: parent.width
                            height: parent.height
                            clip: true

                            Label {
                                font.pixelSize: swipeDelegate2.font.pixelSize
                                text: "Remove"
                                color: "white"
                                anchors.centerIn: parent
                            }
                        }
                    }

                    swipe.left: removeComponent
                    swipe.right: removeComponent
                }

                ScrollBar.vertical: ScrollBar {}
            }

            RowLayout {
                spacing: 10

                Button {
                    id: addSolutionButton
                    text: "Add"
                    onClicked: fileDialog.open()

                    Material.foreground: Material.primary
                    Material.background: "transparent"
                    Material.elevation: 0

                    Layout.preferredWidth: 0
                    Layout.fillWidth: true
                }

                Button {
                    id: cancelSolutionButton
                    text: "Cancel"
                    onClicked: {
                        addSolutionPopup.close()
                    }

                    Material.background: "transparent"
                    Material.elevation: 0

                    Layout.preferredWidth: 0
                    Layout.fillWidth: true
                }
            }
        }
    }

    FileDialog {
        id: fileDialog
        title: "Please choose a file"
        modality: Qt.WindowModal
        selectMultiple: true
        selectFolder: false
        folder: shortcuts.home
        nameFilters: [ "All files (*)" ]
        selectedNameFilter: "All files (*)"

        onAccepted: {
            console.log(fileDialog.fileUrls)
            ftp.executePutting(fileDialog.fileUrls,addSolutionPopup.taskId,addSolutionPopup.solutionId)
        }
        onRejected: {
            console.log("Canceled")
        }
    }
}
