// Copyright (C) 2021 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only

#include <QCoreApplication>
#include <QDir>
#include <QFileInfo>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "app_environment.h"
#include "CarPlayConfig.h"
#include "CarPlayEngine.h"
#include "CarPlayView.h"

using namespace Qt::StringLiterals;

namespace
{
QUrl resolveRuntimeQmlUrl()
{
    const QString appDir = QCoreApplication::applicationDirPath();
    const QDir dir(appDir);

    const QStringList candidates = {
        dir.absoluteFilePath("AppMain.qml"),
        dir.absoluteFilePath("../AppMain.qml"),
        dir.absoluteFilePath("../../AppMain.qml"),
        dir.absoluteFilePath("../Rx8_HeadUnit/AppMain.qml"),
        dir.absoluteFilePath("../../Rx8_HeadUnit/AppMain.qml"),
        dir.absoluteFilePath("../../../Rx8_HeadUnit/AppMain.qml")
    };

    for (const QString &candidate : candidates) {
        const QFileInfo fi(candidate);
        if (fi.exists() && fi.isFile())
            return QUrl::fromLocalFile(fi.absoluteFilePath());
    }

    return QUrl(u"qrc:/qt/qml/Main/main.qml"_s);
}
}

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

    const QString carPlaySettingsPath = CarPlayConfig::resolveSettingsPath();
    engine.rootContext()->setContextProperty("carPlaySettingsPath", carPlaySettingsPath);

    engine.addImportPath(QCoreApplication::applicationDirPath() + "/qml");
    engine.addImportPath(":/");

    const QUrl qmlUrl = resolveRuntimeQmlUrl();

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