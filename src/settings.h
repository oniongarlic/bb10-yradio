#ifndef SETTINGS_H
#define SETTINGS_H

#include <QObject>
#include <QSettings>

class Settings : public QObject
{
    Q_OBJECT
public:
    explicit Settings(QObject *parent = 0);

    Q_INVOKABLE int getInt(const QString &key, const int defaultValue);
    Q_INVOKABLE bool getBool(const QString &key, const bool defaultValue);
    Q_INVOKABLE QString getStr(const QString &key, const QString defaultValue);

    Q_INVOKABLE void setInt(const QString &key, const int value);
    Q_INVOKABLE void setBool(const QString &key, const bool value);
    Q_INVOKABLE void setStr(const QString &key, const QString value);
    
signals:
    
public slots:

private:
    QSettings m_settings;
    
};

#endif // SETTINGS_H
