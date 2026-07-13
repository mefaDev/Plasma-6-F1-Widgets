import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: root

    // Plasma main.xml şeması bağları
    property alias cfg_f1FontName: f1FontInput.text
    property alias cfg_khFontName: khFontInput.text
    property alias cfg_f1RedColor: redColorInput.text
    property alias cfg_bgColor: bgColorInput.text
    property alias cfg_logoPath: logoPathInput.text
    property alias cfg_logoType: logoTypeCombo.currentIndex

    // Bulunamayan ikonlar için yedek resim/ikon yolu bağı
    property alias cfg_fallbackIconPath: fallbackIconInput.text

    // Boyut ayarları
    property alias cfg_appIconSize: appIconSizeSpin.value
    property alias cfg_positionBoxWidth: positionBoxWidthSpin.value
    property alias cfg_rowHeight: rowHeightSpin.value
    property alias cfg_logoImageWidth: logoWidthSpin.value
    property alias cfg_logoImageHeight: logoHeightSpin.value

    // JSON dizisi ana ayar bağı
    property string cfg_launcherAppsJson: ""

    // Uygulamaları tutan yerel model
    ListModel { id: appsModel }

    Component.onCompleted: {
        updateLocalModel();
    }

    // Şemadan veriyi çekip modele doldurma
    function updateLocalModel() {
        appsModel.clear();
        try {
            var rawJson = root.cfg_launcherAppsJson;
            if (rawJson && rawJson !== "") {
                var list = JSON.parse(rawJson);
                for (var i = 0; i < list.length; i++) {
                    appsModel.append({
                        "name": list[i].name || "",
                        "icon": list[i].icon || "",
                        "desktop": list[i].desktop || "",
                        "accentColor": list[i].accentColor || "" // YENİ EKLENDİ
                    });
                }
            }
        } catch(e) {
            console.log("F1 Launcher JSON Okuma Hatası: " + e);
        }
    }

    // Modeldeki güncel verileri JSON string'e döküp kaydetme
    function saveModelToJson() {
        var arr = [];
        for (var i = 0; i < appsModel.count; i++) {
            arr.push({
                "name": appsModel.get(i).name,
                "icon": appsModel.get(i).icon,
                "desktop": appsModel.get(i).desktop,
                "accentColor": appsModel.get(i).accentColor // YENİ EKLENDİ
            });
        }
        root.cfg_launcherAppsJson = JSON.stringify(arr);
    }

    Kirigami.FormLayout {
        id: formLayout
        Layout.fillWidth: true

        // --- GÖRÜNÜM AYARLARI ---
        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Görünüm ve Stil Ayarları"
        }

        QQC2.ComboBox {
            id: logoTypeCombo
            Kirigami.FormData.label: "Logo Türü:"
            model: ["Düz Metin (Yazı)", "Sistem İkonu", "Özel Resim Yolu"]
            Layout.fillWidth: true
        }

        QQC2.TextField {
            id: logoPathInput
            Kirigami.FormData.label: "Logo Değeri / Yolu:"
            placeholderText: "Örn: F1 veya ikon adı"
            Layout.fillWidth: true
        }

        QQC2.TextField {
            id: fallbackIconInput
            Kirigami.FormData.label: "Yedek İkon / Resim Yolu:"
            placeholderText: "İkon bulunamazsa kullanılacak yol (Örn: application-x-executable)"
            Layout.fillWidth: true
        }

        // --- BOYUT AYARLARI ---
        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Boyutlar"
        }

        QQC2.SpinBox {
            id: appIconSizeSpin
            Kirigami.FormData.label: "Uygulama İkonu Boyutu (px):"
            from: 12
            to: 48
            stepSize: 2
        }

        QQC2.SpinBox {
            id: positionBoxWidthSpin
            Kirigami.FormData.label: "Pozisyon Kutusu Genişliği (px):"
            from: 20
            to: 60
            stepSize: 2
        }

        QQC2.SpinBox {
            id: rowHeightSpin
            Kirigami.FormData.label: "Satır Yüksekliği (px):"
            from: 24
            to: 72
            stepSize: 2
        }

        QQC2.SpinBox {
            id: logoWidthSpin
            Kirigami.FormData.label: "Logo Resmi Genişliği (px):"
            from: 40
            to: 260
            stepSize: 10
        }

        QQC2.SpinBox {
            id: logoHeightSpin
            Kirigami.FormData.label: "Logo Resmi Yüksekliği (px):"
            from: 20
            to: 120
            stepSize: 5
        }

        QQC2.Label {
            Kirigami.FormData.label: " "
            text: "İpucu: Aşağıdaki listede her uygulama için 'İkon Adı' kutusuna sistem ikon adı (Örn: steam) yerine bir resim dosyasının tam yolunu da yazabilirsiniz (Örn: /home/kullanici/ikonlar/steam.png)."
            wrapMode: Text.WordWrap
            font.italic: true
            opacity: 0.7
            Layout.preferredWidth: formLayout.width - 200
        }

        QQC2.TextField {
            id: f1FontInput
            Kirigami.FormData.label: "F1 Başlık Font Adı:"
            placeholderText: "Formula1 Display Regular"
            Layout.fillWidth: true
        }

        QQC2.TextField {
            id: khFontInput
            Kirigami.FormData.label: "Saat Font Adı:"
            placeholderText: "KH Interference"
            Layout.fillWidth: true
        }

        QQC2.TextField {
            id: redColorInput
            Kirigami.FormData.label: "Vurgu Rengi (HEX):"
            placeholderText: "#e10600"
            Layout.fillWidth: true
        }

        QQC2.TextField {
            id: bgColorInput
            Kirigami.FormData.label: "Arka Plan Rengi (HEX):"
            placeholderText: "#15161c"
            Layout.fillWidth: true
        }

        // --- LIDERBORD UYGULAMA DÜZENLEME ALANI ---
        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Uygulama Sıralaması (Leaderboard)"
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            ListView {
                id: appsListView
                Layout.fillWidth: true
                implicitHeight: appsModel.count * 45
                model: appsModel
                interactive: false

                delegate: RowLayout {
                    width: appsListView.width
                    spacing: 8

                    // --- SIRALAMA DEĞİŞTİRME BUTONLARI ---
                    RowLayout {
                        spacing: 2
                        Layout.preferredWidth: 50

                        QQC2.Button {
                            icon.name: "go-up"
                            display: QQC2.AbstractButton.IconOnly
                            enabled: index > 0 // İlk eleman yukarı gidemez
                            onClicked: {
                                appsModel.move(index, index - 1, 1);
                                saveModelToJson();
                            }
                        }
                        QQC2.Button {
                            icon.name: "go-down"
                            display: QQC2.AbstractButton.IconOnly
                            enabled: index < appsModel.count - 1 // Son eleman aşağı gidemez
                            onClicked: {
                                appsModel.move(index, index + 1, 1);
                                saveModelToJson();
                            }
                        }
                    }

                    QQC2.Label {
                        text: (index + 1) + "."
                        font.bold: true
                        Layout.preferredWidth: 20
                    }

                    // Uygulama Adı Kutusu
                    QQC2.TextField {
                        text: model.name
                        placeholderText: "Adı"
                        Layout.fillWidth: true
                        Layout.preferredWidth: 100

                        onTextChanged: {
                            if (appsModel.get(index) && appsModel.get(index).name !== text) {
                                appsModel.setProperty(index, "name", text);
                                saveModelToJson();
                            }
                        }
                    }

                    // İkon Kutusu
                    QQC2.TextField {
                        text: model.icon
                        placeholderText: "İkon"
                        Layout.preferredWidth: 90
                        onTextChanged: {
                            if (appsModel.get(index) && appsModel.get(index).icon !== text) {
                                appsModel.setProperty(index, "icon", text);
                                saveModelToJson();
                            }
                        }
                    }

                    // Çalıştırılacak Komut Kutusu
                    QQC2.TextField {
                        text: model.desktop
                        placeholderText: "Yol / Komut"
                        Layout.fillWidth: true
                        onTextChanged: {
                            if (appsModel.get(index) && appsModel.get(index).desktop !== text) {
                                appsModel.setProperty(index, "desktop", text);
                                saveModelToJson();
                            }
                        }
                    }
                    
                    // --- YENİ: Renk Kutusu ---
                    QQC2.TextField {
                        text: model.accentColor || ""
                        placeholderText: "Renk (Örn: #5865F2)"
                        Layout.preferredWidth: 140
                        onTextChanged: {
                            if (appsModel.get(index) && appsModel.get(index).accentColor !== text) {
                                appsModel.setProperty(index, "accentColor", text);
                                saveModelToJson();
                            }
                        }
                    }

                    // Satır Silme Butonu
                    QQC2.Button {
                        icon.name: "list-remove"
                        onClicked: {
                            appsModel.remove(index);
                            saveModelToJson();
                        }
                    }
                }
            }

            QQC2.Button {
                text: "Yeni Uygulama Ekle"
                icon.name: "list-add"
                Layout.alignment: Qt.AlignHCenter
                onClicked: {
                    appsModel.append({"name": "YENİ", "icon": "", "desktop": "", "accentColor": ""});
                    saveModelToJson();
                }
            }
        }
    }
}