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

#include "dropboxoperations.h"


DropBoxOperations::DropBoxOperations(QObject *parent) : QObject(parent){
//DropBoxOperations::DropBoxOperations() {
    currentFile="";
    state=false;
    done=false;
}

DropBoxOperations::~DropBoxOperations(){
}

/*!
 * \brief DropBoxOperations::setDropboxObject
 * \param calledDropbox
 */

void DropBoxOperations::setDropboxObject(QDropbox *calledDropbox) {
    dropbox = calledDropbox ;
}

/*!
 * \brief DropBoxOperations::synchronyze()
 * Interface for user login, files update
 */

int DropBoxOperations::synchronyze(){
    qint64 rc;
    QString cursor = "";
    bool hasMore = true;
    QDropboxFileInfoMap file_cache;    
    QMap<QString,QString> hashVersionDict ;
    QString fileRevision;
    QMap<QString,QString>::iterator hashIterator ;
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


    // Delete example.csv if exists
    if(QFile(documents + "/playlists/example.csv").exists())
        QFile(documents + "/playlists/example.csv").remove();

    currentFile = "" ;
    emit currentdownloadChanged();    
    do
    {
        currentFile = tr("\nRetrieving changes ...") ;
        emit currentdownloadChanged();        
        QDropboxDeltaResponse r = dropbox->requestDeltaAndWait(cursor, "");
        cursor = r.getNextCursor();
        hasMore = r.hasMore();

        const QDropboxDeltaEntryMap entries = r.getEntries();

        for(QDropboxDeltaEntryMap::const_iterator i = entries.begin(); i != entries.end(); i++)
        {
            if(i.value().isNull())
            {
                file_cache.remove(i.key());
            }
            else
            {
                file_cache.insert(convToUTF8(i.key()), i.value());
            }
        }

    } while (hasMore);

    // Dropbox to Local
    for(QDropboxFileInfoMap::const_iterator i = file_cache.begin(); i != file_cache.end(); i++)    {                

        if(i.value()->isDir()){
            // It's a directory
            if(!QDir( documents + QDir::separator()  + playListDir + QDir::separator()  + i.key().mid(1)).exists()){
                // Create local directory
                currentFile=currentFile + tr("\nCreate Dir") + i.key().mid(1) ;
                emit currentdownloadChanged();
                if(!QDir( documents + QDir::separator()  + playListDir).mkpath(i.key().mid(1))){                    
                    currentFile=currentFile + tr(" ... ERROR Create dir");
                    emit currentdownloadChanged();
                    return -2;
                }                
            }
        }
        else{
            // It's a file            
            if (QFile( documents + QDir::separator()  + playListDir + QDir::separator()  + i.key().mid(1)).exists()) {

                if(!hashVersionDict.contains(i.key().mid(1))){
                    fileRevision = "NEW";
                }
                else{
                    fileRevision=hashVersionDict[i.key().mid(1)];
                }

                // TEst si le fichier est nouveau ou pas
                if ( fileRevision != i.value()->revisionHash() && fileRevision != "LOCALYMODIFY")  {
                    hashVersionDict[i.key().mid(1)]=i.value()->revisionHash() ;
                    // Si la version du fichier est differente de NEW, on le met à jour.
                    // Si egale NEW cela veut dire que c'est soit une nouvelle install soit une ancienne version
                    if(fileRevision!="NEW"){
                        //Update existing file
                        currentFile=currentFile + "\n" + i.key() + " ... ";
                        emit currentdownloadChanged();
                        emit downloadanimChanged();
                        rc=getfile(i.key(),dropbox,"update");
                        if(rc < 0){
                            currentFile=QString::number(rc) + "KO" + currentFile ;
                            emit currentdownloadChanged();
                        }
                   }
                }
                else{
                    // If local file is newer, upload local version to dropbox
                    if(fileRevision=="LOCALYMODIFY"){
                        // Update only lyrics and setlits
                        if(i.key().indexOf("audio") == -1 && i.key().indexOf("chords") == -1) {
                            currentFile=currentFile + "\n->" + i.key() + " ... ";
                            emit currentdownloadChanged();
                            emit downloadanimChanged();
                            rc=putfile(i.key(),dropbox,&fileRevision,"update");
                            if(rc < 0){
                                currentFile=QString::number(rc) + "KO" + currentFile ;
                                emit currentdownloadChanged();
                                //return rc;
                            }
                            else{
                                currentFile=currentFile + "OK";
                                hashVersionDict[i.key().mid(1)]=fileRevision;
                            }
                        }
                    }
                }

            }
            else{
                // New file                
                hashVersionDict[i.key().mid(1)]=i.value()->revisionHash() ;
                currentFile=currentFile + "\n" + i.key() + " ... ";
                emit currentdownloadChanged();
                state=true;
                emit downloadanimChanged();
                rc=getfile(i.key(),dropbox,"new");
                state=false;
                emit downloadanimChanged();
                if(rc < 0){                    
                    currentFile=QString::number(rc) + "KO" + currentFile ;
                    emit currentdownloadChanged();                    
                }
                else {
                    currentFile=currentFile + "OK";
                    emit currentdownloadChanged();
                }
            }
        }
    }

    // Traite les nouveau fichier locaux
    for(hashIterator=hashVersionDict.begin();hashIterator!=hashVersionDict.end();hashIterator++){
        if(hashIterator.value() == "LOCALYMODIFY" ){
            if(hashIterator.key().indexOf("audio") == -1 && hashIterator.key().indexOf("chords") == -1) {
                currentFile=currentFile + "\n->" + hashIterator.key() + " ... ";
                emit currentdownloadChanged();
                emit downloadanimChanged();
                rc=putfile("/"+hashIterator.key(),dropbox,&fileRevision,"new");
                if(rc < 0){
                    currentFile=QString::number(rc) + "KO" + currentFile ;
                    emit currentdownloadChanged();
                }
                else{
                    hashVersionDict[hashIterator.key()]=fileRevision;
                }
            }
        }
    }

    //Ecriture de la nouvelle table des versions
    hashVersionTab.remove() ;
    hashVersionTab.open(QIODevice::ReadWrite | QIODevice::Text);

    QTextStream out(&hashVersionTab);
    for(hashIterator=hashVersionDict.begin();hashIterator!=hashVersionDict.end();hashIterator++){
        out << hashIterator.key() << ";" << hashIterator.value() << "\n";
    }

    hashVersionTab.close();

    currentFile=currentFile + tr("\nSynchro completed") ;
    emit currentdownloadChanged();
    done=true;
    emit downloaddoneChanged();
    return 0;
}

