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
#include <QtGui/qpa/qplatformnativeinterface.h>
#include <QtGui>
#include <QtQuick>
#include <QStandardPaths>
#include "pdfvisu.h"
#include "ReaderDocument.h"
#include "ReaderViewController.h"


@interface PdfVisuDelegate : NSObject <ReaderViewControllerDelegate> {
    PDFVisu *m_pdfHandler;
    UIView *mainView;
    UIViewController *qtController;
    ReaderViewController *readerViewController ;
}

-(UIView *) mainView; // getter
-(void) setMainView: (UIView *) newVal; // setter

-(UIViewController *) qtController; // getter
-(void) setQtController: (UIViewController *) newVal; // setter

-(ReaderViewController *) readerViewController; // getter
-(void) setReaderViewController: (ReaderViewController *) newVal; // setter

@end


@implementation PdfVisuDelegate

- (id) initWithPDFHandler:(PDFVisu *)pdfHandler
{
    self = [super init];
    if (self) {
        m_pdfHandler = pdfHandler;
    }
    mainView=nil;
    qtController=nil;
    return self;
}


- (void)dismissReaderViewController:(ReaderViewController *)readerViewController
{
    [readerViewController dismissViewControllerAnimated:YES completion:nil];
    m_pdfHandler->visible=false;
    emit m_pdfHandler->visibleChanged();
}

-(UIView *) mainView {
  /* ce getter se contente de retourner la valeur de maVariable */
  return mainView;
}
-(void) setMainView:(UIView *)newVal {
  /* ce setter se contente d'affecter la valeur de maVariable à la valeur demandée */
  mainView = newVal;
}

-(UIViewController *) qtController {
  /* ce getter se contente de retourner la valeur de maVariable */
  return qtController;
}
-(void) setQtController:(UIViewController *)newVal {
  /* ce setter se contente d'affecter la valeur de maVariable à la valeur demandée */
  qtController = newVal;
}

-(ReaderViewController *) readerViewController {
  /* ce getter se contente de retourner la valeur de maVariable */
  return readerViewController;
}
-(void) setReaderViewController:(ReaderViewController *)newVal {
  /* ce setter se contente d'affecter la valeur de maVariable à la valeur demandée */
  readerViewController = newVal;
}

@end

// Constructeur qui initialise également la classe m_delegate avec PdfHandler
PDFVisu::PDFVisu(QQuickItem *parent) :
    QQuickItem(parent),  mydelegate([[PdfVisuDelegate alloc] initWithPDFHandler:this])
    //QQuickItem(parent)
{
    visible=false;
    source="";
}

PDFVisu::~PDFVisu()
{

}

void PDFVisu::setPdfFile(QString pdfFile)
{
    NSString *path =  [NSString stringWithUTF8String:pdfFile.toUtf8().data()];
    NSString *password = nil;

    ReaderDocument *document = [[ReaderDocument alloc] initWithFilePath:path password:password];

    if (document != nil) // Must have a valid ReaderDocument object in order to proceed with things
    {
        ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
        readerViewController.delegate = id(mydelegate);
        [mydelegate setReaderViewController:id(readerViewController)] ;

        source=pdfFile;
    }
    else
        source="";

    emit sourceChanged();
}

QString PDFVisu::getPdfFile()
{
    return source;
}

bool PDFVisu::getVisible()
{
    return visible;
}

void PDFVisu::setVisible(bool isvisible)
{
    bind();
    visible=isvisible;
    showHide(visible);
    emit visibleChanged();
}

void PDFVisu::bind()
{
    // Association avec la window Qt
    UIView *view ;
    UIViewController *qtController ;

    view = [mydelegate mainView];
    if(!view) {
        view = static_cast<UIView *>(
                    QGuiApplication::platformNativeInterface()
                    ->nativeResourceForWindow("uiview", window()));
        [mydelegate setMainView:id(view)];
     }

    qtController = [mydelegate qtController];
    if(!qtController) {

        qtController = [[view window] rootViewController];
        [mydelegate setQtController:id(qtController)];
    }
}

void PDFVisu::showHide(bool visible)
{
    UIView *view ;
    UIViewController *qtController ;
    ReaderViewController *readerViewController ;

    view = [mydelegate mainView];
    qtController = [mydelegate qtController];
    readerViewController = [mydelegate readerViewController] ;

    if(source!=""){
        if(visible) {
            // Show
            [qtController presentViewController:readerViewController animated:YES completion:nil];
            [readerViewController hideMenuBar];
        }
        else {
            // Hide
            [qtController dismissViewControllerAnimated:YES completion:nil];
        }
    }
}
