public class ClientProtal_Index_Controller {
    // Holds the Account ID associated with the user
    public Id AccountId { get; set; }
    
    // Holds counts for different statuses of quoted works
    public Integer Quoted_Works_Compeleted { get; set; }
    public Integer Quoted_Works_In_Progress { get; set; }
    public Integer Quoted_Works_Awaiting_Client_Approval { get; set; }

    // Holds counts for different statuses of client portal stats
    public Integer Client_Portal_Stat_Completed { get; set; }
    public Integer Client_Portal_Stat_Due { get; set; }
    public Integer Client_Portal_Stat_OverDue { get; set; }

    // Holds total counts for quotes and stats
    public Integer totalQuotes { get; set; }
    public Integer totalStat { get; set; }
    
    // Lists and strings to hold calendar data in JSON format
    public List<String> CalendarString { get; set; }
    public String CalendarEvents { get; set; }
    public List<String> CalendarStringOne { get; set; }
    public String CalendarEventsOne { get; set; }
    public List<String> CalendarStringTwo { get; set; }
    public String CalendarEventsTwo { get; set; }
    public List<String> CalendarStringThree { get; set; }
    public String CalendarEventsThree { get; set; }
    public List<String> CalendarStringFour { get; set; }
    public String CalendarEventsFour { get; set; }
    public List<String> CalendarStringFive { get; set; }
    public String CalendarEventsFive { get; set; }
    
