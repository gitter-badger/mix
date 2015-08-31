import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.3
import QtQuick.Dialogs 1.2
import Qt.labs.settings 1.0
import "js/TransactionHelper.js" as TransactionHelper
import "js/NetworkDeployment.js" as NetworkDeploymentCode
import "js/QEtherHelper.js" as QEtherHelper
import org.ethereum.qml.QEther 1.0

ColumnLayout
{
	property bool defaultGasPrice
	property variant gasPrice

	function init(value)
	{
		gasPriceInput.value = QEtherHelper.createEther(value, QEther.Wei)
		gasPriceDefault.value = QEtherHelper.createEther(value, QEther.Wei)
		gasPrice = QEtherHelper.createEther(value, QEther.Wei)
		gasPriceInput.formatInput()
	}

	Component.onCompleted:
	{
		gasPriceDefaultCheckbox.checked = defaultGasPrice
	}

	RowLayout
	{
		Layout.fillWidth: true
		CheckBox
		{
			id: gasPriceDefaultCheckbox
			onCheckedChanged:
			{
				gasPriceInput.readOnly = checked
				if (checked)
					gasPrice = gasPriceDefault.value
				else
					gasPrice = gasPriceInput.value
				gasPriceChanged()
			}
		}

		Label
		{
			text: qsTr("Default:")
		}

		Ether
		{
			id: gasPriceDefault
			displayUnitSelection: false
			displayFormattedValue: true
			edit: false

			function toHexWei()
			{
				return "0x" + gasPriceDefault.value.toWei().hexValue()
			}
		}
	}

	RowLayout
	{
		Layout.fillWidth: true
		Label
		{
			text: qsTr("Yours:")
		}

		Ether
		{
			id: gasPriceInput
			displayUnitSelection: true
			displayFormattedValue: false
			edit: true
			readOnly: true
			function toHexWei()
			{
				return "0x" + gasPriceInput.value.toWei().hexValue()
			}
		}
	}

	Connections
	{
		target: gasPriceInput
		onValueChanged:
		{
			update()
		}
		onAmountChanged:
		{
			update()
		}
		onUnitChanged:
		{
			update()
		}

		function update()
		{
			if (!gasPriceDefaultCheckbox.checked)
			{
				gasPrice = gasPriceInput.value
				gasPriceChanged()
			}
		}
	}
}


