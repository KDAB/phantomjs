TEMPLATE = lib
CONFIG += shared
CONFIG -= static

TARGET = phantomjsjavabindings
DESTDIR = ../lib

INCLUDEPATH += $$(JAVA_HOME)/include \
               ../src

linux: INCLUDEPATH += $$(JAVA_HOME)/include/linux
win32: INCLUDEPATH += $$(JAVA_HOME)/include/win32

SOURCES += javabindings.cpp \
           phantomjava.cpp \
           swig/phantomjs_javabridge.cpp

HEADERS += phantomjava.h

RESOURCES += phantomjava.qrc

include(../src/phantomjs.pri)
LIBS += -L../lib -lphantomjs
TARGETDEPS += ../lib/libphantomjs.a
