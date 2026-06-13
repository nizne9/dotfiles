#include "fzymatcher.h"

#include <QQmlExtensionPlugin>
#include <QJSEngine>
#include <QQmlEngine>
#include <qqml.h>

class NiriQuickshellFzyMatcherPlugin : public QQmlExtensionPlugin {
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QQmlExtensionInterface_iid)

public:
    void registerTypes(const char *uri) override {
        qmlRegisterSingletonType<FzyMatcher>(uri, 1, 0, "FzyMatcher", [](QQmlEngine *, QJSEngine *) -> QObject * {
            return new FzyMatcher;
        });
    }
};

#include "plugin.moc"
