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

/*================================
  FUNCTIONS
================================*/

/***************************************
  Main function called by the C++ side
***************************************/
function fmain(){    
    // If more than one screen, sreenH and screenW are valued by main.cpp
    //console.log(">>>",deviceType)

    if(screenH>0)
        root.height=screenH
    if(screenW>0)
        root.width=screenW

    var listPlayList
    //var listTune

    Db.init()

    // Test if keyboard is visible, if true, this mean that Remote Constrol is enabled but no external device is pluged , the we hide the soft keyboard

    //console.log(Screen.orientation,Qt.PortraitOrientation)
    listPlayList=fileService.getPlaylist()

     if(listPlayList == "" ) {
         messageDialog.setText(qsTr(" WARNING  \n No Playlist file found. Edit a new one with the grid button below"))
         messageDialog.visible=true
     }

    else if(listPlayList.length > 1 && !liteMode) {
         chooserContainer.chooserModel=listPlayList
         chooserContainer.visible=true
         controlPop.enabled=false
         swipeZone.enabled=false
    }
    else{
        //listTune=fileService.loadPlaylist(listPlayList[0])
         root.currentPlaylist=listPlayList[0]
         playlistName.text = listPlayList[0]
         root.listTune=fileService.loadPlaylist(listPlayList[0])

         //Signal there is a list to load
         root.loadTuneList=!root.loadTuneList
         controlPop.enabled=true
         swipeZone.enabled=true
    }    
}

/********************************
  Next Tune Function
  Called when a new tune is selected or when the previous tune end
*********************************/
function nextTune(title,index,audioFile,duration,lyricsFile,chordsFile){

    if(root.pdfDisplay!=undefined){        
        root.pdfDisplay.visible=false
        //root.pdfDisplay.destroy()
    }
    root.pdfDisplay=undefined
    lyricsSave.visible=false
    root.butPlay.enabled = true

    root.curentTuneTitleHandle.text = title

    root.lyricsEdition = false
    root.plain=""
    var bpm,signature,h,l,textFontSize,linescount

    signature=0
    tempo=0

    // Lecture du tempo et signature dans la colonne Comments
    if(root.tuneModel.get(index).comments.toLowerCase().search("bpm")>=0){
        bpm=root.tuneModel.get(index).comments.toLowerCase().split("bpm")[0].split(" ")
        bpm.pop()
        bpm=bpm.pop()
        if(bpm > 0 && bpm < 250 )
            tempo=bpm
        else
            tempo=0
    }
    if(tempo > 0){
        if(root.tuneModel.get(index).comments.search("/")>=0){
            h=root.tuneModel.get(index).comments.split("/")[0]
            l=root.tuneModel.get(index).comments.split("/")[1]
            h=h.split(" ")
            h=h.pop()
            l=l.split(" ")[0]
            signature=(h*10) + (l*1)
            switch(signature){
                case 44 :
                case 34 :
                case 68 :
                    root.signature=signature
                    break;
                default:
                    root.signature=44;
                    break;
            }
        }
        else
            root.signature=44
    }

    if(audioFile!=undefined && audioFile!=""){
        //mousePlay.enabled=true
        root.audioFile=audioFile
        root.audioDuration=duration
        //imagePlay.opacity=0.8
        audioPlayer.source= audioFile.substring(0,1) == "/" ? "file://"+audioFile : "file:///"+audioFile
    }
    else{
        //mousePlay.enabled=false
        root.audioFile=""
        //imagePlay.opacity=0.1
    }

    root.currentLyricsFile = lyricsFile

    if(lyricsFile!=undefined && lyricsFile!=""){
        if(lyricsFile.split(".").pop().toLowerCase() === "pdf"){
            if(Qt.platform.os === "ios"){
                if(root.pdfDisplay===undefined)
                    DynamicObjCreator.createObjects("../qml/PdfViewCreate.qml",root.contenairWebLyricsDisplay)
                    root.pdfDisplay.source = lyricsFile
                    root.pdfDisplay.visible = false
                    root.pdfDisplay.isChord=false
                    root.contenairWebLyricsDisplay.visible = true
                    root.currentLyrics = "pdf"
            }
            else {
                if(Qt.platform.os === "osx"){
                    DynamicObjCreator.createObjects("../qml/WebViewCreate.qml",root.contenairWebLyricsDisplay)
                    root.pdfDisplay.url = "file://"+lyricsFile
                    root.pdfDisplay.visible = false
                    root.contenairWebLyricsDisplay.visible = true
                }
                else {//Android
                    DynamicObjCreator.createObjects("../qml/AndPdfViewer.qml",root.contenairWebLyricsDisplay)
                    root.pdfDisplay.source = lyricsFile
                    root.pdfDisplay.visible = false
                    root.pdfDisplay.isChord=false
                    root.contenairWebLyricsDisplay.visible = true
                    root.currentLyrics = "pdf"
                    if(audioFile===undefined || audioFile==="")
                        root.butPlay.enabled = false
               }
           }
        }
        else {            
            root.contenairWebLyricsDisplay.visible = false
            readAutomation(title)
            root.lyricsTextY=0
            root.currentLyrics = ""
            root.currentLyrics = fileService.getContent(lyricsFile)

            //20151025 Calcul du nombre de lignes dans le texte (Bug en mode Rich Text)

            linescount=root.currentLyrics.split('\n').length
            if(linescount == 1) {
                // Windows style
                linescount=root.currentLyrics.split('\r\n').length
                if(linescount == 1) {
                    // Mac style
                    linescount=root.currentLyrics.split('\r').length
                }
            }

            root.lyricsLineCount=linescount

            textFontSize=Db.loadFontSize(title,playlistName.text)
            if(textFontSize!=0)
                root.textFontSize=textFontSize
            else
                root.textFontSize=root.defaultTextFontSize
        }
    }
    else{
        root.contenairWebLyricsDisplay.visible = false
        root.currentLyrics = ""
    }

    root.lyricsModified = false
    root.currentChords = ""

    if(chordsFile!=undefined && chordsFile!=""){
        if(fileService.isfileExists(chordsFile))
            //root.currentChords = "file://" + chordsFile
            root.currentChords =  chordsFile
    }

}

