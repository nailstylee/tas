@isTest
public class ContactCaseHandlerTest {
    @isTest
    static void testHandlePrimaryContactCaseUpdate() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Contact primaryContact = new Contact(
            FirstName = 'Primary',
            LastName = 'Contact',
            AccountId = testAccount.Id,
            Level__c = 'primary'
        );
        Contact secondaryContact = new Contact(
            FirstName = 'Secondary',
            LastName = 'Contact',
            AccountId = testAccount.Id,
            Level__c = 'secondary'
        );
        insert new List<Contact>{ primaryContact, secondaryContact };

        Case testCase = new Case(
            AccountId = testAccount.Id,
            Subject = 'Test Case',
            ContactId = null
        );
        insert testCase;

        primaryContact.Level__c = 'primary';
        update primaryContact;

        List<Contact> updatedContacts = [SELECT Id, Level__c, AccountId FROM Contact];
        Test.startTest();
        ContactCaseHandler.handlePrimaryContactCaseUpdate(updatedContacts);
        Test.stopTest();

        Case updatedCase = [SELECT Id, ContactId FROM Case WHERE Id = :testCase.Id];
        System.assertNotEquals(null, updatedCase.ContactId, 'Case ContactId should be updated');
        System.assertEquals(primaryContact.Id, updatedCase.ContactId, 'Case ContactId should match the primary Contact');
    }

    @isTest
    static void testHandlePrimaryContactCaseUpdate_NoUpdates() {
        Account testAccount = new Account(Name = 'Test Account No Updates');
        insert testAccount;

        Contact nonPrimaryContact = new Contact(
            FirstName = 'Non-Primary',
            LastName = 'Contact',
            AccountId = testAccount.Id,
            Level__c = 'secondary'
        );
        insert nonPrimaryContact;

        Case testCase = new Case(
            AccountId = testAccount.Id,
            Subject = 'Test Case No Updates',
            ContactId = null
        );
        insert testCase;

        List<Contact> updatedContacts = [SELECT Id, Level__c, AccountId FROM Contact];
        Test.startTest();
        ContactCaseHandler.handlePrimaryContactCaseUpdate(updatedContacts);
        Test.stopTest();

        Case unchangedCase = [SELECT Id, ContactId FROM Case WHERE Id = :testCase.Id];
        System.assertEquals(null, unchangedCase.ContactId, 'Case ContactId should remain null');
    }
}
