/**
* @author       : Aditya Anand
* @description  : This Generic Utility Sets REST Response
* *************************************************
* 
*/
 
public with sharing class EC_RestResponseUtility {
    public static void setRestResponse(Integer statusCode, String httpCode, String errorMessage){
        try {
            RestResponse res = RestContext.response;
            RestResponseBody responseBody = new RestResponseBody(httpCode,errorMessage);
            res.statusCode = statusCode;
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(JSON.serialize(responseBody));
           
        } catch (Exception e) {
            Logger.error('Error while setting up rest response: '+ e.getMessage() + e.getStackTraceString());
            Logger.saveLog();
        } 
    }
    
    public class RestResponseBody{
        public String httpCode;
        public String errorMessage;
        
        public RestResponseBody(String httpCode, String errorMessage){
            this.httpCode = httpCode;
            this.errorMessage = errorMessage;
        }
    }
}