// MARK: -- Description
/*
    Description: 각 지하철 역별 승,하차인원 에측 페이지
    Date : 2024.6.11
    Author : Shin  + pdg + pjh
    Dtail :
    Updates :
         - 2024.06.11 j.park :
            * 1. 버튼 구현
            * 2. flask 서버에서 하차인원 Json통신
         - 2024.06.12 j.park :
            * 1. 현재시간, 특정역 기준 하차인원 추가
         - 2024.06.13 snr :
            출근시간대 설정 sheet 연결
         - 2024.06.13 j.park :
            1.승차인원 추가
            2. actionsheet에서 sheet로 변경
         - 2024.06.14 j.park :
            1.특정역에 대한 전체 승하차인원 그래프 구현
         - 2024.06.17 j.park :
            1. 예측페이지 진입전 lotti를 활용한 대기화면 구현
         - 2024.06.23 jdpark :
            1. 지하철 노선 정보 중 5호선 추가 struct 파일로 만들고 거기서 불러오게 함.
         - 2024.06.24 by j, d park :
            * 1. sheet(예측페이지) 분리
         - 2024.07.01 by J.Park :
            * 1. 지하철 환승역 구현완료
              2. 지하철 초기화면 위치,zoom scale 지정(이미지 좌측상단 -> 중앙)
         - 2024.07.01 by J.Park :
            * 1. Zoom,Drag시 기준 좌표 변경되는 오류 수정
              2. sheet 호출시 async 삭제
 
 */

