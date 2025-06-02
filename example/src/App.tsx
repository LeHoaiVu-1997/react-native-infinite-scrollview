import { useRef } from 'react';
import { View, StyleSheet, TouchableOpacity, Text, Image } from 'react-native';
import InfiniteScrollview, {
  type InfiniteScrollviewMethods,
} from 'react-native-infinite-scrollview';

export default function App() {
  const ref = useRef<InfiniteScrollviewMethods>(null);

  return (
    <View style={styles.container}>
      <InfiniteScrollview
        ref={ref}
        lockDirection={undefined}
        style={styles.boxCylinder}
        // spacingHorizontal={50}
        // spacingVertical={50}
      >
        <Image
          source={require('./sample-pic.jpg')}
          resizeMode="cover"
          style={styles.img}
        />
      </InfiniteScrollview>
      <View style={styles.rowFull}>
        <TouchableOpacity
          style={styles.btn}
          onPress={() => {
            ref.current?.scrollDistances(1.5, 1.5, 3000);
          }}
        >
          <Text>Scroll a distance to bottom right</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={styles.btn}
          onPress={() => {
            ref.current?.scrollDistances(-1.5, -1.5, 3000);
          }}
        >
          <Text>Scroll a distance to top left</Text>
        </TouchableOpacity>
      </View>
      <View style={styles.rowFull}>
        <TouchableOpacity
          style={styles.btn}
          onPress={() => {
            ref.current?.scrollContinuously(0.5, 0.5);
          }}
        >
          <Text>Scroll continuously to bottom right</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={styles.btn}
          onPress={() => {
            ref.current?.scrollContinuously(-0.5, -0.5);
          }}
        >
          <Text>Scroll continuously to top left</Text>
        </TouchableOpacity>
      </View>
      <View style={styles.rowFull}>
        <TouchableOpacity
          style={styles.btn}
          onPress={() => {
            ref.current?.stopScrolling();
          }}
        >
          <Text>Stop scrolling</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={styles.btn}
          onPress={() => {
            ref.current?.reset();
          }}
        >
          <Text>Reset position</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'space-evenly',
    backgroundColor: 'grey',
  },
  boxCylinder: {
    width: 260,
    height: 260,
    backgroundColor: 'red',
    justifyContent: 'center',
    alignItems: 'center',
  },
  img: {
    height: '80%',
    width: '80%',
    backgroundColor: 'green',
  },
  btn: {
    paddingHorizontal: 25,
    paddingVertical: 15,
    borderWidth: 2,
    borderColor: 'orange',
    borderRadius: 10,
  },
  rowFull: {
    width: '100%',
    justifyContent: 'space-evenly',
    flexDirection: 'row',
  },
});
