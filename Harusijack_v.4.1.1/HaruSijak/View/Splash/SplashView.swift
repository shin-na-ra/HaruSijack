
// MARK: -- Description
/*
 Description : HaruSijack App splash 화면
 Date : 2024.6.14
 Author : j.park
 Dtail :
 Updates :
 * 2024.06.14 by j.park : 1.splash화면 생성
                          2. Lotti 적용
 
 */

//

import SwiftUI
import Lottie

struct SplashView: View {
    @State private var isActive = false
    
    var body: some View {
        VStack {
            
            Spacer()
            ZStack {
                LottieView(jsonName: "train2")
                    .frame(width: 400, height: 400)
                Spacer()
                
//                RoundedRectangle(cornerRadius: 10)
//                            .stroke(Color.white, lineWidth: 4)
//                            .background(Color.white)
//                            .frame(width: 200, height: 100)
//                            .offset(x: 0, y: 100)
                        
                        Text("하루시작")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                            .offset(y: 120)
                
            }
            
            Spacer()
            Spacer()
            
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    self.isActive = true
                }
            }
        }
        //메인화면으로 이동
        .fullScreenCover(isPresented: $isActive) {
            PredictView03()
        }
    }
}

#Preview {
    SplashView()
}
