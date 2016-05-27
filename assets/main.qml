import bb.cascades 1.4
import bb.multimedia 1.4
import bb.data 1.0
import bb.system 1.2
import bb.system.phone 1.0
import org.tal 1.0
import org.tal.bbm 1.0
import org.tal.sopomygga 1.0

NavigationPane {
    id: np
    onPopTransitionEnded: page.destroy();
    
    property variant channel;
    property string currentChannel: ''
    property string newsUrl: ''
    
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
        /*
        settingsAction: SettingsActionItem {
            title: qsTr("Settings")
            onTriggered: {
                settingsSheet.open();                
            }
        }
        */
    }
    
    Page {
        id: root        
        titleBar: TitleBar {
            title: root.getActiveTitle(listScroll.firstVisibleItem[0], currentChannel)
            scrollBehavior: TitleBarScrollBehavior.Default
        }
        
        function getActiveTitle(vid, cc) {
            switch (vid) {
                case 0:
                    return cc=='' ? "Y-Radio" : "Y-Radio - "+cc
                case 1:
                    return qsTr("Channels")
                default:
                    return "Y-Radio"
            
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
                enabled: np.newsUrl=='' ? false : true
                imageSource: "asset:///images/web.png"
                ActionBar.placement: ActionBarPlacement.InOverflow
                title: qsTr("News")
                onTriggered: {
                    var newsPage=newsComponent.createObject();
                    newsPage.rss=np.newsUrl;
                    newsPage.load();
                    np.push(newsPage);
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
                visible: mp.hasVideo && _yradio.onLine
                horizontalAlignment: HorizontalAlignment.Fill
                preferredHeight: fw.preferredHeight
                topMargin: 8.0
                bottomMargin: 8.0
                
                property int scale: 1;
                property int activeScale: listScroll.firstVisibleItem[0]==0 ? scale : 2;
                
                ForeignWindowControl {
                    id: fw
                    windowId: "videoWindowId"
                    preferredWidth: 640/videoContainer.activeScale
                    preferredHeight: 368/videoContainer.activeScale
                    minHeight: 180
                    maxHeight: mainListView.actualWidth/ratio
                    minWidth: 320
                    maxWidth: mainListView.actualWidth
                    visible: videoContainer.visible && boundToWindow
                    
                    property double ratio: 640/368;
                    
                    horizontalAlignment: HorizontalAlignment.Center
                    verticalAlignment: VerticalAlignment.Center
                    updatedProperties: WindowProperty.Size | WindowProperty.Position | WindowProperty.Visible
                    
                    onWindowAttached: {
                        console.debug("Attached!")
                    }
                    onWindowDetached: {
                        console.debug("Detached!")
                    }
                }
                gestureHandlers: [
                    TapHandler {
                        onTapped: {
                            console.debug("VCSTapped")
                            if (videoContainer.scale==1)
                                videoContainer.scale=2
                            else 
                                videoContainer.scale=1;
                        }
                    }
                ]
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
                property alias currentChannel: np.channel
                property alias hasChannel: np.hasChannel
                property alias isLoading: np.isLoading
                property alias isVideo: mp.hasVideo
                
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
                                //bottomPadding: 64.0
                                horizontalAlignment: HorizontalAlignment.Fill
                                stickToEdgePolicy: ListViewStickToEdgePolicy.Default
                                margin.bottomOffset: 1.0
                                onChannelSelected: {
                                    radioList.ListItem.view.channelSelected(data)
                                }
                                onRequestUrl: {
                                    radioList.ListItem.view.openUrl(url)
                                }
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
                                visible: !nowPlaying.ListItem.view.isVideo
                                preferredHeight: preferredWidth
                                preferredWidth: hasChannel ? 128 : 480;
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
                                visible: !hasChannel
                                textStyle.textAlign: TextAlign.Center
                                text: qsTr('No channel selected')
                                horizontalAlignment: HorizontalAlignment.Fill
                                textStyle.color: Color.White
                                textStyle.fontSize: FontSize.XXLarge
                                bottomMargin: 32.0
                                topMargin: 32.0
                            }
                            
                            Label {
                                // visible: !hasChannel
                                textStyle.fontSize: FontSize.Large
                                textStyle.color: Color.LightGray
                                horizontalAlignment: HorizontalAlignment.Fill
                                textStyle.textAlign: TextAlign.Center
                                text: qsTr("Swipe left for channels list")
                            }
                            
                            NowPlayingListView {
                                id: nowPlayingList
                                visible: false
                                dataModel: nowPlaying.ListItem.view.nowPlayingModel
                                minHeight: 256
                                maxHeight: 512
                                horizontalAlignment: HorizontalAlignment.Fill
                                attachedObjects: [
                                    ListScrollStateHandler {
                                        onAtBeginningChanged: {
                                            console.debug("NPS: "+atBeginning)
                                        }
                                    }
                                ]
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
                            mainListView.actualWidth = layoutFrame.width;
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
            if (data.news) {
                console.debug(data.news)
                np.newsUrl=data.news;
            } else {
                np.newsUrl='';
            }
            updateNowplaying();
        }
        
        function updateNowplaying() {
            nowplayingModel.clear();
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
                    var s=root.getHlsStream(channel.streams.stream);
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
                onHasVideoChanged: {
                    console.debug("HasVideo: "+hasVideo)
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
                    console.debug("MediaState: "+mediaState)
                    // Hide video screen if we are not playing
                    switch (mediaState) {
                        case MediaState.Stopped:
                        case MediaState.Unprepared:
                            hasVideo=false;
                            break;
                        default:
                            console.debug("Unhandled state!")
                            break;
                    }
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
                    np.currentEq=equalizerPreset;
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
                currentEq: np.currentEq
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
            ComponentDefinition {
                id: newsComponent
                NewsPage {
                    id: news
                    onCreationCompleted: {
                        news.load();
                    }
                }               
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
                clientId: "talorg-bb10-yradio-"+_yradio.getUUID();
                hostname: "mqtt.tal.org" // XXX: Use dedicated name
                // XXX
                // username: "yradiobb10"
                // password: "a!Very!Secret!Password!"
                onConnected: {
                    console.debug("MQTT Connected")
                    subscribe("radio/yle/#")
                }
                onDisconnected: {
                    console.debug("MQTT Disconnected")
                }
                onConnecting: {
                    console.debug("MQTT Connecting")
                }
                onMsg: {
                    console.debug("Topic:"+topic)
                    if (currentChannel=='')
                        return;
                    var ctopic="radio/yle/"+currentChannel+"/0/";
                    if (topic.indexOf(ctopic)==0) {
                        //songInfo.insert(item);
                    }
                
                }
                onError: {
                    console.debug("MQTT Error")
                }
            }
        ]
        actionBarVisibility: ChromeVisibility.Default
        actionBarAutoHideBehavior: ActionBarAutoHideBehavior.Default
        actionBarFollowKeyboardPolicy: ActionBarFollowKeyboardPolicy.Default
    }
}