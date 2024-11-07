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
        String strContentId;
        String strtitleinCMS;
        List<String> lstContentIds=new List<String>();
        ConnectApi.ManagedContentDeliveryDocument cmsDelivery;
        Boolean boolFlag=false;
        try {
        String strReq=JSON.serialize(requestBody);
        EMR_ProductMediaCMSUpdateServiceClass.RequestWrapper requestWrapper = (EMR_ProductMediaCMSUpdateServiceClass.RequestWrapper) JSON.deserialize(strReq, EMR_ProductMediaCMSUpdateServiceClass.RequestWrapper.class);
        
        //read the request provided and check whether this content already present or not
        lstProdMedia=[ Select id,product.stockkeepingunit,ElectronicMediaid from productmedia 
                                where product.stockkeepingunit=:requestWrapper.strProductSKU
                                 and ElectronicMediaGroup.DeveloperName='productListImage' with security_enforced];
        if(!lstProdMedia.isEmpty())
        {
            
        cmsDelivery=ConnectApi.ManagedContentDelivery.getManagedContentForChannel('',lstProdMedia[0].ElectronicMediaid,true); // channel id will be dependent on the type of prod- fctl, syss
        strContentId=cmsDelivery.managedContentId;
        Object newsf= cmsDelivery.contentBody.get('sfdc_cms:media') ;
        Map<String,Object> contentBody = (Map<String,Object>)ConnectApi.ConnectUtilities.unwrapApexWrapper(newsf);
        String strURLfrmCMS=(String)contentBody.get('url');
        strtitleinCMS=(String)cmsDelivery.contentBody.get('altText') ;
        lstContentIds.add(strContentId);
        if(strURLfrmCMS!=requestWrapper.strImageURL)
        {
            createCMSContent(requestWrapper);
            boolFlag=true;
           
        }
        else if(strtitleinCMS==requestWrapper.strTitle) {
            ManagedContentVariant mcVariant=[select id,name,ManagedContentId from ManagedContentVariant where  ManagedContentId=:strContentId with security_enforced];
            updatecontent(requestWrapper,mcVariant.id) ;
            boolFlag=true;
        }
        if(boolFlag)
        {
        publishContent(lstContentIds);
        }
        }
        }   
        catch (ConnectApi.NotFoundException ex) {
            System.debug('ConnectApi.ManagedContent NotFoundException '+ex.getMessage() + ''+ex.getStackTraceString());
        } catch (ConnectApi.ConnectApiException ex) {
            System.debug('ConnectApi.ManagedContent ConnectApiException '+ex.getMessage() + ''+ex.getStackTraceString());
        } catch (Exception ex) {
            System.debug('ConnectApi.ManagedContent Exeception '+ex.getMessage() + ''+ex.getStackTraceString());
        }
        
    }
    /**
    * @description createCMSContent
    * @author hegoswami@deloitte.com | 10-25-2024 
    * @param requestWrapper 
    **/
    public static void createCMSContent(EMR_ProductMediaCMSUpdateServiceClass.RequestWrapper requestWrapper){
        
        
        ConnectApi.ManagedContentDocumentInput contedocuInput = new ConnectApi.ManagedContentDocumentInput();
        ConnectApi.ManagedContentBodyInput contentBody=new ConnectApi.ManagedContentBodyInput();
        Map<String,Object> sourceMap = new Map<String,Object>();
        sourceMap.put('type','url');
        sourceMap.put('url',requestWrapper.strImageURL);
         sourceMap.put('mimeType',null);
        
        map<string, object> level1map = new map<string, object>();
        level1map.put('source', (object)sourcemap);

        Map<String,Object> nodeMap = new Map<String,Object>();
        nodeMap.put('altText',requestWrapper.strTitle);
        nodeMap.put('sfdc_cms:media', level1map);
        contentBody.nodeMap=nodeMap;
        contedocuInput.contentBody=contentBody;
        contedocuInput.contentSpaceOrFolderId=requestWrapper.strStoreNameOrWorkSpaceId;
        contedocuInput.contentType='sfdc_cms__image ';
        contedocuInput.title=requestWrapper.strTitle;
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

    /**
    * @description updatecontent
    * @author hegoswami@deloitte.com | 10-25-2024 
    * @param requestWrapper 
    * @param strVariantId 
    **/
    public static void updatecontent(EMR_ProductMediaCMSUpdateServiceClass.RequestWrapper requestWrapper, String strVariantId){
        connectapi.ManagedContentVariantUpdateInput contedocuinput = new connectapi.ManagedContentVariantUpdateInput();
        connectapi.managedcontentbodyinput contentbody = new connectapi.managedcontentbodyinput();
        map<string, object> sourcemap = new map<string, object>();
        sourcemap.put('type', 'url');
        sourcemap.put('url', requestWrapper.strImageURL);
        sourcemap.put('mimeType', 'image/jpg');
        
        map<string, object> level1map = new map<string, object>();
        level1map.put('source', (object)sourcemap);
        
        map<string, object> nodemap = new map<string, object>();
        nodemap.put('altText',requestWrapper.strTitle);
        nodemap.put('sfdc_cms:media', (object)level1map); 
        
        
        contentbody.nodemap = nodemap;
        
        contedocuinput.contentbody = contentbody;
        contedocuinput.title = requestWrapper.strTitle;
        
        connectapi.ManagedContentVariant output = connectapi.managedcontent.replaceManagedContentVariant(strVariantId,contedocuinput);
        
        

    }


    /**
    * @description publishContent
    * @author hegoswami@deloitte.com | 10-25-2024 
    * @param lstContentIds 
    **/
    public static void publishContent(List<String> lstContentIds)
    {
        ConnectApi.ManagedContentPublishInput publishParam=new ConnectApi.ManagedContentPublishInput();
        publishParam.contentIds=lstContentIds;
        connectapi.managedcontent.publish(publishParam);
    }
    
}