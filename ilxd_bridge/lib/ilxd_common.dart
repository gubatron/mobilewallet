import 'dart:io';

enum Library {
  ZK,
  CRYPTO
}

class IlxdCommon {
  static String getLibPath(Library lib) {
    String cwd = Directory.current.path.toString();
    String osName = '';
    String arch = '';
    String libExt = 'so';

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

    if (Platform.version.contains('arm64') || Platform.version.contains('aarch64')) {
      arch = 'arm64';
    } else if (Platform.version.contains('x86_64')) {
      arch = 'x86_64';
    } else if (Platform.version.contains('x86')) {
      arch = 'x86';
    }

    if (Platform.isMacOS || Platform.isIOS) {
      libExt = 'dylib';
    } else if (Platform.isWindows) {
      libExt = 'dll';
    }

    if (osName.isEmpty || arch.isEmpty || libExt.isEmpty) {
      return '';
    }

    String libInfix = 'zk';
    if (lib == Library.CRYPTO) {
      libInfix = 'crypto';
    }

    String result = '${cwd}/${osName}/libilxd_${libInfix}_bridge_${osName}_${arch}.${libExt}';
    return result;
  }
}