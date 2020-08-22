using Toybox.WatchUi;
using Toybox.Timer;

class TallyCounterView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function timerCallback() {
        WatchUi.requestUpdate();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.MainLayout(dc));
        
        var myTimer = new Timer.Timer();
        myTimer.start(method(:timerCallback), 5000, true);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
        var myTime = System.getClockTime(); // ClockTime object
        var szTime = myTime.hour.format("%02d") + ":" +
                        myTime.min.format("%02d") + ":" +
                        myTime.sec.format("%02d");
        findDrawableById("clock").setText(szTime);
    
        findDrawableById("counter_1").setText(g_counter_1.toString());
        
        findDrawableById("counter_2").setText(g_counter_2.toString());
        
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

}
