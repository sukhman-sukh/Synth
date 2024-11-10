// part of 'widgets.dart';

// /// Overriding [defaultBuilder] is required. It's passed as the base value of all
// /// other builders.
// ///
// /// Override all other platform builders that should have a unique UI implementation.
// ///
// /// Overriding the [build] method would render this superclass useless, as it's there that
// /// the Platform selection occurs.
// abstract class PlatformAwareBuilder extends  {
//   const PlatformAwareBuilder({super.key});

//   Widget defaultBuilder(BuildContext context);

//   Widget androidBuilder(BuildContext context) => defaultBuilder(context);

//   Widget linuxBuilder(BuildContext context) => defaultBuilder(context);

//   Widget windowsBuilder(BuildContext context) => defaultBuilder(context);

//   Widget iosBuilder(BuildContext context) => defaultBuilder(context);

//   Widget macosBuilder(BuildContext context) => defaultBuilder(context);

//   @override
//   Widget build(BuildContext context) {
//     if (Platform.isAndroid) return androidBuilder(context);
//     if (Platform.isLinux) return linuxBuilder(context);
//     if (Platform.isWindows) return windowsBuilder(context);
//     if (Platform.isIOS) return iosBuilder(context);
//     if (Platform.isMacOS) return macosBuilder(context);

//     return defaultBuilder(context);
//   }
// }