/*!
 * \brief DropBoxOperations::dropBoxGetfile
 * Download file from dropbox to local directory
 * If the local file allready exists, it is delete firs
 * \param filename to create/update
 * \param dropbox handler
 * \param action update : delete existing file, download new one from dropbox, else, new file
 * \return 0 if ok negative value else
 * TODO handle directories
 */
int DropBoxOperations::getfile(QString filename, QDropbox *dropbox, QString action){

    QByteArray utf8filename,writeBuffer;
    qint64 lentoread=512;
    int read;
    bool readloop=true;

    char *readBuffer = new char[lentoread];

    utf8filename.append(filename.toUtf8());

    QDropboxFile dbFile(dropBoxAccess + utf8filename,dropbox);

    if(action == "update"){
        //Delete existing file
        QFile targetFile( documents + QDir::separator() + playListDir + QDir::separator() + filename.mid(1));
        if(! targetFile.remove()){
            return -4;
        }
    }
    QFile targetFile( documents + QDir::separator() + playListDir + QDir::separator() + filename.mid(1));
    if(! targetFile.open(QIODevice::ReadWrite)){
        return -3 ;
    }


    if(dbFile.open(QIODevice::ReadOnly)){
        QDataStream readStream(&dbFile);
        while(readloop){
           read=readStream.readRawData(readBuffer,lentoread);
           if (read>0){
                writeBuffer=QByteArray(readBuffer,read);
                if(targetFile.write(writeBuffer)<0)
                    return -5;
            }
            else
                readloop=false;
        };

        dbFile.close();
        targetFile.close();
        delete readBuffer;
        return 0 ;
    }
    else{
        return -1 ;
    }
}

