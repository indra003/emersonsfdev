/**
 * @description       : 
 * @author            : hegoswami@deloitte.com
 * @group             : 
 * @last modified on  : 10-28-2024
 * @last modified by  : hegoswami@deloitte.com
**/
@RestResource(urlMapping='/cmsProduct/*')
global without sharing class EMR_CMSImageUpdate {
    private static final String PLP='ProductListImage';
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
    * @description productMediaHandler
    * @author hegoswami@deloitte.com | 10-25-2024 
    * @param requestBody 
    **/
    @HttpPost
    global static void productMediaHandler(RequestWrapper requestBody){
        ResponseWrapper resWrapper=new ResponseWrapper();
        RestResponse res = RestContext.response;
        List<ProductMedia> lstProdMedia=new List<ProductMedia>();
        String strContentId;
        //Object strtitleinCMS;
        List<String> lstContentIds=new List<String>();
        ConnectApi.ManagedContentDeliveryDocument cmsDelivery;
        // /ConnectApi.ManagedContentVariantUpdateInput mediaInputcontentBody = new ConnectApi.ManagedContentVariantUpdateInput();
        
        try {
        res.addHeader('Content-Type', 'application/json');
        String strReq=JSON.serialize(requestBody);
        RequestWrapper requestWrapper = (RequestWrapper) JSON.deserialize(strReq, RequestWrapper.class);
        
        //read the request provided and check whether this content already present or not
        lstProdMedia=[ Select id,product.stockkeepingunit,ElectronicMediaid from productmedia 
                                where product.stockkeepingunit=:requestWrapper.strProductSKU
                                 and ElectronicMediaGroup.DeveloperName=:PLP with security_enforced];
          
            /*if(requestWrapper.strStoreNameOrWorkSpaceId!=null && requestWrapper.strProductSKU!=null && requestWrapper.strTitle!=null&& requestWrapper.strImageURL!=null)
            {*/

                if(lstProdMedia.isEmpty())
                {
                    String strNewContentId=createCMSContent(requestWrapper);
                    lstContentIds.add(strNewContentId);
                    publishContent(lstContentIds,true);
                    createProdMedia(strNewContentId,requestWrapper.strProductSKU);
                    res.statuscode=201;
                    resWrapper.StatusCode=res.statuscode;
                    resWrapper.Message='cms created and linked to sku';

                }
                else if(!lstProdMedia.isEmpty()) {
                    ProductCategoryProduct pcRecord=[select id,Catalog.name from ProductCategoryProduct where product.stockkeepingunit=:requestWrapper.strProductSKU WITH SECURITY_ENFORCED];
                    string strProdStore=pcRecord.Catalog.name.replaceAll('Catalog','Channel');
                    ManagedContentChannel mChannel=[select id,name from ManagedContentChannel where name like: strProdStore WITH SECURITY_ENFORCED];

                   // cmsDelivery=ConnectApi.ManagedContentDelivery.getManagedContentForChannel(mChannel.id,lstProdMedia[0].ElectronicMediaid,true); // channel id will be dependent on the type of prod- fctl, syss
                   // strContentId=cmsDelivery.managedContentId;
                //Object newsf= cmsDelivery.contentBody.get('sfdc_cms:media') ;
                //Map<String,Object> contentBody = (Map<String,Object>)ConnectApi.ConnectUtilities.unwrapApexWrapper(newsf);
                //Object strURLfrmCMS=contentBody.get('url');
                //strtitleinCMS=cmsDelivery.contentBody.get('altText') ;
                    ManagedContentVariant mcVariant=[select id,name,ManagedContentId from ManagedContentVariant where  ManagedContentId=:lstProdMedia[0].ElectronicMediaid with security_enforced];
                    updatecontent(requestWrapper,mcVariant.id) ;
                    lstContentIds.add(mcVariant.id);
                    publishContent(lstContentIds,false);
                    resWrapper.Message='cms updated , which was already tagged  to the sku';
                    res.statuscode=200;
                }
       //     }
        }
              catch (ConnectApi.NotFoundException ex) {
            res.statuscode=204;
            resWrapper.Error='Not Found, '+ex.getMessage();
        } catch (ConnectApi.ConnectApiException ex) {
            res.statuscode=403;
            resWrapper.Error='Bad Request, '+ex.getMessage();
        } catch (Exception ex) {
            res.statuscode=400; 
            resWrapper.Error='Bad Request, '+ex.getMessage();
        }
        resWrapper.StatusCode=res.statuscode;
        res.responseBody=Blob.valueOf(JSON.serialize(resWrapper));
        
    }

    /**
    * @description To create product media rec when no rec was there
    * @author hegoswami@deloitte.com | 10-25-2024 
    * @param strContent 
    * @param strProdSKU 
    **/
    public static void createProdMedia(String strContent, String strProdSKU)
    {
	Product2 prodObjRec=[select id from product2 where stockkeepingunit=:strProdSKU with security_enforced] ;  
        ElectronicMediaGroup elecMediGrpId=[select id,name from ElectronicMediaGroup where DeveloperName=:PLP with security_enforced ];
        ProductMedia prodM=new ProductMedia( productid=prodObjRec.id,
                electronicmediaid=strContent,
                ElectronicMediaGroupId=elecMediGrpId.Id
               );
         if(Schema.sObjectType.ProductMedia.IsCreateable())  
         {   
        insert prodM;
         }
    
	}

    
    /**
    * @description 
    * @author hegoswami@deloitte.com | 10-28-2024 
    * @param requestWrapper 
    * @return string 
    **/
    public static string createCMSContent(RequestWrapper requestWrapper){
        
        ProductCategoryProduct pcRecord=[select id,Catalog.name from ProductCategoryProduct where product.stockkeepingunit=:requestWrapper.strProductSKU WITH SECURITY_ENFORCED];
        String strDevName=pcRecord.Catalog.name.replaceAll('&','');
        strDevName=strDevName.replaceAll(' ','');
        String  strFolderId=EMR_ContentFolderIds__mdt.getInstance(strDevName).EMR_ProductImageContentFolderId__c;
        ConnectApi.ManagedContentDocumentInput contedocuInput = new ConnectApi.ManagedContentDocumentInput();
        ConnectApi.ManagedContentBodyInput contentBody=new ConnectApi.ManagedContentBodyInput();
        Map<String,Object> sourceMap = new Map<String,Object>();
        sourceMap.put('type','url');
        sourceMap.put('url',requestWrapper.strImageURL);

         sourceMap.put('mimeType','image/jpg');
        
        map<string, object> level1map = new map<string, object>();
        level1map.put('source', (object)sourceMap);
		
        
        Map<String,Object> nodeMap = new Map<String,Object>();
        nodemap.put('altText',requestWrapper.strTitle);
        nodeMap.put('sfdc_cms:media',(object) level1map);
        
        contentBody.nodeMap=nodeMap;
        contedocuInput.contentBody=contentBody;
        contedocuInput.contentSpaceOrFolderId=strFolderId;//requestWrapper.strStoreNameOrWorkSpaceId;
        contedocuInput.contentType='sfdc_cms__image';
        contedocuInput.title=requestWrapper.strTitle;
        ConnectApi.ManagedContentDocument cmsCreate;
        cmsCreate=ConnectApi.ManagedContent.createManagedContent(contedocuInput);
        return cmsCreate.managedContentId;
    
    }

    /**
    * @description updatecontent
    * @author hegoswami@deloitte.com | 10-25-2024 
    * @param requestWrapper 
    * @param strVariantId 
    **/
    public static void updatecontent(RequestWrapper requestWrapper, String strVariantId){
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
        
       connectapi.managedcontent.replaceManagedContentVariant(strVariantId,contedocuinput);
        
        

    }


    /**
    * @description publishContent
    * @author hegoswami@deloitte.com | 10-25-2024 
    * @param lstContentIds 
    * @param boolIsCreated
    
    **/
    public static void publishContent(List<String> lstContentIds,Boolean boolIsCreated)
    {
        ConnectApi.ManagedContentPublishInput publishParam=new ConnectApi.ManagedContentPublishInput();
        if(boolIsCreated)
        {
        publishParam.contentIds=lstContentIds;
        }
        else{
            publishParam.variantIds=lstContentIds;  
        }
        connectapi.managedcontent.publish(publishParam);
    }

    /**
    * @description ResponseWrapper
    * @author hegoswami@deloitte.com | 10-18-2024 
    **/
    public class ResponseWrapper{
        /**
         * description StatusCode
         * return Integer
         */
        public Integer StatusCode{get;set;}

        /**
         * description Message
         * return String
         */
        public String Message{get;set;}

        /**
         * description Error
         * return String
         */
        public String Error{get;set;}
    }
    
}