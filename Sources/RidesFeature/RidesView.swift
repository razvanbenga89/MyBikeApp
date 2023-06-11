//
//  RidesView.swift
//  
//
//  Created by Razvan Benga on 06.06.2023.
//

import SwiftUI
import Models
import Theme
import SwiftUINavigation
import Localization
import RidesRepo
import Dependencies

public struct RidesSection {
  let date: Date
  let rides: [Ride]
  
  var formattedDate: String {
    DateFormatter.ridesSectionDateFormatter.string(from: date)
  }
}

public class RidesModel: ObservableObject {
  public enum ViewState {
    case empty
    case loadedRides([RidesSection])
  }
  
  public enum Destination {
    case addRide(AddRideModel)
    case editRide(EditRideModel)
    case alert(AlertViewState<AlertAction>)
  }
  
  public enum AlertAction {
    case cancel
    case delete(Ride)
  }
  
  @Published var viewState: ViewState?
  @Published var destination: Destination?
  
  @Dependency(\.ridesRepo) var ridesRepo
  
  public init(
    viewState: ViewState? = nil,
    destination: Destination? = nil
  ) {
    self.viewState = viewState
    self.destination = destination
  }
  
  @MainActor
  func load() async {
    for await rides in ridesRepo.getRides() {
      withAnimation {
        if rides.isEmpty {
          viewState = .empty
        } else {
          let sortedRides = Dictionary(grouping: rides) { ride in
            let dateComps = Calendar.current.dateComponents([.year, .month], from: ride.date)
            return dateComps
          }
          
          let sections = sortedRides.compactMap { key, value -> RidesSection? in
            guard let date = Calendar.current.date(from: key) else {
              return nil
            }
            
            return RidesSection(date: date, rides: value)
          }
          
          let sortedSections = sections.sorted(by: { $0.date > $1.date })
          viewState = .loadedRides(sortedSections)
        }
      }
    }
  }
  
  func didTapAddRide() {
    let model = AddRideModel()
    model.onFinish = { [weak self] in
      self?.destination = nil
    }
    self.destination = .addRide(model)
  }
  
  func didTapDelete(ride: Ride) {
    self.destination = .alert(
      AlertViewState(
        title: ride.name,
        message: Localization.deleteAlertMessage,
        actions: [
          AlertActionState(title: Localization.cancelAction, actionType: .cancel),
          AlertActionState(title: Localization.deleteAction, style: .destructive, actionType: .delete(ride))
        ]
      )
    )
  }
  
  func didTapEdit(ride: Ride) {
    let model = EditRideModel(ride: ride)
    model.onFinish = { [weak self] in
      self?.destination = nil
    }
    self.destination = .editRide(model)
  }
  
  @MainActor
  func handleAlertActions(action: AlertAction) async {
    self.destination = nil
    
    switch action {
    case .cancel:
      break
    case .delete(let ride):
      do {
        try await ridesRepo.deleteRide(ride.id)
      } catch {
        
      }
    }
  }
}

public struct RidesView: View {
  @ObservedObject var model: RidesModel
  
  public init(model: RidesModel) {
    self.model = model
  }
  
  public var body: some View {
    IfLet(self.$model.viewState) { viewState in
      Switch(viewState) {
        CaseLet(/RidesModel.ViewState.empty) { _ in
          RidesEmptyView(model: model)
        }
        CaseLet(/RidesModel.ViewState.loadedRides) { $ridesSections in
          RidesLoadedView(ridesSections: ridesSections, model: model)
        }
      }
    } else: {
      Theme.AppColor.appBlack.value
        .ignoresSafeArea()
    }
    .viewDidLoadTask {
      await self.model.load()
    }
    .fullScreenCover(
      unwrapping: self.$model.destination,
      case: /RidesModel.Destination.addRide
    ) { $addRideModel in
      AddRideView(model: addRideModel)
    }
  }
}

struct RidesLoadedView: View {
  @ObservedObject var model: RidesModel
  @State var showingPopup = false
  private let ridesSections: [RidesSection]
  
  init(
    ridesSections: [RidesSection],
    model: RidesModel
  ) {
    self.ridesSections = ridesSections
    self.model = model
  }
  
  var body: some View {
    NavigationStack {
      VStack {
        RidesChartView(
          rides: ridesSections.flatMap { $0.rides }
        )
        
        ScrollView(showsIndicators: false) {
          LazyVStack(spacing: 10) {
            ForEach(ridesSections, id: \.date) { rideSection in
              Section(
                header:
                  HStack {
                    Text(rideSection.formattedDate.uppercased())
                      .font(.alertTitleFont)
                      .foregroundColor(Theme.AppColor.appGreyBlue.value)
                    Spacer()
                  }
              ) {
                ForEach(rideSection.rides) { ride in
                  RideCardView(
                    ride: ride,
                    backgroundColor: Theme.AppColor.appDarkBlue.value,
                    onTapGesture: {},
                    onEditTap: {
                      self.model.didTapEdit(ride: ride)
                    },
                    onDeleteTap: {
                      self.model.didTapDelete(ride: ride)
                    }
                  )
                }
              }
            }
          }
        }
      }
      .padding(.vertical)
      .scrollContentBackground(.hidden)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(Localization.ridesTitle)
            .font(.navBarTitleFont)
            .foregroundColor(.white)
        }
        ToolbarItem {
          Button {
            self.model.didTapAddRide()
          } label: {
            HStack {
              Theme.Image.addIcon.value
              Text(Localization.addRideAction)
            }
          }
          .font(.navBarItemFont)
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color.defaultBackgroundColor)
      .alertView(
        unwrapping: self.$model.destination,
        case: /RidesModel.Destination.alert
      ) { action in
        guard let action = action else {
          return
        }
        
        Task {
          await self.model.handleAlertActions(action: action)
        }
      }
      .fullScreenCover(
        unwrapping: self.$model.destination,
        case: /RidesModel.Destination.editRide
      ) { $editRideModel in
        AddRideView(model: editRideModel)
      }
    }
  }
}

struct RidesEmptyView: View {
  @ObservedObject var model: RidesModel
  
  init(model: RidesModel) {
    self.model = model
  }
  
  var body: some View {
    VStack(spacing: 10) {
      Spacer()
      Theme.Image.missingRides.value
        .resizable()
        .scaledToFit()
      ZStack(alignment: .leading) {
        Image.dottedLine
          .resizable()
          .scaledToFit()
        Text(Localization.noRidesText)
          .padding()
          .multilineTextAlignment(.center)
          .foregroundColor(.white)
          .background(.black)
          .font(.textFont)
      }
      .padding(.horizontal, 30)
      
      Spacer()
      
      Button(Localization.addRideAction) {
        self.model.didTapAddRide()
      }
      .buttonStyle(PrimaryButtonStyle())
      .padding(.bottom)
      .padding(.horizontal, 10)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.defaultBackgroundColor)
  }
}

struct RidesView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      RidesView(
        model: RidesModel(viewState: .loadedRides([]))
      )
      
      RidesView(
        model: withDependencies {
          $0.ridesRepo.getRides = {
            AsyncStream { continuation in
              continuation.yield([])
              continuation.finish()
            }
          }
        } operation: {
          RidesModel(viewState: .empty)
        }
      )
      .previewDisplayName("Empty rides list")
    }
  }
}
