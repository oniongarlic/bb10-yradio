import bb.cascades 1.4
import bb.platform 1.0
import bb.system 1.0

Sheet {
    id: settingsSheet
    
    onOpened: {
        console.debug("Settings opened");
    }
    
    Page {
        titleBar: TitleBar {
            title: qsTr("Settings")
            kind: TitleBarKind.Default
            dismissAction: ActionItem {
                title: qsTr("Close");
                onTriggered: {
                    settingsSheet.close();
                }
                ActionBar.placement: ActionBarPlacement.Default
            }
        
        }
        ScrollView {
            scrollViewProperties.pinchToZoomEnabled: false
            scrollViewProperties.overScrollEffectMode: OverScrollEffectMode.None
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            implicitLayoutAnimationsEnabled: false
            Container {
                id: sc
                layout: StackLayout {
                }
                topPadding: 8.0
                leftPadding: 16.0
                rightPadding: 16.0
                
                Label {
                    text: qsTr("Autostop on call")                    
                    textFormat: TextFormat.Plain
                }  
                
                CheckBox {
                    id: stopOnIncomingCall
                    text: qsTr("Stop on incoming call")
                    checked: root.stopOnIncomingCall
                    onCheckedChanged: {
                        root.stopOnIncomingCall=checked;
                    }
                }
                CheckBox {
                    id: muteOnOutgoingCall
                    text: qsTr("Stop on outgoing call")
                    checked: root.stopOnOutgoingCall
                    onCheckedChanged: {
                        root.stopOnOutgoingCall=checked;
                    }
                }
            }    
        }
    }
    attachedObjects: [
        ComponentDefinition {
            id: option
            Option{
            
            } 
        }
    ]
    peekEnabled: false
}
