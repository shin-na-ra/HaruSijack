//
//  ChatView.swift
//  HaruSijak
//
//  Created by 신나라 on 7/2/24.

/* 2024.07.03 snr : 챗봇 화면 구성
        - ScrollView로 되게 구현해야됨
        - 텍스트 입력부분 Zstack으로 감싸기
*/

import SwiftUI

struct ChatView: View {
    
    @State var showWelcomMessage = false
    @State var isAnimation = false
    @State var humanInput: String = ""
    @State var chatLogs: [String] = ["C:안녕하세요. 하루입니다. 무엇을 도와드릴까요?"]
    @FocusState var isTextFieldFocused: Bool
    
    var body: some View {
        
        // ****** 이부분 ScrollView로 되게 수정해야됨
        VStack(content: {
            if showWelcomMessage {
//                showChatBotTalk("안녕하세요. 하루입니다. 무엇을 도와드릴까요?")
                
                
                // 대화 기록 표시
                ForEach(chatLogs, id: \.self) { log in
                    if log.starts(with: "H:") {
                        if let humanTalk = log.split(separator: ":").last.map(String.init)?.trimmingCharacters(in: .whitespaces) {
                            showHumanTalk(humanTalk)
                        }
                    } else {
                        if let chatBotTalk = log.split(separator: ":").last.map(String.init)?.trimmingCharacters(in: .whitespaces) {
                            showChatBotTalk(chatBotTalk)
                        }
                    }
                }
                        
                
            }// if
            
            
            Spacer()
            
            
            //****** 이부분 Zstack으로 수정해야되고
            HStack(content: {
                TextField("텍스트를 입력하세요.", text: $humanInput)
                    .frame(width: UIScreen.main
                        .bounds.width * 0.80)
                    .cornerRadius(8)
                    .focused($isTextFieldFocused)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    sendUserInput()
                }, label: {
                    Image(systemName: "arrow.up.square.fill")
                        .font(.largeTitle)
                })
            })
            .padding(.horizontal, 20)
        })
        .padding(.top, 40)
        .navigationTitle("하루챗봇")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear{
            DispatchQueue.main.asyncAfter(deadline:  .now() + 0.5 ) {
                withAnimation(.easeIn(duration: 1)) {
                    isAnimation.toggle()
                    showWelcomMessage = true
                }
            }
        }
    }
    
    // -------------------- functions ----------------------
    
    // 사용자 입력 전송 및 처리
    func sendUserInput() {
        //사용자 입력 기록 추가
        chatLogs.append("H:" + humanInput)
        
        print("ddd : ", chatLogs[1])
        // 챗봇이 응답하도록 로직 구현
//        let response = generateChatBotResponse(humanInput)
//        chatLogs.append("C:" + response)
        
        humanInput = ""
    }
    
    // 사용자가 입력한 단어 분석 -> return값은 String으로 일단
    func generateChatBotResponse(_ quest: String) -> String {
        
        if quest.contains("지하철 혼잡도") || quest.contains("혼잡도") {
            // [지하철 혼잡도], [혼잡도]라는 단어가 포함되어 있을 때 로직 => 사용자 입력텍스트에서 유사도를 체크해야되겠??
        } else if (quest.contains("일정") || quest.contains("스케줄") || quest.contains("스케쥴")) {
            // [일정], [스케쥴], [스케줄]라는 단어가 포함되어 있을 때 로직 => 사용자 입력텍스트에서 유사도를 체크해야되겠??
        }
        
        return ""
    }
    
    /* MARK: chatbot Image Circle & Talk */
    func showChatBotTalk(_ talk: String) -> some View {
        VStack(content: {
            HStack {
                ZStack {
                    Circle()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.blue)
                    
                    Image("chatImage")
                        .resizable()
                        .frame(width: 35, height: 35)
                }
                Spacer()
            }
            
            HStack {
                Text(talk)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .transition(.scale)
                .alignmentGuide(.leading) { _ in 0}
                Spacer()
            }
//             Spacer()
        }) //Vstack
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    } //showChatImage
    
    
    /* MARK: Human Image Circle & Talk */
    func showHumanTalk(_ talk: String) -> some View {
        VStack(content: {
            HStack {
                Spacer()
                ZStack {
                    Circle()
                        .frame(width: 50, height: 50)
                        .foregroundColor(Color("myColor"))
                    
                    Image("human")
                        .resizable()
                        .frame(width: 35, height: 35)
                }
            }
            
            HStack {
                Spacer()
                Text(talk)
                    .padding()
                    .background(Color("myColor"))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .transition(.scale)
                .alignmentGuide(.leading) { _ in 0}
                
            }
//             Spacer()
        }) //Vstack
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding()
    } //showChatImage
    
    
}

#Preview {
    ChatView()
}
