// MARK: -- Description
/*
    Description : 캘린더 문제해결
    Author : Forrest DongGeun Park. (PDG)
    Generate Date :   2024.6.11
    Updates :
     * 2024.06. by Forrest DonGeun Park :
            -
    Details : -
*/

import SwiftUI

struct Cal_test_pdg: View {
    
    @State var currentDate: Date = Date()
    @State var isAlert = false                  // actionSheet 실행
    @State var isSubAlert = false               // subAlert 실행
    @State var isResultTrue = false
    @State var isResultFalse = false
    @State var task: String = ""                // 입력받을 일정 변수
    @FocusState var isTextFieldFocused: Bool    // 키보드 focus
    @State var date: Date = Date()              // 선택된 날짜 변수
    @State var time: Date = Date()              // 선택된 시간 변수
    @Environment(\.dismiss) var dismiss
    let dbModel = CalendarDB()
    @State var tasksForSelectedDate: [Task] = []
    
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: false) { // showsIndicators : false => 스크롤바 안보이게
            
            VStack(spacing: 20, content: {
                
                //Custom Picker View
                CustomDatePicker(currentDate: $currentDate)
                
            })//VStack
            .padding(.vertical)
        }//ScrollView
        .safeAreaInset(edge: .bottom, content: {
            HStack(content: {
                Button(action: {
                    isAlert = true
                }, label: {
                    Image(systemName: "plus")
                        .foregroundStyle(.white)
                        .fontWeight(.bold)
                        .frame(width: 100)
                        .padding(.vertical)
                        .background(Color(.blue), in: Circle())
                })
                
                .sheet(isPresented: $isAlert, content: {
                    VStack(content: {
                        
                        //일정 textfield
                        TextField("일정 제목", text: $task)
                            .font(.title3.bold())
                            .frame(width: 200)
                            .padding()
                            .cornerRadius(8)
                            .focused($isTextFieldFocused)
                        
                        //요일 설정 picker
                        DatePicker(
                            "요일 설정 : ",
                            selection: $date,
                            displayedComponents: [.date]
                        )
                        .frame(width: 200)
                        .environment(\.locale, Locale(identifier: "ko_KR")) // 한국어로 설정
                        .tint(Color("color1"))
                        
                        //시간 설정 picker
                        DatePicker(
                            "시간 설정 : ",
                            selection: $time,
                            displayedComponents: [.hourAndMinute]
                        )
                        .frame(maxWidth: 200)
                        .environment(\.locale, Locale(identifier: "ko_KR")) // 한국어로 설정
                        .tint(Color("color1"))
                        
                        //추가 버튼
                        Button("추가하기", action: {
                            if task != "" {
                                let newTask = Task(id: UUID().uuidString, title: task, time: time)
                                dbModel.insertDB(task: newTask, taskDate: date)
                                dismiss()
                            } else {
                                isSubAlert = true
                            }
                            
                            //추가 후 초기화처리
                            task = ""
                            date = Date()
                            time = Date()
                        }) // Button
                        .tint(.white)
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.capsule)
                        .background(Color("color1"))
                        .cornerRadius(30)
                        .controlSize(.large)
                        .frame(width: 200, height: 50) // 버튼의 크기 조정
                        .padding(.top, 40)
                        
                        // 일정 == empty일 때, alert처리
                        .alert(isPresented: $isSubAlert) {
                            Alert(
                                title: Text("경고"),
                                message: Text("일정을 작성해주세요."),
                                dismissButton: .default(Text("확인"), action: {
                                    isSubAlert = false
                                })
                            )
                        }// alert
                    })
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
                }) //sheet
            })
            .padding(.horizontal)
            .background(.ultraThinMaterial)
            .padding(.top, 10)
            
        })
    }//body
}

   

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }

#Preview {
    Cal_test_pdg()
}
