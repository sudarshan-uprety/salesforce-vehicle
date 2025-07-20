trigger BookingTrigger on Booking__c (after insert, after update, after delete, after undelete) {
    if(Trigger.isAfter) {
        VehicleQuantityTriggerHandler.updateQuantities(
            Trigger.isDelete ? Trigger.old : Trigger.new,
            Trigger.oldMap
        );
    }
}