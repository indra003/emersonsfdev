/**
 * @description       : 
 * @author            : hegoswami@deloitte.com
 * @group             : 
 * @last modified on  : 11-05-2024
 * @last modified by  : hegoswami@deloitte.com
**/
public without sharing class EC_FCTL_ProductDetailsController {
    
    

    /**
    * @description 
    * @author hegoswami@deloitte.com | 11-05-2024 
    * @param strWebstoreId 
    * @param productSKU 
    * @param effectiveAccountId 
    * @return Map<String, Object> 
    **/
    public static Map<String, Object> getProduct(String strWebstoreId,String productSKU, String effectiveAccountId){
        ConnectApi.ProductDetail getProductDetails;
        Map<String, Object> productDetails = new Map<String, Object>();
        String productId = [Select Id, StockKeepingUnit from Product2 where StockKeepingUnit =: productSKU].id;
        List<String> productFields = new List<String>();
        productFields = EMR_Utility.getFieldPathFromFieldSetMember(Schema.SObjectType.Product2.fieldSets.getMap().get(EC_Constants.FCTL_PDP_FIELDSET).getFields());
        try{
            getProductDetails = ConnectApi.CommerceCatalog.getProduct(
                strWebstoreId,
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
            
        }
        catch(Exception e){
            Logger.error(e.getMessage());
            Logger.saveLog();
        }
        return productDetails;
    }


    /**
    * @description getProductDetail
    * @author hegoswami@deloitte.com | 11-05-2024 
    * @param strWebstoreid 
    * @param productSKU 
    * @param accountId 
    
    * @return Map<String, Object> 
    **/
    public static Map<String, Object> getProductDetails(String webstoreId, String productSKU, string accountId){
        String accessToken = EMR_ProductMediaCMSUpdateServiceClass.getAccessToken();
        Map<string, Object> responseMap = new Map<String, Object>();
        List<String> productFields = new List<String>();
        Boolean excludeMedia = false;
        String productId = [Select Id, StockKeepingUnit from Product2 where StockKeepingUnit =: productSKU].id;
        productFields = EMR_Utility.getFieldPathFromFieldSetMember(Schema.SObjectType.Product2.fieldSets.getMap().get('Product_Field_Set').getFields());
        String productFieldsString = String.join(productFields,',');
        System.debug('productFieldsString -->'+productFieldsString);
        System.debug('accesstoken-->'+accessToken);
        //String requestBody = '{"effectiveAccountId":'+'"'+accountId+'"'+',"fields":'+'"'+productFields+'"'+'}';
        String queryParams = '?effectiveAccountId='+accountId+'&fields='+EncodingUtil.urlEncode(productFieldsString, 'UTF-8');
        System.debug('queryParams-->'+queryParams);
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://nosoftware-page-6404--emrdev1.sandbox.my.salesforce.com/services/data/v62.0/commerce/webstores/'+webstoreId+'/products/'+productId+queryParams);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json');
        //req.setBody(requestBody);
        System.debug('request-->'+req);
        Http http = new Http();
        HttpResponse res = new HttpResponse();
        System.debug('response-->'+res);
        try{
            res = http.send(req);
            System.debug('response-->'+res);
            
                //Successfully retrieved the product details
                System.debug(res.getBody());
                responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                System.debug('responseMap-->'+responseMap);
                
            
            
        }
        catch(Exception e){
            System.debug('Exception '+e.getMessage());
            Logger.error(e.getMessage());
            Logger.saveLog();
        }
        return responseMap;
    }
    
}