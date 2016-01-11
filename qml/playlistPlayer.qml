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

// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 2.4
import QtGraphicalEffects 1.0
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.3
import QtQuick.Window 2.0
import QtQuick.Dialogs 1.1
import QtMultimedia 5.0
import "../js/functions.js" as PlTools

SwipeScreen {  
    id:setlist
    color: root.currentBackGroundColour
    property bool isFirstScreen:false
    property bool isLastScreen:false


    /********************************
      Current tune Display
    *********************************/
    Rectangle {
        id: curentTune
        //width: root.hunit * 10
        width: setlist.width*0.95
        height: root.hwratio < 1 ? root.vunit  : root.hunit
        anchors.horizontalCenter: setlist.horizontalCenter
        anchors.top:parent.top
        anchors.topMargin: root.hwratio < 1 ? root.vunit /2 : root.hunit /2
        color: root.currentBackGroundColour
        radius: root.hwratio < 1 ? root.hunit/30 : root.vunit / 30
        border.width: 0.5
        border.color: "lightgray"

        Text {
            id: tunetext
            color: root.currentFontColour
            //font.pointSize: root.hwratio > 1 ? root.hunit/2 : root.vunit / 2
            font.pointSize: PlTools.setPointSize(0.60)
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            //styleColor: "white"
            style: Text.Raised
            text: root.currentTuneTitle
            font.family: root.currentListFont
            anchors.fill: parent
            horizontalAlignment: "AlignHCenter"
            verticalAlignment: "AlignVCenter"
            //font.pixelSize: 12            
            Component.onCompleted: root.tunetext = tunetext
        }

    }

    /********************************
      Tune list
    *********************************/

    Rectangle {
        id: tuneList
        property bool loadTuneList : root.loadTuneList        
        border.color: "#000000"
        color: root.currentBackGroundColour
        width: setlist.width * 0.95
        height: setlist.height * 0.8
        anchors.top:curentTune.bottom
        //anchors.left: SwipeView.left
        //anchors.leftMargin: root.hunit
        anchors.horizontalCenter: setlist.horizontalCenter
        anchors.topMargin: root.hwratio < 1 ? root.hunit/5 : root.vunit / 5

        radius: root.hwratio < 1 ? root.hunit/5 : root.vunit / 5
        border.width: 0.5

        onLoadTuneListChanged: {
            /***************************************
              Function called when a playlist is loaded
            ***************************************/
            var index;
            var maxindex;
            root.tuneModel.clear()
            tunetext.text=""

            maxindex=listTune.length

            if(liteMode && maxindex > 15 ){
                maxindex=15
            }

            for	(index = 0; index < maxindex; index++) {
                //ll.addTune(root.listTune[index])
                root.tuneModel.append({
                                     "title":root.listTune[index]["title"],
                                     "iconItem":root.listTune[index]["iconItem"],
                                     "audioFile":root.listTune[index]["audioFile"],
                                     "lyricsFile":root.listTune[index]["lyricsFile"],
                                     "chordsFile":root.listTune[index]["chordsFile"],
                                     "capo":root.listTune[index]["capo"],
                                     "comments":root.listTune[index]["comments"],
                                     "author":root.listTune[index]["author"],
                                     "year":root.listTune[index]["year"],
                                     "duration":root.listTune[index]["duration"],
                                     "hasChords":root.listTune[index]["hasChords"]
                                  }
                                 )
            }
        }
        LauncherList {
            id: ll
            //enabled: root.llEnabled
            anchors.fill: parent
        }

    }
}
