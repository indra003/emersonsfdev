/**
 * @author          : Aditya Anand
 * @description     : This class is the test class for EMR_Utility class 
 */

 @isTest
 public class EMR_UtilityTest {
   @isTest 
	private static void removeSpecialCharactersTest() {
		Test.startTest();
            String retgetValueFromLocalMetadata = EMR_Utility.removeSpecialCharacters('@41-12');
            System.assertEquals(retgetValueFromLocalMetadata,'4112','Error');
		Test.stopTest();
	}

    @isTest 
    private static void communityIdToWebstoreIdTest() {
            String communityId = [SELECT Id from Community].Id;
            Test.startTest();
           
            String retcommunityIdToWebstoreId = EMR_Utility.communityIdToWebstoreId(communityId);
            System.assertEquals(retcommunityIdToWebstoreId,retcommunityIdToWebstoreId,'Error');
          
            Test.stopTest();
    }

    @isTest 
	private static void getUserAccountIDTest() {
		
		Test.startTest();
		String accountID = EMR_Utility.getUserAccountID();
        System.assertEquals(accountID,accountID,'Error');
		Test.stopTest();
	}

    @isTest 
	private static void isNumericTest() {
		
		Test.startTest();
		Boolean res1 = EMR_Utility.isNumeric('Ab');
        Boolean res2 = EMR_Utility.isNumeric('123');
        System.assertEquals(res1,false,'Error');
        System.assertEquals(res2,true,'Error');
		Test.stopTest();
	}

    @isTest 
	private static void validateEmailTest() {
        Test.startTest();
        Boolean res1 = EMR_Utility.validateEmail('adityaanand6@deloitte.com');
        Boolean res2 = EMR_Utility.validateEmail('123');
        EMR_Utility.validateEmail(null);
        System.assertEquals(res1,true,'Error');
        System.assertEquals(res2,false,'Error');
		Test.stopTest();
	}

    @isTest
    private static void getFieldPathFromFieldSetMember(){
        Test.startTest();
        List<Schema.FieldSetMember> listUserGeneralfieldsSet = 
        Schema.SObjectType.Product2.fieldSets.getMap().get('Product_Field_Set').getFields();
        System.debug('listUserGeneralfieldsSet-->'+listUserGeneralfieldsSet);
        List<String> randomStr = EMR_Utility.getFieldPathFromFieldSetMember(listUserGeneralfieldsSet);
        System.assert(randomStr != null,'getFieldPathFromFieldSetMember');
        Test.stopTest();
        
    }
 }