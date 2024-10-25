/**
 * @description       : This class is used to get the product details based on the webstore id and the product id 
 * @author            : pbypureddy@deloitte.com
 * @group             : 
 * @last modified on  : 10-18-2024
 * @last modified by  : pbypureddy@deloitte.com
**/
@RestResource(urlMapping='/getProductDetails/*')
global class EMR_ProductController {
    @HttpPost
    global static void getProductDetail(string webstoreId, string productId, string effectiveAccountId){//connect api call
        Map<String, Object> productDetail;
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
            if(accessToken != null ){
                System.debug('product details Data-->');
                //connect api call -- start 
                productDetail = getProduct(webstoreId, productId, effectiveAccountId);
                System.debug('productDetail-->'+productDetail);
                
                jsonResponse = JSON.serialize(productDetail);
                if(jsonResponse == '{}'){
                    RestContext.response.statusCode = 400;
                    RestContext.response.responseBody = Blob.valueOf('{"errorCode":"BAD_REQUEST", "message":"Invalid details either productid or effectiveaccountid or the webstoreid"}');
                    RestContext.response.addHeader('Content-Type', 'application/json');
                    return;
                }
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
    * @return           : Map<String, Object>
    * ------------------------------------------------------------------------------------------
    
    */
    public static Map<String, Object> getProduct(String webstoreId, String productId, String effectiveAccountId){
        ConnectApi.ProductDetail getProductDetails;
        //String productData;
        List<String> productFields = new List<String>();
        productFields = EMR_Utility.getFieldPathFromFieldSetMember(Schema.SObjectType.Product2.fieldSets.getMap().get('product_fields').getFields());
        System.debug('productFields -->'+productFields);
        Map<String, Object> productData = new Map<String, Object>(); 
        //ErrorMessageWrapper errorMessage = new ErrorMessageWrapper();       
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
            //productData = JSON.serialize(getProductDetails);
            productData.put('productDetails',getProductDetails);
            System.debug('productData-->'+productData);
            System.debug('product details'+getProductDetails);
            
        }
        catch(Exception e){
            System.debug('Exception '+e.getMessage());
            
            
        }
        return productData;
    }


    /**
    * description       : get Product details for a product with connect rest api call
    * @author           : pbypureddy@deloitte.com
    * @param            : String product Id,webStoreId
    * @return           : String
    * ------------------------------------------------------------------------------------------
    
    */


    /* public static Map<String, Object> getProductDetails(String webstoreId, String productId, string accountId){
        String accessToken = EMR_ProductMediaCMSUpdateServiceClass.getAccessToken();
        Map<string, Object> responseMap = new Map<String, Object>();
        List<String> productFields = new List<String>();
        productFields = EMR_Utility.getFieldPathFromFieldSetMember(Schema.SObjectType.Product2.fieldSets.getMap().get('Product_Field_Set').getFields());
        String productFieldsString = String.join(productFields,',');
        System.debug('productFieldsString -->'+productFieldsString);
        System.debug('accesstoken-->'+accessToken);
        //String requestBody = '{"effectiveAccountId":'+'"'+accountId+'"'+',"fields":'+'"'+productFields+'"'+'}';
        String queryParams = '?effectiveAccountId='+accountId+'&fields='+EncodingUtil.urlEncode(productFieldsString, 'UTF-8');
        System.debug('queryParams-->'+queryParams);
        if (accessToken == null) {
            System.debug('Access token is null. Request cannot be processed');
            //return 'Error: Access token is null';
        }
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
            if(res.getStatusCode() == 200){
                //Successfully retrieved the product details
                System.debug(res.getBody());
                responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                System.debug('responseMap-->'+responseMap);
                return responseMap;
            }
            else{
                System.debug('error '+res.getStatus()+'-->'+res.getBody());
                return new Map<String, Object>{'Error'=> 'Failed to get the products', 'StatusCode'=> res.getStatusCode()};
            }
        }
        catch(Exception e){
            System.debug('Exception '+e.getMessage());
            return new Map<String, Object>{'Exception'=>e.getMessage()};
        }
    } */
    
    
}