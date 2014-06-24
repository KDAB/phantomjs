/*
  This file is part of the PhantomJS project from Ofi Labs.

  Copyright (C) 2014 Milian Wolff, KDAB <milian.wolff@kdab.com>

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the <organization> nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
  ARE DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

%module(directors="1") PhantomJS_JavaBridge

%{
#include <QObject>
#include <qmetaobject.h>
#include <qobjectdefs.h>
#include <QCoreApplication>
#include <QString>


#include "phantomjava.h"
#include "config.h"
%}

//IN: target language to C/++
//OUT: C/++target language to 

//$1 = output | $input 

%pragma(java) jniclasscode=%{
  static {
    try {
        System.loadLibrary("phantomjsjavabindings");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Failed to load native code library.\n" + e
                       + "\nMake sure to configure the VM arguments, such that the library can be found, e.g.:\n"
                       + "-Djava.library.path=/path/to/phantomjs/lib");
      System.exit(1);
    }
  }
%}

//region main vars argc&  argv
	//region int&
	/*---------------------------------------------------------------------------*/
	%typemap(in) int&
	{
		$1 = new int($input);
	}

	%typemap(jni) int& "int"
	%typemap(jtype) int& "int"
	%typemap(jstype) int& "int"

	/* These 2 typemaps handle the conversion of the jtype to jstype typemap type and vice versa */
	%typemap(javain) int& "$javainput"
	%typemap(javaout) int&
	{
		return $jnicall;
	}
	
	//Leak in order to keep the args alive
	
	/*--------------------------------------------------------------------------- */
	//endregion

	//region char**
	/*--------------------------------------------------------------------------- */
	/*
		(modiefied) Example from:
			http://www.swig.org/Doc1.3/Java.html#converting_java_string_arrays
	*/

	/* This tells SWIG to treat char** as a special case when used as a parameter in a function calmailnews.message_display.disablel */
	%typemap(in) char** (jint size) 
	{
		int i = 0;
		size = jenv->GetArrayLength( $input);
		$1 = (char**) malloc((size+1)*sizeof(char* ));
		
		/* make a copy of each string */
		for (i = 0; i<size; i++) 
		{
			jstring j_string = (jstring) jenv->GetObjectArrayElement($input, i);
			const char*  c_string = jenv->GetStringUTFChars( j_string, 0);
			$1[i] = (char*) malloc((strlen(c_string)+1)*sizeof(char));
			strcpy($1[i], c_string);
			jenv->ReleaseStringUTFChars( j_string, c_string);
			jenv->DeleteLocalRef( j_string);
		}
		$1[i] = 0;
	}

	/* This cleans up the memory we malloc'd before the function call */
	%typemap(freearg) char** 
	{
		//Leak in order to keep the args alive
		
		//int i;
		//for (i=0; i<size$argnum-1; i++)
		//{
		//	free($1[i]);
		//}
		//free($1);
	}

	/* These 3 typemaps tell SWIG what JNI and Java types to use */
	%typemap(jni) char** "jobjectArray"
	%typemap(jtype) char** "String[]"
	%typemap(jstype) char** "String[]"

	/* These 2 typemaps handle the conversion of the jtype to jstype typemap type and vice versa */
	%typemap(javain) char** "$javainput"
	%typemap(javaout) char** 
	{
		return $jnicall;
	}
	/*---------------------------------------------------------------------------*/
	//endregion
//endregion



//region QString
/*---------------------------------------------------------------------------*/
%typemap(out) QString 
{
    jresult = jenv->NewStringUTF( $1.toStdString().c_str() );
}

/* These 3 typemaps tell SWIG what JNI and Java types to use */
%typemap(jni) QString "jstring"
%typemap(jtype) QString "String"
%typemap(jstype) QString "String"

/* These 2 typemaps handle the conversion of the jtype to jstype typemap type and vice versa */
%typemap(javain) QString "$javainput"
%typemap(javaout) QString 
{
    return $jnicall;
}

%typemap(in) const QString&
{
    const char* c_string = jenv->GetStringUTFChars( $input, 0);
    $1 = new QString(QString::fromUtf8(c_string));
}

