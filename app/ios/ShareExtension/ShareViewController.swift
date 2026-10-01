import receive_sharing_intent

/// iOS Share Extension. Hands shared screenshots, links and text to the shotr app,
/// which opens straight on the share sheet (/share). See app/docs/ios-share-extension.md.
class ShareViewController: RSIShareViewController {
    /// Open the host app right away so the sheet can sort and save the shot.
    override func shouldAutoRedirect() -> Bool { true }
}
