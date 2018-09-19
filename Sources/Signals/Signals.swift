#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
import Darwin
#elseif os(Linux)
import Glibc
#endif

import Foundation

public class Signals {

  public enum Signal {
    case hup
    case int
    case quit
    case abrt
    case kill
    case alrm
    case term
    case pipe

    public var valueOf: Int32 {
      switch self {
        case .hup:
          return Int32(SIGHUP)
        case .int:
          return Int32(SIGINT)
        case .quit:
          return Int32(SIGQUIT)
        case .abrt:
          return Int32(SIGABRT)
        case .kill:
          return Int32(SIGKILL)
        case .alrm:
          return Int32(SIGALRM)
        case .term:
          return Int32(SIGTERM)
        case .user(let sig):
          return Int32(sig)
      }
    }
  }

  public typealias SigActionHandler = @convention (c)(Int32) -> Void

  public class func trap (signal: Signal, action: @escaping SigActionHandler) {
#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
    var signalAction = sigaction(__sigaction_u: unsafeBitCast(action, to: __sigaction_u.self), sa_mask: 0, sa_flags: 0)
    _ = withUnsafePointer(to: &signalAction) { actionPointer in
      sigaction(signal.valueOf, actionPointer, nil)
    }
#elseif os(Linux)
    var sigAction = sigaction()
    sigAction.__sigaction_handler = unsafeBitCast(action, to: sigaction.__Unnamed_union___sigaction_handler.self)
    _ = sigaction(signal.valueOf, &sigAction, nil)
#endif
  }

  public class func trap (signals: [(signal: Signal, action: SigActionHandler)]) {
    for sighandler in signals {
      Signals.trap(signal: sighandler.signal, action: sighandler.action)
    }
  }

  public class func trap (signals: [Signal], action: @escaping SigActionHandler) {
    for signal in signals {
      Signals.trap(signal: signal, action: action)
    }
  }

  public class func raise (signal: Signal) {
#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
    _ = Darwin.raise(signal.valueOf)
#elseif os(Linux)
    _ = Glibc.raise(signal.valueOf)
#endif
  }

  public class func ignore (signal: Signal) {
#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
    _ = Darwin.signal(signal.valueOf, SIG_IGN)
#elseif os(Linux)
    _ = Glibc.signal(signal.valueOf, SIG_IGN)
#endif
  }

  public class func restore (signal: Signal) {
#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
    _ = Darwin.signal(signal.valueOf, SIG_DFL)
#elseif os(Linux)
    _ = Glibc.signal(signal.valueOf, SIG_DFL)
#endif
  }

}