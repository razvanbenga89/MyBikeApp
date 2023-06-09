//
//  AppView.swift
//  
//
//  Created by Razvan Benga on 22.05.2023.
//

import SwiftUI
import Theme
import BikesFeature
import RidesFeature
import SettingsFeature

public class AppViewModel: ObservableObject {
  public enum Destination: Hashable {
    case bikes
    case rides
    case settings
  }
  
  lazy var bikesModel: BikesModel = {
    BikesModel()
  }()
  
  lazy var ridesModel: RidesModel = {
    RidesModel()
  }()
  
  lazy var settingsModel: SettingsModel = {
    SettingsModel()
  }()
  
  @Published var destination: Destination
  
  public init(destination: Destination = .bikes) {
    self.destination = destination
  }
}

public struct AppView: View {
  @ObservedObject var model: AppViewModel
  
  public init(model: AppViewModel) {
    self.model = model
  }
  
  public var body: some View {
    TabView(selection: $model.destination) {
      BikesView(model: model.bikesModel)
        .tabItem {
          Image.bikesIcon
          Text("Bikes")
        }
        .tag(AppViewModel.Destination.bikes)
      RidesView(model: model.ridesModel)
        .tabItem {
          Image.ridesIcon
          Text("Rides")
        }
        .tag(AppViewModel.Destination.rides)
      SettingsView(model: model.settingsModel)
        .tabItem {
          Image.settingsIcon
          Text("Settings")
        }
        .tag(AppViewModel.Destination.settings)
    }
    .onAppear {
      UITabBar.appearance().backgroundColor = UIColor(Color.toolbarBackgroundColor)
      UITabBar.appearance().unselectedItemTintColor = .white
    }
  }
}

struct AppView_Previews: PreviewProvider {
  static var previews: some View {
    AppView(model: AppViewModel())
  }
}
