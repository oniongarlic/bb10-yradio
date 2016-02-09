import bb.cascades 1.4

Container {
    id: offlineBanner
    horizontalAlignment: HorizontalAlignment.Fill
    
    Label {
        horizontalAlignment: HorizontalAlignment.Fill
        textStyle.fontSize: FontSize.XLarge
        text: qsTr("Off-line")
        textStyle.color: Color.White
    }
    
    Label {                
        horizontalAlignment: HorizontalAlignment.Fill
        textStyle.fontSize: FontSize.Medium
        text: qsTr("You are off-line, please connect to a network to enable streaming")
        textStyle.color: Color.LightGray
        autoSize.maxLineCount: 3
        multiline: true
        textStyle.textAlign: TextAlign.Center;                
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
    verticalAlignment: VerticalAlignment.Center
    background: Color.Black
}