using Toybox.WatchUi;

class TallyCounterDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onPreviousPage() {
        g_counter_1++;
        System.println(g_counter_1);
        
        WatchUi.requestUpdate();
    }

    function onNextPage() {
        g_counter_2++;
        //System.println(g_counter_1);
        
        WatchUi.requestUpdate();
    }

}