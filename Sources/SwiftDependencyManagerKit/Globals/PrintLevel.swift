// swiftlint:disable leveled_print file_types_order

import CLISpinner
import Foundation
import Rainbow

/// The print level type.
enum PrintLevel {
    /// Print (potentially) long data or less interesting information. Only printed if tool executed in vebose mode.
    case verbose

    /// Print any kind of information potentially interesting to users.
    case info

    /// Print information that might potentially be problematic.
    case warning

    /// Print information that probably is problematic.
    case error

    var color: Color {
        switch self {
        case .verbose:
            return Color.lightCyan

        case .info:
            return Color.lightBlue

        case .warning:
            return Color.yellow

        case .error:
            return Color.red
        }
    }
}

/// The output format type.
enum OutputFormatTarget {
    /// Output is targeted to a console to be read by developers.
    case human

    /// Output is targeted to Xcode. Native support for Xcode Warnings & Errors.
    case xcode
}

/// Prints a message to command line with proper formatting based on level, source & output target.
///
/// - Parameters:
///   - message: The message to be printed. Don't include `Error!`, `Warning!` or similar information at the beginning.
///   - level: The level of the print statement.
///   - file: The file this print statement refers to. Used for showing errors/warnings within Xcode if run as script phase.
///   - line: The line within the file this print statement refers to. Used for showing errors/warnings within Xcode if run as script phase.
func print(_ message: String, level: PrintLevel, file: String? = nil, line: Int? = nil) {
    switch Constants.outputFormatTarget {
    case .human:
        humanPrint(message, level: level, file: file, line: line)

    case .xcode:
        xcodePrint(message, level: level, file: file, line: line)
    }
}

/// Prints a message and shows a spinner to communicate a longer running task processing at the moment.
///
/// - Parameters:
///   - message: The message to be printed. Don't include `Error!`, `Warning!` or similar information at the beginning.
///   - level: The level of the print statement.
///   - pattern: The pattern to be shown for the spinner. Defaults to `.dots`.
///   - task: Task closure to execute with spinner. Must provide a completion closure to be called when execution completed.
func performWithSpinner(
    _ message: String,
    level: PrintLevel = .info,
    pattern: CLISpinner.Pattern = .dots,
    task: @escaping (@escaping (() -> Void) -> Void) -> Void
) {
    let spinner = Spinner(pattern: pattern, text: message, color: level.color)
    spinner.start()
    spinner.unhideCursor()

    dispatchGroup.enter()
    task { completion in
        spinner.stopAndClear()
        completion()
        dispatchGroup.leave()
    }

    dispatchGroup.wait()
}


private func humanPrint(_ message: String, level: PrintLevel, file: String? = nil, line: Int? = nil) {
    let location = locationInfo(file: file, line: line)
    let message = location != nil ? [location!, message].joined(separator: " ") : message

    switch level {
    case .verbose:
        if GlobalOptions.verbose.value {
            print(currentDateTime(), "🗣 ", message.lightCyan)
        }

    case .info:
        print(currentDateTime(), "ℹ️ ", message.lightBlue)

    case .warning:
        print(currentDateTime(), "⚠️ ", message.yellow)

    case .error:
        print(currentDateTime(), "❌ ", message.red)
    }
}

private func currentDateTime() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    let dateTime = dateFormatter.string(from: Date())
    return "\(dateTime):"
}

private func xcodePrint(_ message: String, level: PrintLevel, file: String? = nil, line: Int? = nil) {
    let location = locationInfo(file: file, line: line)

    switch level {
    case .verbose:
        if GlobalOptions.verbose.value {
            if let location = location {
                print(location, "verbose: sdm: ", message)
            } else {
                print("verbose: sdm: ", message)
            }
        }

    case .info:
        if let location = location {
            print(location, "info: sdm: ", message)
        } else {
            print("info: sdm: ", message)
        }

    case .warning:
        if let location = location {
            print(location, "warning: sdm: ", message)
        } else {
            print("warning: sdm: ", message)
        }

    case .error:
        if let location = location {
            print(location, "error: sdm: ", message)
        } else {
            print("error: sdm: ", message)
        }
    }
}

private func locationInfo(file: String?, line: Int?) -> String? {
    guard let file = file else { return nil }
    guard let line = line else { return "\(file): " }
    return "\(file):\(line): "
}

private let dispatchGroup = DispatchGroup()
