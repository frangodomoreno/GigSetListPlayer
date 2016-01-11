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

#ifndef PDFVISU_H
#define PDFVISU_H

//#include <UIKit/UIKit.h>
#include <QQuickItem>

class PDFVisu : public QQuickItem
{
    Q_OBJECT
    Q_PROPERTY(QString  source READ getPdfFile WRITE setPdfFile NOTIFY sourceChanged)
    Q_PROPERTY(bool visible READ getVisible WRITE setVisible NOTIFY visibleChanged)

public:
    bool visible;
    explicit PDFVisu(QQuickItem *parent = 0);
    ~PDFVisu() ;

public slots:

signals:
    void sourceChanged();
    void visibleChanged();

private:
    void *mydelegate;
    QString getPdfFile()  ;
    void setPdfFile(QString pdfFile);
    bool getVisible() ;
    void setVisible(bool) ;
    void showHide(bool);
    QString source;
    void bind() ;

};

#endif // PDFVISU_H
