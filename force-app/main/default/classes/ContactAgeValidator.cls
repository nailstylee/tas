public class ContactAgeValidator {
    public static void validateLegalAge(List<Contact> newContacts) {
        Map<String, Integer> countryAgeMap = new Map<String, Integer>();

        // Populate the countryAgeMap with custom metadata
        for (LegalAgeSetting__mdt ageSetting : [SELECT MasterLabel, MinimumAge__c FROM LegalAgeSetting__mdt]) {
            countryAgeMap.put(ageSetting.MasterLabel, Integer.valueOf(ageSetting.MinimumAge__c));
        }

        Set<Id> accountIds = new Set<Id>();
        for (Contact con : newContacts) {
            if (con.AccountId != null && con.Birthdate != null) {
                accountIds.add(con.AccountId);
            }
        }

        Map<Id, Account> accountsById = new Map<Id, Account>(
            [SELECT Id, BillingCountry FROM Account WHERE Id IN :accountIds]
        );

        Date today = Date.today();

        for (Contact con : newContacts) {
            if (con.Birthdate == null || con.AccountId == null) {
                continue;
            }

            Account account = accountsById.get(con.AccountId);

            Integer legalAge = countryAgeMap.containsKey(account.BillingCountry) ?
                countryAgeMap.get(account.BillingCountry) :
                countryAgeMap.get('Default');

            Integer contactAge = today.year() - con.Birthdate.year();

            // Adjust age if today's date is before the Contact's birthday this year
            if (today < con.Birthdate.addYears(contactAge)) {
                contactAge--;
            }

            if (contactAge < legalAge) {
                con.addError('All contact persons should be of legal age.');
            }
        }
    }
}
