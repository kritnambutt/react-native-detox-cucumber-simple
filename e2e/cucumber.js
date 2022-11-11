const common = `features/**/*.feature -f node_modules/cucumber-pretty --require-module @babel/register --require-module @babel/polyfill -f @cucumber/pretty-formatter -r step_definitions -r support`;

process.on("uncaughtException", function (err) {
  console.error("An uncaught error occurred!");
  console.error(err.stack);
});

process.on("unhandledRejection", function (err, promise) {
  console.error("======================================");
  console.error("An unhandled rejection error occurred!");
  console.error(err);
  console.error(err.stack);
  console.error(promise);
  console.error("======================================");
});

const ANDROID = {
  report: "-f json:report-android/cucumber_report.json",
  tags: "'(@android)'",
};

const IOS_IPHONE = {
  report: "-f json:report-iphone/cucumber_report.json",
  tags: "'(@iphone)'",
};

const IOS_IPAD = {
  report: "-f json:report-ipad/cucumber_report.json",
  tags: "'(@ipad)'",
};

module.exports = {
  default: "",
  android: `DETOX_CONFIGURATION=android ${common} ${ANDROID.report} --tags ${ANDROID.tags}`,
  iosIphone: `DETOX_CONFIGURATION=iphone ${common} ${IOS_IPHONE.report} --tags ${IOS_IPHONE.tags}`,
  iosIpad: `DETOX_CONFIGURATION=ipad ${common} ${IOS_IPAD.report} --tags ${IOS_IPAD.tags}`,
  remote: "--fail-fast",
  parallel: '--tags "(not @noparallel and not @webview)" --parallel 3',
  "non-parallel": "--tags @noparallel",
};