/***********************
  Apply Automation on scrolling
***********************/
function scrollAutomation(){
    if(timerLYRIC.idxAutom < timerLYRIC.tabAutom.length) {
        var position
        if(audioFile!=""){ //Audio file exists
            position=audioPlayer.position
        }
        else{
            var d = new Date()
            position=d.getTime() - lyricsPlayer.startTime
        }

        if(position >= timerLYRIC.tabAutom[timerLYRIC.idxAutom].position){            
            if(timerLYRIC.tabAutom[timerLYRIC.idxAutom].slower==1){
                root.scrollCoef-=(root.scrollCoef*timerLYRIC.tabAutom[timerLYRIC.idxAutom].scrollvariation)
            }
            else{
                root.scrollCoef+=(root.scrollCoef*timerLYRIC.tabAutom[timerLYRIC.idxAutom].scrollvariation)
            }
            timerLYRIC.idxAutom+=1
        }
    }
}

/***********************
  Record scrolling
***********************/
function scrollRecord(){
    if(scrollSpeedCtl.pressed){
        if(inputFake.scrollReleased && inputFake.enabled)
            scrollSpeedCtl.pressed=false        
        var d = new Date()
        var position

        if(root.audioFile == "")
            position=d.getTime() - root.lyricsStartTime
        else
            position=root.audioPosition

        if(scrollSpeedCtl.slower)
           root.scrollCoef-=(root.scrollCoef*root.scrollVariation)
        else
           root.scrollCoef+=(root.scrollCoef*root.scrollVariation)           

        PlTools.writeAutomation(root.currentTuneTitle,position,scrollSpeedCtl.slower?1:0,root.scrollVariation)
    }

}

/********************************
  Lyrics scroller Function
*********************************/
function lyricsScroller(){
    var heightInPixels
    var scrollUnit

    // If PageMode is true return, no scrolling, but page change through remote control
    if(root.pageMode || root.currentLyrics === "pdf")
        return

    //heightInPixels=lyricsTab.lyricText.lineCount* ( lyricsTab.lyricText.lineHeight + textFontSize )
    heightInPixels=root.lyricsLineCount * textFontSize


//    if (timerLYRIC.scrollUnit==0){
//        console.log(">>> textFontSize "+textFontSize)
//        console.log('Total Tune Height in pixels >>>',heightInPixels)
//        console.log('Vunit >>>',root.vunit,'Hunit',root.hunit)
//        console.log('scroll unit ',(heightInPixels/root.audioDuration)*scrollTimeUnit,',duration ',root.audioDuration,',scroll time unit',scrollTimeUnit,'Line Height',root.lyricsHeight,"Gap",timerLYRIC.scrollGap)
//    }

    if(root.automationFlag)
        scrollAutomation()

    if(root.automationRecord)
        scrollRecord()

    timerLYRIC.scrollUnit=((heightInPixels/root.audioDuration)*scrollTimeUnit)*root.scrollCoef

    if (timerLYRIC.scrollGap >0){
        //lyricsTab.hightliner.y+=timerLYRIC.scrollUnit
        root.lyricsScrollGapY+=timerLYRIC.scrollUnit
        timerLYRIC.scrollGap-=timerLYRIC.scrollUnit
    }
    else{
        //lyricsTab.lyricText.y-=timerLYRIC.scrollUnit
        root.lyricsTextY-=timerLYRIC.scrollUnit
    }
}

