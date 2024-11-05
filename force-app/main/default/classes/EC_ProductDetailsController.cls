/**
 * @description       : 
 * @author            : hegoswami@deloitte.com
 * @group             : 
 * @last modified on  : 11-05-2024
 * @last modified by  : hegoswami@deloitte.com
**/
@RestResource(urlMapping='/getProductDetails/*')
global without sharing class EC_ProductDetailsController {
    /**
    * @description getProductDetails
    * @author hegoswami@deloitte.com | 11-05-2024 
    **/
    @Httpget
    global static void getProductDetails(){
        RestRequest req = RestContext.request;
        String webstoreName = req.params.get('webstoreName');
        String productSKU = req.params.get('productSKU');
        String accountId = req.params.get('accountId');
        String webstoreId = [Select Id from WebStore where Name =: webstoreName].Id;
        String strReturn;
        Map<String, Object> mapS=new Map<String, Object>();
        if(webstoreName==EC_Constants.MSOL_STORE)
        {
           mapS= EC_MSOL_ProductDetailsController.getProduct(webstoreId,productSKU,accountId); 
            strReturn= JSON.serialize(mapS);
        }
        else if(webstoreName==EC_Constants.FCTL_STORE)
        {
            mapS=EC_FCTL_ProductDetailsController.getProduct(webstoreId,productSKU,accountId);
            strReturn= JSON.serialize(mapS);
        }
        RestContext.response.responseBody = Blob.valueOf(strReturn);
        System.debug('RestContext.response.responseBody-->'+RestContext.response.responseBody);
        RestContext.response.addHeader('Content-Type', 'application/json');
        //return strReturn;
    }
}