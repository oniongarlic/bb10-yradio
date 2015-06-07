/*
 * BBMHandler.cpp
 *
 *  Created on: Jun 3, 2015
 *      Author: milang
 */

#include <QObject>
#include <QDebug>

#include <src/BBMHandler.h>

using namespace bb::platform::bbm;

BBMHandler::BBMHandler(QObject *parent)
    : QObject(parent),
      m_allowed(false),
      m_messageService(0)
{
    bool r;

    qDebug("Preparing BBM Context");
    m_context=new bb::platform::bbm::Context("aabc7273-363e-4ec4-936d-2b31d376fc10", this);
    r=connect(m_context, SIGNAL(registrationStateUpdated(bb::platform::bbm::RegistrationState::Type)), this,
            SLOT(processRegistrationStatus(bb::platform::bbm::RegistrationState::Type)));
    Q_ASSERT(r);

    qDebug("Context ready");
}

BBMHandler::~BBMHandler()
{
    qDebug("BBMHandler is going away, byebye");
    delete m_context;
}

bool BBMHandler::registerApplication()
{
    qDebug("registerApplication");
    if (m_context->isAccessAllowed()) {
        m_allowed=true;
        emit bbmRegistered(true);
        return true;
    }
    qDebug("requestRegisterApplication");
    return m_context->requestRegisterApplication();
}

bool BBMHandler::inviteToDownload()
{
    qDebug("inviteToDownload");
    if (m_allowed==false)
        return false;
    qDebug("sendDownloadInvitation");
    // We need to create is ondemand
    if (!m_messageService)
        m_messageService = new bb::platform::bbm::MessageService(m_context, this);
    return m_messageService->sendDownloadInvitation();
}

void BBMHandler::processRegistrationStatus(const RegistrationState::Type state)
{
qDebug() << "BBM Reg state: " << state;
switch (state) {
    case RegistrationState::Allowed:
        qDebug("Allowed");
        m_allowed=true;
        emit bbmRegistered(true);
        break;
    case RegistrationState::Pending:
        qDebug("Registration is pending");
        break;
    case RegistrationState::Unregistered:
        m_allowed=false;
        emit bbmRegistered(false);
        break;
    case RegistrationState::BlockedByUser:
        qDebug("User blocked!");
        m_allowed=false;
        emit bbmRegistered(false);
        break;
    case RegistrationState::BlockedByRIM:
        m_allowed=false;
        emit bbmRegistered(false);
        break;
    case RegistrationState::NoDataConnection:
        m_allowed=false;
        emit bbmRegistered(false);
        break;
    case RegistrationState::InvalidUuid:
        m_allowed=false;
        emit bbmRegistered(false);
        break;
    case RegistrationState::MaxDownloadsReached:
        m_allowed=false;
        emit bbmRegistered(false);
    break;
    case RegistrationState::MaxAppsReached:
        m_allowed=false;
        emit bbmRegistered(false);
    break;
    case RegistrationState::Expired:
        m_allowed=false;
        emit bbmRegistered(false);
        break;
    case RegistrationState::CancelledByUser:
        m_allowed=false;
        emit bbmRegistered(false);
        break;
    case RegistrationState::BbmDisabled:
        m_allowed=false;
        emit bbmRegistered(false);
        break;
    case RegistrationState::BlockedEnterprisePerimeter:
        m_allowed=false;
        emit bbmRegistered(false);
        break;
    case RegistrationState::TemporaryError:
    case RegistrationState::UnexpectedError:
    case RegistrationState::Unknown:
    default:
        m_allowed=false;
        emit bbmRegistered(false);
    break;
}


}
