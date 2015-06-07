#include "settings.h"

Settings::Settings(QObject *parent) :
    QObject(parent)
{

}

int Settings::getInt(const QString &key, const int defaultValue) {    
    return m_settings.value(key, defaultValue).toInt();
}

bool Settings::getBool(const QString &key, const bool defaultValue) {    
    return m_settings.value(key, defaultValue).toBool();
}

QString Settings::getStr(const QString &key, const QString defaultValue)
{
    return m_settings.value(key, defaultValue).toString();
}

void Settings::setInt(const QString &key, const int value) {
    m_settings.setValue(key, QVariant(value));
}

void Settings::setBool(const QString &key, const bool value) {
    m_settings.setValue(key, QVariant(value));
}

void Settings::setStr(const QString &key, const QString value) {
    m_settings.setValue(key, QVariant(value));
}
