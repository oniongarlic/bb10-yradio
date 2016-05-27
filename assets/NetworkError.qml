import bb.cascades 1.2

Container {
    id: ne;
    visible: false
    horizontalAlignment: HorizontalAlignment.Center    

    signal retry(); 
    
    Label {
        text: qsTr("A network error occurred. Do you have a working internet connection ?");
        multiline: true
        horizontalAlignment: HorizontalAlignment.Fill        
    }
    Button {
        text: qsTr("Try again")
        onClicked: {
            ne.retry();        
        }                
        horizontalAlignment: HorizontalAlignment.Center
    }
    Button {
        text: qsTr("Network settings")
        onClicked: {
            invokeNetworkSettings.trigger("bb.action.OPEN")
        }        
        horizontalAlignment: HorizontalAlignment.Center
    }
    attachedObjects: [
        Invocation {
            id: invokeNetworkSettings
            query {
                invokeTargetId: "sys.settings.target"
                mimeType: "settings/view"
                uri: "settings://networkconnections"
            }
        }
    ]
    implicitLayoutAnimationsEnabled: false

}
