/**
* @author          : Aditya Anand
* @description     : This is the wrapper class for add to cart
*/
public with sharing class EC_AddToCartWrapper {
    public class CartItemsDetails {       
        @AuraEnabled public String accountId{get;set;}
        @AuraEnabled public String storeName {get;set;}
        @AuraEnabled public String productExtId {get; set;}
        @AuraEnabled public String productQuantity {get; set;}
    }
}