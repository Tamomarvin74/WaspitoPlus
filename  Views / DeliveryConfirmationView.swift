import SwiftUI
import Lottie

 struct LottieAnimationViewWrapper: UIViewRepresentable {
    var animationName: String
    var loopMode: LottieLoopMode = .loop
    var contentMode: UIView.ContentMode = .scaleAspectFit

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let animationView = LottieAnimationView(name: animationName)
        animationView.contentMode = contentMode
        animationView.loopMode = loopMode
        animationView.play()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

 struct DeliveryConfirmationView: View {
    let patientName: String
    let phoneNumber: String
    
    @State private var bikeOffsetX: CGFloat = -150
    @State private var bounce: CGFloat = 0
    private let screenWidth: CGFloat = UIScreen.main.bounds.width

    var body: some View {
        VStack(spacing: 30) {
            Text("👨‍⚕️ Pharmacist: Thanks \(patientName)!")
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)
            
            Text("Our delivery agent will contact you at \(phoneNumber) and arrive soon.")
                .multilineTextAlignment(.center)
            
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 180)
                    .cornerRadius(12)
                
                 LottieAnimationViewWrapper(animationName: " delivery_man_on_bike")
                    .frame(width: 120, height: 120)
                    .offset(x: bikeOffsetX, y: bounce)
                    .shadow(color: Color.black.opacity(0.3), radius: 5, x: 2, y: 2)
            }
            .padding()
            .onAppear {
                startBikeAnimation()
                withAnimation(Animation.easeInOut(duration: 0.4).repeatForever(autoreverses: true)) {
                    bounce = -5
                }
            }
        }
        .padding()
    }

    private func startBikeAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            DispatchQueue.main.async {
                bikeOffsetX += 3
                if bikeOffsetX > screenWidth {
                    bikeOffsetX = -150
                }
            }
        }
    }
}

 struct DeliveryConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        DeliveryConfirmationView(patientName: "James Brown", phoneNumber: "1234567890")
    }
}

