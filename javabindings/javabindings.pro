TEMPLATE = lib

TARGET = phantomjsjavabindings

SOURCES += javabindings.cpp \
           phantomjava.cpp \
           swig/phantomjs_javabridge.cpp

HEADERS += phantomjava.h

CONFIG += shared
CONFIG -= static

RESOURCES += phantomjava.qrc

INCLUDEPATH += $$(JAVA_HOME)/include \
               $$(JAVA_HOME)/include/linux \
               ../src

DESTDIR = ../lib

LIBS += -L../lib -lphantomjs
TARGETDEPS += ../lib/libphantomjs.a

include(../src/phantomjs.pri)
