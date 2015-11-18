import bb.cascades 1.4
import bb.multimedia 1.4
import bb.data 1.0
import bb.system 1.2
import bb.system.phone 1.0
import org.tal 1.0
import org.tal.bbm 1.0

Page {
    id: root
    
    property string currentChannel: ''
    property variant channel;
    property bool stopOnOutgoingCall: false;
    property bool stopOnIncomingCall: false;
    
    property bool isLoaded: false;
    property bool isLoading: false;
    
    property int currentEq: EqualizerPreset.Off
    
    onCurrentEqChanged: {
        settings.setBool("savedEq", currentEq);
    }
    onStopOnIncomingCallChanged: {
        settings.setBool("stopIncoming", stopOnIncomingCall);
    }
    onStopOnOutgoingCallChanged: {
        settings.setBool("stopOutgoing", stopOnOutgoingCall);
    }
    
    titleBar: TitleBar {
        title: currentChannel=='' ? "Y-Radio" : "Y-Radio - "+currentChannel
        scrollBehavior: TitleBarScrollBehavior.Sticky
    }
    
    function incomingCall(status) {
        if (!stopOnIncomingCall)
            return;
    }
    
    function outgoingCall(status) {
        if (!stopOnOutgoingCall)
            return ;
    }
    
    Menu.definition: MenuDefinition {
        helpAction: HelpActionItem {
            title: qsTr("About");
            onTriggered: {
                aboutSheet.open();
            }
        }
        actions: [
            ActionItem {
                title: qsTr("Invite")
                // enabled: bbm.allowed
                imageSource: "asset:///images/share.png"
                onTriggered: {
                    if (bbm.allowed==false)
                        bbm.registerApplication();
                    else 
                        bbm.inviteToDownload();
                }
            },
            ActionItem {
                title: "Equalizer"
                imageSource: "asset:///images/eq.png"
                onTriggered: {
                    eqSheet.open()
                }
            }
        ]
        settingsAction: SettingsActionItem {
            title: qsTr("Settings")
            onTriggered: {
                settingsSheet.open();                
            }
        }
    }
    
    actions: [
        ActionItem {
            title: mp.mediaState==MediaState.Started ? qsTr("Stop") : qsTr("Play")
            imageSource: mp.mediaState==MediaState.Started ? "asset:///images/stop.png" : "asset:///images/play.png"
            onTriggered: {
                if (mp.mediaState==MediaState.Started) {
                    console.debug("Revoke")
                    npc.revoke();
                } else {
                    console.debug("Acquire")      
                    npc.acquire();
                }
            }
            ActionBar.placement: ActionBarPlacement.Signature
            enabled: mp.mediaState!=MediaState.Unprepared
            defaultAction: true
        }
    ]
    Container {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        navigation {
            focusPolicy: NavigationFocusPolicy.NotFocusable
        }
        
        Container {
            id: offlineBanner
            horizontalAlignment: HorizontalAlignment.Fill
            visible: !_yradio.onLine
            
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
        
        ListView {
            id: mainListView
            dataModel: viewModel
            flickMode: FlickMode.SingleItem
            inputRoute.primaryKeyTarget: false
            scrollRole: ScrollRole.None
            snapMode: SnapMode.LeadingEdge
            
            layout: StackListLayout {
                orientation: LayoutOrientation.LeftToRight
            }
            visible: _yradio.onLine
            
            property alias channelModel: dataModelRadio
            property alias mainRoot: root
            property alias currentChannel: root.channel
            property alias isLoading: root.isLoading
            
            property int actualWidth: 768
            
            onActualWidthChanged: {
                console.debug("AW: "+actualWidth)
            }
            
            function channelSelected(data) {
                root.setChannel(data)
            }
            
            function openUrl(url) {
                _yradio.openWebSite(url);
            }
            
            listItemComponents: [
                ListItemComponent {
                    type: "channelList"
                    Container {
                        id: radioList
                        background: Color.Black
                        minWidth: 720.0
                        preferredWidth: radioList.ListItem.view.actualWidth
                        verticalAlignment: VerticalAlignment.Fill
                        ChannelsListView {
                            minWidth: 720
                            preferredWidth: radioList.preferredWidth                     
                            root: radioList.ListItem.view.mainRoot
                            dataModel: radioList.ListItem.view.channelModel
                            onChannelSelected: {
                                radioList.ListItem.view.channelSelected(data)
                            }
                            onRequestUrl: {
                                radioList.ListItem.view.openUrl(url)
                            }
                            //bottomPadding: 64.0
                            horizontalAlignment: HorizontalAlignment.Fill
                            stickToEdgePolicy: ListViewStickToEdgePolicy.Default
                            margin.bottomOffset: 1.0
                        }
                    }
                },
                ListItemComponent {
                    type: "nowPlaying"
                    Container {
                        id: nowPlaying
                        horizontalAlignment: HorizontalAlignment.Fill
                        verticalAlignment: VerticalAlignment.Fill
                        minWidth: 720.0
                        preferredWidth: nowPlaying.ListItem.view.actualWidth
                        background: Color.Black
                        topPadding: 32.0
                        property variant channel: nowPlaying.ListItem.view.currentChannel
                        
                        ImageView {
                            imageSource: "asset:///images/icon.png"
                            horizontalAlignment: HorizontalAlignment.Center
                            topMargin: 16.0
                            bottomMargin: 16.0
                            minWidth: 114.0
                            minHeight: 114.0
                            maxWidth: 132.0
                            maxHeight: 132.0
                        }
                        
                        ActivityIndicator {
                            id: bufferingIndicator
                            minWidth: 64.0
                            minHeight: 64.0
                            maxWidth: 128.0
                            maxHeight: 128.0
                            visible: running
                            running: nowPlaying.ListItem.view.isLoading
                            horizontalAlignment: HorizontalAlignment.Center
                        }
                        
                        Label {
                            //visible: channel!=undefined ? true : false
                            textStyle.textAlign: TextAlign.Center
                            text: channel==undefined ? 'No channel selected' : channel.name
                            horizontalAlignment: HorizontalAlignment.Fill
                            textStyle.color: Color.White
                            textStyle.fontSize: FontSize.XLarge
                        }
                        Label {
                            visible: channel==undefined ? true : false
                            textStyle.fontSize: FontSize.Medium
                            textStyle.color: Color.LightGray
                            horizontalAlignment: HorizontalAlignment.Fill
                            textStyle.textAlign: TextAlign.Center
                            text: qsTr("Swipe left for channels list")
                        }
                        /*
                         ListView {
                         id: nowPlayingList
                         }
                         */
                    }
                }
            ]
            
            attachedObjects: [
                ListScrollStateHandler {
                    id: listScroll
                    onFirstVisibleItemChanged: {
                        console.debug("FVI:")
                        console.debug(listScroll.firstVisibleItem[0])
                    }
                },
                GroupDataModel {
                    id: viewModel
                    grouping: ItemGrouping.None
                },
                LayoutUpdateHandler {
                    onLayoutFrameChanged: {
                        mainListView.actualWidth  = layoutFrame.width;
                        // mainListView.actualHeight = layoutFrame.height;
                    }
                }
            ]
            
            onCreationCompleted: {
                viewModel.insert({"item": "nowPlaying"});
                viewModel.insert({"item": "channelList"});
                console.debug(viewModel.size())
            }
            
            function itemType(data, indexPath) {
                switch (indexPath[0]) {
                    case 1:
                        return "channelList"
                    case 0:
                        return "nowPlaying"
                }
            }
        }
    }
    
    function setChannel(data) {
        var s=getHlsStream(data.streams.stream);
        if (s) {
            currentChannel=data.name;
            channel=data;
            mainListView.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Smooth);
            isLoading=true;
            playStarter.start();                        
        } else {                
            currentChannel='';
            channel=undefined;
            mp.sourceUrl=undefined;
            npc.revoke();
            mp.reset();
            mediaErrorToast.body="Failed to set playback stream" 
            mediaErrorToast.show()          
        }
    }
    
    function getHlsStream(m) {                                            
        for (var i in m) {
            var s=m[i];
            if (s.type=='hls') {                        
                return s;                        
            }
        }                            
        return null;
    }
    
    function getRTSPStream(m) {                                            
        for (var i in m) {
            var s=m[i];
            if (s.type=='rtsp') {                        
                return s;                        
            }
        }                            
        return null;
    }
    
    onCreationCompleted: {
        dataSource.load();
        bbm.registerApplication();
        eqModel.insert({"eid": EqualizerPreset.Off, "title": "Off"})
        eqModel.insert({"eid": EqualizerPreset.Airplane, "title": "Airplane"})
        eqModel.insert({"eid": EqualizerPreset.BassBoost, "title": "Bass Boost"})
        eqModel.insert({"eid": EqualizerPreset.TrebleBoost, "title": "Treble Boost"})
        eqModel.insert({"eid": EqualizerPreset.VoiceBoost, "title": "Voice Boost"})
        eqModel.insert({"eid": EqualizerPreset.BassLower, "title": "Bass Lower"})
        eqModel.insert({"eid": EqualizerPreset.TrebleLower, "title": "Treble Lower"})
        eqModel.insert({"eid": EqualizerPreset.VoiceLower, "title": "Voice Lower"})
        eqModel.insert({"eid": EqualizerPreset.Acoustic, "title": "Acoustic"})
        eqModel.insert({"eid": EqualizerPreset.Dance, "title": "Dance"})
        eqModel.insert({"eid": EqualizerPreset.Electronic, "title": "Electronic"})
        eqModel.insert({"eid": EqualizerPreset.HipHop, "title": "Hip Hop"})
        eqModel.insert({"eid": EqualizerPreset.Jazz, "title": "Jazz"})
        eqModel.insert({"eid": EqualizerPreset.Lounge, "title": "Lounge"})
        eqModel.insert({"eid": EqualizerPreset.Piano, "title": "Piano"})
        eqModel.insert({"eid": EqualizerPreset.RhythmAndBlues, "title": "Rhythm and Blues"})
        eqModel.insert({"eid": EqualizerPreset.Rock, "title": "Rock"})
        eqModel.insert({"eid": EqualizerPreset.SpokenWord, "title": "Spoken Word"})
        
        currentEq=settings.getBool("savedEq", EqualizerPreset.Off);
        stopOnIncomingCall=settings.getBool("stopIncoming", false);
        stopOnOutgoingCall=settings.getBool("stopOutgoing", false);
        
        phone.callUpdated.connect(_yradio.onCallUpdated);
        _yradio.incomingCall.connect(incomingCall);
        _yradio.outgoingCall.connect(outgoingCall);
    }
    
    attachedObjects: [
        BBMHandler {
            id: bbm
        },
        Phone {
            id: phone
        },
        GroupDataModel {
            id: eqModel
            grouping: ItemGrouping.None
            sortedAscending: true
            sortingKeys: ["eid"]
        },
        Timer {
            id: playStarter
            interval: 100;
            singleShot: true;
            onTimeout: {
                var s=getHlsStream(channel.streams.stream);
                console.debug("*** PlayTick");
                npc.revoke();
                mp.sourceUrl=s[".data"];
                npc.acquire();    
            } 
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
            onPlaybackCompleted: {
                console.debug("Completed")
            }
            onDurationChanged: {
                console.debug("Got duration:"+duration)
            }
            onMetaDataChanged: {
                console.debug("Got metadata: "+JSON.stringify(metaData))
                // npc.setMetaData(metadata)
            }
            onBufferStatusChanged: {
                console.debug("BufferStatus:"+bufferStatus)
                if (bufferStatus==BufferStatus.Playing) {
                    isLoading=false;
                    isLoaded=true;
                } else if (bufferStatus==BufferStatus.Buffering && isLoaded==false) {
                    isLoading=true;
                } else {
                    isLoading=false;
                    isLoaded=false;
                }
            }                       
            onSourceUrlChanged: {
                console.debug("Source set to: "+sourceUrl)
            }
            equalizerPreset: currentEq
        },
        NowPlayingConnection {
            id: npc
            duration: mp.duration
            position: mp.position
            mediaState: mp.mediaState
            iconUrl: "asset:///images/icon.png"
            onAcquired: {
                console.debug("onAcquired")
                
                var metadata = { "title": root.currentChannel, "artist": "YLE Radio" };
                npc.setMetaData(metadata);
                
                console.debug("Asking player to play")
                mp.play();
            }            
            onPause: {
                console.debug("onPause")
                mp.pause();
            }            
            onPlay: {
                console.debug("onPlay")
                mp.play();
            }            
            onRevoked: {
                console.debug("onRevoked")
                mp.stop();
            }
            onStop: {
                console.debug("onStop")
                mp.stop();
                isLoading=false;
                isLoaded=false;
            }
            overlayStyle: OverlayStyle.Fancy
            nextEnabled: false
            previousEnabled: false
        },
        AboutSheet {
            id: aboutSheet
        },
        SettingsSheet {
            id: settingsSheet            
        },
        Sheet {
            id: eqSheet
            Page {
                titleBar: TitleBar {
                    title: qsTr("Equalizer")
                    kind: TitleBarKind.Default
                    dismissAction: ActionItem {
                        title: qsTr("Close");
                        onTriggered: {
                            eqSheet.close();
                        }
                        ActionBar.placement: ActionBarPlacement.Default
                    }
                
                }
                ListView {
                    dataModel: eqModel
                    onTriggered: {
                        var eq = dataModel.data(indexPath);
                        console.debug("EQ: "+eq["eid"])
                        mp.equalizerPreset=eq["eid"];
                        root.currentEq=eq["eid"];
                    }
                    listItemComponents: [
                        ListItemComponent {
                            type: "item"
                            StandardListItem {
                                title: ListItemData.title
                            }
                        }
                    ]
                }
            }
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
    actionBarVisibility: ChromeVisibility.Default
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.Disabled
    actionBarFollowKeyboardPolicy: ActionBarFollowKeyboardPolicy.Default
}
