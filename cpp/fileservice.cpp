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

#include "fileservice.h"

//QString homeDir;

/*!
 * \brief FileService::FileService
 * \param parent
 */

FileService::FileService(QObject *parent) : QObject(parent)
{

//    if(QSysInfo::productType() == "android")
//        homeDir="/sdcard" ;
//    else
//        homeDir=QDir::homePath();
}

FileService::~FileService()
{

}

/*!
 * \brief Gets the description of the tune
 * \param tune
 * \return a json object representing the csv line
 */

QJsonObject FileService::getTuneDesc(QStringList tune) {
    QJsonObject tuneDesc ;
    QString title ,audioFile , iconItem , lyricsFile, chordsFile, capo, comments, author, year;
    float duration;
    bool hasChords;
    bool fileExists=false;
    QString realfileName;

    // test if audio file exists

    if(tune[4]!="") {
        if(QFile(localAudiodir + "/" + tune[4]).exists()){
            fileExists=true;
            realfileName=tune[4];
        }
        if(QFile(localAudiodir + "/" + tune[4].toLower()).exists()){
            fileExists=true;
            realfileName=tune[4].toLower();
        }
        if(fileExists){
            audioFile = localAudiodir+ "/" + realfileName;
            title = tune[1];            
            iconItem="../images/Speaker_Icon.png";
        }
        else{
            audioFile="";
            title=tune[1];
            //iconItem="../images/Speaker_Icon_off.png";
            iconItem="../images/lyrics-128x128.png";
        }
    }
    else{
        audioFile="";
        title=tune[1];
        //iconItem="../images/Speaker_Icon_off.png";
        iconItem="../images/lyrics-128x128.png";
    }

    fileExists=false;
    // test if lyrics file exists
    if(tune[7]!=""){
        if(QFile(localLyricsdir + "/" + tune[7]).exists()){
            fileExists=true;
            realfileName=tune[7];
        }
        if(QFile(localLyricsdir + "/" + tune[7].toLower()).exists()){
            fileExists=true;
            realfileName=tune[7].toLower();
        }
        if(fileExists){
            lyricsFile = localLyricsdir+ "/" + realfileName;
        }
        else{
            lyricsFile = "";
        }
    }
    else{
        lyricsFile = "";
    }

    fileExists=false;

    // test if Chords file exists    
    if(tune[8]!=""){
        if(QFile(localChordsdir + "/"+tune[8]).exists()){
            fileExists=true;
            realfileName=tune[8];

        }
        if(QFile(localChordsdir + "/"+tune[8].toLower()).exists()){
            fileExists=true;
            realfileName=tune[8].toLower();
        }
        if(fileExists){
            chordsFile = localChordsdir+ "/" +realfileName;
        }
        else{
            chordsFile = "";
        }
    }
    else{
        chordsFile = "";
    }

    capo=tune[2];
    comments=tune[3];
    author=tune[5];
    year=tune[6];

    if (tune[9].split(',').count() > 1)
        duration=float(tune[9].split(',')[0].toInt()*60000 + tune[9].split(',')[1].toInt()*1000);
    else {
        if (tune[9].split(':').count() > 1)
            duration=float(tune[9].split(':')[0].toInt()*60000 + tune[9].split(':')[1].toInt()*1000);
        else
            duration=float(tune[9].toInt()*60000);
    }
    //set default duration to 3mn
    if(duration==0)
        duration=180000.0 ;

    hasChords=false;
    if (tune.count() > 10 )
        if (tune[10] != "" && tune[10] != NULL )
            hasChords = true ;

    tuneDesc.insert("title",title);
    tuneDesc.insert("iconItem",iconItem);
    tuneDesc.insert("audioFile",audioFile);
    tuneDesc.insert("lyricsFile",lyricsFile);
    tuneDesc.insert("chordsFile",chordsFile);
    tuneDesc.insert("capo",capo);
    tuneDesc.insert("comments",comments);
    tuneDesc.insert("author",author);
    tuneDesc.insert("year",year);
    tuneDesc.insert("duration",duration);
    tuneDesc.insert("hasChords",hasChords);


    return tuneDesc;
}

/*!
 * \brief Handle a csv line, the field separator is semicolon '';''
 * \param line
 * \param i
 * \return a list of fields
 */

