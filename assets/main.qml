import bb.cascades 1.4
import bb.multimedia 1.4
import bb.data 1.0
import bb.system 1.2
import bb.system.phone 1.0
import org.tal 1.0
import org.tal.bbm 1.0
import org.tal.sopomygga 1.0

Page {
    id: root
    
    property string currentChannel: ''
    property variant channel;
    property bool hasChannel: channel==undefined ? true : false
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
        },
        ActionItem {
            id: channelActions
            enabled: hasChannel
            imageSource: "asset:///images/web.png"
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                
            }
        }
    ]
    Container {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        navigation {
            focusPolicy: NavigationFocusPolicy.NotFocusable
        }
        
        OfflineContainer {
            visible: !_yradio.onLine
        }
        
        Container {
            id: videoContainer
            visible: mp.hasVideo
            horizontalAlignment: HorizontalAlignment.Fill
            preferredHeight: fw.preferredHeight
            topMargin: 8.0
            bottomMargin: 8.0
            ForeignWindowControl {
                id: fw
                windowId: "videoWindowId"
                preferredWidth: 640
                preferredHeight: 360
                horizontalAlignment: HorizontalAlignment.Center
                updatedProperties: WindowProperty.Size | WindowProperty.Position | WindowProperty.Visible
                visible: boundToWindow
                onWindowAttached: {
                    console.debug("Attached!")
                }
                onWindowDetached: {
                    console.debug("Detached!")
                }
                verticalAlignment: VerticalAlignment.Center
            }
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
            property alias nowPlayingModel: nowplayingModel
            property alias mainRoot: root
            property alias currentChannel: root.channel
            property alias hasChannel: root.hasChannel
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
                        property bool hasChannel: channel==undefined ? false : true;
                        
                        ImageView {
                            imageSource: "asset:///images/icon.png"
                            horizontalAlignment: HorizontalAlignment.Center
                            topMargin: 16
                            bottomMargin: 16
                            minWidth: 114
                            minHeight: 114
                            maxWidth: 480
                            maxHeight: 480
                            visible: !hasChannel
                        }
                        
                        ActivityIndicator {
                            id: bufferingIndicator
                            minWidth: 96
                            minHeight: 96
                            maxWidth: 128
                            maxHeight: 128
                            visible: running
                            running: nowPlaying.ListItem.view.isLoading
                            horizontalAlignment: HorizontalAlignment.Center
                        }
                        
                        Label {
                            textStyle.textAlign: TextAlign.Center
                            text: channel==undefined ? 'No channel selected' : channel.name
                            horizontalAlignment: HorizontalAlignment.Fill
                            textStyle.color: Color.White
                            textStyle.fontSize: FontSize.XXLarge
                            bottomMargin: 32.0
                            topMargin: 32.0
                        }
                        
                        Label {
                            visible: !hasChannel
                            textStyle.fontSize: FontSize.Large
                            textStyle.color: Color.LightGray
                            horizontalAlignment: HorizontalAlignment.Fill
                            textStyle.textAlign: TextAlign.Center
                            text: qsTr("Swipe left for channels list")
                        }
                        
                        NowPlayingListView {
                            id: nowPlayingList
                            dataModel: nowPlaying.ListItem.view.nowPlayingModel
                            minHeight: 256
                            maxHeight: 512
                            horizontalAlignment: HorizontalAlignment.Fill
                        }
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
        updateNowplaying();
    }
    
    function updateNowplaying() {
        nowplayingModel.clear();
        nowplayingModel.insert({"order": "0", "start": "12:10", "artist": "Dummy Artist", "title": "Songname"})
        nowplayingModel.insert({"order": "1", "start": "12:20", "artist": "Dummy Artti", "title": "NameSong"})
    }
    
    function getHlsStream(m) {
        console.debug("HLS: ")
        console.debug(m)
        if (m.type)
            return m;
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

        currentEq=settings.getBool("savedEq", EqualizerPreset.Off);
        stopOnIncomingCall=settings.getBool("stopIncoming", false);
        stopOnOutgoingCall=settings.getBool("stopOutgoing", false);
        
        phone.callUpdated.connect(_yradio.onCallUpdated);
        _yradio.incomingCall.connect(incomingCall);
        _yradio.outgoingCall.connect(outgoingCall);
        
        var r=mqtt.connectToHost();
        console.debug("R="+r)
    }
    
    attachedObjects: [
        BBMHandler {
            id: bbm
        },
        Phone {
            id: phone
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
            videoOutput: VideoOutput.PrimaryDisplay
            repeatMode: RepeatMode.None
            windowId: fw.windowId
            property bool hasVideo: false;
            onVideoDimensionsChanged: {
                console.debug("Got video dimensions")
                console.debug(videoDimensions.width)
                console.debug(videoDimensions.height)
                hasVideo=(videoDimensions.width>0 && videoDimensions.height>0) ? true : false; 
            }
            onError: {
                console.debug("Error: "+mediaError)
                mediaErrorToast.body="Error: "+mediaError                
                mediaErrorToast.show();
                npc.revoke();
                mp.reset();
                hasVideo=false;
            }
            onMediaStateChanged: {
                console.debug("State: "+mediaState)
                if (mediaState==mediaState.Stopped)
                    hasVideo=false;
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
            onEqualizerPresetChanged: {
                root.currentEq=equalizerPreset;
            }
        },
        NowPlayingConnection {
            id: npc
            duration: mp.duration
            position: mp.position
            mediaState: mp.mediaState
            iconUrl: "asset:///images/icon.png"
            onAcquired: {
                console.debug("onAcquired")
                
                var metadata = { "title": root.currentChannel, "album": "YLE Radio: "+root.currentChannel };
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
        EqualizerSheet {
            id: eqSheet
            currentEq: root.currentEq
            onEqualizerPreset: {
                console.debug("EQP: "+eid)
                mp.equalizerPreset=eid;
            }
        },
        SystemToast {
            id: mediaErrorToast            
            position: SystemUiPosition.MiddleCenter
            modality: SystemUiModality.Application
        },
        GroupDataModel {
            id: nowplayingModel
            grouping: ItemGrouping.ByFullValue
            sortingKeys: ["order"]
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
        },
        GroupDataModel {
              id: songInfo  
        },
        MQTT {
            id: mqtt
            keepalive: 60
            clientId: "talorg-bb10-yradio-"+_yradio.getUUID(); // XXX Need a unique client id somehow???
            //clientId: "talorg-bb10-yradio"
            hostname: "amos.tal.org"
            onConnected: {
                console.debug("MQTT Connected")
                subscribe("radio/#")
            }
            onDisconnected: {
                console.debug("MQTT Disconnected")
            }
            onConnecting: {
                console.debug("MQTT Connecting")
            }
            onMsg: {
                console.debug("Topic:"+topic)
            }
            onError: {
                console.debug("MQTT Error")
            }
        }
    ]
    actionBarVisibility: ChromeVisibility.Default
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.Disabled
    actionBarFollowKeyboardPolicy: ActionBarFollowKeyboardPolicy.Default
}
