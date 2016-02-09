APP_NAME = bb10_yradio

CONFIG += qt warn_on cascades10

INCLUDEPATH += ../mosquitto/include ../libsopomygga

LIBS += -lbbmultimedia -lbbdata
LIBS += -lbb -lbbsystem -lbbdevice -lbbplatform -lbbplatformbbm 
LIBS += -L../mosquitto/lib -lmosquitto -lmosquittopp

SOURCES += ../libsopomygga/*.cpp 
HEADERS += ../libsopomygga/*.h

include(config.pri)

TRANSLATIONS = \
    $${TARGET}_fi.ts \
    $${TARGET}.ts