QStringList FileService::csv(QString line,int i) {
    if (i>0){
        if (line.split(';').count() >= 8){
            return line.split(';') ;
        }
        else{
            return QStringList() << NULL;
        }
    }
    else
        return QStringList() << NULL;
}

/*!
 * \brief Reads the content of the playlist
 * \param playlistdir
 * \param theplaylist
 * \return a list of json structure [{"key":value},……]
 */

QVariantList FileService::loadPlayListService(QString playlistdir , QString theplaylist )  {

    FileService::localAudiodir=playlistdir + "/" + audiodir ;
    FileService::localLyricsdir=playlistdir + "/" + lyricsdir ;
    FileService::localChordsdir=playlistdir + "/" + chordsdir;

    QList<QJsonObject> dictTunes;
    QVariantList tuneDescList;

    int i;
    QString line;
    QStringList csvDecode;
    QJsonObject tuneDesc ;

    QFile file(playlistdir + "/" + theplaylist);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return QVariantList() << "Error Open File " << playlistdir << "/" << theplaylist ;

    QTextStream in(&file);
    i=0;

    while (!in.atEnd()) {
        line = in.readLine();
        csvDecode=csv(line,i);
        if(csvDecode.count() > 1) {
            tuneDesc = getTuneDesc(csvDecode) ;
            tuneDescList << tuneDesc;
        }
        i+=1;
    }
    return tuneDescList;
}

/*!
 * \brief Retreives all the csv files in the playlists directory
 *
 * \return The of all .csv files found
 */

QStringList FileService::getPlaylist()  {
    QStringList csvlist;
    QString listname;

    if (QDir(documents + "/" + playListDir).exists()) {
        csvlist = QDir(documents + "/" + playListDir).entryList(QStringList()<<"*"+listextension);
        for (int i = 0; i < csvlist.size(); ++i){
            listname=csvlist.at(i);
            csvlist.replace(i,listname.replace(listextension,""));
        }
        return csvlist;
    }

}

/*!
 * \brief Reads Lyrics file
 * \param filename
 * \return Qstring
 */

QString FileService::getContent(QString filename)  {

    if(QFileInfo(filename).exists()) {
        QFile file(filename);
        if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
            return "Error Open File";
        QTextStream  in( &file) ;
        return in.readAll();
    }
    else {
        return "File not found : " + filename ;
    }
}

/*!
 * \brief Returns a list of Dictionary, describing all the tunes in the file passed by the parameter
 * \param theplaylist
 * \return
 */

QVariantList FileService::loadPlaylist(QString theplaylist)  {
    return loadPlayListService(documents + "/" + playListDir,theplaylist+listextension) ;
}


bool FileService::isfileExists(QString filename) {
    return QFileInfo(filename).exists();
}

bool FileService::deleteFile(QString filename) {
    if(QFileInfo(filename).exists())
        return QFile::remove(filename);
    else {
        if(QFileInfo(documents + "/" + playListDir + "/" + filename).exists())
            return QFile::remove(documents + "/" + playListDir + "/" + filename);
        else
            return false;
   }
}

/*!
 * \brief Save the setlist data in csv format
 * \param filename to save in, JSON data structure to convert in csv
 * \return false/true
 */

