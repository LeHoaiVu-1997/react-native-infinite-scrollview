import { useRef } from 'react';
import { View, StyleSheet, TouchableOpacity, Text } from 'react-native';
import InfiniteScrollviewView, {
  type InfiniteScrollviewMethods,
} from 'react-native-infinite-scrollview';

export default function App() {
  const ref = useRef<InfiniteScrollviewMethods>(null);

  return (
    <View style={styles.container}>
      <InfiniteScrollviewView ref={ref} color="#ff0000" style={styles.box} />
      <TouchableOpacity
        style={styles.btn}
        onPress={() => ref.current?.doSomething()}
      >
        <Text style={styles.btnText}>Do smt</Text>
      </TouchableOpacity>
      <TouchableOpacity
        style={styles.btn}
        onPress={() => ref.current?.setValue('123')}
      >
        <Text style={styles.btnText}>Set value</Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'space-evenly',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
  btn: {
    backgroundColor: 'orange',
    padding: 30,
  },
  btnText: {
    color: '#000000',
    fontWeight: 'bold',
  },
});
