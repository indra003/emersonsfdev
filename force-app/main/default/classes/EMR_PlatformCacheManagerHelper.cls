/**
    * @description : Adds the all the key and value from the Map
    * @author Abhilash Kumar | 04-24-2023  
    **/
public with sharing class EMR_PlatformCacheManagerHelper {
    

   /**
    * @description : Adds the all the key and value from the Map
    * @author Abhilash Kumar | 04-24-2023  
    **/
    public virtual class PlatformCachePartitionProxy {
        private final Cache.Partition platformCachePartition;
        // This Method determines/sets the cacheType to work with
        //@SuppressWarnings('PMD.EmptyCatchBlock')
        /**
        * @description : Adds the all the key and value from the Map
        * @author Abhilash Kumar | 04-24-2023 
        * @param cacheType
        * @param partitionName
        **/
        public PlatformCachePartitionProxy(EMR_PlatformCacheManager1.PlatformCacheType cacheType, String partitionName) {
            this.platformCachePartition = getPartition(cacheType, partitionName);
        }

        private Cache.Partition getPartition(EMR_PlatformCacheManager1.PlatformCacheType cacheType, String partitionName) {
            try {
                return fetchPartition(cacheType, partitionName);
            } catch (Cache.Org.OrgCacheException ex){
                // No-op if the partition can't be found - the rest of the code will fallback to using the transaction cache
                return null;
            } catch (Cache.Session.SessionCacheException ex){
                // No-op if the partition can't be found - the rest of the code will fallback to using the transaction cache
                return null;
            }
        }

        private Cache.Partition fetchPartition(EMR_PlatformCacheManager1.PlatformCacheType cacheType, String partitionName) {
            switch on cacheType {
                when ORGANIZATION {
                    return Cache.Org.getPartition(partitionName);
                }
                when SESSION {
                    return Cache.Session.getPartition(partitionName);
                }
            }
            return null;
        }
        /**
        * @description : checking keys is present 
        * @param key 
        * @return boolean
        **/
        public virtual Boolean contains(String key) {
            return this.platformCachePartition?.contains(key) == true;
        }
        /**
        * @description : checking keys is present 
        * @param keys 
        * @return Map<String,boolean>
        **/
        public Map<String, Boolean> contains(Set<String> keys) {
            Map<String, Boolean> keyToContainsResult = this.platformCachePartition?.contains(keys);
            return EMR_PlatformCacheMangerUtility.getkeyToContainsResult(keyToContainsResult, keys);
        }
        
        /**
        * @description : get the value 
        * @param key 
        * @return object
        **/
        public virtual Object get(String key) {
            return this.platformCachePartition?.get(key);
        }
        /**
        * @description : get the value 
        * @param key
        * @param cacheBuilderClass
        * @return object
        **/
        public virtual Object get(String key, System.Type cacheBuilderClass) {
            return this.platformCachePartition?.get(cacheBuilderClass, key);
        }
        /**
        * @description : get the value 
        * @param keys
        * @return Map<String, Object>
        **/
        public virtual Map<String, Object> get(Set<String> keys) {
            return this.platformCachePartition?.get(keys);
        }
        /**
        * @description : get the keys 
        * @return Set<String>
        **/
        public virtual Set<String> getKeys() {
            return this.platformCachePartition?.getKeys();
        }
        /**
        * @description : checking partition is avaailable
        * @return boolean
        **/
        public virtual Boolean isAvailable() {
            return this.platformCachePartition?.isAvailable() == true;
        }
    
        /**
        * @description : put method
        * @param key
        * @param value
        * @param cacheTtlSeconds
        * @param cacheVisiblity
        * @param isCacheImmutable
        **/
        @SuppressWarnings('PMD.ExcessiveParameterList')
        public virtual void put(String key, Object value, Integer cacheTtlSeconds, Cache.Visibility cacheVisiblity, Boolean isCacheImmutable) {
            this.platformCachePartition?.put(key, value, cacheTtlSeconds, cacheVisiblity, isCacheImmutable);
        }
        
        /**
        * @description : remove the value
        * @param key
        **/
        public virtual void remove(String key) {
            this.platformCachePartition?.remove(key);
        }
    }

    

}