import SwiftUI
import Charts

struct SheetContentView: View {
    @Binding var isLoading: Bool
    @Binding var stationName: String
    @Binding var stationLine: [String]
    @Binding var showingcurrentTime: String
    @Binding var boardingPersonValue: [Double]
    @Binding var AlightingPersonValue: [Double]
    @Binding var BoardingPersondictionary: [[String: Double]]
    @Binding var AlightinggPersondictionary: [[String: Double]]
    @Binding var serverResponseBoardingPerson: [String]
    @Binding var serverResponseAlightingPerson: [String]
    @State private var selectedSegment = 0
    var body: some View {
        VStack(content: {
            if isLoading {
                ZStack {
                    LottieView(jsonName: "SplashLotti")
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                withAnimation {
                                    isLoading = false
                                }
                            }
                        }
                    Spacer()
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white, lineWidth: 4)
                        .background(Color.white)
                        .frame(width: 250, height: 100)
                        .offset(x: 0, y: 200)
                    Text("잠시만 기다려 주세요...")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .offset(y: 120)
                }
            } else {
                Text(stationName)
                    .font(.system(size: 24))
                    .bold()
                    .padding(30)
                Picker("Select a line", selection: $selectedSegment) {
                    ForEach(0..<stationLine.count, id: \.self) { index in
                        Text(stationLine[index] + "호선")
                            .tag(index)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                Text("\(showingcurrentTime)시의 예상 승차인원은 \(Int(boardingPersonValue[selectedSegment]))명 입니다. ")
                Text("\(showingcurrentTime)시의 예상 하차인원은 \(Int(AlightingPersonValue[selectedSegment]))명 입니다")
                
                ScrollView {
                    HStack {
                        Circle()
                            .fill(Color.green.opacity(0.7))
                            .frame(width: 20, height: 20)
                        Text("탑승 인원")
                        
                        Circle()
                            .fill(Color(red: 0.9, green: 0.6, blue: 0.3))
                            .frame(width: 20, height: 20)
                        Text("하차 인원")
                    }
                    .padding()
                    
                    Chart {
                        // 승차인원 차트
                        ForEach(Array(BoardingPersondictionary[selectedSegment].keys.sorted()), id: \.self) { key in
                            if let value = BoardingPersondictionary[selectedSegment][key] {
                                BarMark(
                                    x: .value("인원수", Int(value)),
                                    y: .value("시간", key),
                                    width: 25
                                )
                                .foregroundStyle(Color.green.opacity(0.8))
                                .annotation(position: .top) {
                                    Text("\(Int(value))")
                                        .font(.caption)
                                        .foregroundColor(Color.green.opacity(0.7))
                                }
                            }
                        }
                        
                        // 하차인원 차트
                        ForEach(Array(AlightinggPersondictionary[selectedSegment].keys.sorted()), id: \.self) { key in
                            if let value = AlightinggPersondictionary[selectedSegment][key] {
                                BarMark(
                                    x: .value("인원수", Int(value)),
                                    y: .value("시간", key),
                                    width: 25
                                )
                                .foregroundStyle(Color.orange)
                                .annotation(position: .top) {
                                    Text("\(Int(value))")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    .chartXAxis {
                        AxisMarks(position: .bottom)
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                    .frame(height: 400)
                }
            }
        })
        .presentationDetents([.fraction(CGFloat(0.8))])
        .presentationDragIndicator(.visible)
    }
}


