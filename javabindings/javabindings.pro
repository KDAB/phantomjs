TEMPLATE = lib
CONFIG += shared
CONFIG -= static

TARGET = phantomjsjavabindings
DESTDIR = ../lib

INCLUDEPATH += $$(JAVA_HOME)/include \
               $$(JAVA_HOME)/include/linux \
               ../src

SOURCES += javabindings.cpp \
           phantomjava.cpp \
           swig/phantomjs_javabridge.cpp

HEADERS += phantomjava.h

RESOURCES += phantomjava.qrc

include(../src/phantomjs.pri)
LIBS += -L../lib -lphantomjs
TARGETDEPS += ../lib/libphantomjs.a
