trigger ContactTrigger on Contact (before insert, before update, after insert, after update) {
    if (Trigger.isBefore) {
        ContactAgeValidator.validateLegalAge(Trigger.new);
    }
    
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        ContactCaseHandler.handlePrimaryContactCaseUpdate(Trigger.new);
    }
}