%typemap(freearg) const QString&
{
	delete $1;
}

/* These 3 typemaps tell SWIG what JNI and Java types to use */
%typemap(jni) const QString& "jstring"
%typemap(jtype) const QString& "String"
%typemap(jstype) const QString& "String"

/* These 2 typemaps handle the conversion of the jtype to jstype typemap type and vice versa */
%typemap(javain) const QString& "$javainput"
%typemap(javaout) const QString& 
{
    return $jnicall;
}

/*---------------------------------------------------------------------------*/
//endregion


//{
//region QStringList
/*---------------------------------------------------------------------------*/
%typemap(out) QStringList 
{
    int i;
    int len=0;
    jstring temp_string;
    const jclass clazz = jenv->FindClass("java/lang/String");

    len = $1.length();
    jresult = jenv->NewObjectArray( len, clazz, NULL);
    /* exception checking omitted */

    for (i=0; i<len; i++) 
    {
      temp_string = jenv->NewStringUTF( $1.at(i).toStdString().c_str());
      jenv->SetObjectArrayElement( jresult, i, temp_string);
      jenv->DeleteLocalRef(temp_string);
    }
}

/* These 3 typemaps tell SWIG what JNI and Java types to use */
%typemap(jni) QStringList "jobjectArray"
%typemap(jtype) QStringList "String[]"
%typemap(jstype) QStringList "String[]"

/* These 2 typemaps handle the conversion of the jtype to jstype typemap type and vice versa */
%typemap(javain) QStringList "$javainput"
%typemap(javaout) QStringList 
{
    return $jnicall;
}


%typemap(in) const QStringList& (jint len)
{
    len = jenv->GetArrayLength( $input);
    jstring temp_string;
    
	$1 = new QStringList();
	
	//const QString& tempQString;
		
	/* const QStringList& */
	for (int i = 0; i < len; i++) 
	{
		temp_string = (jstring) jenv->GetObjectArrayElement($input, i);
		const char* c_string = jenv->GetStringUTFChars( temp_string, 0);
		//tempQString = c_string;
		
		$1->append(QString::fromUtf8(c_string));
		
		jenv->ReleaseStringUTFChars( temp_string, c_string);
		jenv->DeleteLocalRef( temp_string );
	}
}


%typemap(freearg) const QStringList&
{
	delete $1;
}

/* These 3 typemaps tell SWIG what JNI and Java types to use */
%typemap(jni) const QStringList& "jobjectArray"
%typemap(jtype) const QStringList& "String[]"
%typemap(jstype) const QStringList& "String[]"

/* These 2 typemaps handle the conversion of the jtype to jstype typemap type and vice versa */
%typemap(javain) const QStringList& "$javainput"
%typemap(javaout) const QStringList&
{
    return $jnicall;
}


%typemap(in) const QStringList* const (jint len)
{
    len = jenv->GetArrayLength( $input);
    jstring temp_string;
    
	$1 = new QStringList();
	
	//const QString& tempQString;
		
	// eee
	for (int i = 0; i < len; i++) 
	{
		temp_string = (jstring) jenv->GetObjectArrayElement($input, i);
		const char* c_string = jenv->GetStringUTFChars( temp_string, 0);
		//tempQString = c_string;
		
		$1->append(QString::fromUtf8(c_string));
		
		jenv->ReleaseStringUTFChars( temp_string, c_string);
		jenv->DeleteLocalRef( temp_string );
	}
}

/* These 3 typemaps tell SWIG what JNI and Java types to use */
%typemap(jni) const QStringList* const "jobjectArray"
%typemap(jtype) const QStringList* const "String[]"
%typemap(jstype) const QStringList* const "String[]"

/* These 2 typemaps handle the conversion of the jtype to jstype typemap type and vice versa */
%typemap(javain) const QStringList* const "$javainput"
%typemap(javaout) const QStringList* const
{
    return $jnicall;
}

/*---------------------------------------------------------------------------*/
//}endregion

