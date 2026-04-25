#include "CarPlayConfig.h"

#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QStandardPaths>
#include <QStringList>
#include <QTextStream>

namespace
{
constexpr int kDefaultCarPlayWidth = 1280;
constexpr int kDefaultCarPlayHeight = 720;

QStringList candidateSettingsPaths()
{
    const QString appDir = QCoreApplication::applicationDirPath();
    const QString appConfigDir = QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation);

    return {
        QDir(appDir).absoluteFilePath("settings.txt"),
        QDir(appDir).absoluteFilePath("carplay/settings.txt"),
        QDir(appConfigDir).absoluteFilePath("settings.txt"),
        QDir(appConfigDir).absoluteFilePath("carplay/settings.txt"),
        QDir(appDir).absoluteFilePath("../../integrations/carplay/fastcarplay/settings.txt"),
        QDir(appDir).absoluteFilePath("../Resources/settings.txt")
    };
}

QString readSettingValue(const QString &key)
{
    const QString settingsPath = CarPlayConfig::resolveSettingsPath();
    if (settingsPath.isEmpty())
        return QString();

    QFile file(settingsPath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return QString();

    QTextStream stream(&file);

    while (!stream.atEnd()) {
        const QString line = stream.readLine().trimmed();

        if (line.isEmpty() || line.startsWith('#'))
            continue;

        const int equalsIndex = line.indexOf('=');
        if (equalsIndex <= 0)
            continue;

        const QString currentKey = line.left(equalsIndex).trimmed();
        const QString value = line.mid(equalsIndex + 1).trimmed();

        if (currentKey == key)
            return value;
    }

    return QString();
}

int readIntSetting(const QString &key, int fallback)
{
    bool ok = false;
    const int value = readSettingValue(key).toInt(&ok);
    return ok ? value : fallback;
}
}

namespace CarPlayConfig
{
QString resolveSettingsPath()
{
    const QStringList candidates = candidateSettingsPaths();

    for (const QString &candidate : candidates) {
        const QFileInfo info(candidate);
        if (info.exists() && info.isFile())
            return info.canonicalFilePath().isEmpty() ? info.absoluteFilePath() : info.canonicalFilePath();
    }

    return candidates.isEmpty() ? QString() : candidates.first();
}

int carPlayWidth()
{
    return readIntSetting("width", kDefaultCarPlayWidth);
}

int carPlayHeight()
{
    return readIntSetting("height", kDefaultCarPlayHeight);
}
}