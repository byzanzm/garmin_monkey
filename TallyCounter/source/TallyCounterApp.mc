using Toybox.Application;
using Toybox.WatchUi;

var gActiveSet = 1;
var g_counter_1 = 0;
var g_counter_2 = 0;
var g_counter_3 = 0;
var g_counter_4 = 0;
var g_et = 0;

class TallyCounterApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
        return [ new TallyCounterView(), new TallyCounterDelegate() ];
    }

}
