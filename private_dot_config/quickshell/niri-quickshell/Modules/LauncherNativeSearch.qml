import QtQml
import "../plugins/NiriQuickshell/FzyMatcher" as NativeSearch

QtObject {
    function rank(query, entries, limit) {
        return NativeSearch.FzyMatcher.rank(query, entries, limit);
    }
}