int DropBoxOperations::putfile(QString filename, QDropbox *dropbox, QString *revision,QString action="update"){

    QByteArray utf8filename,writeBuffer;
    qint64 lentoread=512;
    int read;
    bool readloop=true;

    char *readBuffer = new char[lentoread];

    utf8filename.append(filename.toUtf8());

    QDropboxFile dbFile(dropBoxAccess + utf8filename,dropbox);

    if(!dbFile.open(QIODevice::ReadWrite))
            return -3;

//    if(action == "update"){
//        //Reset existing file
//        dbFile.reset();
//    }

    QFile sourceFile( documents + QDir::separator() + playListDir + QDir::separator() + filename.mid(1));
    if(sourceFile.open(QIODevice::ReadOnly)){
        QDataStream readStream(&sourceFile);
        while(readloop){
           read=readStream.readRawData(readBuffer,lentoread);
           if (read>0){
                writeBuffer=QByteArray(readBuffer,read);
                if(dbFile.write(writeBuffer)<0)
                    return -5;
            }
            else
                readloop=false;
        };
        dbFile.flush() ;
        dbFile.close();        
        sourceFile.close();
        delete readBuffer;
        *revision = dbFile.metadata().revisionHash() ;
        return 0 ;
    }
    else{
        return -1 ;
    }
}

/*!
 * \brief DropBoxOperations::authorization complete authorization cycle when it is a new connection
 * \return
 */

int DropBoxOperations::authorization(){
    QFile tokenFile(tokens);
    if(!dropbox->requestAccessTokenAndWait())
    {
        int i = 0;
        for(;i<3; ++i) // we try three times
        {
            if(dropbox->error() != QDropbox::TokenExpired)
                break;
        }

       if(i>3)
       {
           //qDebug() <<  "too many tries for authentication";
           currentFile = "" ;
           emit currentdownloadChanged();
           return -2;
       }

        if(dropbox->error() != QDropbox::NoError)
        {
           //qDebug() << "Error: " << dropbox.error() << " - " << dropbox.errorString() << endl;
           currentFile = "" ;
           emit currentdownloadChanged();
           return -3;
        }
    }

    if(!tokenFile.open(QIODevice::WriteOnly|QIODevice::Truncate|QIODevice::Text)) {
        currentFile = "" ;
        emit currentdownloadChanged();
        return -5;
     }

    QTextStream outstream(&tokenFile);
    outstream << dropbox->token() << endl;
    outstream << dropbox->tokenSecret() << endl;
    tokenFile.close();
    currentFile = "" ;
    emit currentdownloadChanged();
    return 0;
}

/*!
 * \brief DropBoxOperations::connectDropbox
 * \param d
 * \param m
 * \param tokens
 * \return
 */

