import {
  forwardRef,
  useRef,
  useImperativeHandle,
  useState,
  useMemo,
} from 'react';
import NativeComponent, {
  Commands,
} from './InfiniteScrollviewViewNativeComponent';
import { Platform, type LayoutRectangle, type ViewProps } from 'react-native';

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
  const [rnLaylout, setRnLayout] = useState<LayoutRectangle>({
    x: 0,
    y: 0,
    width: 0,
    height: 0,
  });
  const nativeProps = useMemo(() => {
    const spacing = {
      rnWidth: rnLaylout.width,
      rnHeight: rnLaylout.height,
      spacingHor: props.spacingHorizontal ? props.spacingHorizontal : 0,
      spacingVer: props.spacingVertical ? props.spacingVertical : 0,
    };
    return Platform.OS === 'android' ? { ...props, spacing } : props;
  }, [rnLaylout, props]);

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
      {...nativeProps}
      disableTouch={nativeProps.disableTouch || false}
      ref={nativeRef}
      onLayout={(e) => {
        setRnLayout(e.nativeEvent.layout);
        nativeProps.onLayout?.(e);
      }}
    />
  );
});

export default InfiniteScrollview;
