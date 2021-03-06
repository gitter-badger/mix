import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Dialogs 1.1
import QtQuick.Layouts 1.1
import Qt.labs.settings 1.0
import org.ethereum.qml.QEther 1.0
import "js/Debugger.js" as Debugger
import "js/ErrorLocationFormater.js" as ErrorLocationFormater
import "js/TransactionHelper.js" as TransactionHelper
import "js/QEtherHelper.js" as QEtherHelper
import "."

Rectangle {
	id: root
	property variant tx
	property variant currentState
	property variant bc
	property variant storage
	property var blockIndex
	property var txIndex
	property var callIndex

	property string selectedTxColor: "#accbf2"
	property string selectedBlockForeground: "#445e7f"
	signal updated()

	function clear()
	{
		inputParams.clear()
		returnParams.clear()
		accounts.clear()
		events.clear()
		ctrStorage.clear()
		accounts.visible = false
	}

	function addAccount(address, amount)
	{
		accounts.add(address, amount)
	}

	function updateWidthTx(_tx, _state, _blockIndex, _txIndex, _callIndex)
	{
		accounts.visible = true
		tx = _tx
		blockIndex  = _blockIndex
		txIndex = _txIndex
		callIndex = _callIndex
		currentState = _state
		storage = clientModel.contractStorageByIndex(_tx.recordIndex, _tx.isContractCreation ? _tx.returned : blockChain.getContractAddress(_tx.contractId))
		inputParams.init()
		if (_tx.isContractCreation)
		{
			returnParams.role = "creationAddr"
			returnParams._data = {
				creationAddr : {
				}
			}
			returnParams._data.creationAddr[qsTr("contract address")] = _tx.returned
		}
		else
		{
			returnParams.role = "returnParameters"
			returnParams._data = tx
		}
		returnParams.init()
		accounts.init()
		events.init()
		ctrStorage.init()

		storages.clear()
		searchBox.visible = Object.keys(currentState.contractsStorage).length > 0
		for (var k in currentState.contractsStorage)
			storages.append({ "key": k, "value": currentState.contractsStorage[k].values })
		for (var k = 0; k < storages.count; k++)
			stoRepeater.itemAt(k).init()
		updated()
	}

	color: "transparent"
	radius: 4
	Column {
		anchors.fill: parent
		id: colWatchers
		ListModel
		{
			id: storages
		}

		KeyValuePanel
		{
			height: minHeight
			width: parent.width
			visible: false
			anchors.horizontalCenter: parent.horizontalCenter
			id: accounts
			title: qsTr("Accounts")
			role: "accounts"
			_data: currentState
			function computeData()
			{
				model.clear()
				var ret = []
				if (currentState)
					for (var k in currentState.accounts)
					{
						var label = blockChain.addAccountNickname(k, false)
						if (label === k)
							label = blockChain.addContractName(k) //try to resolve the contract name
						model.append({ "key": label, "value": currentState.accounts[k] })
					}
			}
			onMinimized:
			{
				root.Layout.preferredHeight = root.Layout.preferredHeight - maxHeight
				root.Layout.preferredHeight = root.Layout.preferredHeight + minHeight
			}
			onExpanded:
			{
				root.Layout.preferredHeight = root.Layout.preferredHeight - minHeight
				root.Layout.preferredHeight = root.Layout.preferredHeight + maxHeight
			}
		}

		RowLayout
		{
			id: searchBox
			visible: false
			height: 30
			Image {
				anchors.top: parent.top
				anchors.topMargin: 8
				sourceSize.width: 20
				sourceSize.height: 20
				source: "qrc:/qml/img/searchicon.png"
				fillMode: Image.PreserveAspectFit
			}
			DefaultTextField
			{
				anchors.top: parent.top
				anchors.topMargin: 5
				Layout.preferredWidth: 350
				onTextChanged: {
					for (var k = 0; k < stoRepeater.count; k++)
					{
						var label = storages.get(k).key.split(" - ")
						stoRepeater.itemAt(k).visible = text.trim() === "" || label[0].toLowerCase().indexOf(text.toLowerCase()) !== -1 || label[1].toLowerCase().indexOf(text.toLowerCase()) !== -1
					}
				}
			}
		}

		Repeater
		{
			id: stoRepeater
			model: storages
			KeyValuePanel
			{
				height: minHeight
				width: colWatchers.width
				anchors.horizontalCenter: colWatchers.horizontalCenter
				id: ctrsStorage
				function computeData()
				{
					title = storages.get(index).key
					ctrsStorage.model.clear()
					for (var k in storages.get(index).value)
						ctrsStorage.model.append({ "key": k, "value": JSON.stringify(storages.get(index).value[k]) })
				}
				onMinimized:
				{
					root.Layout.preferredHeight = root.Layout.preferredHeight - maxHeight
					root.Layout.preferredHeight = root.Layout.preferredHeight + minHeight
				}
				onExpanded:
				{
					root.Layout.preferredHeight = root.Layout.preferredHeight - minHeight
					root.Layout.preferredHeight = root.Layout.preferredHeight + maxHeight
				}
			}
		}

		KeyValuePanel
		{
			visible: false
			height: minHeight
			width: parent.width
			anchors.horizontalCenter: parent.horizontalCenter
			id: inputParams
			title: qsTr("INPUT PARAMETERS")
			role: "parameters"
			_data: tx
			onMinimized:
			{
				root.Layout.preferredHeight = root.Layout.preferredHeight - maxHeight
				root.Layout.preferredHeight = root.Layout.preferredHeight + minHeight
			}
			onExpanded:
			{
				root.Layout.preferredHeight = root.Layout.preferredHeight - minHeight
				root.Layout.preferredHeight = root.Layout.preferredHeight + maxHeight
			}
		}

		KeyValuePanel
		{
			visible: false
			height: minHeight
			width: parent.width
			anchors.horizontalCenter: parent.horizontalCenter
			id: returnParams
			title: qsTr("RETURN PARAMETERS")
			role: "returnParameters"
			_data: tx
			onMinimized:
			{
				root.Layout.preferredHeight = root.Layout.preferredHeight - maxHeight
				root.Layout.preferredHeight = root.Layout.preferredHeight + minHeight
			}
			onExpanded:
			{
				root.Layout.preferredHeight = root.Layout.preferredHeight - minHeight
				root.Layout.preferredHeight = root.Layout.preferredHeight + maxHeight
			}
		}

		KeyValuePanel
		{
			visible: false
			height: minHeight
			width: parent.width
			anchors.horizontalCenter: parent.horizontalCenter
			id: ctrStorage
			title: qsTr("CONTRACT STORAGE")
			function computeData()
			{
				model.clear()
				if (storage.values)
					for (var k in storage.values)
						model.append({ "key": k, "value": JSON.stringify(storage.values[k]) })
			}
			onMinimized:
			{
				root.Layout.preferredHeight = root.Layout.preferredHeight - maxHeight
				root.Layout.preferredHeight = root.Layout.preferredHeight + minHeight
			}
			onExpanded:
			{
				root.Layout.preferredHeight = root.Layout.preferredHeight - minHeight
				root.Layout.preferredHeight = root.Layout.preferredHeight + maxHeight
			}
		}

		KeyValuePanel
		{
			visible: false
			height: minHeight
			width: parent.width
			anchors.horizontalCenter: parent.horizontalCenter
			id: events
			title: qsTr("EVENTS")
			function computeData()
			{
				model.clear()
				var ret = []
				for (var k in tx.logs)
				{
					var param = ""
					for (var p in tx.logs[k].param)
					{
						param += " " + tx.logs[k].param[p].value + " "
					}
					param = "(" + param + ")"
					model.append({ "key": tx.logs[k].name, "value": param })
				}
			}
			onMinimized:
			{
				root.Layout.preferredHeight = root.Layout.preferredHeight - maxHeight
				root.Layout.preferredHeight = root.Layout.preferredHeight + minHeight
			}
			onExpanded:
			{
				root.Layout.preferredHeight = root.Layout.preferredHeight - minHeight
				root.Layout.preferredHeight = root.Layout.preferredHeight + maxHeight
			}
		}
	}
}

