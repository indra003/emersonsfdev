/**
* Apex Core API Class to facilitate making API calls from Apex API Client classes
* @CreatedDate: January 18, 2023
* @Author: Pranay Mistry - Deloitte Digital.
* @Modified:
*    Pranay Mistry on January 18, 2023 - 
*       Added Logic in toReturnValue to check for contentType.containsIgnoreCase('application/json') instead of contentType == 'application/json'
* @StoryURL:
*/

public with sharing class EMR_API {
    private static final String HEADER_CONTENT_TYPE = 'Content-Type';
    private static final String HEADER_ACCEPT = 'Accept';
    private static final String HEADER_ACCEPT_DELIMITER = ',';
    private static final Map<String, String> DELIMITERS = new Map<String, String> {
        'csv' => ',',
        'ssv' => ' ',
        'tsv' => '\t',
        'pipes' => '|'
    };

    /**
     * class to represent api parameters encoded as UTF-8
    */
	public class Param {
        private String name, value;
        public Param(String name, String value) {
            this.name = name;
            this.value = value;
        }
        public override String toString() {
            return EncodingUtil.urlEncode(name, 'UTF-8') + '=' + EncodingUtil.urlEncode(value, 'UTF-8');
        }
    }

    /**
     * interface for defining authentication
    */
    public interface Authentication {
        void apply(Map<String, Object> headers, List<Param> query);
    }

    /**
     * interface for defining mapped properties
    */
    public interface MappedProperties {
        Map<String, String> getPropertyMappings();
    }

    /**
     * abstract class for implementing api key/dictionary based authentications
    */
    public abstract class ApiKeyAuth implements Authentication {
        protected final String paramName;
        protected String key = '';

        public void setApiKey(String key) {
            this.key = key;
        }
        
        @TestVisible
        private String getApiKey() {
            return key;
        }
    }

    /**
     * abstract class for implementing api query-key based authentications
    */
    public class ApiKeyQueryAuth extends ApiKeyAuth {
        public ApiKeyQueryAuth(String paramName) {
            this.paramName = paramName;
        }

        public void apply(Map<String, Object> headers, List<Param> query) {
            query.add(new Param(paramName, key));
        }
    }

    /**
     * class defining the api key header authorization setup
    */
    public class ApiKeyHeaderAuth extends ApiKeyAuth {
        public ApiKeyHeaderAuth(String paramName) {
            this.paramName = paramName;
        }

        public void apply(Map<String, Object> headers, List<Param> query) {
            headers.put(paramName, key);
        }
    }

    /**
     * class for api exceptions
    */
    public class ApiException extends Exception {
        public final Integer code;
        public final String status;
        public final Map<String, String> headers;
        public final String body;

        /**
         * constructor for the api exception class
         * @param code - http status code
         * @param status - http status value
         * @param headers - map of callout response header values
         * @param body - callout response body
        */
        public ApiException(Integer code, String status, Map<String, String> headers, String body) {
            this('API returned HTTP ' + code + ': ' + status);
            this.code = code;
            this.status = status;
            this.headers = headers;
            this.body = body;
        }

        /**
         * property getters
        */
        public Integer getStatusCode() {
            return code;
        }

        public String getStatus() {
            return status;
        }

        public Map<String, String> getHeaders() {
            return headers;
        }

        public String getBody() {
            return body;
        }
    }

    /**
     * class for the api client
    */
	public virtual class ApiClient {
		protected String preferredContentType = 'application/json';
		protected String oAuthTokenGenerationContentType = 'application/x-www-form-urlencoded';
        protected String preferredAccept = 'application/json';
        protected final String basePath;
        protected final String calloutName;

        @TestVisible
        public String getPreferredContentType(){
        	return preferredContentType;
        }

		@TestVisible
        public String getOAuthTokenGenerationContentType(){
        	return oAuthTokenGenerationContentType;
        }

        @TestVisible
        protected final Map<String, Authentication> authentications = new Map<String, Authentication>();

        /**
         * gets the api authentication that was set by auth name
         * @param authName - authentication type/name
        */
		public virtual Authentication getAuthentication(String authName) {
            return authentications.get(authName);
        }

        /**
         * sets the api key for authentication
         * @param apiKey - api key
        */
		public virtual void setApiKey(String apiKey) {
            for (Authentication auth : authentications.values()) {
                if (auth instanceof ApiKeyAuth) {
                    ((ApiKeyAuth) auth).setApiKey(apiKey);
                    return;
                }
            }
            throw new NoSuchElementException('No API key authentication configured!');
        }

        /**
         * adds api parameters
         * @param name - parameter name
         * @param values - parameter values
        */
		public List<Param> makeParams(String name, List<Object> values) {
            List<Param> pairs = new List<Param>();
            for (Object value : new List<Object>(values)) {
                pairs.add(new Param(name, String.valueOf(value)));
            }
            return pairs;
        }

        /**
         * adds api parameters
         * @param name - parameter name
         * @param values - parameter values
         * @param format - delimiter type
        */
        public List<Param> makeParam(String name, List<Object> values, String format) {
            List<Param> pairs = new List<Param>();
            if (values != null) {
                String delimiter = DELIMITERS.get(format);
                pairs.add(new Param(name, String.join(values, delimiter)));
            }
            return pairs;
        }

        /**
         * adds parameter
         * @param name - parameter name
         * @param value - parameter value
        */
        public List<Param> makeParam(String name, Object value) {
            List<Param> pairs = new List<Param>();
            if (value != null) {
                pairs.add(new Param(name, String.valueOf(value)));
            }
            return pairs;
        }

        /**
         * assertion of not null, throws exceptions
         * @param required - object to assert (parameter value)
         * @param parameterName - parameter being tested
        */
        public virtual void assertNotNull(Object required, String parameterName) {
            if (required == null) {
                Exception e = new NullPointerException();
                e.setMessage('Argument cannot be null: ' + parameterName);
                throw e;
            }
        }

        /**
         * invoke the callout to the external system
         * @param method - method type: GET, PUT, POST, ETC
         * @param path - path of the callout url
         * @param body - callout body
         * @param query - list of query parameters to include
         * @param form - list of form parameters to include
         * @param pathParams - map of path parameters
         * @param headers - map of additional headers
         * @param accepts - list of acceptable formats
         * @param contentTypes - list of content types included
         * @param authMethods - list of acceptable authorization methods
         * @param returnType - callout return type
         * @return object representing the response/result of the callout
        */
		public virtual Object invoke(String method, String path, Object body, List<Param> query, List<Param> form,
                Map<String, Object> pathParams, Map<String, Object> headers, List<String> accepts,
                List<String> contentTypes, List<String> authMethods, Type returnType, Boolean isBlobBody) {
			HttpResponse res = getResponse(method, path, body, query, form, pathParams, headers, accepts, contentTypes, authMethods, isBlobBody);
            Integer code = res.getStatusCode();
            Boolean isFailure = code / 100 != 2;
            if (isFailure) {
                throw new ApiException(code, res.getStatus(), getHeaders(res), res.getBody());
                
            }
			else if (returnType != null) {
                return toReturnValue(res.getBody(), returnType, res.getHeader('Content-Type'));
              
            }
			else if (returnType == null) {
                return res;                
			}
            return null;
        }

        /**
         * Gets the headers from the httpResponse
         * @param res - the http response
         * @return map of the header values
        */
		@TestVisible
        protected virtual Map<String, String> getHeaders(HttpResponse res) {
            Map<String, String> headers = new Map<String, String>();
			if(res != null && res.getHeaderKeys() != null) {
				List<String> headerKeys = res.getHeaderKeys();
				if(headerKeys != null && headerKeys.size() > 0) {
					for (String headerKey : headerKeys) {
						if(!String.isEmpty(headerKey)) {
							headers.put(headerKey, res.getHeader(headerKey));
						}
		            }
				}
			}
            return headers;
        }

        /**
         * Converts the response body to the specified type
         * @param body - the http response body
         * @param returnType - return type desired
         * @param contentType - contentType of the body
         * @return converted object
        */
		@TestVisible
        protected virtual Object toReturnValue(String body, Type returnType, String contentType) {   
            if ((contentType.containsIgnoreCase('application/json; charset=UTF-8'))) {  
                // Added space in between 'application/json; and charset=UTF-8' so that all application can run
                Object o = returnType.newInstance();
                if (o instanceof MappedProperties) { 
                    Map<String, String> propertyMappings = ((MappedProperties) o).getPropertyMappings();
                    for (String baseName : propertyMappings.keySet()) {
                        body = body.replaceAll('"' + baseName + '"\\s*:',
                            '"' + propertyMappings.get(baseName) + '":');
                    }
                }
                JsonParser parser = Json.createParser(body);
                parser.nextToken();
                return parser.readValueAs(returnType);
            }
           return body;
        }

        /**
         * Gets the httpResponse for the callout
         * @param method - method type: GET, PUT, POST, ETC
         * @param path - path of the callout url
         * @param body - callout body
         * @param query - list of query parameters to include
         * @param form - list of form parameters to include
         * @param pathParams - map of path parameters
         * @param headers - map of additional headers
         * @param accepts - list of acceptable formats
         * @param contentTypes - list of content types included
         * @param authMethods - list of acceptable authorization methods
         * @return httpResponse of the callout
        */
		@TestVisible
        protected virtual HttpResponse getResponse(String method, String path, Object body, List<Param> query, List<Param> form,
                Map<String, Object> pathParams, Map<String, Object> headers, List<String> accepts,
                List<String> contentTypes, List<String> authMethods, Boolean isBlobBody) {
         //Integer apiTimeOut = Integer.valueof(SC_Configuration__mdt.getInstance('SC_APITimeOut').SC_DataValue__c);
            HttpRequest req = new HttpRequest();
			if(authMethods != null && authMethods.size() > 0) {
				applyAuthentication(authMethods, headers, query);
			}
            req.setMethod(method);
			req.setEndpoint(toEndpoint(path, pathParams, query));
			String contentType = setContentTypeHeader(contentTypes, headers);
			setAcceptHeader(accepts, headers);
			setHeaders(req, headers);
            if (method != 'GET') {
				if(contentType.contains('application/x-www-form-urlencoded') && form != null && form.size() > 0) {
                    String decodedRequestBody = EncodingUtil.urlDecode(toBody(contentType, body, form), 'utf-8');
                    req.setBody(decodedRequestBody);
                }
				else {
                    if(isBlobBody) {
                        req.setBodyAsBlob(Blob.valueOf(String.valueOf(body)));
                    }
                    else {
                        String requestBody = toBody(contentType, body, form);
                        req.setBody(requestBody);  
                       req.setTimeout(60000);                    
                    }                    
				}
            }
            Logger.info('API Tracking: method :::: '+ req.getEndpoint());
            Logger.info('API Tracking: headers :::: '+ headers);
            Logger.info('API Tracking: body :::: '+ req.getBody());
            Logger.saveLog();
            return new Http().send(req);
        }

        /**
         * Sets the headers for the httpRequest
         * @param req - the http request
         * @param headers - map of header values
        */
		@TestVisible
        protected virtual void setHeaders(HttpRequest req, Map<String, Object> headers) {
            for (String headerName : headers.keySet()) {
                req.setHeader(headerName, String.valueOf(headers.get(headerName)));
            }
        }

        /**
         * Converts the body string to its base string from the contentType
         * @param contentType - the existing content type of the body
         * @param body - body value
         * @param form - form values
         * @return converted body value to string
        */
        @TestVisible
        protected virtual String toBody(String contentType, Object body, List<Param> form) {
            if (contentType.contains('application/x-www-form-urlencoded')) {
                return paramsToString(form);
            }
			else if (contentType.contains('application/json')) {
                //avoid double encoding by checking for valid JSON already
                try{
                    Object result = JSON.deserializeUntyped(String.valueOf(body));
                    return String.valueOf(body);
                }
                catch(Exception ex){
                    return Json.serialize(body);
                }
            }
            return String.valueOf(body);
        }

        /**
         * sets up the content type header acceptance
         * @param contentTypes - list of acceptable content type formats
         * @param headers - map of callout header values
        */
		@TestVisible
        protected virtual String setContentTypeHeader(List<String> contentTypes, Map<String, Object> headers) {
            if (contentTypes.isEmpty()) {
                headers.put(HEADER_CONTENT_TYPE, preferredContentType);
                return preferredContentType;
            }
            for (String contentType : contentTypes) {
                if (preferredContentType == contentType) {
                    headers.put(HEADER_CONTENT_TYPE, contentType);
                    return contentType;
                }
            }
            String contentType = contentTypes.get(0);
            headers.put(HEADER_CONTENT_TYPE, contentType);
            return contentType;
        }

        /**
         * sets up the header acceptance
         * @param accepts - list of acceptable formats
         * @param headers - map of callout header values
        */
		@TestVisible
        protected virtual void setAcceptHeader(List<String> accepts, Map<String, Object> headers) {
            for (String accept : accepts) {
                if (preferredAccept == accept) {
                    headers.put(HEADER_ACCEPT, accept);
                    return;
                }
            }
            if (!accepts.isEmpty()) {
                headers.put(HEADER_ACCEPT, String.join(accepts, HEADER_ACCEPT_DELIMITER));
            }
        }

        /**
         * applies authentication to the callout
         * @param names - list of authentication method names
         * @param headers - map of callout header values
         * @param query - list of SC_API params
        */
        @TestVisible
        protected virtual void applyAuthentication(List<String> names, Map<String, Object> headers, List<Param> query) {
            for (Authentication auth : getAuthMethods(names)) {
                auth.apply(headers, query);
            }
        }

        /**
         * gets the auth methods
         * @param names - list of authentication method names
         * @return list of Authentications setup
        */
		@TestVisible
        protected virtual List<Authentication> getAuthMethods(List<String> names) {
            List<Authentication> authMethods = new List<Authentication>();
            for (String name : names) {
                authMethods.add(authentications.get(name));
            }
            return authMethods;
        }

        /**
         * formats the parameters for passing into the url path
         * @param path - path with brace parameters
         * @return formatted path, removing the braces
        */
        @TestVisible
        protected virtual String toPath(String path, Map<String, Object> params) {
            String formatted = path;
            for (String key : params.keySet()) {
                formatted = formatted.replace('{' + key + '}', String.valueOf(params.get(key)));
            }
            return formatted;
        }

        /**
         * formats the callout endpoint string
         * @param path - callout path
         * @param params - callout parameters
         * @param queryParams - query string/url parameters
         * @return formatted endPoint path
        */
        @TestVisible
        protected virtual String toEndpoint(String path, Map<String, Object> params, List<Param> queryParams) {
            String query = '?' + paramsToString(queryParams);
            return 'callout:' + calloutName + toPath(path, params) + query.removeEnd('?');
        }

        /**
         * formats the query string parameters
         * @param path - list of params
         * @return formatted parameter string
        */
        @TestVisible
        protected virtual String paramsToString(List<Param> params) {
            String s = '';
            for (Param p : params) {
                s += '&' + p;
            }
            return s.removeStart('&');
        }
	}
}