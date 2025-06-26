import SwiftUI
import MapKit
import CoreLocation

struct MapLocation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String
}

struct ContentView: View {
    @State private var city: String = ""
    @State private var country: String = ""
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0)
    )
    @State private var selectedLocation: MapLocation?

    var body: some View {
        VStack(spacing: 20) {
            TextField("Enter city", text: $city)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 200)

            TextField("Enter country", text: $country)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 200)

            Button("Show on Map") {
                geocodeLocation()
            }
            .padding()
            
            Map(coordinateRegion: $region, annotationItems: selectedLocation == nil ? [] : [selectedLocation!]) { item in
                MapMarker(coordinate: item.coordinate, tint: .red)
            }
            .edgesIgnoringSafeArea(.all)
        }
        .padding(.top, 40)
    }
    func geocodeLocation() {
        let address = "\(city), \(country)"
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let placemark = placemarks?.first,
            let location = placemark.location {
                let coordinate = location.coordinate
                region.center = coordinate
                selectedLocation = MapLocation(coordinate: coordinate, title: city)
            } else {
                print("Geocoding failed: \(error?.localizedDescription ?? "Unknown error")")
                }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
