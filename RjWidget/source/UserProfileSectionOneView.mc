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


    function initialize() {
        View.initialize();

        //Sensor.setEnabledSensors([Sensor.SENSOR_HEARTRATE, Sensor.SENSOR_TEMPERATURE]);
        //Sensor.enableSensorEvents(method(:onSensor));

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

        //System.println("tempe:" +  mTempStr);
        //System.println("HR:" +  mHrStr);
        //findDrawableById("TemperatureLabel").setText(mTempStr);

        var info = ActivityMonitor.getInfo();
        var mStepsStr = "Steps: " + info.steps.format("%d");
        findDrawableById("StepsLabel").setText(mStepsStr);

        var mBattStr = "Batt: " + System.getSystemStats().battery.format("%.1f");
        findDrawableById("BattLabel").setText(mBattStr);


        View.onUpdate(dc);
    }
}
