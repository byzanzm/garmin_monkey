using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Time.Gregorian;

class digitalFaceView extends WatchUi.WatchFace {
    //var batt_history_refresh = 6;
    //var maxDataAge = 78;
    var batt_history_refresh = 600;
    var maxDataAge = 11400;

    var battRateStr = ".";
    var battRate2Str = "";
    var burnRate1 = [];
    var burnRate2 = [];

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
        
         
        var battTimeStamp = [utc_now - (batt_history_refresh*50),
                         utc_now - (batt_history_refresh*40),
                         utc_now - (batt_history_refresh*3),
                         utc_now - (batt_history_refresh*2),
                         utc_now - (batt_history_refresh*1),];
        var battHistory = [batt_now + 2, batt_now + 1.8, batt_now + 1.2,
                           batt_now + 1.1, batt_now + 0.05];
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

        //drawBattLevel();

        drawStatus();

        battHistory();

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        drawBattLevelG(dc);

        drawMinuteGraphics(dc);

        if (burnRate1.size() > 0) {
            drawBurnrate(dc, 130, 200, burnRate1[1]);
        }
        if (burnRate2.size() > 0) {
            drawBurnrate(dc, 80, 200, burnRate2[1]);
        }
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

        View.findDrawableById("TimeHour").setText(clockTime.hour.format("%02d"));
        View.findDrawableById("TimeMin").setText(":"+clockTime.min.format("%02d"));
    }

    function drawDate() {
        var info = Gregorian.info(Time.now(), Time.FORMAT_LONG);
        var dateStr = Lang.format("$1$ $2$", [info.day_of_week, info.day]);
        View.findDrawableById("Date").setText(dateStr + " ");
    }

    function drawBattLevel () {
        var battLevel = System.getSystemStats().battery;

        View.findDrawableById("Batt").setColor(Graphics.COLOR_WHITE);
        if (battLevel > 65) {
            View.findDrawableById("Batt").setColor(Graphics.COLOR_GREEN);
        } else if (battLevel < 45) {
            View.findDrawableById("Batt").setColor(Graphics.COLOR_YELLOW);
        }

        View.findDrawableById("Batt").setText(" " + System.getSystemStats().battery.format("%.1f") + "%");
    }

    function drawBattLevelG(dc) {
        var yPos = 167;
        var ySize = 2;
        var xStart = 45;
        var xEnd = 160;
        var markerSize = [3,12];

        var battLevel = System.getSystemStats().battery;

        // figure out the color for battery state
        var color = Graphics.COLOR_WHITE;
        var xSize = 10;
        if (battLevel > 75) {
            color = Graphics.COLOR_GREEN;
            var minLevel = 75;
            var sizeLevel = 25; //100-75

            xSize = ((battLevel-minLevel)/sizeLevel)*xEnd;
        } else if (battLevel < 40) {
            color = Graphics.COLOR_RED;
            var minLevel = 0;
            var sizeLevel = 40; //40-0

            xSize = ((battLevel-minLevel)/sizeLevel)*xEnd;
        } else {
            var minLevel = 40;
            var sizeLevel = 35; //75-40

            xSize = ((battLevel-minLevel)/sizeLevel)*xEnd;
        }

        //draw marker for start,mid,end state
        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(xStart, yPos-5, markerSize[0], markerSize[1]);
        dc.fillRectangle(xStart+xEnd, yPos-5, markerSize[0], markerSize[1]);
        dc.fillRectangle(xStart+(xEnd/2), yPos-5, markerSize[0], markerSize[1]);

        //draw the battery level
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(xStart, yPos, xSize, ySize);
        //dc.fillRectangle(xStart+xSize, yPos-5, markerSize[0], markerSize[1]);
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
            burnRate1 = [];

            battRate2Str = "";
            burnRate2 = [];
        } else if (batt_now > battHistory.reverse()[0]) {
        // reset if battery been charged

            Application.getApp().setProperty("battery", [batt_now]);
            Application.getApp().setProperty("battery_stamp", [utc_now]);

            battRateStr = "-c-";
            burnRate1 = [];

            battRate2Str = "";
            burnRate2 = [];
        } else if (utc_now - battTimeStamp.reverse()[0] >= batt_history_refresh) {
        // update if more than 10 minutes has passed since

            // add latest value to array
            battHistory.add(batt_now);
            battTimeStamp.add(utc_now);

            //trim old value from array if needed
            var oldestDataAge = utc_now - battTimeStamp[0];
            while (battTimeStamp.size() >4 and oldestDataAge > maxDataAge) {
                battTimeStamp = battTimeStamp.slice(1,null);
                battHistory = battHistory.slice(1,null);
                System.println("trim");
            }

            //update storage    
            Application.getApp().setProperty("battery", battHistory);
            Application.getApp().setProperty("battery_stamp", battTimeStamp);

            System.println("delta: " + oldestDataAge);                
            System.println(battTimeStamp + " " + battHistory);    

            //compute burn rate to oldest data
            burnRate1 = computeBurnRate(utc_now, batt_now, battTimeStamp[0], battHistory[0]);
            //battRateStr = burnRate1[0] + "__" + burnRate1[1].format("%.1f") + "%";
            battRateStr = burnRate1[0] + " " + burnRate1[1].format("%.1f") + "%";

            //compute burn rate to half oldest data
            burnRate2 =[];
            if (battTimeStamp.size() > 4) {
                var p = battTimeStamp.size()/2;
                burnRate2 = computeBurnRate(utc_now, batt_now, battTimeStamp[p], battHistory[p]);
                //battRate2Str = burnRate2[1].format("%.1f") + "% " +  burnRate2[0];
                battRate2Str = burnRate2[0] + " " + burnRate2[1].format("%.1f") + "%";
            }
        } else if (battRateStr.equals(".") and battTimeStamp.size() > 0) {
            //compute burn rate to oldest data
            burnRate1 = computeBurnRate(utc_now, batt_now, battTimeStamp[0], battHistory[0]);
            //battRateStr = burnRate1[0] + "__" + burnRate1[1].format("%.1f") + "%";
            battRateStr = burnRate1[0] + " " + burnRate1[1].format("%.1f") + "%";

            //compute burn rate to half oldest data
            burnRate2 =[];
            if (battTimeStamp.size() > 4) {
                var p = battTimeStamp.size()/3;
                burnRate2 = computeBurnRate(utc_now, batt_now, battTimeStamp[p], battHistory[p]);
                //battRate2Str = burnRate2[0] + "__" + burnRate2[1].format("%.1f") + "%";
                battRate2Str = burnRate2[0] + " " + burnRate2[1].format("%.1f") + "%";
            }
        } else {
        }

        View.findDrawableById("BattHistory").setText(battRate2Str + " " + battRateStr);
        //View.findDrawableById("BattHistory2").setText(battRate2Str);
    }

    function computeBurnRate(utc_now, batt_now, utc_point, batt_point) {
        //compute burn rate
        var dataAge = (utc_now - utc_point)/60;
        var battDiff = batt_point - batt_now;
        System.println("x "+dataAge);
        
        var battRate = 0;
        if (dataAge > 0) {
            battRate = battDiff / (dataAge.toFloat()/60);
        }
        
        System.println("rate: " + dataAge + "/" + battRate);

        return [dataAge, battRate];
    }

    function drawBurnrate(dc, xPos, yPos, br) {
        var xSize = 10;
        var yMax = 20;

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(xPos, yPos, xSize, yMax);

        var yVal = br - br.toNumber();
        var xVal = (br.toNumber()+1) * xSize;

        //if more than 1% we always show full height bar
        var ySize = yMax+1;
        if (br < 1) {
            ySize = (yVal * yMax) + 1;
        }

        //red color if br is more than 0.8%
        if (br > 0.8) {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        }

        dc.fillRectangle(xPos, yPos+yMax-ySize+1, xVal, ySize);
    }

    function drawMinuteGraphics(dc) {
        var clockTime = System.getClockTime();

        var pos = 360-(clockTime.min*6);
        pos = pos + 90;

        dc.setPenWidth(10);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, dc.getHeight()/2, Graphics.ARC_COUNTER_CLOCKWISE, pos-45, pos+45);

        dc.setPenWidth(30);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, dc.getHeight()/2, Graphics.ARC_COUNTER_CLOCKWISE, pos-1, pos+1);
    }

}
