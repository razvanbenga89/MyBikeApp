//
//  BikesView.swift
//  
//
//  Created by Razvan Benga on 29.05.2023.
//

import SwiftUI
import SwiftUINavigation
import Theme
import Localization
import Models
import Dependencies

extension Bike {
  var formattedServiceDue: String {
    let serviceIn = serviceDue - ridesTotalDistance
    
    if serviceIn > 0 {
      return String(format: "%.0f", serviceIn)
    } else {
      return "Overdue"
    }
  }
  
  var formattedRidesTotalDistance: String {
    String(format: "%.1f", ridesTotalDistance)
  }
  
  var serviceDuePercentage: Double {
    ridesTotalDistance / serviceDue
  }
}

public class BikesModel: ObservableObject {
  public enum ViewState {
    case empty
    case loadedBikes([Bike])
  }
  
  public enum Destination {
    case addBike(AddBikeModel)
    case editBike(EditBikeModel)
    case bikeDetails(BikeDetailsModel)
    case alert(AlertViewState<AlertAction>)
  }
  
  public enum AlertAction {
    case cancel
    case delete(Bike)
  }
  
  @Published var viewState: ViewState
  @Published var destination: Destination?
  
  @Dependency(\.bikesRepo) var bikesRepo
  
  public init(
    viewState: ViewState = .empty,
    destination: Destination? = nil
  ) {
    self.viewState = viewState
    self.destination = destination
  }
  
  @MainActor
  func load() async {
    for await bikes in bikesRepo.getBikes() {
      if bikes.isEmpty {
        viewState = .empty
      } else {
        viewState = .loadedBikes(bikes)
      }
    }
  }
  
  func didTapAddBike() {
    let model = AddBikeModel()
    model.onFinish = { [weak self] in
      self?.destination = nil
    }
    self.destination = .addBike(model)
  }
  
  func didTapEdit(bike: Bike) {
    let model = EditBikeModel(bike: bike)
    model.onFinish = { [weak self] in
      self?.destination = nil
    }
    self.destination = .editBike(model)
  }
  
  func didTapDelete(bike: Bike) {
    self.destination = .alert(
      AlertViewState(
        title: bike.name,
        message: "will be deleted.",
        actions: [
          AlertActionState(title: "Cancel", actionType: .cancel),
          AlertActionState(title: "Delete", style: .destructive, actionType: .delete(bike))
        ]
      )
    )
  }
  
  func didTapDetails(bike: Bike) {
    let model = BikeDetailsModel(id: bike.id)
    model.onDelete = { [weak self] in
      self?.destination = nil
    }
    self.destination = .bikeDetails(model)
  }
  
  @MainActor
  func handleAlertActions(action: AlertAction) async {
    switch action {
    case .cancel:
      self.destination = nil
    case .delete(let bike):
      self.destination = nil
      
      do {
        try await bikesRepo.deleteBike(bike.id)
      } catch {
        
      }
    }
  }
}

public struct BikesView: View {
  @ObservedObject var model: BikesModel
  
  public init(model: BikesModel) {
    self.model = model
  }
  
  public var body: some View {
    Switch(self.$model.viewState) {
      CaseLet(/BikesModel.ViewState.empty) { _ in
        BikesEmptyView(model: model)
      }
      CaseLet(/BikesModel.ViewState.loadedBikes) { $bikes in
        BikesLoadedView(bikes: bikes, model: model)
      }
    }
    .taskLoadOnce {
      await self.model.load()
    }
    .fullScreenCover(
      unwrapping: self.$model.destination,
      case: /BikesModel.Destination.addBike
    ) { $addBikeModel in
      AddBikeView(model: addBikeModel)
    }
  }
}

struct BikesLoadedView: View {
  @ObservedObject var model: BikesModel
  @State var showingPopup = false
  private let bikes: [Bike]
  
  init(
    bikes: [Bike],
    model: BikesModel
  ) {
    self.bikes = bikes
    self.model = model
  }
  
  var body: some View {
    NavigationStack {
      ScrollView {
        LazyVStack(spacing: 10) {
          ForEach(bikes) { bike in
            BikeCardView(
              bike: bike,
              onTapGesture: {
                self.model.didTapDetails(bike: bike)
              },
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
      .padding(.vertical)
      .scrollContentBackground(.hidden)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text("Bikes")
            .font(.navBarTitleFont)
            .foregroundColor(.white)
        }
        ToolbarItem {
          Button {
            self.model.didTapAddBike()
          } label: {
            HStack {
              Theme.Image.addIcon.value
              Text("Add Bike")
            }
          }
          .font(.navBarItemFont)
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color.defaultBackgroundColor)
      .navigationDestination(
        unwrapping: self.$model.destination,
        case: /BikesModel.Destination.bikeDetails
      ) { $model in
        BikeDetailsView(model: model)
      }
      .alertView(
        unwrapping: self.$model.destination,
        case: /BikesModel.Destination.alert
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
        case: /BikesModel.Destination.editBike
      ) { $editBikeModel in
        AddBikeView(model: editBikeModel)
      }
    }
  }
}

struct BikesEmptyView: View {
  @ObservedObject var model: BikesModel
  
  init(model: BikesModel) {
    self.model = model
  }
  
  var body: some View {
    VStack(spacing: 10) {
      Image.missingBikesCard
        .resizable()
        .scaledToFit()
      ZStack(alignment: .leading) {
        Image.dottedLine
          .resizable()
          .scaledToFit()
        Text(Localization.noBikesText)
          .padding()
          .multilineTextAlignment(.center)
          .foregroundColor(.white)
          .background(.black)
          .font(.textFont)
      }
      .padding(.horizontal, 30)
      Button(Localization.addBikeAction) {
        self.model.didTapAddBike()
      }
      .buttonStyle(PrimaryButtonStyle())
      .padding(.bottom)
      .padding(.horizontal, 10)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.defaultBackgroundColor)
  }
}

struct BikesView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      BikesView(
        model: BikesModel(viewState: .loadedBikes([]))
      )

      BikesView(
        model: withDependencies {
          $0.bikesRepo.getBikes = {
            AsyncStream { continuation in
              continuation.yield([])
              continuation.finish()
            }
          }
        } operation: {
          BikesModel()
        }
      )
      .previewDisplayName("Empty bikes list")
    }
  }
}
