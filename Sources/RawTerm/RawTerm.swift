#if os(macOS)
import Darwin
#else
import Glibc
#endif


public enum RawTermError: Error {
	case configurationError(String)
	case readError(String)
}


/// Some common character codes for convenience.
public struct CharCode {
	public static let TAB = "\u{09}"
	public static let RET = "\u{0d}"
	public static let ESC = "\u{1b}"
}


/// `termios` struct to hold original terminal settings.
private var original: termios?


/// Read a single character from STDIN.
/// This assumes the terminal sends Unicode characters with UTF8 encoding.
public func readChar() throws -> String {
	var buffer: [UInt8] = [0, 0, 0, 0]

	// read one byte
	guard read(STDIN_FILENO, &buffer, 1) != -1 else {
		throw RawTermError.readError("Could not read input character")
	}

	// any additional bytes needed for a multibyte character?
	// https://en.wikipedia.org/wiki/UTF-8#Encoding
	let n = if buffer[0] < 0b10000000 { 0 }
	else if buffer[0] >= 0b11110000 { 3 }
	else if buffer[0] >= 0b11100000 { 2 }
	else if buffer[0] >= 0b11000000 { 1 }
	else {
		throw RawTermError.readError("Found invalid UTF8 sequence")
	}

	if n > 0 {
		// read remaining bytes of multibyte character
		guard read(STDIN_FILENO, &buffer[1], n) != -1 else {
			throw RawTermError.readError("Could not read input character")
		}
	}

	return String(decoding: buffer.prefix(n+1), as: UTF8.self)
}


/// Put terminal in raw mode. Input is not echoed, characters are returned immediately.
/// Calling `enableRawMode()` repeatedly has no effect.
public func enableRawMode() throws {
	guard original == nil else {
		// already in raw mode
		return
	}
	original = termios()

	// read attributes to restore state later
	guard tcgetattr(STDIN_FILENO, &original!) == 0 else {
		original = nil
		throw RawTermError.configurationError("Could not read terminal attributes")
	}

	// configure attributes for raw mode
	var raw = original!
	cfmakeraw(&raw)
	// apply attributes
	guard tcsetattr(STDIN_FILENO, TCSANOW, &raw) == 0 else {
		original = nil
		throw RawTermError.configurationError("Could not apply terminal attributes")
	}
}


/// Reset terminal to original settings.
/// Calling `disableRawMode()` repeatedly has no effect.
public func disableRawMode() throws {
	guard original != nil else {
		// not in raw mode
		return
	}
	guard tcsetattr(STDIN_FILENO, TCSANOW, &original!) == 0 else {
		throw RawTermError.configurationError("Could not apply terminal attributes")
	}
	original = nil
}
