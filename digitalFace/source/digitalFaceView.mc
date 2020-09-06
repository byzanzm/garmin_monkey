using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Time.Gregorian;

class digitalFaceView extends WatchUi.WatchFace {
    //var batt_history_refresh = 599;
    var batt_history_refresh = 600;
    var maxDataAge = 3661;
    
    var battRateStr = ".";

    function initialize() {
        WatchFace.initialize();
        
        // ====================================
        //debug
        /*
        var x = Application.getApp().getProperty("battery");
	    System.println(x);
	    x = Application.getApp().getProperty("battery_stamp");
        System.println(x);
        */
	    
        /*
        var utc_now = Time.now().value();
        var batt_now = System.getSystemStats().battery.toFloat();
        
         
		var battTimeStamp = [utc_now - (batt_history_refresh*3), 
                         utc_now - (batt_history_refresh*2),
                         utc_now - (batt_history_refresh*1),];
        var battHistory = [batt_now + 5, batt_now + 4, batt_now +2];
        Application.getApp().setProperty("battery", battHistory);
	    Application.getApp().setProperty("battery_stamp", battTimeStamp);
	    */
        // ====================================
        
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
        drawClock();

        drawDate();

        View.findDrawableById("Batt").setText(" " + System.getSystemStats().battery.format("%.1f") + "%");
        
        drawStatus();
        
        battHistory();

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }
    
    function drawClock() {
        // Get and show the current time
        var clockTime = System.getClockTime();
        var timeString = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%02d")]);
        //var view = View.findDrawableById("TimeLabel");
        //view.setText(timeString);
        View.findDrawableById("TimeHour").setText(clockTime.hour.format("%02d"));
        View.findDrawableById("TimeMin").setText(":"+clockTime.min.format("%02d"));
    }
    
    function drawDate() {
        var info = Gregorian.info(Time.now(), Time.FORMAT_LONG);
        var dateStr = Lang.format("$1$ $2$", [info.day_of_week, info.day]);
        View.findDrawableById("Date").setText(dateStr + " ");
    }

    function drawStatus() {
        var myStatus = "";
        var mySettings = System.getDeviceSettings();
         
        if (mySettings.alarmCount > 0) {
            myStatus += " A";
        }

        if (mySettings.notificationCount > 0) {
            myStatus += " N";
            if (mySettings.notificationCount > 1) {
                myStatus += "x" + mySettings.notificationCount;
            }
        }
        
        if (mySettings has :doNotDisturb) {
            if (mySettings.doNotDisturb) {
                myStatus += " DnD";
            }
        }
        
        if (mySettings.phoneConnected) {
            myStatus += " P";
        }
        
        View.findDrawableById("Status").setText(myStatus);
    }
    
    function battHistory() {
        
        // curr time and battery
        var utc_now = Time.now().value();
        var batt_now = System.getSystemStats().battery.toFloat();
                
        //get last time battery history taken
        var battTimeStamp = Application.getApp().getProperty("battery_stamp");
        var battHistory = Application.getApp().getProperty("battery");

        //if nothing in storage, then init value
        //or if now is in the past (debugging only?)
        if (battTimeStamp == null or utc_now < battTimeStamp[0]) {
	        Application.getApp().setProperty("battery", [batt_now]);
	        Application.getApp().setProperty("battery_stamp", [utc_now]);

	        battRateStr = "-i-";
	        
        } else if (batt_now > battHistory.reverse()[0]) {
        // reset if battery been charged
	        
	        Application.getApp().setProperty("battery", [batt_now]);
	        Application.getApp().setProperty("battery_stamp", [utc_now]);
	        
	        battRateStr = "-c-";
        } else if (utc_now - battTimeStamp.reverse()[0] >= batt_history_refresh) {
        // update if more than 10 minutes has passed since
           
            battHistory.add(batt_now);
            battTimeStamp.add(utc_now);
            System.println(utc_now);
            
            var oldestDataAge = utc_now - battTimeStamp[0];
            System.println("delta: " + oldestDataAge);
            if (oldestDataAge > maxDataAge) {
                battTimeStamp = battTimeStamp.slice(1,null);
                battHistory = battHistory.slice(1,null);
            }
                
            System.println(battTimeStamp + " " + battHistory);    
                
            //update storage    
            Application.getApp().setProperty("battery", battHistory);
	        Application.getApp().setProperty("battery_stamp", battTimeStamp);
	        
	        //compute burn rate
	        var dataAge = (utc_now - battTimeStamp[0])/60;
	        var battDiff = battHistory[0] - batt_now;
	        var battRate = battDiff / (dataAge.toFloat()/60);
	        
	        System.println("rate: " + dataAge + "/" + battRate);
	        //View.findDrawableById("BattHistory").setText(dataAge + "/" + battRate.format("%.1f") + "%");
	        battRateStr = dataAge + "/" + battRate.format("%.1f") + "%"; 
        } else {
        }
        
        
        View.findDrawableById("BattHistory").setText(battRateStr);
        
        /*
        var x = "";
        if (utc_now % 2 == 1) {
            x = ".";
        }
        View.findDrawableById("BattHistory").setText(x);
        */
    }
}
