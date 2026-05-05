

/// GetX by default disposes unused controllers from memory,
/// Through different behaviors.
///
/// [SmartManagement.full] is the default one. Dispose classes that are
/// not being used and were not set to be permanent.
///
/// [SmartManagement.onlyBuilder] only controllers started in init: or loaded
/// into a Binding with Get.lazyPut() will be disposed.
///
/// [SmartManagement.keepFactory] Just like SmartManagement.full, it will remove
/// its dependencies when it's not being used anymore. However, it will keep
/// their factory, which means it will recreate the dependency if you need
/// that instance again.
enum SmartManagement { full, onlyBuilder, keepFactory }
