using Toybox.WatchUi;

class TallyCounterDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onPreviousPage() {

    }

    function onNextPage() {

    }
    
    function onSelect() {
        WatchUi.pushView(new ActiveView(), new ActiveDelegate(), WatchUi.SLIDE_DOWN);
    }

}