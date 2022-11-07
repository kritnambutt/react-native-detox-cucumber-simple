/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * Generated with the TypeScript template
 * https://github.com/react-native-community/react-native-template-typescript
 *
 * @format
 */

import React from 'react';
import {Button, StyleSheet, Text, View} from 'react-native';

const App = () => {
  return (
    <View>
      <Text testID="welcome">Open up App.js to start working on your app!</Text>
      <Button title="Hello!!!" testID="hello_button" />

      <View testID="world_screen">
        <View>
          <Button title="World!!!" testID="world_button" />
        </View>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  sectionContainer: {
    marginTop: 32,
    paddingHorizontal: 24,
  },
  sectionTitle: {
    fontSize: 24,
    fontWeight: '600',
  },
  sectionDescription: {
    marginTop: 8,
    fontSize: 18,
    fontWeight: '400',
  },
  highlight: {
    fontWeight: '700',
  },
});

export default App;
