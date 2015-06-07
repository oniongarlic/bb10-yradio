/*
 * BBMHandler.h
 *
 *  Created on: Jun 3, 2015
 *      Author: milang
 */

#ifndef BBMHANDLER_H_
#define BBMHANDLER_H_

#include <QObject>

#include <bb/platform/bbm/Context>
#include <bb/platform/bbm/RegistrationState>
#include <bb/platform/bbm/MessageService>

class BBMHandler: public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool allowed READ isAllowed NOTIFY allowedChanged)
public:
    BBMHandler(QObject *parent = 0);
    virtual ~BBMHandler();

    Q_INVOKABLE bool registerApplication();
    Q_INVOKABLE bool inviteToDownload();

public slots:
    void processRegistrationStatus(const bb::platform::bbm::RegistrationState::Type state);

signals:
    void allowedChanged();
    void bbmRegistered(bool ok);

private:
    bool isAllowed() { return m_allowed; }
    bool m_allowed;
    bb::platform::bbm::Context *m_context;
    bb::platform::bbm::MessageService* m_messageService;
};

#endif /* BBMHANDLER_H_ */
