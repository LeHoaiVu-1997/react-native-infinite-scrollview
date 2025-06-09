import type { HostComponent, ViewProps } from 'react-native';
import type { Float, Int32 } from 'react-native/Libraries/Types/CodegenTypes';
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
declare const _default: import("react-native/Libraries/Utilities/codegenNativeComponent").NativeComponentType<NativeProps>;
export default _default;
type ComponentType = HostComponent<NativeProps>;
interface NativeCommands {
    scrollDistances(viewRef: React.ElementRef<ComponentType>, distanceX: Float, distanceY: Float, durationMs: Int32): void;
    scrollContinuously(viewRef: React.ElementRef<ComponentType>, distanceX: Float, distanceY: Float): void;
    stopScrolling(viewRef: React.ElementRef<ComponentType>, reset: boolean): void;
    reset(viewRef: React.ElementRef<ComponentType>): void;
}
export declare const Commands: NativeCommands;
//# sourceMappingURL=InfiniteScrollviewViewNativeComponent.d.ts.map