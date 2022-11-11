const detox = require("detox");
const {
  Before,
  BeforeAll,
  AfterAll,
  After,
  Status,
} = require("@cucumber/cucumber");

BeforeAll(async () => {
  console.log("before all detox init");
  await detox.init();
});

Before(
  "not @skip and (not @draft-ios or not @draft-android or @focus)",
  async () => {
    await device.launchApp({ newInstance: true });
  }
);

// @tag in case skip or draft
Before(
  "@skip or @draft-ios or @draft-android and not @focus",
  function (scenario) {
    const scenarioTags = scenario.pickle.tags;

    let shouldSkip = true;
    let findTag = scenarioTags.find((o) =>
      ["@skip", "@draft-ios"].includes(o.name)
    );
    shouldSkip = findTag != null;

    console.log("enter Before hook draft or skip", shouldSkip);
    return shouldSkip ? "skipped" : "";
  }
);

After(async (scenario) => {
  if ([Status.SKIPPED, Status.UNDEFINED].includes(scenario.result.status)) {
    console.log("After: do nothing because it's skipped");
  } else {
    try {
      if (scenario.result.status === Status.FAILED) {
        // const image = await device.takeScreenshot("opened general section");
        // this.attach(image, "image/png");
      }
    } finally {
      console.log("After: finished in case failed");
    }
  }
});

AfterAll(async () => {
  console.log("after all detox clean up");
  await detox.cleanup();
});
