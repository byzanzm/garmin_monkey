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

(:glance)
class UserProfileGlanceView extends WatchUi.GlanceView {

    var mWeightPrefixStr = null;
    var mWeightUnitsStr = null;
    var mHeightPrefixStr = null;
    var mGenderPrefixStr = null;
    var mFemaleStr = null;
    var mMaleStr = null;
    var mHeightUnitsStr = null;
    var mWakeTimePrefixStr = null;
    var mItemNotSetStr = null;
    var mTempStr = null;
    var mHrStr = null;

    function initialize() {
        GlanceView.initialize();
 
 /*
        Sensor.setEnabledSensors([Sensor.SENSOR_HEARTRATE, Sensor.SENSOR_TEMPERATURE]);
        Sensor.enableSensorEvents(method(:onSensor));
        
        mTempStr = "--";
        mHrStr = "--";
        
        System.println("Hello Monkey");   
        */  
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


    function onUpdate(dc) {
        var mySummaryText = "";
        var mySummaryText_line2 = "";
    
        var myTime = System.getClockTime(); // ClockTime object
        mySummaryText = ":" + myTime.sec.format("%02d");

        mySummaryText += ", " + System.getSystemStats().battery.format("%.1f") +"%";        
        
        var info = ActivityMonitor.getInfo();
        mySummaryText_line2 +=  info.steps.format("%d") + " steps";
        
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(2,2, Graphics.FONT_SMALL, mySummaryText, Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(2,dc.getHeight()/3, Graphics.FONT_MEDIUM, mySummaryText_line2, Graphics.TEXT_JUSTIFY_LEFT);
      
    }
}
