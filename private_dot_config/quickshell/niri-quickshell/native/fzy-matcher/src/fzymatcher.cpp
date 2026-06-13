#include "fzymatcher.h"

#include <QCollator>
#include <QVariant>

#include <algorithm>
#include <cmath>
#include <limits>
#include <string>
#include <vector>

extern "C" {
#include "match.h"
}

FzyMatcher::FzyMatcher(QObject *parent)
    : QObject(parent) {
}

QVariantList FzyMatcher::rank(const QString &query, const QVariantList &entries, int limit) const {
    const QString needle = query.trimmed();
    const int resultLimit = limit <= 0 ? 20 : limit;
    std::vector<RankedEntry> ranked;
    ranked.reserve(static_cast<size_t>(entries.size()));

    for (int i = 0; i < entries.size(); ++i) {
        const QVariantMap entry = entries.at(i).toMap();
        if (entry.isEmpty())
            continue;

        RankedEntry item;
        item.entry = entry;
        item.name = entry.value(QStringLiteral("name")).toString();
        item.originalIndex = i;
        item.score = needle.isEmpty()
            ? 0.0
            : scoreEntry(needle, entry);

        if (needle.isEmpty() || item.score > 0.0)
            ranked.push_back(item);
    }

    const auto less = [](const RankedEntry &a, const RankedEntry &b) {
        if (a.score != b.score)
            return a.score > b.score;

        const int nameCmp = QString::localeAwareCompare(a.name, b.name);
        if (nameCmp != 0)
            return nameCmp < 0;

        return a.originalIndex < b.originalIndex;
    };

    if (ranked.size() > static_cast<size_t>(resultLimit)) {
        std::partial_sort(ranked.begin(), ranked.begin() + resultLimit, ranked.end(), less);
        ranked.resize(static_cast<size_t>(resultLimit));
    } else {
        std::sort(ranked.begin(), ranked.end(), less);
    }

    QVariantList out;
    out.reserve(static_cast<qsizetype>(ranked.size()));
    for (const auto &item : ranked)
        out.push_back(item.entry);

    return out;
}

double FzyMatcher::score(const QString &query, const QString &text) const {
    return scoreText(query.trimmed(), text);
}

QStringList FzyMatcher::stringListFromVariant(const QVariant &value) {
    QStringList result;

    if (value.canConvert<QStringList>())
        return value.toStringList();

    const QVariantList list = value.toList();
    result.reserve(list.size());
    for (const QVariant &item : list) {
        const QString text = item.toString().trimmed();
        if (!text.isEmpty())
            result.push_back(text);
    }

    return result;
}

double FzyMatcher::scoreEntry(const QString &needle, const QVariantMap &entry) {
    double best = 0.0;

    const QString name = entry.value(QStringLiteral("name")).toString();
    const QString genericName = entry.value(QStringLiteral("genericName")).toString();
    const QString comment = entry.value(QStringLiteral("comment")).toString();
    const QString exec = entry.value(QStringLiteral("exec")).toString();
    const QString id = entry.value(QStringLiteral("id")).toString();
    const QStringList keywords = stringListFromVariant(entry.value(QStringLiteral("keywords")));
    const QStringList categories = stringListFromVariant(entry.value(QStringLiteral("categories")));

    double nameScore = scoreText(needle, name) * 5.0;
    if (nameScore > 0.0) {
        if (equalsFolded(name, needle))
            nameScore += 1000.0;
        else if (startsWithFolded(name, needle))
            nameScore += 500.0;
    }
    best = std::max(best, nameScore);

    double genericScore = scoreText(needle, genericName) * 2.0;
    if (genericScore > 0.0 && startsWithFolded(genericName, needle))
        genericScore += 150.0;
    best = std::max(best, genericScore);

    best = std::max(best, scoreBestStringList(needle, keywords, 1.0));
    best = std::max(best, scoreBestStringList(needle, categories, 0.3));
    best = std::max(best, scoreText(needle, id) * 1.5);
    best = std::max(best, scoreText(needle, exec) * 0.8);
    best = std::max(best, scoreText(needle, comment) * 0.3);

    return best;
}

double FzyMatcher::scoreText(const QString &needle, const QString &text) {
    if (needle.isEmpty() || text.isEmpty())
        return 0.0;

    const std::string needleUtf8 = needle.toUtf8().toStdString();
    const std::string haystackUtf8 = text.toUtf8().toStdString();

    if (needleUtf8.empty() || haystackUtf8.empty())
        return 0.0;

    if (!has_match(needleUtf8.c_str(), haystackUtf8.c_str()))
        return 0.0;

    const score_t raw = match(needleUtf8.c_str(), haystackUtf8.c_str());
    if (std::isinf(raw) && raw > 0)
        return 1000.0;
    if (!std::isfinite(raw))
        return 0.0;

    // fzy scores are usually small floating point values; shift them positive
    // so every valid fuzzy match beats the no-match sentinel.
    return raw + 100.0;
}

double FzyMatcher::scoreBestStringList(const QString &needle, const QStringList &values, double weight) {
    double best = 0.0;
    for (const QString &value : values)
        best = std::max(best, scoreText(needle, value) * weight);
    return best;
}

bool FzyMatcher::startsWithFolded(const QString &text, const QString &prefix) {
    return text.startsWith(prefix, Qt::CaseInsensitive);
}

bool FzyMatcher::equalsFolded(const QString &text, const QString &other) {
    return QString::compare(text, other, Qt::CaseInsensitive) == 0;
}
