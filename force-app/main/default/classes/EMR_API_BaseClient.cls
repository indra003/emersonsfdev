/**
* @author       : Dhara Desai    
* @description  : API Base Client for access token
* *************************************************
* <runTest>EMR_API_BaseClient_Test<runTest>
* *************************************************
* @History
* -------
* VERSION | AUTHOR          | DATE
| UserStory    
* 1.0     | Dhara Desai     | Feb 05, 2023   
*/
public class EMR_API_BaseClient extends EMR_API.ApiClient {

    public EMR_API_Setting__mdt apiSetting;

    public EMR_API_BaseClient() {
        basePath = '';
        calloutName = '';
    }

    /**
     * constructor for the SC_API_BaseClient class
     * @param apiType - the specific api type to establish the base client for, example: Core Security API for Invoices
    */
    public EMR_API_BaseClient(EMR_API_Type apiType, String callOutName) {
       List<EMR_API_Setting__mdt> apiSettingList = [SELECT EMR_API_AccessToken__c, EMR_API_BaseURL__c, EMR_API_ResourceURL__c, EMR_API_URLPath__c,  EMR_API_ClientId__c, EMR_API_ClientSecret__c,EMR_API_Version__c  FROM EMR_API_Setting__mdt WHERE DeveloperName =: String.valueOf(apiType)];
        this.calloutName = callOutName;

        if(apiSettingList.size() > 0){
            this.apiSetting = apiSettingList[0];
        }
        else {
            this.apiSetting = null;
        }
    }
        /**
     * constructor for the SC_API_BaseClient class
     * @param apiType - the specific api type to establish the base client for, example: Core Security API for Invoices
    */
    public EMR_API_BaseClient(String apiType, String callOutName) {
        List<EMR_API_Setting__mdt> apiSettingList = [SELECT EMR_API_AccessToken__c, EMR_API_BaseURL__c, EMR_API_ResourceURL__c, EMR_API_URLPath__c, EMR_API_ClientId__c, EMR_API_ClientSecret__c ,EMR_API_Version__c FROM EMR_API_Setting__mdt WHERE DeveloperName =: apiType];
        this.calloutName = callOutName;

        if(apiSettingList.size() > 0){
            this.apiSetting = apiSettingList[0];
        }
        else {
            this.apiSetting = null;
        }
    }
}