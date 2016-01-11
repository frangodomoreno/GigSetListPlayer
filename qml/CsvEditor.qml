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
  CSV Editor

  Update, create, delete lines in the current setlist
********************************************************************************/

import QtQuick 2.0
import QtGraphicalEffects 1.0
import QtQuick.Controls 1.3
import QtQuick.Dialogs 1.0


import "../js/functions.js" as PlTools
import "../js/Database.js" as Db

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

    //property int localCurrentIndex: -1
    property bool hasBeenModified : false
    property bool saveDone: false


    /*********************************
      Local working model
    **********************************/
    ListModel {
        id:localTuneModel
    }

    /*********************************
      Func. for copying working model to the local model
    **********************************/
    function copyWorkToLocal(){
        var i;
        var secondes

        localTuneModel.clear()
        listView.currentRow=-1
        //console.log(">>> WORK TO LOCAL --",root.tuneModel.count)
        for(i=0;i<root.tuneModel.count;i++){
            //console.log(">>> WORK TO LOCAL",i)
            if(((root.tuneModel.get(i).duration%60000) / 1000) <= 9)
                secondes="0"+(root.tuneModel.get(i).duration%60000) / 1000
            else
                secondes=(root.tuneModel.get(i).duration%60000) / 1000

            localTuneModel.insert(i,{
                                      "order":i+1,
                                      "title":root.tuneModel.get(i).title,
                                      "iconItem":root.tuneModel.get(i).iconItem,
                                      "audioFile":root.tuneModel.get(i).audioFile.split('/').reverse()[0],
                                      "lyricsFile":root.tuneModel.get(i).lyricsFile.split('/').reverse()[0],
                                      "chordsFile":root.tuneModel.get(i).chordsFile.split('/').reverse()[0],
                                      "capo":root.tuneModel.get(i).capo,
                                      "comments":root.tuneModel.get(i).comments,
                                      "author":root.tuneModel.get(i).author,
                                      "year":root.tuneModel.get(i).year,
                                      //"duration":parseInt(root.tuneModel.get(i).duration/60000) + ":" + (root.tuneModel.get(i).duration%60000) / 1000,
                                      "duration":parseInt(root.tuneModel.get(i).duration/60000) + ":" + secondes,
                                      "hasChords":root.tuneModel.get(i).hasChords
                                   }
                                  )
        }
    }

    /*********************************
      Func. for copying local model to working model (save action)
    **********************************/
    function copyLocalToWork(){
        //console.log(">>> LOCAL TO WORK")
        var i;
        var iconitem;
        var duration ;

        root.tuneModel.clear()
        for(i=0;i<localTuneModel.count;i++){
            if(localTuneModel.get(i).audioFile!==""){
                iconitem="../images/Speaker_Icon.png"
            }
            else{
                iconitem="../images/lyrics-128x128.png"
            }

            if(localTuneModel.get(i).duration.split(',').length > 1 )
                duration=localTuneModel.get(i).duration.split(',')[0]*60000 + localTuneModel.get(i).duration.split(',')[1]*1000
            else {
                if(localTuneModel.get(i).duration.split(':').length > 1 )
                    duration=localTuneModel.get(i).duration.split(':')[0]*60000 + localTuneModel.get(i).duration.split(':')[1]*1000
                else
                    duration=localTuneModel.get(i).duration*60000
            }

            //set default duration to 3mn
            if(duration===0)
                duration=180000

            root.tuneModel.insert(i,{                                      
                                      "title":localTuneModel.get(i).title,
                                      "iconItem":iconitem,
                                      "audioFile":localTuneModel.get(i).audioFile === "" ? "" : setlistDir+"audio/"+localTuneModel.get(i).audioFile,
                                      "lyricsFile":localTuneModel.get(i).lyricsFile === "" ? "" : setlistDir+"lyrics/"+localTuneModel.get(i).lyricsFile,
                                      "chordsFile":localTuneModel.get(i).chordsFile === "" ? "" : setlistDir+"chords/"+localTuneModel.get(i).chordsFile,
                                      "capo":localTuneModel.get(i).capo,
                                      "comments":localTuneModel.get(i).comments,
                                      "author":localTuneModel.get(i).author,
                                      "year":localTuneModel.get(i).year,
                                      "duration":duration,
                                      "hasChords":localTuneModel.get(i).hasChords
                                   }
                                  )
        }
        //console.log(">>> LOCAL TO WORK END")
        localTuneModel.clear()
    }


    /*********************************
      Function for adding a tune in the list
    *********************************/
    function addTune()
    {
        if(listView.currentRow != -1 && listView.currentRow != localTuneModel.count - 1 ) {
            localTuneModel.insert(listView.currentRow+1,{
                                 "order":listView.currentRow+1,
                                 "title":"New Tune",
                                 "iconItem":"",
                                 "audioFile":"",
                                 "lyricsFile":"",
                                 "chordsFile":"",
                                 "capo":"",
                                 "comments":"",
                                 "author":"",
                                 "year":"",
                                 "duration":"1",
                                 "hasChords":false}
                         )
            PlTools.renumListTune(localTuneModel,listView.currentRow+1,listView.currentRow+1,false)
        }
        else {
            localTuneModel.append({
                                 "order":localTuneModel.count+1,
                                 "title":"New Tune",
                                 "iconItem":"",
                                 "audioFile":"",
                                 "lyricsFile":"",
                                 "chordsFile":"",
                                 "capo":"",
                                 "comments":"",
                                 "author":"",
                                 "year":"",
                                 "duration":"1",
                                 "hasChords":false}
                         )
        }
        hasBeenModified=true
    }


    /*********************************
      Function for deleting tune in the list
    *********************************/
    function deleteCurrentRow(){
        if (listView.currentRow != -1) {
            localTuneModel.remove(listView.currentRow)
            PlTools.renumListTune(localTuneModel,listView.currentRow,listView.currentRow,true)
            hasBeenModified=true
        }
    }


    /*********************************
      Delegate for editing cells
    ***********************************/
    Component {
        id: editableDelegate        
        Item {
            Text {
                id:displayText
                width: parent.width
                anchors.margins: 4
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                elide: styleData.elideMode
                text: {
                    styleData.value !== undefined ? styleData.value : ""
                }
                color: styleData.textColor
                visible: !styleData.selected
            }
            Loader {
                id: loaderEditor

                anchors.fill: parent                
                sourceComponent: styleData.selected ? editor : null
                Component {
                    id: editor                    
                    Rectangle{
                        anchors.fill: parent
                        id: flickText
                        clip:true                        
                        Connections {
                            target : textinput
                            onEditingFinished: {
                                //console.log(">>> EDIT DONE XXX ",textinput.text, styleData.column,setlistDir)
                                hasBeenModified=true
                                switch(styleData.column){
                                    case 0 :
                                        // Reorganise la liste
                                        PlTools.renumListTune(localTuneModel,styleData.row,parseInt(textinput.text)-1,false)
                                        break;
                                    default :
                                        localTuneModel.setProperty(styleData.row, styleData.role, textinput.text)
                                }
                            }
                        }
                        TextField {
                            id: textinput
                            anchors.fill: parent
                            text: {                                
                                styleData.value !== undefined ? styleData.value : ""
                            }                            
                            textColor: "black"
                        }
                    }
                }
            }
        }
    }


    /*********************************
      Delegate for retrieving file (audio, lyrics, chords)
    ***********************************/
    Component {
        id: fileChooser
        Item {
            id : fileChooserItem            
            Text {
                id:fileDisplayName
                width: parent.width
                anchors.margins: 4
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                elide: styleData.elideMode
                text: {
                    styleData.value !== undefined ? styleData.value : ""
                }
                color: styleData.textColor
                visible: !styleData.selected
            }
            Loader {
                id: fileLoaderEditor
                anchors.fill: parent                
                sourceComponent: styleData.selected ? fileEditor : null
                Component {
                    id: fileEditor
                    Rectangle{
                        anchors.fill: parent
                        clip:true 
                        Connections {
                            target : fileName
                            onEditingFinished: {
                                //console.log(">>> EDIT DONE XXX ",textinput.text, styleData.column,setlistDir)
                                hasBeenModified=true
                                localTuneModel.setProperty(styleData.row, styleData.role, fileName.text)
                            }
                        }
                        TextField{
                            id:fileName                            
                            anchors.fill: parent
                            text:{
                                styleData.value !== undefined ? String(styleData.value) : ""
                            }
                            focus: true
                        }

                        MouseArea {
                            anchors.fill : parent
                            onDoubleClicked: {
                                switch(styleData.column){
                                case 3 :
                                    fileDialog.folder="file://" + setlistDir + "audio"
                                    break;
                                case 4 :
                                    fileDialog.folder="file://" + setlistDir + "lyrics"
                                    break;
                                case 5 :
                                    fileDialog.folder="file://" + setlistDir + "chords"
                                    break;
                                default:
                                    fileDialog.folder=""
                                }
                                fileDialog.open()
                                fileDialog.visible=true
                            }
                            onClicked: {
                                fileName.forceActiveFocus()
                            }
                        }

                        FileDialog {
                            visible: false
                            id: fileDialog
                            title: qsTr("Choose a file")
                            sidebarVisible: false
                            onAccepted: {
                                hasBeenModified=true
                                localTuneModel.setProperty(styleData.row, styleData.role, fileDialog.fileUrl.toString().split('/').reverse()[0])
                                fileDialog.visible=false
                                fileDialog.close()
                            }
                            onRejected: {
                                fileDialog.visible=false
                                fileDialog.close()
                            }
                        }
                    }
                }
            }
        }
    }

    TableView {        
        model: localTuneModel
        //model: proxyModel
        id: listView
        width: parent.width
        clip: true
        sortIndicatorVisible:true
        anchors.fill: parent
        focus: true        
        TableViewColumn {
            role: "order"
            title: qsTr("Order")
            width: root.width/10 / 2
            movable: false
        }

        TableViewColumn {
            role: "title"
            title: qsTr("Title")
            width: root.width/10
            movable: false
//            delegate: editableDelegate
        }
        TableViewColumn {
            role: "author"
            title: qsTr("Author")
            width: root.width/10
            movable: false
        }
        TableViewColumn {
            role: "audioFile"
            title: qsTr("Audio File")
            width: root.width/10
            movable: false
            delegate: fileChooser
        }
        TableViewColumn {
            role: "lyricsFile"
            title: qsTr("Lyrics File")
            width: root.width/10
            movable: false
            delegate: fileChooser
        }
        TableViewColumn {
            role: "chordsFile"
            title: qsTr("Chords File")
            width: root.width/10
            movable: false
            delegate: fileChooser
        }
        TableViewColumn {
            role: "capo"
            title: "Capo"
            movable: false
            width: root.width/10
        }
        TableViewColumn {
            role: "comments"
            title: qsTr("Comments")
            width: root.width/10
            movable: false
        }
        TableViewColumn {
            role: "year"
            title: qsTr("Year")
            width: root.width/10
            movable: false
        }
        TableViewColumn {
            role: "duration"
            title: qsTr("Duration")
            width: root.width/10
            movable: false
        }
        itemDelegate: {
            return editableDelegate;
        }
    }

}
