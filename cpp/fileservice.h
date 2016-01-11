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

#ifndef FILESERVICE_H
#define FILESERVICE_H

#include <QObject>
#include <QDir>
#include <QTextStream>
#include "global.h"
#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonArray>
#include <QStandardPaths>
#include <QDebug>
#include <QList>

class FileService : public QObject
{
    Q_OBJECT
private:
    // CLass Vars
    QString localAudiodir;
    QString localLyricsdir;
    QString localChordsdir;

    /*!
     * \brief getTuneDesc
     * \param tune
     * \return
     */

    QJsonObject getTuneDesc(QStringList tune) ;

    /*!
     * \brief csv
     * \param line
     * \param i
     * \return
     */

    QStringList csv(QString line,int i) ;

    /*!
     * \brief loadPlayListService
     * \param playlistdir
     * \param theplaylist
     * \return
     */

    QVariantList loadPlayListService(QString playlistdir = NULL , QString theplaylist = NULL) ;
    bool updateHashVersion(QString);

public:

    explicit FileService(QObject *parent = 0);

    ~FileService();

    Q_INVOKABLE QStringList getPlaylist();

    Q_INVOKABLE QString getContent(QString filename)  ;

    Q_INVOKABLE QVariantList loadPlaylist(QString theplaylist)  ;

    Q_INVOKABLE bool isfileExists(QString filename)  ;

    Q_INVOKABLE bool deleteFile(QString filename) ;

    Q_INVOKABLE bool saveCsvFile(QString filename, QJsonObject setListData) ;

    Q_INVOKABLE bool saveTxtFile(QString filename, QString tunename , QString lyricsText,QString setlistDir) ;

signals:

public slots:
};

#endif // FILESERVICE_H
