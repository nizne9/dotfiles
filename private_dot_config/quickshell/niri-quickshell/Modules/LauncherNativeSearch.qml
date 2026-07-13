import QtQml
import NiriQuickshell.FzyMatcher 1.0 as NativeSearch

QtObject {
    function rank(query, entries, limit) {
        return NativeSearch.FzyMatcher.rank(query, entries, limit);
    }
}
