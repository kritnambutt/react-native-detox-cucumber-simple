const report = require('multiple-cucumber-html-reporter');
const args = process.argv.slice(2);

if (!args || args.length <= 0) {
  throw new Error(
    'Missing scripts arguments. Example usage: node generate-report.js android sit',
  );
}

if (!args[0] || !['android', 'ipad', 'iphone'].includes(args[0])) {
  throw new Error(
    'Invalid required platform argument. Possible value { android | ipad | iphone }',
  );
}
const PLATFORM = args[0];
const DEVICE = (() => {
  switch (PLATFORM) {
    case 'android':
      return {name: 'Android Emulator', version: '10.0'};
    case 'iphone':
      return {name: 'iPhone 13 emulator', version: '15.5'};
    case 'ipad':
      return {
        name: 'iPad mini (5th generation) emulator',
        version: '15.5',
      };
    default:
      return 'Emulator';
  }
})();

const ENVIRONMENT = args[1] || 'local';
if (!args[1]) {
  console.log("Missing env argument, default to 'local'");
}

const APP_VERSION = args[2] || 'latest';
if (!args[2]) {
  console.log("Missing app_version argument, default to 'latest'");
}

report.generate({
  jsonDir: `report-${PLATFORM}`,
  reportPath: `report-${PLATFORM}`,
  displayDuration: true,
  metadata: {
    device: DEVICE.name,
    platform: {
      name: PLATFORM !== 'android' ? 'ios' : 'android',
      version: DEVICE.version,
    },
  },
  customData: {
    title: 'Run info',
    data: [
      {label: 'Timestamp', value: new Date().toLocaleString()},
      {label: 'Project', value: 'aia-aio'},
      {label: 'Package', value: 'th.aia.aio'},
      {label: 'Version', value: APP_VERSION},
      {
        label: 'Description',
        value: 'E2E automated test, run with Appium.',
      },
      {label: 'Environment', value: ENVIRONMENT},
    ],
  },
});
