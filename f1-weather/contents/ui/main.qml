import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore

PlasmoidItem {
    id: root

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    compactRepresentation: fullRepresentation

    readonly property string f1Font: Plasmoid.configuration.f1FontName || "Formula1 Display-Regular"
    readonly property string f1FontBold: Plasmoid.configuration.f1FontBoldName || "Formula1 Display Bold"
    readonly property string khFont: Plasmoid.configuration.khFontName || "KH Interference Trial"
    readonly property string accentColor: Plasmoid.configuration.accentColor || "#D4FF00"
    readonly property string panelBg: Plasmoid.configuration.bgColor || "#1c1c1c"
    readonly property string headerBg: Plasmoid.configuration.headerBgColor || "#F0F0F0"
    readonly property string cityLabel: Plasmoid.configuration.cityLabel || "ANKARA"
    readonly property real latitude: Plasmoid.configuration.latitude || 39.9334
    readonly property real longitude: Plasmoid.configuration.longitude || 32.8597
    readonly property int detailIconSize: Plasmoid.configuration.detailIconSize || 28
    readonly property string trackIconPath: Plasmoid.configuration.trackIconPath || ""
    readonly property string humidityIconPath: Plasmoid.configuration.humidityIconPath || ""
    readonly property string windIconPath: Plasmoid.configuration.windIconPath || ""

    property string weatherDesc: "YÜKLENİYOR..."
    property string tempC: "--°C"
    property string tempF: "--°F"
    property string trackTempC: "--°C"
    property string trackTempF: "--°F"
    property string humidityValue: "--%"
    property string windSpeedValue: "--"
    property string windDirValue: "--"

    fullRepresentation: Item {
        Layout.minimumWidth: 220
        Layout.minimumHeight: 300

        Rectangle {
            anchors.fill: parent
            color: root.panelBg
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // 1. BÖLÜM: BEYAZ BAŞLIK ALANI
            Rectangle {
                Layout.fillWidth: true
                height: 55
                color: root.headerBg

                Text {
                    anchors.centerIn: parent
                    text: "HAVA\nDURUMU"
                    font.family: root.f1Font
                    font.pixelSize: 18
                    font.bold: true
                    color: "black"
                    horizontalAlignment: Text.AlignHCenter
                    lineHeight: 0.9
                }
            }

            // Yapılandırmadan gelen şehir etiketi
            Text {
                Layout.fillWidth: true
                Layout.topMargin: 6
                Layout.leftMargin: 20
                text: root.cityLabel
                font.family: root.f1Font
                font.pixelSize: 12
                font.bold: true
                color: "#888888"
            }

            // 2. BÖLÜM: ANA İÇERİK ALANI
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: 20
                spacing: 15

                // Durum ve Ana Sıcaklık
                ColumnLayout {
                    spacing: -5

                    Text {
                        text: root.weatherDesc
                        font.family: root.f1FontBold
                        font.pixelSize: 36
                        color: root.accentColor
                    }

                    RowLayout {
                        spacing: 8
                        Text {
                            text: root.tempC
                            font.family: root.khFont
                            font.pixelSize: 42
                            color: "white"
                        }
                        Text {
                            text: root.tempF
                            font.family: root.khFont
                            font.pixelSize: 24
                            color: "#888888"
                            Layout.alignment: Qt.AlignBottom
                            Layout.bottomMargin: 5
                        }
                    }
                }

                Item { Layout.preferredHeight: 10 }

                // Detaylar
                ColumnLayout {
                    spacing: 18
                    Layout.fillWidth: true

                    DetailItem {
                        label: "PİST SICAKLIĞI";
                        icon: "🌡"
                        imagePath: root.trackIconPath
                        mainValue: root.trackTempC; subValue: "TAHMİNİ"; rightValue: root.trackTempF
                    }
                    DetailItem {
                        label: "NEM";
                        icon: "💧"
                        imagePath: root.humidityIconPath
                        mainValue: root.humidityValue; subValue: "GÜNCEL"; rightValue: ""
                    }
                    DetailItem {
                        label: "RÜZGAR";
                        icon: "🧭"
                        imagePath: root.windIconPath
                        mainValue: root.windSpeedValue; subValue: root.windDirValue; rightValue: "KM/S"
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }
    }

    Timer {
        id: updateTimer
        interval: (Plasmoid.configuration.refreshMinutes || 15) * 60 * 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: fetchWeatherData()
    }

    // Yapılandırma panelinden konum veya yenileme süresi değiştirilince anında yansısın
    Connections {
        target: Plasmoid.configuration
        function onRefreshMinutesChanged() { updateTimer.restart(); }
        function onLatitudeChanged() { fetchWeatherData(); }
        function onLongitudeChanged() { fetchWeatherData(); }
    }

    function fetchWeatherData() {
        var xhr = new XMLHttpRequest();
        var url = "https://api.open-meteo.com/v1/forecast?latitude=" + root.latitude + "&longitude=" + root.longitude + "&current=temperature_2m,relative_humidity_2m,wind_speed_10m,wind_direction_10m,weather_code";

        xhr.open("GET", url, true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    var data = JSON.parse(xhr.responseText);
                    var current = data.current;

                    var tC = Math.round(current.temperature_2m);
                    root.tempC = tC + "°C";
                    root.tempF = Math.round((tC * 9/5) + 32) + "°F";

                    var trC = tC + 12;
                    root.trackTempC = trC + "°C";
                    root.trackTempF = Math.round((trC * 9/5) + 32) + "°F";

                    root.humidityValue = current.relative_humidity_2m + "%";
                    root.windSpeedValue = current.wind_speed_10m.toFixed(1);

                    // Rüzgar Yönü Türkçe Çevirileri
                    var deg = current.wind_direction_10m;
                    var dirs = ["KUZEY", "KUZEYDOĞU", "DOĞU", "GÜNEYDOĞU", "GÜNEY", "GÜNEYBATI", "BATI", "KUZEYBATI"];
                    var dirIndex = Math.round(((deg %= 360) < 0 ? deg + 360 : deg) / 45) % 8;
                    root.windDirValue = dirs[dirIndex];

                    var code = current.weather_code;

                    if (code === 0) root.weatherDesc = "AÇIK";
                    else if (code <= 3) root.weatherDesc = "BULUTLU";
                    else if (code === 45 || code === 48) root.weatherDesc = "SİSLİ";
                    else if (code >= 51 && code <= 55) root.weatherDesc = "ÇİSELEME";
                    else if (code >= 56 && code <= 57) root.weatherDesc = "ÇİSELEME";
                    else if (code >= 61 && code <= 65) root.weatherDesc = "YAĞMURLU";
                    else if (code >= 66 && code <= 67) root.weatherDesc = "YAĞMURLU";
                    else if (code >= 71 && code <= 77) root.weatherDesc = "KARLI";
                    else if (code >= 80 && code <= 82) root.weatherDesc = "SAĞANAK";
                    else if (code >= 85 && code <= 86) root.weatherDesc = "KARLI";
                    else if (code >= 95 && code <= 99) root.weatherDesc = "FIRTINALI";
                    else root.weatherDesc = "Bilinmiyor";
                } else {
                    root.weatherDesc = "HATA";
                }
            }
        };
        xhr.send();
    }

    component DetailItem : ColumnLayout {
        property string label
        property string icon
        property string imagePath
        property string mainValue
        property string subValue
        property string rightValue

        spacing: 5

        Text {
            text: label
            font.family: root.f1Font
            font.pixelSize: 12
            color: root.accentColor
        }

        RowLayout {
            spacing: 12

            Item {
                Layout.preferredWidth: root.detailIconSize
                Layout.preferredHeight: root.detailIconSize
                Layout.alignment: Qt.AlignTop

                Text {
                    anchors.fill: parent
                    visible: imagePath === ""
                    text: icon
                    font.pixelSize: Math.round(root.detailIconSize * 0.85)
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                Image {
                    anchors.fill: parent
                    visible: imagePath !== ""
                    source: imagePath
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    mipmap: true
                }
            }

            ColumnLayout {
                spacing: -2

                RowLayout {
                    spacing: 8
                    Text {
                        text: mainValue
                        font.family: root.khFont
                        font.pixelSize: 24
                        color: "white"
                    }
                    Text {
                        text: rightValue
                        font.family: root.khFont
                        font.pixelSize: 18
                        color: "#888888"
                        visible: rightValue !== ""
                        Layout.alignment: Qt.AlignBottom
                        Layout.bottomMargin: 2
                    }
                }

                Text {
                    text: subValue
                    font.family: root.khFont
                    font.pixelSize: 14
                    color: "white"
                    visible: subValue !== ""
                }
            }
        }
    }
}
