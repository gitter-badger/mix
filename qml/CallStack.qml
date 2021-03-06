import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1

DebugInfoList
{
	id: callStack
	collapsible: true
	title : qsTr("Call Stack")
	enableSelection: true
	itemDelegate:
		Item {
		anchors.fill: parent

		Rectangle {
			anchors.fill: parent
			color: "#4A90E2"
			visible: styleData.selected;
		}

		RowLayout
		{
			id: row
			anchors.fill: parent
			Rectangle
			{
				color: "#f7f7f7"
				Layout.fillWidth: true
				Layout.minimumWidth: 30
				Layout.maximumWidth: 30
				DefaultText {
					anchors.verticalCenter: parent.verticalCenter
					anchors.left: parent.left
					font.family: "monospace"
					anchors.leftMargin: 5
					color: "#4a4a4a"
					text: styleData.row;
					width: parent.width - 5
					elide: Text.ElideRight
				}
			}
			Rectangle
			{
				color: "transparent"
				Layout.fillWidth: true
				Layout.minimumWidth: parent.width - 30
				Layout.maximumWidth: parent.width - 30
				DefaultText {
					anchors.leftMargin: 5
					width: parent.width - 5
					wrapMode: Text.NoWrap
					anchors.left: parent.left
					font.family: "monospace"
					anchors.verticalCenter: parent.verticalCenter
					color: "#4a4a4a"
					text: styleData.value;
					elide: Text.ElideRight
				}
			}
		}

		Rectangle {
			anchors.top: row.bottom
			width: parent.width;
			height: 1;
			color: "#cccccc"
			anchors.bottom: parent.bottom
		}
	}
}
