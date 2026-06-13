import XCTest
@testable import LinguaFloatCore

final class ProviderStatusTests: XCTestCase {
    func testSharedStatusCopyIsModelSourceNeutral() {
        XCTAssertEqual(ProviderStatus.checking.displayText, "检查模型")
        XCTAssertEqual(ProviderStatus.available.displayText, "模型可用")
        XCTAssertEqual(ProviderStatus.loading.displayText, "等待模型")

        XCTAssertEqual(ProviderStatus.checking.detailText, "正在检查模型服务...")
        XCTAssertEqual(ProviderStatus.available.detailText, "当前模型可用。")
        XCTAssertEqual(ProviderStatus.loading.detailText, "首次加载模型可能需要更长时间。")
        XCTAssertEqual(ProviderStatus.generating.detailText, "正在生成英文。")
    }
}
