// SPDX-License-Identifier: AGPL-3.0-or-later

import Foundation

/// The App Group storage the app and the widget extension share (docs/widgets.md, "The contract").
///
/// Compiled into the app and the extension on iOS and macOS. Every value is a JSON string.
enum WidgetStore {
  static let indexKey = "tix.widget.index"
  static let queueKey = "tix.widget.queue"
  static let wantedKey = "tix.widget.wanted"
  static let activeContext = "active"
  static let queuedNotification = "red.tix.tixMobile.widgets.queued"

  /// The App Group identifier, from `TixAppGroup` in the running bundle's Info.plist.
  static var appGroup: String? {
    guard let group = Bundle.main.object(forInfoDictionaryKey: "TixAppGroup") as? String,
      !group.isEmpty, !group.hasPrefix("$(")
    else { return nil }
    return group
  }

  static var defaults: UserDefaults? {
    appGroup.flatMap { UserDefaults(suiteName: $0) }
  }

  static func string(_ key: String) -> String? {
    defaults?.string(forKey: key)
  }

  static func set(_ value: String?, for key: String) {
    guard let defaults else { return }
    if let value {
      defaults.set(value, forKey: key)
    } else {
      defaults.removeObject(forKey: key)
    }
  }

  static func nowMillis() -> Int64 {
    Int64((Date().timeIntervalSince1970 * 1000).rounded())
  }

  /// `index.active`, or nil before the app has written an index.
  static func activeContextID() -> String? {
    guard let index = json(string(indexKey)) as? [String: Any] else { return nil }
    return index["active"] as? String
  }

  /// The context a widget configured with [ctx] reads: `active` resolves to `index.active`.
  static func resolve(_ ctx: String?) -> String? {
    guard let ctx, !ctx.isEmpty, ctx != activeContext else { return activeContextID() }
    return ctx
  }

  /// Appends a `complete` action to the queue, once per context and task.
  @discardableResult
  static func enqueueComplete(ctx: String, ref: String) -> Bool {
    guard let defaults, let resolved = resolve(ctx) else { return false }
    var queue = (json(defaults.string(forKey: queueKey)) as? [[String: Any]]) ?? []
    let queued = queue.contains {
      $0["op"] as? String == "complete" && $0["ctx"] as? String == resolved
        && $0["ref"] as? String == ref
    }
    if queued { return true }
    let at = nowMillis()
    queue.append([
      "id": "w-\(at)-\(Int.random(in: 0..<1_000_000))",
      "op": "complete",
      "ctx": resolved,
      "ref": ref,
      "at": at,
    ])
    guard let encoded = encode(queue) else { return false }
    defaults.set(encoded, forKey: queueKey)
    return true
  }

  /// The refs waiting in the queue for [ctx], which a widget hides at once.
  static func queuedRefs(ctx: String) -> Set<String> {
    guard let queue = json(string(queueKey)) as? [[String: Any]] else { return [] }
    return Set(
      queue.compactMap { entry in
        entry["ctx"] as? String == ctx ? entry["ref"] as? String : nil
      })
  }

  /// Renews the request of one configured widget in `tix.widget.wanted`.
  static func recordWanted(kind: String, ctx: String, project: String?) {
    guard let defaults else { return }
    var wanted = (json(defaults.string(forKey: wantedKey)) as? [String: Any]) ?? [:]
    let entry: [String: Any] = [
      "ctx": ctx,
      "project": project.map { $0 as Any } ?? NSNull(),
      "at": nowMillis(),
    ]
    wanted["\(kind):\(ctx):\(project ?? "")"] = entry
    guard let encoded = encode(wanted) else { return }
    defaults.set(encoded, forKey: wantedKey)
  }

  /// Tells a running app that the queue has work (macOS, where no headless engine runs).
  static func postQueued() {
    CFNotificationCenterPostNotification(
      CFNotificationCenterGetDarwinNotifyCenter(),
      CFNotificationName(queuedNotification as CFString),
      nil,
      nil,
      true)
  }

  private static func json(_ raw: String?) -> Any? {
    guard let data = raw?.data(using: .utf8) else { return nil }
    return try? JSONSerialization.jsonObject(with: data)
  }

  private static func encode(_ value: Any) -> String? {
    guard JSONSerialization.isValidJSONObject(value),
      let data = try? JSONSerialization.data(withJSONObject: value)
    else { return nil }
    return String(data: data, encoding: .utf8)
  }
}
