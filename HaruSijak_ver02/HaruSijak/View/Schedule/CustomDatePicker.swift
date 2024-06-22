//
//  CustomDatePicker.swift
//  HaruSijak
//
//  Created by 신나라 on 6/10/24.
//
/*
 Description
    - 2024. 06. 11 snr : - insert된 내용을 조회하는 부분의 문제가 있음.
                         - 일정 있는 날짜에 원 표시 : dbModel.queryDB()에서 불러오지 않아서였음
                         - ForEach문에서 id 중복조회된다는 메세지 tasksForSelectedDate.indices를 사용하여 해결
                         - print(), 불필요한 기능 삭제처리
                         - 일정리스트 클릭 시 상세내용 조회 및 수정되도록
    
    - 2024. 06. 12 snr : - navigationView, List 제거
                         - 날짜 클릭 시 Capsule() -> Circle() 모양으로 변경
                            => 비교 후에 삭제 예정
                         - 달력 사이즈 조정
 
    - 2024. 06. 17 snr - 추가 후에 달력에 바로 반영되기 위해서 onDismiss 처리
                         
 */

import SwiftUI

struct CustomDatePicker: View {
    
    @Binding var currentDate: Date
    @State var currentMonth: Int = 0 // 화살표버튼 클릭 시 월 update
    let dbModel = CalendarDB()
    @State var title: String = ""
    @State var taskDate: Date = Date()
    @State var tasksForSelectedDate: [Task] = []
    @FocusState var isTextFieldFocused: Bool    // 키보드 focus
    @State var isPresented = false //상세보기 sheet 조회 변수
    @Binding var dateValue : Date
    @State var selectedTask: Task? = nil // ForEach로 생성된 리스트의 task 값을 담을 변수
    
