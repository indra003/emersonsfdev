/**
* @author          : Aditya Anand
* @description     : This class is used for creation and updation of cart 
*/

public with sharing class EC_AddToCart {
    
    /**
     *  @author : Aditya Anand
     *  @description : This method is used to create a cart
     *  @param  effectiveAccountId
     *  @param  storeName
     *  @return ConnectApi.CartSummary
     */

     public static ConnectApi.CartSummary createCart(String effectiveAccountId, String storeName){
        ConnectApi.CartSummary cartSummary;
        try{
            String webstoreId = EMR_Utility.getWebStoreId(storeName);	
            ConnectApi.CartInput cartInput = new ConnectApi.CartInput();
            cartInput.effectiveAccountId = effectiveAccountId;
            cartSummary = ConnectApi.CommerceCart.createCart(webstoreId, cartInput);
        } catch (Exception e) {
            Logger.error('Error occured in creating a cart :: '+ e.getMessage() + e.getStackTraceString());
            Logger.saveLog();
        } 
        
        return cartSummary;
     }

     /**
     *  @author : Aditya Anand
     *  @description : This method is used to fetch active cart Id
     *  @param  effectiveAccountId
     *  @param  storeName
     *  @return WebCart
     */
     public static List<WebCart> getActiveCartByAccountId(String effectiveAccountId, String storeName) {
        List<WebCart> existingActiveCart = new List<WebCart>();
        try{
            if (Schema.sObjectType.WebCart.isAccessible()) {
                existingActiveCart = [  SELECT Id FROM WebCart 
                                        WHERE AccountId = :effectiveAccountId
                                        AND Status IN ('Active', 'Checkout') AND OwnerId = :UserInfo.getUserId() 
                                        LIMIT 1];
            }
            System.debug('@@@--->'+existingActiveCart);
        }catch (Exception e) {
            Logger.error('Error occured in getActiveCartByAccountId :: '+ e.getMessage() + e.getStackTraceString());
            Logger.saveLog();
        } 
        
        return  existingActiveCart;          
    }
    /**
     *  @author : Aditya Anand
     *  @description : This method is used to add item to cart
     *  @param  effectiveAccountId
     *  @param  webstoreId
     *  @param  activeCartOrId
     *  @param  cartItemInput
     *  @param  currencyIsoCode
     *  @return WebCart
     */
    public static ConnectApi.CartItem addItemToCart(
            String webstoreId, 
            String effectiveAccountId, 
            String activeCartOrId, 
            ConnectApi.CartItemInput cartItemInput, 
            String currencyIsoCode)
    {
        ConnectApi.CartItem cartItem;
        try{
            cartItem = ConnectApi.CommerceCart.addItemTocart(webstoreId, effectiveAccountId, activeCartOrId, cartItemInput, currencyIsoCode);
        } catch (Exception e) {
            Logger.error('Error occured in addItemToCart :: '+ e.getMessage() + e.getStackTraceString());
            Logger.saveLog();
        }
        return cartItem;
    }
}