//
//
//
//import SwiftUI
//
//struct PredictView03: View {
//    
//    var body: some View {
//        
//        NavigationView{
//            VStack(content: {
//                ZStack(content: {
//                    GeometryReader { geometry in
//                        subwayImage()
//                            .edgesIgnoringSafeArea(.bottom)
//                    } // GR
//                })//ZS
//            }) // VS
//        }//NV
//        .navigationTitle("승하차 인원 예측")
//        .toolbar{
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button(action : {
//                    print("설정 버튼 클릭")
//                }) {
//                    Image(systemName: "gearshape")
//                        .imageScale(.large)
//                }
//            }
//        }
//    }
//}
//
//// MARK: 지하철 이미지
//struct subwayImage : View {
//    
//    // MARK: Server request 변수
//    @State var stationName: String = ""
//    @State var stationLine: [String] = []
//    
//    @State private var showAlertForStation = false
//    // 승차인원 JSON 받아오는 변수(승차)
//    @State var serverResponseBoardingPerson: [String] = []
//    // 승차인원 JSON 받아오는 변수(하차)
//    @State var serverResponseAlightingPerson: [String] = []
//    // 현재시간 열차의 승차인원 변수
//    @State var boardingPersonValue: [Double] = []
//    // 현재시간 열차의 하차인원 변수
//    @State var AlightingPersonValue: [Double] = []
//    // 현재 날짜 저장
//    @State var showingcurrentdate = ""
//    // 현재 시간 저장
//    @State var showingcurrentTime = ""
//    // 승차인원 JSON 값을 dictionary로 변환 변수
//    @State private var BoardingPersondictionary: [[String: Double]] = []
//    //하차인원
//    @State private var AlightinggPersondictionary: [[String: Double]] = []
//    
//    //로딩중 화면
//    @State private var isLoading = false
//    
//    // MARK: 화면조작 변수
//    @State var currentScale: CGFloat = 0.5
//    @State var previousScale: CGFloat = 1.0
//    let minScale: CGFloat = 0.4
//    let maxScale: CGFloat = 1.1
//    //드레그 우선순위 주기
//    @GestureState private var dragState = CGSize.zero
//    @GestureState private var scaleState: CGFloat = 1.0
//    
//    
//    @State var currentOffset = CGSize(width: -1500, height: -800)
//    @State var previousOffset = CGSize.zero
//    let line23 = SubwayList().totalStation
//    //    let line23 = SubwayList().testStation
//    let imgWidth = UIImage(named: "subwayMap")!.size.width
//    let imgHeight = UIImage(named: "subwayMap")!.size.height
//    //이미지 크기 차이때문은 아닌거같음
//    
//    
//    var body: some View {
//        GeometryReader { geometry in
//            Image("subwayMap")
//                .resizable()
//                .frame(
//                    width: imgWidth * self.currentScale,
//                    height: imgHeight * self.currentScale)
//                .overlay( GeometryReader { geometry in
//                    ForEach(Array(line23.enumerated()), id: \.0) { index, station in
//                        Button(action: {
//                            isLoading = true
//                            
//                            let stationLines = [station.3, station.4, station.5]
//                                .filter { $0 != 0 }// 호선값이 0이 아닐때만 반환
//                                .map { String($0) }// string으로 변환
//                            handleStationClick(stationName: station.0, stationLines: stationLines)
//                            //                            $showAlertForStation
//                        }) {
//                            Text("")
//                                .font(.system(size: 10))
//                                .bold()
//                                .frame(width: 15, height: 15)
//                                .background(Color.clear)
//                        }
//                        .position(  x: (station.2 * self.currentScale),
//                                    y: (station.1 * self.currentScale))
//                    }//button
//                })// OverLay
//                .edgesIgnoringSafeArea(.all)
//                .aspectRatio(contentMode: .fill)
//                .offset(x: self.currentOffset.width, y: self.currentOffset.height)
//                .offset(dragState)
//            //                .scaleEffect(scaleState)
//                .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
//                    .onChanged { value in
//                        let dragSpeed: CGFloat = 0.05
//                        let newOffsetX = self.currentOffset.width + value.translation.width / self.currentScale * dragSpeed
//                        let newOffsetY = self.currentOffset.height + value.translation.height / self.currentScale * dragSpeed
//                        
//                        // 이미지 크기 계산
//                        let scaledWidth = self.imgWidth * self.currentScale
//                        let scaledHeight = self.imgHeight * self.currentScale
//                        
//                        // 드래그 제한 계산
//                        let minX = min(0, geometry.size.width - scaledWidth)
//                        let maxX = max(0, geometry.size.width - scaledWidth)
//                        
//                        let minY = min(0, geometry.size.height - scaledHeight )
//                        let maxY = max(0, geometry.size.height - scaledHeight )
//                        
//                        // 오프셋 제한 적용
//                        self.currentOffset = CGSize(
//                            width: min(maxX, max(minX, newOffsetX)),
//                            height: min(maxY, max(minY, newOffsetY)))
//                    }
//                         
//                    .onEnded { value in self.previousOffset = CGSize.zero })
//            
//                .gesture(MagnificationGesture(minimumScaleDelta: 0)
//                    .onChanged { value in
//                        let delta = value / self.previousScale
//                        self.previousScale = value
//                        
//                        var newScale = self.currentScale * delta
//                        newScale = min(max(newScale, self.minScale), self.maxScale)
//                        
//                        let deltaScale = newScale / self.currentScale
//                        
//                        // 현재 터치 위치를 기준으로 확대/축소
//                        let touchPoint = CGPoint(
//                            x: geometry.frame(in: .local).midX,
//                            y: geometry.frame(in: .local).midY
//                        )
//                        print(imgWidth)
//                        print(imgHeight)
//                        withAnimation(.interpolatingSpring(stiffness: 300, damping: 30)) {
//                            self.currentOffset.width = (self.currentOffset.width - touchPoint.x) * deltaScale + touchPoint.x
//                            self.currentOffset.height = (self.currentOffset.height - touchPoint.y) * deltaScale + touchPoint.y
//                            self.currentScale = newScale
//                        }
//                    }
//                    .onEnded { value in
//                        self.previousScale = 1.0
//                    }
//                )}//GeometryReader
//        .sheet(isPresented: $showAlertForStation, onDismiss: {
//            // 변수 초기화
//            isLoading = false
//            stationName = ""
//            stationLine = []
//            boardingPersonValue = []
//            AlightingPersonValue = []
//            BoardingPersondictionary = []
//            AlightinggPersondictionary = []
//            serverResponseBoardingPerson = []
//            serverResponseAlightingPerson = []
//        })  {
//            SheetContentView(
//                isLoading: $isLoading,
//                stationName: $stationName,
//                stationLine: $stationLine,
//                showingcurrentTime: $showingcurrentTime,
//                boardingPersonValue: $boardingPersonValue,
//                AlightingPersonValue: $AlightingPersonValue,
//                BoardingPersondictionary: $BoardingPersondictionary,
//                AlightinggPersondictionary: $AlightinggPersondictionary,
//                serverResponseBoardingPerson: $serverResponseBoardingPerson,
//                serverResponseAlightingPerson:$serverResponseAlightingPerson
//            )
//        }//sheet
//        //        }// GeometryReader
//    }// View
//    // MARK: Functions
//    
//    func handleStationClick(stationName: String, stationLines: [String]) {
//        self.stationName = stationName
//        self.stationLine = stationLines
//        
//        let (dateString, timeString) = getCurrentDateTime()
//        showingcurrentTime = timeString
//        showingcurrentdate = dateString
//        // 배열에 들어온 호선 수 만큼 반복
//        print("stationline-----------------")
//        print(stationLines)
//        print("stationline-----------------")
//        for line in stationLines {
//            // 승차인원
//            fetchDataFromServerBoarding(stationName: stationName, date: dateString, time: timeString, stationLine: line) { responseString in
//                self.serverResponseBoardingPerson.append(responseString)
//                self.boardingPersonValue.append(getValueForCurrentTime(jsonString: responseString, currentTime: timeString))
//                if let dictionary = convertJSONStringToDictionary(responseString) {
//                    var tempBoardingPersondictionary: [String: Double] = [:]
//                    let sortedKeys = dictionary.keys.sorted()
//                    
//                    let lowerBound = max(0, Int(self.showingcurrentTime)! - 7)
//                    let upperBound = min(sortedKeys.count - 1, Int(self.showingcurrentTime)! - 3)
//                    
//                    if lowerBound <= upperBound && sortedKeys.indices.contains(upperBound) {
//                        for index in lowerBound...upperBound {
//                            let key = sortedKeys[index]
//                            if let value = dictionary[key] {
//                                tempBoardingPersondictionary[key] = value
//                            }
//                        }
//                    }
//                    self.BoardingPersondictionary.append(tempBoardingPersondictionary)
//                } else {
//                    print("인덱스 범위 오류")
//                }
//            }
//            
//            // 하차인원
//            fetchDataFromServerAlighting(stationName: stationName, date: dateString, time: timeString, stationLine: line) { responseString in
//                self.serverResponseAlightingPerson.append(responseString)
//                self.AlightingPersonValue.append(getValueForCurrentTime(jsonString: responseString, currentTime: timeString))
//                
//                if let dictionary = convertJSONStringToDictionary(responseString) {
//                    var tempAlightingPersondictionary: [String: Double] = [:]
//                    let sortedKeys = dictionary.keys.sorted()
//                    
//                    let lowerBound = max(0, Int(self.showingcurrentTime)! - 7)
//                    let upperBound = min(sortedKeys.count - 1, Int(self.showingcurrentTime)! - 3)
//                    
//                    if lowerBound <= upperBound && sortedKeys.indices.contains(upperBound) {
//                        for index in lowerBound...upperBound {
//                            let key = sortedKeys[index]
//                            if let value = dictionary[key] {
//                                tempAlightingPersondictionary[key] = value
//                            }
//                        }
//                    }
//                    self.AlightinggPersondictionary.append(tempAlightingPersondictionary)
//                } else {
//                    print("인덱스 범위에 해당하는 요소가 없습니다.")
//                }
//import SwiftUI
//
//struct PredictView03: View {
//    
//    init() {
//            // UINavigationBarAppearance를 사용하여 네비게이션 바 스타일 설정
//            let appearance = UINavigationBarAppearance()
//            appearance.backgroundColor = UIColor(named: "color2") // 배경색 설정
//            appearance.titleTextAttributes = [.foregroundColor: UIColor.black] // 타이틀 텍스트 색상 설정
//            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black] // 큰 타이틀 텍스트 색상 설정
//            
//            UINavigationBar.appearance().standardAppearance = appearance
//            UINavigationBar.appearance().scrollEdgeAppearance = appearance
//        
//        }
//
//    var body: some View {
//        NavigationView {
//            ZStack {
//                subwayImage()
////                    .edgesIgnoringSafeArea(.bottom)
//            }
//            .navigationTitle("승하차 인원 예측") // 제목 표시
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    NavigationLink(destination: SettingView(stationName: "중화", line: 7, time: 10)) {
//                        Image(systemName: "gearshape")
//                            .imageScale(.large)
//                            .foregroundColor(.black) // 버튼 아이콘 색상 변경
//                    }
//                }
//            }
//        } // NavigationView
//    }
//}
//
//// MARK: 지하철 이미지
//struct subwayImage: View {
//
//    // MARK: Server request 변수
//    @State var stationName: String = ""
//    @State var stationLine: [String] = []
//
//    @State private var showAlertForStation = false
//    @State var serverResponseBoardingPerson: [String] = []
//    @State var serverResponseAlightingPerson: [String] = []
//    @State var boardingPersonValue: [Double] = []
//    @State var AlightingPersonValue: [Double] = []
//    @State var showingcurrentdate = ""
//    @State var showingcurrentTime = ""
//    @State private var BoardingPersondictionary: [[String: Double]] = []
//    @State private var AlightinggPersondictionary: [[String: Double]] = []
//    @State private var isLoading = false
//
//    // MARK: 화면조작 변수
//    @State var currentScale: CGFloat = 0.5
//    @State var previousScale: CGFloat = 1.0
//    let minScale: CGFloat = 0.4
//    let maxScale: CGFloat = 1.1
//    @GestureState private var dragState = CGSize.zero
//    @GestureState private var scaleState: CGFloat = 1.0
//
//    @State var currentOffset = CGSize(width: -1500, height: -800)
//    @State var previousOffset = CGSize.zero
//    let line23 = SubwayList().totalStation
//    let imgWidth = UIImage(named: "subwayMap")!.size.width
//    let imgHeight = UIImage(named: "subwayMap")!.size.height
//
//    var body: some View {
//        GeometryReader { geometry in
//            Image("subwayMap")
//                .resizable()
//                .frame(
//                    width: imgWidth * self.currentScale,
//                    height: imgHeight * self.currentScale)
//                .overlay(GeometryReader { geometry in
//                    ForEach(Array(line23.enumerated()), id: \.0) { index, station in
//                        Button(action: {
//                            isLoading = true
//
//                            let stationLines = [station.3, station.4, station.5]
//                                .filter { $0 != 0 }
//                                .map { String($0) }
//                            handleStationClick(stationName: station.0, stationLines: stationLines)
//                        }) {
//                            Text("")
//                                .font(.system(size: 10))
//                                .bold()
//                                .frame(width: 15, height: 15)
//                                .background(Color.clear)
//                        }
//                        .position(x: (station.2 * self.currentScale),
//                                  y: (station.1 * self.currentScale))
//                    }
//                })
//                .edgesIgnoringSafeArea(.all)
//                .aspectRatio(contentMode: .fill)
//                .offset(x: self.currentOffset.width, y: self.currentOffset.height)
//                .offset(dragState)
//                .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
//                    .onChanged { value in
//                        let dragSpeed: CGFloat = 0.05
//                        let newOffsetX = self.currentOffset.width + value.translation.width / self.currentScale * dragSpeed
//                        let newOffsetY = self.currentOffset.height + value.translation.height / self.currentScale * dragSpeed
//
//                        let scaledWidth = self.imgWidth * self.currentScale
//                        let scaledHeight = self.imgHeight * self.currentScale
//
//                        let minX = min(0, geometry.size.width - scaledWidth)
//                        let maxX = max(0, geometry.size.width - scaledWidth)
//
//                        let minY = min(0, geometry.size.height - scaledHeight)
//                        let maxY = max(0, geometry.size.height - scaledHeight)
//
//                        self.currentOffset = CGSize(
//                            width: min(maxX, max(minX, newOffsetX)),
//                            height: min(maxY, max(minY, newOffsetY)))
//                    }
//                    .onEnded { value in self.previousOffset = CGSize.zero })
//
//                .gesture(MagnificationGesture(minimumScaleDelta: 0)
//                    .onChanged { value in
//                        let delta = value / self.previousScale
//                        self.previousScale = value
//
//                        var newScale = self.currentScale * delta
//                        newScale = min(max(newScale, self.minScale), self.maxScale)
//
//                        let deltaScale = newScale / self.currentScale
//
//                        let touchPoint = CGPoint(
//                            x: geometry.frame(in: .local).midX,
//                            y: geometry.frame(in: .local).midY
//                        )
//                        withAnimation(.interpolatingSpring(stiffness: 300, damping: 30)) {
//                            self.currentOffset.width = (self.currentOffset.width - touchPoint.x) * deltaScale + touchPoint.x
//                            self.currentOffset.height = (self.currentOffset.height - touchPoint.y) * deltaScale + touchPoint.y
//                            self.currentScale = newScale
//                        }
//                    }
//                    .onEnded { value in
//                        self.previousScale = 1.0
//                    }
//                )
//        }
//        .sheet(isPresented: $showAlertForStation, onDismiss: {
//            isLoading = false
//            stationName = ""
//            stationLine = []
//            boardingPersonValue = []
//            AlightingPersonValue = []
//            BoardingPersondictionary = []
//            AlightinggPersondictionary = []
//            serverResponseBoardingPerson = []
//            serverResponseAlightingPerson = []
//        })  {
//            SheetContentView(
//                isLoading: $isLoading,
//                stationName: $stationName,
//                stationLine: $stationLine,
//                showingcurrentTime: $showingcurrentTime,
//                boardingPersonValue: $boardingPersonValue,
//                AlightingPersonValue: $AlightingPersonValue,
//                BoardingPersondictionary: $BoardingPersondictionary,
//                AlightinggPersondictionary: $AlightinggPersondictionary,
//                serverResponseBoardingPerson: $serverResponseBoardingPerson,
//                serverResponseAlightingPerson: $serverResponseAlightingPerson
//            )
//        }
//    }
//
//    func handleStationClick(stationName: String, stationLines: [String]) {
//        self.stationName = stationName
//        self.stationLine = stationLines
//
//        let (dateString, timeString) = getCurrentDateTime()
//        showingcurrentTime = timeString
//        showingcurrentdate = dateString
//
//        for line in stationLines {
//            fetchDataFromServerBoarding(stationName: stationName, date: dateString, time: timeString, stationLine: line) { responseString in
//                self.serverResponseBoardingPerson.append(responseString)
//                self.boardingPersonValue.append(getValueForCurrentTime(jsonString: responseString, currentTime: timeString))
//                if let dictionary = convertJSONStringToDictionary(responseString) {
//                    var tempBoardingPersondictionary: [String: Double] = [:]
//                    let sortedKeys = dictionary.keys.sorted()
//
//                    let lowerBound = max(0, Int(self.showingcurrentTime)! - 7)
//                    let upperBound = min(sortedKeys.count - 1, Int(self.showingcurrentTime)! - 3)
//
//                    if lowerBound <= upperBound && sortedKeys.indices.contains(upperBound) {
//                        for index in lowerBound...upperBound {
//                            let key = sortedKeys[index]
//                            if let value = dictionary[key] {
//                                tempBoardingPersondictionary[key] = value
//                            }
//                        }
//                    }
//                    self.BoardingPersondictionary.append(tempBoardingPersondictionary)
//                } else {
//                    print("인덱스 범위 오류")
//                }
//            }
//
//            fetchDataFromServerAlighting(stationName: stationName, date: dateString, time: timeString, stationLine: line) { responseString in
//                self.serverResponseAlightingPerson.append(responseString)
//                self.AlightingPersonValue.append(getValueForCurrentTime(jsonString: responseString, currentTime: timeString))
//
//                if let dictionary = convertJSONStringToDictionary(responseString) {
//                    var tempAlightingPersondictionary: [String: Double] = [:]
//                    let sortedKeys = dictionary.keys.sorted()
//
//                    let lowerBound = max(0, Int(self.showingcurrentTime)! - 7)
//                    let upperBound = min(sortedKeys.count - 1, Int(self.showingcurrentTime)! - 3)
//
//                    if lowerBound <= upperBound && sortedKeys.indices.contains(upperBound) {
//                        for index in lowerBound...upperBound {
//                            let key = sortedKeys[index]
//                            if let value = dictionary[key] {
//                                tempAlightingPersondictionary[key] = value
//                            }
//                        }
//                    }
//                    self.AlightinggPersondictionary.append(tempAlightingPersondictionary)
//                } else {
//                    print("인덱스 범위에 해당하는 요소가 없습니다.")
//                }
//
//            }
//        }
//        self.showAlertForStation = true
//    }
//    
//    // 현재시간 가져오는 함수
//    func getCurrentDateTime() -> (String, String) {
//        let currentDate = Date()
//        
//        // Date Formatter for Date
//        let dateFormatterDate = DateFormatter()
//        dateFormatterDate.dateFormat = "yyyy-MM-dd"
//        let dateString = dateFormatterDate.string(from: currentDate)
//        
//        // Date Formatter for Time
//        let dateFormatterTime = DateFormatter()
//        dateFormatterTime.dateFormat = "HH"
//        let timeString = String(Int(dateFormatterTime.string(from: currentDate))!)
//        
//        return (dateString, timeString)
//    }
//    
//    // Flask 통신을 위한 함수(승차인원)
//    func fetchDataFromServerBoarding(stationName: String, date: String, time: String, stationLine: String, completion: @escaping (String) -> Void) {
//        // 127.0.0.1
//        //개인 faskapi
//        let url = URL(string: "http://54.180.247.41:8000/subway/subwayRide")!
//        // 개인 flask
//        //        let url = URL(string: "http://127.0.0.1:5000/subwayRide")!
//        // aws flask
//        //        let url = URL(string: "http://54.180.247.41:5000/subwayRide")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        let parameters: [String: Any] = [
//            "stationName": stationName,
//            "date": date,
//            "time": time,
//            "stationLine": stationLine
//        ]
//        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let data = data, error == nil else {
//                print("Error:", error ?? "Unknown error")
//                return
//            }
//            if let responseString = String(data: data, encoding: .utf8) {
//                completion(responseString)
//                print("승차인원 ::******************")
//                print(responseString)
//            }
//        }
//        task.resume()
//    }
//    
//    // Flask 통신을 위한 함수(하차인원)
//    func fetchDataFromServerAlighting(stationName: String, date: String, time: String, stationLine: String, completion: @escaping (String) -> Void) {
//        print(stationName,date,time,stationLine)
//        //127.0.0.1 54.180.247.41:
//        //개인 fasdtapi
//        let url = URL(string: "http://54.180.247.41:8000/subway/subwayAlighting")!
//        //개인 flask
//        //        let url = URL(string: "http://127.0.0.1:5000/subwayAlighting")!
//        //aws flask
//        //        let url = URL(string: "http://54.180.247.41:5000/subwayAlighting")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        let parameters: [String: Any] = [
//            "stationName": stationName,
//            "date": date,
//            "time": time,
//            "stationLine": stationLine
//        ]
//        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let data = data, error == nil else {
//                print("Error:", error ?? "Unknown error")
//                
//                return
//            }
//            if let responseString = String(data: data, encoding: .utf8) {
//                completion(responseString)
//                print("하차인원 ::******************")
//                print(responseString)
//            }
//        }
//        task.resume()
//    }
//    
//    // 현재시간에 "시인원"을 더한 값을 key값으로 서버에서 받아온 JSON값에서 검색해서 값을 가져오는 함수
//    func getValueForCurrentTime(jsonString: String, currentTime: String) -> Double {
//        guard let jsonData = jsonString.data(using: .utf8) else { return 0.0 }
//        do {
//            if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
//                let keyForCurrentTime = "\(currentTime)시인원"
//                if let value = json[keyForCurrentTime] as? Double {
//                    return value
//                }
//            }
//        } catch {
//            print("Error parsing JSON:", error)
//        }
//        return 0.0
//    }
//    
//    // JSON 데이터를 dictionary로 변환(차트그리기 위해서)
//    func convertJSONStringToDictionary(_ jsonString: String) -> [String: Double]? {
//        guard let jsonData = jsonString.data(using: .utf8) else {
//            print("딕셔너리 변환 실패.")
//            return nil
//        }
//        
//        do {
//            let dictionary = try JSONDecoder().decode([String: Double].self, from: jsonData)
//            return dictionary
//        } catch {
//            print("Error decoding JSON: \(error.localizedDescription)")
//            return nil
//        }
//    }
//    
//}


import SwiftUI

struct PredictView03: View {
    
    init() {
           // 네비게이션 바 스타일을 모던하고 심플하게 설정
           let appearance = UINavigationBarAppearance()
           appearance.backgroundColor = UIColor.systemBackground // 배경을 기본 시스템 배경색으로 설정
           appearance.titleTextAttributes = [.foregroundColor: UIColor.label] // 기본 텍스트 색상으로 설정
           appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]

           UINavigationBar.appearance().standardAppearance = appearance
           UINavigationBar.appearance().scrollEdgeAppearance = appearance
       }

    var body: some View {
        NavigationView {
            ZStack {
                subwayImage()
            }
            .navigationTitle("승하차 인원 예측")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: SettingView(stationName: "중화", line: 7, time: 10)) {
                            Image(systemName: "gearshape.fill")
                                .imageScale(.large)
                                .foregroundColor(.primary) // 아이콘 색상을 기본 텍스트 색상으로 설정
                        }
                    }
                }
        } // NavigationView
    }
}

