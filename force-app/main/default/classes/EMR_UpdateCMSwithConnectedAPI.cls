/**
 * @description       : 
 * @author            : hegoswami@deloitte.com
 * @group             : 
 * @last modified on  : 10-25-2024
 * @last modified by  : hegoswami@deloitte.com
**/
@RestResource(urlMapping='/cmsProductMedia/*')
global without sharing class EMR_UpdateCMSwithConnectedAPI {
    
    /**
    * @description 
    * @author hegoswami@deloitte.com | 10-25-2024 
    * @param requestBody 
    **/
    @HttpPost
    global static void replaceManagedContentVariantWithMedia(EMR_ProductMediaCMSUpdateServiceClass.RequestWrapper requestBody){
        
        List<ProductMedia> lstProdMedia=new List<ProductMedia>();
        String strContentVariantId;
        String strtitleinCMS;
        ConnectApi.ManagedContentDeliveryDocument cmsDelivery;
        ConnectApi.ManagedContentVariantUpdateInput mediaInputcontentBody = new ConnectApi.ManagedContentVariantUpdateInput();
        String variantId = '9PsD70000004EJoKAM';
        String title = 'NewImageOct23';
        try {
        String strReq=JSON.serialize(requestBody);
        EMR_ProductMediaCMSUpdateServiceClass.RequestWrapper requestWrapper = (EMR_ProductMediaCMSUpdateServiceClass.RequestWrapper) JSON.deserialize(strReq, EMR_ProductMediaCMSUpdateServiceClass.RequestWrapper.class);
        
        //read the request provided and check whether this content already present or not
        lstProdMedia=[ Select id,product.stockkeepingunit,ElectronicMediaid from productmedia 
                                where product.stockkeepingunit=:requestWrapper.strProductSKU
                                 and ElectronicMediaGroup.DeveloperName='productListImage' with security_enforced];
        if(!lstProdMedia.isEmpty())
        {
            
        cmsDelivery=ConnectApi.ManagedContentDelivery.getManagedContentForChannel('channelID',lstProdMedia[0].ElectronicMediaid,true); // channel id will be dependent on the type of prod- fctl, syss
        strContentVariantId=cmsDelivery.managedContentId;
        Object newsf= cmsDelivery.contentBody.get('sfdc_cms:media') ;
        Map<String,Object> contentBody = (Map<String,Object>)ConnectApi.ConnectUtilities.unwrapApexWrapper(newsf);
        String strURLfrmCMS=(String)contentBody.get('url');
        strtitleinCMS=(String)cmsDelivery.contentBody.get('altText') ;
        if(strURLfrmCMS!=requestWrapper.strImageURL)
        {
            //ConnectApi.ManagedContent.createManagedContent(contedocuInput);
            // product-media update also
           
        }
        else if(strtitleinCMS==requestWrapper.strTitle) {

           //ConnectApi.ManagedContent.replaceManagedContentVariantWithMedia(strContentVariantId,mediaInputcontentBody,null); 
        }
        }
        
        
        mediaInputcontentBody.title=title;//requestWrapper.strTitle;
        Blob data;
        //ConnectApi.BinaryInput contentData = new ConnectApi.BinaryInput(data,'sfdc_cms__image','NewImageOct23.jpg');
        Map<String,Object> sourceMap = new Map<String,Object>();
        sourceMap.put('type','url');
        sourceMap.put('url','https://www.emerson.com/resource/image/16674/portrait_ratio1x1/176/176/a9f8d2f05b87e56bf1f324ead97a0274/A2ED50ACB7531C28F9C9561E046CB45C/aprod-flow-micro-motion-hseries-pdp-family.jpg');
        //requestWrapper.strImageURL
        sourceMap.put('mimeType',null);
        
        Map<String,Object> level1Map = new Map<String,Object>();
        level1Map.put('altText',title);
        level1Map.put('sfdc_cms:media', sourceMap);
        
        ConnectApi.ManagedContentBodyInput variantInput = new ConnectApi.ManagedContentBodyInput();
        //variantInput.title = title;
        //variantInput.description = description;
        variantInput.nodeMap = level1Map;
        mediaInputcontentBody.contentBody=variantInput;
        //ConnectApi.ManagedContentNodeInput mediaNode = new ConnectApi.ManagedContentNodeInput();
        //mediaNode.body = mediaInput;
        //variantInput.nodeMap.put('Url', 'ImageURL');
        
        ConnectApi.ManagedContentVariant updatedVariant;
       
            //ManagedContentvariant mcVariantRecord= [SELECT Id,urlname,name,VariantType  from ManagedContentvariant Where Name=:requestBody.strTitle WITH SYSTEM_MODE];
            updatedVariant = ConnectApi.ManagedContent.replaceManagedContentVariantWithMedia(variantId, mediaInputcontentBody, null);
        }catch (ConnectApi.NotFoundException ex) {
            System.debug('ConnectApi.ManagedContent NotFoundException '+ex.getMessage() + ''+ex.getStackTraceString());
        } catch (ConnectApi.ConnectApiException ex) {
            System.debug('ConnectApi.ManagedContent ConnectApiException '+ex.getMessage() + ''+ex.getStackTraceString());
        } catch (Exception ex) {
            System.debug('ConnectApi.ManagedContent Exeception '+ex.getMessage() + ''+ex.getStackTraceString());
        }
        
    }
    public static void createCMSContent(){
        
        String variantId = '9PsD70000004EJoKAM';
        String title = 'NewImageOct24';
        
        ConnectApi.ManagedContentDocumentInput contedocuInput = new ConnectApi.ManagedContentDocumentInput();
        Blob data;
        ConnectApi.ManagedContentBodyInput contentBody=new ConnectApi.ManagedContentBodyInput();
        //ConnectApi.BinaryInput contentData = new ConnectApi.BinaryInput(data,'sfdc_cms__image','NewImageOct23.jpg');
        Map<String,Object> sourceMap = new Map<String,Object>();
        sourceMap.put('type','url');
        sourceMap.put('url','https://www.emerson.com/resource/image/16674/portrait_ratio1x1/176/176/a9f8d2f05b87e56bf1f324ead97a0274/A2ED50ACB7531C28F9C9561E046CB45C/aprod-flow-micro-motion-hseries-pdp-family.jpg');
        sourceMap.put('mimeType',null);
        
        Map<String,Object> level1Map = new Map<String,Object>();
        level1Map.put('altText',title);
        level1Map.put('sfdc_cms:media', sourceMap);
        contentBody.nodeMap=level1Map;
        contedocuInput.contentBody=contentBody;
        contedocuInput.contentSpaceOrFolderId='9PuD70000008crdKAA';
        contedocuInput.contentType='sfdc_cms__image ';
        contedocuInput.title=title;
        ConnectApi.ManagedContentDocument cmsCreate;
        try {
         cmsCreate=ConnectApi.ManagedContent.createManagedContent(contedocuInput);
        }
        catch (ConnectApi.ConnectApiException ex) {
            System.debug('ConnectApi.ManagedContent ConnectApiException '+ex.getMessage() + ''+ex.getStackTraceString());
        } catch (Exception ex) {
            System.debug('ConnectApi.ManagedContent Exeception '+ex.getMessage() + ''+ex.getStackTraceString());
        }
    
    }
    
}