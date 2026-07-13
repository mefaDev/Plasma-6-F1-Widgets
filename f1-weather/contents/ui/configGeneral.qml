import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQuick.Dialogs
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: root

    // Plasma main.xml şeması bağları
    property alias cfg_cityLabel: cityInput.text
    property alias cfg_latitude: latInput.text
    property alias cfg_longitude: lonInput.text
    property alias cfg_refreshMinutes: refreshSpin.value
    property alias cfg_f1FontName: f1FontInput.text
    property alias cfg_f1FontBoldName: f1FontBoldInput.text
    property alias cfg_khFontName: khFontInput.text
    property alias cfg_accentColor: accentColorInput.text
    property alias cfg_bgColor: bgColorInput.text
    property alias cfg_headerBgColor: headerBgColorInput.text
    property alias cfg_detailIconSize: iconSizeSpin.value
    property string cfg_trackIconPath: ""
    property string cfg_humidityIconPath: ""
    property string cfg_windIconPath: ""

    FileDialog {
        id: trackIconDialog
        title: "Pist Sıcaklığı İkonu Seç"
        nameFilters: ["Resim dosyaları (*.png *.jpg *.jpeg *.svg *.webp)"]
        onAccepted: root.cfg_trackIconPath = selectedFile
    }

    FileDialog {
        id: humidityIconDialog
        title: "Nem İkonu Seç"
        nameFilters: ["Resim dosyaları (*.png *.jpg *.jpeg *.svg *.webp)"]
        onAccepted: root.cfg_humidityIconPath = selectedFile
    }

    FileDialog {
        id: windIconDialog
        title: "Rüzgar İkonu Seç"
        nameFilters: ["Resim dosyaları (*.png *.jpg *.jpeg *.svg *.webp)"]
        onAccepted: root.cfg_windIconPath = selectedFile
    }

    Kirigami.FormLayout {
        id: formLayout
        Layout.fillWidth: true

        // --- KONUM ---
        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Konum"
        }

        QQC2.TextField {
            id: cityInput
            Kirigami.FormData.label: "Şehir Etiketi:"
            placeholderText: "ANKARA"
            Layout.fillWidth: true
        }

        QQC2.TextField {
            id: latInput
            Kirigami.FormData.label: "Enlem (Latitude):"
            placeholderText: "39.9334"
            validator: DoubleValidator { bottom: -90; top: 90; decimals: 6 }
            Layout.fillWidth: true
        }

        QQC2.TextField {
            id: lonInput
            Kirigami.FormData.label: "Boylam (Longitude):"
            placeholderText: "32.8597"
            validator: DoubleValidator { bottom: -180; top: 180; decimals: 6 }
            Layout.fillWidth: true
        }

        QQC2.Label {
            Kirigami.FormData.label: " "
            text: "İpucu: Şehrinizin enlem/boylamını bulmak için Google Haritalar'da konuma sağ tıklayıp koordinatları kopyalayabilirsiniz."
            wrapMode: Text.WordWrap
            font.italic: true
            opacity: 0.7
            Layout.preferredWidth: formLayout.width - 200
        }

        // --- VERİ ---
        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Veri"
        }

        QQC2.SpinBox {
            id: refreshSpin
            Kirigami.FormData.label: "Yenileme Sıklığı (dakika):"
            from: 5
            to: 120
            stepSize: 5
        }

        // --- DETAY İKONLARI ---
        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Detay İkonları"
        }

        QQC2.Label {
            Kirigami.FormData.label: " "
            text: "Varsayılan olarak emoji (🌡 💧 🧭) kullanılır. Bir resim seçerseniz o detay için emoji yerine resim gösterilir."
            wrapMode: Text.WordWrap
            font.italic: true
            opacity: 0.7
            Layout.preferredWidth: formLayout.width - 200
        }

        RowLayout {
            Kirigami.FormData.label: "Pist Sıcaklığı İkonu:"
            Layout.fillWidth: true
            spacing: 8

            Image {
                source: root.cfg_trackIconPath
                visible: root.cfg_trackIconPath !== ""
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                fillMode: Image.PreserveAspectFit
                smooth: true
            }

            QQC2.Label {
                text: root.cfg_trackIconPath !== "" ? root.cfg_trackIconPath.toString().split("/").pop() : "🌡  (emoji kullanılıyor)"
                elide: Text.ElideMiddle
                Layout.fillWidth: true
                opacity: root.cfg_trackIconPath !== "" ? 1.0 : 0.6
            }

            QQC2.Button {
                text: "Gözat..."
                onClicked: trackIconDialog.open()
            }

            QQC2.Button {
                icon.name: "edit-clear"
                display: QQC2.AbstractButton.IconOnly
                visible: root.cfg_trackIconPath !== ""
                onClicked: root.cfg_trackIconPath = ""
            }
        }

        RowLayout {
            Kirigami.FormData.label: "Nem İkonu:"
            Layout.fillWidth: true
            spacing: 8

            Image {
                source: root.cfg_humidityIconPath
                visible: root.cfg_humidityIconPath !== ""
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                fillMode: Image.PreserveAspectFit
                smooth: true
            }

            QQC2.Label {
                text: root.cfg_humidityIconPath !== "" ? root.cfg_humidityIconPath.toString().split("/").pop() : "💧  (emoji kullanılıyor)"
                elide: Text.ElideMiddle
                Layout.fillWidth: true
                opacity: root.cfg_humidityIconPath !== "" ? 1.0 : 0.6
            }

            QQC2.Button {
                text: "Gözat..."
                onClicked: humidityIconDialog.open()
            }

            QQC2.Button {
                icon.name: "edit-clear"
                display: QQC2.AbstractButton.IconOnly
                visible: root.cfg_humidityIconPath !== ""
                onClicked: root.cfg_humidityIconPath = ""
            }
        }

        RowLayout {
            Kirigami.FormData.label: "Rüzgar İkonu:"
            Layout.fillWidth: true
            spacing: 8

            Image {
                source: root.cfg_windIconPath
                visible: root.cfg_windIconPath !== ""
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                fillMode: Image.PreserveAspectFit
                smooth: true
            }

            QQC2.Label {
                text: root.cfg_windIconPath !== "" ? root.cfg_windIconPath.toString().split("/").pop() : "🧭  (emoji kullanılıyor)"
                elide: Text.ElideMiddle
                Layout.fillWidth: true
                opacity: root.cfg_windIconPath !== "" ? 1.0 : 0.6
            }

            QQC2.Button {
                text: "Gözat..."
                onClicked: windIconDialog.open()
            }

            QQC2.Button {
                icon.name: "edit-clear"
                display: QQC2.AbstractButton.IconOnly
                visible: root.cfg_windIconPath !== ""
                onClicked: root.cfg_windIconPath = ""
            }
        }

        QQC2.SpinBox {
            id: iconSizeSpin
            Kirigami.FormData.label: "İkon Boyutu (px):"
            from: 16
            to: 64
            stepSize: 2
        }

        // --- YAZI TİPLERİ ---
        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Yazı Tipleri"
        }

        QQC2.TextField {
            id: f1FontInput
            Kirigami.FormData.label: "Başlık/Etiket Fontu:"
            placeholderText: "Formula1 Display-Regular"
            Layout.fillWidth: true
        }

        QQC2.TextField {
            id: f1FontBoldInput
            Kirigami.FormData.label: "Kalın Font (Durum Yazısı):"
            placeholderText: "Formula1 Display Bold"
            Layout.fillWidth: true
        }

        QQC2.TextField {
            id: khFontInput
            Kirigami.FormData.label: "Değer/Rakam Fontu:"
            placeholderText: "KH Interference Trial"
            Layout.fillWidth: true
        }

        // --- RENKLER ---
        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Renkler"
        }

        QQC2.TextField {
            id: accentColorInput
            Kirigami.FormData.label: "Vurgu Rengi (HEX):"
            placeholderText: "#D4FF00"
            Layout.fillWidth: true
        }

        QQC2.TextField {
            id: bgColorInput
            Kirigami.FormData.label: "Arka Plan Rengi (HEX):"
            placeholderText: "#1c1c1c"
            Layout.fillWidth: true
        }

        QQC2.TextField {
            id: headerBgColorInput
            Kirigami.FormData.label: "Başlık Şeridi Rengi (HEX):"
            placeholderText: "#F0F0F0"
            Layout.fillWidth: true
        }
    }
}
