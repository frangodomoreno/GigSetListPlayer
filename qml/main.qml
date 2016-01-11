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

/********************************
  TODOLIST

    Android:
        --> Ok Creer dossier Documents si inexistant (A voir, ne semble pas fonctionner)
        --> Ok Synchro Dropbox OK

    iOS:
        Volume slider à intégrer en Objective C
        --> OK Splash Screen

    MacOsx:
        --> Ok Icône Application

    Fonctionnel :
        ---> OK  20150726 : Quand le mode edition csv est actif, faire disable Liste et disable Tool Button.
        ---> OK  20150726 : Lors du choix de la liste, disable All button et Liste.

        TODOOK: - 20150812 : Ajouter un sablier lors du chargement de l'editeur CSV
        TODOOK: - 20150812 : Synchro Ipad / Dropbox
        TODOOK: - 20150814 : Dans la sauvegard des fichier (txt et csv) ajouter une procédure de mise à jour du fichier hashVersionTab.dat poue la synchro dropbox
        TODOOK: - 20150821 : Si mode pedalier autorisé, prevoir un mode scroll et une mode page.
        TODOOK: - 20150827 : Revoir le séquencement (pop up de switch de list intempestif mal placé) lorsqu'on supprime une liste
        TODOOK: - 20150902 : Menu tool ajouter mode par défaut : scroll/page
        TODOOK: - 20150827 : Dans l'edition CSV, revoir l'affichage quand on sauvegarde dans une autre liste que la liste courante, (utiliser un 3eme buffer ?)
        TODOOK: - 20150726 : Lors de l'activation du mode edition csv,supprimer la selection active si il y en a une.
        TODOOK: - 20150917 : Embarquer le scrollVariation dans les données d'automation
        TODOOK: - 20150827 : Revoir Menu tools
        TODOOK: - 20150917 : Etude du scrolling d'un png (jpeg) dans l'écran chordsDisplay

        TODOOK: - 20151028 : Regénérer les messages en français


        TODOOK: - 20151202 : Voir pourquoi si le fichier texte est un pdf et que c'est le premier, play ne fonctionne pas
                           Voir pourquoi après un pdf, un morceau sans texte affiche encore le même pdf.
                           Si temps du morceau est 0 considérer que c'est 3:30 mn

        TODO: - 20150812 : Ajouter un décompte pour les morceau sans bandes son (BPM et Signature dans la colonne divers à la mode Live) ENCORE DU BOULOT LADSUS
        TODO: - 20150807 : Si le texte est déja au format html, ne pas ajouter la, balise <pre> et voir comment réagis l'automatisation
        TODO: - 20150813 : Tap Tempo pour les morceaux sans bande son (soit manuel, soit vocal)

        Implementation d'un menu Tools avec :
        --> Ok    -Suppression de la liste en cours (fichier csv) avec choix de supprimer tous
                les fichiers référencés dedans (mp3, txt, pgn).
        --> Ok    -Supression de tous les fichiers mp3, txt ..
        --> Ok    -Modification police et couleur police.
        --> Ok    -Modification couleur de fond

        --> Ok Multi Language
        --> OK Tester cycle complet avec dossier dropbox inndexistant
        --> Ok via acces web Help à voir
        --> OK Icône mode lecture audio a animer et mode lecture lyrics
        --> OK Revoir l'affichage de la synchro DropBox
        --> OK Revoir Calcul increment defilement
        --> OK Voir la synchro DropBox deux foix de suite qui ne fonctionne pas

    BUGS:
        --> OK Problème de repositionnement dans le texte lors du passage d'un texte à un autre
               si le texte de dépaart n'est pas positionné tout en hat (position 0)

    Autre:

    Icons from : https://www.iconfinder.com
    Fonts from : http://openfontlibrary.org/
    Icon made by Freepik at http://www.freepik.com from http://www.flaticon.com is licensed under Creative Commons BY 3.0

*********************************/

import QtQuick 2.4
import QtGraphicalEffects 1.0
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.3
import QtQuick.Window 2.0
import QtQuick.Dialogs 1.1
import QtMultimedia 5.0
import QtQuick.LocalStorage 2.0
import Qt.labs.settings 1.0
import QtWebView 1.0


import "../js/functions.js" as PlTools
import "../js/Database.js" as Db
import "../js/dynamicObjCreator.js" as DynamicObjCreator


