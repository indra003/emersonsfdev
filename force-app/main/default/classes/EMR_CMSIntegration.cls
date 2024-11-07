/**
 * @description       : 
 * @author            : hegoswami@deloitte.com
 * @group             : 
 * @last modified on  : 10-18-2024
 * @last modified by  : hegoswami@deloitte.com
**/
public without sharing class EMR_CMSIntegration {
    
    private static final String CLIENT_ID = '3MVG9A6Mm0rJfTIgqtIIZi478ddsQDJCqu0PXarujdc1gpZXVJvJEg4M0n0DZ.hsStMgbghsLvhIx9JWfuKi4';

    private static final String CLIENT_SECRET = '840AE4F647566A2CB54A4347421A24D1E3AC4A53F2A74003D53C534BF49AAA83';

    private static final String TOKEN_URL = 'https://nosoftware-page-6404--emrdev1.sandbox.my.salesforce.com/services/oauth2/token';
    private static final String CMS_ENDPOINT='https://nosoftware-page-6404--emrdev1.sandbox.my.salesforce.com/services/data/v56.0/connect/cms/contents?managedContentSpaceOrFolderId=';
    private static final String CMS_PUBLISH='https://nosoftware-page-6404--emrdev1.sandbox.my.salesforce.com/services/data/v56.0/connect/cms/contents/publish';
    private static final String PLP='Product List Image';
 
/**
    * @description cmsUpdateWrapper
    * @author hegoswami@deloitte.com | 10-16-2024 
    **/
    public class CmsUpdateWrapper{
        public String contentSpaceOrFolderId{get;set;}
        public String title{get;set;}
        public String contentType{get;set;}
        public ContentBodyWrapper contentBody{get;set;}
        
    }
    /**
    * @description contentBodyWrapper
    * @author hegoswami@deloitte.com | 10-16-2024 
    **/
    public class ContentBodyWrapper{
          public String altText{get;set;}
          public SrcImageWrapper sfdc_cms_media{get;set;}
         
    }

    /**
    * @description SrcImageWrapper
    * @author hegoswami@deloitte.com | 10-16-2024 
    **/
    public class SrcImageWrapper{
        public SourceWrapper source{get;set;}
    }

    /**
    * @description SourceWrapper
    * @author hegoswami@deloitte.com | 10-16-2024 
    **/
    public class SourceWrapper{
        public String type{get;set;}
        public String url{get;set;}
        public String mimeType{get;set;}
    }


    /**
    * @description PublishContentWrapper
    * @author hegoswami@deloitte.com | 10-16-2024 
    **/
    public class PublishContentWrapper{
        String strDescription{get;set;}
        String strContentid{get;set;}
    }


    
    /**
    * @description
    * @author hegoswami@deloitte.com | 10-16-2024
    * @return String
    **/
    public static String getAccessToken() {
 
        HttpRequest req = new HttpRequest();
 
        req.setEndpoint(TOKEN_URL);
 
        req.setMethod('POST');
 
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
 
        req.setBody('grant_type=client_credentials&client_id=' + CLIENT_ID + '&client_secret=' + CLIENT_SECRET);
 
        Http http = new Http();
 
        HttpResponse res = http.send(req);
 
        if (res.getStatusCode() == 200) {
 
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
 
            return (String) result.get('access_token');
 
        } else {
 
            System.debug('Failed to obtain access token: ' + res.getBody());
 
            return null;
 
        }
    }    
}