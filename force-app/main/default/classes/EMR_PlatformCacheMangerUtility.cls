public with sharing class EMR_PlatformCacheMangerUtility {
    
    public static Map<String, Boolean> getkeyToContainsResult(Map<String, Boolean> keyToContainsResult, Set<String>keys){
        if (keyToContainsResult == null) {
            keyToContainsResult = new Map<String, Boolean>();
        }
        if (keyToContainsResult.isEmpty() == true) {
            keyToContainsResult = new Map<String, Boolean>();
            for (String key : keys) {
            keyToContainsResult.put(key, false);
            }
        }
        return keyToContainsResult;
}
}