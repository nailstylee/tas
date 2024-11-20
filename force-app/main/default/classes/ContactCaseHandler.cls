public class ContactCaseHandler {
    public static void handlePrimaryContactCaseUpdate(List<Contact> newContacts) {
        List<Case> casesToUpdate = new List<Case>();
        Set<Id> accountIds = new Set<Id>();

        for (Contact con : newContacts) {
            if (con.Level__c == 'primary' && con.AccountId != null) {
                accountIds.add(con.AccountId);
            }
        }

        if (!accountIds.isEmpty()) {
            List<Case> relatedCases = [SELECT Id, AccountId, ContactId FROM Case WHERE AccountId IN :accountIds];

            // Map Account IDs to the corresponding primary Contact IDs
            Map<Id, Id> primaryContactMap = new Map<Id, Id>();
            for (Contact con : newContacts) {
                if (con.Level__c == 'primary' && con.AccountId != null) {
                    primaryContactMap.put(con.AccountId, con.Id);
                }
            }

            // Associate primary Contacts with where ContactId is null
            for (Case c : relatedCases) {
                if (c.ContactId == null && primaryContactMap.containsKey(c.AccountId)) {
                    c.ContactId = primaryContactMap.get(c.AccountId);
                    casesToUpdate.add(c);
                }
            }

            if (!casesToUpdate.isEmpty()) {
                update casesToUpdate;
            }
        }
    }
}
