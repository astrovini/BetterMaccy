extension String {
  func shortened(to maxLength: Int) -> String {
    // index(offsetBy:limitedBy:) walks at most maxLength characters instead of
    // calling .count which walks the entire string — critical for large clipboard items.
    guard let end = index(startIndex, offsetBy: maxLength, limitedBy: endIndex) else {
      return self
    }
    return String(self[..<end])
  }
}
