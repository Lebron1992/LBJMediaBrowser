import UIKit

/// 表示可以计算其内存开销的类型。
/// Represents types whose size in memory can be calculated.
public protocol CacheSizeCalculable {
  var cacheSize: UInt { get }
}