//region QApplication
/*---------------------------------------------------------------------------*/
%typemap(javacode) QApplication %{
  public QApplication(String[] argv) {
    //cArr: 1. arg = working dir | x. arg = programm arg
    int cArrLen = argv.length+1;
    String[] cArr = new String[cArrLen];
    cArr[0] = System.getProperty("user.dir");
    for(int i = 1; i < cArrLen; i++) { cArr[i] = argv[i-1]; }

    swigCPtr = PhantomJS_JavaBridgeJNI.new_QApplication__SWIG_1(cArrLen, cArr);
    swigCMemOwn = true;
  }
%}
/*---------------------------------------------------------------------------*/
//endregion

//region JavaCallback
/*---------------------------------------------------------------------------*/

%feature("director", assumeoverride=1) JavaCallback;

%typemap(directorin,descriptor="Ljava/lang/String;") const QString&
  %{ $input = jenv->NewStringUTF( $1.toStdString().c_str() ); %}

%typemap(directorout) const QString& {
  $1 = new QString(QString::fromUtf8(jenv->GetStringUTFChars( $input, 0)));
}

%typemap(javadirectorin) const QString& "$jniinput"
%typemap(javadirectorout) const QString& "$javacall"

/*
%typemap(out) QString
{
    jresult = jenv->NewStringUTF( $1.toStdString().c_str() );
}

/ * These 3 typemaps tell SWIG what JNI and Java types to use * /
%typemap(jni) QString "jstring"
%typemap(jtype) QString "String"
%typemap(jstype) QString "String"

/ * These 2 typemaps handle the conversion of the jtype to jstype typemap type and vice versa * /
%typemap(javain) QString "$javainput"
%typemap(javaout) QString
{
    return $jnicall;
}

%typemap(in) const QString&
{
    const char* c_string = jenv->GetStringUTFChars( $input, 0);
    $1 = new QString(QString::fromUtf8(c_string));
}
*/

/*---------------------------------------------------------------------------*/

/*
%define __GNUC__ 3 %enddef
%define __attribute__(arg) %enddef
%define __WORDSIZE 64 %enddef
%define QT_NO_QOBJECT %enddef

%include "QtCore/qconfig.h"
%include "QtCore/qconfig-64.h"
%include "QtCore/qcompilerdetection.h"
%include "QtCore/qfeatures.h"
%include "QtCore/qglobal.h"
%include "QtCore/qobjectdefs.h"
%include "qcoreapplication.h"
*/

//region classes
class QObject
{
	public:
		QObject(QObject *parent=0);
		~QObject();
};

class QApplication
{
    public:
        #ifdef Q_QDOC
            QApplication(int &argc, char **argv);
        #else
            QApplication(int &argc, char **argv, int = ApplicationFlags);
        #endif

		~QApplication();
		static int exec();
		static QStringList arguments();
		static QApplication *instance() { return self; }
};

class QCoreApplication
{
    public:
        #ifdef Q_QDOC
            QCoreApplication(int &argc, char **argv);
        #else
            QCoreApplication(int &argc, char **argv, int = ApplicationFlags);
        #endif

        ~QCoreApplication();
        static int exec();
        static QStringList arguments();
        static QCoreApplication *instance() { return self; }
};

class Config 
{
	public:
		Config(QObject* parent = 0);
		~Config();

