/*************************************************************
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
        $$PWD/objc/pdfvisu.mm

    HEADERS += \
        $$PWD/objc/pdfvisu.h

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



