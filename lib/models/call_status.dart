/// A function call status for different function calls
///
// Time-stamp: <Sunday 2025-11-02 15:13:32 +1000 Graham Williams>
///
/// Copyright (C) 2024-2025, Software Innovation Institute, ANU.
///
/// Licensed under the MIT License (the "License").
///
/// License: https://choosealicense.com/licenses/mit/.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
///
///
/// Authors: Jess Moore
library;

/// Solid function call results
enum FileCallStatus {
  /// Function call successful
  success('success'),

  /// Function call fails (unknown or any type of fail)
  fail('fail'),

  /// When file access forbidden
  fileAccessForbidden('fileAccessForbidden'),

  /// When file not exists
  fileNotExists('fileNotExists'),

  /// When file cannot be decrypted (e.g. when a shared file was
  /// shared with a key that cannot be decrypted because the user's
  /// pod has been re-initialised)
  fileNotDecryptable('fileNotDecryptable'),

  /// When file parsing to deserialise note fails
  parsingFail('parsingFail');

  /// Constructor
  const FileCallStatus(this.value);

  /// String value of the function
  final String value;
}
