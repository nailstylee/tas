@isTest
public class ContactBirthdayTaskSchedulerTest {

    @testSetup
    static void setupTestData() {
        Account testAccount = new Account(
            Name = 'Test Account',
            Industry = 'Technology'
        );
        insert testAccount;

        Contact contactWithUpcomingBirthday = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            AccountId = testAccount.Id,
            Birthdate = Date.today().addYears(-25).addDays(2),
            OwnerId = UserInfo.getUserId(),
            MailingStreet = '123 Elm St',
            MailingCity = 'Springfield',
            MailingState = 'IL',
            MailingPostalCode = '62704',
            MailingCountry = 'USA'
        );
        insert contactWithUpcomingBirthday;

        Contact contactWithoutUpcomingBirthday = new Contact(
            FirstName = 'Jane',
            LastName = 'Smith',
            AccountId = testAccount.Id,
            Birthdate = Date.today().addYears(-30).addDays(-2),
            OwnerId = UserInfo.getUserId()
        );
        insert contactWithoutUpcomingBirthday;
    }

    @isTest
    static void testExecuteMethodCreatesTasks() {
        Test.startTest();
        ContactBirthdayTaskScheduler scheduler = new ContactBirthdayTaskScheduler();
        scheduler.execute(null);
        Test.stopTest();

        List<Task> createdTasks = [SELECT Id, Subject, Priority, ActivityDate, WhatId, Description
                                   FROM Task
                                   WHERE Subject LIKE '%Birthday!%'];
        
        System.assertEquals(1, createdTasks.size(), 'One Task should have been created.');

        Task createdTask = createdTasks[0];
        
        System.assert(createdTask.Subject.contains('John Doe Birthday!'), 'Task subject should contain Contact name and "Birthday!".');
        System.assertEquals('Low', createdTask.Priority, 'Task priority should be Low.');
        System.assertEquals(Date.today().addDays(2), createdTask.ActivityDate, 'Task due date should match Contact birthdate.');
        System.assertNotEquals(null, createdTask.WhatId, 'Task should be related to an Account.');
        System.assert(createdTask.Description.contains('The Mailing Address of the Contact is: 123 Elm St, Springfield, IL, 62704, USA'), 'Description should contain mailing address.');
        System.assert(createdTask.Description.contains('Consider making an appropriate gift. Today is the Birthdate of John Doe. He/She is now 25 years old.'), 'Description should contain birthday message.');
    }
}
