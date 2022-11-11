import {Given} from '@cucumber/cucumber';
import {expect, element, by} from 'detox';
import {fillLoginForm} from '../../support';

Given('I should see the {string} element', async elementId => {
  await expect(element(by.id(elementId))).toBeVisible();
});

Given('I am login as {string}', async userType => {});
