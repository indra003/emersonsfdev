/**
* Test Data Factory Class
* @description  : This Class will be used by other test classes to create test data
* @Author       : Aditya Anand

*/

public with sharing class EMR_TestDataFactory {

    /**
    * @description      : This method remoces the specialcharacters from the string parameter  
    * @param    recNumber     
    * @return   List of Accounts  
    */  
   
    public static List<Account> massCreateAccounts(Integer recNumber) {
        
        List<Account> accountsToAdd = new List<Account>();
        for(Integer temp=0; temp < recNumber; temp++){
            Account acc  = new Account();
            acc.Name = 'New Account' +temp;
            acc.BillingStreet = '3022 Strother Street';
            acc.BillingCity = 'Into';
            acc.BillingState = 'Alabama';
            acc.BillingPostalCode = '35222';
            acc.BillingCountry = 'United States';
            accountsToAdd.add(acc);
        }
        return accountsToAdd;
    }
}