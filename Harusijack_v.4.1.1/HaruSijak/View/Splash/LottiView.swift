// MARK: -- Description
/*
 Description : Lotti 설정 화면
 Date : 2024.6.14
 Author : j.park
 Dtail :
 Updates :
 * 2024.06.14 by j.park : 1. Lotti 설정
 
 */

//

import Foundation
import SwiftUI
import Lottie
// SwiftUI에서 사용하기 위헤 UIKit을 import해주세요
import UIKit

// 로티 애니메이션 뷰
struct LottieView: UIViewRepresentable {
    var name : String
    var loopMode: LottieLoopMode
    var animationSpeed: CGFloat // 재생 속도
    
    // 간단하게 View로 JSON 파일 이름으로 애니메이션을 실행합니다.
    init(jsonName: String = "", loopMode : LottieLoopMode = .loop, animationSpeed: CGFloat = 2.0){
        self.name = jsonName
        self.loopMode = loopMode
        self.animationSpeed = animationSpeed
    }
    
    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView(frame: .zero)

        let animationView = LottieAnimationView()
        let animation = LottieAnimation.named(name)
        animationView.animation = animation
        
        animationView.contentMode = .scaleAspectFit
        // Loop기능(무한반복)
        animationView.loopMode = loopMode
        // 애니메이션을 재생
        animationView.play()
        // 백그라운드에서 재생이 멈추는 오류 방지
        animationView.backgroundBehavior = .pauseAndRestore

  
  
  
      animationView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(animationView)
         //높이, 넓이 제약
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
}
