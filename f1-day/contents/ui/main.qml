import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

PlasmoidItem {
    id: root

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    readonly property var gunler: ["PAZAR", "PAZARTESİ", "SALI", "ÇARŞAMBA", "PERŞEMBE", "CUMA", "CUMARTESİ"]

    preferredRepresentation: fullRepresentation

    fullRepresentation: RowLayout {
        id: row
        spacing: 8

        Layout.minimumWidth: implicitWidth
        Layout.minimumHeight: implicitHeight

        // Gün adı — ayrı
        Text {
            text: root.gunler[new Date().getDay()]
            color: "white"
            font.family: "Formula1 Display-Regular"
            font.pixelSize: 28
            renderType: Text.NativeRendering
        }

        // 23|05 — tek blok
        Text {
            text: Qt.formatDate(new Date(), "dd") + "|" + Qt.formatDate(new Date(), "MM")
            color: "white"
            font.family: "KH Interference Trial"
            font.pixelSize: 45
            renderType: Text.NativeRendering
        }
    }
}
