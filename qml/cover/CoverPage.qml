import QtQuick 2.0
import Sailfish.Silica 1.0
import SortFilterProxyModel 0.2
import "../components"
import "../constants" 1.0

CoverBackground {
    SortFilterProxyModel {
        id: filteredModel
        sourceModel: status === Cover.Active ? rawModel : null

        sorters: [
            RoleSorter { roleName: "entryState"; sortOrder: Qt.AscendingOrder },
            RoleSorter { roleName: "weight"; sortOrder: Qt.DescendingOrder }
        ]

        filters: [
            AllOf {
                ValueFilter {
                    roleName: "date"
                    value: today
                }
                ValueFilter {
                    roleName: "subState"
                    value: EntrySubState.today
                }
            },
            AnyOf {
                ValueFilter {
                    roleName: "entryState"
                    value: EntryState.todo
                }
                ValueFilter {
                    roleName: "entryState"
                    value: EntryState.ignored
                }
            }
        ]
    }


    SilicaListView {
        id: view
        anchors {
            top: parent.top; topMargin: Theme.paddingMedium
            left: parent.left; leftMargin: Theme.paddingMedium
            right: parent.right; rightMargin: Theme.paddingMedium
            bottom: coverActionArea.top; bottomMargin: Theme.paddingMedium
        }

        VerticalScrollDecorator { id: scrollBar; flickable: view }

        model: filteredModel
        delegate: ListItem {
            id: item
            anchors.topMargin:  Theme.paddingSmall
            height: entryLabel.height + Theme.paddingSmall
            opacity: 1.0 - ((item.y - view.contentY)/view.height * 0.5)

            HighlightImage {
                id: statusIcon
                width: 0.8*Theme.iconSizeExtraSmall
                height: width
                anchors { top: parent.top; topMargin: Theme.paddingSmall }
                color: Theme.primaryColor
                source: {
                    if (entryState === EntryState.todo) "../images/icon-todo-small.png"
                    else if (entryState === EntryState.ignored) "../images/icon-ignored-small.png"
                    else if (entryState === EntryState.done) "../images/icon-done-small.png"
                }
            }

            Label {
                id: entryLabel
                maximumLineCount: 2
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                text: model.text
                truncationMode: TruncationMode.Fade
                anchors { leftMargin: Theme.paddingSmall; left: statusIcon.right; right: parent.right }
            }
        }
    }

    property int currentPageNumber: 1
    property int scrollPerPage: 5

    onCurrentPageNumberChanged: {
        anim.running = false;

        var pos = view.contentY;
        var destPos;

        view.positionViewAtIndex(currentPageNumber*scrollPerPage-scrollPerPage, ListView.Beginning);
        destPos = view.contentY;

        scrollBar.showDecorator();
        anim.from = pos;
        anim.to = destPos;
        anim.running = true;
    }

    NumberAnimation { id: anim; target: view; property: "contentY"; duration: 300 }

    CoverActionList {
        id: coverActionList

        CoverAction {
            iconSource: "image://theme/icon-cover-previous"
            onTriggered: {
                if (currentPageNumber > 1) currentPageNumber -= 1
                else scrollBar.showDecorator();
            }
        }

        CoverAction {
            iconSource: "image://theme/icon-cover-new"
            onTriggered: {
                var dialog = pageStack.push(Qt.resolvedUrl("../pages/AddItemDialog.qml"), { date: main.today },
                                            PageStackAction.Immediate)
                dialog.accepted.connect(function() {
                    addItem(main.today, dialog.text.trim(), dialog.description.trim());
                });
                main.activate();
            }
        }

        CoverAction {
            iconSource: "image://theme/icon-cover-next"
            onTriggered: {
                if (currentPageNumber < (view.count/scrollPerPage)) currentPageNumber += 1;
                else scrollBar.showDecorator();
            }
        }
    }
}
