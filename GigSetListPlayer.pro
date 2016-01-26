# TODO: 20150701 - Setlist editable voir : http://www.developpez.net/forums/d1397033/c-cpp/bibliotheques/qt/qt-quick/rendre-tableview-editable/
#       20150701 - Threading  :voir utilisation de workerscript pour le chargement de la setlist.
#       20150701 - Confort : lors de la diminution de la police Lyrics, voir si il est possible de passer sur  deux colonnes d'affichage
#       20150722 - Test du webviewer 5.5 de Qt pour une utilisation avec du pdf
#
#       20150721 - OK-20150722 Confort : Prévoir un système de switch de setlist saans avoir à passer par la synchro dropbox
#       20150721 - OK-20150721 Confort : Prévoir un système de suppresion des liste seule (sans les fichiers liés)

TEMPLATE = app
TARGET = playlistPlayer

android {
    message(" Android Conf")

    DISTFILES += \
        $$PWD/android/gradle/wrapper/gradle-wrapper.jar \
        $$PWD/android/AndroidManifest.xml \
        $$PWD/android/res/values/libs.xml \
        $$PWD/android/build.gradle \
        $$PWD/android/gradle/wrapper/gradle-wrapper.properties \
        $$PWD/android/gradlew \
        $$PWD/android/gradlew.bat

    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
    DEFINES += ANDROID
    QT += androidextras
    SOURCES += \
         $$PWD/cpp/pdfcore.cpp

    HEADERS += \
        $$PWD/cpp/pdfcore.h
}

win32{
    message("Win32 Configuration")
    DEFINES += QTDROPBOX_LIBRARY
}


ios {
    CONFIG+=lib_bundle
    message("iOS Configuration")
    QMAKE_INFO_PLIST = ios/Info.plist
    ios_icon.files = $$files($$PWD/ios/Icon*.png)
    ios_icon.files += $$files($$PWD/ios/Default*.png)
    QMAKE_BUNDLE_DATA += ios_icon
    assets_catalogs.files = $$files($$PWD/ios/*.xcassets)
    QMAKE_BUNDLE_DATA += assets_catalogs
    LIBS += -framework UIKit -framework Foundation -framework CoreGraphics -framework QuartzCore -framework ImageIO -framework MessageUI
    LIBS += -F$$PWD/pdfCore/ -framework pdfCore

    INCLUDEPATH += $$PWD/pdfCore/pdfCore.framework/Versions/A/Headers
    DEPENDPATH += $$PWD/pdfCore/pdfCore.framework/Versions/A/Headers

    OBJECTIVE_SOURCES += \
        $$PWD/objc/pdfvisu.mm \
        $$PWD/objc/backupattrib.mm

    HEADERS += \
        $$PWD/objc/pdfvisu.h \
        $$PWD/objc/backupattrib.h

    QT += sensors gui_private
    DEFINES += IOS
}

osx {
    message("OsX Configuration")
    ICON = $$PWD/playlistPlayer.icns
}

!osx:qtHaveModule(webengine) {
        QT += webengine
        DEFINES += QT_WEBVIEW_WEBENGINE_BACKEND
}


SOURCES += \
    $$PWD/cpp/main.cpp \
    $$PWD/cpp/fileservice.cpp \
    $$PWD/cpp/dropboxoperations.cpp \
    $$PWD/cpp/dropbox/qdropbox.cpp \
    $$PWD/cpp/dropbox/qdropboxaccount.cpp \
    $$PWD/cpp/dropbox/qdropboxdeltaresponse.cpp \
    $$PWD/cpp/dropbox/qdropboxfile.cpp \
    $$PWD/cpp/dropbox/qdropboxfileinfo.cpp \
    $$PWD/cpp/dropbox/qdropboxjson.cpp \
    $$PWD/cpp/internetservices.cpp

HEADERS += \
    $$PWD/cpp/fileservice.h \
    $$PWD/cpp/global.h \
    $$PWD/cpp/dropboxoperations.h \
    $$PWD/cpp/dropbox/qdropbox.h \
    $$PWD/cpp/dropbox/qdropboxaccount.h \
    $$PWD/cpp/dropbox/qdropboxdeltaresponse.h \
    $$PWD/cpp/dropbox/qdropboxfile.h \
    $$PWD/cpp/dropbox/qdropboxfileinfo.h \
    $$PWD/cpp/dropbox/qdropboxjson.h \
    $$PWD/cpp/dropbox/qtdropbox_global.h \
    $$PWD/cpp/keys.h\
    $$PWD/cpp/internetservices.h



RESOURCES += \
    $$PWD/playlistplayer.qrc

OTHER_FILES +=\


QT += quick
QT += multimedia
QT += network xml
QT += sql



################
# MultiLanguage
################
lupdate_only {
SOURCES = $$PWD/qml/*.qml \
          $$PWD/js/*.js \
          $$PWD/cpp/*.cpp\
}

TRANSLATIONS = $$PWD/playlistPlayer.fr_FR.ts

DISTFILES += \
    qml/CsvEditor.qml \
    qml/InAppProcess.qml \
    images/buy10.png \
    qml/WebViewCreate.qml \
    js/dynamicObjCreator.js \
    qml/PdfViewCreate.qml \
    qml/AndPdfViewer.qml






