/// Mirrors the Postgres enum `note_visibility`.
///
/// • [private]    — only the author ever sees this note. NEVER shared with AI.
/// • [aiAllowed]  — the author explicitly tagged this note as something the
///                  AI coach may reference. Even then it's only used in chat
///                  context if the user also has the `ai_can_use_notes`
///                  consent toggled on.
enum NoteVisibility {
  private('private'),
  aiAllowed('ai_allowed');

  const NoteVisibility(this.wire);

  /// Value stored in Postgres / sent over the wire.
  final String wire;

  static NoteVisibility fromWire(String? value) {
    switch (value) {
      case 'ai_allowed':
        return NoteVisibility.aiAllowed;
      case 'private':
      default:
        return NoteVisibility.private;
    }
  }
}
