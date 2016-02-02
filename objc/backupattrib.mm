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

#include <UIKit/UIKit.h>
#include "backupattrib.h"
#include <QtGui/qpa/qplatformnativeinterface.h>
#include <QDebug>

@interface AttribChange : NSObject
{
    backupAttrib *m_bckattrib;
}


@end

@implementation AttribChange

- (id) initWithbackupAttrib:(backupAttrib *)bckattrib
{
    self = [super init];
    if (self) {
        m_bckattrib = bckattrib;
    }
    return self;
}

@end

backupAttrib::backupAttrib(QObject *parent) :
    QObject(parent) , m_delegate([[AttribChange alloc] initWithbackupAttrib:this])
{

}

backupAttrib::~backupAttrib()
{

}

bool backupAttrib::setAttribExclude(QString filename)
{    
    NSError *error = nil;
    NSString *path = [NSString stringWithUTF8String:filename.toUtf8().data()] ;
    NSURL* URL= [NSURL fileURLWithPath: path];
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
//    if(!success)
//        qDebug()<<"error "<<error ;
    return success ;
}
