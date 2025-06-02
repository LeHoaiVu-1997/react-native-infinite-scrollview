import { forwardRef, useRef, useImperativeHandle } from 'react';
import NativeComponent, {
  Commands,
} from './InfiniteScrollviewViewNativeComponent';
import type { ViewProps } from 'react-native';

export interface InfiniteScrollviewMethods {
  scrollDistances: (
    distanceX: number,
    distanceY: number,
    durationMs: number
  ) => void;
  scrollContinuously: (distanceX: number, distanceY: number) => void;
  stopScrolling: (reset?: boolean) => void;
  reset: () => void;
}

export interface InfiniteScrollviewProps extends ViewProps {
  lockDirection?: 'hor' | 'ver';
  disableTouch?: boolean;
  spacingHorizontal?: number;
  spacingVertical?: number;
}

const InfiniteScrollview = forwardRef<
  InfiniteScrollviewMethods,
  InfiniteScrollviewProps
>((props, ref) => {
  const nativeRef = useRef(null);

  useImperativeHandle(ref, () => ({
    scrollDistances(distanceX: number, distanceY: number, durationMs: number) {
      if (nativeRef.current != null) {
        Commands.scrollDistances(
          nativeRef.current,
          distanceX,
          distanceY,
          durationMs
        );
      }
    },
    scrollContinuously(distanceX: number, distanceY: number) {
      if (nativeRef.current != null) {
        Commands.scrollContinuously(nativeRef.current, distanceX, distanceY);
      }
    },
    stopScrolling(reset?: boolean) {
      if (nativeRef.current != null) {
        Commands.stopScrolling(nativeRef.current, reset || false);
      }
    },
    reset() {
      if (nativeRef.current != null) {
        Commands.reset(nativeRef.current);
      }
    },
  }));

  return (
    <NativeComponent
      {...props}
      disableTouch={props.disableTouch || false}
      ref={nativeRef}
    />
  );
});

export default InfiniteScrollview;
