//
//   MapMeetingView.swift
//  WaspitoPlus
//
//  Created by Tamo Marvin Achiri   on 9/17/25.
//

import SwiftUI
import MapKit

struct MapMeetingView: UIViewRepresentable {
    var doctorCoordinate: CLLocationCoordinate2D
    var patientCoordinate: CLLocationCoordinate2D?

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.showsUserLocation = true
        map.delegate = context.coordinator
        map.userTrackingMode = .none
        return map
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)
        uiView.removeOverlays(uiView.overlays)

 
        let doctorAnnotation = MKPointAnnotation()
        doctorAnnotation.coordinate = doctorCoordinate
        doctorAnnotation.title = "Doctor"
        uiView.addAnnotation(doctorAnnotation)


        if let p = patientCoordinate {
            let patientAnnotation = MKPointAnnotation()
            patientAnnotation.coordinate = p
            patientAnnotation.title = "You"
            uiView.addAnnotation(patientAnnotation)


            let rect = MKMapRect(origin: MKMapPoint(doctorCoordinate), size: MKMapSize(width: 0, height: 0))
            uiView.showAnnotations([doctorAnnotation, patientAnnotation], animated: true)


            drawRoute(from: p, to: doctorCoordinate, on: uiView)
        } else {
            uiView.setCenter(doctorCoordinate, animated: true)
            uiView.setRegion(MKCoordinateRegion(center: doctorCoordinate, latitudinalMeters: 3000, longitudinalMeters: 3000), animated: true)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    private func drawRoute(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, on mapView: MKMapView) {
        let src = MKPlacemark(coordinate: from)
        let dst = MKPlacemark(coordinate: to)
        let req = MKDirections.Request()
        req.source = MKMapItem(placemark: src)
        req.destination = MKMapItem(placemark: dst)
        req.transportType = .automobile

        let directions = MKDirections(request: req)
        directions.calculate { resp, err in
            if let route = resp?.routes.first {
                DispatchQueue.main.async {
                    mapView.addOverlay(route.polyline)
                    mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 80, left: 40, bottom: 80, right: 40), animated: true)
                }
            }
        }
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let poly = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: poly)
                renderer.strokeColor = UIColor.systemGreen
                renderer.lineWidth = 5
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}

