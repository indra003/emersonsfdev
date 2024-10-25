/**
 * @description       : 
 * @author            : hegoswami@deloitte.com
 * @group             : 
 * @last modified on  : 10-22-2024
 * @last modified by  : hegoswami@deloitte.com
**/
@RestResource(urlMapping='/cmsImage/*')
global without sharing class EMR_CMSImageUpdate {
    
    private static final String PLP='Product List Image';
    /**
    * @description 
    * @author hegoswami@deloitte.com | 10-15-2024 
    * @return ProductMedia 
    **/
    @HttpGet 
    global static ProductMedia  getMediarecord(){
        RestRequest req = RestContext.request;
        //RestResponse res = RestContext.response;
        String strProdId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
		ProductMedia prodMObjeRecord=[Select id,ElectronicMediaId,ProductId from ProductMedia where ProductID=:strProdId WITH SECURITY_ENFORCED ];
        return prodMObjeRecord; 
    }
    
    /**
    * @description 
    * @author hegoswami@deloitte.com | 10-15-2024 
    * @param strProductExternalId 
    * @param strContentId 
    * @return String 
    **/
    @HttpPut
    global static String updateProductMedia(String strProductExternalId,String strContentId) {
        List<ProductMedia> lstProductMedia=new List<ProductMedia>();
        RestResponse res = RestContext.response;
        Map<String, Object> responseBody = new Map<String, Object>();
        try{
            lstProductMedia=[select id,electronicmediaid from productmedia where product.stockkeepingunit=:strProductExternalId and ElectronicMediaGroup.Name=:PLP with security_enforced];
            Product2 prodObjRec=[Select id from Product2 where stockkeepingunit=:strProductExternalId with security_enforced];
        ManagedContentVariant contentObj=[select id,name,ManagedContentId from ManagedContentVariant where ManagedContentId=:strContentId  with security_enforced limit 1] ;
        ElectronicMediaGroup elecMediGrpId=[select id,name from ElectronicMediaGroup where name=:PLP with security_enforced ];
            if(!lstProductMedia.isEmpty())
            {
                lstProductMedia[0].electronicmediaid=contentObj.ManagedContentId;
                /*if(!Schema.sObjectType.ProductMedia.isUpdateable())
                {*/
                    update lstProductMedia[0];
                    res.statusCode = 200;
                    responseBody.put('status', 'success');
                    responseBody.put('message', 'Updated Successfully');
                    //responseBody.put('data', new List<String>{'Item1', 'Item2', 'Item3'});
               // }
                
                
			}
            else{
                ProductMedia pmRecord=new ProductMedia();
                pmRecord.productid=prodObjRec.id;
                pmRecord.electronicmediaid=contentObj.ManagedContentId;
                pmRecord.ElectronicMediaGroupId=elecMediGrpId.Id;
                insert pmRecord;
                res.statusCode = 200;
                responseBody.put('status', 'success');
                responseBody.put('message', 'Created Successfully');
                res.statusCode = 200;
              //  }
            }
        }
        catch(Exception ex)
        {
            res.statusCode = 400;
            responseBody.put('status', 'failed');
	}
    
    res.responseBody = Blob.valueOf(JSON.serialize(responseBody));
    return JSON.serialize(responseBody);
    }
}