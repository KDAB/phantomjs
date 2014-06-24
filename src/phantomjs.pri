QT += network webkitwidgets
LIBS += -L$$PWD/qt/qtbase/plugins/platforms/ -lqphantom

mac {
    QMAKE_CXXFLAGS += -fvisibility=hidden
    QMAKE_LFLAGS += '-sectcreate __TEXT __info_plist Info.plist'
    CONFIG -= app_bundle
# Uncomment to build a Mac OS X Universal Binary (i.e. x86 + ppc)
#    CONFIG += x86 ppc
}

win32-msvc* {
    LIBS += -lCrypt32 -llibxml2_a
    CONFIG(static) {
        DEFINES += STATIC_BUILD
        QTPLUGIN += \
            qico
    }
}

openbsd* {
    LIBS += -L/usr/X11R6/lib
}

