TEMPLATE = lib
CONFIG += shared
CONFIG -= static

TARGET = phantomjsjavabindings
DESTDIR = ../lib

!win32:!winrt: {
  # this is only available on non-windows platforms
  QTPLUGIN += qphantom
} else {
  QTPLUGIN += qwindows
}

INCLUDEPATH += $$(JAVA_HOME)/include \
               ../src \
               $$PWD

linux: INCLUDEPATH += $$(JAVA_HOME)/include/linux
win32: INCLUDEPATH += $$(JAVA_HOME)/include/win32

SOURCES += javabindings.cpp \
           phantomjava.cpp \
           swig/phantomjs_javabridge.cpp

HEADERS += phantomjava.h

RESOURCES += phantomjava.qrc

include(../src/phantomjs.pri)
LIBS += -L../lib -lphantomjs
win32:TARGETDEPS += ../lib/phantomjs.lib
else:TARGETDEPS += ../lib/libphantomjs.a
