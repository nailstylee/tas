public class AccountTriggerHandler {
    public static void handleAfterInsert(List<Account> newAccounts) {
        List<Case> casesToInsert = new List<Case>();

        for (Account acc : newAccounts) {
            Case newCase = new Case(
                OwnerId = acc.OwnerId,
                Origin = 'System',
                Priority = acc.Priority__c,
                Subject = acc.Name + ' - Onboarding',
                AccountId = acc.Id
            );
            casesToInsert.add(newCase);
        }

        if (!casesToInsert.isEmpty()) {
            insert casesToInsert;
        }
    }
}