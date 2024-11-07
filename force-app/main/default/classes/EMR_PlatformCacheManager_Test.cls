/**
 * @description       : Test Class for EMR_PlatformCacheManager.
 * @author            : Aditya Anand
 * @group             : Platform Cache Manager
 * @last modified on  : 04-10-2023
 * @last modified by  : Abhilash Kumar
**/
@isTest
public without sharing class EMR_PlatformCacheManager_Test {

    static {
        EMR_PlatformCacheManager.CONFIGURED_CACHE_VALUES.clear();
      }
    
      @IsTest
      static void it_does_not_put_key_in_organisation_cache_when_configuration_is_disabled() {
        String mockKey = 'SomeKey';
        EMR_CacheConfiguration__mdt disabledConfiguration = new EMR_CacheConfiguration__mdt(
            EMR_IsEnabled__c = false,
            EMR_IsImmutable__c = true,
            EMR_PlatformCachePartitionName__c = 'Mock'
        );
        User mockValue = new User(Id = System.UserInfo.getUserId(), ProfileId = System.UserInfo.getProfileId());
        EMR_PlatformCacheManager.Cacheable cache = EMR_PlatformCacheManager.getOrganizationCache(disabledConfiguration);
        System.Assert.isFalse(cache.contains(mockKey));
    
        cache.put(mockKey, mockValue);
    
        System.Assert.isFalse(cache.contains(mockKey));
      }
    
      @IsTest
      static void it_does_not_put_key_in_session_cache_when_configuration_is_disabled() {
        String mockKey = 'SomeKey';
        EMR_CacheConfiguration__mdt disabledConfiguration = new EMR_CacheConfiguration__mdt(
            EMR_IsEnabled__c = false,
            EMR_IsImmutable__c = true,
            EMR_PlatformCachePartitionName__c = 'Mock'
        );
        User mockValue = new User(Id = System.UserInfo.getUserId(), ProfileId = System.UserInfo.getProfileId());
        EMR_PlatformCacheManager.Cacheable cache = EMR_PlatformCacheManager.getSessionCache(disabledConfiguration);
        System.Assert.isFalse(cache.contains(mockKey));
    
        cache.put(mockKey, mockValue);
    
        System.Assert.isFalse(cache.contains(mockKey));
      }
       
      @IsTest
      static void it_adds_new_key_to_organization_cache_when_organization_platform_cache_is_available() {
        String mockKey = 'SomeKey';
        User mockValue = new User(Id = System.UserInfo.getUserId(), ProfileId = System.UserInfo.getProfileId());
        MockPlatformCachePartitionProxy mockOrganizationPartitionProxy = new MockPlatformCachePartitionProxy(true);
        System.Assert.isTrue(mockOrganizationPartitionProxy.isAvailable());
        EMR_PlatformCacheManager.setMockPartitionProxy(EMR_PlatformCacheManager.PlatformCacheType.ORGANIZATION, mockOrganizationPartitionProxy);
        System.Assert.areEqual(0, mockOrganizationPartitionProxy.containsMethodCallCount);
        System.Assert.isFalse(EMR_PlatformCacheManager.getOrganizationCache().contains(mockKey));
        System.Assert.areEqual(1, mockOrganizationPartitionProxy.containsMethodCallCount);
        System.Assert.areEqual(0, mockOrganizationPartitionProxy.putMethodCallCount);
    
        EMR_PlatformCacheManager.getOrganizationCache().put(mockKey, mockValue);
    
        System.Assert.areEqual(1, mockOrganizationPartitionProxy.putMethodCallCount);
        System.Assert.isTrue(mockOrganizationPartitionProxy.contains(mockKey));
        System.Assert.areEqual(mockValue, mockOrganizationPartitionProxy.get(mockKey));
        System.Assert.isTrue(EMR_PlatformCacheManager.getOrganizationCache().contains(mockKey));
        System.Assert.areEqual(mockValue, EMR_PlatformCacheManager.getOrganizationCache().get(mockKey));
      }
    
      @IsTest
      static void it_gets_value_from_organization_cache_when_transaction_cache_miss_and_organization_platform_cache_is_available() {
        String mockKey = 'SomeKey';
        User mockValue = new User(Id = System.UserInfo.getUserId(), ProfileId = System.UserInfo.getProfileId());
        MockPlatformCachePartitionProxy mockOrganizationPartitionProxy = new MockPlatformCachePartitionProxy(true);
        mockOrganizationPartitionProxy.put(mockKey, mockValue, 3600, Cache.Visibility.ALL, false);
        System.Assert.isTrue(mockOrganizationPartitionProxy.isAvailable());
        EMR_PlatformCacheManager.setMockPartitionProxy(EMR_PlatformCacheManager.PlatformCacheType.ORGANIZATION, mockOrganizationPartitionProxy);
        System.Assert.areEqual(0, mockOrganizationPartitionProxy.containsMethodCallCount);
        System.Assert.isTrue(EMR_PlatformCacheManager.getOrganizationCache().contains(mockKey));
        System.Assert.areEqual(1, mockOrganizationPartitionProxy.containsMethodCallCount);
        System.Assert.areEqual(0, mockOrganizationPartitionProxy.getMethodCallCount);
    
        Object actualResult = EMR_PlatformCacheManager.getOrganizationCache().get(mockKey);
    
        System.Assert.areEqual(1, mockOrganizationPartitionProxy.getMethodCallCount);
        System.Assert.areEqual(mockValue, actualResult);
        System.Assert.isTrue(EMR_PlatformCacheManager.getOrganizationCache().contains(mockKey));
      }
    
      @IsTest
      static void it_gets_value_from_session_cache_when_transaction_cache_miss_and_session_platform_cache_is_available() {
        String mockKey = 'SomeKey';
        User mockValue = new User(Id = System.UserInfo.getUserId(), ProfileId = System.UserInfo.getProfileId());
        MockPlatformCachePartitionProxy mockSessionPartitionProxy = new MockPlatformCachePartitionProxy(true);
        mockSessionPartitionProxy.put(mockKey, mockValue, 3600, Cache.Visibility.ALL, false);
        System.Assert.isTrue(mockSessionPartitionProxy.isAvailable());
        EMR_PlatformCacheManager.setMockPartitionProxy(EMR_PlatformCacheManager.PlatformCacheType.SESSION, mockSessionPartitionProxy);
        System.Assert.areEqual(0, mockSessionPartitionProxy.containsMethodCallCount);
        System.Assert.isTrue(EMR_PlatformCacheManager.getSessionCache().contains(mockKey));
        System.Assert.areEqual(1, mockSessionPartitionProxy.containsMethodCallCount);
        System.Assert.areEqual(0, mockSessionPartitionProxy.getMethodCallCount);
    
        Object actualResult = EMR_PlatformCacheManager.getSessionCache().get(mockKey);
    
        System.Assert.areEqual(1, mockSessionPartitionProxy.getMethodCallCount);
        System.Assert.areEqual(mockValue, actualResult);
        System.Assert.isTrue(EMR_PlatformCacheManager.getSessionCache().contains(mockKey));
      }
    
      @IsTest
      static void it_gets_null_from_organization_cache_when_transaction_cache_miss_and_organization_platform_cache_is_available() {
        String mockKey = 'SomeKey';
        MockPlatformCachePartitionProxy mockOrganizationPartitionProxy = new MockPlatformCachePartitionProxy(true);
        mockOrganizationPartitionProxy.put(mockKey, EMR_PlatformCacheManager.PLATFORM_CACHE_NULL_VALUE, 3600, Cache.Visibility.ALL, false);
        System.Assert.isTrue(mockOrganizationPartitionProxy.isAvailable());
        EMR_PlatformCacheManager.setMockPartitionProxy(EMR_PlatformCacheManager.PlatformCacheType.ORGANIZATION, mockOrganizationPartitionProxy);
        System.Assert.areEqual(0, mockOrganizationPartitionProxy.containsMethodCallCount);
        System.Assert.isTrue(EMR_PlatformCacheManager.getOrganizationCache().contains(mockKey));
        System.Assert.areEqual(1, mockOrganizationPartitionProxy.containsMethodCallCount);
        System.Assert.areEqual(0, mockOrganizationPartitionProxy.getMethodCallCount);
    
        Object actualResult = EMR_PlatformCacheManager.getOrganizationCache().get(mockKey);
    
        System.Assert.areEqual(1, mockOrganizationPartitionProxy.getMethodCallCount);
        System.Assert.areEqual(null, actualResult);
        System.Assert.isTrue(EMR_PlatformCacheManager.getOrganizationCache().contains(mockKey));
      }
    
      @IsTest
      static void it_gets_null_from_session_cache_when_transaction_cache_miss_and_session_platform_cache_is_available() {
        String mockKey = 'SomeKey';
        MockPlatformCachePartitionProxy mockSessionPartitionProxy = new MockPlatformCachePartitionProxy(true);
        mockSessionPartitionProxy.put(mockKey, EMR_PlatformCacheManager.PLATFORM_CACHE_NULL_VALUE, 3600, Cache.Visibility.ALL, false);
        System.Assert.isTrue(mockSessionPartitionProxy.isAvailable());
        EMR_PlatformCacheManager.setMockPartitionProxy(EMR_PlatformCacheManager.PlatformCacheType.SESSION, mockSessionPartitionProxy);
        System.Assert.areEqual(0, mockSessionPartitionProxy.containsMethodCallCount);
        System.Assert.isTrue(EMR_PlatformCacheManager.getSessionCache().contains(mockKey));
        System.Assert.areEqual(1, mockSessionPartitionProxy.containsMethodCallCount);
        System.Assert.areEqual(0, mockSessionPartitionProxy.getMethodCallCount);
    
        Object actualResult = EMR_PlatformCacheManager.getSessionCache().get(mockKey);
    
        System.Assert.areEqual(1, mockSessionPartitionProxy.getMethodCallCount);
        System.Assert.areEqual(null, actualResult);
        System.Assert.isTrue(EMR_PlatformCacheManager.getSessionCache().contains(mockKey));
      }
    
    
      @IsTest
      static void it_adds_new_key_to_organization_cache_with_cachebuilder_when_organization_platform_cache_is_available() {
        String mockKey = 'SomeKey';
        System.Type cacheBuilderStubType = CacheBuilderStub.class;
        MockPlatformCachePartitionProxy mockOrganizationPartitionProxy = new MockPlatformCachePartitionProxy(true);
        System.Assert.isTrue(mockOrganizationPartitionProxy.isAvailable());
        EMR_PlatformCacheManager.setMockPartitionProxy(EMR_PlatformCacheManager.PlatformCacheType.ORGANIZATION, mockOrganizationPartitionProxy);
        System.Assert.areEqual(0, mockOrganizationPartitionProxy.containsMethodCallCount);
        System.Assert.isFalse(EMR_PlatformCacheManager.getOrganizationCache().contains(mockKey));
        System.Assert.areEqual(1, mockOrganizationPartitionProxy.containsMethodCallCount);
        System.Assert.areEqual(0, mockOrganizationPartitionProxy.getCacheBuilderMethodCallCount);
    
        Object generatedValue = EMR_PlatformCacheManager.getOrganizationCache().get(mockKey, cacheBuilderStubType);
    
        System.Assert.areEqual(1, mockOrganizationPartitionProxy.getCacheBuilderMethodCallCount);
        System.Assert.isTrue(mockOrganizationPartitionProxy.contains(mockKey));
        System.Assert.isNotNull(generatedValue);
    
        Object cachedValue = EMR_PlatformCacheManager.getOrganizationCache().get(mockKey, cacheBuilderStubType);
    
        System.Assert.isNotNull(cachedValue);
        System.Assert.areEqual(generatedValue, cachedValue);
        System.Assert.areEqual(2, mockOrganizationPartitionProxy.getCacheBuilderMethodCallCount);
        System.Assert.areEqual(cachedValue, mockOrganizationPartitionProxy.get(mockKey));
        System.Assert.isTrue(mockOrganizationPartitionProxy.contains(mockKey));
        System.Assert.isTrue(EMR_PlatformCacheManager.getOrganizationCache().contains(mockKey));
        System.Assert.areEqual(cachedValue, EMR_PlatformCacheManager.getOrganizationCache().get(mockKey));
      }
    
      @IsTest
      static void it_adds_configured_key_and_value_to_organization_cache_when_organization_platform_cache_is_available() {
        String mockKey = 'SomeKey';
        User mockValue = new User(Id = System.UserInfo.getUserId(), ProfileId = System.UserInfo.getProfileId());
        EMR_CacheValue__mdt configuredCacheValue = new EMR_CacheValue__mdt(
            EMR_Cache__c = EMR_PlatformCacheManager.ORGANIZATION_CACHE_CONFIGURATION.Id,
            EMR_DataType__c = Schema.User.class.getName(),
            EMR_IsEnabled__c = true,
            EMR_Key__c = mockKey,
            EMR_Value__c = JSON.serialize(mockValue)
        );
        EMR_PlatformCacheManager.CONFIGURED_CACHE_VALUES.add(configuredCacheValue);
        MockPlatformCachePartitionProxy mockOrganizationPartitionProxy = new MockPlatformCachePartitionProxy(true);
        System.Assert.isTrue(mockOrganizationPartitionProxy.isAvailable());
        EMR_PlatformCacheManager.setMockPartitionProxy(EMR_PlatformCacheManager.PlatformCacheType.ORGANIZATION, mockOrganizationPartitionProxy);
    
        System.Assert.isTrue(EMR_PlatformCacheManager.getOrganizationCache().contains(mockKey));
        Object returnedValue = EMR_PlatformCacheManager.getOrganizationCache().get(mockKey);
    
        System.Assert.areEqual(mockValue, returnedValue);
        System.Assert.isInstanceOfType(returnedValue, Schema.User.class);
        System.Assert.areEqual(mockValue, mockOrganizationPartitionProxy.get(mockKey));
        System.Assert.isTrue(EMR_PlatformCacheManager.getOrganizationCache().contains(mockKey));
        System.Assert.areEqual(mockValue, EMR_PlatformCacheManager.getOrganizationCache().get(mockKey));
      }
    
      @IsTest
      static void it_adds_configured_key_with_null_value_to_organization_cache_when_organization_platform_cache_is_available() {
        String mockKey = 'SomeKey';
        EMR_CacheValue__mdt configuredCacheValue = new EMR_CacheValue__mdt(
          EMR_Cache__c = EMR_PlatformCacheManager.ORGANIZATION_CACHE_CONFIGURATION.Id,
          EMR_DataType__c = String.class.getName(),
          EMR_IsEnabled__c = true,
          EMR_Key__c = mockKey,
          EMR_Value__c = null
        );
        EMR_PlatformCacheManager.CONFIGURED_CACHE_VALUES.add(configuredCacheValue);
        MockPlatformCachePartitionProxy mockOrganizationPartitionProxy = new MockPlatformCachePartitionProxy(true);
        System.Assert.isTrue(mockOrganizationPartitionProxy.isAvailable());
        EMR_PlatformCacheManager.setMockPartitionProxy(EMR_PlatformCacheManager.PlatformCacheType.ORGANIZATION, mockOrganizationPartitionProxy);
    
        Object returnedValue = EMR_PlatformCacheManager.getOrganizationCache().get(mockKey);
    
        System.Assert.areEqual(null, returnedValue);
        System.Assert.areEqual(EMR_PlatformCacheManager.PLATFORM_CACHE_NULL_VALUE, mockOrganizationPartitionProxy.get(mockKey));
        System.Assert.isTrue(EMR_PlatformCacheManager.getOrganizationCache().contains(mockKey));
        System.Assert.areEqual(null, EMR_PlatformCacheManager.getOrganizationCache().get(mockKey));
      }
    
      @IsTest
      static void it_adds_new_key_with_null_value_to_organization_cache_when_organization_platform_cache_is_available() {
        String mockKey = 'SomeKey';
        User mockValue = null;
        MockPlatformCachePartitionProxy mockOrganizationPartitionProxy = new MockPlatformCachePartitionProxy(true);
        System.Assert.isTrue(mockOrganizationPartitionProxy.isAvailable());
        EMR_PlatformCacheManager.setMockPartitionProxy(EMR_PlatformCacheManager.PlatformCacheType.ORGANIZATION, mockOrganizationPartitionProxy);
        System.Assert.areEqual(0, mockOrganizationPartitionProxy.containsMethodCallCount);
        System.Assert.isFalse(EMR_PlatformCacheManager.getOrganizationCache().contains(mockKey));
        System.Assert.areEqual(1, mockOrganizationPartitionProxy.containsMethodCallCount);
        System.Assert.areEqual(0, mockOrganizationPartitionProxy.putMethodCallCount);
    
        EMR_PlatformCacheManager.getOrganizationCache().put(mockKey, mockValue);
    
        System.Assert.areEqual(1, mockOrganizationPartitionProxy.putMethodCallCount);
        System.Assert.isTrue(mockOrganizationPartitionProxy.contains(mockKey));
        System.Assert.areEqual(EMR_PlatformCacheManager.PLATFORM_CACHE_NULL_VALUE, mockOrganizationPartitionProxy.get(mockKey));
        System.Assert.isTrue(EMR_PlatformCacheManager.getOrganizationCache().contains(mockKey));
        System.Assert.areEqual(mockValue, EMR_PlatformCacheManager.getOrganizationCache().get(mockKey));
      }
    
      @IsTest
      static void it_updates_value_for_existing_key_in_organization_cache_when_organization_platform_cache_is_available() {
        String mockKey = 'SomeKey';
        User oldMockValue = new User(Id = System.UserInfo.getUserId(), ProfileId = System.UserInfo.getProfileId());
        MockPlatformCachePartitionProxy mockOrganizationPartitionProxy = new MockPlatformCachePartitionProxy(true);
        System.Assert.isTrue(mockOrganizationPartitionProxy.isAvailable());
        EMR_PlatformCacheManager.setMockPartitionProxy(EMR_PlatformCacheManager.PlatformCacheType.ORGANIZATION, mockOrganizationPartitionProxy);
        System.Assert.areEqual(0, mockOrganizationPartitionProxy.putMethodCallCount);
        EMR_PlatformCacheManager.getOrganizationCache().put(mockKey, oldMockValue);
        System.Assert.areEqual(1, mockOrganizationPartitionProxy.putMethodCallCount);
        System.Assert.isTrue(EMR_PlatformCacheManager.getOrganizationCache().contains(mockKey));
        System.Assert.isTrue(mockOrganizationPartitionProxy.contains(mockKey));
        System.Assert.areEqual(oldMockValue, EMR_PlatformCacheManager.getOrganizationCache().get(mockKey));
        Account newMockValue = new Account(Name = 'Some fake account');
        System.Assert.areEqual(1, mockOrganizationPartitionProxy.putMethodCallCount);
    
        EMR_PlatformCacheManager.getOrganizationCache().put(mockKey, newMockValue);
    
        System.Assert.areEqual(2, mockOrganizationPartitionProxy.putMethodCallCount);
        System.Assert.isTrue(mockOrganizationPartitionProxy.contains(mockKey));
        System.Assert.areEqual(newMockValue, mockOrganizationPartitionProxy.get(mockKey));
        System.Assert.isTrue(EMR_PlatformCacheManager.getOrganizationCache().contains(mockKey));
        System.Assert.areEqual(newMockValue, EMR_PlatformCacheManager.getOrganizationCache().get(mockKey));
      }
    
      @IsTest
      static void it_removes_value_for_existing_key_in_organization_cache_when_organization_platform_cache_is_available() {
        String mockKey = 'SomeKey';
        User mockValue = new User(Id = System.UserInfo.getUserId(), ProfileId = System.UserInfo.getProfileId());
        MockPlatformCachePartitionProxy mockOrganizationPartitionProxy = new MockPlatformCachePartitionProxy(true);
        System.Assert.isTrue(mockOrganizationPartitionProxy.isAvailable());
        EMR_PlatformCacheManager.setMockPartitionProxy(EMR_PlatformCacheManager.PlatformCacheType.ORGANIZATION, mockOrganizationPartitionProxy);
        System.Assert.isFalse(EMR_PlatformCacheManager.getOrganizationCache().contains(mockKey));
        EMR_PlatformCacheManager.getOrganizationCache().put(mockKey, mockValue);
        System.Assert.isTrue(mockOrganizationPartitionProxy.contains(mockKey));
        System.Assert.areEqual(mockValue, mockOrganizationPartitionProxy.get(mockKey));
        System.Assert.isTrue(EMR_PlatformCacheManager.getOrganizationCache().contains(mockKey));
        System.Assert.areEqual(mockValue, EMR_PlatformCacheManager.getOrganizationCache().get(mockKey));
        System.Assert.areEqual(0, mockOrganizationPartitionProxy.removeMethodCallCount);
    
        EMR_PlatformCacheManager.getOrganizationCache().remove(mockKey);
    
        System.Assert.areEqual(1, mockOrganizationPartitionProxy.removeMethodCallCount);
        System.Assert.isFalse(mockOrganizationPartitionProxy.contains(mockKey));
        System.Assert.isFalse(EMR_PlatformCacheManager.getOrganizationCache().contains(mockKey));
      }
    
      @IsTest
      static void it_does_not_remove_value_for_existing_key_in_organization_cache_when_organization_platform_cache_is_immutable() {
        String mockKey = 'SomeKey';
        User mockValue = new User(Id = System.UserInfo.getUserId(), ProfileId = System.UserInfo.getProfileId());
        MockPlatformCachePartitionProxy mockOrganizationPartitionProxy = new MockPlatformCachePartitionProxy(true);
        System.Assert.isTrue(mockOrganizationPartitionProxy.isAvailable());
        EMR_PlatformCacheManager.setMockPartitionProxy(EMR_PlatformCacheManager.PlatformCacheType.ORGANIZATION, mockOrganizationPartitionProxy);
        System.Assert.isFalse(EMR_PlatformCacheManager.getOrganizationCache().contains(mockKey));
        EMR_PlatformCacheManager.getOrganizationCache().put(mockKey, mockValue);
        System.Assert.isTrue(mockOrganizationPartitionProxy.contains(mockKey));
        System.Assert.areEqual(mockValue, mockOrganizationPartitionProxy.get(mockKey));
        System.Assert.isTrue(EMR_PlatformCacheManager.getOrganizationCache().contains(mockKey));
        System.Assert.areEqual(mockValue, EMR_PlatformCacheManager.getOrganizationCache().get(mockKey));
        System.Assert.areEqual(0, mockOrganizationPartitionProxy.removeMethodCallCount);
        System.Assert.isFalse(EMR_PlatformCacheManager.getOrganizationCache().isImmutable());
        EMR_PlatformCacheManager.ORGANIZATION_CACHE_CONFIGURATION.EMR_IsImmutable__c = true;
        System.Assert.isTrue(EMR_PlatformCacheManager.getOrganizationCache().isImmutable());
    
        EMR_PlatformCacheManager.getOrganizationCache().remove(mockKey);
    
        System.Assert.areEqual(0, mockOrganizationPartitionProxy.removeMethodCallCount);
        System.Assert.isTrue(mockOrganizationPartitionProxy.contains(mockKey));
        System.Assert.isTrue(EMR_PlatformCacheManager.getOrganizationCache().contains(mockKey));
      }
    
      @IsTest
      static void it_supports_bulk_operations_in_organization_cache() {
        MockPlatformCachePartitionProxy mockOrganizationPartitionProxy = new MockPlatformCachePartitionProxy(true);
        System.Assert.isTrue(mockOrganizationPartitionProxy.isAvailable());
        EMR_PlatformCacheManager.setMockPartitionProxy(EMR_PlatformCacheManager.PlatformCacheType.ORGANIZATION, mockOrganizationPartitionProxy);
        System.Assert.isTrue(EMR_PlatformCacheManager.getOrganizationCache().isAvailable());
        Map<String, Object> keyToValue = new Map<String, Object>{
          'SomeDate' => Date.newInstance(1999, 9, 9),
          'SomeString' => 'hello, world',
          'SomeSObject' => new User(Id = System.UserInfo.getUserId())
        };
        System.Assert.isFalse(EMR_PlatformCacheManager.getOrganizationCache().containsAll(new Set<String>()));
        System.Assert.isFalse(EMR_PlatformCacheManager.getOrganizationCache().containsAll(keyToValue.keySet()));
        EMR_PlatformCacheManager.getOrganizationCache().put(keyToValue);
        for (String key : keyToValue.keySet()) {
          System.Assert.isTrue(EMR_PlatformCacheManager.getOrganizationCache().contains(key));
        }
        System.Assert.isFalse(EMR_PlatformCacheManager.getOrganizationCache().containsAll(new Set<String>()));
        Map<String, Boolean> keyToContainsResult = EMR_PlatformCacheManager.getOrganizationCache().contains(keyToValue.keySet());
        for (String key : keyToContainsResult.keySet()) {
          Boolean containsResult = keyToContainsResult.get(key);
          System.Assert.isTrue(EMR_PlatformCacheManager.getOrganizationCache().contains(key));
        }
        Map<String, Object> returnedKeyToValue = EMR_PlatformCacheManager.getOrganizationCache().getAll();
        System.Assert.areEqual(keyToValue, returnedKeyToValue);
        System.Assert.isFalse(EMR_PlatformCacheManager.getOrganizationCache().containsAll(keyToValue.keySet()), '' + EMR_PlatformCacheManager.getOrganizationCache().getKeys());
        EMR_PlatformCacheManager.getOrganizationCache().remove(keyToValue.keySet());
        System.Assert.isFalse(EMR_PlatformCacheManager.getOrganizationCache().containsAll(keyToValue.keySet()));
      }
    
      @IsTest
      static void it_remove_alls_keys_in_organization_cache_when_remove_all_method_is_called() {
        MockPlatformCachePartitionProxy mockOrganizationPartitionProxy = new MockPlatformCachePartitionProxy(true);
        System.Assert.isTrue(mockOrganizationPartitionProxy.isAvailable());
        EMR_PlatformCacheManager.setMockPartitionProxy(EMR_PlatformCacheManager.PlatformCacheType.ORGANIZATION, mockOrganizationPartitionProxy);
        System.Assert.isTrue(EMR_PlatformCacheManager.getOrganizationCache().isAvailable());
        Map<String, Object> keyToValue = new Map<String, Object>{
          'SomeDate' => Date.newInstance(2999, 9, 9),
          'SomeString' => 'hello, world',
          'SomeSObject' => new User(Id = System.UserInfo.getUserId())
        };
        EMR_PlatformCacheManager.getOrganizationCache().put(keyToValue);
        System.Assert.areEqual(keyToValue.keySet(), EMR_PlatformCacheManager.getOrganizationCache().getKeys());
        
        EMR_PlatformCacheManager.getOrganizationCache().contains(keyToValue.keySet());

        EMR_PlatformCacheManager.getOrganizationCache().containsAll(keyToValue.keySet());

        EMR_PlatformCacheManager.getOrganizationCache().removeAll();
    
        System.Assert.isTrue(EMR_PlatformCacheManager.getOrganizationCache().getKeys().isEmpty());
      }
    
      @IsTest
      static void it_adds_new_key_to_session_cache_with_cachebuilder_when_session_platform_cache_is_available() {
        String mockKey = 'SomeKey';
        System.Type cacheBuilderStubType = CacheBuilderStub.class;
        MockPlatformCachePartitionProxy mockSessionPartitionProxy = new MockPlatformCachePartitionProxy(true);
        System.Assert.isTrue(mockSessionPartitionProxy.isAvailable());
        EMR_PlatformCacheManager.setMockPartitionProxy(EMR_PlatformCacheManager.PlatformCacheType.SESSION, mockSessionPartitionProxy);
        System.Assert.areEqual(0, mockSessionPartitionProxy.containsMethodCallCount);
        System.Assert.isFalse(EMR_PlatformCacheManager.getSessionCache().contains(mockKey));
        System.Assert.areEqual(1, mockSessionPartitionProxy.containsMethodCallCount);
        System.Assert.areEqual(0, mockSessionPartitionProxy.getCacheBuilderMethodCallCount);
    
        Object generatedValue = EMR_PlatformCacheManager.getSessionCache().get(mockKey, cacheBuilderStubType);
    
        System.Assert.areEqual(1, mockSessionPartitionProxy.getCacheBuilderMethodCallCount);
        System.Assert.isTrue(mockSessionPartitionProxy.contains(mockKey));
        System.Assert.isNotNull(generatedValue);
    
        Object cachedValue = EMR_PlatformCacheManager.getSessionCache().get(mockKey, cacheBuilderStubType);
    
        System.Assert.isNotNull(cachedValue);
        System.Assert.areEqual(generatedValue, cachedValue);
        System.Assert.areEqual(2, mockSessionPartitionProxy.getCacheBuilderMethodCallCount);
        System.Assert.areEqual(cachedValue, mockSessionPartitionProxy.get(mockKey));
        System.Assert.isTrue(mockSessionPartitionProxy.contains(mockKey));
        System.Assert.isTrue(EMR_PlatformCacheManager.getSessionCache().contains(mockKey));
        System.Assert.areEqual(cachedValue, EMR_PlatformCacheManager.getSessionCache().get(mockKey));
      }
    
      @IsTest
      static void it_adds_new_key_to_session_cache_when_session_platform_cache_is_available() {
        String mockKey = 'SomeKey';
        User mockValue = new User(Id = System.UserInfo.getUserId(), ProfileId = System.UserInfo.getProfileId());
        MockPlatformCachePartitionProxy mockSessionPartitionProxy = new MockPlatformCachePartitionProxy(true);
        System.Assert.isTrue(mockSessionPartitionProxy.isAvailable());
        EMR_PlatformCacheManager.setMockPartitionProxy(EMR_PlatformCacheManager.PlatformCacheType.SESSION, mockSessionPartitionProxy);
        System.Assert.areEqual(0, mockSessionPartitionProxy.containsMethodCallCount);
        System.Assert.isFalse(EMR_PlatformCacheManager.getSessionCache().contains(mockKey));
        System.Assert.areEqual(1, mockSessionPartitionProxy.containsMethodCallCount);
        System.Assert.areEqual(0, mockSessionPartitionProxy.putMethodCallCount);
    
        EMR_PlatformCacheManager.getSessionCache().put(mockKey, mockValue);
    
        System.Assert.areEqual(1, mockSessionPartitionProxy.putMethodCallCount);
        System.Assert.isTrue(mockSessionPartitionProxy.contains(mockKey));
        System.Assert.areEqual(mockValue, mockSessionPartitionProxy.get(mockKey));
        System.Assert.isTrue(EMR_PlatformCacheManager.getSessionCache().contains(mockKey));
        System.Assert.areEqual(mockValue, EMR_PlatformCacheManager.getSessionCache().get(mockKey));
      }
    
      @IsTest
      static void it_adds_configured_key_and_value_to_session_cache_when_session_platform_cache_is_available() {
        String mockKey = 'SomeKey';
        User mockValue = new User(Id = System.UserInfo.getUserId(), ProfileId = System.UserInfo.getProfileId());
        EMR_CacheValue__mdt configuredCacheValue = new EMR_CacheValue__mdt(
            EMR_Cache__c = EMR_PlatformCacheManager.SESSION_CACHE_CONFIGURATION.Id,
            EMR_DataType__c = Schema.User.class.getName(),
            EMR_IsEnabled__c = true,
            EMR_Key__c = mockKey,
            EMR_Value__c = JSON.serialize(mockValue)
        );
        EMR_PlatformCacheManager.CONFIGURED_CACHE_VALUES.add(configuredCacheValue);
        MockPlatformCachePartitionProxy mockSessionPartitionProxy = new MockPlatformCachePartitionProxy(true);
        System.Assert.isTrue(mockSessionPartitionProxy.isAvailable());
        EMR_PlatformCacheManager.setMockPartitionProxy(EMR_PlatformCacheManager.PlatformCacheType.SESSION, mockSessionPartitionProxy);
    
        System.Assert.isTrue(EMR_PlatformCacheManager.getSessionCache().contains(mockKey));
        Object returnedValue = EMR_PlatformCacheManager.getSessionCache().get(mockKey);
    
        System.Assert.areEqual(mockValue, returnedValue);
        System.Assert.isInstanceOfType(returnedValue, Schema.User.class);
        System.Assert.areEqual(mockValue, mockSessionPartitionProxy.get(mockKey));
        System.Assert.isTrue(EMR_PlatformCacheManager.getSessionCache().contains(mockKey));
        System.Assert.areEqual(mockValue, EMR_PlatformCacheManager.getSessionCache().get(mockKey));
      }
    
      @IsTest
      static void it_adds_configured_key_with_null_value_to_session_cache_when_session_platform_cache_is_available() {
        String mockKey = 'SomeKey';
        EMR_CacheValue__mdt configuredCacheValue = new EMR_CacheValue__mdt(
          EMR_Cache__c = EMR_PlatformCacheManager.SESSION_CACHE_CONFIGURATION.Id,
          EMR_DataType__c = String.class.getName(),
          EMR_IsEnabled__c = true,
          EMR_Key__c = mockKey,
          EMR_Value__c = null
        );
        EMR_PlatformCacheManager.CONFIGURED_CACHE_VALUES.add(configuredCacheValue);
        MockPlatformCachePartitionProxy mockSessionPartitionProxy = new MockPlatformCachePartitionProxy(true);
        System.Assert.isTrue(mockSessionPartitionProxy.isAvailable());
        EMR_PlatformCacheManager.setMockPartitionProxy(EMR_PlatformCacheManager.PlatformCacheType.SESSION, mockSessionPartitionProxy);
    
        Object returnedValue = EMR_PlatformCacheManager.getSessionCache().get(mockKey);
    
        System.Assert.areEqual(null, returnedValue);
        System.Assert.areEqual(EMR_PlatformCacheManager.PLATFORM_CACHE_NULL_VALUE, mockSessionPartitionProxy.get(mockKey));
        System.Assert.isTrue(EMR_PlatformCacheManager.getSessionCache().contains(mockKey));
        System.Assert.areEqual(null, EMR_PlatformCacheManager.getSessionCache().get(mockKey));
      }
    
      @IsTest
      static void it_adds_new_key_with_null_value_to_session_cache_when_session_platform_cache_is_available() {
        String mockKey = 'SomeKey';
        User mockValue = null;
        MockPlatformCachePartitionProxy mockSessionPartitionProxy = new MockPlatformCachePartitionProxy(true);
        System.Assert.isTrue(mockSessionPartitionProxy.isAvailable());
        EMR_PlatformCacheManager.setMockPartitionProxy(EMR_PlatformCacheManager.PlatformCacheType.SESSION, mockSessionPartitionProxy);
        System.Assert.areEqual(0, mockSessionPartitionProxy.containsMethodCallCount);
        System.Assert.isFalse(EMR_PlatformCacheManager.getSessionCache().contains(mockKey));
        System.Assert.areEqual(1, mockSessionPartitionProxy.containsMethodCallCount);
        System.Assert.areEqual(0, mockSessionPartitionProxy.putMethodCallCount);
    
        EMR_PlatformCacheManager.getSessionCache().put(mockKey, mockValue);
    
        System.Assert.areEqual(1, mockSessionPartitionProxy.putMethodCallCount);
        System.Assert.isTrue(mockSessionPartitionProxy.contains(mockKey));
        System.Assert.areEqual(EMR_PlatformCacheManager.PLATFORM_CACHE_NULL_VALUE, mockSessionPartitionProxy.get(mockKey));
        System.Assert.isTrue(EMR_PlatformCacheManager.getSessionCache().contains(mockKey));
        System.Assert.areEqual(mockValue, EMR_PlatformCacheManager.getSessionCache().get(mockKey));
      }
    
      @IsTest
      static void it_updates_value_for_existing_key_in_session_cache_when_session_platform_cache_is_available() {
        String mockKey = 'SomeKey';
        User oldMockValue = new User(Id = System.UserInfo.getUserId(), ProfileId = System.UserInfo.getProfileId());
        MockPlatformCachePartitionProxy mockSessionPartitionProxy = new MockPlatformCachePartitionProxy(true);
        System.Assert.isTrue(mockSessionPartitionProxy.isAvailable());
        EMR_PlatformCacheManager.setMockPartitionProxy(EMR_PlatformCacheManager.PlatformCacheType.SESSION, mockSessionPartitionProxy);
        System.Assert.areEqual(0, mockSessionPartitionProxy.putMethodCallCount);
        EMR_PlatformCacheManager.getSessionCache().put(mockKey, oldMockValue);
        System.Assert.areEqual(1, mockSessionPartitionProxy.putMethodCallCount);
        System.Assert.isTrue(EMR_PlatformCacheManager.getSessionCache().contains(mockKey));
        System.Assert.isTrue(mockSessionPartitionProxy.contains(mockKey));
        System.Assert.areEqual(oldMockValue, EMR_PlatformCacheManager.getSessionCache().get(mockKey));
        Account newMockValue = new Account(Name = 'Some fake account');
        System.Assert.areEqual(1, mockSessionPartitionProxy.putMethodCallCount);
    
        EMR_PlatformCacheManager.getSessionCache().put(mockKey, newMockValue);
    
        System.Assert.areEqual(2, mockSessionPartitionProxy.putMethodCallCount);
        System.Assert.isTrue(mockSessionPartitionProxy.contains(mockKey));
        System.Assert.areEqual(newMockValue, mockSessionPartitionProxy.get(mockKey));
        System.Assert.isTrue(EMR_PlatformCacheManager.getSessionCache().contains(mockKey));
        System.Assert.areEqual(newMockValue, EMR_PlatformCacheManager.getSessionCache().get(mockKey));
      }
    
      @IsTest
      static void it_removes_value_for_existing_key_in_session_cache_when_session_platform_cache_is_available() {
        String mockKey = 'SomeKey';
        User mockValue = new User(Id = System.UserInfo.getUserId(), ProfileId = System.UserInfo.getProfileId());
        MockPlatformCachePartitionProxy mockSessionPartitionProxy = new MockPlatformCachePartitionProxy(true);
        System.Assert.isTrue(mockSessionPartitionProxy.isAvailable());
        EMR_PlatformCacheManager.setMockPartitionProxy(EMR_PlatformCacheManager.PlatformCacheType.SESSION, mockSessionPartitionProxy);
        System.Assert.isFalse(EMR_PlatformCacheManager.getSessionCache().contains(mockKey));
        EMR_PlatformCacheManager.getSessionCache().put(mockKey, mockValue);
        System.Assert.isTrue(mockSessionPartitionProxy.contains(mockKey));
        System.Assert.areEqual(mockValue, mockSessionPartitionProxy.get(mockKey));
        System.Assert.isTrue(EMR_PlatformCacheManager.getSessionCache().contains(mockKey));
        System.Assert.areEqual(mockValue, EMR_PlatformCacheManager.getSessionCache().get(mockKey));
        System.Assert.areEqual(0, mockSessionPartitionProxy.removeMethodCallCount);
    
        EMR_PlatformCacheManager.getSessionCache().remove(mockKey);
    
        System.Assert.areEqual(1, mockSessionPartitionProxy.removeMethodCallCount);
        System.Assert.isFalse(mockSessionPartitionProxy.contains(mockKey));
        System.Assert.isFalse(EMR_PlatformCacheManager.getSessionCache().contains(mockKey));
      }
    
      @IsTest
      static void it_does_not_remove_value_for_existing_key_in_session_cache_when_session_platform_cache_is_immutable() {
        String mockKey = 'SomeKey';
        User mockValue = new User(Id = System.UserInfo.getUserId(), ProfileId = System.UserInfo.getProfileId());
        MockPlatformCachePartitionProxy mockSessionPartitionProxy = new MockPlatformCachePartitionProxy(true);
        System.Assert.isTrue(mockSessionPartitionProxy.isAvailable());
        EMR_PlatformCacheManager.setMockPartitionProxy(EMR_PlatformCacheManager.PlatformCacheType.SESSION, mockSessionPartitionProxy);
        System.Assert.isFalse(EMR_PlatformCacheManager.getSessionCache().contains(mockKey));
        EMR_PlatformCacheManager.getSessionCache().put(mockKey, mockValue);
        System.Assert.isTrue(mockSessionPartitionProxy.contains(mockKey));
        System.Assert.areEqual(mockValue, mockSessionPartitionProxy.get(mockKey));
        System.Assert.isTrue(EMR_PlatformCacheManager.getSessionCache().contains(mockKey));
        System.Assert.areEqual(mockValue, EMR_PlatformCacheManager.getSessionCache().get(mockKey));
        System.Assert.areEqual(0, mockSessionPartitionProxy.removeMethodCallCount);
        System.Assert.isFalse(EMR_PlatformCacheManager.getSessionCache().isImmutable());
        EMR_PlatformCacheManager.SESSION_CACHE_CONFIGURATION.EMR_IsImmutable__c = true;
        System.Assert.isTrue(EMR_PlatformCacheManager.getSessionCache().isImmutable());
    
        EMR_PlatformCacheManager.getSessionCache().remove(mockKey);
    
        System.Assert.areEqual(0, mockSessionPartitionProxy.removeMethodCallCount);
        System.Assert.isTrue(mockSessionPartitionProxy.contains(mockKey));
        System.Assert.isTrue(EMR_PlatformCacheManager.getSessionCache().contains(mockKey));
      }
    
    
      @IsTest
      static void it_remove_alls_keys_in_session_cache_when_remove_all_method_is_called() {
        MockPlatformCachePartitionProxy mockSessionPartitionProxy = new MockPlatformCachePartitionProxy(true);
        System.Assert.isTrue(mockSessionPartitionProxy.isAvailable());
        EMR_PlatformCacheManager.setMockPartitionProxy(EMR_PlatformCacheManager.PlatformCacheType.SESSION, mockSessionPartitionProxy);
        System.Assert.isTrue(EMR_PlatformCacheManager.getSessionCache().isAvailable());
        Map<String, Object> keyToValue = new Map<String, Object>{
          'SomeDate' => Date.newInstance(1999, 9, 9),
          'SomeString' => 'hello, world',
          'SomeSObject' => new User(Id = System.UserInfo.getUserId())
        };
        EMR_PlatformCacheManager.getSessionCache().put(keyToValue);
        System.Assert.areEqual(keyToValue.keySet(), EMR_PlatformCacheManager.getSessionCache().getKeys());
    
        EMR_PlatformCacheManager.getSessionCache().removeAll();
    
        System.Assert.isTrue(EMR_PlatformCacheManager.getSessionCache().getKeys().isEmpty());
      }
    
      @IsTest
      static void it_does_not_impact_other_caches_when_organization_cache_is_updated() {
        String key = 'SomeKey';
        Object value = System.now();

        MockPlatformCachePartitionProxy mockSessionPartitionProxy = new MockPlatformCachePartitionProxy(true);
        System.Assert.isTrue(mockSessionPartitionProxy.isAvailable());
        EMR_PlatformCacheManager.setMockPartitionProxy(EMR_PlatformCacheManager.PlatformCacheType.ORGANIZATION, mockSessionPartitionProxy);

        System.Assert.isFalse(EMR_PlatformCacheManager.getOrganizationCache().contains(key));
        System.Assert.isFalse(EMR_PlatformCacheManager.getSessionCache().contains(key));
    
        EMR_PlatformCacheManager.getOrganizationCache().put(key, value);
    
        System.Assert.isTrue(EMR_PlatformCacheManager.getOrganizationCache().contains(key));
        System.Assert.areEqual(value, EMR_PlatformCacheManager.getOrganizationCache().get(key));
        System.Assert.isFalse(EMR_PlatformCacheManager.getSessionCache().contains(key));
      }
    
      @IsTest
      static void it_does_not_impact_other_caches_when_session_cache_is_updated() {
        String key = 'SomeKey';
        Object value = System.now();

        MockPlatformCachePartitionProxy mockSessionPartitionProxy = new MockPlatformCachePartitionProxy(true);
        System.Assert.isTrue(mockSessionPartitionProxy.isAvailable());
        EMR_PlatformCacheManager.setMockPartitionProxy(EMR_PlatformCacheManager.PlatformCacheType.SESSION, mockSessionPartitionProxy);

        System.Assert.isFalse(EMR_PlatformCacheManager.getSessionCache().contains(key));
        System.Assert.isFalse(EMR_PlatformCacheManager.getOrganizationCache().contains(key));
    
        EMR_PlatformCacheManager.getSessionCache().put(key, value);
    
        System.Assert.isTrue(EMR_PlatformCacheManager.getSessionCache().contains(key));
        System.Assert.areEqual(value, EMR_PlatformCacheManager.getSessionCache().get(key));
        System.Assert.isFalse(EMR_PlatformCacheManager.getOrganizationCache().contains(key));
      }
    
      @IsTest
      static void validateKey_does_not_throw_when_called_with_number() {
        try {
          for (Integer i = 0; i < 50; ++i) {
            EMR_PlatformCacheManager.validateKey('' + i);
          }
          System.Assert.isTrue(true);
        } catch (IllegalArgumentException ex) {
          System.Assert.fail();
        }
      }
    
      @IsTest
      static void validateKey_does_not_throw_when_called_with_letters() {
        String alphabet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
        try {
          for (String key : alphabet.split('')) {
            EMR_PlatformCacheManager.validateKey(key);
          }
          System.Assert.isTrue(true);
        } catch (IllegalArgumentException ex) {
          System.Assert.fail();
        }
      }
    
      @IsTest
      static void validateKey_throws_when_called_with_not_letters_nor_numbers() {
        String otherChars = 'ù%`$€"\'(§!)-&@"#éèàç*¨ %£+/=.?,\\';
    
        for (String key : otherChars.split('')) {
          try {
            EMR_PlatformCacheManager.validateKey(key);
            System.Assert.fail();
          } catch (Exception ex) {
            System.Assert.isInstanceOfType(ex, IllegalArgumentException.class);
          }
        }
      }
    
      @IsTest
      static void validateKey_throws_when_called_with_not_letters_nor_numbers_and_letter_numbers() {
        List<String> phrase = new List<String>{ 'I throw !!', 'I throw 2 times for sure!!', 'No, you throw' };
    
        for (String key : phrase) {
          try {
            EMR_PlatformCacheManager.validateKey(key);
            System.Assert.fail();
          } catch (Exception ex) {
            System.Assert.isInstanceOfType(ex, IllegalArgumentException.class);
          }
        }
      }
    
      // Since the class `Cache.Partition` can't have be mocked & can't have its methods overridden,
      // the `EMR_PlatformCacheManager` class internally uses a proxy to help abstract out the usage of the partition,
      // which lets us mock the proxy within (true) unit tests.
      private class MockPlatformCachePartitionProxy extends EMR_PlatformCacheManager.PlatformCachePartitionProxy {
        private final Boolean isAvailable;
        // Since `Cache.Partition` can't be mocked, this mock proxy uses a map as a substitute
        private final Map<String, Object> keyToValue = new Map<String, Object>();
    
        public Integer isAvailableMethodCallCount = 0;
        public Integer containsMethodCallCount = 0;
        public Integer getMethodCallCount = 0;
        public Integer getCacheBuilderMethodCallCount = 0;
        public Integer putMethodCallCount = 0;
        public Integer removeMethodCallCount = 0;
    
        private MockPlatformCachePartitionProxy(Boolean isAvailable) {
          super(null, null);
          this.isAvailable = isAvailable;
        }
    
        public override Boolean isAvailable() {
          this.isAvailableMethodCallCount++;
          return this.isAvailable;
        }
    
        public override Boolean contains(String key) {
          this.containsMethodCallCount++;
          return this.keyToValue.containsKey(key);
        }
    
        public override Object get(String key) {
          this.getMethodCallCount++;
          return this.keyToValue.get(key);
        }

        public override Map<String, Object> get(Set<String> keys) {
          Map<String, Object> valuesToReturn = new Map<String, Object>();
          for(string key:  keyToValue.keySet()){
            if(keys.contains(key)){
              valuesToReturn.put(key, keyToValue.get(key));
            }
          }
          return valuesToReturn;
        }

        public override Set<String> getKeys() {
          return this.keyToValue.keySet();
        }
    
        public override Object get(String key, System.Type cacheBuilderClass) {
          this.getCacheBuilderMethodCallCount++;
          if (this.keyToValue.containsKey(key) == false) {
            Cache.CacheBuilder cacheBuilder = (Cache.CacheBuilder) cacheBuilderClass.newInstance();
            Object value = cacheBuilder.doLoad(key);
            this.keyToValue.put(key, value);
          }
          return this.keyToValue.get(key);
        }
    
        @SuppressWarnings('PMD.ExcessiveParameterList')
        public override void put(String key, Object value, Integer cacheTtlSeconds, Cache.Visibility cacheVisiblity, Boolean isCacheImmutable) {
          this.putMethodCallCount++;
          this.keyToValue.put(key, value);
        }
    
        public override void remove(String key) {
          this.removeMethodCallCount++;
          this.keyToValue.remove(key);
        }
      }
    
      private class CacheBuilderStub implements Cache.CacheBuilder {
        public Object doLoad(String key) {
          User mockValue = new User(Id = System.UserInfo.getUserId(), ProfileId = System.UserInfo.getProfileId());
          return mockValue;
        }
      }
    }