import XCTest
@testable import EssentialApp
import EssentialFeediOS

class SceneDeleteTests: XCTestCase {

    func test_sceneWillConnectToSession_configuresRootViewController() {

        let sut = SceneDelegate()
        sut.window = UIWindow()
        sut.configureWindow()

        let root = sut.window?.rootViewController
        let rootNavigation = root as? UINavigationController
        let topController = rootNavigation?.topViewController

        XCTAssertNotNil(rootNavigation, "Expected a navigation controller as root, got \(String(describing: root)) instead")
        XCTAssertTrue(topController is ListViewController, "Expected Feed controller as top controller, got \(String(describing: topController)) instead")
    }

}
