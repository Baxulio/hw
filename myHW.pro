QT += qml quick sql quickcontrols2 network

CONFIG += c++11

SOURCES += main.cpp \
    sqlsubjectmodel.cpp \
    sqltaskmodel.cpp \
    servicemodel.cpp \
    solutions.cpp \
    getpostfiles.cpp

RESOURCES += \
    resources.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

DISTFILES += \
    main.qml \
    tasks.qml \
    Subjects.qml

HEADERS += \
    sqlsubjectmodel.h \
    sqltaskmodel.h \
    servicemodel.h \
    solutions.h \
    getpostfiles.h
