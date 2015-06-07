import bb.cascades 1.2

Sheet {
    id: aboutSheet
    
    Page {
        titleBar: TitleBar {
            title: qsTr("About - Y-Radio")
            kind: TitleBarKind.Default
            dismissAction: ActionItem {
                title: qsTr("Close");
                onTriggered: {                                
                    aboutSheet.close()
                }
            }        
        }
        Container {
            layout: DockLayout {
            
            }        
            
            Container {
                layout: StackLayout {
                }
                leftPadding: 24.0
                rightPadding: 24.0
                horizontalAlignment: HorizontalAlignment.Center
                opacity: 0.9
                verticalAlignment: VerticalAlignment.Top
                implicitLayoutAnimationsEnabled: false
                
                Label {
                    text: "Y-Radio 1.0.0"
                    textStyle.fontSize: FontSize.Large
                    verticalAlignment: VerticalAlignment.Fill
                    textStyle.textAlign: TextAlign.Center
                    textStyle.fontStyle: FontStyle.Default
                    textStyle.fontWeight: FontWeight.Bold
                    horizontalAlignment: HorizontalAlignment.Fill
                }
                Label {            
                    text: "Copyright 2015 Kaj-Michael Lang"
                    multiline: true
                    horizontalAlignment: HorizontalAlignment.Fill
                    textStyle.textAlign: TextAlign.Center
                }
                Button {
                    text: "Contact"
                    onClicked: {
                        _yradio.openWebSite("mailto:yradio@tal.org");
                    }
                    horizontalAlignment: HorizontalAlignment.Center
                }                
                Button {
                    text: "Y-Radio project page"
                    onClicked: {
                        _yradio.openWebSite("http://www.tal.org/projects/y-radio");
                    }
                    horizontalAlignment: HorizontalAlignment.Center
                }    
                Label {
                    multiline: true
                    text: qsTr("Unofficial Radio application for Finnish broadcasting company Yleisradio radio stations.")
                    textStyle.fontSize: FontSize.Medium
                    textStyle.textAlign: TextAlign.Justify
                    textFormat: TextFormat.Plain
                }
                Label {            
                    text: "Package version: "+appInfo.version;
                    multiline: true
                    horizontalAlignment: HorizontalAlignment.Fill
                    textStyle.textAlign: TextAlign.Center
                    textStyle.fontSize: FontSize.XSmall
                }
                Label {
                    text: "Uses Subway icons, CC BY 4.0"
                }
                Button {
                    text: "CC BY 4.0"
                    onClicked: {
                        _yradio.openWebSite("http://creativecommons.org/licenses/by/4.0/");
                    }
                    horizontalAlignment: HorizontalAlignment.Center
                }
            }
        }
        attachedObjects: [
            ApplicationInfo {
                id: appInfo
            }
        ]
    }
}