// MARK: 지하철 이미지
struct subwayImage: View {

    // MARK: Server request 변수
    @State var stationName: String = ""
    @State var stationLine: [String] = []

    @State private var showAlertForStation = false
    @State var serverResponseBoardingPerson: [String] = []
    @State var serverResponseAlightingPerson: [String] = []
    @State var boardingPersonValue: [Double] = []
    @State var AlightingPersonValue: [Double] = []
    @State var showingcurrentdate = ""
    @State var showingcurrentTime = ""
    @State private var BoardingPersondictionary: [[String: Double]] = []
    @State private var AlightinggPersondictionary: [[String: Double]] = []
    @State private var isLoading = false

    // MARK: 화면조작 변수
    @State var currentScale: CGFloat = 0.5
    @State var previousScale: CGFloat = 1.0
    let minScale: CGFloat = 0.4
    let maxScale: CGFloat = 1.1
    @GestureState private var dragState = CGSize.zero
    @GestureState private var scaleState: CGFloat = 1.0

    @State var currentOffset = CGSize(width: -1500, height: -800)
    @State var previousOffset = CGSize.zero
    let line23 = SubwayList().totalStation
    let imgWidth = UIImage(named: "subwayMap")!.size.width
    let imgHeight = UIImage(named: "subwayMap")!.size.height

