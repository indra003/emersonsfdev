/**
* @author          : Aditya Anand
* @description     : This class is the Utility class 
*/

public without sharing class EMR_Utility {
    
        /**
    * @description      : This method remoces the specialcharacters from the string parameter  
    * @param    par     
    * @return   String    
    */  
    public static string removeSpecialCharacters(String par){
        string res;
        res=par.replace('-','');
        res=res.replace('_','');
        res=res.replace('@','');
        res=res.replace(' ','');
        return res;
    }

    /**
    * @description          : Given a community ID, returns the relavent webstore ID for use in B2B Commerce on lightning
    * @param  communityId   : The Id of the community from which the call originated
    * @return weStoreId     : The webStoreId corresponding to the community Id.
    */ 

    public static String communityIdToWebstoreId(String communityId) 
    { 
        String webStoreId;
        if(!test.isRunningTest()){
            webStoreId = [SELECT WebStoreId,Name,WebStore.Name FROM WebStoreNetwork WHERE NetworkId = :communityId LIMIT 1].WebStoreId;
        }
        return webStoreId;
    }

    /**
    * @description                   : Method to get the account id of user
    * @return accountId
    */    

    public static String getUserAccountID() {
        String accountId;
        try {
            id userId =UserInfo.getUserId();
            User contactData = [
                SELECT Contact.AccountId, AccountId
                FROM User
                WHERE Id = :userId with security_enforced
            ];
            accountId = (String) contactData.Contact.AccountId;
        } catch (Exception ex) {
            Logger.error(ex.getMessage());
            Logger.saveLog();
        }
        return accountId;
    }


    /**
    * @description                      : Method to check if given string is decimal type
    * @param s                          : The string to be checked
    * @return Boolean                   : Boolean value that tells if the string was decimal or not
    **/

    public static Boolean isNumeric(String s){
        Boolean returnValue = false;
        try{
            Decimal.valueOf(s);
            returnValue = true;
        } catch (Exception e) {
            Logger.error(e.getMessage());
            Logger.saveLog();
        }
        return returnValue;
    }

    /**
    * @description                      : Method to check if given string is valid email using regex
    * @param email
    * @return Boolean                   : Boolean value that tells if the string was valid email
    */
    public static Boolean validateEmail(String email) {
        Boolean res = true; 
        try{                    
            String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; 
            Pattern myPattern = Pattern.compile(emailRegex);
            Matcher myMatcher = myPattern.matcher(email);
            if (!myMatcher.matches()){
                res = false;
            } 
        }catch(Exception e){
            Logger.error(e.getMessage());
            Logger.saveLog();
        }
            return res;
    }


    /**
     * @description  Returns list of String based on list of fieldset member
     * @param    List<Schema.FieldSetMember> is used to get fieldPath
     * @return   List<String> 
     * @author   pbypureddy@deloitte.com
     * @date     10-21-2024
    */      

    public static List<String> getFieldPathFromFieldSetMember(List<Schema.FieldSetMember> listObjectFieldSetMember){
        List<String> listFieldPathString = new List<String>();
        for(Schema.FieldSetMember varFieldSetMember : listObjectFieldSetMember){
            listFieldPathString.add(varFieldSetMember.getFieldPath());
        }
        return listFieldPathString;
    }

}