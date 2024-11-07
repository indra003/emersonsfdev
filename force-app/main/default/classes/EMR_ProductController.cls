/**
 * @description       : This class is used to get the product details based on the webstore id and the product id 
 * @author            : pbypureddy@deloitte.com
 * @group             : 
 * @last modified on  : 10-18-2024
 * @last modified by  : pbypureddy@deloitte.com
**/
@RestResource(urlMapping='/getProductDetail/*')
global class EMR_ProductController {
    @HttpPost
    global static void getProductDetail(string webstoreId, string productId, string effectiveAccountId){//connect api call
        Map<String, Object> productDetail;
        //ConnectApi.ProductDetail products;
        String jsonResponse;
        //ErrorMessageWrapper errorMessage = new ErrorMessageWrapper();  
        try{
            String accessToken = EMR_ProductMediaCMSUpdateServiceClass.getAccessToken();
            if(String.isBlank(webstoreId) || String.isBlank(productId) || String.isBlank(effectiveAccountId)){
                RestContext.response.statusCode = 400;
                RestContext.response.responseBody = Blob.valueOf('{"errorCode":"BAD_REQUEST", "message":"Missing or empty parameters: webstoreId, productId, effectiveAccountId"}');
                RestContext.response.addHeader('Content-Type', 'application/json');
                return;
            }
            System.debug('HOST-->'+RestContext.request.headers.get('Host'));
            /* if(!test.isrunningtest() && RestContext.request.headers.get('Host').contains('.site.com')){
                productDetail = getProductDetails(webstoreId, productId, effectiveAccountId);
                System.debug('productDetail-->'+productDetail);
                
                jsonResponse = JSON.serialize(productDetail);
                RestContext.response.responseBody = Blob.valueOf(jsonResponse);
                System.debug('RestContext.response.responseBody-->'+RestContext.response.responseBody);
                RestContext.response.addHeader('Content-Type', 'application/json');
            } */
            if(accessToken != null ){
                System.debug('product details Data-->');
                //connect api call -- start 
                productDetail = getProductDetails(webstoreId, productId, effectiveAccountId);
                System.debug('productDetail-->'+productDetail);
                
                jsonResponse = JSON.serialize(productDetail);
                /* if(jsonResponse == '{}'){
                    RestContext.response.statusCode = 400;
                    RestContext.response.responseBody = Blob.valueOf('{"errorCode":"BAD_REQUEST", "message":"Invalid details either productid or effectiveaccountid or the webstoreid"}');
                    RestContext.response.addHeader('Content-Type', 'application/json');
                    return;
                } */
                System.debug('prod details-->'+productDetail);
                System.debug('jsonResponse-->'+jsonResponse);
                RestContext.response.responseBody = Blob.valueOf(jsonResponse);
                System.debug('RestContext.response.responseBody-->'+RestContext.response.responseBody);
                RestContext.response.addHeader('Content-Type', 'application/json');
            }
        }
        catch(Exception ex)
        {
            Logger.error(ex.getMessage());
            Logger.saveLog();
        }
        //return productDetail;
        
    }


    /**
    * description       : get Product details for a product with connect api call
    * @author           : pbypureddy@deloitte.com
    * @param            : String product Id,webStoreId, effectiveAccountId
    * @return           : ConnectApi.ProductDetail 
    * ------------------------------------------------------------------------------------------
    
    */
    public static Map<String, Object> getProduct(String webstoreId, String productSKU, String effectiveAccountId){
        ConnectApi.ProductDetail getProductDetails;
        Map<String, Object> productDetails = new Map<String, Object>();
        String productId = [Select Id, StockKeepingUnit from Product2 where StockKeepingUnit =: productSKU].id;
        List<String> productFields = new List<String>();
        List<String> productSpecFields = new List<String>();
        productFields = EMR_Utility.getFieldPathFromFieldSetMember(Schema.SObjectType.Product2.fieldSets.getMap().get('Product_Field_Set').getFields());
        //productSpecFields = EMR_Utility.getFieldPathFromFieldSetMember(Schema.SObjectType.Product2.fieldSets.getMap().get('EC_ProductSpecs').getFields());
        System.debug('productSpecFields -->'+productSpecFields);
        //System.debug('productFields -->'+productFields);
        
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
            //productDetails.put('productSpecs',productSpecFields);
            System.debug('product details'+getProductDetails);
            
        }
        catch(Exception e){
            System.debug('Exception '+e.getMessage());
            
            
        }
        return productDetails;
    }



    /**
    * description       : get Product details for a product with connect rest api call
    * @author           : pbypureddy@deloitte.com
    * @param            : String product Id,webStoreId
    * @return           : String
    * ------------------------------------------------------------------------------------------
    
    */


    public static Map<string, Object> getProductDetails(String webstoreId, String productSKU, string accountId){
        Map<string, Object> responseData = new Map<String, Object>();
        List<String> productFields = new List<String>();
        Boolean excludeMedia = false;
        String productId = [Select Id, StockKeepingUnit from Product2 where StockKeepingUnit =: productSKU].id;
        productFields = EMR_Utility.getFieldPathFromFieldSetMember(Schema.SObjectType.Product2.fieldSets.getMap().get('Product_Field_Set').getFields());
        String productFieldsString = String.join(productFields,',');
        System.debug('productFieldsString -->'+productFieldsString);
        //String queryParams = '?effectiveAccountId='+accountId+'&fields='+EncodingUtil.urlEncode(productFieldsString, 'UTF-8');
        String queryParams = '?fields='+EncodingUtil.urlEncode(productFieldsString, 'UTF-8');
        System.debug('queryParams-->'+queryParams);
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://nosoftware-page-6404--emrdev1.sandbox.my.site.com/MeasurementInstrumentation/webruntime/api/services/data/v62.0/commerce/webstores/'+webstoreId+'/products/'+productId+queryParams);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        System.debug('request-->'+req);
        Http http = new Http();
        HttpResponse res = new HttpResponse();
        System.debug('response-->'+res);
        try{
            res = http.send(req);
            System.debug('response-->'+res);
            System.debug(res.getBody());
            Map<string, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            responseData.put('productDetails', responseMap);
            System.debug('responseMap-->'+responseData);
        }
        catch(Exception e){
            System.debug('Exception '+e.getMessage());
            Logger.error(e.getMessage());
            Logger.saveLog();
            
        } 
        return responseData;
    } 
    
}