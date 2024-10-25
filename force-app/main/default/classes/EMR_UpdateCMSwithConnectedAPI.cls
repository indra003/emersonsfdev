/**
 * @description       : 
 * @author            : hegoswami@deloitte.com
 * @group             : 
 * @last modified on  : 10-24-2024
 * @last modified by  : hegoswami@deloitte.com
**/
public without sharing class EMR_UpdateCMSwithConnectedAPI {
    
    public static void replaceManagedContentVariantWithMedia(){
        
        String variantId = '9PsD70000004EJoKAM';
        String title = 'NewImageOct23';
        
        ConnectApi.ManagedContentVariantUpdateInput mediaInputcontentBody = new ConnectApi.ManagedContentVariantUpdateInput();
        mediaInputcontentBody.title=title;
        Blob data;
        //ConnectApi.BinaryInput contentData = new ConnectApi.BinaryInput(data,'sfdc_cms__image','NewImageOct23.jpg');
        Map<String,Object> sourceMap = new Map<String,Object>();
        sourceMap.put('type','url');
        sourceMap.put('url','https://www.emerson.com/resource/image/16674/portrait_ratio1x1/176/176/a9f8d2f05b87e56bf1f324ead97a0274/A2ED50ACB7531C28F9C9561E046CB45C/aprod-flow-micro-motion-hseries-pdp-family.jpg');
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
        try {
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