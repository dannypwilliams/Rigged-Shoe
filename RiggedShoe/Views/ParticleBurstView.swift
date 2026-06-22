import SwiftUI

struct ParticleBurstView: View {
    let trigger: UUID
    var color: Color = CasinoTheme.gold
    var secondaryColor: Color = CasinoTheme.emerald
    var count: Int = 26
    var intensity: CGFloat = 1

    @State private var particles: [Particle] = []

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .offset(x: particle.x, y: particle.y)
                    .opacity(particle.opacity)
                    .scaleEffect(particle.scale)
                    .blur(radius: particle.blur)
            }
        }
        .allowsHitTesting(false)
        .onChange(of: trigger) { _, _ in
            burst()
        }
        .onAppear {
            burst()
        }
    }

    private func burst() {
        particles = (0..<count).map { index in
            let angle = Double(index) / Double(max(1, count)) * Double.pi * 2
            let distance = CGFloat.random(in: 42...130) * intensity

            return Particle(
                x: 0,
                y: 0,
                targetX: cos(angle) * distance,
                targetY: sin(angle) * distance,
                size: CGFloat.random(in: 4...10) * intensity,
                scale: 0.35,
                opacity: 1,
                blur: CGFloat.random(in: 0...1.2),
                color: Bool.random() ? color : secondaryColor
            )
        }

        withAnimation(.easeOut(duration: 0.72)) {
            particles = particles.map { particle in
                Particle(
                    x: particle.targetX,
                    y: particle.targetY,
                    targetX: particle.targetX,
                    targetY: particle.targetY,
                    size: particle.size,
                    scale: 1,
                    opacity: 0,
                    blur: particle.blur,
                    color: particle.color
                )
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.78) {
            particles = []
        }
    }

    private struct Particle: Identifiable {
        let id = UUID()
        let x: CGFloat
        let y: CGFloat
        let targetX: CGFloat
        let targetY: CGFloat
        let size: CGFloat
        let scale: CGFloat
        let opacity: Double
        let blur: CGFloat
        let color: Color
    }
}

struct CasinoLightsView: View {
    @State private var pulse = false

    var body: some View {
        TimelineView(.animation) { _ in
            Canvas { context, size in
                let lights = 18

                for index in 0..<lights {
                    let progress = CGFloat(index) / CGFloat(max(1, lights - 1))
                    let x = size.width * progress
                    let y = CGFloat(index % 2 == 0 ? 10 : 28)
                    let rect = CGRect(x: x - 3, y: y, width: 6, height: 6)
                    let color = index % 3 == 0 ? CasinoTheme.gold : (index % 3 == 1 ? CasinoTheme.red : CasinoTheme.emerald)
                    context.fill(Path(ellipseIn: rect), with: .color(color.opacity(pulse ? 0.92 : 0.36)))
                }
            }
        }
        .frame(height: 36)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.85).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
        .allowsHitTesting(false)
    }
}