bool FileService::saveCsvFile(QString filename,QJsonObject setListData) {
    QJsonObject::iterator i ;
    QStringList::iterator j;
    QList<int>::iterator k;
    QString duration,csvFilename;
    QFile csvfile(filename+".csv");
    QList<int> orderedlist;
    QStringList unorderedlist;
    bool rc;

    if (!csvfile.open(QIODevice::WriteOnly | QIODevice::Text))
            return false;

    QFileInfo fn(csvfile) ;
    csvFilename=fn.fileName() ;
    rc=updateHashVersion(csvFilename) ;

     QTextStream out(&csvfile);

     // Sorts Json data on numerical order (alpha order by default)
     unorderedlist = setListData.keys() ;
     for(j=unorderedlist.begin();j != unorderedlist.end();j++){
         orderedlist.append((*j).toInt()) ;
     }
    qSort(orderedlist.begin(), orderedlist.end());


    out << "order;title;capo;comments;audioFile;author;year;lyricsFile;chordsFile;duration\n" ;

    for(k=orderedlist.begin();k!=orderedlist.end();k++){
        out << QString::number((*k)+1) << ";"  ;
        out << setListData.value(QString::number(*k)).toObject().value("title").toString() <<  ";" ;
        out << setListData.value(QString::number(*k)).toObject().value("capo").toString() << ";" ;
        out << setListData.value(QString::number(*k)).toObject().value("comments").toString() << ";" ;
        out << setListData.value(QString::number(*k)).toObject().value("audioFile").toString().replace(documents+"/playlists/audio/","") << ";" ;
        out << setListData.value(QString::number(*k)).toObject().value("author").toString() << ";" ;
        out << setListData.value(QString::number(*k)).toObject().value("year").toString() << ";" ;
        out << setListData.value(QString::number(*k)).toObject().value("lyricsFile").toString().replace(documents+"/playlists/lyrics/","") << ";" ;
        out << setListData.value(QString::number(*k)).toObject().value("chordsFile").toString().replace(documents+"/playlists/chords/","") << ";" ;

        duration = QString::number(setListData.value(QString::number(*k)).toObject().value("duration").toInt()/60000);
        duration = duration + ":" + QString::number(setListData.value(QString::number(*k)).toObject().value("duration").toInt()%60000/1000);
        out << duration << "\n";
    }

    csvfile.close();

    return true;
}

/*!
 * \brief FileService::saveTxtFile
 * \param filename :Full qualified name of the file to save
 * \param tunename :Nome of the tune
 * \param lyricsText : Content of the file
 * \param setlistDir : Document directory
 * \return
 */
bool FileService::saveTxtFile(QString filename, QString tunename,QString lyricsText,QString setlistDir) {
    QString realfile, tuneFilename;
    bool rc;

    if(filename=="")
        realfile=setlistDir+"/lyrics/"+tunename + ".txt" ;
    else
        realfile=filename;

    QFileInfo fn(realfile) ;
    tuneFilename="lyrics/" + fn.fileName() ;
    rc=updateHashVersion(tuneFilename) ;

    QFile lyricsfile(realfile);
    if (!lyricsfile.open(QIODevice::WriteOnly | QIODevice::Text))
            return false;

    QTextStream out(&lyricsfile);
    out << lyricsText ;
    lyricsfile.close();
    return true;
}

/*!
 * \brief FileService::updateHashVersion
 * \param tuneFilename : Nom du fichier à controler
 * \return bool
 */
bool FileService::updateHashVersion(QString tuneFilename) {
    QMap<QString,QString> hashVersionDict ;
    QMap<QString,QString>::iterator hashIterator ;
    // Open local HashVersion file
    QFile hashVersionTab(documents + QDir::separator() + playListDir + QDir::separator()  + "hashVersionTab.dat") ;
    hashVersionTab.open(QIODevice::ReadWrite | QIODevice::Text);


    if(hashVersionTab.exists()){
        //Chargement du tableau des versions locale
        QTextStream in(&hashVersionTab);
        while (!in.atEnd()) {
            QString line = in.readLine();
            hashVersionDict[line.split(";")[0]]=line.split(";")[1];
        }
    }
    hashVersionTab.close();

    hashIterator = hashVersionDict.find(tuneFilename);
    if(hashIterator==hashVersionDict.end()) {
        // Nouveau fichier
        hashVersionDict.insert(tuneFilename,"LOCALYMODIFY") ;
    }
    else {
        while (hashIterator != hashVersionDict.end() && hashIterator.key() == tuneFilename) {
            hashVersionDict[tuneFilename] = "LOCALYMODIFY" ;
            ++hashIterator;
        }
    }

    //Ecriture de la nouvelle table des versions
    hashVersionTab.remove() ;
    hashVersionTab.open(QIODevice::ReadWrite | QIODevice::Text);

    QTextStream outHash(&hashVersionTab);
    for(hashIterator=hashVersionDict.begin();hashIterator!=hashVersionDict.end();hashIterator++){
        outHash << hashIterator.key() << ";" << hashIterator.value() << "\n";
    }

    hashVersionTab.close();
    return true ;
}
