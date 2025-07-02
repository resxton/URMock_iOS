import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let rootViewController = PaymentScreenViewController(paymentId: "12345", paymentService: MockPaymentService())
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        handleDeepLink(url: url)
    }

    private func handleDeepLink(url: URL) {
        print("Получили диплинк:", url)

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems

        if let paymentId = queryItems?.first(where: { $0.name == "paymentId" })?.value {
            openPaymentScreen(paymentId: paymentId)
        }
    }

    private func openPaymentScreen(paymentId: String) {
        guard let window = self.window else { return }
        let paymentVC = PaymentScreenViewController(
            paymentId: paymentId,
            paymentService: MockPaymentService()
        )
        let nav = window.rootViewController as? UINavigationController
        nav?.pushViewController(paymentVC, animated: true)
    }
}
