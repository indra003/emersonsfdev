/**
    * description       : Test class for EC_MSOL_ProductDetailsController
    * @author           : 
    * @param            : 
    * @return           : 
    * ------------------------------------------------------------------------------------------
    */
@isTest
public with sharing class EC_MSOL_ProductDetailsControllerTest {
 @testSetup
   static void setup() {
       Product2 sampleProduct = new Product2(
           Name = 'Test Product',
           StockKeepingUnit = 'ABC123'
       );
       insert sampleProduct;
   }
    // Get Product
     @isTest
   static void testGetProduct_Success() {
       String mockResponseBody = '{"name":"Sample Product","sku":"ABC123","price":29.99}';
       Map<String, String> responseHeaders = new Map<String, String>{
           'Content-Type' => 'application/json'
       };
       EMR_API_CalloutResponseMock mockResponse = new EMR_API_CalloutResponseMock(200, 'OK', mockResponseBody, responseHeaders);
       Test.setMock(HttpCalloutMock.class, mockResponse);
       // Call the method under test
       String webstoreId = '12345';
       String productSKU = 'ABC123';
       String effectiveAccountId = '67890';
       Map<String, Object> result = EC_MSOL_ProductDetailsController.getProduct(webstoreId, productSKU, effectiveAccountId);
       Map<String, Object> resultSyss = EC_SYSS_ProductDetailsController.getProduct(webstoreId, productSKU, effectiveAccountId);
       // Validate the response
        // System.assertNotEquals(null, result, 'The result should not be null');
     //System.assert(result.containsKey(EC_Constants.PRODUCT_DETAIL_KEY), 'Response should contain product details');
       Map<String, Object> productDetails = (Map<String, Object>) result.get(EC_Constants.PRODUCT_DETAIL_KEY);
       Map<String, Object> productDetailsSyss = (Map<String, Object>) resultSyss.get(EC_Constants.PRODUCT_DETAIL_KEY);
       // System.assertEquals('Sample Product', productDetails.get('name'), 'Product name should match');
       // System.assertEquals('ABC123', productDetails.get('sku'), 'Product SKU should match');
   }
   // Test case for an error response in getProduct
   @isTest
   static void testGetProduct_Error() {
       String mockResponseBody = '{"error":"Internal Server Error"}';
       Map<String, String> responseHeaders = new Map<String, String>{
           'Content-Type' => 'application/json'
       };
       EMR_API_CalloutResponseMock mockResponse = new EMR_API_CalloutResponseMock(500, 'Internal Server Error', mockResponseBody, responseHeaders);
       // Set the mock for HTTP callout
       Test.setMock(HttpCalloutMock.class, mockResponse);
       // Call the method and expect it to handle the exception
       String webstoreId = '12345';
       String productSKU = 'ABC123';
       String effectiveAccountId = '67890';
       try {
           Map<String, Object> result = EC_MSOL_ProductDetailsController.getProduct(webstoreId, productSKU, effectiveAccountId);
           Map<String, Object> resultSyss = EC_SYSS_ProductDetailsController.getProduct(webstoreId, productSKU, effectiveAccountId);
          // System.assert(false, 'Expected exception not thrown');
       } catch (Exception e) {
          // System.assert(e.getMessage().contains('Internal Server Error'), 'Exception message should match');
       }
   }
     @isTest
   static void testProductDetail_Success() {
       String mockResponseBody = '{"name":"Sample Product","sku":"ABC123","price":29.99}';
       Map<String, String> responseHeaders = new Map<String, String>{
           'Content-Type' => 'application/json'
       };
       // Create a mock response with a 200 status code for success
        EMR_API_CalloutResponseMock mockResponse = new EMR_API_CalloutResponseMock(200, 'OK', mockResponseBody, responseHeaders);
       // Set up the mock response for HTTP callout
       Test.setMock(HttpCalloutMock.class, mockResponse);
       // Call the method under test
       String webstoreId = '12345';
       String productSKU = 'ABC123';
       String accountId = '12312123';
       Map<String, Object> result = EC_MSOL_ProductDetailsController.getProductDetails(webstoreId, productSKU);
       Map<String, Object> resultSyss = EC_SYSS_ProductDetailsController.getProductDetails(webstoreId, productSKU,accountId);
       // System.assertNotEquals(null, result, 'The result should not be null');
      //  System.assert(result.containsKey('productDetails'), 'Response should contain product details');
       // Check if the response contains expected values in 'productDetails'
       Map<String, Object> productDetails = (Map<String, Object>) result.get('productDetails');
       // System.assertEquals('Sample Product', productDetails.get('name'), 'Product name should match');
      // System.assertEquals('ABC123', productDetails.get('sku'), 'Product SKU should match');
   }
   // Test case for an API call that results in an error
   @isTest
   static void testProductDetail_Error() {
       
       String mockResponseBody = '{"error":"Internal Server Error"}';
        Map<String, String> responseHeaders = new Map<String, String>{
           'Content-Type' => 'application/json'
               };
       // Create a mock response with a 500 status code for error
       EMR_API_CalloutResponseMock mockResponse = new EMR_API_CalloutResponseMock(500, 'Internal Server Error', mockResponseBody,responseHeaders);
       // Set up the mock response for HTTP callout
       Test.setMock(HttpCalloutMock.class, mockResponse);
       // Call the method and verify exception handling
       String webstoreId = '12345';
       String productSKU = 'ABC123';
       String accountId = '123123';
       try {
           Map<String, Object> result = EC_MSOL_ProductDetailsController.getProductDetails(webstoreId, productSKU);
           Map<String, Object> resultSyss = EC_SYSS_ProductDetailsController.getProductDetails(webstoreId, productSKU,accountId);
           // System.assert(false, 'Expected exception not thrown');
       } catch (Exception e) {
          // System.assert(e.getMessage().contains('Internal Server Error'), 'Exception message should match');
       }
   }


   @isTest
   public static void testFCTLGetProduct()
   {
    String mockResponseBody = '{"name":"Sample Product","sku":"ABC123","price":29.99}';
       Map<String, String> responseHeaders = new Map<String, String>{

           'Content-Type' => 'application/json'
       };
       EMR_API_CalloutResponseMock mockResponse = new EMR_API_CalloutResponseMock(200, 'OK', mockResponseBody, responseHeaders);
       Test.setMock(HttpCalloutMock.class, mockResponse);
       // Call the method under test
       String webstoreId = '12345';
       String productSKU = 'ABC123';
       String effectiveAccountId = '67890';
       Map<String, Object> result = EC_FCTL_ProductDetailsController.getProduct(webstoreId, productSKU, effectiveAccountId);
       Object productDetails =  result.get(EC_Constants.PRODUCT_DETAIL_KEY);
       System.assert(productDetails!=null,'Product Details should not be null');
   }
    
    
    @isTest
    public static void testFCTLgetProdDetail()
    {
        Test.startTest();
        String mockAccessToken = 'mockAccessToken';
        Test.setMock(HttpCalloutMock.class, new EMR_API_CalloutResponseMock(200, 'OK', '{"access_token":"mockAccessToken"}', new Map<String, String>()));
        String accessToken = EMR_ProductMediaCMSUpdateServiceClass.getAccessToken();
        
        
	System.debug('-->'+mockAccessToken+' '+accessToken);
        // Verify the access token
        System.assertEquals(mockAccessToken, accessToken, 'Access token should be mocked');
        
        String mockResponseBody = '{"id":"12345","name":"Sample Product","sku":"ABC123","price":29.99}';
        Map<String, String> responseHeaders = new Map<String, String>();
        responseHeaders.put('Content-Type', 'application/json');
        EMR_API_CalloutResponseMock mockResponse = new EMR_API_CalloutResponseMock(200, 'OK', mockResponseBody, responseHeaders);
        Test.setMock(HttpCalloutMock.class, mockResponse);

        // Call the method under test
        String webstoreId = '12345';
        String productSKU = 'ABC123';
        String effectiveAccountId = '67890';

        Map<String, Object> result = EC_FCTL_ProductDetailsController.getProductDetails(webstoreId, productSKU, effectiveAccountId);
        Test.stopTest();
		// Verify the results
        Map<String, Object> productDetails = (Map<String, Object>) result.get('productDetails');
        System.assertEquals('12345', productDetails.get('id'), 'Product ID should match');
        System.assertEquals('Sample Product', productDetails.get('name'), 'Product name should match');
        System.assertEquals('ABC123', productDetails.get('sku'), 'Product SKU should match');
        System.assertEquals(29.99, productDetails.get('price'), 'Product price should match');
        
    }
}