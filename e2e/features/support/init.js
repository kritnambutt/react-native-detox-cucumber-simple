const detox = require('detox');
const {Before, BeforeAll, AfterAll, After} = require('@cucumber/cucumber');
const adapter = require('./adapter');

BeforeAll(async () => {
  console.log('before all detox init');
  await detox.init();
});

Before(async context => {
  await detox.device.reloadReactNative();
  await adapter.beforeEach(context);
});

After(async context => {
  await adapter.afterEach(context);
});

AfterAll(async () => {
  console.log('after all detox clean up');
  await detox.cleanup();
});