    @State var isAlert = false            // actionSheet 실행
    @State var isSubAlert = false            // subAlert 실행
    @State var isResultTrue = false
    @State var isResultFalse = false
    @State var date: Date = Date()              // 선택된 날짜 변수
    @State var time: Date = Date()              // 선택된 시간 변수
    @State var task: String = ""
    
    
    var body: some View {
        
        //요일 리스트
        let days: [String] = ["일","월","화","수","목","금","토"]
        
        VStack(spacing: 35, content: {
            
            //년도, 월 나타내기
            HStack(spacing: 20 ,content: {
                VStack(alignment: .leading, spacing: 10 ,content: {
                
                    Text(extraDate()[0])
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    Text("\(extraDate()[1])월")
                        .font(.title.bold())
                })//VStack
                
                Spacer(minLength: 0)
                
                //이전버튼 : month -1 처리
                Button(action: {
                    withAnimation{
                        currentMonth -= 1
                        updateCurrentMonth()
                    }
                }, label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                })
                
                //다음버튼 : month +1 처리
                Button(action: {
                    withAnimation{
                        currentMonth += 1
                        updateCurrentMonth()
                    }
                }, label: {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                })
                
            })//HStack
            .padding()
            
            // 요일 나타내기
            HStack(spacing: 0 ,content: {
                ForEach(days, id: \.self) {day in
                    Text(day)
                        .font(.callout)
                        .fontWeight(.semibold)
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                }
            })//HStack
            
            
            // 날짜 가져오기
            let columns = Array(repeating: GridItem(.flexible()), count: 7)
            LazyVGrid(columns: columns, spacing: 15, content: {
                ForEach(extraDate()) {value in
                    CardView(value: value)
                        .id(value.id)
                        .background(
//                            Capsule()
//                                .fill(Color("color2"))
//                                .padding(.horizontal, 8)
//                                .opacity(isSameDay(date1: value.date, date2: currentDate) ? 1 : 0)
                            
                            Circle()
                                .fill(Color("color2"))
                                .padding(.horizontal, 2)
                                .opacity(isSameDay(date1: value.date, date2: currentDate) ? 1 : 0)
                                .padding(.bottom, 20)
                        )
                }
            }) //LazyVGrid
            
            VStack(spacing: 10) {
                Text("일정")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding(.vertical, 20)
                
                if !tasksForSelectedDate.isEmpty {
                    ForEach(tasksForSelectedDate) { task in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(task.time, style: .time)
                                Text(task.title)
                                    .font(.title2.bold())
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(.black)
                            .background(
                                Color("color1")
                                    .opacity(0.3)
                                    .cornerRadius(10)
                            )
                            .onTapGesture {
                                selectedTask = task
                                isPresented = true
                            }
                    }// ForEach
                    
                } else {
                    Text("일정이 없습니다.")
                }
            }
            .padding()
            
        }) //제일 상위 VStack
        //월 update 처리하기
        .onChange(of: currentMonth) {
            updateCurrentMonth()
        }
        .onAppear {
            print("onAppear 실행")
            fetchTasksForSelectedDate()
        }
        .sheet(item: $selectedTask, onDismiss:  {
            fetchTasksForSelectedDate()
        }, content: { task in
            CalendarDetailView(task: task, currentDate: dateValue)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        })
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
                        .background(Color("myColor"), in: Circle())
                })
                .sheet(isPresented: $isAlert, onDismiss: {
                    fetchTasksForSelectedDate()
                }, content: { VStack(content: {
                        
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
                                isAlert = false //alert창 닫기
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
            .background(.clear)
            .padding(.bottom, 10)
            
        })//safeArea
        
    }// body
    
    
    /* MARK: CardView() */
    @ViewBuilder
    func CardView(value: DateValue) -> some View {
        VStack(content: {
            if value.day != -1 {
                // value.day 와 taskDate가 같으면 색 표시하기
                if let task = dbModel.queryDB().first(where: { task in
                    return isSameDay(date1: task.taskDate, date2: value.date)
                }){
                    //달력에 날짜 표시
                    Text("\(value.day)")
                        .font(.title3.bold())
                        .foregroundStyle(isSameDay(date1: task.taskDate, date2: currentDate) ? .white : .primary )
                        .frame(maxWidth: .infinity)
                    
                    Spacer()
                    
                    Circle()
                        .fill(isSameDay(date1: task.taskDate, date2: currentDate) ? .white : Color("color2"))
                        .frame(width: 10, height: 10)
                        .padding(.bottom, 10)
                }
                else {
                    Text("\(value.day)")
                        .font(.title3.bold())
                        .foregroundStyle(isSameDay(date1: value.date, date2: currentDate) ? .white : .primary )
                        .frame(maxWidth: .infinity)

                    Spacer()
                }
            }
        })
//        .padding(.vertical, 9)
        .frame(height: 50, alignment: .top)
        .onTapGesture (perform: {
            currentDate = value.date
            self.dateValue = value.date
            fetchTasksForSelectedDate()
        })
    }
    
    /* MARK: month 변경 시 다시 조회되도록 */
    func updateCurrentMonth() {
        currentDate = getCurrentMonth()
        fetchTasksForSelectedDate()
    }
    
    /* MARK: 스케줄러 조회 함수 */
    func fetchTasksForSelectedDate() {
        tasksForSelectedDate.removeAll()
        
        let taskMetaData = dbModel.queryDB().filter{ isSameDay(date1: $0.taskDate, date2: currentDate) }
        
        if let taskList = taskMetaData.first {
            tasksForSelectedDate = taskList.task
        }
        
    }
    
    /* MARK: 날짜 체크 */
    func isSameDay(date1: Date, date2: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date1, inSameDayAs: date2)
    }
    
    /* MARK: 년도와 월 정보 가져오기 */
    func extraDate() -> [String] {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY MM" //2024 06로 반환
        
        let date = formatter.string(from: currentDate)
        return date.components(separatedBy: " ")
    }
    
    /* MARK: 현재 Month 가져오기 */
    func getCurrentMonth() -> Date {
        let calendar = Calendar.current
        guard let currentMonth = calendar.date(byAdding: .month, value: self.currentMonth, to: Date()) else { return Date() }
        
        return currentMonth
    }
    
    /* MARK: 날짜 요소 뽑기 함수 */
    func extraDate() -> [DateValue] {
        let calendar = Calendar.current
        let currentMonth = getCurrentMonth()
        
        var days =  currentMonth.getAllDates().compactMap{date -> DateValue in
            //요일 가져오기
            let day = calendar.component(.day, from: date)
            
            return DateValue(day: day, date: date)
        }
        
        //정확한 요일을 얻기위한 offset
        let firstWeekday = calendar.component(.weekday, from: days.first?.date ?? Date())
        
        // 빈 공간 -1로 넣기
        for _ in 0..<firstWeekday - 1 {
            days.insert(DateValue(day: -1, date: Date()), at: 0)
        }
        
        return days
    }
}

#Preview {
    CalendarView()
}

// 이번 달 날짜를 얻기위한 extension
extension Date {
    func getAllDates() -> [Date] {
        
        let calendar = Calendar.current
        
        //시작날짜 정하기
        let startDate = calendar.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
        
        //range(of:in:for) =>
        // of : 더 작은 달력 구성요소
        // in : 더 큰 달력 구성요소
        // date : 계산이 수행되는 절대 시간
        // 위에서 설정한 시작날짜로 부터 계산되게 한다.
        let range = calendar.range(of: .day, in: .month, for: startDate)!
        
        //date 가져오기
        
        //compactMap : nil값은 알아서 제거해서 보여준다.
        return range.compactMap{day -> Date in
            return calendar.date(byAdding: .day, value: day-1, to: startDate)!
        }
    }
}

