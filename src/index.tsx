import { forwardRef, useRef, useImperativeHandle } from 'react';
import NativeComponent, {
  Commands,
  type NativeProps,
} from './InfiniteScrollviewViewNativeComponent';

export interface InfiniteScrollviewMethods {
  setValue(color: string): void;
  doSomething(): void;
}

const InfiniteScrollviewView = forwardRef<
  InfiniteScrollviewMethods,
  NativeProps
>((props, ref) => {
  const nativeRef = useRef(null);

  useImperativeHandle(ref, () => ({
    setValue(color: string) {
      console.log('nativeRef.current null: ', nativeRef.current == null);
      if (nativeRef.current != null) {
        Commands.setValue(nativeRef.current, color);
      }
    },
    doSomething() {
      console.log('nativeRef.current null: ', nativeRef.current == null);
      if (nativeRef.current != null) {
        Commands.doSomething(nativeRef.current);
      }
    },
  }));

  return <NativeComponent {...props} ref={nativeRef} />;
});

export * from './InfiniteScrollviewViewNativeComponent';
export default InfiniteScrollviewView;
