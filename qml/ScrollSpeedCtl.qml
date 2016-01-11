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
import QtQuick.Window 2.2
import "../js/functions.js" as PlTools

Item {
    id:scrollSpeedCtl
    width:root.hwratio < 1 ? root.hunit/1.5 : root.vunit / 1.5
    height:root.hwratio < 1 ? root.hunit*2 : root.vunit*2
    property bool slower
    property bool pressed
    Rectangle {
        id:backImage
        anchors.fill: parent
        color:"white"
        opacity: 0.3
        radius: root.hwratio < 1 ? root.hunit/20 : root.vunit / 20
        Image {
            id: scrollCtlBack
            source: "../images/backScrollSlider.png"
            anchors.fill:parent
        }
    }
    Image {
        id: ctrlMoins
        visible:false
        source: "../images/backScrollSlider_moins.png"
        //anchors.verticalCenter: backImage.verticalCenter
        anchors.top:backImage.top
        width: backImage.width
        height: backImage.height/2
    }
    Image {
        id: ctrlPlus
        visible:false
        source: "../images/backScrollSlider_plus.png"
        //anchors.verticalCenter: backImage.verticalCenter
        anchors.bottom:backImage.bottom
        width: backImage.width
        height: backImage.height/2
    }
    MouseArea{
        id:lessMouseArea
        anchors.top:backImage.top
        //anchors.bottom: handler.top
        height: backImage.height/2
        width: backImage.width
        onPressed: {
            if(automationRecord){
                scrollSpeedCtl.pressed=true
                scrollSpeedCtl.slower=true
                ctrlMoins.visible=true
            }
            else {
                ctrlMoins.visible=true
                PlTools.keyHandler(lessKey)
            }
        }
        onReleased: {
            scrollSpeedCtl.pressed=false
            ctrlMoins.visible=false
        }
    }
    MouseArea{
        id:moreMouseArea
        anchors.bottom:backImage.bottom
        //anchors.top: handler.bottom
        height: backImage.height/2
        width: scrollSpeedCtl.width
        onPressed: {
            if(automationRecord){
                scrollSpeedCtl.pressed=true
                scrollSpeedCtl.slower=false
                ctrlPlus.visible=true
            }
            else{
                ctrlPlus.visible=true
                PlTools.keyHandler(moreKey)
            }
        }
        onReleased: {
            scrollSpeedCtl.pressed=false
            ctrlPlus.visible=false
        }
    }
}

