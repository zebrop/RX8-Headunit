// Copyright (C) 2021 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only

#include <QCoreApplication>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "app_environment.h"
#include "CarPlayConfig.h"
#include "CarPlayEngine.h"
#include "CarPlayView.h"
#include "teensy/TeensyGateway.h"

using namespace Qt::StringLiterals;

int main(int argc, char *argv[])
{
    set_qt_environment();

    QGuiApplication app(argc, argv);

    QCoreApplication::setOrganizationName(QStringLiteral("asrs-automation"));
    QCoreApplication::setOrganizationDomain(QStringLiteral("asrs-automation.local"));
    QCoreApplication::setApplicationName(QStringLiteral("Rx8_HeadUnit"));

    qmlRegisterType<CarPlayView>("CarPlay", 1, 0, "CarPlayView");

    QQmlApplicationEngine engine;

    CarPlayEngine carPlayEngine;
    engine.rootContext()->setContextProperty("carPlayEngine", &carPlayEngine);

    TeensyGateway teensyGateway;
    engine.rootContext()->setContextProperty("teensyGateway", &teensyGateway);

    const QString carPlaySettingsPath = CarPlayConfig::resolveSettingsPath();
    engine.rootContext()->setContextProperty("carPlaySettingsPath", carPlaySettingsPath);

    const QUrl qmlUrl(u"qrc:/qt/qml/Main/main.qml"_s);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [qmlUrl](QObject *object, const QUrl &objectUrl) {
            if (!object && qmlUrl == objectUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);

    engine.load(qmlUrl);

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}