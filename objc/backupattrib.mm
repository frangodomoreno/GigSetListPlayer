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
