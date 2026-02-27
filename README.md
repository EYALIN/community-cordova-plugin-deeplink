# community-cordova-plugin-deeplink

[![npm version](https://badge.fury.io/js/community-cordova-plugin-deeplink.svg)](https://badge.fury.io/js/community-cordova-plugin-deeplink)

A Cordova plugin for handling deep links on Android (App Links / custom URI schemes) and iOS (Universal Links / custom URL schemes). The plugin captures incoming URLs and forwards them to JavaScript.

I dedicate a considerable amount of my free time to developing and maintaining many cordova plugins for the community ([See the list with all my maintained plugins][community_plugins]).
To help ensure this plugin is kept updated,
new features are added and bugfixes are implemented quickly,
please donate a couple of dollars (or a little more if you can stretch) as this will help me to afford to dedicate time to its maintenance.
Please consider donating if you're using this plugin in an app that makes you money,
or if you're asking for new features or priority bug fixes. Thank you!

[![](https://img.shields.io/static/v1?label=Sponsor%20Me&style=for-the-badge&message=%E2%9D%A4&logo=GitHub&color=%23fe8e86)](https://github.com/sponsors/eyalin)

## Installation

```bash
cordova plugin add community-cordova-plugin-deeplink
```

## Usage

```javascript
// Get the URL that launched the app (cold start)
DeeplinkPlugin.getLastDeepLink().then(function(result) {
    if (result.url) {
        console.log('App launched with deep link:', result.url);
        // Navigate to the appropriate page
    }
});

// Listen for deep links while the app is running
DeeplinkPlugin.onDeepLink(function(result) {
    console.log('Deep link received:', result.url);
    // Navigate to the appropriate page
});
```

## API Reference

### `getLastDeepLink()`

Returns the deep link URL that launched the app (cold start).

**Returns:** `Promise<{ url: string | null }>`

| Field | Type            | Description                                |
|-------|-----------------|--------------------------------------------|
| url   | string \| null  | The deep link URL, or null if none          |

### `onDeepLink(callback)`

Registers a listener for deep link events received while the app is running.

**Parameters:**
- `callback` - Function that receives `{ url: string }` when a deep link arrives

## Platform Configuration

The plugin captures deep link URLs but does **not** configure intent filters or Associated Domains. You must configure those in your app.

### Android - App Links

Add intent filters to your `config.xml`:

```xml
<platform name="android">
    <config-file target="AndroidManifest.xml" parent="/manifest/application/activity[@android:name='MainActivity']">
        <intent-filter android:autoVerify="true">
            <action android:name="android.intent.action.VIEW" />
            <category android:name="android.intent.category.DEFAULT" />
            <category android:name="android.intent.category.BROWSABLE" />
            <data android:scheme="https" android:host="yourdomain.com" android:pathPrefix="/app" />
        </intent-filter>
    </config-file>
</platform>
```

Host a `/.well-known/assetlinks.json` file on your domain.

### iOS - Universal Links

Add Associated Domains entitlement in Xcode and host an `apple-app-site-association` file on your domain.

## Platform Support

| Feature          | Android | iOS |
|------------------|---------|-----|
| getLastDeepLink  | Yes     | Yes |
| onDeepLink       | Yes     | Yes |
| App Links        | Yes     | -   |
| Universal Links  | -       | Yes |
| Custom URI       | Yes     | Yes |

## Contributing

Feel free to open issues or submit pull requests on [GitHub](https://github.com/EYALIN/community-cordova-plugin-deeplink).

## License

MIT - See [LICENSE](LICENSE)

[community_plugins]: https://github.com/EYALIN?tab=repositories&q=community&type=&language=&sort=
