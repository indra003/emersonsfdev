/**
* Http Callout Mock for Testing of the EMR_API callouts
*
* @CreatedDate: January 19, 2022
* @Author: Pranay Mistry - Deloitte Digital
* @Modified:
* @ADO:
*/
@isTest
global class EMR_API_CalloutResponseMock implements HttpCalloutMock {

    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;

    private final HttpResponse response;
    private HttpRequest request;

    public EMR_API_CalloutResponseMock(HttpResponse response) {
        this.response = response;
    }

    public HttpResponse mockRespond(HttpRequest request) {
        this.request = request;
        return response;
    }

    public HttpRequest getRequest() {
        return request;
    }

    /**
     * constructor for the EMR_API_CalloutResponseMock class
     * @param code - http status code to return
     * @param status - http status related to the code
     * @param body - response body, tyically JSON
     * @param responseHeadersMap - header map as part of response
    */
    public EMR_API_CalloutResponseMock(Integer code, String status, String body, Map<String, String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.body = body;
        this.responseHeaders = responseHeaders;
    }

    /**
     * setup the mock client response
     * @param req - the specific api request
    */
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        if(this.responseHeaders != null && this.responseHeaders.keySet() != null) {
            for (String key : this.responseHeaders.keySet()) {
                res.setHeader(key, this.responseHeaders.get(key));
            }
        }
        if(this.body == null) {
            this.body = 'test';
        }
        if(this.code == null) {
            this.code = 200;
        }
        if(this.status == null) {
            this.status = 'OK';
        }
        res.setBody(this.body);
        res.setStatusCode(this.code);
        res.setStatus(this.status);
        return res;
    }

}