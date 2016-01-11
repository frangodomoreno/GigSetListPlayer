/***********************************************************************************
# Gig Setlist Player
#
# Application Android et iOS pour les musiciens, permettant de créer des setlist de concerts.
#
# Copyright (C) 2015  J-Y Priou MonasysInfo
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
***********************************************************************************/

import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2

Item {
    id: swipeView
    width: swipeZone.width
    property var model
    property alias headersListView : headersListView
    property bool isDesktopPlatform: Qt.platform.os === "windows" ||
                                   Qt.platform.os === "linux" ||
                                   Qt.platform.os === "osx"

    ColumnLayout {
        id:headersListViewLayout
        anchors.fill: parent
        spacing: 0
        //width: swipeZone.width
        property alias headersListView : headersListView

        ListView {
              id: headersListView              
              width: parent.width
              Layout.fillWidth: true
              //Layout.preferredHeight: 16 * Screen.logicalPixelDensity
              Layout.preferredHeight: root.hwratio < 1 ? root.hunit: root.vunit
              orientation: ListView.Horizontal
              boundsBehavior: Flickable.StopAtBounds
              model: swipeView.model
              currentIndex: screensListView.currentIndex


              delegate: Item {
                id:headersListViewDelegate
                width: headerLabel.width + headersListView.height * 0.4
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                Rectangle{
                    width:parent.width
                    height: parent.height * 0.9
                    color: root.currentBackGroundColour
                    //anchors.centerIn: parent

                    Text {
                      id: headerLabel
                      anchors.centerIn: parent
                      text: model.title
                      font.pixelSize: headersListView.height * 0.3
                      font.capitalization: Font.AllUppercase
                      font.family: root.currentListFont
                      color:root.currentFontColour
                      Component.onCompleted: root.headerLabel = headerLabel
                    }
                }

                Rectangle {
                  visible: index !== 0
                  anchors.left: parent.left
                  anchors.verticalCenter: parent.verticalCenter
                  width: 1
                  height: parent.height * 0.4
                  color: "lightgray"
                  //color: "black"
                }

                Rectangle {
                  visible: index !== headersListView.count - 1
                  anchors.right: parent.right
                  anchors.verticalCenter: parent.verticalCenter
                  width: 1
                  height: parent.height * 0.4
                  color: "lightgray"
                  //color: "black"
                }

                Rectangle {
                  anchors.fill: parent
                  opacity: (headerMouseArea.pressed) ? 0.4 : 0
                  //color: "#80c342"
                  color: "lightgray"

                  Behavior on opacity {
                    NumberAnimation {
                      duration: 200
                    }
                  }
                }

                MouseArea {
                  id: headerMouseArea
                  anchors.fill: parent
                  onClicked: screensListView.currentIndex = index
                }
              }

              highlightFollowsCurrentItem: false
              highlight: Item {
                x: headersListView.currentItem.x
                width: headersListView.currentItem.width
                height: stripRectangle.height * 3
                anchors.bottom: parent.bottom

                Behavior on x {
                  NumberAnimation {
                    duration: 300
                  }
                }

                Behavior on width {
                  NumberAnimation {
                    duration: 300
                  }
                }

                Rectangle {
                  anchors.left: parent.left
                  anchors.right: parent.right
                  height: stripRectangle.height * 2
                  //color: "#80c342"
                  color: "lightgray"
                }

                Rectangle {
                  anchors.bottom: parent.bottom
                  anchors.left: parent.left
                  anchors.right: parent.right
                  height: stripRectangle.height
                  //color: "#006325"
                  color:"grey"
                }
              }

              Rectangle {
                id: stripRectangle
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: parent.height * 0.05
                z: -1
                //color: "lightgray"
                color: root.currentBackGroundColour
              }
            }

        ListView {
            id: screensListView

            enabled:!root.automationRecord

            width: parent.width
            Layout.fillWidth: true
            Layout.fillHeight: true
            orientation: ListView.Horizontal
            snapMode: ListView.SnapOneItem
            highlightRangeMode: ListView.StrictlyEnforceRange
            highlightMoveVelocity: 2000
            clip: true            
            model: swipeView.model
            delegate: Loader {
                width: screensListView.width
                height: screensListView.height
                source: model.source
           }
           onCurrentIndexChanged: {
               // 20150619 Activate Specifics lyrics controls
               root.currentPane=currentIndex               
               if(root.pdfDisplay === undefined) {
                    controlAutomation.visible = currentIndex==1
               }
               else {
                    if(currentIndex==1 && !root.pdfDisplay.isChord){
                        root.pdfDisplay.visible=true
                    }
                    else {
                        root.pdfDisplay.visible=false
                     }
               }
               fontsizeLess.visible = currentIndex==1 && (root.pdfDisplay === undefined || root.pdfDisplay.isChord )
           }
           Component.onCompleted: root.screensListView=screensListView
        }
    }
}
