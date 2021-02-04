//
//  MapCardView.swift
//  GoogleMapsSwiftUI
//
//  Created by Chris Arriola on 2/3/21.
//

import GoogleMaps
import SwiftUI

struct MapCardView: View {

  static let cities = [
    City(name: "San Francisco", coordinate: CLLocationCoordinate2D(latitude: 37.7576, longitude: -122.4194)),
    City(name: "Seattle", coordinate: CLLocationCoordinate2D(latitude: 47.6131742, longitude: -122.4824903)),
    City(name: "Singapore", coordinate: CLLocationCoordinate2D(latitude: 1.3440852, longitude: 103.6836164)),
    City(name: "Sydney", coordinate: CLLocationCoordinate2D(latitude: -33.8473552, longitude: 150.6511076)),
    City(name: "Tokyo", coordinate: CLLocationCoordinate2D(latitude: 35.6684411, longitude: 139.6004407))
  ]

  /// State for markers displayed on the map when the use taps at a location. This property gets
  /// reset whenever a new polygon is added to the map.
  @State var markers: [GMSMarker] = cities.map {
    let marker = GMSMarker(position: $0.coordinate)
    marker.title = $0.name
    return marker
  }

  @State var zoomInCenter: Bool = false
  @State var expandList: Bool = false
  @State var selectedMarker: GMSMarker?

  var body: some View {

    let scrollViewHeight: CGFloat = 150

    GeometryReader { geometry in
      ZStack(alignment: .top) {
        ExtractedView(zoomInCenter: $zoomInCenter, markers: $markers, selectedMarker: $selectedMarker)
          .frame(width: geometry.size.width, height: geometry.size.height - scrollViewHeight + 40)
          .blur(radius: 0)

        VStack(spacing: 0) {
          HStack(alignment: .center) {
            Rectangle()
              .frame(width: 25, height: 4, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
              .cornerRadius(10)
              .opacity(0.25)
              .padding(.vertical, 8)
          }
          .frame(width: geometry.size.width, height: 20, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
          .onTapGesture {
            self.expandList.toggle()
          }

          List {
              ForEach(0..<self.markers.count) { id in
                let marker = self.markers[id]
                Button(action: {
                  self.selectedMarker = marker
                  self.zoomInCenter = false
                }) {
                  Text(marker.title ?? "")
                }
              }
          }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .offset(
          x: 0,
          y: geometry.size.height - (expandList ? scrollViewHeight + 100 : scrollViewHeight)
        )
        .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
      }
    }
  }
}

struct ExtractedView: View {

  @Binding var zoomInCenter: Bool
  @Binding var markers: [GMSMarker]
  @Binding var selectedMarker: GMSMarker?

  var body: some View {
    GeometryReader { geometry in
      let diameter = zoomInCenter ? geometry.size.width : (geometry.size.height * 2)
      MapView(markers: $markers, selectedMarker: $selectedMarker, onAnimationEnded: {
        self.zoomInCenter = true
      })
      .clipShape(
        Circle()
          .size(
            width: diameter,
            height: diameter
          )
          .offset(
            CGPoint(
              x: (geometry.size.width - diameter) / 2,
              y: (geometry.size.height - diameter) / 2
            )
          )
      )
      .animation(.easeIn)
    }
  }
}

struct MapCardView_Previews: PreviewProvider {
    static var previews: some View {
        MapCardView()
    }
}
