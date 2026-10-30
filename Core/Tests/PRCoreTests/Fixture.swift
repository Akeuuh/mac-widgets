import Foundation
import PRCore

func content(_ fixture: String) throws -> WidgetContent {
    let url = Bundle.module.url(forResource: fixture, withExtension: "json", subdirectory: "Fixtures")!
    return try makeContent(from: Data(contentsOf: url))
}
