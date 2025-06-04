import type { HostComponent, ViewProps } from 'react-native';
import type { Float, Int32 } from 'react-native/Libraries/Types/CodegenTypes';
import codegenNativeCommands from 'react-native/Libraries/Utilities/codegenNativeCommands';
import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';

interface AndroidSpacing {
  rnWidth: Float;
  rnHeight: Float;
  spacingHor: Float;
  spacingVer: Float;
}
interface NativeProps extends ViewProps {
  lockDirection?: string;
  disableTouch: boolean;
  spacingHorizontal?: Float;
  spacingVertical?: Float;
  spacing?: AndroidSpacing;
}

export default codegenNativeComponent<NativeProps>('InfiniteScrollviewView');

type ComponentType = HostComponent<NativeProps>;

interface NativeCommands {
  scrollDistances(
    viewRef: React.ElementRef<ComponentType>,
    distanceX: Float,
    distanceY: Float,
    durationMs: Int32
  ): void;
  scrollContinuously(
    viewRef: React.ElementRef<ComponentType>,
    distanceX: Float,
    distanceY: Float
  ): void;
  stopScrolling(viewRef: React.ElementRef<ComponentType>, reset: boolean): void;
  reset(viewRef: React.ElementRef<ComponentType>): void;
}

export const Commands = codegenNativeCommands<NativeCommands>({
  supportedCommands: [
    'scrollDistances',
    'scrollContinuously',
    'stopScrolling',
    'reset',
  ],
});
