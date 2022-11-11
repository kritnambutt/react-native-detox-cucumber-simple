import { Then } from "@cucumber/cucumber";
import { expect, element, by } from "detox";

Then("I should see the {string} text", async (text) => {
  await expect(element(by.text(text))).toBeVisible();
});
