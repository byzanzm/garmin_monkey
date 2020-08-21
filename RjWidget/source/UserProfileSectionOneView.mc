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

const SECONDS_PER_HOUR = 3600;
const SECONDS_PER_MINUTE = 60;

class UserProfileSectionOneView extends WatchUi.View {

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
        View.initialize();

        mWeightPrefixStr = WatchUi.loadResource(Rez.Strings.WeightPrefix);
        mWeightUnitsStr = WatchUi.loadResource(Rez.Strings.GramUnits);
        mHeightPrefixStr = WatchUi.loadResource(Rez.Strings.HeightPrefix);
        mGenderPrefixStr = WatchUi.loadResource(Rez.Strings.GenderSpecifierPrefix);
        mFemaleStr = WatchUi.loadResource(Rez.Strings.GenderFemale);
        mMaleStr = WatchUi.loadResource(Rez.Strings.GenderMale);
        mHeightUnitsStr = WatchUi.loadResource(Rez.Strings.CMUnits);
        mWakeTimePrefixStr = WatchUi.loadResource(Rez.Strings.WakeTimePrefix);
        mItemNotSetStr = WatchUi.loadResource(Rez.Strings.ItemNotSet);
        
        Sensor.setEnabledSensors([Sensor.SENSOR_HEARTRATE, Sensor.SENSOR_TEMPERATURE]);
        Sensor.enableSensorEvents(method(:onSensor));
        
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
        findDrawableById("GenderLabel").setText(mTempStr);

        var info = ActivityMonitor.getInfo();
        var mStepsStr = "Steps: " + info.steps.format("%d");
        findDrawableById("HeightLabel").setText(mStepsStr);

        var mBattStr = "Batt: " + System.getSystemStats().battery.format("%.1f");
        findDrawableById("WakeTimeLabel").setText(mBattStr);

 /*
        var profile = UserProfile.getProfile();

        if (profile != null) {
            var hours;
            var minutes;
            var seconds;
            var string = mWeightPrefixStr + profile.weight.toString() + mWeightUnitsStr;
            //findDrawableById("WeightLabel").setText(string);

            string = mGenderPrefixStr;
            if (profile.gender == 0) {
                string += mFemaleStr;
            } else {
                string += mMaleStr;
            }
            //findDrawableById("GenderLabel").setText(string);

            string = mHeightPrefixStr + profile.height.toString() + mHeightUnitsStr;
            //findDrawableById("HeightLabel").setText(string);

            string = mWakeTimePrefixStr;
            if ((profile.wakeTime != null) && (profile.wakeTime.value() != null)) {
                hours = profile.wakeTime.divide(SECONDS_PER_HOUR).value();
                minutes = (profile.wakeTime.value() - (hours * SECONDS_PER_HOUR)) / SECONDS_PER_MINUTE;
                seconds = profile.wakeTime.value() - (hours * SECONDS_PER_HOUR) - (minutes * SECONDS_PER_MINUTE);
                string += hours.format("%02u") + ":" + minutes.format("%02u") + ":" + seconds.format("%02u");
            } else {
                string += mItemNotSetStr;
            }
            //findDrawableById("WakeTimeLabel").setText(string);
        }
*/

        View.onUpdate(dc);
    }
}
