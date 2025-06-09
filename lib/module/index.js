"use strict";

import { forwardRef, useRef, useImperativeHandle, useState, useMemo } from 'react';
import NativeComponent, { Commands } from './InfiniteScrollviewViewNativeComponent';
import { Platform } from 'react-native';
import { jsx as _jsx } from "react/jsx-runtime";
const InfiniteScrollview = /*#__PURE__*/forwardRef((props, ref) => {
  const nativeRef = useRef(null);
  const [rnLaylout, setRnLayout] = useState({
    x: 0,
    y: 0,
    width: 0,
    height: 0
  });
  const nativeProps = useMemo(() => {
    const spacing = {
      rnWidth: rnLaylout.width,
      rnHeight: rnLaylout.height,
      spacingHor: props.spacingHorizontal ? props.spacingHorizontal : 0,
      spacingVer: props.spacingVertical ? props.spacingVertical : 0
    };
    return Platform.OS === 'android' ? {
      ...props,
      spacing
    } : props;
  }, [rnLaylout, props]);
  useImperativeHandle(ref, () => ({
    scrollDistances(distanceX, distanceY, durationMs) {
      if (nativeRef.current != null) {
        Commands.scrollDistances(nativeRef.current, distanceX, distanceY, durationMs);
      }
    },
    scrollContinuously(distanceX, distanceY) {
      if (nativeRef.current != null) {
        Commands.scrollContinuously(nativeRef.current, distanceX, distanceY);
      }
    },
    stopScrolling(reset) {
      if (nativeRef.current != null) {
        Commands.stopScrolling(nativeRef.current, reset || false);
      }
    },
    reset() {
      if (nativeRef.current != null) {
        Commands.reset(nativeRef.current);
      }
    }
  }));
  return /*#__PURE__*/_jsx(NativeComponent, {
    ...nativeProps,
    disableTouch: nativeProps.disableTouch || false,
    ref: nativeRef,
    onLayout: e => {
      setRnLayout(e.nativeEvent.layout);
      nativeProps.onLayout?.(e);
    }
  });
});
export default InfiniteScrollview;
//# sourceMappingURL=index.js.map