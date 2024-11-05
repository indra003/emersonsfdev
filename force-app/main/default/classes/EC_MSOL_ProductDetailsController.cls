/**
 * @description       : 
 * @author            : hegoswami@deloitte.com
 * @group             : 
 * @last modified on  : 10-30-2024
 * @last modified by  : pbypureddy@deloitte.com
**/
public without sharing class EC_MSOL_ProductDetailsController {
    private static string webstoreName = 'Measurement Instrumentation';
    /**
    * description       : get Product details for a product with connect api call for logged in user
    * @author           : pbypureddy@deloitte.com
    * @param            : String product Id, effectiveAccountId
    * @return           : Map<String, Object> 
    * ------------------------------------------------------------------------------------------
    */
    public static Map<String, Object> getProduct(String webstoreId,String productSKU, String effectiveAccountId){
        ConnectApi.ProductDetail getProductDetails;
        Map<String, Object> productDetails = new Map<String, Object>();
        String productId = [Select Id, StockKeepingUnit from Product2 where StockKeepingUnit =: productSKU].id;
        //String webstoreId = [Select Id from WebStore where Name =: webstoreName].Id;
        List<String> productFields = new List<String>();
        productFields = EMR_Utility.getFieldPathFromFieldSetMember(Schema.SObjectType.Product2.fieldSets.getMap().get('Product_Field_Set').getFields());
        System.debug('productSpecFields -->'+productFields);
        try{
            getProductDetails = ConnectApi.CommerceCatalog.getProduct(
                webStoreId,
                productId,
                effectiveAccountId,
                productFields,
                false,
                null,
                false,
                false,
                false,
                false,
                false,
                false
            );
            productDetails.put('productDetails', getProductDetails);
            System.debug('product details'+getProductDetails);
            
        }
        catch(Exception e){
            System.debug('Exception '+e.getMessage());
            Logger.error(e.getMessage());
            Logger.saveLog();
        }
        return productDetails;
    }

     /**
    * description       : get Product details for a product with connect REST api call for guest user
    * @author           : pbypureddy@deloitte.com
    * @param            : String product Id, effectiveAccountId
    * @return           : Map<String, Object> 
    * ------------------------------------------------------------------------------------------
    */

    public static HttpResponse getProductDetails(String webstoreId, String productSKU, string accountId){
        String accessToken = EMR_ProductMediaCMSUpdateServiceClass.getAccessToken();
        Map<string, Object> responseData = new Map<String, Object>();
        List<String> productFields = new List<String>();
        Boolean excludeMedia = false;
        String productId = [Select Id, StockKeepingUnit from Product2 where StockKeepingUnit =: productSKU].id;
        //String webstoreId = [Select Id, name from Webstore where Name =: webstoreName].id;
        productFields = EMR_Utility.getFieldPathFromFieldSetMember(Schema.SObjectType.Product2.fieldSets.getMap().get('Product_Field_Set').getFields());
        String productFieldsString = String.join(productFields,',');
        System.debug('productFieldsString -->'+productFieldsString);
        String queryParams = '?effectiveAccountId='+accountId+'&fields='+EncodingUtil.urlEncode(productFieldsString, 'UTF-8');
        System.debug('queryParams-->'+queryParams);
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://nosoftware-page-6404--emrdev1.sandbox.my.site.com/MeasurementInstrumentation/webruntime/api/services/data/v62.0/commerce/webstores/'+webstoreId+'/products/'+productId+queryParams);
        req.setMethod('GET');
        //req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json');
        //req.setBody(requestBody);
        System.debug('request-->'+req);
        Http http = new Http();
        HttpResponse res = new HttpResponse();
        System.debug('response-->'+res);
        //try{
            res = http.send(req);
            /* System.debug('response-->'+res);
            
                //Successfully retrieved the product details
                System.debug(res.getBody());
                Map<string, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                responseData.put('productDetails', responseMap);
                System.debug('responseMap-->'+responseData);
                //return responseMap;
            
            
        }
        catch(Exception e){
            System.debug('Exception '+e.getMessage());
            Logger.error(e.getMessage());
            Logger.saveLog();
            
        } */
        return res;
    } 
    
    
}