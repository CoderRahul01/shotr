# iOS Share Extension setup

The Android share receiver works out of the box (`ShareActivity`). On iOS, Apple requires a
Share Extension target, which has to be added once in Xcode. The source files are already in
`app/ios/ShareExtension/`.

You need a Mac with Xcode 26+ and an Apple Developer account.

1. `cd app && flutter build ios --config-only`, then open `ios/Runner.xcworkspace` in Xcode.
2. **File > New > Target > Share Extension.** Name it `ShareExtension`, language Swift.
   When Xcode asks to activate the scheme, choose **Cancel** (keep the Runner scheme).
3. Delete the files Xcode generated in the new group, then drag in the ones from
   `ios/ShareExtension/` (`ShareViewController.swift`, `Info.plist`, `ShareExtension.entitlements`).
   Keep `MainInterface.storyboard` from Xcode.
4. In the **ShareExtension** target:
   - Bundle identifier: `app.shotr.ShareExtension`
   - Minimum deployment: iOS 15.5
   - Signing & Capabilities: add **App Groups** with `group.app.shotr`
   - Build Settings: `CODE_SIGN_ENTITLEMENTS = ShareExtension/ShareExtension.entitlements`
   - Build Settings: add user-defined `CUSTOM_GROUP_ID = group.app.shotr`
5. In the **Runner** target:
   - Signing & Capabilities: **App Groups** `group.app.shotr`, **Sign in with Apple**
   - Build Settings: add user-defined `CUSTOM_GROUP_ID = group.app.shotr`
   - Build Phases: move **Embed Foundation Extensions** above **Run Script** (avoids a build cycle)
6. Add the extension to the Podfile, then run `pod install` in `app/ios`:

   ```ruby
   target 'ShareExtension' do
     use_frameworks!
     pod 'receive_sharing_intent', :path => '.symlinks/plugins/receive_sharing_intent/ios'
   end
   ```

7. Run on a device, take a screenshot, tap Share, pick **shotr**. The app opens on the share sheet.

How it works: the extension saves the shared items into the App Group and opens
`ShareMedia-app.shotr://`. The app reads them with `receive_sharing_intent` and shows the
`/share` route (`lib/app/share_intake.dart`).
