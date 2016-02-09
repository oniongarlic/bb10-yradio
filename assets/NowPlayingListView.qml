import bb.cascades 1.4

ListView {
    id: nowPlayingList
    
    listItemComponents: [
        ListItemComponent {
            type: "item"
            StandardListItem {
                status: ListItemData.start
                title: ListItemData.artist
                description: ListItemData.title
            }
        }
    ]
}
