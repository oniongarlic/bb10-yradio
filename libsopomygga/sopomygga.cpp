#include "sopomygga.h"
#include <errno.h>
#include <QDebug>

SopoMygga::SopoMygga(QObject *parent) :
    QObject(parent),
    m_hostname("localhost"),
    m_port(1883),
    m_keepalive(60),
    m_cleanSession(true),
    m_isConnected(false),
    m_clientId(),
    mosquittopp(NULL, true)
{

}

SopoMygga::~SopoMygga()
{

}

void SopoMygga::addTopicMatch(QString topic, int topic_d) {
    m_topics.insert(topic.trimmed(), topic_d);
}

int SopoMygga::removeTopicMatch(QString topic) {
   return m_topics.remove(topic);
}

int SopoMygga::connectToHost()
{
    int r, s;

    r=mosquittopp::reinitialise(m_clientId.isEmpty() ? NULL : m_clientId.toLocal8Bit().data(), m_cleanSession);
    if (r!=MOSQ_ERR_SUCCESS) {
        qWarning() << "Failed to set client id: " << r;
        return r;
    }

    r=mosquittopp::username_pw_set(m_username.isEmpty() ? NULL : m_username.toLocal8Bit().data(), m_password.isEmpty() ? NULL : m_password.toLocal8Bit().data());
    if (r!=MOSQ_ERR_SUCCESS) {
        qWarning() << "Failed to set username/password " << r;
        return r;
    }

#if 1
    r=mosquittopp::connect_async(m_hostname.toLocal8Bit().data(), m_port, m_keepalive);
#else
    r=mosquittopp::connect(m_hostname.toLocal8Bit().data(), m_port, m_keepalive);
#endif
    if (r!=MOSQ_ERR_SUCCESS) {
        qWarning() << "Connection failure to host " << m_hostname << " r=" << r << " errno=" << std::strerror(errno);
        return r;
    }

    s=socket();
    if (s==-1) {
        qWarning() << "Failed to get mosquitto connection socket";
    }

    m_notifier_read = new QSocketNotifier(s, QSocketNotifier::Read, this);
    QObject::connect(m_notifier_read, SIGNAL(activated(int)), this, SLOT(loopRead()));

    m_notifier_write = new QSocketNotifier(s, QSocketNotifier::Write, this);
    QObject::connect(m_notifier_write, SIGNAL(activated(int)), this, SLOT(loopWrite()));

    emit connecting();

    return r;
}

void SopoMygga::timerEvent(QTimerEvent *event)
{
    int r;

    r=loop_misc();
    if (r!=MOSQ_ERR_SUCCESS) {
        qWarning() << "Misc fail " << r;
    }

    m_notifier_write->setEnabled(true);

    if (want_write()==true) {
        qDebug("NWWW");
        loopWrite();
    }
}

void SopoMygga::loopRead() {
    int r;

    qDebug("LR");
    m_notifier_write->setEnabled(true);
    r=loop_read();
    if (r!=MOSQ_ERR_SUCCESS) {
        qWarning() << "Read fail " << r;
    }

}

void SopoMygga::loopWrite() {
    int r;

    m_notifier_write->setEnabled(false);

    r=loop_misc();
    if (r!=MOSQ_ERR_SUCCESS) {
        qWarning() << "Misc fail " << r;
    }

    if (want_write()==false) {
        return;
    }

    qDebug("LW");
    r=loop_write();
    if (r!=MOSQ_ERR_SUCCESS) {
        qWarning() << "Write fail " << r;
    }

}

int SopoMygga::disconnectFromHost()
{
    if (m_isConnected==false)
        return MOSQ_ERR_NO_CONN;
    int r=mosquittopp::disconnect();
    delete m_notifier_read;
    delete m_notifier_write;
    return r;
}

int SopoMygga::reconnectToHost()
{
    int r, s;

    r=reconnect_async();

    delete m_notifier_read;
    delete m_notifier_write;

    if (r!=MOSQ_ERR_SUCCESS) {
        qWarning() << "Connection failure";
        return r;
    }

    s=socket();
    if (s==-1) {
        qWarning() << "Failed to get mosquitto connection socket";
    }

    m_notifier_read = new QSocketNotifier(s, QSocketNotifier::Read, this);
    QObject::connect(m_notifier_read, SIGNAL(activated(int)), this, SLOT(loopRead()));

    m_notifier_write = new QSocketNotifier(s, QSocketNotifier::Write, this);
    QObject::connect(m_notifier_write, SIGNAL(activated(int)), this, SLOT(loopWrite()));

    emit connecting();

    return r;
}

int SopoMygga::subscribe(QString topic, int qos)
{
    m_notifier_write->setEnabled(true);
    int r=mosquittopp::subscribe(&m_smid, topic.toLocal8Bit().data(), qos);

    return r;
}

int SopoMygga::unsubscribe(QString topic)
{
    m_notifier_write->setEnabled(true);
    int r=mosquittopp::unsubscribe(&m_mid, topic.toLocal8Bit().data());

    return r;
}

int SopoMygga::publish(QString topic, QString data, int qos, bool retain)
{
    m_notifier_write->setEnabled(true);
    int r=mosquittopp::publish(&m_pmid, topic.toLocal8Bit().data(), data.size(), data.toLocal8Bit().data(), qos, retain);

    return r;
}

int SopoMygga::setWill(QString topic, QString data, int qos, bool retain)
{
    m_notifier_write->setEnabled(true);
    int r=will_set(topic.toLocal8Bit().data(), data.size(), data.toLocal8Bit().data(), qos, retain);

    return r;
}

void SopoMygga::clearWill()
{
    m_notifier_write->setEnabled(true);
    will_clear();
}

void SopoMygga::on_connect(int rc) {
    m_isConnected=true;
    emit connected();
    emit isConnectedeChanged(m_isConnected);
    m_timer=startTimer(1000);
}

void SopoMygga::on_disconnect(int rc) {
    m_isConnected=false;
    emit disconnected();
    emit isConnectedeChanged(m_isConnected);
    killTimer(m_timer);
}

void SopoMygga::on_message(const mosquitto_message *message)
{
    QString topic(message->topic);
    QString data=QString::fromLocal8Bit((char *)message->payload, message->payloadlen);

    emit msg(topic, data);

    if (m_topics.contains(topic))
        emit topicMatch(m_topics.value(topic));
}

void SopoMygga::on_error()
{
    qWarning("on_error");
    emit error();
}

void SopoMygga::on_log(int level, const char *str)
{
    qDebug() << "mqtt: " << level << str;
}

void SopoMygga::setClientId(QString clientId)
{
    if (m_clientId == clientId)
        return;

    m_clientId = clientId;
    emit clientIdChanged(clientId);
}

void SopoMygga::setCleanSession(bool cleanSession)
{
    if (m_cleanSession == cleanSession)
        return;

    m_cleanSession = cleanSession;
    emit cleanSessionChanged(cleanSession);
}

