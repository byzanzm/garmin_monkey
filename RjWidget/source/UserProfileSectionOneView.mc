//
// Copyright 2015-2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.UserProfile;
using Toybox.Sensor;
using Toybox.ActivityMonitor;
using Toybox.Application;
using Toybox.Time;

const SECONDS_PER_HOUR = 3600;
const SECONDS_PER_MINUTE = 60;

class UserProfileSectionOneView extends WatchUi.View {

    var mTempStr = null;
    var mHrStr = null;
    var battHistory = null;
    var battTimeStamp = null;

    function initialize() {
        View.initialize();

        // update battery history if more than one hour has passed
        var batt_history_refresh = 3600;
        
        // only keep 4 + new one 
        var batt_history_keep = 4;

        Sensor.setEnabledSensors([Sensor.SENSOR_HEARTRATE, Sensor.SENSOR_TEMPERATURE]);
        Sensor.enableSensorEvents(method(:onSensor));
        
        var utc_now = Time.now().value();
        
        //get last time battery history taken
        battTimeStamp = Application.getApp().getProperty("battery_stamp");

        // update if more than 30 minutes has passed since
        if (utc_now - battTimeStamp.reverse()[0] > batt_history_refresh) {
	        battHistory = Application.getApp().getProperty("battery");
	        
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
        
        mTempStr = "--";
        mHrStr = "--";
        
        System.println("Hello Monkey");
        
    }
    
    function onSensor(sensorInfo) {

        mTempStr = "Temp: --";
        mHrStr = "HR: --";

        if (sensorInfo.temperature != null) {
            mTempStr = "Temp: " + sensorInfo.temperature.format("%.1f");
        } 
        if (sensorInfo.temperature != null) {
            mHrStr = "HR: " + sensorInfo.heartRate;
        } 
        
        WatchUi.requestUpdate();
        
    }

    function onLayout(dc) {
        // load section-1-layout.xml
        setLayout(Rez.Layouts.SectionOneLayout(dc));
    }

    function onUpdate(dc) {
        var myTime = System.getClockTime(); // ClockTime object
        var timeAsStr = myTime.hour.format("%02d") + ":" +
                        myTime.min.format("%02d") + ":" +
                        myTime.sec.format("%02d");
        findDrawableById("ClockLabel").setText(timeAsStr);

        System.println("tempe:" +  mTempStr);
        System.println("HR:" +  mHrStr);
        findDrawableById("TemperatureLabel").setText(mTempStr);

        var info = ActivityMonitor.getInfo();
        var mStepsStr = "Steps: " + info.steps.format("%d");
        findDrawableById("StepsLabel").setText(mStepsStr);

        var mBattStr = "Batt: " + System.getSystemStats().battery.format("%.1f");
        findDrawableById("BattLabel").setText(mBattStr);


        View.onUpdate(dc);
    }
}
