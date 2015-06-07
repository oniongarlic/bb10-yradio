#ifndef ApplicationUI_HPP_
#define ApplicationUI_HPP_

#include <QObject>
#include <bb/system/InvokeManager>
#include <bb/system/phone/Phone>
#include <bb/system/phone/CallType>

namespace bb
{
    namespace cascades
    {
        class LocaleHandler;
    }
}

class QTranslator;

/*!
 * @brief Application UI object
 *
 * Use this object to create and init app UI, to create context objects, to register the new meta types etc.
 */
class ApplicationUI : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool onLine READ isOnLine NOTIFY isOnlineChanged)

public:
    ApplicationUI();
    virtual ~ApplicationUI() {}

    Q_INVOKABLE QString getVersion();
    Q_INVOKABLE void openWebSite(const QString url);
    Q_INVOKABLE QString getTempPath();

signals:
    void incomingCall(int status);
    void outgoingCall(int status);
    void callEnded();
    void isOnlineChanged();

private slots:
    void onSystemLanguageChanged();
    void onNetworkOnlineChanged(bool online);
    void onInvokeResult();

public slots:
    void onCallUpdated(const bb::system::phone::Call &call);

private:
    QTranslator* m_pTranslator;
    bb::cascades::LocaleHandler* m_pLocaleHandler;
    bb::system::InvokeManager m_invokeManager;
    bool isOnLine() { return m_isonline; }
    QSettings m_settings;
    QNetworkConfigurationManager* m_netconf;
    bool m_isonline;
};

#endif /* ApplicationUI_HPP_ */
