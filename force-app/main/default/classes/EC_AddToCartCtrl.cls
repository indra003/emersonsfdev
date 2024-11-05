/**
* @author          : Aditya Anand
* @description     : This class is used for creation and updation of cart from helper class
*/
public with sharing class EC_AddToCartCtrl {
    
    /**
     *  @author : Aditya Anand
     *  @description : This method is used to create a cart
     *  @param  request
     *  @return List<String>
     */
    public static List<String> addToCart(EC_AddToCartWrapper.CartItemsDetails request){
        List<String> result = new List<String>();
        try{
            String webstoreId;
            webstoreId = EMR_Utility.getWebStoreId(request.storeName);
            List<WebCart> activeCartId = new List<WebCart>();
            activeCartId = EC_AddToCart.getActiveCartByAccountId(request.accountId, request.storeName);

            if(activeCartId.isEmpty()){
                WebCart wbc = new WebCart();
                ConnectApi.CartSummary createCart = EC_AddToCart.createCart(request.accountId,request.storeName);
                wbc.Id = createCart.cartId;
                activeCartId.add(wbc);
            }
            ConnectApi.CartItemInput cartItemInput = new ConnectApi.CartItemInput();
            cartItemInput.productId = request.productExtId;
            cartItemInput.quantity = request.productQuantity;
            cartItemInput.type = ConnectApi.CartItemType.Product;

            ConnectApi.CartItem addItem = EC_AddToCart.addItemToCart(webstoreId,request.accountId,activeCartId[0].Id,cartItemInput,'USD');
        } catch (Exception e) {
            Logger.error('Error occured in addItemToCart :: '+ e.getMessage() + e.getStackTraceString());
            Logger.saveLog();
        }

        return result;
    }
}