import type { HostComponent, ViewProps } from 'react-native';
import codegenNativeCommands from 'react-native/Libraries/Utilities/codegenNativeCommands';
import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';
export interface NativeProps extends ViewProps {
  color?: string;
  test?: boolean;
}

export default codegenNativeComponent<NativeProps>('InfiniteScrollviewView');

type ComponentType = HostComponent<NativeProps>;

interface NativeCommands {
  setValue(viewRef: React.ElementRef<ComponentType>, color: string): void;

  doSomething(viewRef: React.ElementRef<ComponentType>): void;
}

export const Commands = codegenNativeCommands<NativeCommands>({
  supportedCommands: ['setValue', 'doSomething'],
});