    var body: some View {
        GeometryReader { geometry in
            Image("subwayMap")
                .resizable()
                .frame(
                    width: imgWidth * self.currentScale,
                    height: imgHeight * self.currentScale)
                .overlay(GeometryReader { geometry in
                    ForEach(Array(line23.enumerated()), id: \.0) { index, station in
                        Button(action: {
                            isLoading = true

                            let stationLines = [station.3, station.4, station.5]
                                .filter { $0 != 0 }
                                .map { String($0) }
                            handleStationClick(stationName: station.0, stationLines: stationLines)
                        }) {
                            Text("")
                                .font(.system(size: 10))
                                .bold()
                                .frame(width: 15, height: 15)
                                .background(Color.clear)
                        }
                        .position(x: (station.2 * self.currentScale),
                                  y: (station.1 * self.currentScale))
                    }
                })
                .edgesIgnoringSafeArea(.all)
                .aspectRatio(contentMode: .fill)
                .offset(x: self.currentOffset.width, y: self.currentOffset.height)
                .offset(dragState)
                .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { value in
                        let dragSpeed: CGFloat = 0.05
                        let newOffsetX = self.currentOffset.width + value.translation.width / self.currentScale * dragSpeed
                        let newOffsetY = self.currentOffset.height + value.translation.height / self.currentScale * dragSpeed

                        let scaledWidth = self.imgWidth * self.currentScale
                        let scaledHeight = self.imgHeight * self.currentScale

                        let minX = min(0, geometry.size.width - scaledWidth)
                        let maxX = max(0, geometry.size.width - scaledWidth)

                        let minY = min(0, geometry.size.height - scaledHeight)
                        let maxY = max(0, geometry.size.height - scaledHeight)

                        self.currentOffset = CGSize(
                            width: min(maxX, max(minX, newOffsetX)),
                            height: min(maxY, max(minY, newOffsetY)))
                    }
                    .onEnded { value in self.previousOffset = CGSize.zero })

                .gesture(MagnificationGesture(minimumScaleDelta: 0)
                    .onChanged { value in
                        let delta = value / self.previousScale
                        self.previousScale = value

                        var newScale = self.currentScale * delta
                        newScale = min(max(newScale, self.minScale), self.maxScale)

                        let deltaScale = newScale / self.currentScale

                        let touchPoint = CGPoint(
                            x: geometry.frame(in: .local).midX,
                            y: geometry.frame(in: .local).midY
                        )
                        withAnimation(.interpolatingSpring(stiffness: 300, damping: 30)) {
                            self.currentOffset.width = (self.currentOffset.width - touchPoint.x) * deltaScale + touchPoint.x
                            self.currentOffset.height = (self.currentOffset.height - touchPoint.y) * deltaScale + touchPoint.y
                            self.currentScale = newScale
                        }
                    }
                    .onEnded { value in
                        self.previousScale = 1.0
                    }
                )
        }
        .sheet(isPresented: $showAlertForStation, onDismiss: {
            isLoading = false
            stationName = ""
            stationLine = []
            boardingPersonValue = []
            AlightingPersonValue = []
            BoardingPersondictionary = []
            AlightinggPersondictionary = []
            serverResponseBoardingPerson = []
            serverResponseAlightingPerson = []
        })  {
            SheetContentView(
                isLoading: $isLoading,
                stationName: $stationName,
                stationLine: $stationLine,
                showingcurrentTime: $showingcurrentTime,
                boardingPersonValue: $boardingPersonValue,
                AlightingPersonValue: $AlightingPersonValue,
                BoardingPersondictionary: $BoardingPersondictionary,
                AlightinggPersondictionary: $AlightinggPersondictionary,
                serverResponseBoardingPerson: $serverResponseBoardingPerson,
                serverResponseAlightingPerson: $serverResponseAlightingPerson
            )
        }
    }

    func handleStationClick(stationName: String, stationLines: [String]) {
        self.stationName = stationName
        self.stationLine = stationLines

        let (dateString, timeString) = getCurrentDateTime()
        showingcurrentTime = timeString
        showingcurrentdate = dateString

        for line in stationLines {
            fetchDataFromServerBoarding(stationName: stationName, date: dateString, time: timeString, stationLine: line) { responseString in
                self.serverResponseBoardingPerson.append(responseString)
                self.boardingPersonValue.append(getValueForCurrentTime(jsonString: responseString, currentTime: timeString))
                if let dictionary = convertJSONStringToDictionary(responseString) {
                    var tempBoardingPersondictionary: [String: Double] = [:]
                    let sortedKeys = dictionary.keys.sorted()

                    let lowerBound = max(0, Int(self.showingcurrentTime)! - 7)
                    let upperBound = min(sortedKeys.count - 1, Int(self.showingcurrentTime)! - 3)

                    if lowerBound <= upperBound && sortedKeys.indices.contains(upperBound) {
                        for index in lowerBound...upperBound {
                            let key = sortedKeys[index]
                            if let value = dictionary[key] {
                                tempBoardingPersondictionary[key] = value
                            }
                        }
                    }
                    self.BoardingPersondictionary.append(tempBoardingPersondictionary)
                } else {
                    print("인덱스 범위 오류")
                }
            }

            fetchDataFromServerAlighting(stationName: stationName, date: dateString, time: timeString, stationLine: line) { responseString in
                self.serverResponseAlightingPerson.append(responseString)
                self.AlightingPersonValue.append(getValueForCurrentTime(jsonString: responseString, currentTime: timeString))

                if let dictionary = convertJSONStringToDictionary(responseString) {
                    var tempAlightingPersondictionary: [String: Double] = [:]
                    let sortedKeys = dictionary.keys.sorted()

                    let lowerBound = max(0, Int(self.showingcurrentTime)! - 7)
                    let upperBound = min(sortedKeys.count - 1, Int(self.showingcurrentTime)! - 3)

                    if lowerBound <= upperBound && sortedKeys.indices.contains(upperBound) {
                        for index in lowerBound...upperBound {
                            let key = sortedKeys[index]
                            if let value = dictionary[key] {
                                tempAlightingPersondictionary[key] = value
                            }
                        }
                    }
                    self.AlightinggPersondictionary.append(tempAlightingPersondictionary)
                } else {
                    print("인덱스 범위 오류")
                }
            }
        }
        showAlertForStation = true
    }
}

