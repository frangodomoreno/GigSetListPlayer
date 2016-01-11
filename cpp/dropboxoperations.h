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
#ifndef DROPBOXOPERATIONS_H
#define DROPBOXOPERATIONS_H

#include <QObject>
#include <QDir>
#include <QStandardPaths>
//#include <QSharedPointer>
#include <QDebug>
#include <QDesktopServices>
#include <QDataStream>

#include "global.h"
#include "keys.h"
#include "dropbox/qdropbox.h"
#include "dropbox/qdropboxfile.h"


class DropBoxOperations : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString currentdownload READ currentdownload NOTIFY currentdownloadChanged)
    Q_PROPERTY(bool downloadanim READ downloadanim NOTIFY downloadanimChanged)
    Q_PROPERTY(bool downloaddone READ downloaddone WRITE setdownloaddone NOTIFY downloaddoneChanged)

private:    
    QString urlValidation ;
    QString currentFile ;
    bool state;
    bool done;
    int getfile(QString filename, QDropbox *dropbox, QString action);
    int putfile(QString filename, QDropbox *dropbox, QString * , QString);
    void authorize(QDropbox* d);
    QString convToUTF8(QString source);
    QString currentdownload() const;
    bool downloadanim() ;
    bool downloaddone();
    void setdownloaddone(bool setdone);
    typedef QMap<QString, QSharedPointer<QDropboxFileInfo> > QDropboxFileInfoMap;
    QDropbox *dropbox;
    //const QString tokens=":/tokens";
    const QString tokens=documents+"/playlists/tokens";


public:    
    explicit DropBoxOperations(QObject *parent = 0 );
    //explicit DropBoxOperations();
    ~DropBoxOperations();
    void setDropboxObject(QDropbox *calledDropbox) ;
    Q_INVOKABLE int synchronyze();
    Q_INVOKABLE int connect();
    Q_INVOKABLE int authorization();
    Q_INVOKABLE QString geturlvalidation();

signals:
    void currentdownloadChanged();
    void downloadanimChanged();
    void downloaddoneChanged();

public slots:
};

#endif // DROPBOXOPERATIONS_H
