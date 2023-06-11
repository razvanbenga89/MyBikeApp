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
import UserNotifications
import Dependencies
import Popovers
import Localization

public class AppModel: ObservableObject {
  public struct NotificationBannerState: Hashable {
    let title: String
    let subtitle: String
    let color: String
  }
  
  public enum Destination: Hashable {
    case bikes
    case rides
    case settings
  }
  
  lazy var bikesModel: BikesModel = {
    withDependencies(from: self) {
      BikesModel()
    }
  }()
  
  lazy var ridesModel: RidesModel = {
    withDependencies(from: self) {
      RidesModel()
    }
  }()
  
  lazy var settingsModel: SettingsModel = {
    withDependencies(from: self) {
      SettingsModel()
    }
  }()
  
  @Published var destination: Destination
  @Published var notificationBanner: NotificationBannerState?
  @Dependency(\.bikesRepo) var bikesRepo
  @Dependency(\.ridesRepo) var ridesRepo
  
  public init(
    destination: Destination = .bikes
  ) {
    self.destination = destination
  }
  
  @MainActor
  func load() async {
    do {
      try await bikesRepo.setup()
      try await ridesRepo.setup()
    } catch {
      
    }
  }
  
  public func willPresentNotification(_ notification: UNNotification) {
    let content = notification.request.content
    let payload = content.userInfo
    let title = content.title
    let subtitle = content.subtitle
    let bikeColor = payload["bikeColor"] as? String ?? "bikeYellow"
    
    notificationBanner = NotificationBannerState(
      title: title,
      subtitle: subtitle,
      color: bikeColor
    )
  }
}

public struct AppView: View {
  @ObservedObject var model: AppModel
  @State var notificationBannerId = UUID()
  
  public init(model: AppModel) {
    self.model = model
  }
  
  public var body: some View {
    TabView(selection: $model.destination) {
      BikesView(model: model.bikesModel)
        .tabItem {
          Image.bikesIcon
          Text(Localization.bikesTitle)
        }
        .tag(AppModel.Destination.bikes)
      RidesView(model: model.ridesModel)
        .tabItem {
          Image.ridesIcon
          Text(Localization.ridesTitle)
        }
        .tag(AppModel.Destination.rides)
      SettingsView(model: model.settingsModel)
        .tabItem {
          Image.settingsIcon
          Text(Localization.settingsTitle)
        }
        .tag(AppModel.Destination.settings)
    }
    .popover(present: self.$model.notificationBanner.isPresent(), attributes: {
      $0.position = .relative(
        popoverAnchors: [
          .top,
        ]
      )
      $0.presentation.animation = .spring()
      $0.presentation.transition = .move(edge: .top)
      $0.dismissal.animation = .spring(response: 3, dampingFraction: 0.8, blendDuration: 1)
      $0.dismissal.transition = .move(edge: .top)
      $0.dismissal.mode = [.dragUp]
      $0.dismissal.dragDismissalProximity = 0.1
    }) {
      if let notificationBanner = self.model.notificationBanner {
        HStack {
          Theme.Image.bikesIcon.value
          VStack(alignment: .leading) {
            Text(notificationBanner.title)
              .font(.notificationTitleFont)
            Text(notificationBanner.subtitle)
              .font(.notificationSubtitleFont)
          }
          Spacer()
        }
        .foregroundColor(.black)
        .padding()
        .background(
          Theme.BikeColor(rawValue: notificationBanner.color)?.value ?? Theme.BikeColor.bikeYellow.value
        )
        .cornerRadius(16)
        .onAppear {
          self.notificationBannerId = UUID()
          let currentId = notificationBannerId
          
          DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if currentId == self.notificationBannerId {
              self.model.notificationBanner = nil
            }
          }
        }
      }
    }
    .onAppear {
      UITabBar.appearance().backgroundColor = UIColor(Color.toolbarBackgroundColor)
      UITabBar.appearance().unselectedItemTintColor = .white
    }
    .task {
      await self.model.load()
    }
  }
}

struct AppView_Previews: PreviewProvider {
  static var previews: some View {
    AppView(model: AppModel())
  }
}
