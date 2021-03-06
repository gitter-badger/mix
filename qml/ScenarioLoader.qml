import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.0
import QtQuick.Dialogs 1.1
import Qt.labs.settings 1.0
import org.ethereum.qml.InverseMouseArea 1.0
import "js/Debugger.js" as Debugger
import "js/ErrorLocationFormater.js" as ErrorLocationFormater
import "."

ColumnLayout
{
	id: blockChainSelector
	signal restored(variant scenario)
	signal saved(variant scenario)
	signal duplicated(variant scenario)
	signal loaded(variant scenario)
	signal renamed(variant scenario)
	signal deleted()
	signal closed()
	property alias selectedScenarioIndex: scenarioList.currentIndex
	property bool panelLoaded: false
	property int btnWidth: 50
	spacing: 0
	function init()
	{
		scenarioList.model = projectModel.stateListModel
		scenarioList.load()
		panelLoaded = true
	}

	function clear()
	{
		scenarioList.model = []
		closed()
		panelLoaded = false
	}

	function needSaveOrReload()
	{
	}

	function updateWidth(_width)
	{
		var w;
		if (_width < btnRowContainer.minimalWidth)
			w = (_width - 180) / 6
		else
			w = 100
		updatebtnWidth(w)
		if (_width < 824)
            btnRowContainer.anchors.horizontalCenter = undefined
        else
            btnRowContainer.anchors.horizontalCenter = btnRowContainer.parent.horizontalCenter
            
		updatebtnWidth(rowBtn.width / 6 < btnWidth ? btnWidth : rowBtn.width / 6)
		scenarioLabel.visible = rowBtn.width / 6 > btnWidth
	}

	function updatebtnWidth(w)
	{
		editScenario.width = w
		deleteScenario.width = w
		duplicateScenario.width = w
		addScenario.width = w
		restoreScenario.width = w
		saveScenario.width = w
		rowBtn.width = 6 * w
	}

	RowLayout
	{
		anchors.horizontalCenter: parent.horizontalCenter
		spacing: 0
		anchors.top: parent.top
		anchors.topMargin: 7
		id: btnRowContainer
		property int minimalWidth: 100 * 6 + 180

		Item
		{
			Layout.preferredWidth: parent.minimalWidth
			Layout.preferredHeight: 40
			Rectangle
			{
				color: "white"
				width: 180
				height: 20
				id: scenarioCont
				anchors.top: parent.top
				Rectangle
				{
					anchors.top: parent.bottom
					anchors.topMargin: 10
					width: parent.width
					DefaultLabel
					{
						text: qsTr("Scenario")
						id: scenarioLabel
						anchors.centerIn: parent
						font.pixelSize: 12
					}
				}

				/*Rectangle
				{
					id: left
					width: 10
					height: parent.height
					anchors.left: parent.left
					anchors.leftMargin: -2
					radius: 15
				}*/

				Connections
				{
					target: projectModel.stateListModel
					onStateDeleted: {
						scenarioList.init()
					}
				}

				ComboBox
				{
					id: scenarioList
					anchors.left: parent.left
					model: projectModel.stateListModel
					anchors.top: parent.top
					textRole: "title"
					height: parent.height
					width: 182
					signal updateView()

					onCurrentIndexChanged:
					{
						restoreScenario.restore()
					}

					function init()
					{
						scenarioList.currentIndex = 0
						deleted()
					}

					function load()
					{
						var state = projectModel.stateListModel.getState(currentIndex)
						if (state)
							loaded(state)
					}

					style: ComboBoxStyle {
						id: style
						background: Rectangle {
							color: "white"
							anchors.fill: parent
						}
						label: Rectangle {
							property alias label: comboLabel
							anchors.fill: parent
							color: "white"
							DefaultLabel {
								Image {
									id: up
									anchors.top: parent.top
									anchors.right: parent.right
									anchors.topMargin: -2
									source: "qrc:/qml/img/up.png"
									width: 10
									height: 10
								}

								Image {
									id: down
									anchors.bottom: parent.bottom
									anchors.bottomMargin: -3
									anchors.right: parent.right
									source: "qrc:/qml/img/down.png"
									width: 10
									height: 10
								}
								id: comboLabel
								maximumLineCount: 1
								elide: Text.ElideRight
								width: parent.width
								anchors.verticalCenter: parent.verticalCenter
								anchors.left: parent.left
								anchors.leftMargin: -4
								anchors.top: parent.top
								font.pixelSize: 11
								Component.onCompleted:
								{
									comboLabel.updateLabel()
								}

								function updateLabel()
								{
									comboLabel.text = ""
									if (scenarioList.currentIndex > - 1 && scenarioList.currentIndex < projectModel.stateListModel.count)
										comboLabel.text = projectModel.stateListModel.getState(scenarioList.currentIndex).title
								}

								Connections {
									target: blockChainSelector
									onLoaded: {
										if (projectModel.stateListModel.count > 0)
											comboLabel.text = projectModel.stateListModel.getState(scenarioList.currentIndex).title
										else
											return ""
									}
									onRenamed: {
										comboLabel.text = scenario.title
										scenarioNameEdit.text = scenario.title
									}
									onDeleted: {
										comboLabel.updateLabel()
									}
									onClosed: {
										comboLabel.text = ""
									}
								}
							}
						}
					}
				}

				DefaultTextField
				{
					id: scenarioNameEdit
					anchors.left: scenarioCont.left
					anchors.top: parent.top
					anchors.leftMargin: -4
					height: parent.height
					z: 5
					font.pixelSize: 11
					visible: false
					width: 190
					Keys.onEnterPressed:
					{
						toggleEdit()
					}

					Keys.onReturnPressed:
					{
						toggleEdit()
					}

					function toggleEdit()
					{
						scenarioList.visible = !scenarioList.visible
						scenarioNameEdit.visible = !scenarioNameEdit.visible
						if (!scenarioNameEdit.visible)
							scenarioNameEdit.save()
						else
						{
							scenarioNameEdit.text = projectModel.stateListModel.getState(scenarioList.currentIndex).title
							scenarioNameEdit.forceActiveFocus()
							outsideClick.active = true
						}
					}

					function save()
					{
						outsideClick.active = false

						for (var k = 0; k < projectModel.stateListModel.count; ++k)
						{
								if (projectModel.stateListModel.get(k).title === scenarioNameEdit.text)
									return //title already exists
						}

						projectModel.stateListModel.getState(scenarioList.currentIndex).title = scenarioNameEdit.text
						projectModel.saveProjectFile()
						saved(state)
						scenarioList.model.get(scenarioList.currentIndex).title = scenarioNameEdit.text
						scenarioList.currentIndex = scenarioList.currentIndex
						renamed(projectModel.stateListModel.getState(scenarioList.currentIndex))
					}

					InverseMouseArea {
						id: outsideClick
						anchors.fill: parent
						active: false
						onClickedOutside: {
							scenarioNameEdit.toggleEdit()
						}
					}
				}

				Rectangle
				{
					width: 10
					height: parent.height
					anchors.right: parent.right
					anchors.rightMargin: -6
					color: "white"
					radius: 15
				}
			}

			Rectangle
			{
				anchors.left: scenarioCont.right
				anchors.leftMargin: 15
				width: btnWidth * 6
				height: 20
				color: "transparent"
				id: rowBtn
				ScenarioButton {
					id: editScenario
					width: btnWidth
					height: parent.height
					sourceImg: "qrc:/qml/img/edittransaction.png"
					onClicked: {
						scenarioNameEdit.toggleEdit()
					}
					text: qsTr("Edit Title")
					roundRight: false
					roundLeft: true
					enabled: panelLoaded
				}

				Rectangle
				{
					width: 1
					height: parent.height
					anchors.right: deleteScenario.left
					color: "#ededed"
				}

				ScenarioButton {
					id: deleteScenario
					enabled: panelLoaded
					width: btnWidth
					height: parent.height
					anchors.left: editScenario.right
					sourceImg: "qrc:/qml/img/delete-block-icon@2x.png"
					onClicked: {
						if (projectModel.stateListModel.count > 1)
							deleteWarning.open()
					}
					text: qsTr("Delete")
					roundRight: false
					roundLeft: false
				}

				MessageDialog
				{
					id: deleteWarning
					text: qsTr("Are you sure to delete this scenario ?")
					onYes:
					{
						projectModel.stateListModel.deleteState(scenarioList.currentIndex)
						scenarioList.init()
					}
					standardButtons: StandardButton.Yes | StandardButton.No
				}

				Rectangle
				{
					width: 1
					height: parent.height
					anchors.right: addScenario.left
					color: "#ededed"
				}

				ScenarioButton {
					id: addScenario
					enabled: panelLoaded
					width: btnWidth
					height: parent.height
					anchors.left: deleteScenario.right
					sourceImg: "qrc:/qml/img/newIcon@2x.png"
					onClicked: {
						var item = projectModel.stateListModel.createDefaultState();
						item.title = qsTr("New Scenario")
						projectModel.stateListModel.appendState(item)
						projectModel.stateListModel.save()
						scenarioList.currentIndex = projectModel.stateListModel.count - 1
						scenarioNameEdit.toggleEdit()
					}
					text: qsTr("New")
					roundRight: false
					roundLeft: false
				}

				Rectangle
				{
					width: 1
					height: parent.height
					anchors.right: restoreScenario.left
					color: "#ededed"
				}

				ScenarioButton {
					id: restoreScenario
					enabled: panelLoaded
					width: btnWidth
					height: parent.height
					anchors.left: addScenario.right
					buttonShortcut: ""
					sourceImg: "qrc:/qml/img/restoreicon@2x.png"
					onClicked: {
						restore()
					}
					text: qsTr("Reset")
					function restore()
					{
						var state = projectModel.stateListModel.reloadStateFromProject(scenarioList.currentIndex)
						if (state)
						{
							restored(state)
							loaded(state)
						}
					}
					roundRight: false
					roundLeft: false
				}

				Rectangle
				{
					width: 1
					height: parent.height
					anchors.right: saveScenario.left
					color: "#ededed"
				}

				ScenarioButton {
					id: saveScenario
					enabled: panelLoaded
					anchors.left: restoreScenario.right
					text: qsTr("Save")
					onClicked: save()
					width: btnWidth
					height: parent.height
					buttonShortcut: ""
					sourceImg: "qrc:/qml/img/saveicon@2x.png"
					roundRight: false
					roundLeft: false

					function save()
					{
						projectModel.saveProjectFile()
						saved(state)
					}
				}

				Connections
				{
					target: clientModel
					onSetupFinished: {
						saveScenario.save()
					}
				}

				Rectangle
				{
					width: 1
					height: parent.height
					anchors.right: duplicateScenario.left
					color: "#ededed"
				}

				ScenarioButton
				{
					id: duplicateScenario
					anchors.left: saveScenario.right
					enabled: panelLoaded
					text: qsTr("Duplicate")
					onClicked: {
						projectModel.stateListModel.duplicateState(scenarioList.currentIndex)
						duplicated(state)
						scenarioList.currentIndex = projectModel.stateListModel.count - 1
						scenarioNameEdit.toggleEdit()
					}
					width: btnWidth
					height: parent.height
					buttonShortcut: ""
					sourceImg: "qrc:/qml/img/duplicateicon@2x.png"
					roundRight: true
					roundLeft: false
				}
			}
		}
	}
}
