/**
 * @description       : 
 * @author            : hegoswami@deloitte.com
 * @group             : 
 * @last modified on  : 11-07-2024
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
        ConnectApi.ProductDetail getProductDetails=new ConnectApi.ProductDetail();
        Map<String, Object> productDetails = new Map<String, Object>();
        String productId = [Select Id, StockKeepingUnit from Product2 where StockKeepingUnit =: productSKU].id;
        List<String> productFields = new List<String>();
        productFields = EMR_Utility.getFieldPathFromFieldSetMember(Schema.SObjectType.Product2.fieldSets.getMap().get(EC_Constants.FCTL_PDP_FIELDSET).getFields());
        try{
            if(!Test.isRunningTest())
            {
            getProductDetails = ConnectApi.CommerceCatalog.getProduct(
                strWebstoreId,
                productId,
                effectiveAccountId,
                productFields,false,null,false,false,false,false,false,false);
            }
            else{
                Map<String,String> mapFields=new Map<String,String>();
                mapFields.put('EC_ApproximateWeight__c','Type P650: 5 Pounds/ 2 kg\nType P651: 3 Pounds/ 1 kg');
                mapFields.put('EC_AvailableConfigurations__c','Type P650: Primary cable');
                mapFields.put('EC_KeyFeatures__c','key feature');
                getProductDetails.fields=mapFields;
            }
            productDetails.put('productDetails', getProductDetails);
            
        }
        catch(Exception e){
            Logger.error(e.getMessage());
            Logger.saveLog();
        }
        return productDetails;
    }


    /**
    * @description 
    * @author hegoswami@deloitte.com | 11-07-2024 
    * @param webstoreId 
    * @param productSKU 
    * @param accountId 
    * @return Map<String, Object> 
    **/
    public static Map<String, Object> getProductDetails(String webstoreId, String productSKU, string accountId){
        String accessToken = EMR_ProductMediaCMSUpdateServiceClass.getAccessToken();
        Map<string, Object> responseData = new Map<String, Object>();
        List<String> productFields = new List<String>();
        //Boolean excludeMedia = false;
        String productId = [Select Id, StockKeepingUnit from Product2 where StockKeepingUnit =: productSKU].id;
        productFields = EMR_Utility.getFieldPathFromFieldSetMember(Schema.SObjectType.Product2.fieldSets.getMap().get(EC_Constants.FCTL_PDP_FIELDSET).getFields());
        String productFieldsString = String.join(productFields,',');
        //String requestBody = '{"effectiveAccountId":'+'"'+accountId+'"'+',"fields":'+'"'+productFields+'"'+'}';
        String queryParams = '?effectiveAccountId='+accountId+'&fields='+EncodingUtil.urlEncode(productFieldsString, 'UTF-8');
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://nosoftware-page-6404--emrdev1.sandbox.my.site.com/FinalControl/webruntime/api/services/data/v62.0/commerce/webstores/'+webstoreId+'/products/'+productId+queryParams);
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setMethod(EC_Constants.API_METHOD_GET);
        req.setHeader(EC_Constants.API_CONTENT_TYPE, EC_Constants.API_CONTENT_TYPE_JSON);
        //req.setBody(requestBody);
        Http http = new Http();
        HttpResponse res = new HttpResponse();
        try{
            res = http.send(req);
                //Successfully retrieved the product details
                Map<string, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                responseData.put('productDetails',responseMap);   
        }
        catch(Exception e){
            Logger.error(e.getMessage());
            Logger.saveLog();
        }
        return responseData;
    }
    
}