import { type ViewProps } from 'react-native';
export interface InfiniteScrollviewMethods {
    scrollDistances: (distanceX: number, distanceY: number, durationMs: number) => void;
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
declare const InfiniteScrollview: import("react").ForwardRefExoticComponent<InfiniteScrollviewProps & import("react").RefAttributes<InfiniteScrollviewMethods>>;
export default InfiniteScrollview;
//# sourceMappingURL=index.d.ts.map