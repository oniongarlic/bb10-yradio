import bb.cascades 1.4

Sheet {
    id: eqSheet
    
    signal equalizerPreset(int eid);
    
    property int currentEq;
    property int previousEq;
    
    onCurrentEqChanged: {
        console.debug("Current EQ is: "+currentEq)
        var i=eqModel.findExact({"eid": currentEq})
        if (i)
            eqList.select(i);
    }
    onCreationCompleted: {
        eqModel.init();
    }
    onOpened: {
        console.debug("EqOpen")
        previousEq=currentEq;
    }
    
    Page {
        titleBar: TitleBar {
            title: qsTr("Equalizer")
            kind: TitleBarKind.Default
            dismissAction: ActionItem {
                title: qsTr("Cancel");
                onTriggered: {
                    currentEq=previousEq;
                    equalizerPreset(currentEq);
                    eqSheet.close();
                }
            }
            acceptAction: ActionItem {
                title: qsTr("Done")
                onTriggered: {
                    eqSheet.close();
                }
            }
        }
        ListView {
            id: eqList
            dataModel: eqModel
            onTriggered: {
                var eq = dataModel.data(indexPath);
                console.debug("EQ: "+eq["eid"]);
                currentEq=eq["eid"];
                equalizerPreset(currentEq);
                clearSelection();
                select(indexPath);
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
    attachedObjects: [
        EqualizerModel {
            id: eqModel
        }
    ]
}