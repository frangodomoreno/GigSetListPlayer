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

#ifndef INTERNETSERVICES_H
#define INTERNETSERVICES_H

#include <QDesktopServices>
#include <QUrl>
#include <QObject>
#include "global.h"

class InternetServices : public QObject
{
    Q_OBJECT

public:
    explicit InternetServices(QObject *parent = 0 );
    ~InternetServices();
    Q_INVOKABLE bool openLink(QString link);
signals:

public slots:

};

#endif // INTERNETSERVICES_H