int DropBoxOperations::connect(){
    QFile tokenFile(tokens);

    currentFile = "" ;
    emit currentdownloadChanged();
    currentFile = tr("Connecting DopBox ...") ;
    emit currentdownloadChanged();

    if(tokenFile.exists()) // reuse old tokens
    {
        if(tokenFile.open(QIODevice::ReadOnly|QIODevice::Text))
        {
            QTextStream instream(&tokenFile);
            QString token = instream.readLine().trimmed();
            QString secret = instream.readLine().trimmed();
            if(!token.isEmpty() && !secret.isEmpty())
            {
                dropbox->setToken(token);
                dropbox->setTokenSecret(secret);
                tokenFile.close();
                currentFile = "" ;
                emit currentdownloadChanged();
                return 0;
            }
        }
        tokenFile.close();
        return -7;
    }

    // acquire new token
    if(!dropbox->requestTokenAndWait())
    {
        //qDebug() << "error on token request";
        currentFile = "" ;
        emit currentdownloadChanged();
        return -1;
    }

    dropbox->setAuthMethod(QDropbox::Plaintext);
    if(!dropbox->requestAccessTokenAndWait())
    {
        int i = 0;
        for(;i<3; ++i) // we try three times
        {
            if(dropbox->error() != QDropbox::TokenExpired)
                break;
            urlValidation=dropbox->authorizeLink().toString() ;
            //qDebug()<< "Authoriser application\n";
            currentFile = "" ;
            emit currentdownloadChanged();            
            return -4;
        }

       if(i>3)
       {
           //qDebug() <<  "too many tries for authentication";
           currentFile = "" ;
           emit currentdownloadChanged();
           return -2;
       }

        if(dropbox->error() != QDropbox::NoError)
        {
           //qDebug() << "Error: " << dropbox.error() << " - " << dropbox.errorString() << endl;
           currentFile = "" ;
           emit currentdownloadChanged();
           return -3;
        }
    }

//    if(!tokenFile.open(QIODevice::WriteOnly|QIODevice::Truncate|QIODevice::Text)) {
//        currentFile = "" ;
//        emit currentdownloadChanged();
//        return -5;
//     }

//    QTextStream outstream(&tokenFile);
//    outstream << dropbox->token() << endl;
//    outstream << dropbox->tokenSecret() << endl;
//    tokenFile.close();
//    currentFile = "" ;
//    emit currentdownloadChanged();
    return 0;
}

/*!
 * \brief DropBoxOperations::authorizeApplication
 * \param d
 */

void DropBoxOperations::authorize(QDropbox* d){

    //TODO Gérer ce cas proprement
    QTextStream strout(stdout);
    QTextStream strin(stdin);
    //qDebug() << " Authorisation URL: " << d->authorizeLink().toString() ;
    //QDesktopServices::openUrl(d->authorizeLink());
    //strout << "Press ENTER after you authorized the application!";
    strout.flush();
    //strin.readLine();
    //strout << endl;
    d->requestAccessTokenAndWait();
}

/*!
 * \brief DropBoxOperations::convToUTF8
 * parses the source string convert unicode escaped strings to real unicode char
 * example : \u00e5 will be converted to the unicode representation
 * This function is here to complete the behavior of the QDropbox Json handler
 * \param source
 * \return converted QString
 */

QString DropBoxOperations::convToUTF8(QString source){
    QByteArray buffer;
    QString cible;
    QString conv ;
    bool ok;

    buffer.append(source);

    for (int i=0;i<buffer.size();i++){
        if (buffer.at(i) == '\\'){
            if(buffer.at(i+1) == 'u' ){
                conv.append(buffer.at(i+2));
                conv.append(buffer.at(i+3));
                int H=conv.toInt(&ok,16);
                conv="";
                conv.append(buffer.at(i+4));
                conv.append(buffer.at(i+5));
                int L=conv.toInt(&ok,16);
                cible.append(QChar(L,H));
                i+=5;;
            }
            else
                cible.append(buffer.at(i));
        }
        else
            cible.append(buffer.at(i));
    }
    return cible;
}

QString DropBoxOperations::geturlvalidation(){
    return urlValidation ;
}

QString DropBoxOperations::currentdownload() const {
    return(currentFile);
}

bool DropBoxOperations::downloadanim() {
    return(state);
}

bool DropBoxOperations::downloaddone() {    
    return(done);
}

void DropBoxOperations::setdownloaddone(bool setdone) {
    done=setdone;
    emit downloaddoneChanged();
}
