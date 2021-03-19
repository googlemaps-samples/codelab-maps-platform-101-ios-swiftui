// Copyright 2021 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  MapViewControllerBridge.swift
//  GoogleMapsSwiftUI
//
//  Created by Chris Arriola on 2/5/21.
//

import GoogleMaps
import SwiftUI

struct MapViewControllerBridge: UIViewControllerRepresentable {

  @Binding var markers: [GMSMarker]
  @Binding var selectedMarker: GMSMarker?
  var onAnimationEnded: () -> ()
  var mapViewWillMove: (Bool) -> ()

  func makeUIViewController(context: Context) -> MapViewController {
    let uiViewController = MapViewController()
    uiViewController.map.delegate = context.coordinator
    return uiViewController
  }

  func updateUIViewController(_ uiViewController: MapViewController, context: Context) {
    markers.forEach { $0.map = uiViewController.map }
    selectedMarker?.map = uiViewController.map
    animateToSelectedMarker(viewController: uiViewController)
  }

  func makeCoordinator() -> MapViewCoordinator {
    return MapViewCoordinator(self)
  }

  private func animateToSelectedMarker(viewController: MapViewController) {
    guard let selectedMarker = selectedMarker else {
      return
    }

    let map = viewController.map
    if map.selectedMarker != selectedMarker {
      map.selectedMarker = selectedMarker
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        map.animate(toZoom: kGMSMinZoomLevel)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          map.animate(with: GMSCameraUpdate.setTarget(selectedMarker.position))
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            map.animate(toZoom: 12)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
              onAnimationEnded()
            })
          })
        }
      } 
    }
  }

  final class MapViewCoordinator: NSObject, GMSMapViewDelegate {
    var mapViewControllerBridge: MapViewControllerBridge

    init(_ mapViewControllerBridge: MapViewControllerBridge) {
      self.mapViewControllerBridge = mapViewControllerBridge
    }

    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
      self.mapViewControllerBridge.mapViewWillMove(gesture)
    }
  }
}
