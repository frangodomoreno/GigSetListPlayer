#include <QDir>
#include <QGuiApplication>
#include <QQmlEngine>
#include <QQmlFileSelector>
#include <QQmlContext>
#include <QQuickItem>
#include <QScreen>
#include <QSizeF>
#include <QSysInfo>
#include <QStandardPaths>
#include <QQuickView> //Not using QQmlApplicationEngine because many examples don't have a Window{}
#include <QtSql/QSqlDatabase>
//Translation
#include <QTranslator>
#include <QDesktopServices>

#include "fileservice.h"
#include "internetservices.h"
#include "global.h"

#ifdef IOS
#include "pdfvisu.h"
#include "backupattrib.h"
#endif

#ifdef ANDROID
#include "pdfcore.h"
#endif

#ifdef QT_WEBVIEW_WEBENGINE_BACKEND
#include <QtWebEngine>
#endif // QT_WEBVIEW_WEBENGINE_BACKEND

#include "dropboxoperations.h"

bool setFileAttribute(QString filename);

int main(int argc, char* argv[])
{
    QGuiApplication app(argc,argv);

#ifdef QT_WEBVIEW_WEBENGINE_BACKEND
    QtWebEngine::initialize();
#endif // QT_WEBVIEW_WEBENGINE_BACKEND

    qreal screenH=0;
    qreal screenW=0;
    bool firstLaunch=false;

    FileService fileservice;   
    InternetServices internetservices;

    //Translation
    QTranslator translator;
    QDropbox dropbox(APP_KEY, APP_SECRET);
    DropBoxOperations dropboxOperations;
    dropboxOperations.setDropboxObject(&dropbox);


#ifdef IOS
    qmlRegisterType<PDFVisu>("PDFVisu", 1, 0, "PDFVisu");
#endif

#ifdef ANDROID
    qmlRegisterType<PdfCore>("ANDPDFVisu", 1, 0, "ANDPDFVisu");
#endif


    translator.load(":/playlistPlayer."+ QLocale::system().name());

    if(QGuiApplication::screens().length()>1){
        QScreen *scrn = QGuiApplication::primaryScreen();
        screenH=scrn->availableGeometry().size().height();
        screenW=scrn->availableGeometry().size().width();
    }

    app.setOrganizationName("Monasys");
    app.setOrganizationDomain("Monasys.fr");

    app.setApplicationName(QFileInfo(app.applicationFilePath()).baseName());

    //Translation

    app.installTranslator(&translator);

    QQuickView view;
    view.connect(view.engine(), SIGNAL(quit()), &app, SLOT(quit()));

    // Test if local Documents Dir exists, if not creates it

    if(!QDir(documents).exists()){        
        if(QDir(documents.left(documents.lastIndexOf("/"))).exists()){
            QDir(documents.left(documents.lastIndexOf("/"))).mkdir(QDir(documents).dirName());
        }
    }
    if(!QDir(documents + "/playlists").exists()){
        // First launch, install examples
        QDir(documents).mkdir("playlists");
        QDir(documents + "/playlists").mkdir("audio");
        QDir(documents + "/playlists").mkdir("chords");
        QDir(documents + "/playlists").mkdir("lyrics");
        QFile::copy(":/playlists/mysetlist.csv",documents + "/playlists/example.csv") ;
        QFile::copy(":/playlists/audio/onemore.mp3",documents + "/playlists/audio/onemore.mp3") ;        
        QFile::copy(":/playlists/lyrics/onemore.txt",documents + "/playlists/lyrics/onemore.txt") ;
        QFile::copy(":/playlists/lyrics/mysong.txt",documents + "/playlists/lyrics/mysong.txt") ;
        QFile::copy(":/playlists/chords/onemore.png", documents + "/playlists/chords/onemore.png") ;

        setFileAttribute(documents + "/playlists/example.csv");
        setFileAttribute(documents + "/playlists/audio/onemore.mp3");
        setFileAttribute(documents + "/playlists/lyrics/onemore.txt");
        setFileAttribute(documents + "/playlists/lyrics/mysong.txt");
        setFileAttribute(documents + "/playlists/chords/onemore.png");

#ifdef IOS
        // 20160124 Rend ces fichiers non sauvegardable sur iCloud
        backupAttrib bckAtt;
        bool statAttrib;

        setFileAttribute(documents + "/playlists/example.csv");
        setFileAttribute(documents + "/playlists/audio/onemore.mp3");
        setFileAttribute(documents + "/playlists/lyrics/onemore.txt");
        setFileAttribute(documents + "/playlists/lyrics/mysong.txt");
        setFileAttribute(documents + "/playlists/chords/onemore.png");

        statAttrib = bckAtt.setAttribExclude(documents + "/playlists/example.csv");
        statAttrib = bckAtt.setAttribExclude(documents + "/playlists/audio/onemore.mp3");
        statAttrib = bckAtt.setAttribExclude(documents + "/playlists/lyrics/onemore.txt");
        statAttrib = bckAtt.setAttribExclude(documents + "/playlists/lyrics/mysong.txt");
        statAttrib = bckAtt.setAttribExclude(documents + "/playlists/chords/onemore.png");
#endif

        firstLaunch=true;
    }


    //qDebug() << ">>>>>>>>>>>>> Kernel " << QSysInfo::productType() << QSysInfo::kernelVersion() << " Location " << documents;


    /*****
    if (qgetenv("QT_QUICK_CORE_PROFILE").toInt()) {
        QSurfaceFormat f = view.format();
        f.setProfile(QSurfaceFormat::CoreProfile);
        f.setVersion(4, 4);
        view.setFormat(f);
    }
    ******/

    view.rootContext()->setContextProperty("firstLaunch",firstLaunch);
    view.rootContext()->setContextProperty("fileService",&fileservice);
    view.rootContext()->setContextProperty("internetServices",&internetservices);
    view.rootContext()->setContextProperty("deviceType",QSysInfo::productType());
    view.rootContext()->setContextProperty("screenH",screenH);
    view.rootContext()->setContextProperty("screenW",screenW);
    view.rootContext()->setContextProperty("liteMode",LiteMode);

    //20150723 Ajout de la property setlistDir
    view.rootContext()->setContextProperty("setlistDir",documents + "/playlists/");

    view.rootContext()->setContextProperty("dropBoxOperations",&dropboxOperations);
    view.rootContext()->setContextProperty("android",false);
    view.setSource(QUrl("qrc:/qml/main.qml"));


    view.setResizeMode(QQuickView::SizeRootObjectToView);

    if (QGuiApplication::platformName() == QLatin1String("qnx") ||  QGuiApplication::platformName() == QLatin1String("eglfs")) {
        view.showFullScreen();
    } else {
        view.show() ;
    }

    QObject *qmlRoot = view.rootObject() ;
    QMetaObject::invokeMethod(qmlRoot, "main");

    return app.exec();
}

bool setFileAttribute(QString filename){
    return QFile::setPermissions(filename,QFileDevice::WriteOwner|QFileDevice::ReadOwner);
}