		void init(const QStringList* const args);
		void processArgs(const QStringList& args);
		void loadJsonFile(const QString& filePath);
		const QString helpText();
		const bool autoLoadImages();
		void setAutoLoadImages(const bool value);
		const QString cookiesFile();
		void setCookiesFile(const QString& cookiesFile);
		const QString offlineStoragePath();
		void setOfflineStoragePath(const QString& value);
		const int offlineStorageDefaultQuota();
		void setOfflineStorageDefaultQuota(int offlineStorageDefaultQuota);
		const bool diskCacheEnabled();
		void setDiskCacheEnabled(const bool value);
		const int maxDiskCacheSize();
		void setMaxDiskCacheSize(int maxDiskCacheSize);
		const bool ignoreSslErrors();
		void setIgnoreSslErrors(const bool value);
		const bool localToRemoteUrlAccessEnabled();
		void setLocalToRemoteUrlAccessEnabled(const bool value);
		const QString outputEncoding();
		void setOutputEncoding(const QString& value);
		const QString proxyType();
		void setProxyType(const QString value);
		const QString proxy();
		void setProxy(const QString& value);
		const QString proxyHost();
		const int proxyPort();
		const QString proxyAuth();
		void setProxyAuth(const QString& value);
		const QString proxyAuthUser();
		const QString proxyAuthPass();
		void setProxyAuthUser(const QString& value);
		void setProxyAuthPass(const QString& value);
		const QStringList scriptArgs();
		void setScriptArgs(const QStringList& value);
		const QString scriptEncoding();
		void setScriptEncoding(const QString& value);
		const QString scriptLanguage();
		void setScriptLanguage(const QString& value);
		const QString scriptFile();
		void setScriptFile(const QString& value);
		const QString unknownOption();
		void setUnknownOption(const QString& value);
		const bool versionFlag();
		void setVersionFlag(const bool value);
		void setDebug(const bool value);
		const bool debug();
		void setRemoteDebugPort(const int port);
		const int remoteDebugPort();
		void setRemoteDebugAutorun(const bool value);
		const bool remoteDebugAutorun();
		const bool webSecurityEnabled();
		void setWebSecurityEnabled(const bool value);
		const bool helpFlag();
		void setHelpFlag(const bool value);
		void setPrintDebugMessages(const bool value);
		const bool printDebugMessages();
		void setJavascriptCanOpenWindows(const bool value);
		const bool javascriptCanOpenWindows();
		void setJavascriptCanCloseWindows(const bool value);
		const bool javascriptCanCloseWindows();
		void setSslProtocol(const QString& sslProtocolName);
		const QString sslProtocol();
		void setSslCertificatesPath(const QString& sslCertificatesPath);
		const QString sslCertificatesPath();
		void setWebdriver(const QString& webdriverConfig);
		const QString webdriver();
		const bool isWebdriverMode();
		void setWebdriverLogFile(const QString& webdriverLogFile);
		const QString webdriverLogFile();
		void setWebdriverLogLevel(const QString& webdriverLogLevel);
		const QString webdriverLogLevel();
		void setWebdriverSeleniumGridHub(const QString& hubUrl);
		const QString webdriverSeleniumGridHub();
	//public slots:
		void handleSwitch(const QString& sw);
		//void handleOption(const QString& option, const QVariant& value);
		//void handleParam(const QString& param, const QVariant& value);
		void handleError(const QString& error);
};

%include "javacallback.h"

class PhantomJava
{
    private:
        PhantomJava::PhantomJava();
    public:
        static PhantomJava* instance();
        ~PhantomJava();

        const QStringList args();
        //const QVariantMap defaultPageSettings();
        const QString outputEncoding();
        void setOutputEncoding(const QString& encoding);
        bool execute();
        const int returnValue();
        const QString libraryPath();
        void setLibraryPath(const QString& libraryPath);
        const QString scriptName();
        //const QVariantMap version();
        QObject* page() const;
        Config* config();
        const bool printDebugMessages();
        const bool areCookiesEnabled();
        void setCookiesEnabled(const bool value);
        const bool webdriverMode();
        //Q_INVOKABLE QObject* _createChildProcess();
        //public slots:
        QObject* createCookieJar(const QString& filePath);
        QObject* createWebPage();
        QObject* createWebServer();
        QObject* createFilesystem();
        QObject* createSystem();
        QObject* createCallback();
        void loadModule(const QString& moduleSource, const QString& filename);
        bool injectJs(const QString& jsFilePath);
        //bool setCookies(const QVariantList& cookies);
        //const QVariantList cookies();
        //bool addCookie(const QVariantMap& cookie);
        bool deleteCookie(const QString& cookieName);
        void clearCookies();
        void exit(int code = 0);
        void debugExit(int code = 0);

        void call(const QString& data);
        void listen(JavaCallback* callback);
};

//endregion classes
