# react-native-infinite-scrollview

Infinite scrollview for React Native

This component takes another one as its children, also allows translating the child in both horizontal and vertical directions. When a part of the child go out of the component border, a mirrored part will be rendered on the opposite side, creating an infinite scrolling effect.

<img src="demo.gif" width="240" />


## Installation

```sh
yarn add @levu97/react-native-infinite-scrollview
```

Fabric and Paper supported. Make sure you run codegen commands:
- Android: 
```sh 
cd android && ./gradlew generateCodegenArtifactsFromSchema
```
- iOS: 
```sh
cd ios && pod install
```

**Note**: 
- yarn 4.x and node 22 recommended.
- Support react native 0.72.* and above.


## Usage

```js
import InfiniteScrollview, {
  type InfiniteScrollviewMethods,
} from '@vule97/react-native-infinite-scrollview';

const ref = useRef<InfiniteScrollviewMethods>(null);

<InfiniteScrollview 
    ref={ref}
    style={{
          width: 260,
          height: 260,
          backgroundColor: 'skyblue',
          alignItems: 'center',
          justifyContent: 'center',
        }}>
    <Text style={{color: 'red', fontSize: 20, backgroundColor: 'pink'}}>
        0123456789ABCDEF
    </Text>
</InfiniteScrollview>
```


## Properties

| Property          | Type                | Default value    | Note                   |
|-------------------|---------------------|------------------|------------------------|
| lockDirection     | String ```ver```, ```hor```or undefined  | undefined        | Lock the translation direction. Tranlate horizontally with ```hor```, vertically when ```ver```. |
| disableTouch      | boolean, undefined  | undefined        | Disable touch to translate, when ```true``` |
| spacingHorizontal | number, undefine    | undefined        | Minus number not allowed. The additional distance that the child component have to move on the **horizontal** axis after go out of **InfiniteScrollview** border before appear on the other side. |
| spacingVertical   | number, undefine    | undefined        | Minus number not allowed. The additional distance that the child component have to move on the **vertical** axis after go out of **InfiniteScrollview** border before appear on the other side. |

Beside the above porperties, ```InfiniteScrollview``` also contains those belong to react-native ```ViewProps```.


## Methods

Property ```disableTouch``` does not apply for translating the child component via methods.

### `scrollDistances`

```typescript
scrollDistances(distanceX: number, distanceY: number, durationMs: number): void
```

- **Feature**: Translate the child component a distance in a duration of time.
- **Arguments**:
  - `distanceX` (number): Horizontal distance, based on **width** of **InfiniteScrollview**.
  - `distanceY` (number): Vertical distance, based on **height** of **InfiniteScrollview**.
  - `durationMs` (number): Translating duration in miliseconds.
- **Exmaple**: translate the child component to the bottom right a distance equals to 50% width and 50% height of ```InfiniteScrollview```, in 5000 miliseconds.
  ```typescript
  refCylinder.current?.scrollDistances(0.5, 0.5, 5000);
  ```

### `scrollContinuously`

```typescript
scrollContinuously(distanceX: number, distanceY: number): void
```

- **Feature**: Translate the child component a distance for every second.
- **Arguments**:
  - `distanceX` (number): Horizontal distance, based on **width** of **InfiniteScrollview**.
  - `distanceY` (number): Vertical distance, based on **height** of **InfiniteScrollview**.
- **Exmaple**: translate the child component to the top left right a distance equals to 50% width and 50% height of ```InfiniteScrollview```, every second.
  ```typescript
  refCylinder.current?.scrollContinuously(-0.5, -0.5);
  ```

### `stopScrolling`

```typescript
stopScrolling(reset?: boolean): void
```

- **Feature**: Stop translation.
- **Arguments**:
  - `reset` (number | undefined): Move the child component to its original position when ```true```.
- **Exmaple**:
  ```typescript
  refCylinder.current?.stopScrolling(true);
  ```

### `reset`

```typescript
reset(): void
```

- **Arguments**: Move the child component to its original position.
- **Exmaple**:
  ```typescript
  refCylinder.current?.reset();
  ```


## Change log

See [change log](CHANGELOG.md).


## Cons
 - Only accept a single component as children.
 - This library might not work correctly with the child component that has its own translation.
 - On iOS, this library might not work if the child component is a **Video** (react-native-video/AVFoundation).
 - Interactions (such as button press, long press, ...) will not be available for the mirrored parts which are just a copy the children render.


## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.


## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
