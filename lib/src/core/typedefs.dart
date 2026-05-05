
/// Callback type for log writer.
typedef LogWriterCallback = void Function(String text, {bool isError});

/// Default log writer - does nothing in lite version.
void defaultLogWriter(String text, {bool isError = false}) {
  // Silent by default in getx_lite
}
