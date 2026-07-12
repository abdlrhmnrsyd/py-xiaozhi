// 主窗口 - 匹配原布局并进行精美视觉重构
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../theme"
import "../components"

AppWindow {
    id: root

    width: 420
    height: 520
    minimumWidth: 360
    minimumHeight: 420
    title: ""
    visible: true

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // 自定义标题栏 - 平台自适应
        TitleBar {
            Layout.fillWidth: true
            showMaximize: true
            showSettingsButton: true  // 启用标题栏设置按钮
            onMinimizeClicked: root.showMinimized()
            onMaximizeClicked: {
                if (root.visibility === Window.FullScreen || root.visibility === Window.Maximized) {
                    root.showNormal()
                } else {
                    root.showMaximized()
                }
            }
            onCloseClicked: {
                if (eventBridge) eventBridge.onQuitRequest()
            }
        }

        // 状态与内容显示区域
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.spacingLg
                spacing: Theme.spacingMd

                // Center floating status pill badge
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: Theme.spacingSm
                    spacing: 0

                    Rectangle {
                        implicitWidth: statusTextItem.implicitWidth + Theme.spacingXl * 2
                        implicitHeight: 32
                        color: Theme.primaryLight
                        radius: 16
                        border.width: 1
                        border.color: Theme.darkMode ? "#3B2E6B" : "#D0E7FF"

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: Theme.spacingSm

                            // pulsing status indicator dot
                            Rectangle {
                                width: 8
                                height: 8
                                radius: 4
                                color: (mainModel && mainModel.connected) ? Theme.success : Theme.error

                                SequentialAnimation on opacity {
                                    running: true
                                    loops: Animation.Infinite
                                    NumberAnimation { to: 0.3; duration: 800 }
                                    NumberAnimation { to: 1.0; duration: 800 }
                                }
                            }

                            Text {
                                id: statusTextItem
                                text: (mainModel && mainModel.statusText) ? mainModel.statusText : "Standby"
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSm
                                font.weight: Font.DemiBold
                                color: Theme.primaryText
                            }
                        }
                    }
                }

                // AI Avatar & Breathing Halo Orb
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 120

                    property string currentEmotionUrl: (mainModel && mainModel.emotionUrl) ? mainModel.emotionUrl : ""

                    // Outer breathing glow ring 1
                    Rectangle {
                        id: glowRing1
                        anchors.centerIn: parent
                        width: Math.max(Math.min(parent.width, parent.height) * 0.65, 120)
                        height: width
                        radius: width / 2
                        color: "transparent"
                        border.width: 2
                        border.color: Theme.primary
                        opacity: (mainModel && (mainModel.statusText === "Listening..." || mainModel.statusText === "Speaking..." || mainModel.statusText === "Thinking...")) ? 0.6 : 0.1

                        Behavior on opacity {
                            NumberAnimation { duration: 300 }
                        }

                        SequentialAnimation on scale {
                            running: glowRing1.opacity > 0.2
                            loops: Animation.Infinite
                            NumberAnimation { to: 1.15; duration: 1500; easing.type: Easing.InOutSine }
                            NumberAnimation { to: 1.0; duration: 1500; easing.type: Easing.InOutSine }
                        }
                    }

                    // Inner breathing glow ring 2
                    Rectangle {
                        id: glowRing2
                        anchors.centerIn: parent
                        width: glowRing1.width - 24
                        height: width
                        radius: width / 2
                        color: Theme.primaryLight
                        opacity: glowRing1.opacity * 0.5

                        Behavior on opacity {
                            NumberAnimation { duration: 300 }
                        }

                        SequentialAnimation on scale {
                            running: glowRing1.opacity > 0.2
                            loops: Animation.Infinite
                            NumberAnimation { to: 0.85; duration: 1500; easing.type: Easing.InOutSine }
                            NumberAnimation { to: 1.0; duration: 1500; easing.type: Easing.InOutSine }
                        }
                    }

                    AnimatedImage {
                        anchors.centerIn: parent
                        width: Math.max(Math.min(parent.width, parent.height) * 0.45, 60)
                        height: width
                        source: parent.currentEmotionUrl
                        fillMode: Image.PreserveAspectFit
                        playing: true
                        visible: parent.currentEmotionUrl.length > 0 && parent.currentEmotionUrl.indexOf("file://") === 0
                    }

                    Text {
                        anchors.centerIn: parent
                        text: parent.currentEmotionUrl.indexOf("file://") !== 0 ? (parent.currentEmotionUrl || "😊") : ""
                        font.pixelSize: 72
                        visible: parent.currentEmotionUrl.indexOf("file://") !== 0
                    }
                }

                // Floating TTS Scrollable Card
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    Layout.leftMargin: Theme.spacingSm
                    Layout.rightMargin: Theme.spacingSm
                    color: Theme.darkMode ? "#141B2D" : "#F1F5F9"
                    radius: Theme.radiusLg
                    border.width: 1
                    border.color: Theme.border

                    ScrollView {
                        anchors.fill: parent
                        anchors.margins: Theme.spacingMd
                        clip: true
                        ScrollBar.vertical.policy: ScrollBar.AsNeeded

                        Text {
                            width: parent.width
                            text: (mainModel && mainModel.ttsText) ? mainModel.ttsText : "I am ready to help. Click 'Start Chat' or 'Hold to Speak' to begin."
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSm
                            color: Theme.textPrimary
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }
        }

        // Modern Control Panel (Bottom)
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            color: "transparent"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.spacingLg
                anchors.topMargin: 0
                spacing: Theme.spacingSm

                // Row 1: Chat Input Bar
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingSm

                    // Pill input field
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 38
                        color: Theme.darkMode ? "#141B2D" : "#F1F5F9"
                        radius: 19
                        border.color: textInput.activeFocus ? Theme.primary : Theme.border
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Theme.spacingMd
                            anchors.rightMargin: 6
                            spacing: Theme.spacingXs

                            TextInput {
                                id: textInput
                                Layout.fillWidth: true
                                verticalAlignment: TextInput.AlignVCenter
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSm
                                color: Theme.textPrimary
                                selectByMouse: true
                                clip: true

                                Text {
                                    anchors.fill: parent
                                    text: "Type a message..."
                                    font: textInput.font
                                    color: Theme.textPlaceholder
                                    verticalAlignment: Text.AlignVCenter
                                    visible: !textInput.text && !textInput.activeFocus
                                }

                                Keys.onReturnPressed: sendText()
                            }

                            // Send Button
                            Button {
                                id: sendBtn
                                Layout.preferredWidth: 28
                                Layout.preferredHeight: 28

                                background: Rectangle {
                                    color: textInput.text.trim().length > 0 ? (sendBtn.pressed ? Theme.primaryPressed : (sendBtn.hovered ? Theme.primaryHover : Theme.primary)) : "transparent"
                                    radius: 14
                                }

                                contentItem: Text {
                                    text: "✈"
                                    font.pixelSize: Theme.fontSizeMd
                                    color: textInput.text.trim().length > 0 ? "white" : Theme.textPlaceholder
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                onClicked: sendText()
                            }
                        }
                    }

                    // Interrupt button
                    Button {
                        id: abortBtn
                        Layout.preferredHeight: 38
                        Layout.preferredWidth: 90
                        text: "Interrupt"
                        visible: mainModel && (mainModel.statusText === "Speaking..." || mainModel.statusText === "Thinking...")

                        background: Rectangle {
                            color: abortBtn.pressed ? Theme.errorHover : Theme.errorLight
                            radius: Theme.radiusMd
                            border.width: 1
                            border.color: Theme.error
                        }

                        contentItem: Text {
                            text: "⏹ " + abortBtn.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSm
                            font.weight: Font.Medium
                            color: Theme.error
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: if (eventBridge) eventBridge.onAbort()
                    }
                }

                // Row 2: Main Voice Action & Mode Toggle
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingSm

                    // Voice primary button
                    Button {
                        id: actionBtn
                        Layout.fillWidth: true
                        Layout.preferredHeight: 42
                        text: (mainModel && mainModel.buttonText) ? mainModel.buttonText : "Hold to Speak"

                        background: Rectangle {
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: actionBtn.pressed ? Theme.primaryPressed : (actionBtn.hovered ? Theme.primaryHover : Theme.primary) }
                                GradientStop { position: 1.0; color: actionBtn.pressed ? Theme.primaryPressed : Theme.primary }
                            }
                            radius: Theme.radiusMd

                            layer.enabled: true
                            layer.effect: DropShadow {
                                transparentBorder: true
                                horizontalOffset: 0
                                verticalOffset: 2
                                radius: 6
                                color: Theme.darkMode ? "#30000000" : "#15000000"
                            }
                        }

                        contentItem: RowLayout {
                            anchors.centerIn: parent
                            spacing: Theme.spacingSm

                            Text {
                                text: (mainModel && mainModel.autoMode) ? "🤖" : "🎤"
                                font.pixelSize: Theme.fontSizeLg
                            }

                            Text {
                                text: actionBtn.text
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSm
                                font.weight: Font.Bold
                                color: "white"
                            }
                        }

                        onClicked: {
                            if (eventBridge) {
                                if (mainModel && mainModel.autoMode) {
                                    eventBridge.onAutoStart()
                                } else {
                                    eventBridge.onManualToggle()
                                }
                            }
                        }
                    }

                    // Mode switch button
                    Button {
                        id: modeBtn
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 42
                        text: (mainModel && mainModel.modeText) ? mainModel.modeText : "Manual Chat"

                        background: Rectangle {
                            color: modeBtn.pressed ? Theme.divider : (modeBtn.hovered ? Theme.backgroundHover : Theme.backgroundSecondary)
                            radius: Theme.radiusMd
                            border.width: 1
                            border.color: Theme.border
                        }

                        contentItem: Text {
                            text: modeBtn.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSm
                            color: Theme.textPrimary
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: if (eventBridge) eventBridge.onAutoToggle()
                    }
                }
            }
        }
    }

    function sendText() {
        let text = textInput.text.trim()
        if (text.length > 0 && eventBridge) {
            eventBridge.onSendText(text)
            textInput.text = ""
        }
    }
}