Rectangle{
    property string  currentVersion: "2.7-FULL 20151220"
    width: Screen.desktopAvailableWidth
    height: Screen.desktopAvailableHeight

    id:root
    color:currentBackGroundColour
    /*================================
      PROPERTIES
      ================================*/

    property real textFontSize: PlTools.setPointSize(0.85)
    //property string textFontFamily:"courier"
    // Get pixel per milimeter
    property real pixelDensity: Screen.pixelDensity
    property real hwratio: height/width

    // Set refresh scrolling frequency to 40ms
    property real scrollTimeUnit:60

    // set delay before read player duration
    property real pauseBeforeReadAudioDuration:1000


    // Scrolling coef
    property real scrollCoef:1
    // scroll Increment Variation (10%)
    property real scrollVariation : 0.1
    property bool automationFlag

    property real hunit: width/16
    property real vunit: height/16

    // Global defs
    property string defaultBackGroundColour: "black"
    property string defaultFontColour: "white"

    property string defaultLyricsFont: lyricsFont.name
    property string defaultListFont: scriptFont.name

    property real   defaultTextFontSize: PlTools.setPointSize(0.85)

    // Contains the current active pane (list :0  or lyrics :1)
    property int currentPane : 0

    /*====================================
      Remote Command COnfiguration
    ======================================*/
    // Enables the use of a remote command (InApp purchase dependent)    
    property bool remoteEnabled : true  //default true
    property bool remotePluged : false  //default false
    property string remodeMode : "UD"  //Modes are LR (Left - Right Keys) or UD (default) (up - Down Keys)
     property alias inputFake:inputFake

    //TODO: Configuration a faire en fonction du mode AirTurn choisi (1,2,3,4)
    property int moreKey: remodeMode==="UD" ? Qt.Key_Down : Qt.Key_Right
    property int lessKey: remodeMode==="UD" ? Qt.Key_Up   : Qt.Key_Left

    /* _____________________________________________*/
    property string currentBackGroundColour: defaultBackGroundColour
    property string currentFontColour: defaultFontColour
    property string currentListFont:defaultListFont

    // Misc Vars
    property bool loadTuneList:false
    property string currentPlaylist
    property variant listTune :undefined
    property bool llEnabled: true
    property alias audioPosition: audioPlayer.position
    property alias lyricsStartTime: lyricsPlayer.startTime
    property bool audioPlaying

    property var firstLaunchHelp:undefined
    property alias controlPop:controlPop
    property alias toolsControl:toolsControl
    property alias csveditor:csveditor
    property alias csvswitch:csvswitch
    property alias remoteActivatio:remoteActivatio
    property alias fontsizeMore:fontsizeMore
    property alias fontsizedef:fontsizedef
    property alias fontsizeLess:fontsizeLess
    property alias scrollOrPageMode: scrollOrPageMode
    property alias lyricsEdit: lyricsEdit
    property alias help : help
    property alias lyricsSave:lyricsSave    
    property alias controls: controls
    property alias scrollSpeedCtl:scrollSpeedCtl
    property alias controlAutomation:controlAutomation

    property var headerLabel:undefined
    property var screensListView:undefined
    property var tunetext:undefined
    property var listView:undefined
    property var colorOver:undefined
    property var tuneTitle:undefined
    property var butSync:undefined
    property var butPlay:undefined
    property var mousePlay: undefined
    property var mouseSync: undefined
    property var mouseInfo: undefined


    // Lyrics Properties
    property string currentLyrics: ""
    property string plain: ""
    property string currentLyricsFile: ""
    property string currentLyricsFont: defaultLyricsFont
    property string currentLyricsFontColour: defaultFontColour
    property real lyricsHeight: 0
    property real lyricsLineCount: 0
    property real lyricsTextY : 0
    property real lyricsScrollGapY: 0
    property bool automationRecord:false    
    property alias controlshow: controls.showhide
    property alias controlswidth: controls.width
    property bool lyricsEdition : false
    property bool lyricsModified: false
    property int tempo:0
    property int signature:0

    //Define ScrollMode or PageMode (defaut scroll mode)
    property bool pageMode: false

    // Chords properties
    property string currentChords: ""
    property var pdfDisplay:undefined
    //property var webLyricsDisplay:undefined
    property var contenairWebLyricsDisplay:undefined
    property var imageChordsDisplay:undefined
    property var mouseHideChords:undefined
    property var flickContenair:undefined
    property var chordsDisplay:undefined

    //setList Properties
    property string currentTuneTitle: ""
    property var listViewHandler:undefined
    property real audioDuration: 0.0
    //property var tuneModel :undefined
    property var hasChords:undefined
    property string audioFile:""
    property variant curentTuneTitleHandle


    property alias tuneModel: tuneModel

    onWidthChanged: {
        if(firstLaunchHelp !== undefined) {
            if (firstLaunchHelp.visible){
                firstLaunchHelp.width=root.width*.7
                firstLaunchHelp.height=root.height*.7
            }
        }
     }

    Component.onCompleted: {
        if(firstLaunch){
            DynamicObjCreator.createObjects("../qml/FirstLaunch.qml",root)
            firstLaunchHelp.width=root.width*.7
            firstLaunchHelp.height=root.height*.7
            firstLaunchHelp.anchors.centerIn = root
            firstLaunchHelp.visible=true
        }
    }

    ListModel {
        id:tuneModel
    }

    /*================================
      SETTINGS
      ================================*/
    Settings{
        id:fontsAndColourSettings
        category: "FontsAndColour"
        property string settingLyricsFont:""
        property string settingLyricsFontColour:""
        property string settingBackGroundColour:""
        property string settingFontColour:""
        property string settingListFont:""
    }

    Settings{
        id:pagemodeSetting
        category: "PageMode"
        property bool pagemodeSet: false
        property real scrollInc : 0.1
    }

    Settings{
        id:remoteControlSettings
        category: "remoteEnabled"
        property bool settingsRemotePluged: true
    }

    /*================================
      Import JavaScripts
      ================================*/
    function main(){
        // Load default settings
        currentBackGroundColour = fontsAndColourSettings.settingBackGroundColour != "" ? fontsAndColourSettings.settingBackGroundColour : defaultBackGroundColour
        currentLyricsFontColour = fontsAndColourSettings.settingLyricsFontColour != "" ? fontsAndColourSettings.settingLyricsFontColour : defaultFontColour
        currentLyricsFont = fontsAndColourSettings.settingLyricsFont != "" ? fontsAndColourSettings.settingLyricsFont : defaultLyricsFont
        currentFontColour = fontsAndColourSettings.settingFontColour != "" ? fontsAndColourSettings.settingFontColour : defaultFontColour
        currentListFont = fontsAndColourSettings.settingListFont != "" ? fontsAndColourSettings.settingListFont : defaultListFont        
        remoteEnabled = true
        remotePluged = remoteControlSettings.settingsRemotePluged && !liteMode
        pageMode = pagemodeSetting.pagemodeSet
        scrollVariation = pagemodeSetting.scrollInc
        PlTools.fmain()        
    }

    /*================================
      TIMERS
      ================================*/

    /********************************
      Lyrics scroller delay before begin scrolling
    *********************************/
    Timer {
        id:timerLYRIC
        //interval:pauseBeforeScroll
        //interval:pauseBeforeReadAudioDuration
        interval:scrollTimeUnit
        running:false
        repeat:true
        property real scrollUnit:0
        property real scrollGap: 0
        property int idxAutom
        property variant tabAutom
        onTriggered: PlTools.lyricsScroller()
    }

    /********************************
      Lyrics scroller delay before begin scrolling
    *********************************/
    Timer {
        id:lyricsPlayer
        interval:0
        property bool manualStop: false
        property real startTime
        running:false
        onTriggered: PlTools.endTuneAction()
    }

    /*================================
      MISC
      ================================*/

    /********************************
      Media Players
    *********************************/
    MediaPlayer{
        id:audioPlayer
        source: ""
        property bool manualStop: false        
        volume:volumeSlider.value
        onStopped: {
            PlTools.endTuneAction()
        }
        onPlaying: {
            root.audioPlaying=true
            timerLYRIC.start()
        }
    }
    MediaPlayer{
        id:metronome1
        source: "file://"+setlistDir+"audio/01.mp3"
        volume:1.0        
    }
    MediaPlayer{
        id:metronome2
        source: "file://"+setlistDir+"audio/02.mp3"
        volume:1.0
    }

    MediaPlayer{
        id:metronome3
        source: "file://"+setlistDir+"audio/03.mp3"
        volume:1.0
    }
    MediaPlayer{
        id:metronome4
        source: "file://"+setlistDir+"audio/04.mp3"
        volume:1.0
    }
    /********************************
      Font Loader
    *********************************/

    FontLoader {
        id:scriptFont
        source:"../fonts/ArchitectsDaughter.ttf"
    }

    FontLoader {
        id:lyricsFont
        source:"../fonts/SVBasicManual.ttf"
    }


    /********************************
      FAKE OBJECT FOR TRAP KEYS IN IOS
    *********************************/
    //TextEdit{
    TextArea{
        // Detecte les touches Fleche droite et Fleche gauche pour le pilotage du defilement du texte
        id:inputFake
        height:50
        width:50
        property int arrowPos:0
        property bool scrollReleased: false
        //focus:remoteEnabled
        focus:false
        visible:focus
        enabled: focus
        text:"1\n2\n2\n"
        cursorPosition: 5
        onTextChanged: {
            //console.log("cursorPosition",cursorPosition,"arrowpos",arrowPos)
            scrollReleased=true
            if(remodeMode==="LR"){
                if(cursorPosition==0){
                    arrowPos=1
                    cursorPosition=1
                    PlTools.keyHandler(lessKey)
                    return
                }
                if(cursorPosition==2){
                    arrowPos=1
                    cursorPosition=1
                    PlTools.keyHandler(moreKey)
                    return
                }
            }
            if(remodeMode==="UD"){
                if(cursorPosition==5){
                    arrowPos=cursorPosition
                    PlTools.keyHandler(moreKey)
                    return
                }
                if(cursorPosition==6 || cursorPosition==3){
                    arrowPos=5
                    if(cursorPosition==3)
                         PlTools.keyHandler(moreKey)
                    cursorPosition=5
                    return
                }
                if(arrowPos==5&&cursorPosition==4){
                    //cursorPosition=5
                    PlTools.keyHandler(lessKey)
                    return
                }
            }
        }
        Component.onCompleted: {
            remoteEnabled = remoteControlSettings.settingsRemotePluged
            //focus=remoteEnabled
            if(remodeMode==="LR")
                cursorPosition=1
            if(remodeMode==="UD")
                cursorPosition=5
       }
       onFocusChanged: {
           //console.log("FOCUS",Qt.inputMethod.keyboardRectangle.width,focus,remoteEnabled,remotePluged)
           //if(Qt.inputMethod.keyboardRectangle.width > 0 && remoteEnabled == false)
           //Qt.inputMethod.hide()
           if(remodeMode==="LR")
               cursorPosition=1
           if(remodeMode==="UD")
               cursorPosition=5
      }
       /***********************************
         Key Handler for non Ios Devices
       ************************************/
      Keys.onPressed: {
          if(remoteEnabled)
               PlTools.keyHandler(event.key)
      }
      Keys.onReleased: {
          if(remoteEnabled)
               scrollSpeedCtl.pressed=false
      }

    }

    /********************************
      MAIN SCREEN
    *********************************/

    Rectangle {
        id : swipeZone
        width: root.width
        height: root.height - toolsControl.height
        color:currentBackGroundColour
        anchors.left: root.left        
        SwipeView {
            id:swipeView
            anchors.fill: parent
            model: ListModel {
                ListElement {
                    title: qsTr("Set list")
                    source: "playlistPlayer.qml"
                }
                ListElement {
                    title: qsTr("Lyrics")                    
                    source: "Lyrics.qml"
                }
          }
        }
    }

    /********************************
      CONTROLS MENUS
    *********************************/

    // Speed control buttons
    ScrollSpeedCtl{
        id:scrollSpeedCtl
        //visible: root.automationRecord
        visible:root.currentTuneTitle !== "" ? fontsizeLess.visible  && butPlay.isplaying  && (!remoteEnabled || !remotePluged) : false
        anchors.right: parent.right
        anchors.bottom: root.bottom
        anchors.bottomMargin: fontsizeLess.height + root.hunit*0.4
        //y:parent.height-scrollSpeedCtl.height
        width:root.hwratio < 1 ? root.hunit : root.vunit
        height:root.hwratio < 1 ? root.hunit*3 : root.vunit*3        
    }

    /********************************
      Start/Stop , Volume , Synchro
    *********************************/
    Rectangle{
        id:controls
        height: root.height -  (root.hwratio < 1 ? root.hunit*1.5: root.vunit*1.5)

        width: root.hwratio < 1 ? root.hunit * 2 : root.vunit * 2

        property alias ctrlanimy: ctrlanimy
        property alias ctrlanimx: ctrlanimx

        visible:false
        color:currentBackGroundColour
        ////z:0
        y:-controls.height
        x:parent.width - controls.width
        radius:root.hwratio < 1 ? root.hunit/10  : root.vunit/10
        border.color: "gray"
        border.width: 2
        property bool showhide: false
        NumberAnimation on y {
                        id:ctrlanimy
                        property real begin: 0
                        property real end : -controls.height
                        from: begin; to: end
                        duration:500
                        easing.type: Easing.OutBack
                        easing.amplitude: 2.0
                        easing.period: 1.5
                }

        NumberAnimation on x {
                id:ctrlanimx
                property real begin: root.width - controls.width
                property real end : root.width
                from: begin
                to: end
                duration:500
                easing.type: Easing.OutBack
                easing.amplitude: 2.0
                easing.period: 1.5
        }

        /********************************
          Play Button
        *********************************/
        Rectangle {
            id: butPlay

            enabled: true

            width: root.hunit * 1.5
            height: root.vunit * 1.5
            anchors.top:controls.top           
            anchors.topMargin: root.hwratio > 1 ? root.hunit*0.5 : root.vunit*0.5
            anchors.horizontalCenter: controls.horizontalCenter
            color: currentBackGroundColour
            border.width: 0.5
            //border.color: "grey"
            radius: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
            property bool isplaying:false
            property alias imagePlay:imagePlay
            property alias mousePlay:mousePlay
            Component.onCompleted: root.butPlay=butPlay            

            Image  {
                id: imagePlay
                z:0
                anchors.fill: parent
                anchors.centerIn: parent
                opacity: 1
                Behavior on opacity {NumberAnimation {duration: 100}}                
                source: "../images/play_button.png"
                fillMode: Image.PreserveAspectFit
                MouseArea {
                    id: mousePlay
                    enabled: true
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height
                    hoverEnabled: true
                    Component.onCompleted: root.mousePlay = mousePlay
                    onClicked: {
                        PlTools.startStopButon()
                        PlTools.controlHideShow(controls,
                                                controlPop.height,
                                                -controls.height ,
                                                root.width - controls.width ,
                                                root.width,
                                                controls.ctrlanimx,
                                                controls.ctrlanimy)
                    }
                    Rectangle {
                        anchors.fill: parent
                        opacity: mousePlay.pressed ? 1 : 0
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



        /********************************
          Volume slider
        *********************************/
        Rectangle{
            //x: root.width - 140
            //y: 200
            id:sliderContainer
            //visible:deviceType!="ios"
            visible:false
            width: root.hunit
            //height: deviceType!="ios" ? root.vunit * 5 : 0
            height:  0
            //height: root.vunit * 5
            anchors.top : butPlay.bottom
            anchors.topMargin: root.vunit*0.5
            //anchors.right: root.right
            anchors.rightMargin: root.hunit
            anchors.horizontalCenter: butPlay.horizontalCenter
            border.width: 1
            border.color: "grey"
            radius: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5

            gradient: Gradient {
                GradientStop {
                    position: 0
                    color: "grey"
                }

                GradientStop {
                    position: 1
                    color: "#000000"
                }
            }

            Slider{
                id:volumeSlider
                height: parent.height
                width: parent.width
                orientation:Qt.Vertical
                anchors.centerIn: parent
                value:0.5

                style: SliderStyle {
                    groove: Rectangle {
                        implicitWidth: 200
                        implicitHeight: 8
                        color: "gray"
                        radius:root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
                    }
                    handle:
                        Image {
                            id: butonSlider
                            width: root.vunit
                            height: root.vunit*1.5
                            rotation: 90
                            //anchors.fill: parent
                            anchors.centerIn: parent
                            source: "../images/slider_button.png"
                            //fillMode: Image.PreserveAspectFit
                        }
                }
            }

            Text{
                id:volumeText
                text:"Volume"
                font.family: scriptFont.name
                font.bold: true
                font.pointSize: PlTools.setPointSize(0.33)
                anchors.top: parent.bottom
                anchors.topMargin: 10
                anchors.horizontalCenter: volumeSlider.horizontalCenter
                color:currentFontColour
            }

        }


        /********************************
          Drop box sync button
        *********************************/
        Rectangle {
            /*
              DropBox Synchronization
            */
            id: butSync

            width: butPlay.width
            //height: android ? 0 : butPlay.height
            height: butPlay.height
            //visible:!android
            visible:true

            //anchors.bottom: controls.bottom
            anchors.top: sliderContainer.bottom
            anchors.topMargin: volumeText.height*1.5
            //anchors.right: setlist.right
            //anchors.bottomMargin: root.hwratio > 1 ? root.hunit*0.8 : root.vunit*0.8
            //anchors.rightMargin: root.hunit
            anchors.horizontalCenter: controls.horizontalCenter
            color: currentBackGroundColour
            border.width: 0.5
            border.color: "#000000"
            radius: root.hwratio < 1 ? root.hunit/30 : root.vunit / 30
            Component.onCompleted: root.butSync = butSync

            Image  {
                id: imageSync
                anchors.fill: parent
                anchors.centerIn: parent
                opacity: 1
                Behavior on opacity {NumberAnimation {duration: 100}}
                fillMode: Image.PreserveAspectFit
                source: "../images/dropbox-48.png"
                z:0
                MouseArea {
                        id: mouseSync
                        anchors.centerIn: parent
                        width: parent.width
                        height: parent.height
                        hoverEnabled: true
                        Component.onCompleted: root.mouseSync = mouseSync
                        onClicked: {
                            PlTools.controlHideShow(controls,
                                                    controlPop.height,
                                                    -controls.height ,
                                                    root.width - controls.width ,
                                                    root.width,
                                                    controls.ctrlanimx,
                                                    controls.ctrlanimy)
                            messageDialog.visible=false
                            var rc=dropBoxOperations.connect()
                            if ( rc < 0){
                                if(rc==-4){
                                    messageDialog.setText(qsTr("Tap Ok Button when DropBox Authorization is completed"))
                                    messageDialog.visible=true
                                    messageDialog.buttonOK=true
                                    messageDialog.action=1
                                    internetServices.openLink(dropBoxOperations.geturlvalidation())
                                }
                                else if (rc==-5){
                                    messageDialog.setText(qsTr("Local tokens file acces denied"))
                                    messageDialog.visible=true
                                }

                                else {
                                    messageDialog.setText(qsTr("DropBox connection Error : ") + rc)
                                    messageDialog.visible=true
                                }
                            }
                            else{
                                dropboxContainer.visible=true
                                dropBoxOperations.downloaddone=false
                           }

                        }

                        Rectangle {
                            anchors.fill: parent
                            opacity: mouseSync.pressed ? 1 : 0
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
            Text{
                text:"Synchro\nDropbox"
                font.family: scriptFont.name
                font.pointSize: PlTools.setPointSize(0.33)
                color:currentFontColour
                anchors.top: parent.bottom
                anchors.horizontalCenter: butSync.horizontalCenter
                font.bold: true
                z:1
            }
        }

        /********************************
         Help
        *********************************/
        Rectangle {
            id:helpMe
            width: butPlay.width
            height: butPlay.height
            anchors.top: butSync.bottom
            anchors.topMargin: volumeText.height*3
            anchors.horizontalCenter: controls.horizontalCenter
            color:currentBackGroundColour
            border.width: 0.5
            radius: root.hwratio < 1 ? root.hunit/30 : root.vunit / 30

            Image {
                id: helpInfo
                width: parent.width
                height: parent.height
                source: "../images/info.png"
                fillMode: Image.PreserveAspectFit
                anchors.centerIn: parent
                MouseArea {
                    id: mouseInfo
                    enabled: true
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height
                    hoverEnabled: true
                    Component.onCompleted: root.mouseInfo = mouseInfo
                    onClicked: {
                        DynamicObjCreator.createObjects("../qml/FirstLaunch.qml",root)
                        firstLaunchHelp.width=root.width*.7
                        firstLaunchHelp.height=root.height*.7
                        firstLaunchHelp.anchors.centerIn = root
                        firstLaunchHelp.visible=true
                        firstLaunchHelp.disphelp=true

                        PlTools.controlHideShow(controls,
                                                controlPop.height,
                                                -controls.height ,
                                                root.width - controls.width ,
                                                root.width,
                                                controls.ctrlanimx,
                                                controls.ctrlanimy)
                        //help.visible=true
                    }
                    Rectangle {
                        anchors.fill: parent
                        opacity: mouseInfo.pressed ? 1 : 0
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
    }

    /***********************************
      HELP
    ************************************/
    Rectangle{
        id:help
        width:root.width*0.8
        height: root.height*0.8
        anchors.bottom: root.bottom
        anchors.centerIn: root
        visible: false
        color:"lightgrey"
        Text{
            id:textinfo
            textFormat: Text.RichText
            font.family: scriptFont.name
            font.pointSize: PlTools.setPointSize(0.33)
            color:currentBackGroundColour
            wrapMode:Text.Wrap
            text:'<b>Version : ' + currentVersion + '<b><br>' +
                  qsTr('<b>Author : J.Y Priou</b><br>
                  <b>WebSite: <a href="http://www.monasysinfo.com" title="MonasysInfo">Monasysinfo.com</a></b><br>
                  <b>Online Help <a href="http://www.monasysinfo.com/documentation/en/" title="Online Help">Online Help</a></b><br>
                  <b>Mail: <a href="mailto:support@monasysinfo.com">support@monasysinfo.com</a></b><br>                  <
                  <br>
                  <b>Fonts from : <a href="http://openfontlibrary.org">openfontlibrary.org</a><b>
                  <div>Icon made by <a href="http://www.freepik.com" title="Freepik">Freepik</a> <br>
                  from <a href="http://www.flaticon.com" title="Flaticon">www.flaticon.com</a> <br>
                  Is licensed under <a href="http://creativecommons.org/licenses/by/3.0/" title="Creative Commons BY 3.0">CC BY 3.0</a></div>')
            anchors.centerIn: parent
            onLinkActivated: internetServices.openLink(link)
        }
        Rectangle{
            id:hideHelp
            width:controlPop.width
            height: controlPop.height
            color: "lightgrey"
            anchors.top:parent.top
            anchors.right: parent.right
            MouseArea{
                anchors.fill: parent
                onClicked: help.visible=false
            }
            Text{
                font.pointSize: PlTools.setPointSize(0.33)
                text:"X"
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.top:parent.top
                anchors.topMargin: 10
            }
        }
    }

    /***********************************
      MENU Hide/Show Play, Volume, Sync, Help Controls
    ************************************/
    Rectangle {
        id:controlPop
        width : root.hwratio < 1 ? root.hunit*0.8: root.vunit*0.8
        height: root.hwratio < 1 ? root.hunit: root.vunit
        color:currentBackGroundColour
        y:0
        ////z:1
        anchors.right: parent.right        
        Image {
            id: butmenu
            source: "../images/menu-button_black.png"
            anchors.fill:parent
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                PlTools.controlHideShow(controls,
                                               controlPop.height,
                                               -controls.height ,
                                               root.width - controls.width ,
                                               root.width,
                                               controls.ctrlanimx,
                                               controls.ctrlanimy)
                controls.visible?controlPop.color="green":controlPop.color=currentBackGroundColour
           }
        }
    }


    /********************************************
      Scrolling Automation Controls
    *********************************************/
    Rectangle{
        id:automations
        height: root.height - ( root.hwratio < 1 ? root.hunit: root.vunit )
        width: automationTitle.width*1.2 //root.hwratio < 1 ? root.hunit * 2 : root.vunit * 2

        property alias automanimy: automanimy
        property alias automanimx: automanimx

        visible:false
        color:currentBackGroundColour
        ////z:0
        y:-controls.height
        x:parent.width - automations.width
        radius:root.hwratio < 1 ? root.hunit/10  : root.vunit/10
        border.color: "gray"
        border.width: 2
        property bool showhide: false
        NumberAnimation on y {
                        id:automanimy
                        property real begin: 0
                        property real end : -automations.height
                        from: begin; to: end
                        duration:500
                        easing.type: Easing.OutBack
                        easing.amplitude: 2.0
                        easing.period: 1.5
                }

        NumberAnimation on x {
                id:automanimx
                property real begin: root.width - automations.width
                property real end : root.width
                from: begin
                to: end
                duration:500
                easing.type: Easing.OutBack
                easing.amplitude: 2.0
                easing.period: 1.5
        }
        Text{
            id:automationTitle
            text:qsTr("Scrolling Automation")
            anchors.top:automations.top
            anchors.topMargin: root.hwratio < 1 ? root.hunit*0.5 : root.vunit*0.5
            anchors.horizontalCenter: automations.horizontalCenter
            color:currentFontColour
            font.family: scriptFont.name
            font.bold: true
            font.pointSize: PlTools.setPointSize(0.25)
        }

        /********************************
          Clear Automation
        *********************************/
        Rectangle {
            id: clearAutom

            width: automationTitle.width*0.8 // root.hunit * 1.5
            height: root.vunit * 1.5
            anchors.top:automationTitle.top
            anchors.topMargin: root.hwratio < 1 ? root.hunit*0.5 : root.vunit*0.5
            anchors.horizontalCenter: automations.horizontalCenter

            color: automationFlag?"green":"grey"
            border.width: 0.5
            border.color: "white"
            radius: root.hwratio < 1 ? root.hunit/5 : root.vunit / 5
            property bool isplaying:false
            property alias imagePlay:imagePlay
            property alias mousePlay:mousePlay

            Text{
                text:automationFlag?qsTr("Clear"):qsTr("Cleared")
                color:currentFontColour
                font.family: scriptFont.name
                font.bold: true
                font.pointSize: PlTools.setPointSize(0.25)
                anchors.centerIn: parent
            }
            MouseArea {
                    id: mouseAutomClear
                    enabled: automationFlag?true:false
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height
                    hoverEnabled: true
                    onClicked: {
                        automationFlag=false
                        PlTools.clearAutomation(root.curentTuneTitleHandle.text) //console.log(">>>> CLEAR AUTOM")
                    }
                    Rectangle {
                        anchors.fill: parent
                        opacity: mouseAutomClear.pressed ? 1 : 0
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
          Record Automation
        *********************************/
        Rectangle {
            id: recAutom

            width: automationTitle.width*0.8 //root.hunit * 1.5
            height: root.vunit * 1.5
            anchors.top:clearAutom.bottom
            anchors.topMargin: root.hwratio < 1 ? root.hunit*0.5 : root.vunit*0.5
            anchors.horizontalCenter: automations.horizontalCenter

            color: root.automationRecord ? "red" : "gray"
            border.width: 0.5
            border.color: "white"
            radius: root.hwratio < 1 ? root.hunit/5 : root.vunit / 5
            property bool isplaying:false
            property alias imagePlay:imagePlay
            property alias mousePlay:mousePlay

            Text{
                text: root.automationRecord ? qsTr("Recording") : qsTr("Record")
                color:currentFontColour
                font.family: scriptFont.name
                font.bold: true
                font.pointSize: PlTools.setPointSize(0.25)
                anchors.centerIn: parent
            }
            MouseArea {
                    id: mouseAutomRec
                    enabled: automationFlag?false:true
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height
                    hoverEnabled: true
                    onClicked: root.automationRecord=!root.automationRecord
                    Rectangle {
                        anchors.fill: parent
                        opacity: mouseAutomRec.pressed ? 1 : 0
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
    /***********************************
       MENU Hide/Show Automation scroll control
    ************************************/
    Rectangle {
        id:controlAutomation
        width : root.hwratio < 1 ? root.hunit*0.8: root.vunit*0.8
        height: root.hwratio < 1 ? root.hunit: root.vunit
        color:currentBackGroundColour
        y:0
        ////z:1
        anchors.right: controlPop.left
        anchors.rightMargin: 0
        visible:false
        //border.color: "yellow"
        Image {
         id: butAutomation
         source: "../images/menu-button_black.png"
         anchors.fill:parent
        }
        MouseArea {
         anchors.fill: parent

         onClicked: {
             automations.visible ? controlAutomation.color=currentBackGroundColour:controlAutomation.color="green"
             PlTools.controlHideShow(automations,
                                            controlAutomation.height,
                                            -automations.height ,
                                            root.width - automations.width - controls.width,
                                            root.width,
                                            automations.automanimx,
                                            automations.automanimy)
            }
        }

    }

    /***********************************
     MENU Tools
    ************************************/
    Rectangle {
       id:toolsControl
       width : root.hwratio < 1 ? root.hunit*0.8: root.vunit*0.8
       height: root.hwratio < 1 ? root.hunit*0.5: root.vunit*0.5
       color:currentBackGroundColour
       y:root.height - height
       border.color: "darkgray"
       border.width: 1
       radius: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
       anchors.left : root.left
       Image {
           id: toolsControlImage
           source: "../images/tools.png"
           anchors.fill:parent
       }
       MouseArea {
           id: mousetoolsControl
           anchors.fill: parent
           onClicked: {
               if(toolMenu.toolsAccess.showhide){
                   toolsControl.color=currentBackGroundColour
                   PlTools.modalMode("disabled")
               }
               else{
                   toolsControl.color="green"
                   PlTools.modalMode("enabled")
                   toolsControl.enabled=true
               }


               PlTools.controlHideShow(toolMenu.toolsAccess,
                                      controlPop.height,
                                      root.height,
                                      0,
                                      0,
                                      toolMenu.toolsAccess.toolsanimx,
                                      toolMenu.toolsAccess.toolsanimy)
               //llEnabled=!llEnabled
           }
           Rectangle {
               anchors.fill: parent
               opacity: mousetoolsControl.pressed ? 1 : 0
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


    ToolMenu{
        id:toolMenu
    }

    /****************************************
      Playlist name display
    *****************************************/
    Text {
      id : playlistName
      visible:true
      text: ""
      color:root.currentFontColour
      font.family: currentListFont
      font.bold: true
      font.pointSize: PlTools.setPointSize(0.30)
      anchors.bottom: root.bottom
      //anchors.horizontalCenter: root.horizontalCenter
      anchors.left: toolsControl.right
      anchors.leftMargin: root.hwratio < 1 ? root.hunit*0.4: root.vunit*0.4
      anchors.topMargin: root.hwratio < 1 ? root.hunit*0.4: root.vunit*0.4
    }

    /****************************************
      CSV EDITOR
    *****************************************/
    Rectangle {
       id:csveditor
       visible: !fontsizeLess.visible  && currentPane === 0
       width : root.hwratio < 1 ? root.hunit*0.8: root.vunit*0.8
       height: root.hwratio < 1 ? root.hunit*0.5: root.vunit*0.5
       color:currentBackGroundColour
       y:root.height - height
       border.color: "darkgray"
       border.width: 1
       radius: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
       anchors.left : playlistName.right
       anchors.leftMargin: root.hwratio < 1 ? root.hunit*0.4: root.vunit*0.4

       Image  {
           id: csveditorImage
           anchors.fill: parent
           opacity: 1
           Behavior on opacity {NumberAnimation {duration: 100}}
           source: "../images/Spreadsheet_64.png"
           fillMode: Image.PreserveAspectFit
       }
       MouseArea {
           id:mousecsveditor
           anchors.fill: parent
           onClicked: {
               //Wait               
               generalBusy.running=true
               generalBusy.visible=true

               //console.log('>>> EDITOR CSV',csvedit.editcsv.hasBeenModified,csvedit.visible,setlistDir)
               if(csvedit.visible) { //Editeur deja actif
                   csveditor.color=currentBackGroundColour
                   //root.inputFake.focus=true
                   PlTools.modalMode("disabled")
                   if(csvedit.editcsv.hasBeenModified){                       
//                       csvedit.editcsv.copyLocalToWork()
//                       csvedit.editcsv.saveDone=true

                       csvedit.editcsv.hasBeenModified=false
                       messageDialog.setText(qsTr("Save changes ?"))
                       messageDialog.visible=true
                       messageDialog.buttonOK=true
                       messageDialog.action=4
                   }
               }
               else {
                   csveditor.color="green"
                   messageDialog.visible=false
                   PlTools.modalMode("enabled")                   
                   csveditor.enabled=true
                   csvedit.editcsv.copyWorkToLocal()
               }
               csvedit.visible=!csvedit.visible
               generalBusy.running=false
               generalBusy.visible=false
           }
           Rectangle {
               anchors.fill: parent
               opacity: mousecsveditor.pressed ? 1 : 0
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
      CSV SWITCHG FILE
    *********************************/
    Rectangle {
       id:csvswitch
       visible: csveditor.visible
       width : root.hwratio < 1 ? root.hunit*0.8: root.vunit*0.8
       height: root.hwratio < 1 ? root.hunit*0.5: root.vunit*0.5
       color:currentBackGroundColour
       y:root.height - height
       border.color: "darkgray"
       border.width: 1
       radius: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
       anchors.left : csveditor.right
       anchors.leftMargin: root.hwratio < 1 ? root.hunit*0.4: root.vunit*0.4

       Image  {
           id: csvswitchImage
           anchors.fill: parent
           opacity: 1
           Behavior on opacity {NumberAnimation {duration: 100}}
           source: "../images/Switch_64.png"
           fillMode: Image.PreserveAspectFit
       }
       MouseArea {
           id:mousecsvswitch
           anchors.fill: parent
           onClicked: {
               //console.log('>>> SWITCH CSV')
               PlTools.switchPlayLIst()
               //csvedit.visible=!csvedit.visible
           }
           Rectangle {
               anchors.fill: parent
               opacity: mousecsvswitch.pressed ? 1 : 0
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
      CSV Add Line
    *********************************/
    Rectangle {
       id:csveditorAdd
       visible: csvedit.visible
       width : root.hwratio < 1 ? root.hunit*0.8: root.vunit*0.8
       height: root.hwratio < 1 ? root.hunit*0.5: root.vunit*0.5
       color:currentBackGroundColour
       y:root.height - height
       //border.color: "darkgray"
       //border.width: 1
       radius: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
       anchors.left : csveditor.right
       anchors.leftMargin: root.hwratio < 1 ? root.hunit*0.4: root.vunit*0.4

       Image  {
           id: csveditorAddImage
           anchors.fill: parent
           opacity: 1
           Behavior on opacity {NumberAnimation {duration: 100}}
           source: "../images/round69.png"
           fillMode: Image.PreserveAspectFit
       }
       MouseArea {
           id:mousecsveditorAdd
           anchors.fill: parent
           onClicked: {
               //console.log('>>>  EDITOR ADD')
               csvedit.editcsv.addTune()
           }
           Rectangle {
               anchors.fill: parent
               opacity: mousecsveditorAdd.pressed ? 1 : 0
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
      CSV Delete line
    *********************************/
    Rectangle {
       id:csveditorDel
       visible: csvedit.visible
       width : root.hwratio < 1 ? root.hunit*0.8: root.vunit*0.8
       height: root.hwratio < 1 ? root.hunit*0.5: root.vunit*0.5
       color:currentBackGroundColour
       y:root.height - height
       //border.color: "darkgray"
       //border.width: 1
       radius: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
       anchors.left : csveditorAdd.right
       anchors.leftMargin: root.hwratio < 1 ? root.hunit*0.4: root.vunit*0.4

       Image  {
           id: csveditorImageDel
           anchors.fill: parent
           opacity: 1
           Behavior on opacity {NumberAnimation {duration: 100}}
           source: "../images/round73.png"
           fillMode: Image.PreserveAspectFit
       }
       MouseArea {
           id:mousecsveditorDel
           anchors.fill: parent
           onClicked: {
               //console.log('>>> EDITOR DEL',csvedit.editcsv.currentIndex)
               csvedit.editcsv.deleteCurrentRow();
           }
           Rectangle {
               anchors.fill: parent
               opacity: mousecsveditorDel.pressed ? 1 : 0
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

    /****************************************
      ScrollMode / PageMode
    *****************************************/
    Rectangle {
       id:scrollOrPageMode
       //visible: root.currentTuneTitle !== "" ? fontsizeLess.visible && remoteEnabled : false
       visible: root.currentTuneTitle !== "" ? fontsizeLess.visible  : false
       width : root.hwratio < 1 ? root.hunit*0.8: root.vunit*0.8
       height: root.hwratio < 1 ? root.hunit*0.5: root.vunit*0.5
       color:currentBackGroundColour
       y:root.height - height
       border.color: "darkgray"
       border.width: 1
       radius: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
       anchors.right : lyricsEdit.left
       anchors.rightMargin: root.hwratio < 1 ? root.hunit*0.4: root.vunit*0.4

       Image  {
           id: scrollOrPageModeImage
           anchors.fill: parent
           opacity: 1
           Behavior on opacity {NumberAnimation {duration: 100}}
           source: pageMode ? "../images/pagemode_x64.png" : "../images/scrollmode_x64.png"
           fillMode: Image.PreserveAspectFit
       }
       MouseArea {
           id: mousescrollOrPageMode
           anchors.fill: parent
           onClicked: {
               pageMode=!pageMode
           }
           Rectangle {
               anchors.fill: parent
               opacity: mousescrollOrPageMode.pressed ? 1 : 0
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

    /****************************************
      Edit lyrics
    *****************************************/
    Rectangle {
       id:lyricsEdit
       visible: root.currentTuneTitle !== "" ? fontsizeLess.visible : false
       width : root.hwratio < 1 ? root.hunit*0.8: root.vunit*0.8
       height: root.hwratio < 1 ? root.hunit*0.5: root.vunit*0.5
       color:currentBackGroundColour
       y:root.height - height
       border.color: "darkgray"
       border.width: 1
       radius: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
       anchors.right : lyricsSave.left
       anchors.rightMargin: root.hwratio < 1 ? root.hunit*0.4: root.vunit*0.4

       Image  {
           id: lyricsEditImage
           anchors.fill: parent
           opacity: 1
           Behavior on opacity {NumberAnimation {duration: 100}}
           source: "../images/edit.png"
           fillMode: Image.PreserveAspectFit
       }
       MouseArea {
           id: mouselyricsEdit
           anchors.fill: parent
           onClicked: {               
               lyricsEdition=!lyricsEdition
               if(lyricsEdition){
                   PlTools.modalMode("enabled")
                   root.mousePlay.enabled=false
                   root.mouseSync.enabled=false
                   root.mouseInfo.enabled=false
                   lyricsEdit.color="green"
               }
               else{
                   PlTools.modalMode("disabled")
                   root.mousePlay.enabled=true
                   root.mouseSync.enabled=true
                   root.mouseInfo.enabled=true
                   lyricsEdit.color=currentBackGroundColour
               }
               swipeZone.enabled=true
               mouselyricsEdit.enabled=true
               lyricsEdit.enabled=true

               if(lyricsModified)
                   lyricsSave.visible=(lyricsModified && lyricsEditImage.visible) || (lyricsSave.fontsizeSave && lyricsEditImage.visible)
           }
           Rectangle {
               anchors.fill: parent
               opacity: mouselyricsEdit.pressed ? 1 : 0
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
    /****************************************
      Save modified lyrics
    *****************************************/
    Rectangle {
       id:lyricsSave
       visible: (lyricsModified && lyricsEditImage.visible) || (lyricsSave.fontsizeSave && lyricsEditImage.visible)
       width : root.hwratio < 1 ? root.hunit*0.8: root.vunit*0.8
       height: root.hwratio < 1 ? root.hunit*0.5: root.vunit*0.5
       property bool fontsizeSave: false

       color:"orange"
       y:root.height - height
       border.color: "darkgray"
       border.width: 1
       radius: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
       anchors.right : fontsizeLess.left
       anchors.rightMargin: root.hwratio < 1 ? root.hunit*0.4: root.vunit*0.4

       Image  {
           id: lyricsSaveImage
           anchors.fill: parent
           opacity: 1
           Behavior on opacity {NumberAnimation {duration: 100}}
           source: "../images/Save_icon_64.png"
           fillMode: Image.PreserveAspectFit
       }
       MouseArea {
           id: mouselyricsSave
           anchors.fill: parent
           onClicked: {
               messageDialog.setText(qsTr("Save changes ?"))
               messageDialog.visible=true
               messageDialog.buttonOK=true
               messageDialog.action=6
           }
           Rectangle {
               anchors.fill: parent
               opacity: mouselyricsSave.pressed ? 1 : 0
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

    /****************************************
      Font size adjustement less
    *****************************************/
    Rectangle {
       id:fontsizeLess
       visible: false
       width : root.hwratio < 1 ? root.hunit*0.8: root.vunit*0.8
       height: root.hwratio < 1 ? root.hunit*0.5: root.vunit*0.5
       color:currentBackGroundColour
       y:root.height - height
       border.color: "darkgray"
       border.width: 1
       radius: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
       anchors.right : fontsizedef.left
       anchors.rightMargin: root.hwratio < 1 ? root.hunit*0.4: root.vunit*0.4

       Image  {
           id: fontsizeLessImage
           anchors.fill: parent
           opacity: 1
           Behavior on opacity {NumberAnimation {duration: 100}}
           source: "../images/Zoom_out_64.png"
           fillMode: Image.PreserveAspectFit
       }
       MouseArea {
           id:mousefontsizeLess
           anchors.fill: parent
           onClicked: {
               lyricsSave.visible=true
               lyricsSave.fontsizeSave=true
               textFontSize=textFontSize-(textFontSize*.10)
           }
           Rectangle {
               anchors.fill: parent
               opacity: mousefontsizeLess.pressed ? 1 : 0
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
    /****************************************
      Font size adjustement default
    *****************************************/
    Rectangle {
       id:fontsizedef
       visible: fontsizeLess.visible
       width : root.hwratio < 1 ? root.hunit*0.8: root.vunit*0.8
       height: root.hwratio < 1 ? root.hunit*0.5: root.vunit*0.5
       color:currentBackGroundColour
       y:root.height - height
       border.color: "darkgray"
       border.width: 1
       radius: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
       anchors.right : fontsizeMore.left
       anchors.rightMargin: root.hwratio < 1 ? root.hunit*0.4: root.vunit*0.4       

       Image  {
           id: fontsizedefImage
           anchors.fill: parent
           opacity: 1
           Behavior on opacity {NumberAnimation {duration: 100}}
           source: "../images/zoom_def_64.png"
           fillMode: Image.PreserveAspectFit
       }
       MouseArea {
           id:mousefontsizedef
           anchors.fill: parent
           onClicked: {
               lyricsSave.visible=true
               lyricsSave.fontsizeSave=true
               textFontSize=PlTools.setPointSize(0.85)
           }
           Rectangle {
               anchors.fill: parent
               opacity: fontsizedef.pressed ? 1 : 0
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
    /****************************************
      Font size adjustement more
    *****************************************/
    Rectangle {
       id:fontsizeMore
       visible: fontsizeLess.visible
       width : root.hwratio < 1 ? root.hunit*0.8: root.vunit*0.8
       height: root.hwratio < 1 ? root.hunit*0.5: root.vunit*0.5
       color:currentBackGroundColour
       y:root.height - height
       border.color: "darkgray"
       border.width: 1
       radius: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
       anchors.right : root.right
       anchors.rightMargin: root.hwratio < 1 ? root.hunit*0.4: root.vunit*0.4       

       Image  {
           id: fontsizeMoreImage
           anchors.fill: parent
           opacity: 1
           Behavior on opacity {NumberAnimation {duration: 100}}
           source: "../images/zoom_in_64.png"
           fillMode: Image.PreserveAspectFit
       }
       MouseArea {
           id: mousefontsizeMore
           anchors.fill: parent
           onClicked: {
               lyricsSave.visible=true
               lyricsSave.fontsizeSave=true
               textFontSize=textFontSize+(textFontSize*.10)
           }
           Rectangle {
               anchors.fill: parent
               opacity: mousefontsizeMore.pressed ? 1 : 0
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

    /****************************************
      Remote control connection
    *****************************************/
    Rectangle{
        id:remoteActivatio
        width : root.hwratio < 1 ? root.hunit*0.8: root.vunit*0.8
        height: root.hwratio < 1 ? root.hunit*0.5: root.vunit*0.5
        color:remotePluged ? "green":currentBackGroundColour
        y:0
        radius: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
        anchors.right: inappRemote.left
        anchors.rightMargin: root.hwratio < 1 ? root.hunit*0.1: root.vunit*0.1
        anchors.topMargin: root.hwratio < 1 ? root.hunit*0.2: root.vunit*0.2
        anchors.top:root.top
        visible:remoteEnabled

        Image  {
            id:remoteActivatioImage
            property bool pluged: remotePluged
            anchors.fill: parent
            source: remotePluged ? "../images/wireless_on_x64.png" : "../images/wireless_off_x64.png"
            fillMode: Image.PreserveAspectFit
            onPlugedChanged: {
                source: remotePluged ? "../images/wireless_on_x64.png" : "../images/wireless_off_x64.png"
            }
        }
        MouseArea {
            id:remoteActivatioMouse
            anchors.fill: parent
            enabled: !liteMode
            onClicked: {
                remotePluged=!remotePluged
                inputFake.focus=remotePluged
                remotePluged ? remoteActivatio.color="green":remoteActivatio.color=currentBackGroundColour
            }
        }
        Rectangle {
            anchors.fill: parent
            opacity: remoteActivatioMouse.pressed ? 1 : 0
            Behavior on opacity { NumberAnimation{ duration: 100 }}
            gradient: Gradient {
                GradientStop { position: 0 ; color: "#22000000" }
                GradientStop { position: 0.2 ; color: "#44000000" }
            }
            border.color: "darkgray"
            radius: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
        }
    }

    /****************************************
      Remote control buy
    *****************************************/
    Rectangle{
        id:inappRemote
        width : root.hwratio < 1 ? root.hunit*0.8: root.vunit*0.8
        height: root.hwratio < 1 ? root.hunit*0.5: root.vunit*0.5
        color:currentBackGroundColour
        y:0
        radius: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
        anchors.right: playerIndicator.left
        anchors.rightMargin: root.hwratio < 1 ? root.hunit*0.1: root.vunit*0.1
        anchors.topMargin: root.hwratio < 1 ? root.hunit*0.2: root.vunit*0.2
        anchors.top:root.top

        visible:true
        enabled: true

        Image  {
            id:inappRemoteImage
            anchors.fill: parent
            source: "../images/shop3.png" // remoteEnabled ? "../images/wireless_on_x64.png" : "../images/wireless_off_x64.png"
            fillMode: Image.PreserveAspectFit
        }
        MouseArea {
            id:inappRemoteMouse
            anchors.fill: parent
            enabled: true
            onClicked: {                
                if(inappByer.visible){                    
                    inappRemote.color=currentBackGroundColour
                    PlTools.modalMode("disabled")
                }
                else{
                    inappRemote.color="green"
                    PlTools.modalMode("enabled")
                    inappRemote.enabled=true
                }
                inappByer.visible=!inappByer.visible
            }
        }
        Rectangle {
            anchors.fill: parent
            opacity: inappRemoteMouse.pressed ? 1 : 0
            Behavior on opacity { NumberAnimation{ duration: 100 }}
            gradient: Gradient {
                GradientStop { position: 0 ; color: "#22000000" }
                GradientStop { position: 0.2 ; color: "#44000000" }
            }
            border.color: "darkgray"
            radius: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
        }
    }

    /****************************************
      Automation indicators
    *****************************************/
    Text {
        id: automationIndicator
        y:0
        anchors.right: remoteActivatio.left
        visible:true
        text: {
            if(root.automationFlag)
               qsTr("Scroll automation")
            else
                if(root.automationRecord)
                    qsTr("Scroll Recording")
                else
                    ""
        }
        color:root.automationRecord?"red":"white"
        font.family: currentListFont
        font.bold: true
        font.pointSize: PlTools.setPointSize(0.20)
        anchors.top: root.top
        anchors.topMargin: root.hwratio < 1 ? root.hunit*0.4: root.vunit*0.4
    }

    /*******************************
      Player Indicator
    *******************************/
    Image {
        id: playerIndicator
        visible:false
        width : root.hwratio < 1 ? root.hunit*1.5: root.vunit*1.5
        height: root.hwratio < 1 ? root.hunit: root.vunit
        source: root.audioFile != "" ? "../images/Speaker_Icon.png" : "../images/lyrics-128x128.png"
        y:0
        anchors.right: controlAutomation.left
        anchors.rightMargin: root.hwratio < 1 ? root.hunit*0.1: root.vunit*0.1
        scale:0.4
        PropertyAnimation on scale {
            id:playerAnim
            property bool bigger:true
            from : bigger ? 0.3 : 0.4
            to : bigger ? 0.4 : 0.3
            duration:2000
            loops: 1
            running:true
            onStopped: {
                bigger=!bigger
                playerAnim.start()
            }
        }
    }
    BusyIndicator{
        id:busyplayerIndicator
        height: playerIndicator.height
        width: playerIndicator.width
        anchors.centerIn: playerIndicator
        anchors.bottom: parent.bottom
        running:playerIndicator.visible
    }


    /*******************************
      Chords Display
    *******************************/


    Rectangle{
        id:chordsDisplay
        visible: false
        width: Screen.desktopAvailableWidth
        height: Screen.desktopAvailableHeight        
        anchors.centerIn: root        
        radius: root.hwratio < 1 ? root.hunit/30 : root.vunit / 30
        color:"white"
        Component.onCompleted: {
            root.chordsDisplay = chordsDisplay
        }
        Flickable {
            id:flickContenair
            anchors.fill: parent
            contentWidth:Screen.desktopAvailableWidth*.9            
            contentHeight:imageChordsDisplay.height
            property real swipeY: 0
            flickableDirection: Flickable.VerticalFlick
            clip:true
            Component.onCompleted: {
                root.flickContenair = flickContenair
            }
            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                y:0
                id:imageChordsDisplay
                scale:1
                Component.onCompleted: {
                    root.imageChordsDisplay = imageChordsDisplay
                }
            }
            MouseArea{
                onClicked: {
                    chordsDisplay.visible=false
                    inputFake.focus = false
                }
                anchors.fill: parent
            }
        }

        MouseArea{
            id:mouseHideChords
            enabled: false
            onClicked: {
                if(root.pdfDisplay != undefined){
                    root.pdfDisplay.destroy() ;
                    root.pdfDisplay = undefined;
                }
                chordsDisplay.visible=false
                inputFake.focus = false
            }
            anchors.fill: parent
            Component.onCompleted: {
                root.mouseHideChords=mouseHideChords
            }
        }
    }

    /*====================================
      Message Box
      ===================================*/
    Rectangle {
        id: messageDialog
        visible:false
        color: "orange"

        width:buttonOK ? errorMsg.width*1.2 + okbutMessDialog.width : errorMsg.width*1.2
        height:buttonOK ? errorMsg.height*1.2 + okbutMessDialog.height + ( 4 * errorMsg.anchors.topMargin) + csvFileName.height : errorMsg.height*2

        property bool buttonOK:false
        property int action:0

        //height:root.hunit*5
        anchors.verticalCenter: root.verticalCenter
        anchors.horizontalCenter: root.horizontalCenter
        border.color: currentBackGroundColour
        border.width: 3
        radius:root.hwratio < 1 ? root.hunit/30 : root.vunit / 30
        ////z:0
        function setText(message) {
            errorMsg.text=message
        }

        Text{
            id:errorMsg
            text: ""
            anchors.top : messageDialog.top
            anchors.topMargin: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
            anchors.horizontalCenter: parent.horizontalCenter
            //font.pointSize: 10
            font.pointSize: PlTools.setPointSize(0.33)
        }

        Rectangle{
            id:csvFileName
            visible: false
            anchors.horizontalCenter: messageDialog.horizontalCenter
            anchors.top:errorMsg.bottom
            anchors.topMargin: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
            color:"lightgrey"
            height: csvFileNameEditor.height
            width: messageDialog.width * 0.8
            TextInput {
                id:csvFileNameEditor
                width:parent.width
                text:playlistName.text
                font.pointSize: PlTools.setPointSize(0.33)
                anchors.centerIn: parent
            }
        }

        Rectangle{
            id:okbutMessDialog
            anchors.left: parent.left
            anchors.leftMargin: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
            anchors.bottom : parent.bottom
            anchors.bottomMargin: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5

            width:  root.hwratio < 1 ? root.vunit*1.5  : root.hunit*1.5 //root.hunit
            height: root.hwratio < 1 ? root.vunit  : root.hunit //root.vunit

            color: "gray"
            radius: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
            visible:messageDialog.buttonOK

            onVisibleChanged: {
                if(visible){
                    PlTools.modalMode("enabled")
                }
                else{
                    PlTools.modalMode("disabled")
                }
            }
            Text{
                text:"Ok"
                font.family: scriptFont.name
                font.pointSize: PlTools.setPointSize(0.25)
                font.bold: true
                color:currentFontColour
                anchors.fill: parent
                horizontalAlignment: "AlignHCenter"
                verticalAlignment: "AlignVCenter"
            }
            MouseArea {
                id: mouseokbutMessDialog
                anchors.centerIn: parent
                width: parent.width
                height: parent.height
                hoverEnabled: true
                onClicked: {                    
                    switch(messageDialog.action){
                        case 0 :
                            // Do nothing
                            messageDialog.buttonOK=false
                            messageDialog.visible=false
                            break;
                        case 1 :
                            // First dropbox synchronization
                            var rc=dropBoxOperations.authorization()
                            messageDialog.buttonOK=false
                            messageDialog.visible=false
                            messageDialog.action=0
                            if ( rc < 0){
                                if (rc==-5){
                                    messageDialog.setText(qsTr("Local tokens file acces denied"))
                                    messageDialog.visible=true
                                }

                                else {
                                    messageDialog.setText(qsTr("DropBox connection Error : ") + rc)
                                    messageDialog.visible=true
                                }
                            }
                            else {
                                // Lance la synchro dropBox
                                dropboxContainer.visible=true
                                dropBoxOperations.downloaddone=false
                            }

                            break;
                        case 2 :
                            // Erase files in current list
                            busyActivity.running=true
                            cancelbutMessDialog.enabled=false                            
                            var index
                            for	(index = 0; index < listTune.length; index++) {
                                //console.log(root.listTune[index]["audioFile"],"==",root.listTune[index]["lyricsFile"],"==",root.listTune[index]["chordsFile"])
                                fileService.deleteFile(root.listTune[index]["audioFile"])
                                fileService.deleteFile(root.listTune[index]["lyricsFile"])
                                fileService.deleteFile(root.listTune[index]["chordsFile"])
                            }
                            busyActivity.running=false
                            cancelbutMessDialog.enabled=true
                            errorMsg.text=qsTr("List deleted")
                            messageDialog.action=0
                            listTune=[]
                            playlistName.text=""
                            currentPlaylist=""
                            loadTuneList=!loadTuneList
                            root.main()
                            break;

                        case 3 :
                            // Erase current list (csv file)
                            busyActivity.running=true
                            cancelbutMessDialog.enabled=false
                            fileService.deleteFile(currentPlaylist+".csv")
                            busyActivity.running=false
                            cancelbutMessDialog.enabled=true
                            errorMsg.text=qsTr("List deleted")
                            messageDialog.action=7
                            break;

                        case 4 :
                            // Save current list
                            messageDialog.visible=false
                            messageDialog.action=5
                            csvFileName.visible=true
                            messageDialog.setText(qsTr("SetList Name"))
                            messageDialog.visible=true
                            break;

                        case 5 :
                            // edit csv file name to save in
                            csvedit.editcsv.copyLocalToWork()
                            csvedit.editcsv.saveDone=true                            
                            PlTools.reloadListTune()

                            messageDialog.action=0
                            messageDialog.buttonOK=false
                            messageDialog.visible=false
                            csvFileName.visible=false                                                
                            fileService.saveCsvFile(setlistDir+csvFileNameEditor.text,listTune)
                            PlTools.switchPlayLIst()
                            break;

                        case 6 :
                            // Save lyrics file
                            messageDialog.action=0
                            messageDialog.buttonOK=false
                            messageDialog.visible=false
                            if(lyricsModified){
                                //console.log("SAVE LYRCIS")
                                //TODO:OK Passer le nom du dossier de stockage également

                                // If lyricsFile is currently empty, set it with the current Title
                                if(root.tuneModel.get(root.listViewHandler.currentIndex).lyricsFile == "")
                                    root.tuneModel.setProperty(root.listViewHandler.currentIndex, "lyricsFile", setlistDir+"lyrics/"+ root.tuneModel.get(root.listViewHandler.currentIndex).title + ".txt")

                                fileService.saveTxtFile(root.currentLyricsFile,root.currentTuneTitle,root.currentLyrics,setlistDir)
                                PlTools.reloadListTune()
                                fileService.saveCsvFile(setlistDir+csvFileNameEditor.text,listTune)
                                lyricsModified=false
                                lyricsSave.visible=(lyricsModified && lyricsEditImage.visible) || (lyricsSave.fontsizeSave && lyricsEditImage.visible)
                            }
                            if(lyricsSave.fontsizeSave){
                                Db.updateFontSize(root.curentTuneTitleHandle.text,textFontSize,playlistName.text)
                                lyricsSave.fontsizeSave=false
                                lyricsSave.visible=(lyricsModified && lyricsEditImage.visible) || (lyricsSave.fontsizeSave && lyricsEditImage.visible)
                            }

                            break;
                        case 7 :
                            // Choose list after delete one list
                            messageDialog.buttonOK=false
                            messageDialog.visible=false
                            listTune=[]
                            playlistName.text=""
                            currentPlaylist=""
                            loadTuneList=!loadTuneList
                            root.main()
                            break;

                    }
                }
                Rectangle {
                    anchors.fill: parent
                    opacity: mouseokbutMessDialog.pressed ? 1 : 0
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

        BusyIndicator{
            id:busyActivity
            height: root.hwratio < 1 ? root.vunit  : root.hunit //root.vunit
            anchors.right: okbutMessDialog.left
            anchors.left: okbutMessDialog.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: root.hwratio > 1 ? root.hunit/4 : root.vunit / 4
            anchors.leftMargin: root.hwratio > 1 ? root.hunit/4 : root.vunit / 4
            anchors.bottomMargin: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
            running:false
        }

        Rectangle{
            id:cancelbutMessDialog
            anchors.right: parent.right
            anchors.rightMargin: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
            anchors.bottom : parent.bottom
            anchors.bottomMargin: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5

            width:  root.hwratio < 1 ? root.vunit*1.5  : root.hunit*1.5 //root.hunit
            height: root.hwratio < 1 ? root.vunit  : root.hunit //root.vunit

            color: "gray"
            radius: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
            visible:messageDialog.buttonOK

            Text{
                text:"Cancel"
                font.family: scriptFont.name
                font.pointSize: PlTools.setPointSize(0.25)
                font.bold: true
                color:currentFontColour
                anchors.fill: parent
                horizontalAlignment: "AlignHCenter"
                verticalAlignment: "AlignVCenter"
            }
            MouseArea {
                id: mousecancelbutMessDialog
                anchors.centerIn: parent
                width: parent.width
                height: parent.height
                hoverEnabled: true
                onClicked: {
                    messageDialog.buttonOK=false
                    messageDialog.visible=false
                }
                Rectangle {
                    anchors.fill: parent
                    opacity: mousecancelbutMessDialog.pressed ? 1 : 0
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


    /*====================================
      Playlist Chooser
    ====================================*/
    Rectangle {
        id: chooserContainer

        width: root.hunit * 4
        height: root.vunit * 4

        visible: false

        property variant chooserModel: []

        color: currentBackGroundColour
        border.width: 0.5
        border.color: "lightgray"
        radius: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
        anchors.horizontalCenter: root.horizontalCenter
        anchors.verticalCenter: root.verticalCenter
        onVisibleChanged: {
            if(visible){
                PlTools.modalMode("enabled")
            }
            else{
                PlTools.modalMode("disabled")
            }
        }

        Text{
            id:textChooser
            text:qsTr('Choose Playlist')
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 10
            color:currentFontColour
            font.family: scriptFont.name
            //font.pointSize: root.hwratio > 1 ? root.hunit/3 : root.vunit / 3
            font.pointSize: PlTools.setPointSize(0.33)
            font.bold: true
        }



        ComboBox{
            id:listChooser
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: textChooser.bottom
            width:parent.width * 0.8
            anchors.topMargin: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
            height:parent.height * 0.2
            model:parent.chooserModel
            style: comboStyle
        }
        /********************************
          Ok Button
        *********************************/
        Rectangle {
            /*
              Playlist Ok button
            */
            id: butChooser
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
            width:  root.hwratio < 1 ? root.vunit*1.5  : root.hunit*1.5 //root.hunit
            height: root.hwratio < 1 ? root.vunit  : root.hunit //root.vunit
            color: "gray"
            border.width: 0.5            
            radius: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
            Text{
                text:qsTr("Choose")
                font.family: scriptFont.name
                font.pointSize: PlTools.setPointSize(0.25)
                font.bold: true
                color:currentFontColour
                anchors.fill: parent
                horizontalAlignment: "AlignHCenter"
                verticalAlignment: "AlignVCenter"
                z:1
            }
            MouseArea {
                    id: butChooserMouse
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height
                    hoverEnabled: true
                    onClicked: {
                        var listTune
                        //console.log('>>>>>',listChooser.currentText)                        
                        currentPlaylist=listChooser.currentText
                        root.listTune=fileService.loadPlaylist(listChooser.currentText)
                        playlistName.text=listChooser.currentText
                        currentTuneTitle = ""
                        //console.log('>>>>>>',listTune)
                        //fillTune(listTune)
                        root.loadTuneList=!root.loadTuneList
                        chooserContainer.visible=false
                        controlPop.enabled=true
                        swipeZone.enabled=true
                    }
                    Rectangle {
                        anchors.fill: parent
                        opacity: butChooserMouse.pressed ? 1 : 0
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

    /*====================================
      Dropbox  synchro
    ======================================*/
    Rectangle {
        id: dropboxContainer

        width: textDropbox.width * 1.2 //root.hunit * 5
        height: root.vunit * 5

        visible: false

        color: currentBackGroundColour
        border.width: 0.5
        border.color: "lightgray"
        radius: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
        anchors.horizontalCenter: root.horizontalCenter
        anchors.verticalCenter: root.verticalCenter

        onVisibleChanged: {
            if(visible){
                PlTools.modalMode("enabled")
            }
            else{
                PlTools.modalMode("disabled")
            }
        }
        /********************************
          TITLE
        ********************************/
        Text{
            id:textDropbox
            text: android ? "" : dropBoxOperations.downloaddone ? qsTr("          Synchro Done         ") :  qsTr("Sync. to Confirm Synchronization")
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 10
            font.family: scriptFont.name
            color:currentFontColour
            //font.pointSize: root.hwratio > 1 ? root.hunit/3 : root.vunit / 3
            font.pointSize: PlTools.setPointSize(0.33)
            font.bold: true
        }

        /********************************
          SYNCHRO ACTIVITY
        ********************************/

            Rectangle{
                /*
                  Text scrolling zone
                 */
                id:dropboxTextArea
                anchors.top:textDropbox.bottom
                anchors.bottom: okbutDropbox.top
                anchors.bottomMargin: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width*0.8
                radius:root.hwratio > 1 ? root.hunit/5 : root.vunit / 5

                Flickable{
                    id:dropboxScrollText
                    height:dropboxTextArea.height
                    width:dropboxTextArea.width
                    flickableDirection: Flickable.VerticalFlick
                    clip: true

                    Text{
                        id:dropboxFile
                        width: dropboxTextArea.width
                        height: dropboxTextArea.height
                        property int wY:0
                        text: dropBoxOperations ? dropBoxOperations.currentdownload : ""
                        //lineHeightMode: Text.FixedSize
                        visible: true
                        font.pixelSize: PlTools.setPointSize(0.33)
                        font.family: lyricsFont.name
                        color: currentFontColour
                        Behavior on y { SmoothedAnimation { velocity: 20 } }
                        onTextChanged: {
                            if(wY*font.pixelSize <= dropboxFile.height)
                                wY+=1
                            else
                                dropboxFile.y-=font.pixelSize
                        }
                    }

                }
                color: currentBackGroundColour
            }

            /********************************
              Sync Button
            *********************************/
            Rectangle {
                /*
                  Dropbox Sync button
                */
                id: okbutDropbox
                //anchors.horizontalCenter: parent.horizontalCenter``
                property bool hasbbeenPressed: false
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.bottomMargin: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
                anchors.leftMargin: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
                width:  root.hwratio < 1 ? root.vunit*1.5  : root.hunit*1.5 //root.hunit
                height: root.hwratio < 1 ? root.vunit  : root.hunit //root.vunit
                color: "gray"
                radius: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5

                Text{
                    text:"Sync."                    
                    font.family: scriptFont.name
                    font.pointSize: PlTools.setPointSize(0.25)
                    font.bold: true
                    color:currentFontColour
                    anchors.fill: parent
                    horizontalAlignment: "AlignHCenter"
                    verticalAlignment: "AlignVCenter"
                }
                MouseArea {
                        id: okbutDropboxMouse
                        anchors.centerIn: parent
                        width: parent.width
                        height: parent.height
                        hoverEnabled: true
                        onClicked: {
                            okbutDropbox.hasbbeenPressed=true                            
                            dropBoxOperations.synchronyze()
                        }
                        Rectangle {
                            anchors.fill: parent
                            opacity: okbutDropboxMouse.pressed ? 1 : 0
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
              Download Animation
            *********************************/
            BusyIndicator{
                id:downloadDropboxAnim                
                height: root.hwratio < 1 ? root.vunit  : root.hunit //root.vunit
                anchors.right: cancelbutDropbox.left
                anchors.left: okbutDropbox.right
                anchors.bottom: parent.bottom
                anchors.rightMargin: root.hwratio > 1 ? root.hunit/4 : root.vunit / 4
                anchors.leftMargin: root.hwratio > 1 ? root.hunit/4 : root.vunit / 4
                anchors.bottomMargin: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
                running:dropBoxOperations ? dropBoxOperations.downloadanim : false
            }

            /********************************
              Dropbox OK/Cancel Button
            *********************************/
            Rectangle {
                /*
                  Dropbox Cancel button
                */
                id: cancelbutDropbox
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
                anchors.rightMargin: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
                width:  root.hwratio < 1 ? root.vunit*1.5  : root.hunit*1.5 //root.hunit
                height: root.hwratio < 1 ? root.vunit  : root.hunit //root.vunit
                color: "gray"
                radius: root.hwratio > 1 ? root.hunit/5 : root.vunit / 5
                enabled: true

                Text{
                    text: android ? "" : dropBoxOperations.downloaddone ? "Ok" :  qsTr("Cancel")
                    font.family: scriptFont.name
                    font.pointSize: PlTools.setPointSize(0.25)
                    font.bold: true
                    color:currentFontColour
                    anchors.fill: parent
                    horizontalAlignment: "AlignHCenter"
                    verticalAlignment: "AlignVCenter"
                    z:1
                }


                MouseArea {
                        id: cancelbutDropboxMouse
                        anchors.centerIn: parent
                        width: parent.width
                        height: parent.height
                        hoverEnabled: true
                        onClicked: {                            
                            dropboxContainer.visible=false                            
                            dropboxFile.wY=0
                            dropboxFile.y=0
                            if(okbutDropbox.hasbbeenPressed) {
                                okbutDropbox.hasbbeenPressed=false
                                root.main()
                            }
                        }
                        enabled: true
                        Rectangle {
                            anchors.fill: parent
                            opacity: cancelbutDropboxMouse.pressed ? 1 : 0
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
    /********************************
      CSV EDITOR
    *********************************/

    Rectangle {
        id: csvedit
        visible: false
        //property bool loadTuneList : root.loadTuneList
        property alias editcsv: editcsv
        border.color: "white"
        color: root.currentBackGroundColour
        width: root.width
        height: root.height - fontsizeLess.height
        anchors.top:root.top
        anchors.bottom: fontsizeLess.top
        anchors.bottomMargin: root.hwratio < 1 ? root.hunit/5 : root.vunit / 5
        //anchors.left: SwipeView.left
        //anchors.leftMargin: root.hunit
        anchors.horizontalCenter: root.horizontalCenter
        anchors.topMargin: root.hwratio < 1 ? root.hunit/5 : root.vunit / 5

        radius: root.hwratio < 1 ? root.hunit/5 : root.vunit / 5
        border.width: 0.5

        CsvEditor {
            id: editcsv
            //enabled: root.llEnabled
            anchors.fill: parent
        }

    }

    BusyIndicator {
        id : generalBusy
        visible: false
        running: false
        anchors.centerIn: root
    }

    /********************************
      InApp Buy
    *********************************/
    Rectangle {
        id: inappByer
        visible: false
        border.color: "white"
        color: root.currentBackGroundColour
        width: root.width
        height: root.height * .8
        anchors.top:root.top
        anchors.centerIn: root
        InAppProcess {
            id: inappBuyerProcess
            anchors.fill: parent
        }
    }

    /********************************
      ComboBox Style Control
    *********************************/
    Component{
        id:comboStyle
        ComboBoxStyle{
            background: bckgrdCombo
            textColor: "black"
        }
    }
    Component{
        Rectangle {
            implicitWidth: 200
            implicitHeight: 25
            color: "lightgrey"
            border.width: 1
            antialiasing: true
            Rectangle {
                id: glyph
                width: 16
                height: 16
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 10
                color: "black"
                states: State {
                    name: "inverted"
                    PropertyChanges { target: glyph; rotation: 180 }
                }

                transitions: Transition {
                  RotationAnimation { duration: 50; direction: RotationAnimation.Clockwise }
                }

                Image {
                  id: imageItem
                  source: "../images/triangle3.png"
                  anchors.fill: parent
                }
            }
        }
        id:bckgrdCombo
//        Rectangle{
//            color:"white"
//            height:10
//            width:10
//        }
    }    
}
