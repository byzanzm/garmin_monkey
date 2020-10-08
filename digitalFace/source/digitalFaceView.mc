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
        
        //debug
        //debugBatteryValue();
    }

    //set battery history value for debug purpose
    function debugBatteryValue() {
        var utc_now = Time.now().value();
        var batt_now = System.getSystemStats().battery.toFloat();
        
         
        var battTimeStamp = [utc_now - (batt_history_refresh*24),
                         utc_now - (batt_history_refresh*6),
                         utc_now - (batt_history_refresh*3),
                         utc_now - (batt_history_refresh*2),
                         utc_now - (batt_history_refresh*1),];
        var battHistory = [batt_now + 5.3, batt_now + 5.9, batt_now + 1.6,
                           batt_now + 0.3, batt_now + 0.2];
        Application.getApp().setProperty("battery", battHistory);
        Application.getApp().setProperty("battery_stamp", battTimeStamp);
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

/*
        if (burnRate1.size() > 0) {
            drawBurnrate(dc, 130, 200, burnRate1[1], burnRate1[0], "R");
        }
        if (burnRate2.size() > 0) {
            drawBurnrate(dc, 120, 200, burnRate2[1], burnRate2[0], "L");
        }
*/
        drawBurnratev2(dc);

        drawMinuteGraphics(dc);
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
        // Load the custom font we use for drawing the 3, 6, 9, and 12 on the watchface.
        var font = WatchUi.loadResource(Rez.Fonts.id_font_robo);

        // Get and show the current time
        var clockTime = System.getClockTime();
        var timeString = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%02d")]);

        View.findDrawableById("TimeHour").setFont(font);
        View.findDrawableById("TimeHour").setText(clockTime.hour.format("%02d"));
        View.findDrawableById("TimeMin").setText(""+clockTime.min.format("%02d"));
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
        var yPos = 170;
        var ySize = 3;
        var xEnd = 140; //this is the full width
        var xStart = (dc.getWidth()/2)-(xEnd/2);

        var markerSize = [3,12];

        var battLevel = System.getSystemStats().battery;

        // figure out the color and bar len for battery state
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
        // bar len should be at least 3 px for ui visbility
        if (xSize < 7) {xSize = 7;}

        dc.setColor(color, Graphics.COLOR_TRANSPARENT);

        //draw marker for start,mid,end state
        dc.fillRectangle(xStart, yPos-5, markerSize[0], markerSize[1]);
        dc.fillRectangle(xStart+xEnd, yPos-5, markerSize[0], markerSize[1]);
        dc.fillRectangle(xStart+(xEnd/2), yPos-5, markerSize[0], markerSize[1]);

        //draw the battery level
        dc.fillRectangle(xStart, yPos, xSize, ySize);
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
            if (battTimeStamp.size() > 20) {
                battTimeStamp = battTimeStamp.slice(-19, null);
                battHistory = battHistory.slice(-19, null);
            }

            //update storage    
            Application.getApp().setProperty("battery", battHistory);
            Application.getApp().setProperty("battery_stamp", battTimeStamp);

            System.println("delta: " + oldestDataAge);                
            System.println(battTimeStamp + " " + battHistory);    

            //compute burn rate to oldest data
            /* Old text style burn rate info
            burnRate1 = computeBurnRate(utc_now, batt_now, battTimeStamp[0], battHistory[0]);
            battRateStr = burnRate1[0] + " " + burnRate1[1].format("%.1f") + "%";

            //compute burn rate to half oldest data
            burnRate2 =[];
            if (battTimeStamp.size() > 4) {
                //var p = battTimeStamp.size()/3;
                var p=3;
                burnRate2 = computeBurnRate(utc_now, batt_now, battTimeStamp.reverse()[p],
                            battHistory.reverse()[p]);
                battRate2Str = burnRate2[0] + " " + burnRate2[1].format("%.1f") + "%";
            }
            */
        } else if (battRateStr.equals(".") and battTimeStamp.size() > 0) {
            //compute burn rate to oldest data
            /* Old text style burn rate info
            burnRate1 = computeBurnRate(utc_now, batt_now, battTimeStamp[0], battHistory[0]);
            battRateStr = burnRate1[0] + " " + burnRate1[1].format("%.1f") + "%";

            //compute burn rate to half oldest data
            burnRate2 =[];
            if (battTimeStamp.size() > 4) {
                //var p = battTimeStamp.size()/3;
                var p=3;
                burnRate2 = computeBurnRate(utc_now, batt_now, battTimeStamp.reverse()[p],
                            battHistory.reverse()[p]);
                battRate2Str = burnRate2[0] + " " + burnRate2[1].format("%.1f") + "%";
            }
            */
        } else {
        }

        //View.findDrawableById("BattHistory").setText(battRate2Str + " " + battRateStr);
    }

    function computeBurnRate(utc_now, batt_now, utc_point, batt_point) {
        //compute burn rate
        var dataAge = (utc_now - utc_point)/60;
        var battDiff = batt_point - batt_now;
        //System.println("x "+dataAge);
        
        var battRate = 0;
        if (dataAge > 0) {
            battRate = battDiff / (dataAge.toFloat()/60);
        }
        
        //System.println("rate: " + dataAge + "/" + battRate);

        return [dataAge, battRate];
    }


    function computeBurnRatev2(utc_now, batt_now, utc_point, batt_point) {
        //compute burn rate
        var dataAge = (utc_now - utc_point)/60;
        var battDiff = batt_point - batt_now;

        var battRate = 0;
        if (dataAge > 0) {
            battRate = battDiff / (dataAge.toFloat()/60);
        }

        return battRate;
    }

    function drawBurnrate(dc, xPos, yPos, br, timePeriod, growDir) {
        var xSize = 10;
        var yMax = 20;

        //draw bar background
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        if (growDir.equals("L")) {
            dc.fillRectangle(xPos-xSize, yPos, xSize, yMax);
        } else{
            dc.fillRectangle(xPos, yPos, xSize, yMax);
        }

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

        // draw burn rate bar
        if (growDir.equals("L")) {
            dc.fillRectangle(xPos-xVal, yPos+yMax-ySize+1, xVal, ySize);
        } else {
            dc.fillRectangle(xPos, yPos+yMax-ySize+1, xVal, ySize);
        }

        // draw time period bar
        /*
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        if (growDir.equals("L")) {
            dc.fillRectangle(xPos-timePeriod, yPos - 5, timePeriod, 1);
        } else {
            dc.fillRectangle(xPos, yPos - 5, timePeriod, 1);
        }
        */
    }

    //draw burnrate graphic bar
    function drawBurnratev2(dc) {
        var utc_now = Time.now().value();
        var batt_now = System.getSystemStats().battery.toFloat();
        var battTimeStamp = Application.getApp().getProperty("battery_stamp");
        var battHistory = Application.getApp().getProperty("battery");
        var brVal = [-1,-1,-1,-1,-1,-1,-1];

        for(var i=0; i < battTimeStamp.size(); i++) {
            // calculate how old is the data in 30 minutes unit (60sec*30)
            var age_m = (utc_now - battTimeStamp[i])/(60*30);

            //organized the data for 30m, 1h, 2h, 3h, 4h, 5h,6h
            var br=0;
            if (age_m == 1) {
                br = computeBurnRatev2(utc_now, batt_now, battTimeStamp[i], battHistory[i]);
                brVal[0] = br;
            } else if (age_m == 2 or age_m == 3) {
                br = computeBurnRatev2(utc_now, batt_now, battTimeStamp[i], battHistory[i]);
                brVal[1] = br;
            } else if (age_m == 4 or age_m == 5) {
                br = computeBurnRatev2(utc_now, batt_now, battTimeStamp[i], battHistory[i]);
                brVal[2] = br;
            } else if (age_m == 6 or age_m == 7) {
                br = computeBurnRatev2(utc_now, batt_now, battTimeStamp[i], battHistory[i]);
                brVal[3] = br;
            } else if (age_m == 8 or age_m == 9) {
                br = computeBurnRatev2(utc_now, batt_now, battTimeStamp[i], battHistory[i]);
                brVal[4] = br;
            } else if (age_m == 10 or age_m == 11) {
                br = computeBurnRatev2(utc_now, batt_now, battTimeStamp[i], battHistory[i]);
                brVal[5] = br;
            } else if (age_m == 12 or age_m == 13) {
                br = computeBurnRatev2(utc_now, batt_now, battTimeStamp[i], battHistory[i]);
                brVal[6] = br;
            }
        }
        //System.println("br: " + brVal);

        var sizeMax = [80,15];
        var posOrigin = [(dc.getWidth()/2)-(sizeMax[0]/2),200];

        dc.setPenWidth(1);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(posOrigin[0], posOrigin[1], sizeMax[0], 1);

        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        for (var i=0; i < brVal.size(); i++) {
            if (brVal[i] >= 0) {
                //default bar width is 9, but make it thinner for the last half
                var bar_width = 12;
                var spacing = 3;

                //add two pixel space
                var x_offset = 0;
                if (i >= 4) {
                    // calc off set of the first three bar with wider width
                    x_offset = ((4*bar_width) + (4*spacing)) ;

                    bar_width = 7;
                    spacing = 2;
                    x_offset += ((i-4)*bar_width) + (spacing*(i-4));
                } else {
                    x_offset = (i*bar_width) + (i*spacing);
                }

                //calculate y height based on the burnrate, but cap at max height
                var y_size = (brVal[i]*sizeMax[1])/1;
                if (y_size < 1) {y_size = 1;} //at least 1 pixel
                if (y_size > sizeMax[1]) {y_size = sizeMax[1];} //at most sizeMax

                //use color to help visualize burnrate > 0.8
                if (brVal[i] > 5.5) {
                    dc.setColor(0x884444, Graphics.COLOR_TRANSPARENT);
                } else if (brVal[i] > 2.5) {
                    dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
                } else if (brVal[i] > 0.8) {
                    dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
                } else {
                    dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
                }

                //draw the bar
                dc.fillRectangle(posOrigin[0] + x_offset, posOrigin[1],
                                 bar_width-1 , y_size);

                //System.println("draw " + i + ":" + x_offset + "," + y_size);
            }
        }
    }

    //draw minutes "hand"
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
