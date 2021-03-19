// Copyright 2020 Google LLC
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


import GoogleMaps
import SwiftUI

/// The root view of the application displaying a map that the user can interact with and a
/// button where the user
struct ContentView: View {
  static let cities = [
    City(name: "San Francisco", coordinate: CLLocationCoordinate2D(latitude: 37.7576, longitude: -122.4194)),
    City(name: "Seattle", coordinate: CLLocationCoordinate2D(latitude: 47.6131742, longitude: -122.4824903)),
    City(name: "Singapore", coordinate: CLLocationCoordinate2D(latitude: 1.3440852, longitude: 103.6836164)),
    City(name: "Sydney", coordinate: CLLocationCoordinate2D(latitude: -33.8473552, longitude: 150.6511076)),
    City(name: "Tokyo", coordinate: CLLocationCoordinate2D(latitude: 35.6684411, longitude: 139.6004407))
  ]

  /// State for markers displayed on the map for each city in `cities`
  @State var markers: [GMSMarker] = cities.map {
    let marker = GMSMarker(position: $0.coordinate)
    marker.title = $0.name
    return marker
  }

  @State var zoomInCenter: Bool = false
  @State var expandList: Bool = false
  @State var selectedMarker: GMSMarker?
  @State var yDragTranslation: CGFloat = 0

  var body: some View {

    let scrollViewHeight: CGFloat = 80

    GeometryReader { geometry in
      ZStack(alignment: .top) {
        // Map - TODO add the map here

        // Cities List
        CitiesList(markers: $markers) { (marker) in
          guard self.selectedMarker != marker else { return }
          self.selectedMarker = marker
          self.zoomInCenter = false
          self.expandList = false
        }  handleAction: {
          self.expandList.toggle()
        }.background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .offset(
          x: 0,
          y: geometry.size.height - (expandList ? scrollViewHeight + 150 : scrollViewHeight)
        )
        .offset(x: 0, y: self.yDragTranslation)
        .animation(.spring())
        .gesture(
          DragGesture().onChanged { value in
            self.yDragTranslation = value.translation.height
          }.onEnded { value in
            self.expandList = (value.translation.height < -120)
            self.yDragTranslation = 0
          }
        )
        .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
      }
    }
  }
}

struct CitiesList: View {

  @Binding var markers: [GMSMarker]
  var buttonAction: (GMSMarker) -> Void
  var handleAction: () -> Void

  var body: some View {
    GeometryReader { geometry in
      VStack(spacing: 0) {

        // List Handle
        HStack(alignment: .center) {
          Rectangle()
            .frame(width: 25, height: 4, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            .cornerRadius(10)
            .opacity(0.25)
            .padding(.vertical, 8)
        }
        .frame(width: geometry.size.width, height: 20, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        .onTapGesture {
          handleAction()
        }

        // List of Cities
        List {
            ForEach(0..<self.markers.count) { id in
              let marker = self.markers[id]
              Button(action: {
                buttonAction(marker)
              }) {
                Text(marker.title ?? "")
              }
            }
        }.frame(maxWidth: .infinity)
      }
    }
  }
}

struct MapContainerView: View {

  @Binding var zoomInCenter: Bool
  @Binding var markers: [GMSMarker]
  @Binding var selectedMarker: GMSMarker?

  var body: some View {
    GeometryReader { geometry in
      let diameter = zoomInCenter ? geometry.size.width : (geometry.size.height * 2)
      MapViewControllerBridge()
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
      .background(Color(red: 254.0/255.0, green: 1, blue: 220.0/255.0))
    }
  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

