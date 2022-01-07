import UIKit
import JitsiMeetSDK

class JitsiViewController: UIViewController {
    
    @IBOutlet weak var videoButton: UIButton?
    
    fileprivate var pipViewCoordinator: PiPViewCoordinator?
    fileprivate var jitsiMeetView: JitsiMeetView?
    
    var eventSink:FlutterEventSink? = nil
    var roomName:String? = nil
    var serverUrl:URL? = nil
    var subject:String? = nil
    var audioOnly:Bool? = false
    var audioMuted: Bool? = false
    var videoMuted: Bool? = false
    var token:String? = nil
    var featureFlags: Dictionary<String, Any>? = Dictionary();
    
    
    var jistiMeetUserInfo = JitsiMeetUserInfo()
    
    override func loadView() {
        
        super.loadView()
    }
    
    @objc func openButtonClicked(sender : UIButton){
        
        //openJitsiMeetWithOptions();
    }
    
    @objc func closeButtonClicked(sender : UIButton){
        cleanUp();
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        
        //print("VIEW DID LOAD")
        self.view.backgroundColor = .black
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        openJitsiMeet();
    }
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let rect = CGRect(origin: CGPoint.zero, size: size)
        pipViewCoordinator?.resetBounds(bounds: rect)
    }
    
    func openJitsiMeet() {
        cleanUp()
        // create and configure jitsimeet view
        let jitsiMeetView = JitsiMeetView()
        
        
        jitsiMeetView.delegate = self
        self.jitsiMeetView = jitsiMeetView
        let options = JitsiMeetConferenceOptions.fromBuilder { (builder) in
            builder.welcomePageEnabled = true
            builder.room = self.roomName
            builder.serverURL = self.serverUrl
            builder.subject = self.subject
            builder.userInfo = self.jistiMeetUserInfo
            builder.audioOnly = self.audioOnly ?? false
            builder.audioMuted = self.audioMuted ?? false
            builder.videoMuted = self.videoMuted ?? false
            builder.setFeatureFlag("chat.enabled", withValue false)
            builder.setFeatureFlag("audio-focus.disabled", withValue true)
            builder.setFeatureFlag("audio-only.enabled", withValue false)
            builder.setFeatureFlag("calendar.enabled", withValue false)
            builder.setFeatureFlag("call-integration.enabled", withValue false)
            builder.setFeatureFlag("close-captions.enabled", withValue false)
            builder.setFeatureFlag("conference-timer.enabled", withValue true)
            builder.setFeatureFlag("filmstrip.enabled", withValue false)
            builder.setFeatureFlag("help.enabled", withValue false)
            builder.setFeatureFlag("invite.enabled", withValue true)
            builder.setFeatureFlag("ios.recording.enabled", withValue false)
            builder.setFeatureFlag("ios.screensharing.enabled", withValue false)
            builder.setFeatureFlag("android.screensharing.enabled", withValue false)
            builder.setFeatureFlag("speakerstats.enabled", withValue false)
            builder.setFeatureFlag("kick-out.enabled", withValue false)
            builder.setFeatureFlag("live-streaming.enabled", withValue false)
            builder.setFeatureFlag("lobby-mode.enabled", withValue false)
            builder.setFeatureFlag("meeting-name.enabled", withValue false)
            builder.setFeatureFlag("meeting-password.enabled", withValue false)
            builder.setFeatureFlag("notifications.enabled", withValue false)
            builder.setFeatureFlag("overflow-menu.enabled", withValue false)
            builder.setFeatureFlag("pip.enabled", withValue true)
            builder.setFeatureFlag("raise-hand.enabled", withValue false)
            builder.setFeatureFlag("reactions.enabled", withValue false)
            builder.setFeatureFlag("recording.enabled", withValue false)
            builder.setFeatureFlag("replace.participant", withValue false)
            builder.setFeatureFlag("resolution", withValue false)
            builder.setFeatureFlag("security-options.enabled", withValue false)
            builder.setFeatureFlag("server-url-change.enabled", withValue false)
            builder.setFeatureFlag("tile-view.enabled", withValue false)
            builder.setFeatureFlag("toolbox.alwaysVisible", withValue true)
            builder.setFeatureFlag("toolbox.enabled", withValue true)
            builder.setFeatureFlag("video-mute.enabled", withValue true)
            builder.setFeatureFlag("video-share.enabled", withValue false)
            builder.setFeatureFlag("video-share.enabled", withValue false)
            builder.token = self.token
            
            self.featureFlags?.forEach{ key,value in
                builder.setFeatureFlag(key, withValue: value);
            }
            
        }
        
        jitsiMeetView.join(options)
        
        // Enable jitsimeet view to be a view that can be displayed
        // on top of all the things, and let the coordinator to manage
        // the view state and interactions
        pipViewCoordinator = PiPViewCoordinator(withView: jitsiMeetView)
        pipViewCoordinator?.configureAsStickyView(withParentView: view)
        
        // animate in
        jitsiMeetView.alpha = 0
        pipViewCoordinator?.show()
    }
    
    func closeJitsiMeeting(){
        jitsiMeetView?.leave()
    }
    
    fileprivate func cleanUp() {
        jitsiMeetView?.removeFromSuperview()
        jitsiMeetView = nil
        pipViewCoordinator = nil
        //self.dismiss(animated: true, completion: nil)
    }
}

extension JitsiViewController: JitsiMeetViewDelegate {
    
    func conferenceWillJoin(_ data: [AnyHashable : Any]!) {
        //        print("CONFERENCE WILL JOIN")
        var mutatedData = data
        mutatedData?.updateValue("onConferenceWillJoin", forKey: "event")
        self.eventSink?(mutatedData)
    }
    
    func conferenceJoined(_ data: [AnyHashable : Any]!) {
        //        print("CONFERENCE JOINED")
        var mutatedData = data
        mutatedData?.updateValue("onConferenceJoined", forKey: "event")
        self.eventSink?(mutatedData)
    }
    
    func conferenceTerminated(_ data: [AnyHashable : Any]!) {
        //        print("CONFERENCE TERMINATED")
        var mutatedData = data
        mutatedData?.updateValue("onConferenceTerminated", forKey: "event")
        self.eventSink?(mutatedData)
        
        DispatchQueue.main.async {
            self.pipViewCoordinator?.hide() { _ in
                self.cleanUp()
                self.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
    func enterPicture(inPicture data: [AnyHashable : Any]!) {
        //        print("CONFERENCE PIP IN")
        var mutatedData = data
        mutatedData?.updateValue("onPictureInPictureWillEnter", forKey: "event")
        self.eventSink?(mutatedData)
        DispatchQueue.main.async {
            self.pipViewCoordinator?.enterPictureInPicture()
        }
    }
    
    func exitPictureInPicture() {
        //        print("CONFERENCE PIP OUT")
        var mutatedData : [AnyHashable : Any]
        mutatedData = ["event":"onPictureInPictureTerminated"]
        self.eventSink?(mutatedData)
    }
}