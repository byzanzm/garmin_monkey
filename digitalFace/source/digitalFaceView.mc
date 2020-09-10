using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Time.Gregorian;

class digitalFaceView extends WatchUi.WatchFace {
    //var batt_history_refresh = 599;
    var batt_history_refresh = 600;
    var maxDataAge = 7800;
    
    var battRateStr = ".";
    var battRate2Str = "";

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

        //System.println("now:" + utc_now);
        //System.println("oldest data:" + battTimeStamp.reverse()[0]);
        //System.println("oldest data:" + battTimeStamp[0]);


        //if nothing in storage, then init value
        //or if now is in the past (debugging only?)
        if (battTimeStamp == null or utc_now < battTimeStamp.reverse()[0]) {
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
           
            // add latest value to array
            battHistory.add(batt_now);
            battTimeStamp.add(utc_now);
            
            //trim old value from array if needed
            var oldestDataAge = utc_now - battTimeStamp[0];
            if (oldestDataAge > maxDataAge) {
                battTimeStamp = battTimeStamp.slice(1,null);
                battHistory = battHistory.slice(1,null);
            }
                
            //update storage    
            Application.getApp().setProperty("battery", battHistory);
	        Application.getApp().setProperty("battery_stamp", battTimeStamp);

            System.println("delta: " + oldestDataAge);                
            System.println(battTimeStamp + " " + battHistory);    
	        
	        //compute burn rate to oldest data
            battRateStr = computeBurnRate(utc_now, batt_now, battTimeStamp[0], battHistory[0]);
            
            //compute burn rate to half oldest data
	        if (battTimeStamp.size() > 4) {
	            var p = battTimeStamp.size()/2;
	            battRate2Str = computeBurnRate(utc_now, batt_now, battTimeStamp[p], battHistory[p]);
	        }
	         
        } else {
        }
        
        View.findDrawableById("BattHistory").setText(battRateStr);
        View.findDrawableById("BattHistory2").setText(battRate2Str);
        
        /*
        var x = "";
        if (utc_now % 2 == 1) {
            x = ".";
        }
        View.findDrawableById("BattHistory").setText(x);
        */
        
         
    }
    
    function computeBurnRate(utc_now, batt_now, utc_point, batt_point) {
        //compute burn rate
        var dataAge = (utc_now - utc_point)/60;
        var battDiff = batt_point - batt_now;
        System.println("x "+dataAge);
        
        var battRate = 0;
        if (dataAge > 0) {
            var battRate = battDiff / (dataAge.toFloat()/60);
        }
        
        System.println("rate: " + dataAge + "/" + battRate);
	    //View.findDrawableById("BattHistory").setText(dataAge + "/" + battRate.format("%.1f") + "%");
	    return dataAge + "/" + battRate.format("%.1f") + "%";
        
        /*
                //compute burn rate
        var dataAge = (utc_now - battTimeStamp[0])/60;
        var battDiff = battHistory[0] - batt_now;
        System.println("x "+dataAge);
        
        var battRate = 0;
        if (dataAge > 0) {
            var battRate = battDiff / (dataAge.toFloat()/60);
        }*/
    
    }
}