    // Constructor to initialize the controller and populate data
    public ClientProtal_Index_Controller() {
        // Initialize lists and strings for calendar events
        CalendarString = new List<String>();
        CalendarEvents = '';
        CalendarStringOne = new List<String>();
        CalendarEventsOne = '';
        CalendarStringTwo = new List<String>();
        CalendarEventsTwo = '';
        CalendarStringThree = new List<String>();
        CalendarEventsThree = '';
        CalendarStringFour = new List<String>();
        CalendarEventsFour = '';
        CalendarStringFive = new List<String>();
        CalendarEventsFive = '';
        
        // Fetch the Account ID associated with the current user
        AccountId = [SELECT Id, AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].AccountId;
        
        // Retrieve projects based on their status and created date within the last 90 days
        List<ERP7__Project__c> CompeQuotedProjs = [SELECT Id FROM ERP7__Project__c WHERE Account__c = :AccountId AND Project_Type__c NOT IN :setProjType AND ERP7__Status__c = 'Completed' AND CreatedDate = LAST_N_DAYS:90];
        List<ERP7__Project__c> CompeInProgProjs = [SELECT Id FROM ERP7__Project__c WHERE Account__c = :AccountId AND Project_Type__c NOT IN :setProjType AND ERP7__Status__c = 'In Progress' AND CreatedDate = LAST_N_DAYS:90];
        List<ERP7__Project__c> CompeAwaitingProjs = [SELECT Id FROM ERP7__Project__c WHERE Account__c = :AccountId AND Project_Type__c NOT IN :setProjType AND ERP7__Status__c = 'Awaiting Approval' AND CreatedDate = LAST_N_DAYS:90];
        
        // Retrieve schedules based on their completion status and scheduled date
        List<ERP7__Schedule__c> CompeQuotedSch = [SELECT Id FROM ERP7__Schedule__c WHERE Job_Complete__c = true AND Building__r.ERP7__Organisation__c = :AccountId AND ERP7__Asset__r.ERP7__Active__c = true AND ERP7__Asset__r.Statutory_Maintenance__c = 'Yes' AND Scheduled_Date_Reporting__c = NEXT_N_DAYS:30];
        List<ERP7__Schedule__c> CompeInProgSch = [SELECT Id, ERP7__Scheduled_Date__c, Name, Visit_Date_Time__c FROM ERP7__Schedule__c WHERE Job_Complete__c = false AND Overdue__c = false AND Building__r.ERP7__Organisation__c = :AccountId AND ERP7__Asset__r.ERP7__Active__c = true AND ERP7__Asset__r.Statutory_Maintenance__c = 'Yes' AND Scheduled_Date_Reporting__c = NEXT_N_DAYS:30];
        List<ERP7__Schedule__c> CompeAwaitingSch = [SELECT Id FROM ERP7__Schedule__c WHERE Overdue__c = true AND Building__r.ERP7__Organisation__c = :AccountId AND ERP7__Asset__r.ERP7__Active__c = true AND ERP7__Asset__r.Statutory_Maintenance__c = 'Yes' AND Scheduled_Date_Reporting__c = NEXT_N_DAYS:30];
        
        // Set counts for quoted works based on the retrieved projects
        Quoted_Works_Compeleted = CompeQuotedProjs.size();
        Quoted_Works_In_Progress = CompeInProgProjs.size();
        Quoted_Works_Awaiting_Client_Approval = CompeAwaitingProjs.size();
        
        // Set counts for client portal stats based on the retrieved schedules
        Client_Portal_Stat_Completed = CompeQuotedSch.size();
        Client_Portal_Stat_Due = CompeInProgSch.size();
        Client_Portal_Stat_OverDue = CompeAwaitingSch.size();
        
        // Calculate total counts for quotes and stats
        totalQuotes = CompeQuotedProjs.size() + CompeInProgProjs.size() + CompeAwaitingProjs.size();
        totalStat = CompeQuotedSch.size() + CompeInProgSch.size() + CompeAwaitingSch.size(); 
        
        // Loop through each schedule to format and add to calendar strings
        for (ERP7__Schedule__c s : CompeInProgSch) {    
            String sCal = '';   
            String sCalOne = '';
            String sCalTwo = '';
            String sCalThree = '';
            String sCalFour = '';
            String sCalFive = '';
            
            // If schedule has valid date, name, and visit time, format the calendar strings
            if (s.ERP7__Scheduled_Date__c != null && s.Name != null && s.Visit_Date_Time__c != null) { 
                sCal = '{"date": "' + String.valueOf(s.ERP7__Scheduled_Date__c) + '", "title": "' + String.valueOf(s.Name) + '", "time": "' + String.valueOf(s.Visit_Date_Time__c.format('h:mm a')) + '"}';
                sCalOne = '{"date": "' + String.valueOf(s.ERP7__Scheduled_Date__c) + '", "title": "' + String.valueOf(s.Name) + '", "time": "' + String.valueOf(s.Visit_Date_Time__c.format('h:mm a')) + '"}';
                sCalTwo = 'date: "' + String.valueOf(s.ERP7__Scheduled_Date__c) + '", title: "' + String.valueOf(s.Name) + '", time: "' + String.valueOf(s.Visit_Date_Time__c.format('h:mm a')) + '"';
                sCalThree = '{"date": "' + String.valueOf(s.ERP7__Scheduled_Date__c) + '", "title": "' + String.valueOf(s.Name) + '", "time": "' + String.valueOf(s.Visit_Date_Time__c.format('h:mm a')) + '"}';
                
                // Additional formatting based on the time of day
                if (s.Visit_Date_Time__c.hour() <= 12) {
                    sCalFour = '{"date": "' + String.valueOf(s.ERP7__Scheduled_Date__c) + '", "title": "' + String.valueOf(s.Name) + '", "time": "' + String.valueOf(s.Visit_Date_Time__c.format('h:mm a')) + '"}';
                    sCalFive = '{"date": "' + String.valueOf(s.ERP7__Scheduled_Date__c) + '", "title": "' + String.valueOf(s.Name) + '", "time": "' + String.valueOf(s.Visit_Date_Time__c.format('h:mm a')) + '"}';
                } else {  
                    sCalFour = '{"date": "' + String.valueOf(s.ERP7__Scheduled_Date__c) + '", "title": "' + String.valueOf(s.Name) + '", "time": "' + String.valueOf(s.Visit_Date_Time__c.format('h:mm a')) + '"}';
                    sCalFive = '{"date": "' + String.valueOf(s.ERP7__Scheduled_Date__c) + '", "title": "' + String.valueOf(s.Name) + '", "time": "' + String.valueOf(s.Visit_Date_Time__c.format('h:mm a')) + '"}';
                }
                
                // Add the formatted strings to their respective lists
                CalendarString.add(sCal); 
                CalendarStringOne.add(sCalOne);  
                CalendarStringTwo.add(sCalTwo);  
                CalendarStringThree.add(sCalThree); 
                CalendarStringFour.add(sCalFour);
                CalendarStringFive.add(sCalFive);
            }  
        }
        
        // Serialize the calendar event lists into JSON format strings
        // These strings are used to store the calendar data for different time slots or categories
        CalendarEvents = JSON.serialize(CalendarString);
        CalendarEventsOne = JSON.serialize(CalendarStringOne);
        CalendarEventsTwo = JSON.serialize(CalendarStringTwo);
        CalendarEventsThree = JSON.serialize(CalendarStringThree);
        CalendarEventsFour = JSON.serialize(CalendarStringFour);
        CalendarEventsFive = JSON.serialize(CalendarStringFive);
    }
}
