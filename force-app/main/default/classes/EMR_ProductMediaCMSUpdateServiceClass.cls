/**
 * @description       : 
 * @author            : hegoswami@deloitte.com
 * @group             : 
 * @last modified on  : 10-22-2024
 * @last modified by  : hegoswami@deloitte.com
**/
@RestResource(urlMapping='/updateCMSProductImages/*')
global class EMR_ProductMediaCMSUpdateServiceClass {

    private static final String CLIENT_ID = '3MVG9A6Mm0rJfTIgqtIIZi478ddsQDJCqu0PXarujdc1gpZXVJvJEg4M0n0DZ.hsStMgbghsLvhIx9JWfuKi4';

    private static final String CLIENT_SECRET = '840AE4F647566A2CB54A4347421A24D1E3AC4A53F2A74003D53C534BF49AAA83';

    private static final String TOKEN_URL = 'https://nosoftware-page-6404--emrdev1.sandbox.my.salesforce.com/services/oauth2/token';
    private static final String CMS_ENDPOINT='https://nosoftware-page-6404--emrdev1.sandbox.my.salesforce.com/services/data/v56.0/connect/cms/contents';
    private static final String CMS_PUBLISH='https://nosoftware-page-6404--emrdev1.sandbox.my.salesforce.com/services/data/v56.0/connect/cms/contents/publish';
    private static final String PLP='Product List Image';
    private static final String PRODUCTMEDI_ENDP='https://nosoftware-page-6404--emrdev1.sandbox.my.salesforce.com/services/apexrest/cmsImage';
    public static String strACCToken='';

    /**
    * @description RequestWrapper
    * @author hegoswami@deloitte.com | 10-18-2024 
    **/
    global class RequestWrapper{
        /**
         * @description strStoreNameOrWorkSpaceId
         * @return String
         */
        global  String strStoreNameOrWorkSpaceId;
        /**
         * @description strProductSKU
         * @return String
         */
        global  String strProductSKU;
        /**
         * @description strTitle
         * @return String
         */
        global  String strTitle;
        /**
         * @description strImageURL
         * @return String
         */
        global  String strImageURL;
    }
    
    /**
    * @description 
    * @author hegoswami@deloitte.com | 10-18-2024 
    * @param requestBody 
    * @return String 
    **/
    @HttpPost
    global static String updateProductImages(RequestWrapper requestBody){ //String strStoreNameOrWorkSpaceId, String strProductSKU,String strTitle,String strImageURL) {
        String strReq=JSON.serialize(requestBody);
        RequestWrapper requestWrapper = (RequestWrapper) JSON.deserialize(strReq, RequestWrapper.class);
        String strResponse='error';
       try{
        
        String accessToken = getAccessToken();
        if(accessToken != null)
        {

            strResponse=createMangedContenet(requestWrapper);//strStoreNameOrWorkSpaceId,strProductSKU,strTitle,strImageURL );//,accessToken);
        }
        }
        catch(Exception ex)
        {
            Logger.error(ex.getMessage());
            Logger.saveLog();
        }

        return strResponse;
    }
    
    /**
    * @description 
    * @author hegoswami@deloitte.com | 10-18-2024 
    * @return string 
    **/
    public static string getAccessToken(){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(TOKEN_URL);//'callout:Salesforce Authentication Token');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody('grant_type=client_credentials&client_id=' + CLIENT_ID + '&client_secret=' + CLIENT_SECRET);
        Http http = new Http();
        HttpResponse res = http.send(req);
        if (res.getStatusCode() == 200) {
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            strACCToken=(String) result.get('access_token');
            return (String) result.get('access_token');
        } else {
            return null;
        }
    }

    /**
    * @description createMangedContenet
    * @author hegoswami@deloitte.com | 10-18-2024 
    * @param requestWrapper 
    * @return String
    **/
    public static String createMangedContenet(RequestWrapper requestWrapper)
    {
        String strAccessToken=getAccessToken();
        String strremani='{"contentSpaceOrFolderId":'+'"'+requestWrapper.strStoreNameOrWorkSpaceId+'"' +',"title":'+'"'+requestWrapper.strTitle+'"'+',"contentType":"sfdc_cms__image"'+',"contentBody": {"altText": "EMR-1", "sfdc_cms:media": { "source": {"type":"url"'+ ',"url":'+'"'+requestWrapper.strImageURL+'"'+',"mimeType": null}}'       +'}}';
        
        HttpRequest httpReq = new HttpRequest();
        httpReq.setEndpoint('callout:EMR_CMSContent');
        httpReq.setMethod('POST');
        //httpReq.setHeader('Authorization', 'Bearer ' + strAccessToken);
        httpReq.setHeader('Content-Type', 'application/json');
        httpReq.setBody(strremani);
        String strResponse;
         Http http = new Http();
        HttpResponse res = http.send(httpReq);
        if (res.getStatusCode() == 201) {
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            strResponse= publishManagedContent((String)result.get('managedContentId'),(String)result.get('title'),requestWrapper.strProductSKU);
        }
        return strResponse;

    }
   
    /**
    * @description 
    * @author hegoswami@deloitte.com | 10-18-2024 
    * @param mangedContentId 
    * @param title 
    * @param strProductSKU 
    * @return string 
    **/
    public static string publishManagedContent(String mangedContentId, String title,String strProductSKU){
        String strResponse;
        String strReq='{"description":'+'"'+Title+'"' +',"contentIds":'+'["'+mangedContentId+'"]'  +'}' ;
        HttpRequest httpReq = new HttpRequest();
        httpReq.setEndpoint(CMS_PUBLISH);
        httpReq.setMethod('POST');
        httpReq.setHeader('Authorization', 'Bearer ' + strACCToken);
        httpReq.setHeader('Content-Type', 'application/json');
        httpReq.setBody(strReq);
        Http http = new Http();
        HttpResponse res = http.send(httpReq);
        if (res.getStatusCode() == 201) {
            strResponse=updateProductMedia(strProductSKU,mangedContentId);
        }


        return strResponse;
    }
    /**
    * @description 
    * @author hegoswami@deloitte.com | 10-18-2024 
    * @param strProductId 
    * @param contentnId 
    * @return string 
    **/
    public static string updateProductMedia(String strProductId, String contentnId){

        String strReq='{"strProductExternalId":'+'"'+strProductId+'"' +',"strContentId":'+'"'+contentnId+'"'  +'}' ;
        String str='';
        RestResponse restResponse = RestContext.response;
        HttpRequest httpReq = new HttpRequest();
        httpReq.setEndpoint(PRODUCTMEDI_ENDP);
        httpReq.setMethod('PUT');
        httpReq.setHeader('Authorization', 'Bearer ' + strACCToken);
        httpReq.setHeader('Content-Type', 'application/json');
        httpReq.setBody(strReq);
        Http http = new Http();
        HttpResponse res = http.send(httpReq);
        if (res.getStatusCode() == 201) {
            restResponse.statusCode =res.getStatusCode();
            restResponse.responseBody = Blob.valueOf(res.getBody());
        }
        str=res.getbody();
        return str;

    }
    
}