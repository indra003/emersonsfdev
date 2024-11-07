@RestResource(urlMapping='/updateProductImages')
global with sharing class POC_EMR_ProductImageUpdateService {
@HttpPost
    global static String updateProductImages(List<ProductImageData> images) {
        List<ContentVersion> lstContentVersions = new List<ContentVersion>();
        
        for (ProductImageData image : images) {
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.Title = image.title;
            contentVersion.PathOnClient = image.pathOnClient;
            contentVersion.VersionData = EncodingUtil.base64Decode(image.base64Data);
            
            if (image.contentDocumentId != null) {
                contentVersion.ContentDocumentId = image.contentDocumentId;
            }
            
            lstContentVersions.add(contentVersion);
        }
        
        try {
            insert lstContentVersions;
            
            List<ContentVersion> lstContentVerionsData = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id IN : lstContentVersions];
            
            // Link the ContentVersion to the Product Media record
            for (ContentVersion contentVersion : lstContentVersions) {
                ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
                contentDocumentLink.ContentDocumentId = lstContentVerionsData[0].ContentDocumentId;
                contentDocumentLink.LinkedEntityId = images[0].productMediaId;
                contentDocumentLink.ShareType = 'I'; // 'I' for Inferred permission
                contentDocumentLink.Visibility = 'AllUsers';
                
                insert contentDocumentLink;
            }
            
            return 'Product images updated successfully';
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }
    
    global class ProductImageData {
        public String title;
        public String pathOnClient;
        public String base64Data;
        public String contentDocumentId;
        public String productMediaId;
    }
}