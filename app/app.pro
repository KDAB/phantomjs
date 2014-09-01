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

linux*|mac|openbsd* {
    INCLUDEPATH += breakpad/src

    SOURCES += breakpad/src/client/minidump_file_writer.cc \
      breakpad/src/common/convert_UTF.c \
      breakpad/src/common/md5.cc \
      breakpad/src/common/string_conversion.cc
}

linux* {
    SOURCES += breakpad/src/client/linux/crash_generation/crash_generation_client.cc \
      breakpad/src/client/linux/handler/exception_handler.cc \
      breakpad/src/client/linux/log/log.cc \
      breakpad/src/client/linux/minidump_writer/linux_dumper.cc \
      breakpad/src/client/linux/minidump_writer/linux_ptrace_dumper.cc \
      breakpad/src/client/linux/minidump_writer/minidump_writer.cc \
      breakpad/src/common/linux/file_id.cc \
      breakpad/src/common/linux/guid_creator.cc \
      breakpad/src/common/linux/memory_mapped_file.cc \
      breakpad/src/common/linux/safe_readlink.cc
}

mac {
    SOURCES += breakpad/src/client/mac/crash_generation/crash_generation_client.cc \
      breakpad/src/client/mac/handler/exception_handler.cc \
      breakpad/src/client/mac/handler/minidump_generator.cc \
      breakpad/src/client/mac/handler/dynamic_images.cc \
      breakpad/src/client/mac/handler/breakpad_nlist_64.cc \
      breakpad/src/common/mac/bootstrap_compat.cc \
      breakpad/src/common/mac/file_id.cc \
      breakpad/src/common/mac/macho_id.cc \
      breakpad/src/common/mac/macho_utilities.cc \
      breakpad/src/common/mac/macho_walker.cc \
      breakpad/src/common/mac/string_utilities.cc

    OBJECTIVE_SOURCES += breakpad/src/common/mac/MachIPC.mm
}

win32-msvc* {
    INCLUDEPATH += breakpad/src
    SOURCES += breakpad/src/client/windows/handler/exception_handler.cc \
      breakpad/src/client/windows/crash_generation/crash_generation_client.cc \
      breakpad/src/common/windows/guid_string.cc
}
