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

/*********************************
  In App processing
*********************************/

Rectangle {
    border.width: 0.5
    border.color: "white"
    radius:5
    anchors.fill: parent
    color: "grey"
    Text {
        id: presentation
        width:parent.width*.7
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize : textFontSize
        font.family: root.currentLyricsFont
        text: !liteMode ? qsTr("<br>
<b><big>Remote control enabled</b></big>
") : qsTr("<br>
<b><big>Get Gig Setlist Player Full Edition to enable remote control</b></big>
")
        color:"white"
        horizontalAlignment:Text.AlignHCenter
        wrapMode: Text.WordWrap
    }   

    Text {
        id: goBuy
        width:parent.width*.7
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top:presentation.bottom
        anchors.topMargin: root.hwratio > 1 ? root.hunit*0.5 : root.vunit*0.5
        color:"white"
        font.pixelSize : textFontSize*.5
        font.family: root.currentLyricsFont
        horizontalAlignment:Text.AlignHCenter
        wrapMode: Text.WordWrap
        text: qsTr("
With Gig Setlist Player Full Edition you will be able to control the page scroll or the page shift in the lyrics pane<br><br>
The Gig SetList Player application supports BlueTooth remote pedal board that can send the Up and Down Arrows key.<br>
")
    }

    Text {
        id: buyText
        width:parent.width*.7
        visible:liteMode
        anchors.top:goBuy.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize : textFontSize*.7
        font.family: root.currentLyricsFont
        text: qsTr("
<br>
Touch the <b>button</b> below,<br>to buy the full version<br>of the app ")
        color:"white"
        horizontalAlignment:Text.AlignHCenter        
        wrapMode: Text.WordWrap
    }

    Rectangle{
        id:buyBut
        visible:liteMode
        width:64
        height: 64
        anchors.top:buyText.bottom
        anchors.topMargin: root.hwratio > 1 ? root.hunit*0.5 : root.vunit*0.5
        anchors.horizontalCenter: parent.horizontalCenter
        color:"grey"
        radius: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
        border.color: "black"
        border.width: 3

        Image {
            id: buy
            source: "../images/buy10.png"
            fillMode: Image.PreserveAspectFit
            anchors.centerIn: parent
            MouseArea {
                id: buyMouse
                enabled: true
                anchors.centerIn: parent
                width: parent.width
                height: parent.height
                hoverEnabled: true
                onClicked: {
                    console.log("BUY")
                    if(Qt.platform.os==="ios")
                        internetServices.openLink("https://itunes.apple.com/fr/app/gig-setlist-player/id989573453?mt=8&ign-mpt=uo%3D4")
                    if(Qt.platform.os==="android")
                        internetServices.openLink("https://play.google.com/store/apps/details?id=org.monasys")
                }
                Rectangle {
                    anchors.fill: parent
                    opacity: buyMouse.pressed ? 1 : 0
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

    Text {
        id: devices
        width:parent.width*.7
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top:buyBut.bottom
        anchors.topMargin: root.hwratio > 1 ? root.hunit*0.5 : root.vunit*0.5
        color:"white"
        horizontalAlignment:Text.AlignHCenter
        font.pixelSize : textFontSize*.5
        font.family: root.currentLyricsFont
        text: qsTr("
    These folowing models are supported : AirTurn DUO, AirTurn PED, PageFlip CICADA
")
    }




}
