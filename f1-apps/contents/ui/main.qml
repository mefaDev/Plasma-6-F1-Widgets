import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: root

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    compactRepresentation: null

    readonly property string f1Font: Plasmoid.configuration.f1FontName || "Formula1 Display-Regular"
    readonly property string khFont: Plasmoid.configuration.khFontName || "KH Interference Trial"
    readonly property string primaryRed: Plasmoid.configuration.f1RedColor || "#e10600"
    readonly property string panelBg: Plasmoid.configuration.bgColor || "#15161c"

    readonly property int logoType: Plasmoid.configuration.logoType
    readonly property string logoPath: Plasmoid.configuration.logoPath || "F1"
    readonly property string fallbackIcon: Plasmoid.configuration.fallbackIconPath || "application-x-executable"

    readonly property int appIconSize: Plasmoid.configuration.appIconSize || 20 
    readonly property int positionBoxWidth: Plasmoid.configuration.positionBoxWidth || 38 
    readonly property int rowHeight: Plasmoid.configuration.rowHeight || 38 
    readonly property int logoImageWidth: Plasmoid.configuration.logoImageWidth || 180
    readonly property int logoImageHeight: Plasmoid.configuration.logoImageHeight || 60

    readonly property bool showFloatingShapes: Plasmoid.configuration.showFloatingShapes

    Layout.minimumWidth: 100
    Layout.minimumHeight: 400
    Layout.preferredWidth: 280
    Layout.preferredHeight: 750

    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            disconnectSource(sourceName);
        }
        function exec(cmd) {
            connectSource(cmd);
        }
    }

    function shellEscape(str) {
        return "'" + str.replace(/'/g, "'\\''") + "'";
    }

    function launchApp(type, value) {
        if (!value || value.trim() === "") return;
        var v = value.trim();

        if (type === "link") {
            Qt.openUrlExternally(v);
            return;
        }

        var runCmd;
        if (v.endsWith(".desktop")) {
            var id = v.substring(v.lastIndexOf("/") + 1).replace(".desktop", "");
            var escId = shellEscape(id);
            runCmd = "gtk-launch " + escId + " > /dev/null 2>&1 || nohup " + escId + " > /dev/null 2>&1 &";
        } else {
            runCmd = "nohup " + v + " > /dev/null 2>&1 &";
        }

        executable.exec(runCmd);
    }

    Timer {
        id: clockTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var date = new Date();
            timeLabel.text = date.toLocaleTimeString(Qt.locale("en_US"), "HH:mm:ss");
        }
    }

    ListModel {
        id: dynamicAppModel
    }

    // Yedek plan: Eğer config içerisinde özel bir renk tanımlanmadıysa devreye girecek akıllı fonksiyon
    function getAccentColorForApp(name, type) {
        if (type === "link") return "#00A2ED"; 
        
        var n = name.toLowerCase();
        if (n.indexOf("steam") !== -1) return "#171a21";
        if (n.indexOf("discord") !== -1) return "#5865F2";
        if (n.indexOf("firefox") !== -1) return "#FF9400";
        if (n.indexOf("chrome") !== -1) return "#4285F4";
        if (n.indexOf("spotify") !== -1) return "#1ED760";
        if (n.indexOf("terminal") !== -1 || n.indexOf("konsole") !== -1) return "#4E9A06";
        if (n.indexOf("code") !== -1 || n.indexOf("vs") !== -1) return "#007ACC";
        
        return root.primaryRed; 
    }

    function refreshModel() {
        dynamicAppModel.clear();
        try {
            var jsonStr = Plasmoid.configuration.launcherAppsJson;
            if (jsonStr) {
                var arr = JSON.parse(jsonStr);
                for (var i = 0; i < arr.length; i++) {
                    var appName = arr[i].name || "";
                    var appType = arr[i].type || "app";
                    
                    // Önce ayarlardan elle girilen accentColor var mı diye bakar, yoksa otomatik fonksiyonu çağırır
                    var finalColor = (arr[i].accentColor && arr[i].accentColor.trim() !== "") 
                                     ? arr[i].accentColor 
                                     : getAccentColorForApp(appName, appType);

                    dynamicAppModel.append({
                        "pos": (i + 1).toString(),
                        "name": appName,
                        "icon": arr[i].icon || "",
                        "type": appType,
                        "desktop": arr[i].desktop || "",
                        "url": arr[i].url || "",
                        "rowAccentColor": finalColor // Son belirlenen net renk modele işleniyor
                    });
                }
            }
        } catch(e) {
            console.log("Widget Model Update Error: " + e);
        }
    }

    Connections {
        target: Plasmoid.configuration
        function onLauncherAppsJsonChanged() {
            refreshModel();
        }
    }

    Component.onCompleted: {
        refreshModel();
        Plasmoid.backgroundHints = PlasmaCore.Types.NoBackground;
    }

    // --- OPAK ARKA PLAN KATMANI ---
    Rectangle {
        anchors.fill: parent
        color: root.panelBg
        z: -3
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // --- DİNAMİK HEADER (LOGO) ALANI ---
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 116 
            color: root.panelBg

            ColumnLayout {
                anchors.fill: parent
                anchors.topMargin: 12
                anchors.bottomMargin: 0 
                anchors.leftMargin: 0 
                anchors.rightMargin: 0 
                spacing: 6

                Loader {
                    Layout.alignment: Qt.AlignHCenter
                    sourceComponent: {
                        if (root.logoType === 1) return iconLogoComponent;
                        if (root.logoType === 2) return imageLogoComponent;
                        return textLogoComponent;
                    }
                }

                Component {
                    id: textLogoComponent
                    Text {
                        text: root.logoPath
                        font.family: root.f1Font
                        font.pixelSize: 22
                        font.bold: true
                        color: root.primaryRed
                    }
                }

                Component {
                    id: iconLogoComponent
                    Kirigami.Icon {
                        source: root.logoPath
                        width: 32
                        height: 32
                    }
                }

                Component {
                    id: imageLogoComponent
                    Image {
                        source: root.logoPath
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        mipmap: true
                        asynchronous: false
                        width: root.logoImageWidth
                        height: root.logoImageHeight
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: "#ffffff"
                    opacity: 0.5
                }

                Text {
                    id: timeLabel
                    text: "00:00:00"
                    font.family: root.f1Font
                    font.pixelSize: 20
                    color: "white"
                    Layout.alignment: Qt.AlignHCenter
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 3
                    color: root.primaryRed
                }
            }
        }

        Item {
            Layout.preferredHeight: 3
        }

        // --- LEADERBOARD (UYGULAMA LİSTESİ) ALANI ---
        ListView {
            id: leaderboardListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: dynamicAppModel
            interactive: true
            spacing: 2 
            clip: true

            delegate: ItemDelegate {
                id: delegateItem
                width: leaderboardListView.width
                height: root.rowHeight
                padding: 0

                property real fillProgress: 0
                property bool isHovered: false

                // Model içerisinden gelen dinamik uygulama rengi saptanıyor
                readonly property color finalAccentColor: model.rowAccentColor ? model.rowAccentColor : root.primaryRed

                NumberAnimation { id: growAnim; target: delegateItem; property: "fillProgress"; to: 1.0; duration: 200; easing.type: Easing.OutQuad }
                NumberAnimation { id: shrinkAnim; target: delegateItem; property: "fillProgress"; to: 0.0; duration: 150; easing.type: Easing.InQuad }

                background: Rectangle {
                    anchors.fill: parent
                    color: delegateItem.isHovered ? "#FFFFFF" : "transparent"

                    Behavior on color {
                        ColorAnimation { duration: 130; easing.type: Easing.InOutQuad }
                    }

                    // Dinamik uygulama rengiyle dolan animasyon barı
                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: parent.width * delegateItem.fillProgress
                        color: delegateItem.finalAccentColor
                        opacity: 0.45
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    z: 20 
                    
                    onEntered: delegateItem.isHovered = true
                    onExited: {
                        delegateItem.isHovered = false
                        shrinkAnim.start()
                    }
                    onPressed: {
                        shrinkAnim.stop()
                        growAnim.start()
                    }
                    onReleased: {
                        growAnim.stop()
                        shrinkAnim.start()
                        root.launchApp(model.type, model.type === "link" ? model.url : model.desktop)
                    }
                    onCanceled: {
                        growAnim.stop()
                        shrinkAnim.start()
                    }

                    Item {
                        anchors.fill: parent

                        // Numara Kutusu (posBox)
                        Rectangle {
                            id: posBox
                            width: root.positionBoxWidth
                            height: parent.height
                            anchors.left: parent.left
                            
                            color: delegateItem.isHovered ? "#E5E5E5" : (model.pos === "1" ? root.primaryRed : "#1D1F24")

                            Behavior on color {
                                ColorAnimation { duration: 130; easing.type: Easing.InOutQuad }
                            }

                            Text {
                                text: model.pos
                                font.family: root.khFont
                                font.pixelSize: 16
                                font.bold: true
                                anchors.centerIn: parent
                                
                                color: delegateItem.isHovered ? "#000000" : "#ffffff"

                                Behavior on color {
                                    ColorAnimation { duration: 130; easing.type: Easing.InOutQuad }
                                }
                            }
                        }

                        // Hover Durumunda Tamamen Opak ve Kare olan İkon Arka Planı
                        Rectangle {
                            id: iconBgContainer
                            width: root.appIconSize + 12
                            height: parent.height // Satırı dikeyde tamamen doldurması sağlandı
                            anchors.left: posBox.right
                            radius: 0 // Tam bir F1 karesi olması için sıfırlandı
                            color: delegateItem.finalAccentColor // Uygulamanın kendi simge rengi
                            opacity: delegateItem.isHovered ? 1.0 : 0.0 // İstediğin gibi tamamen OPAK

                            Behavior on opacity {
                                NumberAnimation { duration: 120; easing.type: Easing.InOutQuad }
                            }
                        }

                        Kirigami.Icon {
                            id: appIcon
                            source: model.icon ? model.icon : root.fallbackIcon
                            width: root.appIconSize
                            height: root.appIconSize
                            anchors.left: posBox.right
                            anchors.leftMargin: 6 
                            anchors.verticalCenter: parent.verticalCenter
                            z: 2 // Kare arka planın üstünde kalması sağlandı
                        }

                        // Uygulama İsmi Yazısı
                        Text {
                            text: model.name ? model.name.toUpperCase() : ""
                            font.family: root.f1Font
                            font.pixelSize: 15
                            font.bold: true
                            anchors.left: appIcon.right
                            anchors.leftMargin: 12 // İkon karesi büyüdüğü için yazı boşluğu dengelendi
                            anchors.right: actionIndicator.visible ? actionIndicator.left : parent.right
                            anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            elide: Text.ElideRight

                            color: delegateItem.isHovered ? "#000000" : "#ffffff"

                            Behavior on color {
                                ColorAnimation { duration: 130; easing.type: Easing.InOutQuad }
                            }
                        }

                        // Düz Çalıştır İkonu (Saf siyah sembol)
                        Item {
                            id: actionIndicator
                            visible: delegateItem.isHovered
                            width: 22
                            height: 22
                            anchors.right: parent.right
                            anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                anchors.centerIn: parent
                                text: model.type === "link" ? "🔗" : "▶"
                                color: "#000000" 
                                font.pixelSize: model.type === "link" ? 12 : 10
                            }
                        }
                    }
                }
            }
        }
    }
}