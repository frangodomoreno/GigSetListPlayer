#ifndef PLAYLIST_H
#define PLAYLIST_H

#include <QObject>
#include <QVariant>
#include <QTextStream>
#include <QFile>
#include <QDebug>
#include <QStringList>

class Playlist : public QObject
{
    Q_OBJECT

private:
    QStringList csv(QString line,int i) {
        if (i>0){
            if (line.split(';').count() >= 8)
                return line.split(';') ;
                // TODO Iplementer logique python

            else
                return QStringList(0);
        }
        else
            return QStringList(0);
    }

public:
    explicit Playlist(QObject *parent = 0);
    ~Playlist();

    QVariant loadPlayList(QString playlistdir = NULL , QString theplaylist = NULL)  {

        QString mp3dir=playlistdir + "/audio" ;
        QString lyricsdir=playlistdir + "/paroles" ;
        QString chordsdir=playlistdir + "/grilles" ;
        QVariant dictTunes;
        int i;
        QString line;
        QStringList csvDecode;

        qDebug() << "COUCOU1" ;

        QFile file(playlistdir + "/" + theplaylist);
        if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
            return QVariant("Error Open File " + playlistdir + "/" + theplaylist) ;

        QTextStream in(&file);
        i=0;

        while (!in.atEnd()) {
            line = in.readLine();
            csvDecode=csv(line,i);
            if(csvDecode.count() > 1)
                qDebug() << "Line csv" << csvDecode[1] ;
            i+=1;
        }

        qDebug() << "COUCOU" ;
        return QVariant(0) ;
    }

signals:

public slots:
};

#endif // PLAYLIST_H
