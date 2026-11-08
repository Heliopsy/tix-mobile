// SPDX-License-Identifier: AGPL-3.0-or-later

/// How long to wait for a server to accept a connection.
const connectTimeout = Duration(seconds: 15);

/// How long to wait for a response once connected; the server's own limit
/// is 30 seconds.
const receiveTimeout = Duration(seconds: 35);

/// Rows asked for per page of a listing.
const pageSize = 50;

/// Riverpod retry policy: never retry on its own. Every error view offers a
/// retry button, and a refused token will not start working by itself.
Duration? noRetry(int retryCount, Object error) => null;
