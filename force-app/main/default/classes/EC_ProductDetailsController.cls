/**
 * @description       : 
 * @author            : hegoswami@deloitte.com
 * @group             : 
 * @last modified on  : 11-06-2024
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
        String locale = req.params.get('language');
        String webstoreId = [Select Id from WebStore where Name =: webstoreName].Id;
        String strReturn;
        String strAccessToken;
        Boolean isGuest = false;
        Map<String, Object> mapS=new Map<String, Object>();
        //String isGuest = UserInfo.getUserType();
        if(RestContext.request.headers.get('Host').contains('.site.com')){
            isGuest = true;
        }
        try{
        //Map<String,Object> res=fetchAccessToken();
       // strAccessToken=String.valueOf(res.get('access_token'));
        //System.debug('token->'+strAccessToken);
        if(webstoreName==EC_Constants.MSOL_STORE)
        {
                //if(isGuest == 'Guest')
                if(isGuest)
                {
                    mapS= EC_MSOL_ProductDetailsController.getProductDetails(webstoreId,productSKU, locale); 
                }
                 else{
                mapS= EC_MSOL_ProductDetailsController.getProduct(webstoreId,productSKU,accountId); 
                } 
           
            strReturn= JSON.serialize(mapS);
        }
        else if(webstoreName==EC_Constants.FCTL_STORE)
        {
            mapS=EC_FCTL_ProductDetailsController.getProduct(webstoreId,productSKU,accountId);
            strReturn= JSON.serialize(mapS);
        }
        else if(webstoreName == EC_Constants.SYSS_STORE)
        {
            if(isGuest){
                mapS= EC_SYSS_ProductDetailsController.getProductDetails(webstoreId,productSKU, locale); 
            }
            else{
            mapS=EC_SYSS_ProductDetailsController.getProduct(webstoreId,productSKU,accountId);
            }
            strReturn= JSON.serialize(mapS);
        }
        RestContext.response.responseBody = Blob.valueOf(strReturn);
        System.debug('RestContext.response.responseBody-->'+strReturn);
        RestContext.response.addHeader('Content-Type', 'application/json');
    }
    catch(Exception e){
        Logger.error('API Error - ::'+ e.getMessage());
        Logger.savelog();
    }
    }

/**
* @description fetchAccessToken
* @author hegoswami@deloitte.com | 11-06-2024 
* @return Map<String, Object> 
**/
public static Map<String,Object> fetchAccessToken()
{
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    String errorString = null;
    try{
        EMR_API_Setting__mdt metaDataRecord = EMR_API_Setting__mdt.getInstance('PDPEndpoint');
        String grantType = metaDataRecord.EMR_Grant_Type__c ;
        String clientId = metaDataRecord.EMR_API_ClientId__c;
        String clientSecret = metaDataRecord.EMR_API_ClientSecret__c;
        String endPoint  = metaDataRecord.EMR_API_BaseURL__c;

        //callout to get the access token
        String payload = '?grant_type='+grantType+'&client_id='+clientId+'&client_secret='+clientSecret;
        request.setEndpoint(endPoint+'oauth2/token'+payload); //custom settings
        System.debug('-->'+endPoint+'oauth2/token'+payload);
        request.setHeader(EC_Constants.API_CONTENT_TYPE, EC_Constants.API_CONTENT_TYPE_VALUE_JSON);                 
        request.setMethod(EC_Constants.API_METHOD_POST);
        HttpResponse response = http.send(request);
        // If the request is successful, parse the JSON response. 
        if (response.getStatusCode() == 200) {
            System.debug('in-> '+response.getBody());
            // Deserialize the JSON string into collections of primitive data types.            
            return (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        }
        else{ 
            return new Map<String,Object>{'Error'=>response.getBody(),'access_token'=>''};
        }
    }
    catch(Exception e){
        Logger.error('Marketo API Error - ::'+ e.getMessage());
        Logger.savelog();
        errorString = (errorString == null) ? e.getMessage() : errorString;
        return new Map<String,Object>{'Error'=>errorString,'access_token'=>''};
    }
}




}