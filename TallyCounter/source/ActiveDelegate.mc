using Toybox.WatchUi;

class ActiveDelegate extends WatchUi.BehaviorDelegate {

    var activeSet = 1;


    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onPreviousPage() {
        //increment first counter
        if (gActiveSet == 1) {
            g_counter_1++;
        } else {
            g_counter_3++;
        }
 
        WatchUi.requestUpdate();
        
        return true;
    }

    function onNextPage() {
        //increment second counter
        if (gActiveSet == 1) {
            g_counter_2++;
        } else {
            g_counter_4++;
        }
        
        WatchUi.requestUpdate();
        
        return true;
    }
    
    function onSelect() {
        if (gActiveSet == 1) {
            gActiveSet = 2;
        } else {
            gActiveSet = 1;
        }
        
        WatchUi.requestUpdate();
       
    }
    
    function onBack() {
        //go back to main page
        WatchUi.popView(SLIDE_UP);
        
        return true;
    }

}