/********************************
  End tune playing action
*********************************/
function endTuneAction(){
    //Redraw buttons
    stopResetAction()

    //Test if stop button has been pressed, if not, it's an end of tune
    if(!audioPlayer.manualStop || !lyricsPlayer.manualStop){
        //jump to next tune in the list
        signature=0
        tempo=0
        root.listViewHandler.incrementCurrentIndex()

        //Set the next tune data
        nextTune(root.tuneModel.get(root.listViewHandler.currentIndex)['title'],
                 root.listViewHandler.currentIndex,
                 root.tuneModel.get(root.listViewHandler.currentIndex)['audioFile'],
                 root.tuneModel.get(root.listViewHandler.currentIndex)['duration'],
                 root.tuneModel.get(root.listViewHandler.currentIndex)['lyricsFile'],
                 root.tuneModel.get(root.listViewHandler.currentIndex)['chordsFile'])

        // Load the lyrics and chords if any        
        root.currentLyrics=fileService.getContent(root.tuneModel.get(root.listViewHandler.currentIndex)['lyricsFile'])
        root.lyricsTextY=0
        root.lyricsScrollGapY=0        
   }
   else
        audioPlayer.manualStop=false
        lyricsPlayer.manualStop=false        
}

/********************************
  Start / Stop Function
*********************************/
function startStopButon(){
    if (!butPlay.isplaying) {        
        if(root.audioFile == "" && root.currentLyrics=="")
            return

        modalMode("enabled")
        inputFake.focus = remoteEnabled && remotePluged
        controlPop.enabled=true
        swipeZone.enabled=true
        butPlay.isplaying=true
        controlAutomation.enabled=true
        imagePlay.source="../images/stop_button.png"

        if(root.currentLyrics!=""){
            readAutomation(root.curentTuneTitleHandle.text)
            timerLYRIC.scrollGap=(root.lyricsHeight/2 ) - root.textFontSize * 2
        }
        if(tempo>0 && signature > 0)
            playCountDown(tempo,signature)

        if (root.audioFile != "" ){            
            root.audioDuration=audioPlayer.duration
            audioPlayer.play()
        }

        //If lyrics, start scrolling
        if(root.currentLyrics!=""){            
            if(root.audioFile == "" ){
                var d = new Date()
                lyricsPlayer.interval=root.audioDuration
                lyricsPlayer.startTime=d.getTime()
                lyricsPlayer.start()
                timerLYRIC.start()
                root.audioPlaying=true
            }            
        }        
        playerIndicator.visible=true
        toolsControl.enabled=false
    }
    else if (butPlay.isplaying) {
        audioPlayer.manualStop=true
        lyricsPlayer.manualStop=true
        if(root.automationRecord)
            root.automationFlag=true
        stopResetAction()
        audioPlayer.stop()
    }

}

function modalMode(action){
    if(action==='enabled'){
            root.llEnabled=false
            toolsControl.enabled=false
            csveditor.enabled=false
            csvswitch.enabled=false
            fontsizeLess.enabled=false
            fontsizedef.enabled=false
            fontsizeMore.enabled=false
            controlPop.enabled=false
            swipeZone.enabled=false
            controlAutomation.enabled=false
            lyricsSave.enabled=false
            lyricsEdit.enabled=false
            scrollOrPageMode.enabled=false
            inappRemote.enabled=false
            remoteActivatio.enabled=false
            }
        else{
            root.llEnabled=true
            toolsControl.enabled=true
            csveditor.enabled=true
            csvswitch.enabled=true
            fontsizeLess.enabled=true
            fontsizedef.enabled=true
            fontsizeMore.enabled=true
            controlPop.enabled=true
            swipeZone.enabled=true
            controlAutomation.enabled=true
            lyricsSave.enabled=true
            lyricsEdit.enabled=true
            scrollOrPageMode.enabled=true
            inappRemote.enabled=true
            remoteActivatio.enabled=true
        }
}

