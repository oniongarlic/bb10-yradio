import bb.cascades 1.2
import bb.multimedia 1.2
import bb.data 1.0
import bb.system 1.2
import org.tal.bbm 1.0

Page {
    id: root
    
    property string currentChannel: ''
    
    titleBar: TitleBar {
        title: currentChannel=='' ? "Y-Radio" : "Y-Radio - "+currentChannel
        scrollBehavior: TitleBarScrollBehavior.Sticky
    }
    
    Menu.definition: MenuDefinition {
        helpAction: HelpActionItem {
            title: qsTr("About");
            onTriggered: {
                aboutSheet.open();
            }
        }
        actions: ActionItem {
            title: "Invite"
            // enabled: bbm.allowed
            imageSource: "asset:///images/share.png"
            onTriggered: {
                if (bbm.allowed==false)
                    bbm.registerApplication();
                else 
                    bbm.inviteToDownload();
            }
        }
    }
    
    actions: [
        ActionItem {
            title: mp.mediaState==MediaState.Started ? "Stop" : "Play"
            imageSource: mp.mediaState==MediaState.Started ? "asset:///images/stop.png" : "asset:///images/play.png"
            onTriggered: {
                if (mp.mediaState==MediaState.Started)
                    npc.revoke();
                else 
                    npc.acquire();
            }
            ActionBar.placement: ActionBarPlacement.OnBar
            enabled: mp.mediaState!=MediaState.Unprepared
        }
    ]
    Container {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        ListView {
            id: radioList
            dataModel: dataModelRadio
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
                 
                var s=getHlsStream(m.streams.stream)
                if (s) {
                    currentChannel=m.name;
                    mp.sourceUrl=s[".data"];
                    mp.prepare();
                    radioList.select(indexPath)
                } else {                
                    currentChannel='';
                    mp.sourceUrl='';
                    mp.reset();                    
                }
            }
            
            function hasWebType(type, data) {
                console.debug(JSON.stringify(data))
                for (var i in data) {
                    var s=data[i];
                    console.debug(JSON.stringify(s))
                    if (s.type==type) {                        
                        return true;                        
                    }
                }                            
                return false;
            }
            
            function web(type, data) {
                for (var i in data) {
                    var s=data[i];
                    console.debug(JSON.stringify(s))
                    if (s.type==type) {
                        _yradio.openWebSite(s[".data"]);                        
                        return true;                        
                    }
                }                            
                return false;                                  
            }
            
            function openUrl(url) {
                _yradio.openWebSite(url);
            }
            
            function getHlsStream(m) {                
                console.debug(JSON.stringify(m))
                
                for (var i in m) {
                    var s=m[i];
                    console.debug(JSON.stringify(s))                    
                    if (s.type=='hls') {                        
                        return s;                        
                    }
                }                            
                return null;
            }
            
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
        }
    }
    
    onCreationCompleted: {
        dataSource.load();
        bbm.registerApplication();
    }
    
    attachedObjects: [
        BBMHandler {
            id: bbm
        },
        MediaPlayer {
            id: mp
            onError: {
                console.debug("Error: "+mediaError)
                mediaErrorToast.body="Error: "+mediaError                
                mediaErrorToast.show();
            }
            onMediaStateChanged: {
                console.debug("State: "+mediaState)
            }
            onMetaDataChanged: {
                console.debug("Got metadata")
            }            
        },
        NowPlayingConnection {
            id: npc
            duration: mp.duration
            position: mp.position
            mediaState: mp.mediaState
            iconUrl: "asset:///images/icon.png"
            onAcquired: {
                mp.play();
            }            
            onPause: {
                mp.pause()
            }            
            onPlay: {
                mp.play()
            }            
            onRevoked: {
                mp.stop()
            }
        },
        AboutSheet {
            id: aboutSheet
        },
        SystemToast {
            id: mediaErrorToast            
            position: SystemUiPosition.MiddleCenter
        },
        GroupDataModel {
            id: dataModelRadio
            sortingKeys: [ "category" ]
            grouping: ItemGrouping.ByFullValue
            sortedAscending: false
        },
        DataSource {
            id: dataSource
            source: "asset:///yle.xml"
            query: "/radio/channels/channel"
            onDataLoaded: {
                console.debug("Loaded!"+data)
                console.log("Channels loaded:"+data.length);
                dataModelRadio.insertList(data);                
            }
            onError: {
                console.log("DataSourceError:"+errorMessage);
                console.log("DataSourceErrorType:"+errorType);
            }
            type: DataSourceType.Xml
        }
    ]
    actionBarVisibility: ChromeVisibility.Visible
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.Disabled
}
