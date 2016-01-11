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
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2

import "../js/functions.js" as PlTools

Item {
    id:toolMenu
    property alias toolsAccess: rootToolsAccess
    property alias fontDialog: fontDialog
    property alias colorDialog: colorDialog
    property bool tosave: false

    /********************************************
     Tools Menu
    *********************************************/
    Rectangle{
       id:rootToolsAccess
       height: root.height - controlPop.height - toolsControl.height
       width: root.width

       property alias toolsanimy: toolsanimy
       property alias toolsanimx: toolsanimx

       visible:false
       color:root.currentBackGroundColour
       ////z:0
       y: root.height
       x: 0

       radius:root.hwratio < 1 ? root.hunit/10  : root.vunit/10
       border.color: "gray"
       border.width: 2
       property bool showhide: false
       NumberAnimation on y {
                       id:toolsanimy
                       property real begin: root.height
                       property real end : controlPop.height
                       from: begin; to: end
                       duration:500
                       easing.type: Easing.OutBack
                       easing.amplitude: 2.0
                       easing.period: 1.5
               }

       NumberAnimation on x {
               id:toolsanimx
               property real begin: 0
               property real end : 0
               from: begin
               to: end
               duration:500
               easing.type: Easing.OutBack
               easing.amplitude: 2.0
               easing.period: 1.5
       }
       GridLayout {
           id:toolsAccess
           columns: 5
           anchors.centerIn: parent

           /********************************
             Change font size of tune list
           *********************************/
           Text{
               id:changeFontListLabel
               text:qsTr("Change menu font")   
               color: "white"
               width:font.pixelSize*text.length
           }

           Rectangle {
               id: changeFontList

               width: root.hunit/2
               height: root.vunit /2
               color: "grey"
               border.width: 0.5
               border.color: "white"
               radius: root.hwratio < 1 ? root.hunit/10 : root.vunit / 10

               Image {
                   source: "../images/menu_dot_x32.png"
                   anchors.fill:parent
                   anchors.centerIn: parent
                   fillMode: Image.PreserveAspectFit
               }
               MouseArea {
                   id: mousechangeFontList
                   enabled: true
                   anchors.centerIn: parent
                   width: parent.width
                   height: parent.height
                   hoverEnabled: true
                   onClicked: {
                       tosave=true
                       fontDialog.fontTtargetProperty="root.currentListFont"
                       fontDialog.open()
                   }
                   Rectangle {
                       anchors.fill: parent
                       opacity: mousechangeFontList.pressed ? 1 : 0
                       Behavior on opacity { NumberAnimation{ duration: 100 }}
                       gradient: Gradient {
                           GradientStop { position: 0 ; color: "#22000000" }
                           GradientStop { position: 0.2 ; color: "#11000000" }
                       }
                       border.color: "darkgray"
                       radius: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
                   }
               }
           }
           /*********************************
             separators
           **********************************/
           Text{
               text:"       "
           }
           /********************************
             Change list font colour
           *********************************/
           Text{
               id:changeFontListColourLabel
               text:qsTr("Change menu colour")   
               color: "white"
               width:font.pixelSize*text.length
           }

           Rectangle {
               id: changeFontListColour
               width: root.hunit/2
               height: root.vunit /2
               color: "grey"
               border.width: 0.5
               border.color: "white"
               radius: root.hwratio < 1 ? root.hunit/10 : root.vunit / 10

               Image {
                   source: "../images/menu_dot_x32.png"
                   anchors.fill:parent
                   anchors.centerIn: parent
                   fillMode: Image.PreserveAspectFit
               }


               MouseArea {
                   id: mousechangeFontListColour
                   enabled: true
                   anchors.centerIn: parent
                   width: parent.width
                   height: parent.height
                   hoverEnabled: true
                   onClicked: {
                       tosave=true
                       colorDialog.colourTtargetProperty="root.currentFontColour"
                       colorDialog.open()
                   }
                   Rectangle {
                       anchors.fill: parent
                       opacity: mousechangeFontListColour.pressed ? 1 : 0
                       Behavior on opacity { NumberAnimation{ duration: 100 }}
                       gradient: Gradient {
                           GradientStop { position: 0 ; color: "#22000000" }
                           GradientStop { position: 0.2 ; color: "#11000000" }
                       }
                       border.color: "darkgray"
                       radius: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
                   }
               }
           }
           /*********************************
             separators
           **********************************/
           Text{
               text:""
           }

           Text{
               text:""
           }
           Text{
               text:""
           }
           Text{
               text:""
           }

           Text{
               text:""
           }

           /********************************
             Change font size of Lyrics
           *********************************/
           Text{
               id:changeFontLyricsLabel
               text:qsTr("Change Lyrics font") 
               color: "white"
               width:font.pixelSize*text.length
           }

           Rectangle {
               id: changeFontLyrics
               width: root.hunit/2
               height: root.vunit /2
               color: "grey"
               border.width: 0.5
               border.color: "white"
               radius: root.hwratio < 1 ? root.hunit/10 : root.vunit / 10

               Image {
                   source: "../images/menu_dot_x32.png"
                   anchors.fill:parent
                   anchors.centerIn: parent
                   fillMode: Image.PreserveAspectFit
               }

               MouseArea {
                   id: mousechangeFontLyrics
                   enabled: true
                   anchors.centerIn: parent
                   width: parent.width
                   height: parent.height
                   hoverEnabled: true
                   onClicked: {
                       tosave=true
                       fontDialog.fontTtargetProperty="root.currentLyricsFont"
                       fontDialog.open()
                   }
                   Rectangle {
                       anchors.fill: parent
                       opacity: mousechangeFontLyrics.pressed ? 1 : 0
                       Behavior on opacity { NumberAnimation{ duration: 100 }}
                       gradient: Gradient {
                           GradientStop { position: 0 ; color: "#22000000" }
                           GradientStop { position: 0.2 ; color: "#11000000" }
                       }
                       border.color: "darkgray"
                       radius: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
                   }
               }
           }
           /*********************************
             separators
           **********************************/
           Text{
               text:"       "
           }

           /********************************
             Change lyrics font colour
           *********************************/
           Text{
               id:changeLyricsColourLabel
               text:qsTr("Change lyrics colour")
               color: "white"
               width:font.pixelSize*text.length
           }
           Rectangle {
               id: changeLyricsColour
               width: root.hunit/2
               height: root.vunit /2
               color: "grey"
               border.width: 0.5
               border.color: "white"
               radius: root.hwratio < 1 ? root.hunit/10 : root.vunit / 10

               Image {
                   source: "../images/menu_dot_x32.png"
                   anchors.fill:parent
                   anchors.centerIn: parent
                   fillMode: Image.PreserveAspectFit
               }

               MouseArea {
                   id: mousechangeLyricsColour
                   enabled: true
                   anchors.centerIn: parent
                   width: parent.width
                   height: parent.height
                   hoverEnabled: true
                   onClicked: {
                       tosave=true
                       colorDialog.colourTtargetProperty="root.currentLyricsFontColour"
                       colorDialog.open()
                   }
                   Rectangle {
                       anchors.fill: parent
                       opacity: mousechangeLyricsColour.pressed ? 1 : 0
                       Behavior on opacity { NumberAnimation{ duration: 100 }}
                       gradient: Gradient {
                           GradientStop { position: 0 ; color: "#22000000" }
                           GradientStop { position: 0.2 ; color: "#11000000" }
                       }
                       border.color: "darkgray"
                       radius: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
                   }
               }
           }

           /*********************************
             separators
           **********************************/
           Text{
               text:""
           }

           Text{
               text:""
           }
           Text{
               text:""
           }
           Text{
               text:""
           }

           Text{
               text:""
           }
           /********************************
             Change backgroung color
           *********************************/
           Text{
               id:changeBackgroundColourLabel
               text:qsTr("Change BackGround colour")
               color: "white"
               width:font.pixelSize*text.length
           }
           Rectangle {
               id: changeBackgroundColour
               width: root.hunit/2
               height: root.vunit /2
               color: "grey"
               border.width: 0.5
               border.color: "white"
               radius: root.hwratio < 1 ? root.hunit/10 : root.vunit / 10

               Image {
                   source: "../images/menu_dot_x32.png"
                   anchors.fill:parent
                   anchors.centerIn: parent
                   fillMode: Image.PreserveAspectFit
               }

               MouseArea {
                   id: mousechangeBackgroundColour
                   enabled: true
                   anchors.centerIn: parent
                   width: parent.width
                   height: parent.height
                   hoverEnabled: true
                   onClicked: {
                       tosave=true
                       colorDialog.colourTtargetProperty="root.currentBackGroundColour"
                       colorDialog.open()
                   }
                   Rectangle {
                       anchors.fill: parent
                       opacity: mousechangeBackgroundColour.pressed ? 1 : 0
                       Behavior on opacity { NumberAnimation{ duration: 100 }}
                       gradient: Gradient {
                           GradientStop { position: 0 ; color: "#22000000" }
                           GradientStop { position: 0.2 ; color: "#11000000" }
                       }
                       border.color: "darkgray"
                       radius: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
                   }
               }
           }
           /*********************************
             separators
           **********************************/
           Text{
               text:"       "
           }

           /********************************
             Change to default color and font
           *********************************/
           Text{
               id:changetoDefaultLabel
               text:qsTr("Load default values")    
               color: "white"
               width:font.pixelSize*text.length
           }

           Rectangle {
               id: changetoDefault
               width: root.hunit/2
               height: root.vunit /2
               color: "grey"
               border.width: 0.5
               border.color: "white"
               radius: root.hwratio < 1 ? root.hunit/10 : root.vunit / 10

               Image {
                   source: "../images/menu_dot_x32.png"
                   anchors.fill:parent
                   anchors.centerIn: parent
                   fillMode: Image.PreserveAspectFit
               }

               MouseArea {
                   id: mousechangetoDefault
                   enabled: true
                   anchors.centerIn: parent
                   width: parent.width
                   height: parent.height
                   hoverEnabled: true
                   onClicked: {                       
                       root.currentBackGroundColour=root.defaultBackGroundColour
                       root.currentFontColour=root.defaultFontColour
                       root.currentLyricsFontColour=root.defaultFontColour
                       root.currentLyricsFont=root.defaultLyricsFont
                       root.currentListFont=root.defaultListFont
                   }
                   Rectangle {
                       anchors.fill: parent
                       opacity: mousechangetoDefault.pressed ? 1 : 0
                       Behavior on opacity { NumberAnimation{ duration: 100 }}
                       gradient: Gradient {
                           GradientStop { position: 0 ; color: "#22000000" }
                           GradientStop { position: 0.2 ; color: "#11000000" }
                       }
                       border.color: "darkgray"
                       radius: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
                   }
               }
           }
           /*********************************
             separators
           **********************************/
           Text{
               text:""
           }

           Text{
               text:""
           }
           Text{
               text:""
           }
           Text{
               text:""
           }

           Text{
               text:""
           }

           /********************************
             Choose default lyrics mode : page or scroll
           *********************************/
           Text{
               id:defaultLyricsModeLabel
               text:qsTr("Choose default lyrics mode")
               color: "white"
               width:font.pixelSize*text.length
           }
           Rectangle {
               id: defaultLyricsMode
               width: root.hunit/2
               height: root.vunit /2
               color: "grey"
               border.width: 0.5
               border.color: "white"
               radius: root.hwratio < 1 ? root.hunit/10 : root.vunit / 10

               Image {
                   source: "../images/menu_dot_x32.png"
                   anchors.fill:parent
                   anchors.centerIn: parent
                   fillMode: Image.PreserveAspectFit
               }
               MouseArea {
                   id: mousedefaultLyricsMode
                   enabled: true
                   anchors.centerIn: parent
                   width: parent.width
                   height: parent.height
                   hoverEnabled: true
                   onClicked: {                       
                       tosave=true
                       lyricsModeChoice.visible=true
                   }
                   Rectangle {
                       anchors.fill: parent
                       opacity: mousedefaultLyricsMode.pressed ? 1 : 0
                       Behavior on opacity { NumberAnimation{ duration: 100 }}
                       gradient: Gradient {
                           GradientStop { position: 0 ; color: "#22000000" }
                           GradientStop { position: 0.2 ; color: "#11000000" }
                       }
                       border.color: "darkgray"
                       radius: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
                   }
               }
           }
           /*********************************
             separators
           **********************************/
           Text{
               text:"       "
           }
           /********************************
             Choose default increment for scrolling (default 10%)
           *********************************/
           Text{
               id:defaultScrollIncLabel
               text:qsTr("Choose default scroll speed control")
               color: "white"
               width:font.pixelSize*text.length
           }
           Rectangle {
               id: defaultScrollInc
               width: root.hunit/2
               height: root.vunit /2
               color: "grey"
               border.width: 0.5
               border.color: "white"
               radius: root.hwratio < 1 ? root.hunit/10 : root.vunit / 10

               Image {
                   source: "../images/menu_dot_x32.png"
                   anchors.fill:parent
                   anchors.centerIn: parent
                   fillMode: Image.PreserveAspectFit
               }
               MouseArea {
                   id: mousedefaultScrollInc
                   enabled: true
                   anchors.centerIn: parent
                   width: parent.width
                   height: parent.height
                   hoverEnabled: true
                   onClicked: {
                       tosave=true
                       switch(scrollVariation){
                            case .1 :
                                tenpercent.checked=true
                                break
                            case .2 :
                                twentypercent.checked=true
                                break
                            case .3 :
                                thirtypercent.checked=true
                                break
                            case .4 :
                                fourtypercent.checked=true
                                break
                            case .5 :
                                fiftypercent.checked=true
                                break
                       }
                       scrollIncChoice.visible=true
                   }
                   Rectangle {
                       anchors.fill: parent
                       opacity: mousedefaultScrollInc.pressed ? 1 : 0
                       Behavior on opacity { NumberAnimation{ duration: 100 }}
                       gradient: Gradient {
                           GradientStop { position: 0 ; color: "#22000000" }
                           GradientStop { position: 0.2 ; color: "#11000000" }
                       }
                       border.color: "darkgray"
                       radius: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
                   }
               }
           }

          /*********************************
            separators
          **********************************/
          Text{
              text:""
          }
          Text{
              text:""
          }
          Text{
              text:""
          }
          Text{
              text:""
          }
          Text{
              text:""
          }
          /********************************
            Enabled default Remote Mode
          *********************************/
          Text{
              id:remoteModeEnablerLabel
              text:qsTr("Set default remote mode (enabled/disabled)")
              color: "white"
              width:font.pixelSize*text.length
          }
          Rectangle {
              id: remoteModeEnabler
              width: root.hunit/2
              height: root.vunit /2
              color: remotePluged ? "green" : "grey"
              border.width: 0.5
              border.color: "white"
              //radius: root.hwratio < 1 ? root.hunit/5 : root.vunit / 5

              MouseArea {
                  id: mouseremoteModeEnabler
                  enabled: true
                  anchors.centerIn: parent
                  width: parent.width
                  height: parent.height
                  hoverEnabled: true
                  onClicked: {
                      remoteControlSettings.settingsRemotePluged=!remoteControlSettings.settingsRemotePluged
                      remotePluged=remoteControlSettings.settingsRemotePluged && !liteMode
                      remoteActivatio.color = remotePluged ? "green" : currentBackGroundColour
                  }
                  Rectangle {
                      anchors.fill: parent
                      opacity: remoteModeEnabler.pressed ? 1 : 0
                      Behavior on opacity { NumberAnimation{ duration: 100 }}
                      gradient: Gradient {
                          GradientStop { position: 0 ; color: "#22000000" }
                          GradientStop { position: 0.2 ; color: "#11000000" }
                      }
                      border.color: "darkgray"
                      radius: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
                  }
              }
          }

         /*********************************
           separators
         **********************************/
         Text{
             text:""
         }
           /********************************
             SAVE SETTINGS
           *********************************/
           Text{
               id:saveSettingsLabel
               text:qsTr("Save Current Settings")
               color: "white"
               width:font.pixelSize*text.length
           }
           Rectangle {
               id: saveSettings
               width: root.hunit/2
               height: root.vunit /2
               color: tosave == true ? "red" : "grey"
               border.width: 0.5
               border.color: "white"
               radius: root.hwratio < 1 ? root.hunit/10 : root.vunit / 10

               Image {
                   source: "../images/Save_icon_64.png"
                   anchors.fill:parent
                   anchors.centerIn: parent
                   fillMode: Image.PreserveAspectFit
               }

               MouseArea {
                   id: mousesaveSettings
                   enabled: true
                   anchors.centerIn: parent
                   width: parent.width
                   height: parent.height
                   hoverEnabled: true
                   onClicked: {
                       tosave=false
                       fontsAndColourSettings.settingBackGroundColour=currentBackGroundColour
                       fontsAndColourSettings.settingLyricsFontColour=currentLyricsFontColour
                       fontsAndColourSettings.settingLyricsFont=currentLyricsFont
                       fontsAndColourSettings.settingFontColour=currentFontColour
                       fontsAndColourSettings.settingListFont=currentListFont
                       pagemodeSetting.pagemodeSet=pageMode
                       pagemodeSetting.scrollInc=scrollVariation

                   }
                   Rectangle {
                       anchors.fill: parent
                       opacity: mousesaveSettings.pressed ? 1 : 0
                       Behavior on opacity { NumberAnimation{ duration: 100 }}
                       gradient: Gradient {
                           GradientStop { position: 0 ; color: "#22000000" }
                           GradientStop { position: 0.2 ; color: "#11000000" }
                       }
                       border.color: "darkgray"
                       radius: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
                   }
               }
           }

           /*********************************
             separators
           **********************************/
           Text{
               text:""
           }
           Text{
               text:""
           }
           Text{
               text:""
           }
           Text{
               text:""
           }
           Text{
               text:""
           }

//           /*********************************
//             separators
//           **********************************/
//           Text{
//               text:""
//           }
//           Text{
//               text:""
//           }
           /*********************************
             separators
           **********************************/
           Text{
               text:""
           }
           Text{
               text:""
           }
           Text{
               text:""
           }
           Text{
               text:""
           }
           Text{
               text:""
           }
           /********************************
             Delete files in the current list
           *********************************/
           Text{
               id:deleteFilesInCurrentPlaylistLabel
               text:qsTr("Delete all files in the current list")
               color: "white"
               width:font.pixelSize*text.length
           }
           Rectangle {
               id: deleteFilesInCurrentPlaylist
               width: root.hunit/2
               height: root.vunit /2
               color: "grey"
               border.width: 0.5
               border.color: "white"
               radius: root.hwratio < 1 ? root.hunit/10 : root.vunit / 10

               Image {
                   source: "../images/menu_dot_x32.png"
                   anchors.fill:parent
                   anchors.centerIn: parent
                   fillMode: Image.PreserveAspectFit
               }

               MouseArea {
                   id: mousedeleteFilesInCurrentPlaylist
                   enabled: true
                   anchors.centerIn: parent
                   width: parent.width
                   height: parent.height
                   hoverEnabled: true
                   onClicked: {
                       // TODO DELETE THE CSV FILE AND ALL FILES REFERENCED INSIDE
                       messageDialog.setText(qsTr("Are you sure ?"))
                       messageDialog.visible=true
                       messageDialog.buttonOK=true
                       messageDialog.action=2
                   }
                   Rectangle {
                       anchors.fill: parent
                       opacity: deleteFilesInCurrentPlaylist.pressed ? 1 : 0
                       Behavior on opacity { NumberAnimation{ duration: 100 }}
                       gradient: Gradient {
                           GradientStop { position: 0 ; color: "#22000000" }
                           GradientStop { position: 0.2 ; color: "#11000000" }
                       }
                       border.color: "darkgray"
                       radius: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
                   }
               }
           }
           /*********************************
             separators
           **********************************/
           Text{
               text:"       "
           }
           /********************************
             Delete current list file (csv file)
           *********************************/
           Text{
               id:deleteCurrentPlaylistLabel
               text:qsTr("Delete the current list")
               color: "white"
               width:font.pixelSize*text.length
           }
           Rectangle {
               id: deleteCurrentPlaylist
               width: root.hunit/2
               height: root.vunit /2
               color: "grey"
               border.width: 0.5
               border.color: "white"
               radius: root.hwratio < 1 ? root.hunit/10 : root.vunit / 10

               Image {
                   source: "../images/menu_dot_x32.png"
                   anchors.fill:parent
                   anchors.centerIn: parent
                   fillMode: Image.PreserveAspectFit
               }


               MouseArea {
                   id: mousedeleteCurrentPlaylist
                   enabled: true
                   anchors.centerIn: parent
                   width: parent.width
                   height: parent.height
                   hoverEnabled: true
                   onClicked: {
                       // TODO DELETE THE CSV FILE AND ALL FILES REFERENCED INSIDE

                       messageDialog.setText(qsTr("Are you sure ?"))
                       messageDialog.visible=true
                       messageDialog.buttonOK=true
                       messageDialog.action=3
                   }
                   Rectangle {
                       anchors.fill: parent
                       opacity: mousedeleteCurrentPlaylist.pressed ? 1 : 0
                       Behavior on opacity { NumberAnimation{ duration: 100 }}
                       gradient: Gradient {
                           GradientStop { position: 0 ; color: "#22000000" }
                           GradientStop { position: 0.2 ; color: "#11000000" }
                       }
                       border.color: "darkgray"
                       radius: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
                   }
               }
           }
        }

       /**************************************
         Scroll mode choice (page or scrolling)
       ***************************************/
       Rectangle{
           id:lyricsModeChoice
           visible: false
           height:parent.height*.2
           width:parent.width*.2
           anchors.centerIn: parent
           color:"grey"
           radius: root.hwratio < 1 ? root.hunit/10 : root.vunit / 10
           opacity: .95
           border.color: "white"
           GridLayout{
               anchors.centerIn: parent
               columns: 3
               Text{
                   text:qsTr("Scroll mode")
                   color:"white"
               }
               Text{
                   text:"   "
               }
               Text{
                   text:qsTr("Page mode")
                   color:"white"
               }

               Rectangle {
                   id: scrollIconMode
                   width: root.hunit/2
                   height: root.vunit /2
                   color: "grey"
                   border.width: 0.5
                   border.color: "white"
                   radius: root.hwratio < 1 ? root.hunit/10 : root.vunit / 10

                   Image {
                       source: "../images/scrollmode_x64.png"
                       anchors.fill:parent
                       anchors.centerIn: parent
                       fillMode: Image.PreserveAspectFit
                   }

                   MouseArea {
                       id: mousescrollIconMode
                       enabled: true
                       anchors.centerIn: parent
                       width: parent.width
                       height: parent.height
                       hoverEnabled: true
                       onClicked: {
                           pageMode=false
                           lyricsModeChoice.visible=false
                       }
                       Rectangle {
                           anchors.fill: parent
                           opacity: mousescrollIconMode.pressed ? 1 : 0
                           Behavior on opacity { NumberAnimation{ duration: 100 }}
                           gradient: Gradient {
                               GradientStop { position: 0 ; color: "#22000000" }
                               GradientStop { position: 0.2 ; color: "#11000000" }
                           }
                           border.color: "darkgray"
                           radius: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
                       }
                   }
               }
               Text{
                   text:"      "
               }

               Rectangle {
                   id: pageIconMode
                   width: root.hunit/2
                   height: root.vunit /2
                   color: "grey"
                   border.width: 0.5
                   border.color: "white"
                   radius: root.hwratio < 1 ? root.hunit/10 : root.vunit / 10

                   Image {
                       source: "../images/pagemode_x64.png"
                       anchors.fill:parent
                       anchors.centerIn: parent
                       fillMode: Image.PreserveAspectFit
                   }

                   MouseArea {
                       id: mousepageIconMode
                       enabled: true
                       anchors.centerIn: parent
                       width: parent.width
                       height: parent.height
                       hoverEnabled: true
                       onClicked: {
                           pageMode=true
                           lyricsModeChoice.visible=false
                       }
                       Rectangle {
                           anchors.fill: parent
                           opacity: mousepageIconMode.pressed ? 1 : 0
                           Behavior on opacity { NumberAnimation{ duration: 100 }}
                           gradient: Gradient {
                               GradientStop { position: 0 ; color: "#22000000" }
                               GradientStop { position: 0.2 ; color: "#11000000" }
                           }
                           border.color: "darkgray"
                           radius: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
                       }
                   }
               }
           }
       }
       /***********************************
         Scroll increment choice
      *************************************/
       Rectangle{
           id:scrollIncChoice
           visible: false
           height:parent.height*.2 + okbutIncChoice.height
           width:parent.width*.8
           anchors.centerIn: parent
           color:"lightgrey"
           radius: root.hwratio < 1 ? root.hunit/10 : root.vunit / 10
           opacity: .95
           border.color: "white"
           GroupBox{
                id:scrollChoice
                title:qsTr("Increase the scroll speed by \n")
                anchors.centerIn: parent
                RowLayout{
                    ExclusiveGroup  {id:incSelect}
                    RadioButton {
                        id:tenpercent
                        text:"10%"
                        checked: true
                        exclusiveGroup: incSelect
                        onCheckedChanged: {
                            if(checked)
                                scrollVariation=.1
                        }
                    }
                    RadioButton {
                        id:twentypercent
                        text:"20%"
                        checked: false
                        exclusiveGroup: incSelect
                        onCheckedChanged: {
                            if(checked)
                                scrollVariation=.2
                        }
                    }
                    RadioButton {
                        id:thirtypercent
                        text:"30%"
                        checked: false
                        exclusiveGroup: incSelect
                        onCheckedChanged: {
                            if(checked)
                                scrollVariation=.3
                        }
                    }
                    RadioButton {
                        id:fourtypercent
                        text:"40%"
                        checked: false
                        exclusiveGroup: incSelect
                        onCheckedChanged: {
                            if(checked)
                                scrollVariation=.4
                        }
                    }
                    RadioButton {
                        id:fiftypercent
                        text:"50%"
                        checked: false
                        exclusiveGroup: incSelect
                        onCheckedChanged: {
                            if(checked)
                                scrollVariation=.5
                        }
                    }
                }
           }
           Rectangle{
               id:okbutIncChoice
               anchors.top: scrollChoice.bottom
               anchors.horizontalCenter: parent.horizontalCenter
               anchors.topMargin: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5

               width:  root.hwratio < 1 ? root.vunit*1.5  : root.hunit*1.5 //root.hunit
               height: root.hwratio < 1 ? root.vunit  : root.hunit //root.vunit

               color: "gray"
               radius: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
               visible:true

               Text{
                   text:"Ok"
                   font.family: scriptFont.name
                   font.pointSize: PlTools.setPointSize(0.20)
                   font.bold: true
                   color:currentFontColour
                   anchors.fill: parent
                   horizontalAlignment: "AlignHCenter"
                   verticalAlignment: "AlignVCenter"
               }
               MouseArea {
                   id: mouseokbutIncChoice
                   anchors.centerIn: parent
                   width: parent.width
                   height: parent.height
                   hoverEnabled: true
                   onClicked: {
                       scrollIncChoice.visible=false
                   }
             }
          }
       }
    }



    FontDialog {
        id: fontDialog
        property string fontTtargetProperty
        title: "Please choose a font"
        font: Qt.font({ family: "Arial", pointSize: 24, weight: Font.Normal })
        onAccepted: {
            //console.log("You chose: " + fontDialog.font)
            visible=false
            switch (fontTtargetProperty) {
                case "root.currentListFont":
                    root.currentListFont=fontDialog.font.family
                    break
                case "root.currentLyricsFont":
                    root.currentLyricsFont=fontDialog.font.family
                    break
            }
        }
    }

    ColorDialog {
        id: colorDialog
        property string colourTtargetProperty
        title: "Please choose a color"
        onAccepted: {
            visible=false
            switch (colourTtargetProperty) {
                case "root.currentLyricsFontColour":
                    root.currentLyricsFontColour=colorDialog.color
                    break
                case "root.currentFontColour":
                    root.currentFontColour=colorDialog.color
                    break
                case "root.currentBackGroundColour":
                    root.currentBackGroundColour=colorDialog.color
                    break
            }
        }

    }    
}
