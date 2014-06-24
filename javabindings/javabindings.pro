TEMPLATE = lib

TARGET = phantomjsjavabindings

SOURCES += javabindings.cpp \
           swig/phantomjs_javabridge.cpp

CONFIG += shared
CONFIG -= static

INCLUDEPATH += $$(JAVA_HOME)/include \
               $$(JAVA_HOME)/include/linux \
               ../src

DESTDIR = ../lib

LIBS += -L../lib -lphantomjs

include(../src/phantomjs.pri)