function stopResetAction(){
    modalMode('disabled')
    root.scrollCoef=1
    timerLYRIC.stop()
    timerLYRIC.scrollGap=0
    timerLYRIC.scrollUnit=0    
    lyricsPlayer.stop()
    butPlay.isplaying=false
    imagePlay.source="../images/play_button.png"   
    root.lyricsTextY=0
    root.lyricsScrollGapY=0    
    root.automationRecord=false
    root.audioPlaying=false
    playerIndicator.visible=false
    toolsControl.enabled=true    
    inputFake.focus = false
    root.controlPop.color=root.defaultBackGroundColour
}

function setPointSize(coef){
    var size;
    size=root.hwratio > 1 ? root.hunit*coef: root.vunit*coef ;
    size = size  <= 0 ? 1 : size ;
    return size ;
}


/*********************************
  Function for adding a new tune in the list
*********************************/
function addTune(dictData)
{
    tuneModel.append({
                 "title":dictData["title"],
                 "iconItem":dictData["iconItem"],
                 "audioFile":dictData["audioFile"],
                 "lyricsFile":dictData["lyricsFile"],
                 "chordsFile":dictData["chordsFile"],
                 "capo":dictData["capo"],
                 "comments":dictData["comments"],
                 "author":dictData["author"],
                 "year":dictData["year"],
                 "duration":dictData["duration"],
                 "hasChords":dictData["hasChords"]
              }
    )
}

/***********************************
  Load Automation data for the  tune
***********************************/
function readAutomation(tuneTitle) {    
    var records = Db.getRecords(tuneTitle)    
    if(records.length > 0){
        root.automationFlag=true
        timerLYRIC.tabAutom = records
        timerLYRIC.idxAutom = 0
    }
    else
        root.automationFlag=false
  }

/***********************************
  Write Automation data for the  tune
***********************************/
function writeAutomation(tuneTitle,position,slower,scrollvariation) {
    //console.log(">>> Write Automation for ",tuneTitle,position,slower)
    var records = Db.insertRecord(tuneTitle,position,slower,scrollvariation)
  }

/***********************************
  Clear Automation data for the tune
***********************************/
function clearAutomation(tuneTitle) {
    //console.log(">>> Write Automation for ",tuneTitle,position,slower)
    var records = Db.removeRecord(tuneTitle)
    root.automationFlag=false
    timerLYRIC.tabAutom = []
  }

/**********************************
  Animation Tool Boxes
**********************************/
function controlHideShow(controlId,yBegin,yEnd,xBegin,xEnd,animxId,animyId){

    if (controlId.showhide) { // Hide
        //Y
        animyId.begin = yBegin //menuId.height
        animyId.end = yEnd //-controlId.height
        //X
        animxId.begin = xBegin //animoffset - controlId.width
        animxId.end =  xEnd //rootId.width
        controlId.visible=false
    }
    else{ // Show
        //Y
        controlId.visible=true
        animyId.begin = yEnd //-controlId.height
        animyId.end = yBegin //menuId.height

        //X
        animxId.begin =  xEnd //rootId.width
        animxId.end = xBegin //animoffset - controlId.width

    }
    controlId.showhide=!controlId.showhide

    animyId.restart()
    animxId.restart()
    //controlId.visible=true
}

/**********************************
  Save current list un current csv or new csv file
**********************************/
function reloadListTune(){
    root.listTune=[]
    var i
    for(i=0;i<root.tuneModel.count;i++){        
        root.listTune.push(root.tuneModel.get(i))        
    }    
}

/**********************************
  Renumber the list
**********************************/
function renumListTune(listModel,oldNum,newNum,deleteAction){
    var i
    if(newNum < 0 || newNum >= listModel.count || isNaN(newNum))
        return

    if (!deleteAction){
        if (oldNum === newNum){
            for(i=oldNum;i<listModel.count;i++){
                listModel.setProperty(i,"order",i+1)
            }
        }
        if (oldNum > newNum) {
            listModel.move(oldNum,newNum,1)
            for(i=0;i<listModel.count;i++){
                listModel.setProperty(i,"order",i+1)
            }
        }
        else {
            listModel.move(oldNum,newNum,1)
            listModel.setProperty(newNum,"order",newNum+1)
            for(i=0;i<newNum;i++){
                listModel.setProperty(i,"order",i+1)
            }
        }
    }
    else{        
        for(i=oldNum;i<listModel.count;i++){            
            listModel.setProperty(i,"order",i+1)
        }
    }
}

