//
//  TimeSettingView.swift
//  HaruSijak
//
//  Created by 신나라 on 6/13/24.
// 2024.07.05 snr : 호선과 역명 설정되도록 수정

import SwiftUI

struct TimeSettingView: View {
    
//    @State var isShowSheet: Bool = false    // 시간 변경 sheet alert
    let timeList = [Int](5..<25)            // 5~24까지 리스트
    let line23 = SubwayList().totalStation
    
    let dbModel = TimeSettingDB()           // 시간 설정 vm instance 생성
    @State var infoList: [Time] = []        // 조회된 시간정보 담을 리스트
    @Environment(\.dismiss) var dismiss         // 화면 이동을 위한 변수
    @State var alertType: SettingAlertType?        // 추가, 수정 alert
    @State var titleName : String
    
    @State var selectedTime = 0             // picker뷰 선택 value
    @State var selectedStation = 0          // station 선택 value
    @State var selectedLine = 0             // line 선택 value
    
    @State var line: [Int] = [1, 2, 3, 4, 5, 6, 7, 8]
    
    @Binding var stationValue: String
    @Binding var lineValue: Int
    @Binding var timeValue: Int
    
    
    var filteredStatioins: [(String, Int)] {
        line23.map { ($0.name, $0.intValue1) }
            .filter { $0.1 == selectedLine + 1 }
            .sorted { $0.0 < $1.0 }
    }
    
    
    var body: some View {
            VStack(content: {
                
                //title
                Text(titleName)
                    .font(.custom("Ownglyph_noocar-Rg", size: 30).bold())
                    .padding(.top, 20)
                
                
                
                // ---------------- line picker -------------------
                HStack {
                    Text("호선 선택 : ")
                        .font(.custom("Ownglyph_noocar-Rg", size: 20))
                    
                    Picker("", selection: $selectedLine, content: {
                        ForEach(0..<line.count, id:\.self, content: { index in
                            Text("\(line.map{$0}.sorted()[index])호선").tag(index)
                                .font(.custom("Ownglyph_noocar-Rg", size: 30))
                        })
                    })
                    .pickerStyle(.menu)
                }
                .padding(.top, 40)
//                .onAppear {
//                    // 초기 값 설정
//                    selectedStation = filteredStatioins.firstIndex(where: { $0.0 == stationValue }) ?? 0
//                    selectedLine = lineValue
//                }
                
                
                // ---------------- station picker -------------------
                HStack {
                    Text("역 선택 : ")
                        .font(.custom("Ownglyph_noocar-Rg", size: 20))
                    
                    Picker("", selection: $selectedStation, content: {
                        ForEach(filteredStatioins.indices, id: \.self) { index in
                            Text(self.filteredStatioins[index].0).tag(index)
                        }
                        .pickerStyle(MenuPickerStyle())
                    })
                    .pickerStyle(.menu)
                }
                .padding(.top, 10)
                
                
                // ---------------- time picker -------------------
                Picker("", selection: $selectedTime, content: {
                    ForEach(0..<timeList.count, id:\.self, content: { index in
                        Text("\(timeList[index])시").tag(index)
                            .font(.custom("Ownglyph_noocar-Rg", size: 30))
                    })
                })
                .pickerStyle(.wheel)
                
                // ---------------- 변경 button -------------------
                Button("변경하기", action: {
                    infoList = dbModel.queryDB()
                    
                    print("infoList.count : ",infoList.count)
                    
                    // 시간 설정 정보가 없을 때 => insert
                    if infoList.isEmpty {
                        print("infoList is empty, setting isAdd to true")
                        alertType = .add
                        
                    } else {
                        // update 처리
                        print("infoList is not empty, setting isUpdate to true")
                        alertType = .update
                    }
                }) // Button
                .tint(.white)
                .font(.custom("Ownglyph_noocar-Rg", size: 25))
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
                .background(Color("color1"))
                .cornerRadius(30)
                .controlSize(.large)
                .frame(width: 200, height: 50) // 버튼의 크기 조정
                .padding(.top, 40)
                .alert(item: $alertType) { alertType in
                    switch alertType {
                    case .add:
                        return Alert(
                            title: Text("알림"),
                            message: Text("\(timeList[selectedTime])시,  \(filteredStatioins[selectedStation].0)역으로 \n 설정하시겠습니까?"),
                            primaryButton: .destructive(Text("확인"), action: {
                                dbModel.insertDB(time: timeList[selectedTime], station: filteredStatioins[selectedStation].0, line: line[selectedLine])
                                dismiss()
                            }),
                            secondaryButton: .cancel(Text("취소"))
                        )
                    case .update:
                        return Alert(
                            title: Text("알림"),
                            message: Text("\(timeList[selectedTime])시, \(filteredStatioins[selectedStation].0)역으로 \n 설정하시겠습니까?"),
                            primaryButton: .destructive(Text("확인"), action: {
                                dbModel.updateDB(time: timeList[selectedTime], station: filteredStatioins[selectedStation].0, line: line[selectedLine], id: infoList[0].id)
                                dismiss()
                            }),
                            secondaryButton: .cancel(Text("취소"))
                        )
                    }
                }
            })//VStack
            .onAppear{
                selectedLine = lineValue
                selectedStation = filteredStatioins.firstIndex { $0.0 == stationValue } ?? 0
                selectedTime = timeList.firstIndex { $0 == timeValue } ?? 0
                
                print("onAppear lineValue : ", lineValue)
                print("onAppear selectedLine : ", selectedLine)
                print("onAppear selectedStation : ", selectedStation)
            }
    }
}

enum SettingAlertType: Identifiable {
    case add
    case update
    
    var id: Int{
        hashValue
    }
}
#Preview {
    TimeSettingView(titleName: "테스트제목", stationValue: .constant("Initial Station Value"), lineValue: .constant(1), timeValue: .constant(1))
}
