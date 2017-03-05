#include "applicationui.hpp"

#include <QTimer>
#include <QtGui/QImage>
#include <QtGui/QPainter>
#include <QtGui/QFont>
#include <QUuid>

#include <bb/cascades/Application>
#include <bb/cascades/QmlDocument>
#include <bb/cascades/AbstractPane>
#include <bb/cascades/LocaleHandler>
#include <bb/cascades/SceneCover>
#include <bb/cascades/AbstractCover>
#include <bb/system/InvokeTargetReply>
#include <bb/ApplicationInfo>

#include <bb/data/DataSource>

#include "settings.h"
#include "BBMHandler.h"
#include "sopomygga.h"

using namespace bb::cascades;

ApplicationUI::ApplicationUI() :
        QObject()
{
    Settings *settings;

    m_pTranslator = new QTranslator(this);
    m_pLocaleHandler = new LocaleHandler(this);

    bool res = QObject::connect(m_pLocaleHandler, SIGNAL(systemLanguageChanged()), this, SLOT(onSystemLanguageChanged()));
    Q_ASSERT(res);
    Q_UNUSED(res);

    onSystemLanguageChanged();

    settings = new Settings();

    bb::data::DataSource::registerQmlTypes();

    qmlRegisterType<SceneCover>("bb.cascades", 1, 2, "SceneCover");
    qmlRegisterType<bb::ApplicationInfo>("bb.cascades", 1, 2, "ApplicationInfo");
    qmlRegisterUncreatableType<AbstractCover>("bb.cascades", 1, 2, "AbstractCover", "An AbstractCover cannot be created.");
    qmlRegisterType<QTimer>("org.tal", 1, 0, "Timer");
    qmlRegisterType<BBMHandler>("org.tal.bbm", 1, 0, "BBMHandler");
    qmlRegisterType<bb::system::phone::Phone>("bb.system.phone", 1, 0, "Phone");

    qmlRegisterType<SopoMygga>("org.tal.sopomygga", 1, 0, "MQTT");

    QCoreApplication::setOrganizationDomain("org.tal");
    QCoreApplication::setOrganizationName("TalOrg");
    QCoreApplication::setApplicationName("Y-Radio");
    QCoreApplication::setApplicationVersion("1.0.4");

    m_netconf=new QNetworkConfigurationManager();
    res = QObject::connect(m_netconf, SIGNAL(onlineStateChanged(bool)), this, SLOT(onNetworkOnlineChanged(bool)));
    Q_ASSERT(res);

    m_isonline=m_netconf->isOnline();
    emit isOnlineChanged(m_isonline);

    m_uuid=settings->getStr("GUID", "");
    if (m_uuid.isEmpty()) {
        QUuid tmp=QUuid::createUuid();
        m_uuid=tmp.toString();
        settings->setStr("GUID", m_uuid);
        qDebug() << "NEW UUID is " << m_uuid;
    } else {
        qDebug() << "Stored UUID: " << m_uuid;
    }

    QmlDocument *qml = QmlDocument::create("asset:///main.qml").parent(this);
    qml->setContextProperty("_yradio", this);
    qml->setContextProperty("settings", settings);
    AbstractPane *root = qml->createRootObject<AbstractPane>();
    Application::instance()->setScene(root);
}

QString ApplicationUI::getTempPath() const
{
    return  QDir::tempPath();
}

QString ApplicationUI::getUUID() const
{
    return m_uuid;
}

void ApplicationUI::openWebSite(const QString url)
{
    bb::system::InvokeRequest request;

    request.setMimeType("text/plain");
    request.setAction("bb.action.OPEN");
    request.setUri(url);
    bb::system::InvokeTargetReply *reply = m_invokeManager.invoke(request);
    connect(reply, SIGNAL(finished()), this, SLOT(onInvokeResult()));
}

void ApplicationUI::onInvokeResult() {
    bb::system::InvokeTargetReply * reply = qobject_cast<bb::system::InvokeTargetReply*>(sender());
    qDebug() << "Invoked target: " << reply->target();
    qDebug() << "Invoke result was: " << reply->error();
    reply->deleteLater();
}

void ApplicationUI::onNetworkOnlineChanged(bool online) {
    qDebug() << "IsOnlineChanged: " << online;
    if (online==m_isonline)
        return;

    m_isonline=online;
    emit isOnlineChanged(m_isonline);
}

void ApplicationUI::onCallUpdated(const bb::system::phone::Call &call) {
    using namespace bb::system::phone;

    qDebug() << "Call ID : " << call.callId();

    if (call.callId()==-1) {
        qWarning("Call status for invalid Call ?");
        return;
    }

    CallType::Type t = call.callType();
    CallState::Type s = call.callState();

    qDebug() << "Call Type : " << call.callType();
    qDebug() << "Call State : " << call.callState();

    switch (t) {
        case CallType::Incoming:
            emit incomingCall(s);
            break;
        case CallType::Outgoing:
            emit outgoingCall(s);
            break;
        default:
            // Ignore for now
            break;
    }
}

QString ApplicationUI::getVersion() const {
    return QCoreApplication::applicationVersion();
}

void ApplicationUI::onSystemLanguageChanged()
{
    QCoreApplication::instance()->removeTranslator(m_pTranslator);
    QString locale_string = QLocale().name();
    qDebug() << "Locale is now: " << locale_string;

    QString file_name = QString("bb10_yradio_%1").arg(locale_string);

    qDebug() << "Trying to load: " << file_name;
    if (m_pTranslator->load(file_name, "app/native/qm")) {
        QCoreApplication::instance()->installTranslator(m_pTranslator);
    } else {
        qWarning() << "Failed to load translation for " << locale_string;
    }
}
