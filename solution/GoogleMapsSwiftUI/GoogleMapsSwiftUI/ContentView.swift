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

  /// State for markers displayed on the map when the use taps at a location. This property gets
  /// reset whenever a new polygon is added to the map.
  @State var polygonPath: [GMSMarker] = []

  /// State for polygons displayed on the map
  @State var polygons: [GMSPolygon] = []

  var body: some View {
    VStack {
      MapView(polygonPath: $polygonPath, polygons: $polygons)
      Button(action: {
        addNewPolygonIfNeeded()
      }) {
        Text("Create New Polygon")
      }.padding(.top).disabled(polygonPath.count < 3)
    }
  }

  private func addNewPolygonIfNeeded() {
    guard !polygonPath.isEmpty else {
      print("Cannot add new polygon. polygonPath is empty")
      return
    }

    // Create a new polygon from `polygonPath` and remove all
    // from the map.
    let newPolygon = GMSMutablePath()
    polygonPath.forEach { marker in
      marker.map = nil
      newPolygon.add(marker.position)
    }
    polygons.append(GMSPolygon(path: newPolygon))
    polygonPath.removeAll()
  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