/***********************************
  Key Handler if Remote command enabled
*************************************/
function keyHandler(key){
    //console.log("functionsJs:keyHandler",key)
//    if(!remoteEnabled)
//        return
    if(root.currentPane==1 && butPlay.isplaying){        
        if (key == lessKey) {
            if(root.automationRecord) { // For automation record func
                scrollSpeedCtl.pressed=true
                scrollSpeedCtl.slower=true
            }
            else{  // Live control
                if(!root.pageMode)
                    root.scrollCoef-=(root.scrollCoef*root.scrollVariation)
                else{
                    if(root.lyricsTextY+lyricsHeight > 0)
                        root.lyricsTextY=0
                    else
                        //root.lyricsTextY+=lyricsHeight*.85
                        root.lyricsTextY+=lyricsHeight
                }
           }
        }        
        if (key == moreKey) {
            if(root.automationRecord) { // For automation record func
                scrollSpeedCtl.pressed=true
                scrollSpeedCtl.slower=false
            }
            else // Live control
                if(!root.pageMode)
                    root.scrollCoef+=(root.scrollCoef*root.scrollVariation)
                else{
                    //root.lyricsTextY-=lyricsHeight*.85
                    //console.log("functions keyHandler",lyricsLineCount,textFontSize,lyricsLineCount*textFontSize,root.lyricsTextY-lyricsHeight)
                    if(lyricsLineCount*textFontSize>-(root.lyricsTextY-lyricsHeight)){
                        root.lyricsTextY-=lyricsHeight
                    }
                    else{
                        root.lyricsTextY= -(lyricsLineCount*textFontSize)
                    }
                }
        }
    }
    if(root.chordsDisplay.visible && root.imageChordsDisplay.visible){
        if (key == lessKey) {
            if(imageChordsDisplay.y+flickContenair.height > 0)
                imageChordsDisplay.y=0
            else
                imageChordsDisplay.y+=flickContenair.height

        }
        if (key == moreKey) {
            if(-(imageChordsDisplay.y-flickContenair.height) < imageChordsDisplay.height)
                imageChordsDisplay.y+=-flickContenair.height
        }
    }
}

/***********************************
  CountDown metronome
*************************************/
function playCountDown(bpm,signature){
    var interval ;
    var i,j
    switch(signature){
        case 44:
        case 22:
        default:
            interval=(60000/bpm)*2            
            metronome1.play()
            sleep(interval)
            metronome2.play()
            sleep(interval)
            interval/=2
            metronome1.stop()
            metronome1.play()
            sleep(interval)
            metronome2.stop()
            metronome2.play()
            sleep(interval)            
            metronome3.play()
            sleep(interval)
            metronome4.play()
            sleep(interval)

            break;
        case 68:
        case 34:
            interval=60000/bpm
            for(i=1;i<3;i++){
                metronome1.stop()
                metronome1.play()
                sleep(interval)
                metronome2.stop()
                metronome2.play()
                sleep(interval)
                metronome3.stop()
                metronome3.play()
                sleep(interval)
            }
            break;
    }
    return
}

/***************************
  Sleep function
*****************************/
function sleep(ms){
    var now = new Date()
    var exitTime = now.getTime()+ms
    while(true){
        now = new Date()
        if(now.getTime()>exitTime)
            return
    }
}

/***************************
  Switch Playlist
*****************************/
function switchPlayLIst(){
    var listPlayList
    listPlayList=fileService.getPlaylist()

     if(listPlayList == "" ) {
         messageDialog.setText(qsTr(" WARNING  \n Playlist file not found (no csv file), Try Synchronization..."))
         messageDialog.visible=true
     }

    else if(listPlayList.length > 1 && !liteMode) {
         chooserContainer.chooserModel=listPlayList
         chooserContainer.visible=true
         controlPop.enabled=false
         swipeZone.enabled=false
    }
}

/*********************************
  Function called when a line has been clicked in the list
*********************************/
function tuneClicked(title,index,audioFile,duration,lyricsFile,chordsFile,hasChords){
    // Set then current tune display
    root.curentTuneTitleHandle=root.tunetext
    // Set to current position
    root.currentTuneTitle = title
    listView.currentIndex = index

    //console.log(duration)

    root.audioDuration=duration
    root.listViewHandler=root.listView
    //root.tuneModel = tuneModel
    root.hasChords=hasChords
    PlTools.nextTune(title,index,audioFile,duration,lyricsFile,chordsFile)
}
