/**
* @author          : Aditya Anand
* @description     : This class is used for creation and updation of cart from helper class
*/
@RestResource(urlMapping='/addToCart/*')
global with sharing class EC_AddToCartCtrl {
    
    /**
     *  @author : Aditya Anand
     *  @description : This method is used to create a cart
     *  @param  request
     *  @return List<String>
     */
    @HttpPost
    global static void addToCart(EC_AddToCartWrapper addToCartWrapper){
        List<String> result = new List<String>();
        try{
            //EC_AddToCartWrapper addToCartWrapper = (EC_AddToCartWrapper) JSON.deserialize(addToCartRequest, EC_AddToCartWrapper.class);
            String webstoreId;
            webstoreId = EMR_Utility.getWebStoreId(addToCartWrapper.storeName);
            List<WebCart> activeCartId = new List<WebCart>();
            activeCartId = EC_AddToCart.getActiveCartByAccountId(addToCartWrapper.accountId, addToCartWrapper.storeName);

            if(activeCartId.isEmpty()){
                WebCart wbc = new WebCart();
                ConnectApi.CartSummary createCart = EC_AddToCart.createCart(addToCartWrapper.accountId,addToCartWrapper.storeName);
                wbc.Id = createCart.cartId;
                activeCartId.add(wbc);
            }
            ConnectApi.CartItemInput cartItemInput = new ConnectApi.CartItemInput();
            cartItemInput.productId = addToCartWrapper.productExtId;
            cartItemInput.quantity = addToCartWrapper.productQuantity;
            cartItemInput.type = ConnectApi.CartItemType.Product;

            ConnectApi.CartItem addItem = EC_AddToCart.addItemToCart(webstoreId,addToCartWrapper.accountId,activeCartId[0].Id,cartItemInput,'USD');
            EC_RestResponseUtility.setRestResponse(200,'Ok',String.valueOf(activeCartId[0].Id));
        } catch (Exception e) {
            EC_RestResponseUtility.setRestResponse(500,'Internal Server Error',e.getMessage());
            Logger.error('Error occured in addItemToCart :: '+ e.getMessage() + e.getStackTraceString());
            Logger.saveLog();
        }
    }
}