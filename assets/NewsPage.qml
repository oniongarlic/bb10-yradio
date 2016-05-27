import bb.cascades 1.4
import bb.data 1.0

Page {
    id: news
    
    titleBar: TitleBar {
        title: qsTr("News")
    }
    
    property string rss;
    
    function load() {
        if (articlesDataSource.hasLoaded)
        	return;
        
        articlesDataSource.loadError=false;
        articlesDataSource.load();
    }    
    
    actions: [
        ActionItem {
            id: tmp
            title: qsTr("Refresh")
            onTriggered: {
                articlesDataSource.load();
            }
            ActionBar.placement: ActionBarPlacement.OnBar
            imageSource: "asset:///images/ic_reload.png"
        }
    ]
    
    Container {
        ActivityIndicator {
            id: loadingIndicator
            running: visible
            enabled: true
            visible: !articlesDataSource.hasLoaded && !articlesDataSource.loadError
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center
            preferredWidth: 200.0
            preferredHeight: 200.0
        }
        NetworkError {
            visible: articlesDataSource.loadError
            onRetry: {
                console.log("Retrying NEWS load");
                articlesDataSource.load();                    
            }
        }
        ListView {
            dataModel: articlesDataModel
            visible: !articlesDataSource.loadError
            property variant yr: _yradio;
            listItemComponents: [
                ListItemComponent {
                    type: "item"
                    CustomListItem {
                        id: msli
                        Container {
                            layout: StackLayout {

                            }
                            Label {
                                text: ListItemData.title
                                horizontalAlignment: HorizontalAlignment.Fill
                                autoSize.maxLineCount: 2
                                textStyle.fontSize: FontSize.Large
                                bottomMargin: 2.0
                                textFit.maxFontSizeValue: 12.0
                                textFit.minFontSizeValue: 6.0
                                multiline: true
                            }
                            Label {
                                text: ListItemData.pubDate
                                textFormat: TextFormat.Auto
                                horizontalAlignment: HorizontalAlignment.Fill
                                textStyle.fontSize: FontSize.XSmall
                                textFit.maxFontSizeValue: 10.0
                                topMargin: 2.0
                                textStyle.color: Color.LightGray

                            }
                        }                        
                        // status: msli.ListItem.view.fk.formatDate(ListItemData.PublishDate)
                    }                    
                }
            ]
            
            onTriggered: {
                var feedItem = articlesDataModel.data(indexPath);                
                var page = detailPage.createObject();
                var html = '<html><head><meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1"></head><body>';
                html+='<h1>'+feedItem.title+'</h1>';                
                html+='<div style="width: 100%;">'+feedItem.description+'</div>';
                //if (feedItem.ImageURL)
                //    html+='<img src="'+feedItem.ImageURL+'" />';
                //html+='<div style="width: 100%;">'+feedItem.HTMLContent+'</div>';                
                html+='</body></html>'
                
                page.newsTitle = feedItem.title;
                page.newsDate = feedItem.pubDate;
                page.htmlContent = html;
                np.push(page);
            }
        }
        attachedObjects: [
            GroupDataModel {
                id: articlesDataModel
                //sortingKeys: ["pubDate"]
                //sortedAscending: false
                grouping: ItemGrouping.None
            },
            DataSource {
                id: articlesDataSource
                source: news.rss
                query: "/rss/channel/item"
                type: DataSource.Xml
                property bool hasLoaded: false;
                property bool loadError: false;                                
                
                onDataLoaded: {
                    hasLoaded=true;
                    loadError=false;
                    articlesDataModel.clear();
                    articlesDataModel.insertList(data);
                }
                onError: {
                    loadError=true;
                    hasLoaded=false;
                    console.log("News error [" + errorType + "]: " + errorMessage);
                }
            },
            ComponentDefinition {
                id: detailPage
                NewsDetailsPage {
                    
                }
            }
        ]
        layout: DockLayout {

        }
    }
}
