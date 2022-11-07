import {Then, Given} from '@cucumber/cucumber';
import {expect, element, by, waitFor} from 'detox';

Given('I should see the {string} element', async elementId => {
  await expect(element(by.id(elementId))).toBeVisible();
});
Then('I should see the {string} text', async text => {
  await expect(element(by.text(text))).toBeVisible();
});
