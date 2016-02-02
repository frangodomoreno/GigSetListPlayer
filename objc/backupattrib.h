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

#ifndef BACKUPATTRIB_H
#define BACKUPATTRIB_H

#include <QObject>

class backupAttrib : public QObject
{
    Q_OBJECT
private:

public:
    explicit backupAttrib(QObject *parent = 0);
    ~backupAttrib();
    Q_INVOKABLE bool setAttribExclude(QString);

signals:

public slots:

private:
    void *m_delegate;

};

#endif // BACKUPATTRIB_H
