import CoreLocation

protocol LocationConsuming: class {
    func locationDidUpdate(newLocation: CLLocation)
    func locationUnreachable()
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    static let sharedManager = LocationManager()
    private(set) var currentLocation: CLLocation?
    private let locManager = CLLocationManager()
    weak var delegate: LocationConsuming?
    
    private override init() {
        super.init()
        locManager.delegate = self
        locManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else { return }
        currentLocation = lastLocation
        delegate?.locationDidUpdate(newLocation: lastLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.locationUnreachable()
    }
    
    func requestWhenInUse(){
        locManager.requestWhenInUseAuthorization()
    }
}
