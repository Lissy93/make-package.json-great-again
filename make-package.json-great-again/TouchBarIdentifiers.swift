
import AppKit

extension NSTouchBarItem.Identifier {
    static let infoLabelItem = NSTouchBarItem.Identifier("com.aliciasykes.InfoLabel")
  static let visitedLabelItem = NSTouchBarItem.Identifier("com.aliciasykes.VisitedLabel")
  static let visitSegmentedItem = NSTouchBarItem.Identifier("com.aliciasykes.VisitedSegementedItem")
  static let visitedItem = NSTouchBarItem.Identifier("com.aliciasykes.VisitedItem")
  static let ratingLabel = NSTouchBarItem.Identifier("com.aliciasykes.RatingLabel")
  static let packageListScrubber = NSTouchBarItem.Identifier("com.aliciasykes.RatingScrubber")
}

extension NSTouchBar.CustomizationIdentifier {
    static let travelBar = NSTouchBar.CustomizationIdentifier("com.aliciasykes.ViewController.TravelBar")
}
