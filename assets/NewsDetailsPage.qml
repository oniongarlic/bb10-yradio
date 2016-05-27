import bb.cascades 1.2

Page {
    property alias htmlContent: detailView.html
    property alias newsTitle: newsTitleBar.title
    property alias newsDate: newsDateLabel.text  

    
    titleBar: TitleBar {
        id: newsTitleBar
        appearance: TitleBarAppearance.Default
        scrollBehavior: TitleBarScrollBehavior.NonSticky
    }                    
    
    Container {
        implicitLayoutAnimationsEnabled: false
        Label {
            id: newsDateLabel
            textStyle.fontSize: FontSize.Medium
            horizontalAlignment: HorizontalAlignment.Fill            
        }
        ScrollView {
            id: scrollView
            scrollViewProperties.scrollMode: ScrollMode.Vertical
            scrollViewProperties.overScrollEffectMode: OverScrollEffectMode.OnPinchAndScroll
            scrollViewProperties.pinchToZoomEnabled: true
            scrollViewProperties.minContentScale: 1.0
            scrollViewProperties.maxContentScale: 10.0
            layoutProperties: StackLayoutProperties {
                spaceQuota: 1.0
            }
            verticalAlignment: VerticalAlignment.Fill
            horizontalAlignment: HorizontalAlignment.Fill
            implicitLayoutAnimationsEnabled: false
            WebView {
                id: detailView
                settings.javaScriptEnabled: false
                settings.minimumFontSize: 18
                settings.defaultFontSize: 22
                settings.binaryFontDownloadingEnabled: false
                horizontalAlignment: HorizontalAlignment.Fill
                onMinContentScaleChanged: {
                    scrollView.scrollViewProperties.minContentScale = minContentScale;
                }
                
                onMaxContentScaleChanged: {
                    scrollView.scrollViewProperties.maxContentScale = maxContentScale;
                }
                settings.zoomToFitEnabled: true
                verticalAlignment: VerticalAlignment.Fill
                implicitLayoutAnimationsEnabled: false
            }
        }
    }
}
