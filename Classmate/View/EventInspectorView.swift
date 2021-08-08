//
//  EventInspectorView.swift
//  Classmate
//
//  Created by Kuba Florek on 09/12/2020.
//

import SwiftUI

struct EventInspectorView: View {
    @StateObject var eventInspectorVM = EventInspectorViewModel()
    
    @State private var showAddView = false
    
    var body: some View {
            VStack {
                Picker(selection: $eventInspectorVM.filter.animation(.spring()), label: Text("Day of the week")) {
                    ForEach(EventInspectorViewModel.filters.allCases, id: \.self) { day in
                        Text(day.rawValue)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                List {
                    Text("Past events")
                    
                    ForEach(eventInspectorVM.filteredEvents.filter({ $0.date < Date() })) { event in
                        VStack(alignment: .leading, spacing: 5) {
                            Text("\(event.title), \(event.subject)")
                                .font(.headline)
                            
                            Text(event.date, style: .date)
                                .font(.subheadline)
                        }
                        .foregroundColor(eventInspectorVM.doesSubjectExist(event.event) ? .primary : .red)
                        .onTapGesture {
                            eventInspectorVM.selectedEvent = event
                        }
                    }
                    .onDelete(perform: { indexSet in
                        let deletedEvent = eventInspectorVM.filteredEvents.filter({ $0.date < Date() })[indexSet.count - 1]
                        eventInspectorVM.removeEvent(deletedEvent)
                    })
                    
                    Text("Next events")
                    
                    ForEach(eventInspectorVM.filteredEvents.filter({ $0.date > Date() })) { event in
                        VStack(alignment: .leading, spacing: 5) {
                            Text("\(event.title), \(event.subject)")
                                .font(.headline)
                            
                            Text(event.date, style: .date)
                                .font(.subheadline)
                        }
                        .foregroundColor(eventInspectorVM.doesSubjectExist(event.event) ? .primary : .red)
                        .onTapGesture {
                            eventInspectorVM.selectedEvent = event
                        }
                    }
                    .onDelete(perform: { indexSet in
                        let deletedEvent = eventInspectorVM.filteredEvents.filter({ $0.date > Date() })[indexSet.count - 1]
                        eventInspectorVM.removeEvent(deletedEvent)
                    })
                }
                .listStyle(InsetListStyle())
            }
            .sheet(isPresented: $showAddView) {
                EventAddView(eventInspectorVM: eventInspectorVM)
            }
            .navigationBarTitle("Your Events")
            .navigationBarItems(trailing: Button(action: {
                showAddView = true
            }) {
                Image(systemName: "plus")
            })
            .alert(item: $eventInspectorVM.selectedEvent) { event in
                Alert(title: Text(event.title), message: Text(event.description), dismissButton: .default(Text("OK")))
            }
        }
}

struct EventAddView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var eventInspectorVM: EventInspectorViewModel
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    DatePicker("Date", selection: $eventInspectorVM.newEventDate, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                }
                
                Section {
                    Picker("Subject", selection: $eventInspectorVM.newEventSubject) {
                        if eventInspectorVM.filteredSubjects.isEmpty {
                            Text("You haven't planned any lessons for this day yet")
                        }
                        
                        ForEach(eventInspectorVM.filteredSubjects, id: \.self) { subject in
                            Text(subject)
                        }
                    }
                }
                
                TextField("Title", text: $eventInspectorVM.newEventTitle)
                
                TextField("Description", text: $eventInspectorVM.newEventDescription)
                
                Section {
                    Button("Add") {
                        eventInspectorVM.newEvent()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(eventInspectorVM.newEventTitle.isEmpty || eventInspectorVM.newEventSubject.isEmpty || eventInspectorVM.dayOfTheWeek == nil)
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("New event")
        }
    }
}
