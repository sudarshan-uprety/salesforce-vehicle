public with sharing class VehicleQuantityTriggerHandler {
    
    public static void updateQuantities(List<Booking__c> newBookings, Map<Id,Booking__c> oldMap) {
        // 1. Get affected vehicle IDs
        Set<Id> vehicleIds = new Set<Id>();
        for(Booking__c booking : newBookings) {
            if(booking.Vehicle__c != null) {
                vehicleIds.add(booking.Vehicle__c);
                // Handle vehicle changes in updates
                if(oldMap != null && oldMap.containsKey(booking.Id) && 
                   oldMap.get(booking.Id).Vehicle__c != null &&
                   booking.Vehicle__c != oldMap.get(booking.Id).Vehicle__c) {
                    vehicleIds.add(oldMap.get(booking.Id).Vehicle__c);
                }
            }
        }
        
        if(vehicleIds.isEmpty()) return;
        
        // 2. Count active bookings per vehicle
        Map<Id, Integer> vehicleBookedCounts = new Map<Id, Integer>();
        for(AggregateResult ar : [
            SELECT Vehicle__c vehId, COUNT(Id) bookingCount 
            FROM Booking__c 
            WHERE Vehicle__c IN :vehicleIds 
            AND Status__c IN ('Confirmed','Pending')
            GROUP BY Vehicle__c
        ]) {
            vehicleBookedCounts.put((Id)ar.get('vehId'), (Integer)ar.get('bookingCount'));
        }
        
        // 3. Update vehicle quantities
        List<Vehicle__c> vehiclesToUpdate = new List<Vehicle__c>();
        for(Id vehId : vehicleIds) {
            Integer bookedCount = vehicleBookedCounts.containsKey(vehId) ? 
                                vehicleBookedCounts.get(vehId) : 0;
            vehiclesToUpdate.add(new Vehicle__c(
                Id = vehId,
                Booked_Quantity__c = bookedCount
            ));
        }
        
        if(!vehiclesToUpdate.isEmpty()) {
            update vehiclesToUpdate;
        }
    }
}