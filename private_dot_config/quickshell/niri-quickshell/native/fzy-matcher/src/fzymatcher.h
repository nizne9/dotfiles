#pragma once

#include <QObject>
#include <QVariantList>
#include <QVariantMap>

class FzyMatcher : public QObject {
    Q_OBJECT

public:
    explicit FzyMatcher(QObject *parent = nullptr);

    Q_INVOKABLE QVariantList rank(const QString &query, const QVariantList &entries, int limit = 20) const;
    Q_INVOKABLE double score(const QString &query, const QString &text) const;

private:
    struct RankedEntry {
        QVariantMap entry;
        double score = 0.0;
        QString name;
        int originalIndex = 0;
    };

    static QStringList stringListFromVariant(const QVariant &value);
    static double scoreEntry(const QString &needle, const QVariantMap &entry);
    static double scoreText(const QString &needle, const QString &text);
    static double scoreBestStringList(const QString &needle, const QStringList &values, double weight);
    static bool startsWithFolded(const QString &text, const QString &prefix);
    static bool equalsFolded(const QString &text, const QString &other);
};
