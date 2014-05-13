#!/usr/bin/env bash

set -e

QT_CFG=''

BUILD_CONFIRM=0
COMPILE_JOBS=1
MAKEFLAGS_JOBS=''
BUILD_JAVA=

if [[ "$MAKEFLAGS" != "" ]]; then
  MAKEFLAGS_JOBS=$(echo $MAKEFLAGS | egrep -o '\-j[0-9]+' | egrep -o '[0-9]+')
fi

if [[ "$MAKEFLAGS_JOBS" != "" ]]; then
  # user defined number of jobs in MAKEFLAGS, re-use that number
  COMPILE_JOBS=$MAKEFLAGS_JOBS
elif [[ $OSTYPE = darwin* ]]; then
   # We only support modern Mac machines, they are at least using
   # hyperthreaded dual-core CPU.
   COMPILE_JOBS=4
elif [[ $OSTYPE == freebsd* ]]; then
   COMPILE_JOBS=`sysctl -n hw.ncpu`
else
   CPU_CORES=`grep -c ^processor /proc/cpuinfo`
   if [[ "$CPU_CORES" -gt 1 ]]; then
       COMPILE_JOBS=$CPU_CORES
   fi
fi

if [[ "$COMPILE_JOBS" -gt 8 ]]; then
   # Safety net.
   COMPILE_JOBS=8
fi

until [ -z "$1" ]; do
    case $1 in
        "--qt-config")
            shift
            QT_CFG=" $1"
            shift;;
        "--qmake-args")
            shift
            QMAKE_ARGS=$1
            shift;;
        "--jobs")
            shift
            COMPILE_JOBS=$1
            shift;;
        "--confirm")
            BUILD_CONFIRM=1
            shift;;
        "--java")
            BUILD_JAVA=CONFIG+=javabindings
            shift;;
        "--help")
            echo "Usage: $0 [--qt-config CONFIG] [--jobs NUM]"
            echo
            echo "  --confirm                   Silently confirm the build."
            echo "  --qt-config CONFIG          Specify extra config options to be used when configuring Qt"
            echo "  --jobs NUM                  How many parallel compile jobs to use. Defaults to 4."
            echo "  --java                      Generate Java bindings for PhantomJS."
            echo
            exit 0
            ;;
        *)
            echo "Unrecognised option: $1"
            exit 1;;
    esac
done


if [[ "$BUILD_CONFIRM" -eq 0 ]]; then
cat << EOF
----------------------------------------
               WARNING
----------------------------------------

Building PhantomJS from source takes a very long time, anywhere from 30 minutes
to several hours (depending on the machine configuration). It is recommended to
use the premade binary packages on supported operating systems.

For details, please go the the web site: http://phantomjs.org/download.html.

EOF

    echo "Do you want to continue (y/n)?"
    read continue
    if [[ "$continue" != "y" ]]; then
        exit 1
    fi
    echo
    echo
fi

if [ ! -z "$BUILD_JAVA" ]; then
    if [ -z "$(which swig)" ]; then
        echo "Could not find swig executable in PATH, make sure it is installed."
        echo "Swig is required to generated the Java bindings."
        exit 1
    fi

    if [[ -z "$JAVA_HOME" || ! -d "$JAVA_HOME" ]]; then
        echo "JAVA_HOME environment variable is not set."
        echo "Set it to the path to your JDK, e.g.: export JAVA_HOME=/usr/lib/jvm/java-7-openjdk"
        exit 1
    fi
    if [[ ! -d "$JAVA_HOME/include" ]]; then
        echo "The JAVA_HOME folder does not have an include folder: $JAVA_HOME/include"
        exit 1
    fi
    if [[ ! -d "$JAVA_HOME/include/linux" ]]; then
        echo "The JAVA_HOME folder does not have an include/linux folder: $JAVA_HOME/include/linux"
        exit 1
    fi
fi

cd src/qt && ./preconfig.sh --jobs $COMPILE_JOBS --qt-config "$QT_CFG"
export SQLITE3SRCDIR=$PWD/qtbase/3rdparty/sqlite/
cd qtwebkit
../qtbase/bin/qmake $QMAKE_ARGS
make -j$COMPILE_JOBS
cd ../../..

if [ ! -z "$BUILD_JAVA" ]; then
    swig -java -c++ -package phantom \
         -I$PWD/src/qt/qtbase/include \
         -I$PWD/src/qt/qtbase/include/QtCore \
         -I$PWD/src \
         -outdir $PWD/swig/phantom \
         -o $PWD/swig/phantomjs_javabridge.cpp \
         $PWD/swig/phantomjs_javabridge.i
fi

src/qt/qtbase/bin/qmake $QMAKE_ARGS $BUILD_JAVA
make -j$COMPILE_JOBS
