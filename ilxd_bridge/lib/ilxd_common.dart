import 'dart:io';

enum Library {
  ZK,
  CRYPTO
}

class IlxdCommon {
  static String getLibPath(Library lib) {
    String cwd = Directory.current.path;
    String osName = '';
    String arch = '';
    String libExt = 'so';

    // Detect OS
    if (Platform.isMacOS) {
      osName = 'macos';
    } else if (Platform.isIOS) {
      osName = 'ios';
    } else if (Platform.isAndroid) {
      osName = 'android';
    } else if (Platform.isWindows) {
      osName = 'win';
    } else if (Platform.isLinux) {
      osName = 'linux';
    } else {
      throw UnsupportedError('IlxdCommon::getLibPath(): Unsupported OS: ${Platform.operatingSystem}');
    }

    // Print Platform version
    print('Platform.version: ${Platform.version}');

    // Detect Architecture
    if (Platform.version.contains('arm64') || Platform.version.contains('aarch64')) {
      arch = 'arm64';
    } else if (Platform.version.contains('x86_64') || Platform.version.contains('x64')) {
      arch = 'x86_64';
    } else if (Platform.version.contains('x86')) {
      arch = 'x86';
    } else {
      // For debugging, print that architecture was not found
      print('Unable to detect architecture from Platform.version');
    }

    // Print detected values
    print('Detected OS: $osName');
    print('Detected Arch: $arch');

    // Set library extension
    if (Platform.isMacOS || Platform.isIOS) {
      libExt = 'dylib';
    } else if (Platform.isWindows) {
      libExt = 'dll';
    }

    if (osName.isEmpty || arch.isEmpty || libExt.isEmpty) {
      print('One of the required parameters is empty: osName=$osName, arch=$arch, libExt=$libExt');
      return '';
    }

    String libInfix = 'zk';
    if (lib == Library.CRYPTO) {
      libInfix = 'crypto';
    }

    String result = '${cwd}/${osName}/libilxd_${libInfix}_bridge_${osName}_${arch}.${libExt}';
    print("IlxdCommon::getLibPath() -> $result");
    return result;
  }
}