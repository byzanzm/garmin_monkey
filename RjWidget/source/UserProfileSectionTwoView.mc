//
// Copyright 2015-2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.UserProfile;

class UserProfileSectionTwoView extends WatchUi.View {
    var displayStr = "";

    function initialize() {
        View.initialize();
        
        updateBattHistory();
    }
    
    
    function updateBattHistory() {
	    // update battery history if more than one hour has passed
	    var batt_history_refresh = 3600;
	    
	    // only keep 4 + new one 
	    var batt_history_keep = 5;
    
        var utc_now = Time.now().value();
        
        //get last time battery history taken
        var battTimeStamp = Application.getApp().getProperty("battery_stamp");

        // update if more than 30 minutes has passed since
        if (utc_now - battTimeStamp.reverse()[0] > batt_history_refresh) {
	        var battHistory = Application.getApp().getProperty("battery");
	        
	        if (battHistory == null or battTimeStamp == null or battTimeStamp.size() != battHistory.size()) {
	            // create empty array if either new or history/size mismatch
	            battHistory = [];
	            battTimeStamp = [];
	        } else if (battHistory.size() > batt_history_keep) {
	            // if history is large, keep the last four
	            battHistory = battHistory.slice(batt_history_keep * -1,null);
	            battTimeStamp = battTimeStamp.slice(batt_history_keep * -1,null);
	        } else {
	            // no special steps needed
	        }
		               
	        System.println(battHistory);
	        System.println(battTimeStamp);
	        
	        //update battery history with current value
	        battHistory.add(System.getSystemStats().battery.toFloat());
	        battTimeStamp.add(Time.now().value());
	        
	        //set battery history back to storage
	        Application.getApp().setProperty("battery", battHistory);
	        Application.getApp().setProperty("battery_stamp", battTimeStamp);
        } else {
	        System.println("less than 60 minute passed");
        }
        
    }
    
    function analyzeBattUsage() {
        //XXX For debugging
        //battHistory = [90, 80, 78, 72, 89];
        //battTimeStamp = [1598256504, 1598320566, 1598335013, 1598350935, 1598351935];
        //battHistory = [90];
        //battTimeStamp = [1598256504];

        var timeDelta;
        var hh;
        var mm;
        var burnRate;
        
        //get battery history/time
        var battHistory = Application.getApp().getProperty("battery");
        var battTimeStamp = Application.getApp().getProperty("battery_stamp");

        for (var i=0; i<battHistory.size(); i++) {
            if (i == 0) {               
                displayStr += battHistory[i].format("%.1f") + "%, ";
                displayStr += "\n";    
            } else {
                timeDelta = battTimeStamp[i] - battTimeStamp[i-1];
                hh = timeDelta/3600;
                mm = (timeDelta%3600)/60;
               
                displayStr += battHistory[i].format("%.1f") + "%, ";
                displayStr += hh + "h" + mm + ", ";
                
                if (battHistory[i] >= battHistory[i-1]) {
                    displayStr += "--";
                } else {
                    burnRate = (battHistory[i-1]-battHistory[i])/(timeDelta.toFloat()/3600);
                    displayStr += burnRate.format("%0.1f") + "%";
                }
            
	            //System.println(hh+"h"+mm+" "+burnRate.format("%0.2f"));

               displayStr += "\n";
           }
        }    
    }

    
    function onLayout(dc) {
        setLayout(Rez.Layouts.SectionTwoLayout(dc));
                
        analyzeBattUsage();
    }
    

    function onUpdate(dc) {
        findDrawableById("BatteryHistory").setText(displayStr);

        View.onUpdate(dc);
    }
}
