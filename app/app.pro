TEMPLATE = app
CONFIG += console

TARGET = phantomjs
DESTDIR = ../bin

INCLUDEPATH = ../src

SOURCES += main.cpp

include(../src/phantomjs.pri)

LIBS += -L../lib -lphantomjs
win32:TARGETDEPS += ../lib/phantomjs.lib
else:TARGETDEPS += ../lib/libphantomjs.a
