import SwiftUI
import RayTracerCore

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Ray Tracer")
                .font(.largeTitle)
                .padding()

            Spacer()

            Rectangle()
                .fill(Color.black)
                .aspectRatio(16/9, contentMode: .fit)
                .overlay(
                    Text("Render Output")
                        .foregroundColor(.white.opacity(0.7))
                )
                .padding()

            Spacer()

            HStack {
                Button("", systemImage: "slider.horizontal.3") {
                    
                }
                Button("Render") {
                    // placeholder
                }

                Button("Save Image") {
                    // placeholder
                }
            }
            .padding()
        }
    }
}


#Preview {
    ContentView()
}
