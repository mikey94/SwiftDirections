//
//  ContentView.swift
//  Shared
//
//  Created by Buwaneka Ranatunga on 2022-02-07.
//

import SwiftUI
import MapKit
import CoreLocation

struct ContentView: View {

//    @State private var location: String = ""
//    @State private var region = MKCoordinateRegion(
//        center: CLLocationCoordinate2D(latitude: 37.334, longitude: -122.009), latitudinalMeters: 750, longitudinalMeters: 750
//    )
    @State private var directions: [String] = []
    @State private var showDirections = false
    var body: some View {
//        VStack {
//            HStack {
//                TextField("Location", text: $location)
//                    .accessibilityIdentifier("textFieldForAddress")
//                Button("Get Directions") {
//                    getAddress()
//                }
//            }
//            Map(coordinateRegion: $region)
//                .accessibilityIdentifier("textFieldForAddress")
//        }
        VStack {
            MapView(directions: $directions)
            Button(action: {
            }, label: {
                Text("Show car")
            })
            Button(action: {
                self.showDirections.toggle()
            }, label: { Text("Show Directions") }).disabled(directions.isEmpty).padding()
        }.sheet(isPresented: $showDirections, content: {
            VStack {
                Text("Directions")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                
                Divider().background(Color.indigo)
                
                List {
                    ForEach(0..<self.directions.count, id: \.self) { i in
                        Text(self.directions[i])
                            .padding()
                    }
                }
            }
        })
    }
    
//    func getAddress() {
//        let geoCoder = CLGeocoder()
//        geoCoder.geocodeAddressString(location) { (placemarks,error) in
//            guard let placemarks = placemarks,
//                    let location = placemarks.first?.location
//            else {
//                print("No Location found")
//                return
//            }
//            print(location)
//        }
//
//    }
}

struct MapView: UIViewRepresentable {
    typealias UIViewType = MKMapView
    @Binding var directions: [String]
    
    @State private var startLocation = CLLocationCoordinate2D(latitude: 40.71, longitude: -74)
    @State private var endLocation = CLLocationCoordinate2D(latitude: 42.36, longitude: -71.05)
    
    func makeCoordinator() -> MapViewCoordinator {
        return MapViewCoordinator()
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        let region = MKCoordinateRegion(center: CLLocationCoordinate2DMake(40.71, -74), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
        
        mapView.setRegion(region, animated: true)
        
        let p1 = MKPlacemark(coordinate: startLocation)
        
        let p2 = MKPlacemark(coordinate: endLocation)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: p1)
        request.destination = MKMapItem(placemark: p2)
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        
        directions.calculate { response, error in
            guard let route = response?.routes.first else { return }
            mapView.addAnnotations([p1,p2])
            mapView.addOverlay(route.polyline)
            mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20), animated: true)
            self.directions = route.steps.map{ $0.instructions }.filter{ !$0.isEmpty }
            print("directions", self.directions)
        }
        let angle = angleFromCoordinates(firstCoordinate: startLocation, secondCoordinate: endLocation)
        print("angle",angle)
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
    }
    
    class MapViewCoordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .blue
            renderer.lineWidth = 5
            return renderer
        }
    }

    func angleFromCoordinates(firstCoordinate: CLLocationCoordinate2D, secondCoordinate: CLLocationCoordinate2D) -> Double {
        let deltaLongitude: Double = secondCoordinate.longitude - firstCoordinate.longitude
        let deltaLatitude: Double = secondCoordinate.latitude - firstCoordinate.latitude
        
        let angle = (Double.pi * 0.5) - atan(deltaLatitude/deltaLongitude)
        if (deltaLongitude > 0) {
            return angle
        } else if (deltaLongitude < 0) {
            return angle * Double.pi
        } else if (deltaLatitude < 0) {
            return Double.pi
        } else {
            return 0.0
        }
    }
    
    
}

struct CarModel: Codable {
    var oldLatitude: Double = 0.0
    var oldLongitude: Double = 0.0
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    enum CodingKeys: String, CodingKey {
        case latitude = "Latitude"
        case longitude = "Longitude"
    }
}
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
