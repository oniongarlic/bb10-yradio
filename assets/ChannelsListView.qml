import bb.cascades 1.4

ListView {
    id: radioList
    
    property Page root;
    
    signal channelSelected(variant data)
    signal requestUrl(string url)
    
    listItemComponents: [
        ListItemComponent {
            type: "header"
            Header {
                title: ListItemData
            }
        },
        ListItemComponent {
            type: "item"
            StandardListItem {
                id: item
                title: ListItemData.name
                description: ListItemData.category
                contextActions: [
                    ActionSet {
                        title: ListItemData.name
                        ActionItem {
                            title: qsTr("Web site")                                    
                            imageSource: "asset:///images/web.png"
                            onTriggered: {
                                item.ListItem.view.web('web', ListItemData.somes.some);
                            }
                        }                              
                        ActionItem {
                            title: qsTr("Follow on Twitter")
                            enabled: item.ListItem.view.hasWebType('twitter', ListItemData.somes.some);
                            imageSource: "asset:///images/web.png"
                            onTriggered: {
                                item.ListItem.view.web('twitter', ListItemData.somes.some);
                            }
                        }
                        ActionItem {
                            title: qsTr("Follow on Facebook")
                            enabled: item.ListItem.view.hasWebType('facebook', ListItemData.somes.some);
                            imageSource: "asset:///images/web.png"
                            onTriggered: {
                                item.ListItem.view.web('facebook', ListItemData.somes.some);
                            }
                        }
                        ActionItem {
                            title: qsTr("Follow on YouTube")
                            enabled: item.ListItem.view.hasWebType('youtube', ListItemData.somes.some);
                            imageSource: "asset:///images/web.png"
                            onTriggered: {
                                item.ListItem.view.web('youtube', ListItemData.somes.some);
                            }
                        }
                    }
                ]
            }
        }
    ]
    onTriggered: {
        var m = dataModel.data(indexPath);
        radioList.clearSelection();
        radioList.channelSelected(m);
        radioList.select(indexPath);
    }
    
    
    function hasWebType(type, data) {                
        for (var i in data) {
            var s=data[i];                    
            if (s.type==type) {                        
                return true;                        
            }
        }                            
        return false;
    }
    
    function web(type, data) {
        for (var i in data) {
            var s=data[i];                    
            if (s.type==type) {
                openUrl(s[".data"]);                        
                return true;                        
            }
        }                            
        return false;                                  
    }
    
    function openUrl(url) {
        requestUrl(url)
    }

}