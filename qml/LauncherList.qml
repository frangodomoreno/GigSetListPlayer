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

/****************************************************************************
**
** Copyright (C) 2013 Digia Plc and/or its subsidiary(-ies).
** Contact: http://www.qt-project.org/legal
**
** This file is part of the examples of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:BSD$
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of Digia Plc and its Subsidiary(-ies) nor the names
**     of its contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/
import QtQuick 2.0
import QtGraphicalEffects 1.0
import "../js/functions.js" as PlTools
import "../js/Database.js" as Db
import "../js/dynamicObjCreator.js" as DynamicObjCreator

// Define a highlight with customized movement between items.


/*********************************
  Play list display
*********************************/

Rectangle {


    border.width: 0.5
    border.color: "#000000"
    radius:5

    anchors.fill: parent
    color: root.currentBackGroundColour

    /*********************************
      Delegate for tune item
    *********************************/
    Component {
        id: tuneDelegate         
        Rectangle {            
            height: root.hwratio < 1 ? root.vunit*1.3  : root.hunit*1.3
            width: listView.width
            color: root.currentBackGroundColour
            border.color: "gray"
            border.width: 0.2
            radius:5

            /*********************************
              Icon to indicate if audio track is available
            *********************************/

            Image {
                id: imageType
                opacity: 0.7
                height: root.hwratio < 1 ? root.vunit*0.8  : root.hunit*0.8 // root.vunit*0.8
                width:root.hwratio < 1 ? root.vunit*0.8  : root.hunit*0.8 //root.hunit*0.8
                Behavior on opacity {NumberAnimation {duration: 100}}
                source: iconItem
                scale: 1
                fillMode: Image.PreserveAspectFit
                anchors.left: parent.left
                anchors.leftMargin: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
                anchors.top:parent.top
                Component.onCompleted: {
                    if(chordsFile!=""){
                        colorOver.color="white"
                    }
                }
            }
            ColorOverlay{
                id:colorOver
                enabled: false
                anchors.fill:imageType
                source:imageType
                color: "#848484"
                Component.onCompleted:{
                    if(index==0)
                        root.colorOver = colorOver
               }
            }
            MouseArea {
                id: chordsMouseDisp                
                anchors.left: imageType.left
                anchors.right:imageType.right
                height: parent.height
                onClicked: {                    
                    if(root.pdfDisplay != undefined)
                        root.pdfDisplay.visible = false

                    root.imageChordsDisplay.visible = false
                    if(root.currentChords!==""){
                        // Test file extension
                        if(root.currentChords.split(".").pop().toLowerCase() === "pdf" ){
                            if(Qt.platform.os === "ios" ){
                                if (root.pdfDisplay===undefined)
                                    DynamicObjCreator.createObjects("../qml/PdfViewCreate.qml",root.chordsDisplay)
                                chordsDisplay.color="black"
                                root.pdfDisplay.source = root.currentChords
                                root.pdfDisplay.isChord=true
                                root.pdfDisplay.visible = true                                
                                root.mouseHideChords.enabled=true
                            }
                            else{
                                if(Qt.platform.os === "osx"  ){
                                    DynamicObjCreator.createObjects("../qml/WebViewCreate.qml",root.chordsDisplay)
                                    chordsDisplay.color="black"
                                    root.pdfDisplay.url = "file://" + root.currentChords
                                    root.pdfDisplay.visible = true
                                    root.mouseHideChords.enabled=true
                                    chordsDisplay.visible=!chordsDisplay.visible
                                }
                                else {
                                    DynamicObjCreator.createObjects("../qml/AndPdfViewer.qml",root.chordsDisplay)
                                    root.pdfDisplay.source = root.currentChords
                                    root.pdfDisplay.visible = true
                                    root.pdfDisplay.isChord=true
                                    root.mouseHideChords.enabled=true
                                }
                            }
                        }
                        else {
                            chordsDisplay.color="white"
                            inputFake.focus = remoteEnabled && remotePluged
                            root.imageChordsDisplay.source = 'file://' + root.currentChords
                            root.imageChordsDisplay.visible = true
                            root.imageChordsDisplay.y = 0
                            root.mouseHideChords.enabled=false
                            chordsDisplay.visible=!chordsDisplay.visible
                        }
                    }
                }
                hoverEnabled: true
                enabled: listView.currentIndex == index && tunetext.text!=""
            }

            /*********************************
              Display current tune title and additional infos
            *********************************/
            Rectangle{
                id:titledisplay
                width: listView.width - imageType.width //- imageDetail.width
                anchors.left: imageType.right
                anchors.leftMargin: root.hwratio > 1 ? root.hunit*0.5 : root.vunit*0.5

                Row {
                    spacing: root.hwratio < 1 ? root.hunit/2 : root.vunit/2

                    //anchors.right: imageDetail.left
                    anchors.fill:parent
                    width: parent.width

                    id: row
                    Text {
                        id: tuneTitle
                        text:  index + 1 + ' - ' + title
                        color: root.currentFontColour
                        font.pointSize: PlTools.setPointSize(0.5)
                        font.family: currentListFont
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        Component.onCompleted: {
                            if(index===0)
                                root.tuneTitle = tuneTitle
                        }
                    }

                    Text {
                        id: theauthor
                        text: author + ' ' + year
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        color: root.currentFontColour
                        font.pointSize: PlTools.setPointSize(0.25)
                        font.family: currentListFont
                        anchors.top: row.top
                        anchors.topMargin: root.hwratio < 1 ? root.hunit*0.2 : root.vunit*0.2
                    }
                    Text {
                        id: lecapo
                        text: capo != "" ? "Capo : " + capo : ""
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        color: root.currentFontColour
                        font.pointSize: PlTools.setPointSize(0.33)
                        font.family: currentListFont
                        anchors.top: row.top
                        anchors.topMargin: root.hwratio < 1 ? root.hunit*0.2 : root.vunit*0.2
                    }
                    Text {
                        id: comment
                        text: comments
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        color: root.currentFontColour
                        font.pointSize: PlTools.setPointSize(0.33)
                        font.family: currentListFont
                        anchors.top: row.top
                        anchors.topMargin: root.hwratio < 1 ? root.hunit*0.2 : root.vunit*0.2
                    }
                }
            }

            MouseArea {
                id: itemMouseArea                
                anchors.left: imageType.right
                anchors.right:titledisplay.right
                height: parent.height
                onClicked: PlTools.tuneClicked(title,index,audioFile,duration,lyricsFile,chordsFile,hasChords)
                hoverEnabled: true
                enabled: root.llEnabled
            }
        }
    }

    /*********************************
      Hihglighter
    *********************************/
    Component {
        id: highlightBar
        Rectangle {
            width:  listView.width //200 //ListView.view.width
            height: root.hwratio < 1 ? root.vunit*1.3  : root.hunit*1.3
            border.width: 0.5
            border.color: "#000000"
            radius: 5
            color: root.currentFontColour
            y: listView.currentItem.y;
            opacity: 0.5
            z:3
            Behavior on y { SpringAnimation { spring: 8; damping: 0.5 } }
        }
    }

    /*********************************
      List the tunes
    *********************************/
    ListView {
        id: listView
        width: parent.width
        clip: true
        delegate : tuneDelegate        
        model:root.tuneModel
        highlight: highlightBar
        highlightFollowsCurrentItem: false
        anchors.fill: parent
        focus: true
        Component.onCompleted: root.listView=listView

    }

}
