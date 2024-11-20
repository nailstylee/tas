global class ContactBirthdayTaskScheduler implements Schedulable {
    global void execute(SchedulableContext ctx) {
        Date today = Date.today();
        Integer todayDay = today.day();
        Integer todayMonth = today.month();
        
        Date tomorrow = today.addDays(1);
        Integer tomorrowDay = tomorrow.day();
        Integer tomorrowMonth = tomorrow.month();
        
        Date dayAfterTomorrow = today.addDays(2);
        Integer dayAfterTomorrowDay = dayAfterTomorrow.day();
        Integer dayAfterTomorrowMonth = dayAfterTomorrow.month();

        List<Task> tasksToCreate = new List<Task>();

        // Query for birthdate matches today, tomorrow, or the day after (ignoring year)
        List<Contact> contacts = [
            SELECT Id, FirstName, LastName, Birthdate, OwnerId, AccountId, 
                   MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry
            FROM Contact
            WHERE 
                (DAY_IN_MONTH(Birthdate) = :todayDay AND CALENDAR_MONTH(Birthdate) = :todayMonth) OR
                (DAY_IN_MONTH(Birthdate) = :tomorrowDay AND CALENDAR_MONTH(Birthdate) = :tomorrowMonth) OR
                (DAY_IN_MONTH(Birthdate) = :dayAfterTomorrowDay AND CALENDAR_MONTH(Birthdate) = :dayAfterTomorrowMonth)
        ];

        for (Contact con : contacts) {
            Date nextBirthday = con.Birthdate.addYears(today.year() - con.Birthdate.year());
            if (nextBirthday < today) {
                nextBirthday = nextBirthday.addYears(1);
            }

            String mailingAddress = (con.MailingStreet != null ? con.MailingStreet + ', ' : '') +
                                    (con.MailingCity != null ? con.MailingCity + ', ' : '') +
                                    (con.MailingState != null ? con.MailingState + ', ' : '') +
                                    (con.MailingPostalCode != null ? con.MailingPostalCode + ', ' : '') +
                                    (con.MailingCountry != null ? con.MailingCountry : '');
            String comments = '';
            if (String.isBlank(mailingAddress)) {
                comments = 'The mailing address is unknown.\n';
            } else {
                comments = 'The Mailing Address of the Contact is: ' + mailingAddress + '.\n';
            }

            if (con.AccountId != null) {
                Account acc = [SELECT Name, Industry FROM Account WHERE Id = :con.AccountId LIMIT 1];
                comments += 'This Contact is an employee of ' + acc.Name;
                
                if (acc.Industry != null) {
                    comments += ', part of the ' + acc.Industry + ' Industry';
                }
                comments += '.\n';
            }

            comments += 'Consider making an appropriate gift. Today is the Birthdate of ' + con.FirstName + ' ' + con.LastName + '. He/She is now ' + 
                        (today.year() - con.Birthdate.year()) + ' years old.';

            Task newTask = new Task(
                Subject = con.FirstName + ' ' + con.LastName + ' Birthday!',
                OwnerId = con.OwnerId,
                Priority = 'Low',
                Status = 'Not Started',
                ActivityDate = nextBirthday,
                WhatId = con.AccountId,
                Description = comments
            );

            tasksToCreate.add(newTask);
        }

        if (!tasksToCreate.isEmpty()) {
            insert tasksToCreate;
        }
    }
}
