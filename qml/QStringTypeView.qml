import QtQuick 2.0
import QtQuick.Controls 1.1

Item
{
	property alias value: textinput.text
	property alias readOnly: textinput.readOnly
	id: editRoot
	width: 350

	function init()
	{
		textinput.cursorPosition = 0
	}

	DebuggerPaneStyle {
		id: dbgStyle
	}

	DefaultTextField {
		anchors.verticalCenter: parent.verticalCenter
		id: textinput
		selectByMouse: true
		text: value
		width: 350
		MouseArea {
			id: mouseArea
			anchors.fill: parent
			hoverEnabled: true
			onClicked: textinput.forceActiveFocus()
		}
	}
}



