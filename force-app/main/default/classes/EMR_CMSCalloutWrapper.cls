/**
 * @description       : 
 * @author            : hegoswami@deloitte.com
 * @group             : 
 * @last modified on  : 10-17-2024
 * @last modified by  : hegoswami@deloitte.com
**/
public with sharing class EMR_CMSCalloutWrapper {
    
    public class CMSResponseWrapper{
        String strContentBody{get;set;}
        String  strContentKey{get;set;}
        String  strcontentSpace{get;set;}
        String contentType{get;set;}
        String createdBy{get;set;}
        Boolean isPublished{get;set;}
        String strLanguage{get;set;}
        String strLastModified{get;set;}
        DateTime strLastdate{get;set;}
        public String strManagedContentId{get;set;}
        String strManagedContentVariantId{get;set;}
        String strmanagedContentVersionId{get;set;}
        public String strtitle{get;set;}
        String strurlName{get;set;}
    }
}