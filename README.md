# RawTerm

It does exactly one thing: read input from the terminal, one single character at a time, without the user having to press enter and without echoing the characters back.

Simple to use: first `enableRawMode()`, then call `readChar()` repeatedly to read input character by character. Finally `disableRawMode()` when you're done.

It supports Unicode, including emojis. If you get invalid characters, make sure your terminal is configured to use UTF8 encoding.

## Using Package.swift

```Swift
// Add to your package dependencies
.package(url: "https://github.com/Swonkie/RawTerm.git", from: "0.1.0")

// Add to your target dependencies
"RawTerm"

// Import the module in your code
import RawTerm
```

## Example

A simple spelling aid:

```Swift
import RawTerm

@main
struct Spell {

	static func main() throws {
		print("Type or paste some text\nPress Esc to quit\n")

		try enableRawMode()
		defer {
			try! disableRawMode()
		}

		while true {
			// print requires an extra \r at the end when in raw mode

			guard let input = try? readChar() else {
				print("Invalid input - make sure the terminal uses UTF8.\r")
				continue
			}
			if input == CharCode.ESC {
				break
			}

			if let spelling = dict[input.lowercased()] {
				print("\(input)  \(spelling)\r")
			} else {
				print("\(input)  \(input)\r")
			}
		}
	}
	
	static let dict = [
		"a": "Alpha",
		"b": "Bravo",
		"c": "Charlie",
		"d": "Delta",
		"e": "Echo",
		"f": "Foxtrott",
		"g": "Golf",
		"h": "Hotel",
		"i": "India",
		"j": "Juliett",
		"k": "Kilo",
		"l": "Lima",
		"m": "Mike",
		"n": "November",
		"o": "Oscar",
		"p": "Papa",
		"q": "Quebec",
		"r": "Romeo",
		"s": "Sierra",
		"t": "Tango",
		"u": "Uniform",
		"v": "Victor",
		"w": "Whiskey",
		"x": "X-Ray",
		"y": "Yankee",
		"z": "Zulu",
	]
}
```

### Sample output

```console
Type or paste some text
Press Esc to quit

R  Romeo
a  Alpha
w  Whiskey
    
I  India
n  November
p  Papa
u  Uniform
t  Tango
!  !
🥸  🥸
```
