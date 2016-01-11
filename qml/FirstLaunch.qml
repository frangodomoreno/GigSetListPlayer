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

/********************************************************************************
  InApp Process

  Allow to purchase remote control extention

********************************************************************************/

import QtQuick 2.0
import QtGraphicalEffects 1.0
import QtQuick.Controls 1.3
import QtQuick.Dialogs 1.0
import QtQuick.Layouts 1.1


import "../js/functions.js" as PlTools
import "../js/Database.js" as Db

/*********************************
  In App processing
*********************************/

Rectangle {
    id:firstLaunchHelp
    border.width: 0.5
    border.color: "white"
    radius:5
    color: "grey"
    opacity: .8

    property bool disphelp:false
    property int hlpi:0
    property string imageTypecolorOver: ""
    property var messArray: [qsTr("<br><b><big>Welcome in Setlist Player</b></big><br>Touch next to see tips..."),
                             qsTr("Touch a line in the list to choose the tune to play ..."),
                             qsTr("Touch the top right button to get access to the play and synchronize functions ..."),

                             qsTr("To play audio (if a play back exists) and to start scrolling, touch the Play button..."),
                             qsTr("To synchronize lists, audio files, lyrics and chords with your DropBox, touch the DropBox button..."),

                             qsTr("Swipe to left, or touch Lyrics, to see lyrics ..."),
                             qsTr("The mode button controls the lyrics between page mode and scroll mode ..."),

                             qsTr("This button is shown when the remote command is not plugged in, it allows to control the speed of scrolling or the page change, according to the page mode chosen..."),

                             qsTr("Touch the edit button to modify lyrics ..."),
                             qsTr("Touch less zoom to reduce police size..."),

                             qsTr("Touch center zoom to set the default size..."),
                             qsTr("Touch more zoom to increase size..."),

                             qsTr("This menu gives access to the lyrics scrolling automation (see documentaion for details)..."),

                             qsTr("This Icon give access to chords view (image of pdf in ios) ..."),
                             qsTr("The tool button bellow gives access to global parameters ..."),

                             qsTr("The grid button gives access to list edition..."),        
                             qsTr("The switch button loads another list (full edition only)..."),

                             qsTr("Remote control enabler (full edition only) When it is active (orange colour) you can connect your pedal in BlueTooth mode (see system menu of your device) and then control the speed of scrolling or the page change, according to the page mode chosen..."),
                             qsTr("This Icon, if visible, means that lyrics has been modified and should be saved..."),]

    function displayHelp(){
        if(firstLaunchHelp.hlpi<messArray.length){
            presentation.text=messArray[firstLaunchHelp.hlpi]
            switch(firstLaunchHelp.hlpi) {
            case 1 :
                root.controlPop.color=currentBackGroundColour
                PlTools.tuneClicked(root.tuneModel.get(0).title,0,root.tuneModel.get(0).audioFile,root.tuneModel.get(0).duration,root.tuneModel.get(0).lyricsFile,root.tuneModel.get(0).chordsFile,root.tuneModel.get(0).hasChords)
                root.tuneTitle.color="green"
                root.tunetext.color="green"
                break;
            case 2:                
                if(root.controls.visible){
                    PlTools.controlHideShow(root.controls,
                                               root.controlPop.height,
                                               -root.controls.height ,
                                               root.width - root.controls.width ,
                                               root.width,
                                               root.controls.ctrlanimx,
                                               root.controls.ctrlanimy)
                }

                root.tuneTitle.color=root.currentFontColour
                root.tunetext.color=root.currentFontColour
                root.controlPop.color="green"
                break;

            case 3:
                if(!root.controls.visible)
                    PlTools.controlHideShow(root.controls,
                                               root.controlPop.height,
                                               -root.controls.height ,
                                               root.width - root.controls.width ,
                                               root.width,
                                               root.controls.ctrlanimx,
                                               root.controls.ctrlanimy)

                root.butSync.color=currentBackGroundColour
                root.mousePlay.enabled=false
                root.mouseSync.enabled=false
                root.mouseInfo.enabled=false

                root.butPlay.color="green"
                break;

            case 4:
                if(!root.controls.visible)
                    PlTools.controlHideShow(root.controls,
                                               root.controlPop.height,
                                               -root.controls.height ,
                                               root.width - root.controls.width ,
                                               root.width,
                                               root.controls.ctrlanimx,
                                               root.controls.ctrlanimy)

                root.screensListView.currentIndex=0
                root.butPlay.color=currentBackGroundColour
                root.butSync.color="green"
                break;

            case 5 :
                if(root.scrollOrPageMode.color!=="green")
                    PlTools.controlHideShow(root.controls,
                                               root.controlPop.height,
                                               -root.controls.height ,
                                               root.width - root.controls.width ,
                                               root.width,
                                               root.controls.ctrlanimx,
                                               root.controls.ctrlanimy)
                root.scrollOrPageMode.color=currentBackGroundColour
                root.butSync.color=currentBackGroundColour
                root.controlPop.color=currentBackGroundColour
                root.screensListView.currentIndex=1
                root.headerLabel.color="green"
                break;
            case 6 :
                root.scrollOrPageMode.color="green"
                break;

            case 7 :
                root.scrollOrPageMode.color=currentBackGroundColour
                root.scrollSpeedCtl.visible=true
                break;

            case 8 :
                root.scrollSpeedCtl.visible=false
                root.lyricsEdit.color="green"

                break;
            case 9 :
                root.lyricsEdit.color=currentBackGroundColour
                root.fontsizeLess.color="green"
                break;
            case 10 :
                root.fontsizeLess.color=currentBackGroundColour
                root.fontsizedef.color="green"
                break;
            case 11 :
                if(automations.visible)
                    PlTools.controlHideShow(automations,
                                               controlAutomation.height,
                                               -automations.height ,
                                               root.width - automations.width - controls.width,
                                               root.width,
                                               automations.automanimx,
                                               automations.automanimy)
                root.fontsizedef.color=currentBackGroundColour
                root.controlAutomation.color=currentBackGroundColour
                root.fontsizeMore.color="green"
                break;
            case 12 :
                root.screensListView.currentIndex=1
                root.controlAutomation.color="green"
                root.fontsizeMore.color=currentBackGroundColour
                root.headerLabel.color=root.currentFontColour
                if(!automations.visible)
                    PlTools.controlHideShow(automations,
                                               controlAutomation.height,
                                               -automations.height ,
                                               root.width - automations.width - controls.width,
                                               root.width,
                                               automations.automanimx,
                                               automations.automanimy)
                break;
            case 13 :
                if(automations.visible)
                    PlTools.controlHideShow(automations,
                                               controlAutomation.height,
                                               -automations.height ,
                                               root.width - automations.width - controls.width,
                                               root.width,
                                               automations.automanimx,
                                               automations.automanimy)

                root.controlAutomation.color=currentBackGroundColour
                root.screensListView.currentIndex=0
                root.colorOver.color="green"
                break;
            case 14 :
                root.colorOver.color=firstLaunchHelp.imageTypecolorOver
                root.toolsControl.color="green"
                break;
            case 15 :
                root.toolsControl.color=currentBackGroundColour
                root.csveditor.color="green"
                break;
            case 16 :
                root.csveditor.color=currentBackGroundColour
                root.csvswitch.color="green"
                break;
            case 17 :
                root.csvswitch.color=currentBackGroundColour
                root.remoteActivatio.color="green"
                break;
            case 18 :
                root.remoteActivatio.color=root.remotePluged ? "orange":currentBackGroundColour
                root.lyricsSave.color="green"
                root.lyricsSave.visible=true
                break;
            }
        }
        else{
            root.lyricsSave.color=currentBackGroundColour
            root.lyricsSave.visible=!root.lyricsSave.visible
            root.tuneTitle.color=root.currentFontColour
            root.tunetext.color=root.currentFontColour
            root.mousePlay.enabled=true
            root.mouseSync.enabled=true
            root.mouseInfo.enabled=true

            if(disphelp)
                root.help.visible=true;
            PlTools.modalMode("disabled")
            firstLaunchHelp.destroy() ;
        }
    }

    Component.onCompleted: {
        root.firstLaunchHelp = firstLaunchHelp
        PlTools.modalMode("enabled")
        imageTypecolorOver=root.colorOver.color
    }
    Text {
        id: versionDisplay
        width: firstLaunchHelp.width*.7
        anchors.horizontalCenter: firstLaunchHelp.horizontalCenter
        anchors.topMargin: root.hwratio > 1 ? root.hunit*0.5 : root.vunit*0.5
        anchors.top : firstLaunchHelp.top
        font.pixelSize : textFontSize*.5
        font.family: root.currentLyricsFont
        text:"Gig Setlist Player Version : " + root.currentVersion + "<br>Support : support@monasysinfo.com"
        color:"yellow"
        horizontalAlignment:Text.AlignHCenter
        wrapMode: Text.WordWrap
    }
    Text {
        id: presentation
        width: firstLaunchHelp.width*.7
        anchors.horizontalCenter: firstLaunchHelp.horizontalCenter
        anchors.top:versionDisplay.bottom
        anchors.topMargin: root.hwratio > 1 ? root.hunit*0.5 : root.vunit*0.5
        font.pixelSize : textFontSize*.8
        font.family: root.currentLyricsFont
        //text: qsTr("<br><b><big>Welcome in Setlist Player</b></big><br>Touch next to see next tip...")
        text:messArray[0]
        color:"yellow"
        horizontalAlignment:Text.AlignHCenter
        wrapMode: Text.WordWrap
    }
    /********************************
      Next Button
    *********************************/
    Rectangle {
        id: butNext

        width: root.hunit * 1.5
        height: root.vunit * 1
        anchors.bottom: firstLaunchHelp.bottom
        anchors.bottomMargin: root.hwratio > 1 ? root.hunit*0.5 : root.vunit*0.5
        anchors.horizontalCenter: firstLaunchHelp.horizontalCenter
        color: "grey"
        border.width: 0.5
        radius: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5

        Text  {
            id: nextText
            z:0
            anchors.centerIn: parent
            opacity: 1
            Behavior on opacity {NumberAnimation {duration: 100}}
            color:"yellow"
            text: qsTr("<b><big>Next</b></big>")
        }
        MouseArea {
            id: mousenextText
            enabled: true
            anchors.centerIn: parent
            width: parent.width
            height: parent.height
            hoverEnabled: true
            onClicked: {
                firstLaunchHelp.hlpi+=1
                firstLaunchHelp.displayHelp()
            }
            Rectangle {
                anchors.fill: parent
                opacity: mousenextText.pressed ? 1 : 0
                Behavior on opacity { NumberAnimation{ duration: 100 }}
                gradient: Gradient {
                    GradientStop { position: 0 ; color: "#22000000" }
                    GradientStop { position: 0.2 ; color: "#44000000" }
                }
                border.color: "darkgray"
                radius: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
            }
        }

    }
    /********************************
      Prev Button
    *********************************/
    Rectangle {
        id: butPrev

        width: root.hunit * 1.5
        height: root.vunit * 1
        anchors.bottom: firstLaunchHelp.bottom
        anchors.bottomMargin: root.hwratio > 1 ? root.hunit*0.5 : root.vunit*0.5
        anchors.right: butNext.left
        anchors.rightMargin: root.hwratio > 1 ? root.hunit*1 : root.vunit*1
        color: "grey"
        border.width: 0.5
        radius: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5

        Text  {
            id: prevText
            z:0
            anchors.centerIn: parent
            opacity: 1
            Behavior on opacity {NumberAnimation {duration: 100}}
            color:"yellow"
            text: qsTr("<b><big>Prev.</b></big>")
        }
        MouseArea {
            id: mouseprevText
            enabled: true
            anchors.centerIn: parent
            width: parent.width
            height: parent.height
            hoverEnabled: true
            onClicked: {
                if(firstLaunchHelp.hlpi>0){
                    firstLaunchHelp.hlpi-=1
                    firstLaunchHelp.displayHelp()
                }
            }
            Rectangle {
                anchors.fill: parent
                opacity: mousenextText.pressed ? 1 : 0
                Behavior on opacity { NumberAnimation{ duration: 100 }}
                gradient: Gradient {
                    GradientStop { position: 0 ; color: "#22000000" }
                    GradientStop { position: 0.2 ; color: "#44000000" }
                }
                border.color: "darkgray"
                radius: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
            }
        }

    }
    /********************************
      Stop Button
    *********************************/
    Rectangle {
        id: butStop

        width: root.hunit * 1.5
        height: root.vunit * 1
        anchors.bottom: firstLaunchHelp.bottom
        anchors.bottomMargin: root.hwratio > 1 ? root.hunit*0.5 : root.vunit*0.5
        anchors.left: butNext.right
        anchors.leftMargin:  root.hwratio > 1 ? root.hunit*1 : root.vunit*1
        color: "grey"
        border.width: 0.5
        radius: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5

        Text  {
            id: stopText
            z:0
            anchors.centerIn: parent
            opacity: 1
            Behavior on opacity {NumberAnimation {duration: 100}}
            color:"yellow"
            text: qsTr("<b><big>Stop</b></big>")
        }
        MouseArea {
            id: mousestopText
            enabled: true
            anchors.centerIn: parent
            width: parent.width
            height: parent.height
            hoverEnabled: true
            property string imageTypecolorOver: ""

            onClicked: {
                root.screensListView.currentIndex=0
                root.controlPop.color=currentBackGroundColour
                root.scrollOrPageMode.color=currentBackGroundColour
                root.lyricsEdit.color=currentBackGroundColour
                root.fontsizeLess.color=currentBackGroundColour
                root.fontsizedef.color=currentBackGroundColour
                root.fontsizeMore.color=currentBackGroundColour
                root.headerLabel.color=root.currentFontColour
                root.tuneTitle.color=root.currentFontColour
                root.tunetext.color=root.currentFontColour
                root.colorOver.color=firstLaunchHelp.imageTypecolorOver                
                root.toolsControl.color=currentBackGroundColour
                root.csveditor.color=currentBackGroundColour
                root.csvswitch.color=currentBackGroundColour
                root.butSync.color=currentBackGroundColour
                root.remoteActivatio.color=root.remotePluged ? "orange":currentBackGroundColour
                root.butPlay.color=currentBackGroundColour
                root.lyricsSave.visible=false
                root.lyricsSave.color=currentBackGroundColour
                root.mousePlay.enabled=true
                root.mouseSync.enabled=true
                root.mouseInfo.enabled=true
                root.scrollSpeedCtl.visible=false
                PlTools.modalMode("disabled")
                root.help.visible=true;
                firstLaunchHelp.destroy() ;
            }
            Rectangle {
                anchors.fill: parent
                opacity: mousenextText.pressed ? 1 : 0
                Behavior on opacity { NumberAnimation{ duration: 100 }}
                gradient: Gradient {
                    GradientStop { position: 0 ; color: "#22000000" }
                    GradientStop { position: 0.2 ; color: "#44000000" }
                }
                border.color: "darkgray"
                radius: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
            }
        }

    }

}
