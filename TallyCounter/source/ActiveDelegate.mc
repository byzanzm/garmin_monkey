using Toybox.WatchUi;

class ActiveDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onPreviousPage() {
        //increment first counter
        g_counter_1++;
        System.println(g_counter_1);
        
        WatchUi.requestUpdate();
        
        return true;
    }

    function onNextPage() {
        //increment second counter
        g_counter_2++;
        
        WatchUi.requestUpdate();
        
        return true;
    }
    
    function onSelect() {
    }
    
    function onBack() {
        //go back to main page
        WatchUi.popView(SLIDE_UP);
        
        return true;
    }

}