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

import QtQuick 2.0
import QtGraphicalEffects 1.0
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.3
import QtQuick.Window 2.0
import "../js/functions.js" as PlTools
import "../js/Database.js" as Db
import QtWebView 1.0

SwipeScreen {
    id:lyrics
    color: root.currentBackGroundColour
    property bool isFirstScreen:false
    property bool isLastScreen:false

    property alias lyricText: lyricText
    property alias scrollText: scrollText
    property alias hightliner: hightliner    

    /******************************
      Text view
    ******************************/
    Rectangle{
        /*
          Text scrolling zone
         */
        id:textArea
        width: lyrics.width*0.95
        height:lyrics.height*0.95
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top:parent.top
        anchors.topMargin: root.hwratio < 1 ? root.vunit * 0.5 : root.hunit * 0.5
        radius: root.hwratio < 1 ? root.hunit/30 : root.vunit / 30
        visible: !contenairWebLyricsDisplay.visible

        Flickable{
            id:scrollText
            height:textArea.height
            width:textArea.width
            contentWidth: lyricText.paintedWidth
            contentHeight: lyricText.paintedHeight
            flickableDirection: Flickable.VerticalFlick
            clip: true
            enabled: !(root.controlshow || root.audioPlaying)

            Text{
                id:lyricText
                property bool changeMode:false

                width: textArea.width
                height: textArea.height
                text:root.currentLyrics
                lineHeightMode: Text.FixedSize
                visible: !root.lyricsEdition
                font.pixelSize : textFontSize
                font.family: root.currentLyricsFont
                color: root.currentLyricsFontColour
                textFormat: text.substring(0,1) === "<" ?  Text.RichText :Text.AutoText
                //textFormat: Text.AutoText
                y: root.lyricsTextY
                x: root.hwratio < 1 ? root.vunit * 0.2 : root.hunit * 0.2
                onTextChanged: {
                    root.lyricsHeight=lyricText.height
                    // 20151025 Line count is given by js function 'nexTune' to avoid issues in rich text mode
                    // root.lyricsLineCount=lyricText.lineCount
                }
                onHeightChanged: root.lyricsHeight=lyricText.height
                wrapMode: Text.Wrap

            }
        }
        //HightLight Zone
        Rectangle{
            id:hightliner
            width:parent.width * .9
            height:textFontSize*4
            color:"white"
            opacity: 0.5
            radius: root.hwratio < 1 ? root.hunit/20 : root.vunit / 20
            x:0
            y:root.lyricsScrollGapY            
        }



        /****************************
          EDITOR
        *****************************/
        TextArea{
            id:lyricTextEdit
            property bool rich: false
            property bool haschanged: false

            anchors.fill : scrollText
            textFormat : TextEdit.PlainText
            //backgroundVisible:false
            width: textArea.width
            height: textArea.height
            //text:root.currentLyrics
            visible: root.lyricsEdition
            font.pixelSize : textFontSize
            font.family: root.currentLyricsFont
            textColor: "black"
            readOnly: false
            selectByMouse: true
            onTextChanged: {                
                haschanged=true
            }            
            onVisibleChanged: {
                if(visible) {
                    focus=true
                    if(root.plain!=="")
                        lyricTextEdit.text=root.plain.replace(/<style>.*style><pre>/,"")
                    else
                        //console.log(lyricText.text.replace(/<style>.*style>/,""))
                        lyricTextEdit.text=lyricText.text.replace(/<style>.*style><pre>/,"")

                    lyricTextEdit.textFormat=TextEdit.PlainText
                }
                else{
                    focus=false
                    //root.inputFake.focus=true
                    if(lyricTextEdit.text!=="" ){                        
                        root.plain=lyricTextEdit.text                        
                        root.currentLyrics="<style>pre{font-family: " + root.currentLyricsFont + " ;}</style><pre>"+lyricTextEdit.text
                        root.lyricsModified=haschanged                        
                    }
                }
            }
        }

        //color:"#FEFFC9"
        color:root.currentBackGroundColour
    }

    Rectangle{
        id: contenairWebLyricsDisplay
        visible:false
        color:"black"
        width: lyrics.width - root.controlswidth
        height:lyrics.height*0.95
        anchors.left: parent.left
        Component.onCompleted: {
            root.contenairWebLyricsDisplay = contenairWebLyricsDisplay
        }
        Text{
            anchors.centerIn: parent
            width:parent.width*.7

            font.pixelSize : textFontSize
            font.family: root.currentLyricsFont
            color: root.currentLyricsFontColour
            horizontalAlignment:Text.AlignHCenter
            wrapMode: Text.WordWrap
            text:qsTr("Tap to view the pdf file or swipe to go back to list")
        }

        onVisibleChanged: {
            if(!visible){
                if(root.pdfDisplay != undefined){
                    root.pdfDisplay.destroy() ;
                    root.pdfDisplay = undefined;
                }
            }
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                if(root.pdfDisplay!==undefined)
                    root.pdfDisplay.visible=true
            }
        }
   }
}
