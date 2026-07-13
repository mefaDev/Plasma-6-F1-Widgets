import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.plasmoid 2.0
import QtQuick.Controls 2.15
import org.kde.plasma.core as PlasmaCore

PlasmoidItem {
    id: root
    preferredRepresentation: fullRepresentation
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    fullRepresentation: Item {
        width: 350
        height: 100

        // Fare kontrolü
        property bool mouseHover: ma.containsMouse
        opacity: mouseHover ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 300 } }

        property bool waitingForClick: false
        property bool jumpStarted: false // Erken kalkış kontrolü
        property int activeLights: 0
        property var startTime: 0
        property string displayTime: "Hazır"

        Timer {
            id: lightTimer
            interval: 1000
            repeat: true
            onTriggered: {
                if (activeLights < 5) {
                    activeLights++
                } else {
                    lightTimer.stop()
                    delayTimer.interval = Math.random() * 3000 + 1000
                    delayTimer.start()
                }
            }
        }

        Timer {
            id: delayTimer
            onTriggered: {
                activeLights = 0
                waitingForClick = true
                jumpStarted = false // Yarış normal başladı
                startTime = new Date().getTime()
                displayTime = "Tıkla!"
            }
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 10

            RowLayout {
                spacing: 10
                Repeater {
                    model: 5
                    Rectangle {
                        width: 40; height: 40
                        radius: 20
                        color: (index < activeLights) ? "#FF0000" : "#222222"
                    }
                }
            }

            Text {
                text: displayTime
                color: jumpStarted ? "yellow" : "white" // Hatalı çıkışta uyarı rengi
                font.pixelSize: 18
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }
        }

        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                if (waitingForClick) {
                    let reactionTime = new Date().getTime() - startTime
                    displayTime = reactionTime + " ms"
                    waitingForClick = false
                }
                // JUMP START MANTIĞI:
                else if (activeLights > 0 && activeLights < 5) {
                    lightTimer.stop()
                    delayTimer.stop()
                    activeLights = 0
                    jumpStarted = true
                    displayTime = "Hatalı Çıkış! (Jump Start)"
                }
                else if (activeLights === 0 && !waitingForClick) {
                    jumpStarted = false
                    displayTime = "Başlıyor..."
                    lightTimer.start()
                }
            }
        }
    }
}
