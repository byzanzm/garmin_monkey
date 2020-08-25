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


    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.SectionTwoLayout(dc));
                
        var battHistory = Application.getApp().getProperty("battery");
        var battTimeStamp = Application.getApp().getProperty("battery_stamp");
        var utcNow = Time.now().value();
        
        var timeDelta;
        var hh;
        var mm;
        var burnRate;
        
        //XXX
        //battHistory = [90, 80, 78, 72, 89];
        //battTimeStamp = [1598256504, 1598320566, 1598335013, 1598350935, 1598351935];
        //battHistory = [90];
        //battTimeStamp = [1598256504];
        
        displayStr = "";
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
    

    function onUpdate(dc) {
        
        findDrawableById("BatteryHistory").setText(displayStr);

        View.onUpdate(dc);
    }
}
