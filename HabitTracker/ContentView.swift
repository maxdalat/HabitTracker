import SwiftUI

/*
 Stuff to do:
 
 1. Make it so that when you close the app it keeps it's progress [High priority bug]
    A. Possible Database??
    B. Save it locally
    C. Even crazier, save it both locally and on a database
 2. Make todos
    A. One time todo's like homework assignments for class and etc.
    
 3. Just make a database and stop finding ways to avoid it
    A. Using the database, make it possible to see assignments as a example on multiple devices with one leader phone, and other follower;
 4. Possibly try using the chromebook to host the database?
    A. Find out a way to make it always on
    B. Otherwise use my computer and turn off the; fan lights/replace them
 5. Admin Panel for Database / Admin login
    A. Be careful when uploading to Git
 6. Make it possible to add different types of Blocks.
    A. Ex. Todo's, reminders, homework assignments, tests.
 7. Login page
    A. Add classes that you are in
 8. GooglePlay app [low priority]
 
 
 
 */




struct ContentView: View {
    struct Block: Identifiable {
        let id = UUID()
        var name: String
        var progressToday: Int
        var goalToday: Int
        var color: Color
        var isCompleted: Bool = false
    }
    
    @State private var blocks = [
        Block(name: "Meditation", progressToday: 0, goalToday: 3, color: .red),
        Block(name: "Water", progressToday: 0, goalToday: 3, color: .blue),
    ]
    
    @State private var completedIndices: [Int] = []
    @State private var isPresented = false
    @State private var newHobby = false
    @State private var isDarkMode = true
    @State private var habitName: String = ""
    @State private var habitPerDay: Int = 1
    @State private var habitColor: Color = .red
    
    func resetDay() {
        blocks.indices.forEach { index in
            blocks[index].progressToday = 0
            if completedIndices.contains(index) {
                completedIndices.removeAll(where: { $0 == index })
                blocks.append(blocks[index])
            }
        }
    }
    
    func increaseProgress(for blockIndex: Int) {
        if blocks[blockIndex].progressToday < blocks[blockIndex].goalToday {
            blocks[blockIndex].progressToday += 1
            if blocks[blockIndex].progressToday == blocks[blockIndex].goalToday {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        blocks[blockIndex].isCompleted = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            completedIndices.append(blockIndex)
                            blocks.remove(at: blockIndex)
                        }
                    }
                }
            }
        }
    }

    
    func newHabit() {
        let newBlock = Block(name: habitName, progressToday: 0, goalToday: habitPerDay, color: habitColor)
        blocks.append(newBlock)
        habitName = ""
        habitPerDay = 1
        habitColor = .red
        newHobby = false
    }
    
    var body: some View {
        VStack {
            ForEach(blocks.indices, id: \.self) { index in
                let block = blocks[index]
                
                // Check if the habit is completed or in completedIndices
                if !block.isCompleted || completedIndices.contains(index) {
                    ZStack {
                        Rectangle()
                            .cornerRadius(15)
                            .foregroundColor(.white)
                            .shadow(radius: 15)
                            .frame(height: 150)
                        
                        VStack {
                            HStack {
                                Text(block.name)
                                    .font(.headline)
                                    .padding(.all)
                                Spacer()
                                Button(action: { increaseProgress(for: index) }) {
                                    Image(systemName: "checkmark")
                                        .padding(.all)
                                }
                            }
                            
                            ZStack {
                                LinearGradient(gradient: Gradient(colors: [block.color, block.color.opacity(0.6)]), startPoint: .leading, endPoint: .trailing)
                                    .cornerRadius(15)
                                    .foregroundColor(block.color)
                                    .frame(height: 12)
                                    .opacity(0.6)
                                    .padding(.all)
                                    .cornerRadius(3.0)
                                
                                GeometryReader { geometry in
                                    let progressFraction = CGFloat(block.progressToday) / CGFloat(block.goalToday)
                                    let gradient = Gradient(colors: [block.color.opacity(0.8), block.color.opacity(0.5)])
                                    let gradientWidth = (geometry.size.width - 33) * progressFraction
                                    let startPoint = UnitPoint(x: 0, y: 0.5)
                                    let endPoint = UnitPoint(x: progressFraction, y: 0.5)

                                    LinearGradient(gradient: gradient, startPoint: startPoint, endPoint: endPoint)
                                        .cornerRadius(15)
                                        .frame(width: gradientWidth, height: 12)
                                        .mask(Capsule().fill(Color.white))
                                        .padding(.all)
                                        .gesture(
                                            DragGesture(minimumDistance: 0)
                                                .onEnded { _ in
                                                    increaseProgress(for: index)
                                                }
                                        )
                                }
                            }
                            
                            HStack {
                                ForEach(0..<block.goalToday) { goalIndex in
                                    Rectangle()
                                        .cornerRadius(15)
                                        .foregroundColor(block.color)
                                        .frame(height: 10)
                                        .shadow(radius: 5)
                                        .opacity(block.progressToday > goalIndex ? 1 : 0.6)
                                        .padding(.all)
                                }
                            }
                        }
                        .frame(height: 150.0)
                        .transition(.move(edge: .leading)) // Transition for swiping off to the left
                    }
                    .padding(.all)
                }
            }
            
            Spacer()
            
            HStack {
                Button(action: resetDay) {
                    Image(systemName: "arrowshape.turn.up.left.fill")
                }
                .padding(.all)
                
                Button(action: { isPresented = true }) {
                    Image(systemName: "circle.lefthalf.filled")
                }
                .sheet(isPresented: $isPresented) {
                    VStack {
                        Toggle("Dark Mode", isOn: $isDarkMode)
                            .padding()
                        Stepper(value: $habitPerDay, in: 1...10) {
                            Text("Meditation Goal per Day")
                            Text("\(habitPerDay)")
                        }
                        .padding()
                    }
                    .preferredColorScheme(isDarkMode ? .dark : .light)
                }
                
                Button(action: { newHobby = true }) {
                    Image(systemName: "plus")
                }
                .padding(.all)
                .sheet(isPresented: $newHobby) {
                    ZStack {
                        VStack {
                            TextField("Habit Name", text: $habitName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding(.all)
                    
                    ZStack {
                        Stepper(value: $habitPerDay, in: 1...9) {
                            Text("\(habitPerDay)")
                                .fontWeight(.bold)
                                .font(.headline)
                        }
                        .padding(.all)
                    }
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding(.all)
                    
                    ColorPicker("Color", selection: $habitColor)
                        .padding()
                    
                    Spacer()
                    
                    ZStack {
                        Button(action: newHabit) {
                            ZStack {
                                Rectangle()
                                    .foregroundColor(.blue)
                                    .frame(height: 70)
                                    .shadow(radius: 20)
                                Image(systemName: "plus")
                                    .padding(.all)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding(.all)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
