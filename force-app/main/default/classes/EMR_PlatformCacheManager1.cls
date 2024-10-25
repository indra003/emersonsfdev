/**
* @author       : Aditya Anand
* @description  : This is Platform Cache Manager Class which helps in managing the Org and Session Cache
* @see          : https://www.jamessimone.net/blog/joys-of-apex/iteratively-building-a-flexible-caching-system/
* *************************************************
*     <runTest>EMR_PlatformCacheManager_Test<runTest>
* *************************************************
* @History
* -------------------------------------------------
* VERSION | AUTHOR               | DATE
* 1.0     |Abhilash Kumar        | 24-March-2023
*/
global without sharing class EMR_PlatformCacheManager1 {
    @TestVisible
    private static final Map<String, Cacheable> CONFIGURATION_DEVELOPER_NAME_TO_CACHEABLE_INSTANCE = new Map<String, Cacheable>();
    @TestVisible
    private static final List<EMR_CacheValue__mdt> CONFIGURED_CACHE_VALUES = Schema.EMR_CacheValue__mdt.getAll().values();
    @TestVisible
    private static final String CURRENT_VERSION_NUMBER = 'v1.0.2';
    @TestVisible
    private static final String PLATFORM_CACHE_NULL_VALUE = '<{(CACHE_VALUE_IS_NULL)}>'; // Presumably, no one will ever use this as an actual value
    @TestVisible
    private static final EMR_CacheConfiguration__mdt ORGANIZATION_CACHE_CONFIGURATION = Schema.EMR_CacheConfiguration__mdt.getInstance('EMR_OrganizationCache').clone();
    @TestVisible
    private static final EMR_CacheConfiguration__mdt SESSION_CACHE_CONFIGURATION = Schema.EMR_CacheConfiguration__mdt.getInstance('EMR_SessionCache').clone();
    
    private static Map<PlatformCacheType, EMR_PlatformCacheManagerHelper.PlatformCachePartitionProxy> cacheTypeToMockPartitionProxy = new Map<PlatformCacheType, EMR_PlatformCacheManagerHelper.PlatformCachePartitionProxy>();
    
    private static final System.Pattern alphanumericRegexPattern {
        get {
        /*if (alphanumericRegexPattern == null) {
            alphanumericRegexPattern = System.Pattern.compile('^[a-zA-Z0-9]+$');
        }
        return alphanumericRegexPattern;
        }*/
        return System.Pattern.compile('^[a-zA-Z0-9]+$');
        }
        private set;
    }
    
    static {
        System.debug(System.LoggingLevel.INFO, 'Nebula Cache Manager - Version Number: ' + CURRENT_VERSION_NUMBER);
    }
    
    public enum PlatformCacheType {
        ORGANIZATION,
        SESSION
    }
    
    /**
    * @description : This interface defines the key components and functionalities for caching objects.
    * @interface Cacheable
    **/
    global interface Cacheable {
        /**
        * @description : Checks if the cache contains a value for the given key
        * @param key
        * @return boolean 
        **/
        Boolean contains(String key);
        /**
        * @description : Checks if the cache contains values for the given set of keys.
        * @param keys
        * @return Map<String,Boolean>
        **/
        Map<String, Boolean> contains(Set<String> keys);
        /**
        * @description : Checks if the cache contains values for all the given keys.
        * @param keys
        * @return Boolean
        **/
        Boolean containsAll(Set<String> keys);
        /**
        * @description : Retrieves the value associated with the given key from the cache.
        * @param key
        * @return The cached value associated with the key, or null if not found.
        **/
        Object get(String key);
        /**
        * @description : Retrieves the value associated with the given key from the cache, using the specified cache builder class.
        * @param key
        * @param cacheBuilderClass
        * @return The cached value associated with the key, or null if not found.
        **/
        Object get(String key, System.Type cacheBuilderClass);
        /**
        * @description : Retrieves the values associated with the given set of keys from the cache.
        * @param keys
        * @return Map<String,Object>
        **/
        Map<String, Object> get(Set<String> keys);
        /**
        * @description : Retrieves all values from the cache.
        * @return Map<String,Object>
        **/
        Map<String, Object> getAll();
        /**
        * @description : Retrieves all keys from the cache.
        * @return Set<String>
        **/
        Set<String> getKeys();
        /**
        * @description : Checks if the cache is available for use.
        * @return Boolean
        **/
        Boolean isAvailable();
         /**
        * @description : Checks if the cache is enabled.
        * @return Boolean
        **/
        Boolean isEnabled();
         /**
        * @description : Checks if the cache is immutable.
        * @return Boolean
        **/
        Boolean isImmutable();
         /**
        * @description : Adds or updates a value in the cache.
        * @param key
        * @param value
        **/
        void put(String key, Object value);
        /**
        * @description : Adds or updates a multiple value in the cache.
        * @param keyToValue
        **/
        void put(Map<String, Object> keyToValue);
        /**
        * @description : Removes a value from the cache.
        * @param key
        **/
        void remove(String key);
        /**
        * @description : Removes multiple values from the cache.
        * @param keys
        **/
        void remove(Set<String> keys);
        /**
        * @description : Removes all values from the cache.
        **/
        void removeAll();
    }
    
    
    /**
    * @description : This methods gets the Organisation cache based on pre-configured configurations
    * @author Abhilash Kumar | 04-23-2023 
    * @return Cacheable 
    **/
    global static Cacheable getOrganizationCache() {
        return getOrganizationCache(ORGANIZATION_CACHE_CONFIGURATION);
    }
    
    
    /**
    * @description :This methods gets the Organisation cache based on configurations passed as parameter
    * @author Abhilash Kumar | 04-23-2023 
    * @param configuration 
    * @return Cacheable 
    **/
    global static Cacheable getOrganizationCache(EMR_CacheConfiguration__mdt configuration) {
        return getPlatformCache(configuration, PlatformCacheType.ORGANIZATION);
    }
    
    
    /**
    * @description : This methods gets the Session cache based on pre configured configurations
    * @author Abhilash Kumar | 04-23-2023 
    * @return Cacheable 
    **/
    global static Cacheable getSessionCache() {
        return getSessionCache(SESSION_CACHE_CONFIGURATION);
    }
    
    
    /**
    * @description : This methods gets the Session cache based on configurations passed as parameter
    * @author Abhilash Kumar | 04-23-2023 
    * @param configuration 
    * @return Cacheable 
    **/
    global static Cacheable getSessionCache(EMR_CacheConfiguration__mdt configuration) {
        return getPlatformCache(configuration, PlatformCacheType.SESSION);
    }
    
    /**
    * @description : This mthod is used to set mock partition proxy
    * @author Abhilash Kumar | 04-23-2023 
    * @param cacheType 
    * @param mockPartitionProxy 
    **/
    @TestVisible
    private static void setMockPartitionProxy(PlatformCacheType cacheType, EMR_PlatformCacheManagerHelper.PlatformCachePartitionProxy mockPartitionProxy) {
        cacheTypeToMockPartitionProxy.put(cacheType, mockPartitionProxy);
    }
    
    /**
    * @description : It validates the string key based on the regular expression to check if it's Alphanumeric or not.
    * @author Abhilash Kumar | 04-23-2023 
    * @param key 
    **/
    @TestVisible
    private static void validateKey(String key) {
        Matcher regexMatcher = alphanumericRegexPattern.matcher(key);
        if (regexMatcher.matches() == false) {
            throw new IllegalArgumentException('Key must be alphanumeric, received key: ' + key);
        }
    }
    
    /**
    * @description : Checks if the platform cache instance is available in map(CONFIGURATION_DEVELOPER_NAME_TO_CACHEABLE_INSTANCE). If not, returns new instance  of PlatformCache class.
    * @author Abhilash Kumar | 04-23-2023 
    * @param configuration 
    * @param cacheType 
    * @return Cacheable 
    **/
    private static Cacheable getPlatformCache(EMR_CacheConfiguration__mdt configuration, PlatformCacheType cacheType) {
        if (CONFIGURATION_DEVELOPER_NAME_TO_CACHEABLE_INSTANCE.containsKey(configuration.DeveloperName)) {
            return CONFIGURATION_DEVELOPER_NAME_TO_CACHEABLE_INSTANCE.get(configuration.DeveloperName);
        }
    
       EMR_PlatformCacheManagerHelper.PlatformCachePartitionProxy partitionProxy = 
+             new EMR_PlatformCacheManagerHelper.PlatformCachePartitionProxy(
+                 cacheType, 
+                 configuration.EMR_PlatformCachePartitionName__c);

        if (cacheTypeToMockPartitionProxy.containsKey(cacheType)) {
            partitionProxy = cacheTypeToMockPartitionProxy.get(cacheType);
        }

        PlatformCache platformCache = new PlatformCache(configuration, partitionProxy);
        CONFIGURATION_DEVELOPER_NAME_TO_CACHEABLE_INSTANCE.put(configuration.DeveloperName, platformCache);
    
        return platformCache;
        
    }
    
    /**
    * @description : It is used to load any configured values from custm metadata type to Cache
    * @author Abhilash Kumar | 04-23-2023 
    * @param cacheConfiguration 
    * @return Map<String, Object> 
    **/
    private static Map<String, Object> loadConfiguredCacheValues(EMR_CacheConfiguration__mdt cacheConfiguration) {
        Map<String, Object> keyToCacheValue = new Map<String, Object>();
        if (cacheConfiguration.EMR_IsEnabled__c == false) {
            return keyToCacheValue;
        }
    
        for (EMR_CacheValue__mdt configuredCacheValue : CONFIGURED_CACHE_VALUES) {
            if (configuredCacheValue.EMR_Cache__c == cacheConfiguration.Id && configuredCacheValue.EMR_IsEnabled__c == true) {
                System.Type dataType = System.Type.forName(configuredCacheValue.EMR_DataType__c);
                Boolean isString = configuredCacheValue.EMR_DataType__c == String.class.getName();
                Object castedValue = isString ? configuredCacheValue.EMR_Value__c : System.JSON.deserialize(configuredCacheValue.EMR_Value__c, dataType);
                keyToCacheValue.put(configuredCacheValue.EMR_Key__c, castedValue);
            }
        }
        return keyToCacheValue;
    }

    private class PlatformCache implements Cacheable {
        private final EMR_PlatformCacheManagerHelper.PlatformCachePartitionProxy cachePartitionProxy;
        private final EMR_CacheConfiguration__mdt configuration;

        /**
        * @description : This is constructor class to set the Platform cache proxy value and Cache Configurations from custom metadata type.
        * @author Abhilash Kumar | 04-23-2023 
        * @param configuration 
        * @param cachePartitionProxy 
        **/
        private PlatformCache(EMR_CacheConfiguration__mdt configuration, EMR_PlatformCacheManagerHelper.PlatformCachePartitionProxy cachePartitionProxy) {
            this.configuration = configuration;
            this.cachePartitionProxy = cachePartitionProxy;
        
            this.put(loadConfiguredCacheValues(this.configuration));
        }

        /**
        * @description : This method checks if Cache contains the key or not.
        * @author Abhilash Kumar | 04-23-2023 
        * @param key 
        * @return Boolean 
        **/
        public Boolean contains(String key) {
            if (this.configuration.EMR_IsEnabled__c == false || this.cachePartitionProxy.isAvailable() == false) {
                return false;
            } else {
                return this.cachePartitionProxy.contains(key);
            }
        }
    
        /**
        * @description : This method checks if the Cache contains the set of keys or not.
        * @author Abhilash Kumar | 04-23-2023 
        * @param keys 
        * @return Map<String, Boolean> 
        **/
        public Map<String, Boolean> contains(Set<String> keys) {
            Map<String, Boolean> keyToContainsResult = this.cachePartitionProxy.contains(keys);
            return keyToContainsResult;
        }
    
        
        /**
        * @description :This methods checks if all the keys are present in the Cache or not. If any of the key is not available, it will return false, else true.
        * @author Abhilash Kumar | 04-23-2023 
        * @param keys 
        * @return Boolean 
        **/
        public Boolean containsAll(Set<String> keys) {
            Map<String, Boolean> keyToContainsResult = this.contains(keys);
            if (keyToContainsResult.isEmpty() == true) {
                return false;
            }
        
            for (String key : keyToContainsResult.keySet()) {
                Boolean containsKey = keyToContainsResult.get(key);
                if (containsKey == false) {
                    return false;
                }
            }
            return true;
        }

        /**
        * @description : This method gets the data based on the key valu passed to it.
        * @author Abhilash Kumar | 04-23-2023 
        * @param key 
        * @return Object 
        **/
        public Object get(String key) {
            if (this.cachePartitionProxy.isAvailable() == false) {
                return false;
            } else {
                Object value = this.cachePartitionProxy.get(key);
                // Platform cache does not support storing null values, so a predefined value is used as a substitute
                if (value == PLATFORM_CACHE_NULL_VALUE) {
                    value = null;
                }
                return value;
            }
        }
    
        /**
        * @description : This method gets the 
        * @author Abhilash Kumar | 04-23-2023 
        * @param key 
        * @param cacheBuilderClass 
        * @return Object 
        **/
        public Object get(String key, System.Type cacheBuilderClass) {
            if (this.cachePartitionProxy.isAvailable() == false) {
                Cache.CacheBuilder cacheBuilder = (Cache.CacheBuilder) cacheBuilderClass.newInstance();
                return cacheBuilder.doLoad(key);
            } else {
                // Cache.CacheBuilder.doLoad method can return null
                Object value = this.cachePartitionProxy.get(key, cacheBuilderClass);
                return value;
            }
        }
    
        /**
        * @description : this method gets the key value for the set of keys passed to this method in a map.
        * @author Abhilash Kumar | 04-24-2023 
        * @param keys 
        * @return Map<String, Object> 
        **/
        public Map<String, Object> get(Set<String> keys) {
            Map<String, Object> keyToValue = this.cachePartitionProxy.get(keys);
            if (keyToValue == null) {
                keyToValue = new Map<String, Object>();
            }
            return keyToValue;
        }
    
        /**
        * @description : This method gets all the keys and values in a map from cache partition proxy
        * @author Abhilash Kumar | 04-24-2023 
        * @return Map<String, Object> 
        **/
        public Map<String, Object> getAll() {
            return this.get(this.getKeys());
        }
    
        /**
        * @description : This method gets all the keys from cache partition proxy
        * @author Abhilash Kumar | 04-24-2023 
        * @return Set<String> 
        **/
        public Set<String> getKeys() {
            Set<String> keys = this.cachePartitionProxy.getKeys();
            if (keys == null) {
                keys = new Set<String>();
            }
            return keys;
        }
    
        /**
        * @description : Checks if Cache is enabled and available
        * @author Abhilash Kumar | 04-24-2023 
        * @return Boolean 
        **/
        public Boolean isAvailable() {
            return this.isEnabled() && this.cachePartitionProxy.isAvailable() == true;
        }
    
        /**
        * @description : Checks if Cache is enabled in the configuration.
        * @author Abhilash Kumar | 04-24-2023 
        * @return Boolean 
        **/
        public Boolean isEnabled() {
            return this.configuration?.EMR_IsEnabled__c == true;
        }
    
        /**
        * @description : Checks if configurations are set as immutable or not
        * @author Abhilash Kumar | 04-24-2023 
        * @return Boolean 
        **/
        public Boolean isImmutable() {
            return this.configuration?.EMR_IsImmutable__c == true;
        }

        /**
        * @description : This put method is responsible for adding a key-value pair to a cache if certain conditions are met.
        * @param key
        * @param value
        * @author Abhilash Kumar | 04-24-2023 
        **/
    
        public void put(String key, Object value) {
            if (this.isEnabled() == false) {
                return;
            }
        
            validateKey(key);
        
            if (this.isAvailable() == true && this.isImmutable() == false || this.contains(key) == false) {
                // Platform cache does not support storing null values, so a predefined value is used as a substitute
                if (value == null) {
                    value = PLATFORM_CACHE_NULL_VALUE;
                }
                Cache.Visibility visibility = Cache.Visibility.valueOf(this.configuration.EMR_PlatformCacheVisibility__c.toUpperCase());
                this.cachePartitionProxy.put(key, value, this.configuration.EMR_PlatformCacheTimeToLive__c.intValue(), visibility, this.configuration.EMR_IsImmutable__c);
            }
        }
    
        /**
        * @description : Adds the all the key and value from the Map
        * @author Abhilash Kumar | 04-24-2023 
        * @param keyToValue 
        **/
        public void put(Map<String, Object> keyToValue) {
            for (String key : keyToValue.keySet()) {
                this.put(key, keyToValue.get(key));
            }
        }
    
        /**
        * @description : Removes the value for the respective key passed to this method.
        * @author Abhilash Kumar | 04-24-2023 
        * @param key 
        **/
        public void remove(String key) {
            if (this.isImmutable() == true) {
                return;
            }
            if (this.isAvailable() == true) {
                this.cachePartitionProxy.remove(key);
            }
        }
    
        /**
        * @description : Removes all the data respective to the set of keys passed to this method
        * @author Abhilash Kumar | 04-24-2023 
        * @param keys 
        **/
        public void remove(Set<String> keys) {
            for (String key : keys) {
                this.remove(key);
            }
        }
    
        /**
        * @description : removes all the cached data
        * @author Abhilash Kumar | 04-24-2023 
        **/
        public void removeAll() {
            for (String key : this.getKeys()) {
                this.remove(key);
            }
        }
    }
    

}