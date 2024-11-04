/**
* Apex Test Class for the EMR_API_BaseClient
* @CreatedDate: January 19, 2023
* @Author: Pranay Mistry - Deloitte Digital
* @Modified:
* @JIRA:
*/
@isTest
private class EMR_API_BaseClient_Test {

    @isTest
    private static void testBaseClientConstructor(){
		EMR_API_BaseClient baseClient;
		Test.startTest();
		baseClient = new EMR_API_BaseClient();
		Test.stopTest();		
		System.assert(baseClient.apiSetting == null, 'No API Settings for defaul Constructor');
	}

	@isTest
	private static void testBaseClientArgumentConstructor(){
		EMR_API_BaseClient baseClient;
		Test.startTest();
		//baseClient = new EMR_API_BaseClient(EMR_API_Type.SC_GoogleAutocompleteAPI, 'Core_Security_API_Invoices');
		Test.stopTest();		
		//System.assert(baseClient.apiSetting != null, 'API Settings should be there');
	}

	@isTest
	private static void testBaseClientArgumentConstructorNoAPISettings(){
		EMR_API_BaseClient baseClient;
		Test.startTest();
		baseClient = new EMR_API_BaseClient('', '');
		Test.stopTest();		
		System.assert(baseClient.apiSetting == null, 'No API Settings should be there');
	}
    
    @isTest
	private static void testBaseClientArgumentConstructorNoAPISettings2(){
		EMR_API_BaseClient baseClient;
		Test.startTest();
		baseClient = new EMR_API_BaseClient(EMR_API_Type.EMR_SampleEndPoint,'Sample');
		Test.stopTest();		
		System.assert(baseClient.apiSetting == null, 'No API Settings should be there');
	}
}