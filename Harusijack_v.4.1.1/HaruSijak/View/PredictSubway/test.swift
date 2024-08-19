import SwiftUI
struct test: View {
    @State var currentScale: CGFloat = 1.0
    @State var previousScale: CGFloat = 1.0
    @State var currentOffset = CGSize.zero
    @State var previousOffset = CGSize.zero
    let line23 = SubwayList().stations_line_23
    //    let imgWidth = UIImage(named: "subwayMap")!.size.width
    //    let imgHight = UIImage(named: "subwayMap")!.size.height
    let imgWidth: CGFloat = 6189
    let imgHeight: CGFloat = 4465
    
    var body: some View {
        
        ZStack {
            
            GeometryReader { geometry in // here you'll have size and frame
                
                Image("subwayMap")
                    .resizable()
                    .frame(width: imgWidth * self.currentScale, height: imgHeight * self.currentScale)
                    .overlay( GeometryReader { geometry in
                        ForEach(Array(line23.enumerated()), id: \.0) { index, station in
                            Button(action: {
                                //                                isLoading = true
                                print("line5 station \(station.0)")
                                //                                handleStationClick(stationName: station.0)
                            }) {
                                Text(".\(index) \(station.0)")
                                    .font(.system(size: 10))
                                    .bold()
                                    .frame(width: 100, height: 20)
                                    .background(Color.red)
                            }
                            .position(  x: (station.2 * self.currentScale),
                                        y: (station.1 * self.currentScale)
                            )
                        }
                    })
                    .edgesIgnoringSafeArea(.all)
                    .aspectRatio(contentMode: .fit)
                    .offset(x: self.currentOffset.width, y: self.currentOffset.height)
                    .scaleEffect(max(self.currentScale, 1.0)) // the second question
                    .gesture(DragGesture()
                        .onChanged { value in
                            
                            let deltaX = value.translation.width - self.previousOffset.width
                            let deltaY = value.translation.height - self.previousOffset.height
                            self.previousOffset.width = value.translation.width
                            self.previousOffset.height = value.translation.height
                            
                            //                            let newOffsetWidth = self.currentOffset.width + deltaX / self.currentScale
                            
                            self.currentOffset.width = self.currentOffset.width + deltaX / self.currentScale
                            
                            
                            self.currentOffset.height = self.currentOffset.height + deltaY / self.currentScale
                        }
                             
                        .onEnded { value in self.previousOffset = CGSize.zero })
                
                
                    .gesture(MagnificationGesture()
                        .onChanged { value in
                            let delta = value / self.previousScale
                            self.previousScale = value
                            self.currentScale = self.currentScale * delta
                        }
                        .onEnded { value in self.previousScale = 1.0 })
            }
            
        }
        
    }
}

#Preview {
    test()
}
