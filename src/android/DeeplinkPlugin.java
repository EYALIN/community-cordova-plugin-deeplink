package deeplinkplugin;

import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.net.Uri;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class DeeplinkPlugin extends CordovaPlugin {
    private static final String TAG = "DeeplinkPlugin";

    private String lastDeepLinkUrl = null;
    private CallbackContext deepLinkCallbackContext = null;

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        handleIntent(cordova.getActivity().getIntent());
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if ("getLastDeepLink".equals(action)) {
            return getLastDeepLink(callbackContext);
        } else if ("onDeepLink".equals(action)) {
            return onDeepLink(callbackContext);
        } else if ("launchApp".equals(action)) {
            return launchApp(args, callbackContext);
        }
        return false;
    }

    private boolean getLastDeepLink(CallbackContext callbackContext) {
        try {
            JSONObject result = new JSONObject();
            result.put("url", lastDeepLinkUrl != null ? lastDeepLinkUrl : JSONObject.NULL);
            callbackContext.success(result);
            return true;
        } catch (JSONException e) {
            callbackContext.error(e.getMessage());
            return false;
        }
    }

    private boolean onDeepLink(CallbackContext callbackContext) {
        this.deepLinkCallbackContext = callbackContext;

        // If we already have a pending deep link, send it immediately
        if (lastDeepLinkUrl != null) {
            sendDeepLinkEvent(lastDeepLinkUrl);
        }

        // Keep the callback alive for future events
        PluginResult result = new PluginResult(PluginResult.Status.NO_RESULT);
        result.setKeepCallback(true);
        callbackContext.sendPluginResult(result);
        return true;
    }

    private boolean launchApp(JSONArray args, CallbackContext callbackContext) {
        try {
            String url = args.getString(0);
            Uri uri = Uri.parse(url);
            Intent intent = new Intent(Intent.ACTION_VIEW, uri);
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            cordova.getActivity().startActivity(intent);
            callbackContext.success();
            return true;
        } catch (ActivityNotFoundException e) {
            callbackContext.error("APP_NOT_FOUND");
            return true;
        } catch (JSONException e) {
            callbackContext.error(e.getMessage());
            return false;
        }
    }

    @Override
    public void onNewIntent(Intent intent) {
        handleIntent(intent);
    }

    private void handleIntent(Intent intent) {
        if (intent == null) return;

        String action = intent.getAction();
        Uri data = intent.getData();

        if (Intent.ACTION_VIEW.equals(action) && data != null) {
            lastDeepLinkUrl = data.toString();
            sendDeepLinkEvent(lastDeepLinkUrl);
        }
    }

    private void sendDeepLinkEvent(String url) {
        if (deepLinkCallbackContext == null) return;

        try {
            JSONObject result = new JSONObject();
            result.put("url", url);

            PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, result);
            pluginResult.setKeepCallback(true);
            deepLinkCallbackContext.sendPluginResult(pluginResult);
        } catch (JSONException e) {
            // Ignore JSON errors in event delivery
        }
    }
}