// MARK: SheetContentView는 설정 화면을 나타내는 뷰
//struct SheetContentView: View {
//    @Binding var isLoading: Bool
//    @Binding var stationName: String
//    @Binding var stationLine: [String]
//    @Binding var showingcurrentTime: String
//    @Binding var boardingPersonValue: [Double]
//    @Binding var AlightingPersonValue: [Double]
//    @Binding var BoardingPersondictionary: [[String: Double]]
//    @Binding var AlightinggPersondictionary: [[String: Double]]
//    @Binding var serverResponseBoardingPerson: [String]
//    @Binding var serverResponseAlightingPerson: [String]
//
//    var body: some View {
//        VStack {
//            // SheetContentView 내용
//        }
//    }
//}


func getCurrentDateTime() -> (String, String) {
    let date = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    let dateString = formatter.string(from: date)

    formatter.dateFormat = "HH"
    let timeString = formatter.string(from: date)

    return (dateString, timeString)
}

func fetchDataFromServerBoarding(stationName: String, date: String, time: String, stationLine: String, completion: @escaping (String) -> Void) {
    // 서버에서 데이터 가져오기 로직
    completion("{ \"06\": 10.0, \"07\": 20.0, \"08\": 30.0 }") // 예시 JSON 응답
}

func fetchDataFromServerAlighting(stationName: String, date: String, time: String, stationLine: String, completion: @escaping (String) -> Void) {
    // 서버에서 데이터 가져오기 로직
    completion("{ \"06\": 5.0, \"07\": 10.0, \"08\": 15.0 }") // 예시 JSON 응답
}

func getValueForCurrentTime(jsonString: String, currentTime: String) -> Double {
    if let dictionary = convertJSONStringToDictionary(jsonString) {
        return dictionary[currentTime] ?? 0.0
    }
    return 0.0
}

func convertJSONStringToDictionary(_ jsonString: String) -> [String: Double]? {
    if let data = jsonString.data(using: .utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Double]
        } catch {
            print("JSON 변환 오류: \(error)")
        }
    }
    return nil
}



// MARK: Preview


#Preview {
    PredictView03()
}
