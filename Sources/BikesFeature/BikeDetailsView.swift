//
//  BikeDetailsView.swift
//  
//
//  Created by Razvan Benga on 04.06.2023.
//

import SwiftUI
import Theme
import Models
import Dependencies
import SwiftUINavigation
import RidesFeature
import Localization
import Popovers

extension Bike {
  var ridesSortedByDate: [Ride] {
    rides.sorted(by: { $0.date > $1.date })
  }
  
  var formattedLatestService: String? {
    guard let latestService = latestService else {
      return nil
    }
    
    return DateFormatter.rideDateFormatter.string(from: latestService)
  }
}

public class BikeDetailsModel: ObservableObject {
  public enum Destination {
    case editBike(EditBikeModel)
    case editRide(EditRideModel)
    case alert(AlertViewState<AlertAction>)
  }
  
  public enum AlertAction {
    case cancel
    case deleteBike(Bike)
    case deleteRide(Ride)
  }
  
  private let id: UUID
  @Published var bike: Bike?
  @Published var shouldRefresh: Bool = false
  @Published var destination: Destination?
  @Published var latestServiceDate: Date?
  
  var onDelete: () -> Void = unimplemented("onDelete")
  
  @Dependency(\.bikesRepo) var bikesRepo
  @Dependency(\.ridesRepo) var ridesRepo
  
  public init(id: UUID) {
    self.id = id
  }
  
  @MainActor
  func load() async {
    do {
      self.bike = try await bikesRepo.getBike(id)
    } catch {
      
    }
  }
  
  func didTapDelete(bike: Bike) {
    self.destination = .alert(
      AlertViewState(
        title: bike.name,
        message: Localization.deleteAlertMessage,
        actions: [
          AlertActionState(title: Localization.cancelAction, actionType: .cancel),
          AlertActionState(title: Localization.deleteAction, style: .destructive, actionType: .deleteBike(bike))
        ]
      )
    )
  }
  
  func didTapDelete(ride: Ride) {
    self.destination = .alert(
      AlertViewState(
        title: ride.name,
        message: Localization.deleteAlertMessage,
        actions: [
          AlertActionState(title: Localization.cancelAction, actionType: .cancel),
          AlertActionState(title: Localization.deleteAction, style: .destructive, actionType: .deleteRide(ride))
        ]
      )
    )
  }
  
  func didTapEdit(bike: Bike) {
    let model = EditBikeModel(bike: bike)
    model.onFinish = { [weak self] in
      self?.destination = nil
      self?.shouldRefresh.toggle()
    }
    self.destination = .editBike(model)
  }
  
  func didTapEdit(ride: Ride) {
    let model = EditRideModel(ride: ride)
    model.onFinish = { [weak self] in
      self?.destination = nil
      self?.shouldRefresh.toggle()
    }
    self.destination = .editRide(model)
  }
  
  @MainActor
  func handleAlertActions(action: AlertAction) async {
    self.destination = nil
    
    switch action {
    case .cancel:
      break
    case .deleteBike(let bike):
      do {
        try await bikesRepo.deleteBike(bike.id)
        onDelete()
      } catch {
        
      }
    case .deleteRide(let ride):
      do {
        try await ridesRepo.deleteRide(ride.id)
        shouldRefresh.toggle()
      } catch {
        
      }
    }
  }
  
  @MainActor
  func didMarkLatestService() async {
    guard let latestServiceDate = latestServiceDate else {
      return
    }
    
    do {
      try await bikesRepo.updateLatestService(id, latestServiceDate)
      shouldRefresh.toggle()
    } catch {}
  }
}

public struct BikeDetailsView: View {
  @ObservedObject var model: BikeDetailsModel
  @State private var isShowingDatePopover = false
  
  public init(model: BikeDetailsModel) {
    self.model = model
  }
  
  public var body: some View {
    VStack {
      IfLet(self.$model.bike) { $bike in
        VStack {
          BikeTypeView(
            type: bike.type,
            showTypeDescription: false,
            wheelSize: .constant(bike.wheelSize),
            bikeColor: .constant(Theme.BikeColor(rawValue: bike.color) ?? .bikeWhite)
          )
          
          HStack {
            VStack(alignment: .leading) {
              Text("\(Localization.wheels)\(bike.wheelSize.description)")
                .font(.textFont)
              
              HStack(spacing: 0) {
                Text(Localization.serviceIn)
                  .font(.textFont)
                Text("\(bike.formattedServiceDue)")
                  .font(.bikeServiceDueFont)
              }
            }
            .foregroundColor(.white)
            
            Spacer()
          }
          
          BikeServiceProgressView(percentage: bike.serviceDuePercentage)
          
          HStack {
            VStack(alignment: .leading) {
              Text("\(Localization.rides)\(bike.rides.count)")
                .font(.textFont)
              
              HStack(spacing: 0) {
                Text(Localization.totalRidesDistance)
                  .font(.textFont)
                Text("\(bike.formattedRidesTotalDistance)")
                  .font(.bikeServiceDueFont)
              }
              
              if let formattedLatestService = bike.formattedLatestService {
                HStack(spacing: 0) {
                  Text(Localization.latestService)
                    .font(.textFont)
                  Text(formattedLatestService)
                    .font(.bikeServiceDueFont)
                }
              }
            }
            .foregroundColor(.white)
            
            Spacer()
            
            Button {
              self.isShowingDatePopover = true
            } label: {
              Image(systemName: "wrench.fill")
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .frame(width: 40, height: 40)
            .popover(present: $isShowingDatePopover, attributes: {
              $0.rubberBandingMode = .none
              $0.position = .absolute(
                originAnchor: .center,
                popoverAnchor: .center
              )
            }) {
              DatePickerView(
                selectedDate: self.$model.latestServiceDate,
                title: Localization.markLatestService
              ) {
                self.isShowingDatePopover = false
                Task {
                  await self.model.didMarkLatestService()
                }
              }
            }
          }
          
          ScrollView(showsIndicators: false) {
            LazyVStack {
              ForEach(bike.ridesSortedByDate) { ride in
                RideCardView(
                  ride: ride,
                  backgroundColor: Theme.AppColor.appNavy.value,
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
          .padding(.vertical)
        }
        .padding(.top)
        .padding(.horizontal, 10)
        .toolbar {
          ToolbarItem(placement: .principal) {
            Text(bike.name)
              .font(.navBarTitleFont)
              .foregroundColor(.white)
          }
          ToolbarItem {
            OverflowPopupView(
              onEditTap: {
                self.model.didTapEdit(bike: bike)
              },
              onDeleteTap: {
                self.model.didTapDelete(bike: bike)
              }
            )
          }
        }
      }
      .alertView(
        unwrapping: self.$model.destination,
        case: /BikeDetailsModel.Destination.alert
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
        case: /BikeDetailsModel.Destination.editBike
      ) { $editBikeModel in
        AddBikeView(model: editBikeModel)
      }
      .fullScreenCover(
        unwrapping: self.$model.destination,
        case: /BikeDetailsModel.Destination.editRide
      ) { $editRideModel in
        AddRideView(model: editRideModel)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .navigationBarTitleDisplayMode(.inline)
    .background(
      ZStack(alignment: .top) {
        Color.defaultBackgroundColor
        WaveShape()
          .fill(Theme.AppColor.appDarkBlue.value)
      }
      .ignoresSafeArea()
    )
    .task(id: self.model.shouldRefresh) {
      await self.model.load()
    }
  }
}

struct BikeDetailsView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      BikeDetailsView(
        model: BikeDetailsModel(id: UUID())
      )
    }
  }
}
